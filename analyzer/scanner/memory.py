"""
This module is used to model symbolic memory while avoiding concretization.
Basically, it is used to calculate aliases and overlaps between symbolic
addresses.
"""

from enum import Enum

import angr
import archinfo
import claripy
import sys

# autopep8: off
from ..shared.logger import *
from ..shared.utils import *
from .annotations import *
# autopep8: on

l = get_logger("MemHooks")


class MemOpType(Enum):
    LOAD = 1,
    STORE = 2


class MemOp:
    """
    Symbolic memory operation (load or store).
    """
    pc: int
    addr: claripy.ast.BV
    val: claripy.ast.BV
    size: int
    id: int
    op_type: MemOpType

    def __init__(self, pc: int, addr: claripy.ast.BV, val: claripy.ast.BV, size: int, id: int, op_type: MemOpType):
        self.pc = pc
        self.addr = addr
        self.val = val
        self.size = size
        self.id = id
        self.op_type = op_type

    def __repr__(self) -> str:
        return f"""
        pc : {self.pc}
        addr : {self.addr}
        val : {self.val}
        size : {self.size}
        id : {self.id}
        op_type : {self.op_type}
        """


class RangedSymbol:
    """
    Represents a slice of a symbolic variable.
    """
    sym: claripy.ast.BV
    min: int
    max: int

    def __init__(self, sym, min, max):
        self.sym = sym
        self.min = min
        self.max = max

    def to_BV(self) -> claripy.ast.BV:
        return self.sym[self.max:self.min]

    def __repr__(self) -> str:
        return f"{self.sym}[{self.min}:{self.max}]"


class MemoryAlias:
    """
    Represents an alias between two symbolic variables.
    """
    val1: RangedSymbol
    val2: RangedSymbol

    def __init__(self, val1: RangedSymbol, val2: RangedSymbol):
        self.val1 = val1
        self.val2 = val2

    def get_involved_vars(self):
        return [self.val1.sym, self.val2.sym]

    def __repr__(self) -> str:
        return f"{self.val1} == {self.val2}"

    def is_symbolic(self):
        return is_sym_expr(self.val1.sym) or is_sym_expr(self.val2.sym)

    def to_BV(self):
        return self.val1.to_BV() == self.val2.to_BV()

EDGE_BOUNDS_SIZE = 0x1000

def get_edge_constraints(addr):
    """
    Get constraints to prevent under- and overflow of an addr
    """
    return [addr > EDGE_BOUNDS_SIZE, addr < 0xffffffffffffffff - EDGE_BOUNDS_SIZE]

def get_constraints_for_expr(state, expr) -> list:
    """
    Get all constraints that are related to expr
    """
    all_constraints = state.solver.constraints

    if not all_constraints:
        return []

    splitted_constraints = state.solver._solver._split_constraints(all_constraints)
    all_groups = [group[0] for group in splitted_constraints]
    # Get all independent groups
    independent_groups = merge_dependent_sets(all_groups)

    # find our group
    common_group = set()
    for g in independent_groups:
        if expr.variables & g:
            common_group = g
            break

    # get all the constraints of our group
    constraints = []
    for g, c in splitted_constraints:
        if common_group & g:
            constraints.append(c)

    return constraints

def is_simple_isolated_expression(state, expr):
    """
    Returns if a expression is simple (depth <= 2, only add/sub) and
    is independent from constraints (isolated)
    """
    simple_ops = ['__add__', '__sub__']

    if expr.depth == 1 or (expr.depth == 2 and expr.op in simple_ops):
        c =  get_constraints_for_expr(state, expr)
        if not c:
            return True

    return False

def concrete_value_overlaps_with(val1, size1, val2, size2):
    return not (val1 + size1 < val2 or val2 + size2 < val1)


