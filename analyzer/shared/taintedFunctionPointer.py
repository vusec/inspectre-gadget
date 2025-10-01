"""
TaintedFunctionPointer object (a.k.a. dispatch gadget).
"""

from enum import Enum
from collections import OrderedDict
from collections.abc import MutableMapping
from claripy import BVS

from .utils import ordered_branches, ordered_constraints
from . import ranges
from .transmission import ControlType, Requirements


def flatten_dict(dictionary, parent_key='', separator='_'):
    """
    Transform a hierarchy of nested objects into a flat dictionary.
    """
    items = []
    for key, value in dictionary.items():
        new_key = parent_key + separator + key if parent_key else key
        if isinstance(value, MutableMapping):
            items.extend(flatten_dict(value, new_key,
                         separator=separator).items())
        else:
            items.append((new_key, value))
    return dict(items)


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
    reg: str
    expr: BVS
    controlled_expr: BVS
    control: ControlType
    control_type: TFPRegisterControlType

    branches: list
    constraints: list
    requirements: Requirements

    range: ranges.AstRange
    range_with_branches: ranges.AstRange
    controlled_range: ranges.AstRange
    controlled_range_with_branches: ranges.AstRange

    is_dereferenced: bool
    reg_dereferenced: list

    def __init__(self, reg, expr, is_dereferenced=False) -> None:
        self.reg = reg
        self.expr = expr
        self.is_dereferenced = is_dereferenced
        self.controlled_expr = None

        self.control = ControlType.UNKNOWN
        self.control_type = TFPRegisterControlType.UNKNOWN
        self.branches = []
        self.constraints = []
        self.requirements = Requirements()
        self.range = None
        self.range_with_branches = None
        self.controlled_range = None
        self.controlled_range_with_branches = None
        self.reg_dereferenced = []

    def __repr__(self) -> str:
        return f"""
        reg: {self.reg}
        expr: {self.expr}
        controlled_expr: {self.controlled_expr}
        control: {self.control}
        control_type: {self.control_type}
        branches: {ordered_branches(self.branches)}
        constraints: {ordered_constraints(self.constraints)}
        requirements: {self.requirements}
        range: {self.range}
        range_with_branches: {self.range_with_branches}
        controlled_range: {self.controlled_range}
        controlled_range_with_branches: {self.controlled_range_with_branches}
        """

    def to_dict(self):
        reg_dereferenced_dict = {}
        for r in self.reg_dereferenced:
            new_dict = {
                r.reg:
                {
                    'reg': r.reg,
                    'expr': str(r.expr),
                    'controlled_expr': str(r.controlled_expr),
                    'control': str(r.control),
                    'control_type': str(r.control_type),
                    'branches': ordered_branches(r.branches),
                    'constraints': ordered_constraints(r.constraints),
                    'controlled_range': dict(ranges.AstRange(0, 0, 0, False).to_dict()
                                             if r.controlled_range == None else r.controlled_range.to_dict()),
                    'controlled_range_with_branches': dict(ranges.AstRange(0, 0, 0, False).to_dict()
                                                           if r.controlled_range_with_branches == None else r.controlled_range_with_branches.to_dict()),
                }
            }

            reg_dereferenced_dict[r.reg] = flatten_dict(new_dict)

        return OrderedDict([
            ("reg", self.reg),
            ("expr", self.expr),
            ("is_dereferenced", self.is_dereferenced),
            ("controlled_expr", self.expr),
            ("control", self.control),
            ("control_type", self.control_type),
            ("branches", ordered_branches(self.branches)),
            ("constraints", ordered_constraints(self.constraints)),
            ("requirements", self.requirements.to_dict()),
            ("range", ranges.AstRange(0, 0, 0, False).to_dict()
             if self.range == None else self.range.to_dict()),
            ("range_with_branches", ranges.AstRange(0, 0, 0, False).to_dict()
             if self.range_with_branches == None else self.range_with_branches.to_dict()),
            ("controlled_range", ranges.AstRange(0, 0, 0, False).to_dict()
             if self.controlled_range == None else self.controlled_range.to_dict()),
            ("controlled_range_with_branches", ranges.AstRange(0, 0, 0, False).to_dict()
             if self.controlled_range_with_branches == None else self.controlled_range_with_branches.to_dict()),
            ("reg_dereferenced", str(reg_dereferenced_dict))
        ])

    def copy(self):
        new_t = TFPRegister(self.reg, self.expr, self.is_dereferenced)
        # Copy all values
        new_t.__dict__.update(self.__dict__)
        # Shallow copy mutable values
        new_t.branches = self.branches.copy()
        new_t.constraints = self.constraints.copy()
        return new_t


