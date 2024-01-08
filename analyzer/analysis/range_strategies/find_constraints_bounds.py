import claripy
import time
import sys

from . import RangeStrategy
from .infer_isolated import RangeStrategyInferIsolated

# autopep8: off
from ...shared.config import *
from ...shared.utils import *
from ...shared.logger import *
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
            return self.infer_isolated_strategy.find_range([], ast, ast_min, ast_max)

        # print(f"min:{ast_min}     max:{ast_max}")
        try:
            sat_ranges = _find_sat_distribution(constraints, ast, ast_min, ast_max, stride=1)
        except claripy.ClaripyZ3Error as e:
            # timeout
            return None

        if sat_ranges != None and len(sat_ranges) == 1:
            # It is a full range, we can treat it as isolated
            return self.infer_isolated_strategy.find_range([], ast, sat_ranges[0][0], sat_ranges[0][1])

        # --------- Signed range
        if ast_min == 0 and ast_max == (2**ast.size()) - 1:
            s = claripy.Solver(timeout=global_config["Z3Timeout"])
            new_min = (1 << (ast.size() - 1))
            s.constraints = constraints + [(ast > new_min)]
            upper_ast_min = s.min(ast)
            upper_ast_max = s.max(ast)
            s = claripy.Solver(timeout=global_config["Z3Timeout"])
            s.constraints = constraints + [ast <= new_min]
            lower_ast_min = s.min(ast)
            lower_ast_max = s.max(ast)

            # print(f" new_min:{hex(new_min)} upper_min: {hex(upper_ast_min)}   upper_max: {hex(upper_ast_max)}    lower_min: {hex(lower_ast_min)}    lower_max: {hex(lower_ast_max)}")

            if lower_ast_min == 0 and upper_ast_max == (2**ast.size()) - 1:
                # treat this as a single range that wraps around ( min > max )
                try:
                    upper_range = _find_sat_distribution(constraints, ast, upper_ast_min, upper_ast_max, stride=1)
                    lower_range = _find_sat_distribution(constraints, ast, lower_ast_min, lower_ast_max, stride=1)
                except claripy.ClaripyZ3Error as e:
                    # timeout
                    return None

                if upper_range != None and lower_range != None and len(upper_range) == 1 and len(lower_range) == 1:
                    # It is a full range, we can treat it as isolated
                    return self.infer_isolated_strategy.find_range([], ast, upper_ast_min, lower_ast_max)

        # --------- Can't solve this
        l.warning(f"Cant' solve range: {ast}  ({constraints})")

        # TODO: If there is only one SAT range, we may still be able to treat
        # it as isolated and adjust the min and max.

        return None



def _find_sat_distribution(constraints, ast, start, end, stride = 1):
    all_ranges = []
    start_time = time.time()

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
        # print(f"Range: {[(value+1, value-1)]}")
        return [value+1, value-1]

    # TODO: Double check the validity of the code below
    return None

    task_list = []
    task_list.append((start, end))

    while len(task_list) > 0:

        # We are timing the complete sat finding, since it can consists
        # of many separate solves
        if time.time() - start_time > (SOLVER_TIMEOUT / 1000):
            print("Timeout of interval!")
            return None

        low, high = task_list.pop(0)

        sat = s.satisfiable(extra_constraints=[ast >= low, ast < high, not_constraints])

        if sat:

            diff_low = int((high - low) / 2)
            diff_up = math.ceil((high - low) / 2)

            if diff_low < stride:
                continue

            new_low = low + diff_low
            new_high = high - diff_up

            task_list.append((new_low, high))
            task_list.append((low, new_high))


        else:
            all_ranges.append((low, high))

    return _merge_ranges(sorted(all_ranges))

def _merge_ranges(ranges : tuple):

    if len(ranges) <= 1:
        return ranges

    prev = ranges[0]

    merged_ranges = []

    for cur in ranges[1:]:

        if prev[1] == cur[0]:
            prev = (prev[0], cur[1])
        else:
            merged_ranges.append(prev)
            prev=cur

    merged_ranges.append(prev)

    return merged_ranges
