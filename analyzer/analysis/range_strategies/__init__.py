
from .find_constraints_bounds import RangeStrategyFindConstraintsBounds
from .small_set import RangeStrategySmallSet
from .infer_isolated import RangeStrategyInferIsolated
from .find_masking import RangeStrategyFindMasking
class RangeStrategy:

    def __init__(self):
        pass

    def find_range(self, constraints, ast, min=None, max=None):
        """
        Find the range of an AST
        """

        raise NotImplementedError
