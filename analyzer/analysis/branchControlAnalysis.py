"""BranchControlAnalysis

This analysis is responsible of checking if any of the branches or
constraint depends on the secret.
"""

from enum import Enum
import claripy
import sys

from .dependencyGraph import DepGraph, is_expr_uncontrolled
from ..shared.astTransform import ConditionType

# autopep8: off
from ..scanner.annotations import *
from ..scanner.memory import *
from ..shared.transmission import *
from ..shared.logger import *
# autopep8: on

l = get_logger("BranchControlAnalysis")

class BranchControlType(Enum):
    BRANCH_DEPENDS_ON_UNCONTROLLED = 0,
    BRANCH_DEPENDS_ON_SECRET_ADDRESS = 1,
    BRANCH_DEPENDS_ON_SECRET_VALUE = 2,
    BRANCH_INDEPENDENT_FROM_SECRET = 3,
    UNKNOWN = 8


def get_branch_control(t: Transmission, d: DepGraph, constraints: bool):
        constraint_expr = claripy.BVV(0, 1)
        for c in t.branches:
             for v in get_vars(c[1]):
                 constraint_expr = claripy.Concat(constraint_expr, v)

        l.info(f"Analyzing {constraint_expr} vs {t.transmitted_secret.expr}")

        if len(get_vars(constraint_expr)) == 0:
            l.info(f"No vars")
            return BranchControlType.BRANCH_INDEPENDENT_FROM_SECRET


        # If any branch is uncontrolled.
        if is_expr_uncontrolled(constraint_expr):
            return BranchControlType.BRANCH_DEPENDS_ON_UNCONTROLLED
        # Check if any branch depends on the transmitted secret.
        elif not d.is_independent(constraint_expr, t.transmitted_secret.expr, check_constraints=constraints, check_addr=False):
            return BranchControlType.BRANCH_DEPENDS_ON_SECRET_VALUE
        elif not d.is_independent(constraint_expr, t.transmitted_secret.expr, check_constraints=constraints, check_addr=True):
            return BranchControlType.BRANCH_DEPENDS_ON_SECRET_VALUE
        else:
            # Check if any branch depends on the secret address.
            l.info(f"Analyzing {constraint_expr} vs {t.secret_address.expr}")

            if not d.is_independent(constraint_expr, t.secret_address.expr, check_constraints=constraints, check_addr=False):
                return BranchControlType.BRANCH_DEPENDS_ON_SECRET_ADDRESS
            elif not d.is_independent(constraint_expr, t.secret_address.expr, check_constraints=constraints, check_addr=True):
                return BranchControlType.BRANCH_DEPENDS_ON_SECRET_ADDRESS

            # If none of the above are true, we conclude that the base is independent.
            else:
                return BranchControlType.BRANCH_INDEPENDENT_FROM_SECRET

def get_cmove_control(t: Transmission, d: DepGraph, constraints: bool):
        constraint_expr = claripy.BVV(0, 1)
        for c in t.constraints:
             if c[2] == ConditionType.CMOVE:
                for v in get_vars(c[1]):
                    constraint_expr = claripy.Concat(constraint_expr, v)


        l.info(f"Analyzing {constraint_expr} vs { t.transmitted_secret.expr}")


        if len(get_vars(constraint_expr)) == 0:
            l.info(f"No vars")
            return BranchControlType.BRANCH_INDEPENDENT_FROM_SECRET


        # If any branch is uncontrolled.
        if is_expr_uncontrolled(constraint_expr):
            return BranchControlType.BRANCH_DEPENDS_ON_UNCONTROLLED
        # Check if any branch depends on the transmitted secret.
        elif not d.is_independent(constraint_expr, t.transmitted_secret.expr, check_constraints=constraints, check_addr=False):
            return BranchControlType.BRANCH_DEPENDS_ON_SECRET_VALUE
        elif not d.is_independent(constraint_expr, t.transmitted_secret.expr, check_constraints=constraints, check_addr=True):
            return BranchControlType.BRANCH_DEPENDS_ON_SECRET_VALUE
        else:
            # Check if any branch depends on the secret address.
            l.info(f"Analyzing {constraint_expr} vs {t.secret_address.expr}")

            if not d.is_independent(constraint_expr, t.secret_address.expr, check_constraints=constraints, check_addr=False):
                return BranchControlType.BRANCH_DEPENDS_ON_SECRET_ADDRESS
            elif not d.is_independent(constraint_expr, t.secret_address.expr, check_constraints=constraints, check_addr=True):
                return BranchControlType.BRANCH_DEPENDS_ON_SECRET_ADDRESS

            # If none of the above are true, we conclude that the base is independent.
            else:
                return BranchControlType.BRANCH_INDEPENDENT_FROM_SECRET

def analyse(t: Transmission):
    """
    Check if any branch depends on the secret or secret address.
    """

    l.warning(f"========= [BASE] ==========")

    # 1. Get dependency graph of all symbols involved in this transmission.
    d = t.properties["deps"]

    # 2. Check control ignoring branches.
    t.properties["branch_control_type"] = get_branch_control(t, d, False)
    l.warning(f"Branch control: {t.properties['branch_control_type']}")

    t.properties["cmove_control_type"] = get_cmove_control(t, d, False)
    l.warning(f"Cmove control with constraints: {t.properties['cmove_control_type']}")

    l.warning(f"===========================")