def addr_overlaps_with(addr1: claripy.ast.BV, size1 : int, addr2: claripy.ast.BV, size2: int, state: angr.SimState) -> bool:
    """
    Check if the two accesses (addresses + size) overlap.
    Note that, since we are dealing with symbolic loads, the result
    is true only if the two symbolic addresses _must_ overlap, i.e. there
    is no possible solution where they don't.
    """
    assert(size1 < EDGE_BOUNDS_SIZE and size2 < EDGE_BOUNDS_SIZE)

    # fast-path: two concrete values
    if addr1.concrete and addr2.concrete:
        return concrete_value_overlaps_with(addr1.concrete_value, size1, addr2.concrete_value, size2)

    # fast-path: two independent expressions
    if not (addr1.variables & addr2.variables):
        if addr1.symbolic and 2 ** addr1.length > size2:
            if is_simple_isolated_expression(state, addr1):
                return False

        if addr2.symbolic and 2 ** addr2.length > size1:
            if is_simple_isolated_expression(state, addr2):
                return False

    # slow-path: complicated expr or expr with constraints, we use the solver
    constraints = []
    if addr1.symbolic:
        constraints += get_edge_constraints(addr1)
    elif addr2.symbolic:
        constraints += get_edge_constraints(addr2)

    if not state.solver.satisfiable(extra_constraints=constraints):
        return False


    # If this condition is satisfiable, there is at least one solution for
    # addr1 and addr2 in which they don't overlap.
    no_overlap = claripy.Or(addr2 >= addr1 + size1, addr1 >= addr2 + size2)
    constraints.append(no_overlap)

    # In the opposite case (not satisfiable), there is _no_ solution in which
    # they are separate.
    return not state.solver.satisfiable(extra_constraints=constraints)


def mem_op_overlaps_with(load1: MemOp, load2: MemOp, state: angr.SimState) -> bool:
    """
    Check if the memory region accessed by load1 overlaps the region of
    load2. Note that, since we are dealing with symbolic loads, the result
    is true only if the two symbolic addresses _must_ overlap, i.e. there
    is no possible solution where they don't.
    """

    return addr_overlaps_with(load1.addr, load1.size, load2.addr, load2.size, state)


def get_overlap(load1: MemOp, load2: MemOp, state: angr.SimState):
    """
    Args: two overlapping symbolic memory operations.
    Returns: [memop1, memop2, offset] such that memop1.addr + offset == memop2.
    Note that we don't handle the case in which the two can overlap
    in more than one way.
    """

    edge_const = []
    if load1.addr.symbolic:
        edge_const += get_edge_constraints(load1.addr)
    elif load2.addr.symbolic:
        edge_const += get_edge_constraints(load2.addr)

    if not state.solver.satisfiable(extra_constraints=edge_const):
        return None, None, 0

    # Consider only these offsets for possible overlaps.
    for i in [0, 1, 2, 4]:

        if not state.solver.satisfiable(extra_constraints=[load1.addr != load2.addr + i] + edge_const):
            l.error("Overlap found: {} ~~ {} (offset {})".format(
                load1.addr, load2.addr, i))
            return load2, load1, i

        if not state.solver.satisfiable(extra_constraints=[load1.addr + i != load2.addr] + edge_const):
            l.error("Overlap found: {} (offset {}) ~~ {}".format(
                load1.addr, i, load2.addr))
            return load1, load2, i

    return None, None, 0


def is_load_obj(item):
    return


def get_previous_loads(state: angr.SimState):
    return filter(lambda x: isinstance(x, MemOp) and x.op_type == MemOpType.LOAD, state.globals.values())


def get_aliases(state: angr.SimState) -> MemoryAlias:
    return filter(lambda x: isinstance(x, MemoryAlias), state.globals.values())