class TaintedFunctionPointer():
    """
    A TaintedFunctionPointer (TFP) or Dispatch Gadget consists of an indirect call
    (or jump) that ends up being attacker-controlled in the speculative window.
    These gadgets can be used to stitch together code snippets to for a complete
    transmission gadget.
    """
    uuid: str
    name: str
    address: int
    pc: int
    pc_symbol: str
    address_symbol: str
    expr: BVS
    reg: str

    n_instr: int
    n_control_flow_changes: int

    registers: dict[str, TFPRegister]
    control: ControlType
    contains_spec_stop: bool

    def __init__(self, pc, expr, reg, bbls, branches, constraints, aliases, n_instr, n_control_flow_changes, contains_spec_stop, n_dependent_loads) -> None:
        self.uuid = ""
        self.name = ""
        self.address = 0
        self.pc = pc
        self.pc_symbol = ""
        self.address_symbol = ""

        self.n_instr = n_instr
        self.n_control_flow_changes = n_control_flow_changes
        self.contains_spec_stop = contains_spec_stop
        self.n_dependent_loads = n_dependent_loads
        self.n_branches = len(branches)
        self.reg = reg
        self.expr = expr
        self.control = ControlType.UNKNOWN
        self.range = None
        self.range_with_branches = None
        self.all_branches = []
        self.all_branches.extend(branches)
        self.all_constraints = []
        self.all_constraints.extend(constraints)
        self.aliases = []
        self.aliases.extend(aliases)
        self.bbls = []
        self.bbls.extend(bbls)

        # Constraints only applying on tfp.expr
        self.requirements = Requirements()
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
        control: {self.control}
        range: {self.range}
        range_with_branches: {self.range_with_branches}

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
            ("address_symbol", self.address_symbol),
            ("pc", hex(self.pc)),
            ("pc_symbol", self.pc_symbol),
            ("n_instr", self.n_instr),
            ("n_control_flow_changes", self.n_control_flow_changes),
            ("n_dependent_loads", self.n_dependent_loads),
            ("n_branches", self.n_branches),
            ("contains_spec_stop", self.contains_spec_stop),
            ("reg", self.reg),
            ("expr", self.expr),
            ("control", self.control),
            ("range", ranges.AstRange(0, 0, 0, False).to_dict()
             if self.range == None else self.range.to_dict()),
            ("range_with_branches", ranges.AstRange(0, 0, 0, False).to_dict()
             if self.range_with_branches == None else self.range_with_branches.to_dict()),
            ("branches", ordered_branches(self.constraints)),
            ("constraints", ordered_constraints(self.branches)),
            ("requirements", self.requirements.to_dict()),
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
            if not r.is_dereferenced:
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
                                         n_control_flow_changes=self.n_control_flow_changes,
                                         contains_spec_stop=self.contains_spec_stop,
                                         n_dependent_loads=self.n_dependent_loads)
        new_tfp.control = new_tfp.control
        new_tfp.constraints.extend(self.constraints)
        new_tfp.branches.extend(self.branches)
        new_tfp.requirements = self.requirements
        new_tfp.range = self.range
        new_tfp.controlled.extend(self.controlled)
        new_tfp.uncontrolled.extend(self.uncontrolled)
        new_tfp.unmodified.extend(self.unmodified)
        new_tfp.secrets.extend(self.secrets)
        new_tfp.aliasing.extend(self.aliasing)

        for r in self.registers:
            new_tfp.registers[r] = self.registers[r].copy()

        return new_tfp
