"""BaseControlAnalysis

This analysis is responsible of checking if the base of the transmission
can be controlled independently from the secret and the secret address.
"""

from enum import Enum
import claripy
import sys

from .dependencyGraph import DepGraph, is_expr_controlled

# autopep8: off
from ..scanner.annotations import *
from ..scanner.memory import *
from ..shared.transmission import *
from ..shared.logger import *
from ..shared.astTransform import *
# autopep8: on

l = get_logger("BaseControlAnalysis")

class BaseControlType(Enum):
    NO_BASE = 0,
    CONSTANT_BASE = 1,
    COMPLEX_TRANSMISSION = 2,
    # All symbols of the base are contained in the secret expression.
    BASE_DEPENDS_ON_SECRET_EXPR = 3,
    # All symbols of the base are either contained in the secret expression or
    # are loaded from an address that depends on the value of the secret.
    BASE_INDIRECTLY_DEPENDS_ON_SECRET_EXPR = 4,
    # All symbols of the base are contained in the secret address expression.
    # aka alias type 1.
    BASE_DEPENDS_ON_SECRET_ADDR = 5,
    # All symbols of the base are either contained in the expression of the
    # secret address or they are loaded from an address that depends on the
    # secret address.
    # aka alias type 2.
    BASE_INDIRECTLY_DEPENDS_ON_SECRET_ADDR = 6,

    BASE_INDEPENDENT_FROM_SECRET = 7,
    UNKNOWN = 8

def get_expr_base_control(base_expr, transmitted_secret_expr, secret_address_expr, d: DepGraph, constraints: bool):
    secrets = set(get_vars(transmitted_secret_expr))

    # If the base is not symbolic, we're done.
    if not is_sym_expr(base_expr) or not is_expr_controlled(base_expr):
        return BaseControlType.CONSTANT_BASE
    # Check if the base depends on the transmitted secret.
    elif not d.is_independently_controllable(base_expr, secrets, check_constraints=constraints, check_addr=False):
        return BaseControlType.BASE_DEPENDS_ON_SECRET_EXPR
    elif not d.is_independently_controllable(base_expr, secrets, check_constraints=constraints, check_addr=True):
        return BaseControlType.BASE_INDIRECTLY_DEPENDS_ON_SECRET_EXPR

    else:
        # Check if the base depends on the secret address.
        secrets.update(get_vars(secret_address_expr))
        if not d.is_independently_controllable(base_expr, secrets, check_constraints=constraints, check_addr=False):
            return BaseControlType.BASE_DEPENDS_ON_SECRET_ADDR
        elif not d.is_independently_controllable(base_expr, secrets, check_constraints=constraints, check_addr=True):
            return BaseControlType.BASE_INDIRECTLY_DEPENDS_ON_SECRET_ADDR

        # If none of the above are true, we conclude that the base is independent.
        else:
            return BaseControlType.BASE_INDEPENDENT_FROM_SECRET


def get_base_control(t: Transmission, d: DepGraph, constraints: bool):
    if t.base != None:
        return get_expr_base_control(t.base.expr, t.transmitted_secret.expr, t.secret_address.expr, d, constraints)

    # If there's no base expression, there might still be some symbol in the
    # transmission expression that does not depend on the secret.
    else:
        secrets = set(get_vars(t.secret_address.expr))
        secrets.add(t.secret_val.expr)
        if d.is_independently_controllable(t.transmission.expr, secrets, check_constraints=constraints, check_addr=True):
            return BaseControlType.COMPLEX_TRANSMISSION
        else:
            return BaseControlType.NO_BASE


def analyse(t: Transmission):
    """
    Check if the base depends on the secret or secret address.
    """
    l.warning(f"========= [BASE] ==========")

    # 1. Get dependency graph of all symbols involved in this transmission.
    d = t.properties["deps"]

    # 2. Check control ignoring branches.
    t.properties["base_control_type"] = get_base_control(t, d, False)
    l.warning(f"Base control: {t.properties['base_control_type']}")

    t.properties["base_control_w_constraints"] = get_base_control(t, d, True)
    l.warning(f"Base control with constraints: {t.properties['base_control_w_constraints']}")

    # 3. Check control considering also branch constraints.
    if len(t.branches) > 0:
        d.add_constraints(map(lambda x: x[1], t.branches))
        d.resolve_dependencies()
        t.properties["base_control_w_branches_and_constraints"] = get_base_control(t, d, True)
    else:
        t.properties["base_control_w_branches_and_constraints"] = t.properties["base_control_w_constraints"]

    l.warning(f"Base control including branches: {t.properties['base_control_w_branches_and_constraints']}")

    t.properties["deps"] = d

    l.warning(f"===========================")
