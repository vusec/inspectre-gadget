"""
The Scanner is responsible of:

- initializing symbols
- running the symbolic execution engine
- hook all symbolic loads, stores and calls
- label propagation ("secret", "transmission")
- enforcing the memory model (all symbolic loads return a pure symbol)
"""

import angr
import claripy

from . import memory
from .annotations import *
import sys
import traceback

from angr.concretization_strategies import SimConcretizationStrategy

# autopep8: off
from ..shared.logger import *
from ..shared.transmission import *
from ..shared.taintedFunctionPointer import *
from ..shared.config import *
from ..shared.astTransform import *
# autopep8: on

l = get_logger("Scanner")

n_concrete_addr = 0
class DummyConcretizationStrategy(SimConcretizationStrategy):
    """
    Dummy concretization strategy to make ANGR happy. We never use this.
    """
    def _concretize(self, memory, addr, **kwargs):
        global n_concrete_addr
        n_concrete_addr+=8
        return [n_concrete_addr]

def skip_concretization(state: angr.SimState):
    """
    The address concretization constraints will not be saved.
    Since in the after_hook of every load we generate a completely
    new symbolic value, we are effectively eliminating the side-effects
    of concretization.
    """
    state.inspect.address_concretization_add_constraints = False


def getSubstitution(state, addr, addressSubst=True):
    string_to_search = "subst_" if addressSubst else "valuesubst_"
    for g in state.globals.keys():
        if str(g).startswith(string_to_search) and state.globals[g][0] == addr:
            return state.globals[g][1]

    return None


class SplitException(Exception):
    "Splitted state, skipping"
    pass

