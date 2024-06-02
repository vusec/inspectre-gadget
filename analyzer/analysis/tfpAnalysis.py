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
from ..scanner.annotations import get_load_annotation, LoadAnnotation
# autopep8: on

l = get_logger("TFPAnalysis")


def get_dependency_graph(t: TaintedFunctionPointer):
    d = DepGraph()
    d.add_nodes(t.expr)
    for r in t.registers:
        d.add_nodes(t.registers[r].expr)
    d.add_aliases(map(lambda x: x.to_BV(), t.aliases))
    d.add_constraints([x[1] for x in t.all_constraints])
    d.resolve_dependencies()
    return d

def is_same_var(expr: claripy.BV, reg):
    syms = get_vars(expr)
    assert(len(syms) == 1)
    sym = syms.pop()

    l.info(f"Testing {sym.args[0]} against {reg}")
    return sym.args[0] == reg

def is_potential_secret(d: DepGraph, expr: claripy.BV, tfp_expr: claripy.BV):
    """
    Check if the expression is independent from the tfp and contains loads
    whose address is independent from the tfp.
    """
    has_load_anno = False
    for v in get_vars(expr):
        if not (d.is_independent(tfp_expr, v, check_constraints=True, check_addr=True) ):
            return False

        anno = get_load_annotation(v)
        if anno != None:
            has_load_anno = True
            if not (d.is_independent(tfp_expr, anno.read_address_ast, check_constraints=True, check_addr=True)):
                return False

    return has_load_anno


def analyse(t: TaintedFunctionPointer):
    l.warning(f"========= [TFP] ==========")

    substitutions = []
    needs_substitutions = False

    # Handle if-then-else statements in register expressions.
    for r in t.registers:
        asts = split_conditions(t.registers[r].expr, simplify=False, addr=t.address)

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
                new_t.registers[s[0]].constraints.extend(s[1].conditions)
                new_t.all_constraints.extend(s[1].conditions)
                if s[0] == t.reg:
                    new_t.constraints.extend(s[1].conditions)
                    new_t.expr = s[1].expr

            s = claripy.Solver(timeout=global_config["Z3Timeout"])
            if not s.satisfiable(extra_constraints=[x[1] for x in new_t.all_constraints]):
                # Skipping.. this combination of constraints is not satisfiable
                continue

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
            elif is_potential_secret(d, tfp.registers[r].expr, tfp.expr):
                tfp.registers[r].control = TFPRegisterControlType.POTENTIAL_SECRET
                tfp.secrets.append(r)
            else:
                tfp.registers[r].control = TFPRegisterControlType.CONTROLLED
                tfp.controlled.append(r)

        final_tfps.append(tfp)

    l.warning(f"Found {len(final_tfps)} tfps")
    l.warning("==========================")
    return final_tfps

