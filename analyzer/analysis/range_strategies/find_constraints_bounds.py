import claripy
import time
import sys

from . import RangeStrategy
from .infer_isolated import RangeStrategyInferIsolated

# autopep8: off
from ...shared.config import *
from ...shared.utils import *
from ...shared.logger import *
from ...shared.ranges import *
# autopep8: on

l = get_logger("FindConstraintsBounds")

class RangeStrategyFindConstraintsBounds(RangeStrategy):
    infer_isolated_strategy : RangeStrategyInferIsolated

    def __init__(self, infer_isolated_strategy):
        super().__init__()

        self.infer_isolated_strategy = infer_isolated_strategy

    def find_range(self, constraints, ast : claripy.ast.bv.BVS,
                    ast_min : int = None, ast_max : int = None):

        if not constraints:
            return None

        ast_vars = set(get_vars(ast))
        new_constr = set()
        for c in constraints:
            c_vars = set(get_vars(c))
            if ast_vars.intersection(c_vars):
                new_constr.add(c)

        constraints = list(new_constr)


        # --------- Unsigned range
        if ast_min == None or ast_max == None:
            s = claripy.Solver(timeout=global_config["Z3Timeout"])
            s.constraints = constraints
            if ast_min == None:
                ast_min = s.min(ast)
            if ast_max == None:
                ast_max = s.max(ast)

        # Early exit: single value
        if ast_min == ast_max:
            return range_static(ast_min, isolated=False)

        try:
            sat_ranges = _find_sat_distribution(constraints, ast, ast_min, ast_max)
        except claripy.ClaripyZ3Error as e:
            # timeout
            return None

        # --------- One non-satisfiable range

        if sat_ranges != None and len(sat_ranges) == 1:
            # We have one non-satisfiable range, so we can try to treat it as
            # isolated

            r = self.infer_isolated_strategy.find_range([], ast, sat_ranges[0][0], sat_ranges[0][1])

            if r != None and sat_ranges[0][0] > sat_ranges[0][1]:
                # The range wraps around, we have to be sure that the AST range is
                # a simple strided range, otherwise we get two separate disjoint ranges
                # which we cannot describe in our range (e.g., [ast != 0xf, ast <= 0xffff])
                if r.and_mask != None or r.or_mask != None or \
                    ast_max != ((1 << ast.size()) - 1 - (r.stride - 1)) or ast_min != 0:

                    # We have a complex range thus fail (e.g., masking is performed)
                    return None

            return r

        # --------- symbolic + (large) concrete value

        if ast.op == '__add__' and any(not arg.symbolic for arg in ast.args):

            # We try an extra optimization: separating the concrete value
            # from addition. This covers cases like:
            # 0xffffffff81000000 + <BV32 X > with condition x[31:31] != 0
            # (sign extended)

            concrete_value =  next(arg for arg in ast.args if not arg.symbolic).args[0]
            sub_ast = sum([arg for arg in ast.args if arg.symbolic])

            r = self.find_range(constraints, sub_ast, None, None)

            # We only support 'stride mode' ranges
            if r != None and r.and_mask == None and r.or_mask == None:

                return range_from_symbolic_concrete_addition(ast, ast_min, ast_max,
                                                      r.min, r.max, r.stride,
                                                      concrete_value)


        # --------- Can't solve this
        l.warning(f"Cant' solve range: {ast}  ({constraints})")

        return None



def _find_sat_distribution(constraints, ast, start, end):

    not_constraints =  claripy.Not(claripy.And(*constraints))

    # Start with a clean state
    s = claripy.Solver(timeout=global_config["Z3Timeout"])

    if not s.satisfiable(extra_constraints=[ast >= start, ast <= end, not_constraints]):
        # it is not satisfiable, thus we have a full range
        # print(f"Range: {[(start, end)]}")
        return [(start, end)]


    samples = s.eval(ast, 2, extra_constraints=[ast >= start, ast <= end, not_constraints])
    sample_len = len(samples)

    if sample_len == 1:
        value = samples[0]
        if value < start:
            return [(start, end)]
        if value > end:
            return [(start, end)]

        # Range with a "hole"
        return [(value+1, value-1)]

    return None