class Scanner:
    """
    Performs the symbolic execution, keeping track of state splitting and
    all the loads/stores that were encountered.
    """

    transmissions: list[TransmissionExpr]
    loads: list[memory.MemOp]
    stores: list[memory.MemOp]

    cur_id: int
    n_alias: int

    def __init__(self):
        self.transmissions = []
        self.calls = []

        self.loads = []
        self.stores = []
        self.cur_id = 0
        self.n_alias = 0
        self.n_constr = 0
        self.n_subst = 0

        self.states = []
        self.bbs = {}
        self.cur_state = None


    def initialize_regs_and_stack(self, state: angr.sim_state.SimState, config):
        """
        Mark stack locations and registers as attacker-controlled.
        """
        state.regs.rbp = claripy.BVS('rbp', 64, annotations=(UncontrolledAnnotation('rbp'),))
        state.regs.rsp = claripy.BVS('rsp', 64, annotations=(UncontrolledAnnotation('rsp'),))
        state.regs.gs = claripy.BVS('gs', 64, annotations=(UncontrolledAnnotation('gs'),))

        # Attacker-controlled registers.
        for reg in config['controlled_registers']:
            try:
                length = getattr(state.regs, reg).length
            except AttributeError:
                l.critical(f"Invalid register in config! {reg}")

            bvs = claripy.BVS(reg, length, annotations=(AttackerAnnotation(reg),))
            setattr(state.regs, reg, bvs)

        # Attacker-controlled stack locations: save them as stores.
        # TODO: this is a hack. If STL forwarding is disabled, stack variables
        # will not be loaded.
        if 'controlled_stack' in config:
            for region in config['controlled_stack']:
                for offset in range(region['start'], region['end'], region['size']):
                    size = region['size']
                    assert (size in [1, 2, 4, 8])

                    addr = state.regs.rsp + (offset)
                    name = f"rsp_{offset}"
                    bvs = claripy.BVS(name, size * 8, annotations=(AttackerAnnotation(name),))

                    cur_store = memory.MemOp(pc=state.addr,
                                            addr=addr,
                                            val=bvs,
                                            size=size,
                                            id=self.cur_id,
                                            op_type=memory.MemOpType.STORE)
                    state.globals[self.cur_id] = cur_store
                    self.cur_id += 1
                    self.stores.append(cur_store)

    def block_contains_speculation_stop(self, bb : angr.block.Block):
        for instruction in bb.capstone.insns:
            if instruction.mnemonic in global_config["SpeculationStopMnemonics"]:
                return True
        return False

    def history_contains_speculation_stop(self, state):
        for bbl_addr in state.history.bbl_addrs:
            if self.bbs[bbl_addr]['speculation_stop']:
                return True
        return False

    def count_instructions(self, state, instruction_addr):
        n_instr = 0

        for bbl_addr in state.history.bbl_addrs:
            n_instr += self.bbs[bbl_addr]['block'].instructions
            last_bbs_addr = bbl_addr

        # We cannot slice the iterator, so we iterate over the whole
        # list then ignore the last element.
        # This should by faster than creating a hard copy just to slice.
        n_instr -= self.bbs[last_bbs_addr]['block'].instructions

        for addr in self.bbs[last_bbs_addr]['block'].instruction_addrs:
            n_instr += 1
            if addr == instruction_addr:
                break
        return n_instr

    def get_aliases(self, state):
        aliases = []
        for v in state.globals.keys():
            if isinstance(state.globals[v], memory.MemoryAlias):
                aliases.append(state.globals[v])
        return aliases

    def get_constraints(self, state):
        constraints = []
        for v in state.globals.keys():
            if str(v).startswith("constr_"):
                constraints.append(state.globals[v])
        return constraints

    def get_history(self, state):
        branches = []

        for cond, source, target in zip(state.history.jump_guards, state.history.jump_sources, state.history.jump_targets):
            # Check if the condition contains an if-then-else statement,
            # and substitute it with the appropriate choice for this state.
            subst = getSubstitution(state, source)
            if subst != None:
                cond = subst

            outcome = get_outcome(cond, source, target)
            branches.append((source, cond, outcome))

        return branches


    #---------------- GADGET RECORDING ----------------------------
    def check_transmission(self, expr, op_type, state):
        """
        Loads and Stores that have at least a symbol marked as secret
        in their expression are saved as potential transmissions.
        """
        if contains_secret(expr):
            # Create a new transmission object.
            self.transmissions.append(TransmissionExpr(pc=state.scratch.ins_addr,
                                                       expr=expr,
                                                       transmitter=op_type,
                                                       bbls=utils.get_bbls(state),
                                                       branches=self.get_history(state),
                                                       aliases=self.get_aliases(state),
                                                       constraints=self.get_constraints(state),
                                                       n_instr=self.count_instructions(state, state.scratch.ins_addr),
                                                       contains_spec_stop=self.history_contains_speculation_stop(state)
                                                       ))

    def check_tfp(self, state, func_ptr_reg, func_ptr_ast):
        """
        Indirect calls that are attacker-controlled are saved
        as tainted function pointers (a.k.a Dispatch Gadgets).
        """
        if is_attacker_controlled(func_ptr_ast):
            # Check if there is a substitution to be made for this address.
            # This can happen if the state comes from a manual splitting.
            subst = getSubstitution(state, state.scratch.ins_addr)
            if subst != None:
                func_ptr_ast = subst
            else:
                # Check if the symbolic address contains an if-then-else node.
                asts = split_conditions(func_ptr_ast, simplify=False, addr=state.scratch.ins_addr)
                assert(len(asts) >= 1)

                l.info(f"  After transformations: {func_ptr_ast}")

                if len(asts) > 1:
                    self.split_state(self.cur_state, asts, state.scratch.ins_addr)
                    raise SplitException

            # Create a new TFP object.
            tfp = TaintedFunctionPointer(pc=state.scratch.ins_addr,
                                            expr=func_ptr_ast,
                                            reg=func_ptr_reg,
                                            bbls=utils.get_bbls(state),
                                            branches=self.get_history(state),
                                            aliases=self.get_aliases(state),
                                            constraints=self.get_constraints(state),
                                            n_instr=self.count_instructions(state, state.scratch.ins_addr),
                                            contains_spec_stop=self.history_contains_speculation_stop(state),
                                            n_dependent_loads=get_load_depth(func_ptr_ast)
                                            )

            for reg in get_x86_registers():
                reg_ast = getattr(state.regs, reg)
                tfp.registers[reg] = TFPRegister(reg, reg_ast)

            self.calls.append(tfp)


    #---------------- STATE SPLITTING ----------------------------
    def split_state(self, state, asts, addr, subst_addr=None):
        """
        Manually split the state in two sub-states with different conditions.
        Needed e.g. for CMOVEs and SExt. Note that the current state should be
        skipped after splitting, since the split is done at the BB level.
        """
        if subst_addr == None:
            subst_addr = addr

        for a in asts:
            a.expr = dedup_annotations(a.expr)
            # Create a new state.
            s = state.copy()

            # Record a substitution to be made at this address in the new state.
            s.globals[f"subst_{self.n_subst}"] = (subst_addr, a.expr)
            self.n_subst += 1
            # Record the conditions of the new state.
            for constraint in a.conditions:
                s.globals[f"constr_{self.n_constr}"] = constraint
                s.solver.add(constraint[1])
                self.n_constr += 1

            # TODO: Satisfiability check can be expensive, can we do better with ast substitutions?
            if s.solver.satisfiable():
                l.info(f"Added state @{hex(s.addr)}  with condition {[(hex(addr), cond, str(ctype)) for addr, cond, ctype in a.conditions]}")
                s.regs.pc = addr
                self.states.append(s)

    def split_state_store(self, state, addr_asts, value_asts, addr):
        """
        Manually split the state on symbolic stores. Used when the symbolic
        address contains an if-then-else statement.
        """
        for a in addr_asts:
            a.expr = dedup_annotations(a.expr)

            for v in value_asts:
                # Create a new state.
                s = state.copy()

                # Record a substitution to be made at this address in the new state.
                s.globals[f"subst_{self.n_subst}"] = (addr, a.expr)
                self.n_subst += 1
                # Record the conditions of the new state.
                for constraint in a.conditions:
                    s.globals[f"constr_{self.n_constr}"] = constraint
                    s.solver.add(constraint[1])
                    self.n_constr += 1

                # Record the value substitution,
                if v.expr.symbolic:
                    s.globals[f"valuesubst_{self.n_subst}"] = (addr, v.expr)
                    self.n_subst += 1
                    for constraint in v.conditions:
                        s.globals[f"constr_{self.n_constr}"] = constraint
                        s.solver.add(constraint[1])
                        self.n_constr += 1

                # TODO: Satisfiability check can be expensive, can we do better with ast substitutions?
                if s.solver.satisfiable():
                    l.info(f"Added state with condition addr:{a.conditions} val:{v.conditions}")
                    s.regs.pc = addr
                    self.states.append(s)


    #---------------- EXPRESSIONS HANDLING ----------------------------
    def expr_hook_after(self, state: angr.SimState):
        """
        Reduce any expression equivalent to a SignExtension into an If-Then-Else statement,
        and keep track of the original expression through an annotation.
        This enables the scanner to split the state any time one of such expressions
        is used in a Load/Store/Branch instructions.
        """
        if state.inspect.expr_result.op == "Concat":
            state.inspect.expr_result = match_sign_ext(state.inspect.expr_result, state.scratch.ins_addr)

        elif state.inspect.expr_result.op == "SignExt":
            state.inspect.expr_result = sign_ext_to_sum(state.inspect.expr_result, state.scratch.ins_addr)

        elif state.inspect.expr_result.op == "If":
            # We assume any expression that is directly translated as an if-then-else statement is
            # a CMOVE-like instruction.
            if getCmoveAnnotation(state.inspect.expr_result) == None and getSignExtAnnotation(state.inspect.expr_result) == None:
                state.inspect.expr_result = state.inspect.expr_result.annotate(CmoveAnnotation(state.scratch.ins_addr))

    #---------------- LOADS ----------------------------
    def load_hook_before(self, state: angr.SimState):
        """
        Constrain the address of symbolic loads.
        """
        if state.inspect.mem_read_address.symbolic:
            # TODO: Consider only valid addresses?
            # Rule out stupid edge-cases to avoid confusing the solver.
            state.solver.add(state.inspect.mem_read_address > 0x8,
                             state.inspect.mem_read_address < 0xffffffffffffffff-8)

    def load_hook_after(self, state: angr.SimState):
        """
        Create a new symbolic variable for every load, and annotate it with
        the appropriate label.
        """
        load_addr = state.inspect.mem_read_address
        load_len = state.inspect.mem_read_length
        l.info(f"Load@{hex(state.addr)}: {load_addr}")
        l.info(state.solver.constraints)

        # Check if there is a substitution to be made for this address.
        # This can happen if the state comes from a manual splitting.
        subst = getSubstitution(state, state.addr)
        if subst != None:
            load_addr = subst
            l.info(f" Applied substitution! {load_addr}")
        else:
            # Check if the symbolic address contains an if-then-else node.
            asts = split_conditions(load_addr, simplify=False, addr=state.addr)
            assert(len(asts) >= 1)

            l.info(f"  After transformations: {load_addr}")

            if len(asts) > 1:
                self.split_state(state, asts, state.addr)
                raise SplitException

        # Check if we should forward an existing value (STL) or create a new symbol.
        alias_store, stored_val = memory.get_aliasing_store(load_addr, load_len, state)
        if alias_store:
            # Perform Store-to-Load forwarding.
            load_val = stored_val
            l.info(f"Forwarded ({load_val}) from store @({alias_store.addr})")
        else:
            # Create a new symbol to represent the loaded value.
            annotation = propagate_annotations(load_addr, state.addr)
            load_val = claripy.BVS(name=f'LOAD_{load_len*8}[{load_addr}]_{self.cur_id}',
                                    size=load_len*8,
                                    annotations=(annotation,))

        # Overwrite loaded val.
        state.inspect.mem_read_expr = load_val

        # Check for aliasing loads.
        cur_load = memory.MemOp(pc=state.addr,
                                addr=load_addr,
                                val=load_val,
                                size=load_len,
                                id=self.cur_id,
                                op_type=memory.MemOpType.LOAD)
        self.cur_id += 1

        aliases = memory.get_aliasing_loads(cur_load, state)
        for alias in aliases:
            state.globals[f"alias_{self.n_alias}"] = alias
            self.n_alias += 1
            # Add a symbolic constraint to the angr state.
            state.solver.add(alias.to_BV())


        # Save this load in the angr state.
        state.globals[self.cur_id] = cur_load
        self.loads.append(cur_load)

        # Is this load a transmission?
        self.check_transmission(load_addr, TransmitterType.LOAD, state)


    #---------------- STORES ----------------------------
    def store_hook_before(self, state: angr.SimState):
        """
        Record a store (for STL forwarding) and skip its side-effects.
        """
        if not global_config["STLForwarding"]:
            # Don't execute the store architecturally.
            state.inspect.mem_write_length = 0
            return

        store_addr = state.inspect.mem_write_address
        store_len = state.inspect.mem_write_length
        stored_value = state.inspect.mem_write_expr
        l.warning(f"Store@{hex(state.addr)}: [{store_addr}] = {stored_value}")
        l.info(state.solver.constraints)

        # Don't execute the store architecturally.
        state.inspect.mem_write_length = 0

        # Check if there is a substitution to be made for this address or value.
        # This can happen if the state comes from a manual splitting.
        is_subst = False
        subst = getSubstitution(state, state.addr)
        if subst != None:
            store_addr = subst
            is_subst = True
        subst = getSubstitution(state, state.addr, addressSubst=False)
        if subst != None:
            stored_value = subst
            is_subst = True
        l.warning(f"After substitution: Store@{hex(state.addr)}: [{store_addr}] = {stored_value}")


        # Check if the address or value contains an if-then-else node.
        if not is_subst:
            addr_asts = split_conditions(store_addr, simplify=False, addr=state.addr)
            value_asts = split_conditions(stored_value, simplify=False, addr=state.addr)

            l.warning(f" After ast transformation: [{store_addr}] = {stored_value}")

            if len(addr_asts) > 1 or len(value_asts) > 1:
                self.split_state_store(self.cur_state, addr_asts, value_asts, state.addr)
                raise SplitException


        # Save this store in the angr state, so that future loads can check for
        # aliasing.
        cur_store = memory.MemOp(pc=state.addr,
                                addr=store_addr,
                                val=stored_value,
                                size=store_len,
                                id=self.cur_id,
                                op_type=memory.MemOpType.STORE)
        state.globals[self.cur_id] = cur_store
        self.cur_id += 1
        self.stores.append(cur_store)

        # Is this store a transmission?
        self.check_transmission(store_addr, TransmitterType.STORE, state)


    #---------------- INDIRECT CALLS ----------------------------
    def exit_hook_before(self, state : angr.SimState):
        """
        Hook on indirect calls, for Tainted Function Pointers.
        """
        l.info("Exit hook")
        func_ptr_ast = state.inspect.exit_target

        # First case: symbolic target
        if func_ptr_ast.symbolic:
            # Whenever the target is symbolic, and it is not a return, we
            # know we are performing an indirect call.
            block = state.block()
            if block.vex.jumpkind == 'Ijk_Ret':
                return

            # get the register
            instruction = block.capstone.insns[-1].insn
            regs_read, regs_write = instruction.regs_access()

            # exclude all written registers; RSP in case of a call instruction
            if len(regs_read) > len(regs_write):
                regs_read = [x for x in regs_read if x not in regs_write]

            # TODO: Handle indirect branches with multiple registers
            reg_id = regs_read[0]
            func_ptr_reg = instruction.reg_name(reg_id)

            # process the TFP
            self.check_tfp(state, func_ptr_reg, func_ptr_ast)
            # check if it is also a transmission
            self.check_transmission(func_ptr_ast, TransmitterType.CODE_LOAD, state)

            # Stop exploration here
            raise SplitException

        # Second case: jump to indirect thunk
        elif state.inspect.exit_target.args[0] in self.thunk_list:
            exit_target = state.inspect.exit_target.args[0]
            func_ptr_reg = self.thunk_list[exit_target]
            func_ptr_ast = getattr(state.regs, func_ptr_reg)

            # process the TFP
            self.check_tfp(state, func_ptr_reg, func_ptr_ast)
            # check if it is also a transmission
            self.check_transmission(func_ptr_ast, TransmitterType.CODE_LOAD, state)

            # Stop exploration here
            raise SplitException


    def run(self, proj: angr.Project, start_address, config) -> list[TransmissionExpr]:
        """
        Run the symbolic execution engine for a given number of basic blocks.
        """

        state = proj.factory.blank_state(addr=start_address,
                                        add_options={angr.options.SYMBOL_FILL_UNCONSTRAINED_MEMORY,
                                                    angr.options.SYMBOL_FILL_UNCONSTRAINED_REGISTERS,
                                                    angr.options.SIMPLIFY_CONSTRAINTS})

        state.solver._solver.timeout = global_config["Z3Timeout"]

        # Angr does not correctly detect when the asm snippet stops, however,
        # capstone does. As a workaround, we add a hook at the end to create a new
        # basic block and run until that address.
        instructions = proj.factory.block(start_address).capstone.insns
        if not instructions:
            return

        # Concretization.
        # Our implementation never concretizes anything, but we need this
        # to make angr collaborate.
        state.memory.write_strategies = [DummyConcretizationStrategy()]
        state.memory.read_strategies = [DummyConcretizationStrategy()]

        # Hooks.
        state.inspect.b('mem_read', when=angr.BP_BEFORE, action=self.load_hook_before)
        state.inspect.b('mem_read', when=angr.BP_AFTER, action=self.load_hook_after)
        state.inspect.b('mem_write', when=angr.BP_BEFORE, action=self.store_hook_before)
        state.inspect.b('exit', when=angr.BP_BEFORE, action=self.exit_hook_before)
        state.inspect.b('address_concretization', when=angr.BP_AFTER, action=skip_concretization)
        state.inspect.b('expr', when=angr.BP_AFTER, action=self.expr_hook_after)

        self.initialize_regs_and_stack(state, config)
        self.thunk_list = get_x86_indirect_thunks(proj)

        # Run the symbolic execution engine.
        self.states = [state]
        while len(self.states) > 0:
            # Pick the next state.
            self.cur_state = self.states.pop()
            l.info(f"Visiting {hex(self.cur_state.addr)}")

            # Stop if we have explored enough BBs.
            if len([x for x in self.cur_state.history.jump_guards]) >= global_config["MaxBB"]:
                l.error(f"Trimmed. History: {[x for x in self.cur_state.history.jump_guards]}")
                continue

            # Analyze this state.
            try:
                # Disassemble if we're visiting a new BB.
                if self.cur_state.addr not in self.bbs:
                    cur_block = self.cur_state.block()
                    self.bbs[self.cur_state.addr] = {"block" : cur_block,
                        "speculation_stop" : self.block_contains_speculation_stop(cur_block)}
                # "Execute" the state (triggers the hooks we installed).
                next_states = self.cur_state.step()

            except SplitException as e:
                # The state has been manually splitted: don't explore it further.
                l.error(str(e))
                continue
            except (angr.errors.SimIRSBNoDecodeError, angr.errors.UnsupportedIROpError) as e:
                l.error("=============== UNSUPPORTED INSTRUCTION ===============")
                l.error(str(e))
                report_unsupported(e, hex(self.cur_state.addr), hex(start_address), error_type="SCANNER")
                continue
            except angr.errors.UnsupportedDirtyError as e:
                if "IRET" in str(e):
                    continue
                l.error("=============== UNSUPPORTED INSTRUCTION ===============")
                l.error(str(e))
                report_unsupported(e, hex(self.cur_state.addr), hex(start_address), error_type="SCANNER")
                continue
            except Exception as e:
                # Catch test-case end error
                if 'No bytes in memory for block starting at 0x400dead.' == str(e):
                    continue

                l.error("=============== ERROR ===============")
                l.error(str(e))
                if not l.disabled:
                    traceback.format_exc()
                report_error(e, hex(self.cur_state.addr), hex(start_address), error_type="SCANNER")
                continue

            # If we reached this point, the analysis of the BB has completed.
            for ns in next_states:
                # Check if the last branch condition contains an if-then-else statement.
                asts = split_conditions(ns.history.jump_guards[-1], simplify=False, addr=ns.history.jump_sources[-1])
                if len(asts) > 1:
                    # If this is the case, we need to further split the successors.
                    self.split_state(ns, asts, ns.addr, subst_addr=ns.history.jump_sources[-1])
                else:
                    # If there's no splitting, just add the successor as-is.
                    self.states.append(ns)

        # Print all loads.
        from tabulate import tabulate
        l.info(tabulate([[hex(x.pc),  str(x.addr),
                          "0" if get_load_annotation(x.val) == None else get_load_annotation(x.val).depth,
                           str(x.val), str(x.addr.annotations), str(x.val.annotations),
                          "none" if get_load_annotation(x.val) == None else get_load_annotation(x.val).requirements] for x in self.loads],
                        headers=["pc", "addr", "depth", "val", "addr annotations", "val annotations", "deps"]))

