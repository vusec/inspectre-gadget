import claripy
import sys

from . import RangeStrategy

# autopep8: off
from ...shared.ranges import *
# autopep8: on

SOLVER_TIMEOUT = 10*1000  # ms, 10s


class RangeStrategySmallSet(RangeStrategy):

    def find_range(self, constraints, ast : claripy.ast.bv.BVS,
                   ast_min : int = None, ast_max : int = None):

        s = claripy.Solver(timeout=SOLVER_TIMEOUT)
        s.constraints = constraints


        samples = s.eval(ast, 100)
        sample_len = len(samples)

        if sample_len == 1:
            return range_static(samples[0], False)

        elif sample_len < 100:
            return __list_to_stride_range(sorted(samples))

        return None


def __list_to_stride_range(numbers : list):
    assert(len(numbers) > 1)
    stride = numbers[1] - numbers[0]

    for i in range(0, len(numbers) - 1):
        if numbers[i] + stride != numbers[i+1]:
            return None

    return AstRange(min=numbers[0] , max=numbers[-1],
                    exact=True, isolated=True,
                    intervals=[Interval(numbers[0], numbers[-1], stride)])
