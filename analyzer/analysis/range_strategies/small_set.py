import claripy
import sys

from . import RangeStrategy

# autopep8: off
# I hate python.
sys.path.append("..")
from shared.ranges import *
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
            return range_small(sorted(samples))

        return None
