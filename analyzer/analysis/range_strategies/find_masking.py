import claripy
import sys

from . import RangeStrategy

# autopep8: off
from ...shared.ranges import *
from ...shared.config import *
# autopep8: on

class RangeStrategyFindMasking(RangeStrategy):

    def find_range(self, constraints, ast : claripy.ast.bv.BVS,
                   ast_min : int = None, ast_max : int = None):

        s = claripy.Solver(timeout=global_config["Z3Timeout"])
        s.constraints = constraints


        if ast_min == None:
            ast_min = s.min(ast)
        if ast_max == None:
            ast_max = s.max(ast)

        entropy, and_mask, or_mask = _find_entropy(s, ast, ast_max)

        return range_complex(ast_min, ast_max, ast.size(), False, entropy, and_mask, or_mask)

def _find_entropy(s : claripy.Solver, ast : claripy.BV, ast_max : int):

    highest_bit = ast_max.bit_length()

    or_mask = 0
    and_mask = 2 ** highest_bit - 1
    entropy = highest_bit


    zero_bits = []
    one_bits = []


    for bit in range(0, highest_bit):

        to_check = ast[bit:bit]

        if not s.satisfiable(extra_constraints=[to_check == 1]):
            # bit is always zero
            zero_bits.append(bit)
            and_mask = and_mask & ~(1 << bit)
            entropy -= 1

        elif not s.satisfiable(extra_constraints=[to_check == 0]):
            # bit is always one
            one_bits.append(bit)
            or_mask = or_mask | 1 << bit
            entropy -= 1

    return (entropy, and_mask, or_mask)
