import claripy
import sys

from . import RangeStrategy

# autopep8: off
from ...shared.ranges import *
from ...shared.config import *
# autopep8: on

def _list_to_stride_range(numbers : list):
    assert(len(numbers) > 1)
    stride = numbers[1] - numbers[0]

    for i in range(0, len(numbers) - 1):
        if numbers[i] + stride != numbers[i+1]:
            return None

    return AstRange(min=numbers[0] , max=numbers[-1], ast_size=0,
                    exact=True, isolated=True,
                    intervals=[Interval(numbers[0], numbers[-1], stride)])


class RangeStrategySmallSet(RangeStrategy):

    def find_range(self, constraints, ast : claripy.ast.bv.BVS,
                   ast_min : int = None, ast_max : int = None):

        s = claripy.Solver(timeout=global_config["Z3Timeout"])
        s.constraints = constraints

        if ast_min == None or ast_max == None:

            if ast_min == None:
                ast_min = s.min(ast)
            if ast_max == None:
                ast_max = s.max(ast)

        if ast_min == ast_max:
            return range_static(ast_min, False)

        samples = s.eval(ast, 17)
        sample_len = len(samples)

        if sample_len < 17:
            return _list_to_stride_range(sorted(samples))

        return None