def get_aliasing_loads(this: MemOp, state: angr.SimState, alias_store) -> list[MemoryAlias]:
    """
    Check if a load aliases with any other previous load.
    """

    # If the state is already non-sat, there's no meaning to do this.
    if not state.solver.satisfiable():
        return []

    aliasing_loads = []
    prev_loads = get_previous_loads(state)

    if alias_store:
        prev_loads = filter(lambda p: p.id >= alias_store.id, prev_loads)

    for prev in prev_loads:
        if mem_op_overlaps_with(this, prev, state):
            memop1, memop2, off = get_overlap(this, prev, state)

            if memop1 == None:
                # TODO: Handle this properly.
                l.error(
                    f"Bailing out: Unhandled aliasing condition between {this.addr} and {prev.addr}")
            else:
                val1 = memop1.val
                val2 = memop2.val
                sz1 = memop1.size
                sz2 = memop2.size

                #     addr1[0]                   addr1[sz1]
                #       |---------------------------|
                #       | <-off->  |   <-overlap->  |
                #                  |----------------------------|
                #               addr2[0]                    addr2[sz2]
                #
                #                  | <-overlap-> |
                #                  |-------------|
                #              addr2[0]       addr2[sz2]
                #

                # Calculate length of overlap.
                overlap = min(sz1 - off, sz2)

                # Calculate overlapping ranges.
                range1 = RangedSymbol(sym=val1, max=(
                    off + overlap) * 8 - 1, min=off * 8)
                range2 = RangedSymbol(sym=val2, max=overlap * 8 - 1, min=0)

                memory_alias = MemoryAlias(range1, range2)

                if claripy.is_true(MemoryAlias(range1, range2).to_BV()):
                    # Alias between the same value, thus always true
                    # We can skip
                    continue

                # Return this overlap.
                aliasing_loads.append(memory_alias)
        # else:
            # l.info("No overlap")
            # TODO: force them to never alias in the opposite case?
            # state.solver.add(prev.addr != cur.addr)

    return aliasing_loads

def get_previous_stores(state: angr.SimState):
    return filter(lambda x: (isinstance(x, MemOp) and x.op_type == MemOpType.STORE), state.globals.values())

def get_aliasing_store(load_addr: claripy.ast.BV, load_size: int, load_id: int, state: angr.SimState):
    """
    Return the latest store that aliases with the given load and its value.
    """

    # If the state is already non-sat, there's no meaning to do this.
    if not state.solver.satisfiable():
        return None, None

    prev_stores = get_previous_stores(state)
    overlapping_stores = []

    for prev_s in prev_stores:
        if addr_overlaps_with(load_addr, load_size, prev_s.addr, prev_s.size, state):
            overlapping_stores.append(prev_s)


    if not overlapping_stores:
        # No aliasing stores
        return None, None

    # Sort the stores
    overlapping_stores.sort(key=lambda x: x.id)
    last_store = overlapping_stores[-1]

    if last_store.size == load_size \
        and not state.solver.satisfiable(extra_constraints=[load_addr != last_store.addr]):
        #  The last store is an exact match (both addr + length)! -> Easy case
        return last_store, last_store.val

    else:
        # We are using angr default memory model to handle overlapping stores
        blank_state = state.project.factory.blank_state()
        blank_state.solver.add(*state.solver.constraints)

        if load_addr.symbolic:
            blank_state.solver.add(*get_edge_constraints(load_addr))

        for s in overlapping_stores:
            if s.addr.symbolic:
                blank_state.solver.add(*get_edge_constraints(s.addr))

        # We first store a new expr on load_addr, to fill any possible blank spots
        annotation = propagate_annotations(load_addr, state.scratch.ins_addr)
        gap_expr = claripy.BVS(name=f"LOAD_{load_size*8}[{load_addr}_{load_id}",
                                        size=load_size * 8,
                                        annotations=(annotation,), explicit_name=True)

        blank_state.memory.store(load_addr, gap_expr, endness=archinfo.Endness.LE)

        # Now we store the stores, oldest first
        for s in overlapping_stores:
            blank_state.memory.store(s.addr, s.val, endness=archinfo.Endness.LE)

        # Now we load our addr, we let Angr handle all the crazy overlaps :D
        load_val = blank_state.memory.load(load_addr, load_size, endness=archinfo.Endness.LE)

        # TODO: Handle multiple stores in get_aliasing_loads()
        # for now we simply returns the newest store, however, this may
        # give incorrect get_aliasing_loads() results if in the future a new
        # PARTLY overlapping store is stored
        return last_store, load_val
