import claripy
import sys
from .range_strategies import *

# autopep8: off
from ..shared.transmission import *
from ..shared.taintedFunctionPointer import *
from ..shared.secretDependentBranch import *
from ..shared.halfGadget import HalfGadget
from ..shared.utils import *
from ..shared.logger import *
from ..shared.config import *
# autopep8: on

l = get_logger("RangeAnalys")

__range_strategies = [
    RangeStrategySmallSet(),
    RangeStrategyInferIsolated(),
    RangeStrategyFindConstraintsBounds(RangeStrategyInferIsolated()),
    RangeStrategyFindMasking()
]


def get_constraints_on_ast(ast, constraints):
    """
    get_relevant_asts returns a list with ast's which have at least 1
    variable in common with base_ast
    """
    s = claripy.Solver(timeout=global_config["Z3Timeout"])
    relevant_constraints = []

    base_variables = set(ast.variables)
    splitted_constraints = s._split_constraints(constraints, concrete=False)

    for variables, sub_constraints in splitted_constraints:
        if variables & base_variables:
            relevant_constraints += sub_constraints

    return relevant_constraints


def get_ast_ranges(constraints, ast: claripy.ast.BV):
    l.info(f"Getting range for {ast}")

    # We calculate the min and max once
    s = claripy.Solver(timeout=global_config["Z3Timeout"])
    s.constraints = constraints.copy()
    ast_min = s.min(ast)
    ast_max = s.max(ast)

    for strategy in __range_strategies:
        ast_range = strategy.find_range(constraints, ast, ast_min, ast_max)

        if ast_range:
            l.info(f"Range: {ast_range}")
            return ast_range

    raise Exception("Could not find any range")


def calculate_range(component: TransmissionComponent, constraints, branches):
    if component != None:
        component.range = get_ast_ranges(constraints, component.expr)

        # Calculate ranges considering also branch constraints.
        if len(branches) > 0:
            component.range_with_branches = get_ast_ranges(
                branches, component.expr)
        else:
            component.range_with_branches = component.range


def analyse(t: Transmission):
    l.warning(f"========= [RANGE] ==========")

    # Pre-compute constraint sets.
    constr = []
    constr.extend([x[1] for x in t.constraints])

    constr_with_branches = []
    if len(t.branches) > 0:
        constr_with_branches.extend([x[1] for x in t.constraints])
        constr_with_branches.extend([x[1] for x in t.branches])

    # Calculate ranges for each component
    for c in [t.base, t.transmitted_secret, t.secret_address, t.transmission]:
        if c != None:
            constr = [x[1] for x in c.constraints]
            constr_with_branches = [x[1] for x in c.branches]
            constr_with_branches.extend(constr)
            calculate_range(c, constr, constr_with_branches)

    # Calculate ranges for base sub-components.
    if t.base != None and t.independent_base != None:
        if t.properties['direct_dependent_base_expr'] == None and t.properties['indirect_dependent_base_expr'] == None:
            t.independent_base.range = t.base.range
            t.independent_base.range_with_branches = t.base.range_with_branches
        else:
            constr = [x[1] for x in t.independent_base.constraints]
            constr_with_branches = [x[1] for x in t.independent_base.branches]
            constr_with_branches.extend(constr)
            calculate_range(t.independent_base, constr, constr_with_branches)

    l.warning(f"base range:  {'NONE' if t.base == None else t.base.range}")
    l.warning(
        f"independent base range:  {'NONE' if t.independent_base == None else t.independent_base.range}")
    l.warning(f"secret_address range:  {t.secret_address.range}")
    l.warning(f"transmitted_secret range:  {t.transmitted_secret.range}")
    l.warning(f"transmission range:  {t.transmission.range}")
    l.warning("==========================")


def analyse_tfp(t: TaintedFunctionPointer):
    l.warning(f"========= [RANGE] ==========")

    for r in t.registers.values():
        if r.control in (ControlType.REQUIRES_MEM_LEAK, ControlType.REQUIRES_MEM_MASSAGING, ControlType.CONTROLLED) \
                or r.control_type == TFPRegisterControlType.IS_TFP_REGISTER:
            constr = [x[1] for x in r.constraints]
            constr_with_branches = [x[1] for x in r.branches]
            constr_with_branches.extend(constr)
            calculate_range(r, constr, constr_with_branches)

            if r.controlled_expr != None:
                r.controlled_range = get_ast_ranges(constr, r.controlled_expr)
                if len(r.branches) > 0:
                    r.controlled_range_with_branches = get_ast_ranges(
                        constr_with_branches, r.controlled_expr)
                else:
                    r.controlled_range_with_branches = r.controlled_range

    # Calculate for tfp expr
    constr = [x[1] for x in t.constraints]
    constr_with_branches = [x[1] for x in t.branches]
    constr_with_branches.extend(constr)
    calculate_range(t, constr, constr_with_branches)

    l.warning("==========================")


def analyse_half_gadget(g: HalfGadget):
    l.warning(f"========= [RANGE] ==========")

    # Pre-compute constraint sets.
    constr = []
    constr.extend([x[1] for x in g.constraints])

    constr_with_branches = []
    if len(g.branches) > 0:
        constr_with_branches.extend([x[1] for x in g.constraints])
        constr_with_branches.extend([x[1] for x in g.branches])

    # Calculate ranges for each component
    for c in [g.loaded, g.base, g.uncontrolled_base, g.attacker]:
        calculate_range(c, constr, constr_with_branches)

    l.warning(f"base range:  {'NONE' if g.base == None else g.base.range}")
    l.warning(
        f"uncontrolled_base range:  {'NONE' if g.uncontrolled_base == None else g.uncontrolled_base.range}")
    l.warning(f"attacker range:  {g.attacker.range}")
    l.warning("==========================")


def analyze_secret_dependent_branch(sdb: SecretDependentBranch):

    # First analyze the transmission components
    analyse(sdb)

    # Pre-compute constraint sets.
    constr = []
    constr.extend([x[1] for x in sdb.constraints])

    constr_with_branches = []
    if len(sdb.branches) > 0:
        constr_with_branches.extend([x[1] for x in sdb.constraints])
        constr_with_branches.extend([x[1] for x in sdb.branches])

    calculate_range(sdb.cmp_value, constr, constr_with_branches)
    calculate_range(sdb.controlled_cmp_value, constr, constr_with_branches)

    l.warning(f"cmp_value range:  {sdb.cmp_value.range}")
    l.warning(
        f"controlled_cmp_value range:  {'NONE' if sdb.controlled_cmp_value == None else sdb.controlled_cmp_value.range}")
    l.warning("==========================")
