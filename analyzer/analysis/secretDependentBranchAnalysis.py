"""SecretDependentBranchAnalysis

This analysis is responsible of identifying the branch sides that consist
of the secret and value compared against
"""

import sys
import claripy.ast.base
import itertools

from .dependencyGraph import *
from .transmissionAnalysis import get_transmissions, canonicalize

# autopep8: off
from ..shared.logger import *
from ..shared.astTransform import *
from ..shared.config import *
from ..shared.transmission import *
from ..shared.secretDependentBranch import *
from ..scanner.annotations import *
# autopep8: on

l = get_logger("SecretDependentBranchAnalysis")


def get_secret_dependent_branches(potential_sdb : SecretDependentBranchExpr) -> list[SecretDependentBranch]:
    """
    Analyze an expression marked as a possible secret dependent branch (e.g.
    a branch guard consisting of a secret) to identify its components.
    For the 'secret side' of the comparison we use the logic from the
    transmission component. We check both sides of the comparison if it contains
    a secret.
    """

    l.warning(f"========= [AST] ==========")
    l.warning(f"Analyzing SDP @{hex(potential_sdb.pc)}: {potential_sdb.expr}")

    expr = potential_sdb.expr


    if not isinstance(expr, claripy.ast.bool.Bool):
        return []

    if len(expr.args) == 1:
        report_error(Exception(), hex(0), hex(0), error_type="get_secret_dependent_branches: Unexpected AST with args == 1")
        return []

    expr_right = expr.args[0]
    expr_left = expr.args[1]

    # Do some sanity checks on right left expressions
    if isinstance(expr_right, claripy.ast.bool.Bool) and isinstance(expr_left, claripy.ast.bool.Bool):
        # If expr has depth == 1, its simple 'True' or 'False'
        # Do we need to fix operation of child expr?
        if expr_right.depth == 1:
            potential_sdb.expr = expr_left
            return get_secret_dependent_branches(potential_sdb)

        if expr_left.depth == 1:
            potential_sdb.expr = expr_right
            return get_secret_dependent_branches(potential_sdb)

        return []

    if isinstance(expr_right, claripy.ast.bool.Bool):
        potential_sdb.expr = expr_right
        return get_secret_dependent_branches(potential_sdb)

    elif isinstance(expr_left, claripy.ast.bool.Bool):
        potential_sdb.expr = expr_right
        return get_secret_dependent_branches(potential_sdb)



    secret_dependent_branches = []
    # For both side combinations, do the analysis
    for secret_expr, compared_expr in [[expr_right, expr_left], [expr_left, expr_right]]:

        # Get all transmission for the secret_expr
        potential_sdb.expr = secret_expr
        all_transmissions = get_transmissions(potential_sdb)

        # Now create a secret dependent branch for each transmission
        for t in all_transmissions:
            # We lower the transmission object to a SecretDependentBranch object
            sdb = SecretDependentBranch(expr)
            sdb.__dict__.update(t.__dict__)

            # Init cmp_value
            sdb.cmp_value.expr = compared_expr

            # Collect controlled part of cmp_value
            canonical_exprs = canonicalize(compared_expr, potential_sdb.pc)
            controlled_members = []
            for canonical_expr in canonical_exprs:
                members = extract_summed_vals(canonical_expr.expr)

                for ast in members:
                    if is_attacker_controlled(ast):
                        controlled_members.append(ast)

            if len(controlled_members) > 0:
                sdb.controlled_cmp_value.expr = generate_addition(controlled_members)
            else:
                sdb.controlled_cmp_value = None

            # Done
            secret_dependent_branches.append(sdb)

    return secret_dependent_branches
