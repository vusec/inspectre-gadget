import claripy
from enum import Enum
import json
from collections import OrderedDict

from . import ranges
from . import utils

class TransmitterType(Enum):
    LOAD = 1,
    STORE = 2,
    CALL = 3

class ControlType(Enum):
    NO_CONTROL = 0,
    REQUIRES_MEM_LEAK = 1,
    REQUIRES_MEM_MASSAGING = 2,
    CONTROLLED = 3,
    UNKNOWN = 4

def component_to_dict(component):
    return TransmissionComponent().to_dict() if component == None else component.to_dict()

class Requirements():
    def __init__(self) -> None:
        self.regs = set()
        self.indirect_regs = {}
        self.direct_regs = set()
        self.mem = set()
        self.const_mem = set()

    def __repr__(self) -> str:
        return f"regs: {self.regs}, mem: {self.mem}, const_mem: {self.const_mem}, direct_regs: {self.direct_regs}, indirect_regs: {self.indirect_regs}"

    def to_dict(self):
        return OrderedDict([
            ('regs' , [str(x) for x in self.regs]),
            ('indirect_regs' , [f"{str(x)}: {self.indirect_regs[x]}" for x in self.indirect_regs]),
            ('direct_regs' , [str(x) for x in self.direct_regs]),
            ('mem' , [str(x) for x in self.mem]),
            ('const_mem' , [str(x) for x in self.const_mem]),
        ])

    def merge(self, other):
        self.regs.update(other.regs)
        self.direct_regs.update(other.direct_regs)

        ind_regs = {}
        # Check if any of the indirect regs has become a direct reg.
        for r in self.indirect_regs:
            if not r in self.direct_regs:
                ind_regs[r] = self.indirect_regs[r]
        # Merge the indirect regs from the incoming requirements.
        for r in other.indirect_regs:
            if not r in self.direct_regs:
                if r not in ind_regs.keys():
                    ind_regs[r] = []
                ind_regs[r].extend(other.indirect_regs[r])

        self.indirect_regs = ind_regs

        self.mem.update(other.mem)
        self.const_mem.update(other.const_mem)


class TransmissionExpr:
    """
    Symbolic expression representing a potential transmission of a secret
    through a covert channel.
    """
    pc: int
    expr: claripy.BV
    transmitter: TransmitterType
    aliases: list[claripy.BV]
    branches: list[tuple[int, claripy.BV, str],]
    constraints: list[tuple[int, claripy.BV]]
    n_instr: int
    contains_spec_stop: bool

    def __init__(self, state, pc: int, expr: claripy.BV, transmitter: TransmitterType, aliases, constraints, n_instr, contains_spec_stop):
        self.pc = pc
        self.expr = expr
        self.transmitter = transmitter
        self.aliases = aliases
        self.constraints = constraints

        self.branches = [(addr,cond,taken) for addr, cond, taken in zip(state.history.jump_sources,
                                    state.history.jump_guards,
                                    utils.branch_outcomes(state.history))]
        self.bbls = [x for x in state.history.bbl_addrs]
        self.n_instr = n_instr
        self.contains_spec_stop = contains_spec_stop

    def __repr__(self):
        return f"""
                pc: {hex(self.pc)}
                expr: {self.expr}
                transmitter: {self.transmitter}
                branches: {self.branches}
                bbls: {self.bbls}
                aliases: {self.aliases}
                constraints: {self.constraints}
                n_instr: {self.n_instr}
                contains_spec_stop: {self.contains_spec_stop}
                """

class TransmissionComponent():
    expr: claripy.BV
    branches: list
    constraints: list[tuple[int, claripy.BV]]
    requirements: Requirements
    range: ranges.AstRange
    range_with_branches: ranges.AstRange
    control: ControlType
    size: int
    max_load_depth: int

    def __init__(self) -> None:
        self.expr = None
        self.branches = []
        self.constraints = []
        self.requirements = Requirements()
        self.range = None
        self.range_with_branches = None
        self.control = ControlType.UNKNOWN
        self.size = 0
        self.max_load_depth = 0

    def __repr__(self):
        return f"""
                expr: {self.expr}
                size: {self.size}
                branches: {[(hex(addr),val) for addr, val in self.branches]}
                constraints: {self.constraints}
                requirements: {self.requirements}
                range: {self.range}
                range_with_branches: {self.range_with_branches}
                control: {self.control}
                n_dependent_loads: {self.max_load_depth}
                """

    def to_dict(self):
        return OrderedDict([
            ('expr', str(self.expr)),
            ('size', str(self.size)),
            ('branches', [str(x) for x in self.branches]),
            ('constraints', [str(x) for x in self.constraints]),
            ('requirements', self.requirements.to_dict()),
            ('range', ranges.AstRange(0,0,False).to_dict() if self.range == None else self.range.to_dict()),
            ('range_w_branches', ranges.AstRange(0,0,False).to_dict() if self.range_with_branches == None else self.range_with_branches.to_dict()),
            ('control', str(self.control)),
            ('n_dependent_loads', str(self.max_load_depth))
        ]
        )


