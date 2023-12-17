import claripy
import sys
import itertools

from .range_strategies import *

# autopep8: off
from ..shared.taintedFunctionPointer import *
from ..shared.utils import *
from ..shared.logger import *
from ..shared.config import *
from ..shared.astTransform import *
from ..analysis.dependencyGraph import DepGraph, is_expr_controlled
# autopep8: on

l = get_logger("TFPAnalysis")


def get_dependency_graph(t: TaintedFunctionPointer):
    d = DepGraph()
    d.add_nodes(t.expr)
    for r in t.registers:
        d.add_nodes(t.registers[r].expr)
    d.add_aliases(map(lambda x: x.to_BV(), t.aliases))
    d.add_constraints([x[1] for x in t.constraints])
    d.resolve_dependencies()
    return d

def is_same_var(expr: claripy.BV, reg):
    syms = get_vars(expr)
    assert(len(syms) == 1)
    sym = syms.pop()

    l.info(f"Testing {sym.args[0]} against {reg}")
    return sym.args[0] == reg


def analyse(t: TaintedFunctionPointer):
    l.warning(f"========= [TFP] ==========")

    substitutions = []
    needs_substitutions = False
    # Handle if-then-else statements in registers.
    for r in t.registers:
        expr = match_sign_ext(t.registers[r].expr)
        expr = sign_ext_to_sum(expr)
        asts = split_if_statements(expr)
        assert(len(asts) >= 1)
        if len(asts) > 1:
            needs_substitutions = True
            substitutions.append([(r,a) for a in asts])

    if not needs_substitutions:
        tfps = [t]
    else:
        # Generate all possible combinations of if-then-else statements.
        tfps = []
        for subst in itertools.product(*substitutions):
            new_t = t.copy()
            for s in subst:
                new_t.registers[s[0]].expr = s[1].expr
                new_t.registers[s[0]].constraints.extend([(t.address, x) for x in s[1].conditions])
                new_t.constraints.extend([(t.address, x) for x in s[1].conditions])
                if s[0] == t.reg:
                    new_t.expr = s[1].expr

            tfps.append(new_t)

    # Analyse tfps
    final_tfps = []
    for tfp in tfps:
        # If the TFP is not really controlled, skip.
        if not is_sym_expr(tfp.expr) or not is_expr_controlled(tfp.expr):
            continue

        d = get_dependency_graph(tfp)

        # Analyse registers control.
        for r in tfp.registers:
            if tfp.registers[r].reg == tfp.reg:
                tfp.registers[r].control = TFPRegisterControlType.IS_TFP_REGISTER
            elif not is_sym_expr(tfp.registers[r].expr) or not is_expr_controlled(tfp.registers[r].expr):
                tfp.registers[r].control = TFPRegisterControlType.UNCONTROLLED
                tfp.uncontrolled.append(r)
            elif not (d.is_independently_controllable(tfp.registers[r].expr, [tfp.expr], check_constraints=True, check_addr=False)
                       and d.is_independently_controllable(tfp.expr, [tfp.registers[r].expr], check_constraints=True, check_addr=False)):
                tfp.registers[r].control = TFPRegisterControlType.DEPENDS_ON_TFP_EXPR
                tfp.aliasing.append(r)
            elif not (d.is_independently_controllable(tfp.registers[r].expr, [tfp.expr], check_constraints=True, check_addr=True)
                      and d.is_independently_controllable(tfp.expr, [tfp.registers[r].expr], check_constraints=True, check_addr=True)):
                tfp.registers[r].control =  TFPRegisterControlType.INDIRECTLY_DEPENDS_ON_TFP_EXPR
                tfp.aliasing.append(r)
            elif is_sym_var(tfp.registers[r].expr) and is_same_var(tfp.registers[r].expr, tfp.registers[r].reg):
                tfp.registers[r].control = TFPRegisterControlType.UNMODIFIED
                tfp.unmodified.append(r)
            else:
                tfp.registers[r].control = TFPRegisterControlType.CONTROLLED
                tfp.controlled.append(r)

        final_tfps.append(tfp)

    l.warning(f"Found {len(final_tfps)} tfps")
    l.warning("==========================")
    return final_tfps

