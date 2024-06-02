"""
TaintedFunctionPointer object (a.k.a. dispatch gadget).
"""

from enum import Enum
from collections import OrderedDict
from claripy import BVS

from .utils import ordered_branches, ordered_constraints
from . import ranges

class TFPRegisterControlType(Enum):
    UNMODIFIED = 1,
    CONTROLLED = 2,
    UNCONTROLLED = 3,
    DEPENDS_ON_TFP_EXPR = 4,
    INDIRECTLY_DEPENDS_ON_TFP_EXPR = 5,
    IS_TFP_REGISTER = 6,
    POTENTIAL_SECRET = 7,
    UNKNOWN = 8

class TFPRegister():
    control: TFPRegisterControlType
    expr: BVS

    def __init__(self, reg, expr) -> None:
        self.reg = reg
        self.expr = expr

        self.control = TFPRegisterControlType.UNKNOWN
        self.branches = []
        self.constraints = []
        self.requirements = []
        self.range = None

    def __repr__(self) -> str:
        return f"""
        reg: {self.reg}
        expr: {self.expr}
        control: {self.control}
        branches: {ordered_branches(self.branches)}
        constraints: {ordered_constraints(self.constraints)}
        requirements: {self.requirements}
        range: {self.range}
        """

    def to_dict(self):
        return OrderedDict([
        ("reg", self.reg),
        ("expr", self.expr),
        ("control", self.control),
        ("branches", ordered_branches(self.branches)),
        ("constraints", ordered_constraints(self.constraints)),
        ("requirements", self.requirements),
        ("range", self.range)
        ])

    def copy(self):
        new_t = TFPRegister(self.reg, self.expr)
        new_t.control = self.control
        new_t.branches.extend(self.branches)
        new_t.constraints.extend(self.constraints)
        new_t.requirements.extend(self.requirements)
        new_t.range = self.range
        return new_t


class TaintedFunctionPointer():
    uuid : str
    name: str
    address: int
    pc: int

    registers: dict[str, TFPRegister]

    def __init__(self, pc, expr, reg, bbls, branches, constraints,  aliases, n_instr, contains_spec_stop, n_dependent_loads) -> None:
        self.uuid = ""
        self.name = ""
        self.address = 0
        self.pc = pc

        self.n_instr = n_instr
        self.contains_spec_stop = contains_spec_stop
        self.n_dependent_loads = n_dependent_loads
        self.n_branches = len(branches)
        self.reg = reg
        self.expr = expr
        self.range = None
        self.all_branches = []
        self.all_branches.extend(branches)
        self.all_constraints = []
        self.all_constraints.extend(constraints)
        self.aliases = []
        self.aliases.extend(aliases)
        self.bbls = []
        self.bbls.extend(bbls)

        # Constraints only applying on tfp.expr
        self.requirements = []
        self.constraints = []
        self.branches = []

        # Summarizing lists
        self.controlled = []
        self.uncontrolled = []
        self.unmodified = []
        self.aliasing = []
        self.secrets = []

        self.registers = dict()

    def __repr__(self) -> str:
        return f"""
        uuid: {self.uuid}
        name: {self.name}
        address: {hex(self.address)}
        n_instr: {self.n_instr}
        n_dependent_loads: {self.n_dependent_loads}
        n_branches: {self.n_branches}

        pc: {hex(self.pc)}
        reg: {self.reg}
        expr: {self.expr}

        controlled: {self.controlled}
        uncontrolled: {self.uncontrolled}
        unmodified: {self.unmodified}
        secrets: {self.secrets}
        aliasing: {self.aliasing}

        bbls: {[hex(x) for x in self.bbls]}
        all_branches: {ordered_branches(self.all_branches)}
        all_constraints: {ordered_constraints(self.all_constraints)}
        aliases: {self.aliases}
        requirements: {self.requirements}
        registers:
            {self.registers}
        """

    def to_dict(self):
        d = OrderedDict([
        ("uuid", self.uuid),
        ("name", self.name),
        ("address", hex(self.address)),
        ("n_instr", self.n_instr),
        ("n_dependent_loads", self.n_dependent_loads),
        ("n_branches", self.n_branches),
        ("contains_spec_stop", self.contains_spec_stop),
        ("pc", hex(self.pc)),
        ("reg", self.reg),
        ("expr", self.expr),
        ("range", ranges.AstRange(0,0,0,False).to_dict() if self.range == None else self.range.to_dict()),
        ("branches", ordered_branches(self.constraints)),
        ("constraints", ordered_constraints(self.branches)),
        ("requirements", self.requirements),
        ("all_branches", ordered_branches(self.all_constraints)),
        ("all_constraints", ordered_constraints(self.all_branches)),
        ("aliases", self.aliases),
        ("bbls", [hex(x) for x in self.bbls]),
        ("controlled", self.controlled),
        ("n_controlled", len(self.controlled)),
        ("uncontrolled", self.uncontrolled),
        ("unmodified", self.unmodified),
        ("n_unmodified", len(self.unmodified)),
        ("secrets", self.secrets),
        ("aliasing", self.aliasing)
        ])

        for r in self.registers.values():
            d[r.reg] = r.to_dict()

        return d

    def copy(self):
        new_tfp = TaintedFunctionPointer(pc=self.pc,
                                         expr=self.expr,
                                         reg=self.reg,
                                         bbls=self.bbls,
                                         branches=self.all_branches,
                                         constraints=self.all_constraints,
                                         aliases=self.aliases,
                                         n_instr=self.n_instr,
                                         contains_spec_stop=self.contains_spec_stop,
                                         n_dependent_loads=self.n_dependent_loads)
        new_tfp.constraints.extend(self.constraints)
        new_tfp.branches.extend(self.branches)
        new_tfp.requirements.extend(self.requirements)
        new_tfp.range = self.range
        new_tfp.controlled.extend(self.controlled)
        new_tfp.uncontrolled.extend(self.uncontrolled)
        new_tfp.unmodified.extend(self.unmodified)
        new_tfp.secrets.extend(self.secrets)
        new_tfp.aliasing.extend(self.aliasing)

        for r in self.registers:
            new_tfp.registers[r] = self.registers[r].copy()
        return new_tfp