class Transmission():
    # Transmission info.
    uuid : str
    name: str
    address: int
    pc: int
    secret_load_pc: int
    transmitter: TransmitterType
    n_instr: int
    contains_spec_stop: bool
    max_load_depth: int

    # Components.
    transmission: TransmissionComponent
    base: TransmissionComponent
    transmitted_secret: TransmissionComponent
    secret_val: TransmissionComponent
    secret_address: TransmissionComponent

    # Portion of the base that is independent from the secret or secret address
    independent_base: TransmissionComponent

    # Properties found at scanning time.
    aliases: list[claripy.BV]
    branches: list[tuple[int, claripy.BV]]
    branch_requirements: Requirements

    constraints: list[claripy.BV]
    constraint_requirements: Requirements

    all_requirements: Requirements

    # Additional properties attached by analyses.
    properties: dict()

    def __init__(self, t: TransmissionExpr):
        self.uuid = ""
        self.name = ""
        self.address = 0
        self.pc = t.pc
        self.secret_load_pc = 0
        self.transmitter = t.transmitter
        self.n_instr = t.n_instr
        self.contains_spec_stop = t.contains_spec_stop
        self.max_load_depth = 0

        self.transmission = TransmissionComponent()
        self.transmission.expr = t.expr
        self.base = TransmissionComponent()
        self.secret_val = TransmissionComponent()
        self.transmitted_secret = TransmissionComponent()
        self.secret_address = TransmissionComponent()
        self.independent_base = TransmissionComponent()

        self.aliases = t.aliases
        for x in t.aliases:
            assert(' if ' not in str(x))
        self.branches = t.branches
        self.bbls = t.bbls
        # TODO check if branches contain if-then-else
        self.constraints = t.constraints
        self.properties = {}

        self.branch_requirements = Requirements()
        self.constraint_requirements = Requirements()
        self.all_requirements = Requirements()
        self.all_requirements_w_branches = Requirements()

        self.inferable_bits = None

    def __repr__(self):
        return f"""
        uuid: {self.uuid}
        name: {self.name}
        address: {hex(self.address)}
        pc: {hex(self.pc)}
        secret_load_pc: {hex(self.secret_load_pc)}
        transmitter: {self.transmitter}

        transmission:
            {self.transmission}
          |-- base:
            {self.base}
                |-- secret-independent part:
                {self.independent_base}
          |-- transmitted secret:
            {self.transmitted_secret}
          |-- secret addr:
            {self.secret_address}
          |-- secret val:
            {self.secret_val}


        branches: {[(hex(addr), cond, taken) for addr, cond, taken in self.branches]}
        bbls: {[hex(x) for x in self.bbls]}
        branch requirements: {self.branch_requirements}

        constraints: {[(hex(addr), cond) for addr, cond in self.constraints]}
        constraint requirements: {self.constraint_requirements}

        all requirements: {self.all_requirements}
        all requirements_w_branches: {self.all_requirements_w_branches}

        inferable_bits:
            {self.inferable_bits}

        aliases: {self.aliases}
        n_instr: {self.n_instr}
        n_dependent_loads: {self.max_load_depth}
        properties:\n{self.dump_properties()}
        """

    def dump_properties(self):
        outstr = "{\n"
        for key, val in self.properties.items():
            outstr += f"  {key}: {val}\n"
        outstr += "}\n"
        return outstr


    def to_dict(self):
        d = OrderedDict()

        d['uuid'] = self.uuid
        d['name'] = self.name
        d['address'] = hex(self.address)
        d['pc'] = hex(self.pc)
        d['secret_load_pc'] = hex(self.secret_load_pc)
        d['transmitter'] = str(self.transmitter)
        d['n_instr'] = self.n_instr
        d['n_dependent_loads'] = self.max_load_depth
        d['contains_spec_stop'] = self.contains_spec_stop
        d['bbls'] = str([hex(x) for x in self.bbls])

        d['transmission'] = self.transmission.to_dict()

        d['base'] = component_to_dict(self.base)
        d['independent_base'] = component_to_dict(self.independent_base)

        d['transmitted_secret'] = self.transmitted_secret.to_dict()
        d['secret_address'] = self.secret_address.to_dict()
        d['secret_val'] = self.secret_val.to_dict()

        d['branches'] = [{'addr':hex(addr), 'condition': str(cond), 'taken': str(taken)} for addr, cond, taken in self.branches]
        d['branch_requirements'] = self.branch_requirements
        d['constraints'] = [[(hex(addr), cond) for addr, cond in self.constraints]]
        d['constraint_requirements'] = self.constraint_requirements
        d['all_requirements'] = self.all_requirements
        d['all_requirements_w_branches'] = self.all_requirements_w_branches

        d['inferable_bits'] = self.inferable_bits.to_dict()
        d['aliases'] = [str(x.to_BV()) for x in self.aliases]

        for p in self.properties:
            d[p] = str(self.properties[p])

        return d
