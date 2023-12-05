
class RangeStrategy:

    def __init__(self):
        pass

    def find_range(self, constraints, ast, min = None, max = None):
        """
        Find the range of an AST
        """
        
        raise NotImplementedError
    
from .find_constraints_bounds import RangeStrategyFindConstraintsBounds
from .find_masking import RangeStrategyFindMasking
from .infer_isolated import RangeStrategyInferIsolated
from .small_set import RangeStrategySmallSet



