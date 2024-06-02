import claripy
import sys
from .range_strategies import *

# autopep8: off
from ..shared.transmission import *
from ..shared.taintedFunctionPointer import *
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


def get_ast_ranges(constraints, ast : claripy.BV):
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
            component.range_with_branches = get_ast_ranges(branches, component.expr)
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
        calculate_range(c, constr, constr_with_branches)

    # Calculate ranges for base sub-components.
    if t.base != None:
        if t.properties['direct_dependent_base_expr'] == None and t.properties['indirect_dependent_base_expr'] == None:
            t.independent_base.range = t.base.range
            t.independent_base.range_with_branches = t.base.range_with_branches
        else:
            calculate_range(t.independent_base, constr, constr_with_branches)


    l.warning(f"base range:  {'NONE' if t.base == None else t.base.range}")
    l.warning(f"independent base range:  {'NONE' if t.independent_base == None else t.independent_base.range}")
    l.warning(f"secret_address range:  {t.secret_address.range}")
    l.warning(f"transmitted_secret range:  {t.transmitted_secret.range}")
    l.warning(f"transmission range:  {t.transmission.range}")
    l.warning("==========================")


def analyse_tfp(t: TaintedFunctionPointer):
    l.warning(f"========= [RANGE] ==========")
    for r in t.registers:
        if t.registers[r].control == TFPRegisterControlType.CONTROLLED or t.registers[r].control == TFPRegisterControlType.POTENTIAL_SECRET:
            t.registers[r].range = get_ast_ranges([x[1] for x in t.registers[r].constraints], t.registers[r].expr)

    t.range = get_ast_ranges([x[1] for x in t.constraints], t.expr)

    l.warning("==========================")
