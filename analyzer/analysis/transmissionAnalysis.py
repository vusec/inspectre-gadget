"""TransmissionAnalysis

This analysis is responsible of identifying the basic components (transmission
base, transmitted secret and secret address) of a transmission.
"""

import sys
import claripy.ast.base
import itertools

from .dependencyGraph import *

# autopep8: off
from ..shared.logger import *
from ..shared.astTransform import *
from ..shared.config import *
from ..shared.transmission import *
from ..scanner.annotations import *
# autopep8: on

l = get_logger("TransmissionAnalysis")


def reduce_to_shifts(args, size):
    """
    Helper for concat_to_shift.
    """

    # Only one arg: return it.
    if len(args) == 1:
        arg = concat_to_shift(arg)
        return claripy.ZeroExt(arg.size(), arg)
    else:
        # Leftmost arg -> shift it.
        to_shift = concat_to_shift(args[0])
        # Reduce the rest of the expression to a shift.
        to_add = concat_to_shift(claripy.Concat(*args[1:]))

        # Adjust the size.
        remaining_size = to_add.size()
        to_shift = claripy.ZeroExt(size - to_shift.size(), to_shift)
        to_add = claripy.ZeroExt(size - to_add.size(), to_add)

        return (to_shift << remaining_size) + to_add

def concat_to_shift(ast: claripy.BV,):
    """
    Transform A <concat> B into (A << size_of_b) + B.
    """

    # If this AST is a constant, do nothing.
    if not isinstance(ast, claripy.ast.base.Base) or ast.concrete:
        return ast

    # If this node is a concat, transform it into a shift.
    if ast.op == "Concat":
        return reduce_to_shifts(ast.args, ast.size())

    # Otherwise, transform arguments recursively.
    new_expr = ast
    for arg in ast.args:
        if not isinstance(arg, claripy.ast.base.Base) or arg.concrete:
            continue
        new_expr = new_expr.replace(arg, concat_to_shift(arg))

    return new_expr


def distribute_shifts(ast: claripy.BV):
    """
    Distribute left shifts over additions. The resulting expression is not
    exactly the same as the input, but we decide to sacrifice exactness
    for the possibility of splitting more expressions into adds.
    """

    # If this AST is a constant, do nothing.
    if not isinstance(ast, claripy.ast.base.Base) or ast.concrete:
        return ast

    # If this is a left shift ...
    if ast.op == "__lshift__":
        val_to_shift = ast.args[0]
        shift_amount = ast.args[1]

        addenda = extract_summed_vals(val_to_shift)
        # ... and the first operand is an addition ...
        if len(addenda) > 1:
            # Distribute any shifts inside the addenda before solving this expression.
            args_analyzed = [distribute_shifts(a) for a in addenda]

            # Make sure everything has the same size.
            expr_size = ast.size() - val_to_shift.size()

            # Apply shift to every addenda.
            args_shifted = [claripy.ZeroExt(expr_size, arg) << shift_amount
                            for arg in args_analyzed]
            # Add everything together again.
            return generate_addition(args_shifted)

    # Otherwise, apply to arguments recursively.
    new_expr = ast
    for arg in ast.args:
        if not isinstance(arg, claripy.ast.base.Base) or arg.concrete:
            continue
        new_expr = new_expr.replace(arg, distribute_shifts(arg))

    return new_expr


def canonicalize(expr, addr):
    """
    Reduce an expression to a "canonical" form (sum of independent members).
    """
    # Guarantees:
    # 1. no if-then-else statements
    # 2. all sums
    # 3. distribution of * and / over +
    l.info(f"CANONICALIZING: {expr}")
    splitted = split_conditions(expr, simplify=True, addr=addr)

    for s in splitted:
        s.expr = concat_to_shift(s.expr)

        if global_config["DistributeShifts"]:
            s.expr = distribute_shifts(s.expr)

    l.info(f"canonicalized: {splitted}")
    return splitted

def get_dependency_graph(potential_t: TransmissionExpr, transmission_expr: ConditionalAst):
        d = DepGraph()
        d.add_nodes(transmission_expr.expr)
        d.add_aliases(map(lambda x: x.to_BV(), potential_t.aliases))
        d.add_constraints(transmission_expr.conditions)
        d.add_constraints([x[1] for x in potential_t.constraints])
        d.resolve_dependencies()
        return d


def get_transmissions(potential_t: TransmissionExpr) -> list[Transmission]:
    """
    Analyze an expression marked as a possible transmission (e.g. the address
    of a double load) to identify its components. Note that the same expression
    might contain multiple transmissions.
    """
    l.warning(f"========= [AST] ==========")
    l.warning(f"Analyzing @{hex(potential_t.pc)}: {potential_t.expr}")

    # Extract members of the transmission.
    canonical_exprs = canonicalize(potential_t.expr, potential_t.pc)

    transmissions = []
    for canonical_expr in canonical_exprs:
        l.warning(f"POTENTIAL TRANSMISSION ({potential_t.transmitter}): {canonical_expr}")
        members = extract_summed_vals(canonical_expr.expr)
        l.error(f"aliases:  {potential_t.aliases}")

        d = get_dependency_graph(potential_t, canonical_expr)

        # Analyze each member.
        already_added = set()
        for member in members:
            l.warning(f"  |__ MEMBER = {member}")

            if member in already_added:
                l.warning("     skipping")
                continue

            # Check if this member contains potential secrets.
            secrets = []
            for var in get_vars(member):
                for anno in get_annotations(var):
                    if isinstance(anno, SecretAnnotation) or isinstance(anno, TransmissionAnnotation):
                        secrets.append((var, anno.read_address_ast))

            # If there is at least one secret in this member...
            for secret_sym, secret_addr in secrets:
                l.warning(f"    Found secret")
                # Create new transmission.
                t = Transmission(potential_t)
                t.transmission.expr = canonical_expr.expr
                t.max_load_depth = get_load_depth(t.transmission.expr)
                # Append CMOV conditions.
                t.constraints.extend(canonical_expr.conditions)
                # Append the dependency graph.
                t.properties["deps"] = d

                # Save which secret is is being transmitted.
                t.transmitted_secret.expr = member
                t.secret_val.expr = secret_sym
                t.secret_load_pc = get_load_annotation(secret_sym).address
                t.secret_address.expr = secret_addr

                # Check the rest of the expression
                base_members = []
                independent_base_members = []
                direct_dependent_base = []
                indirect_dependent_base = []
                for other_m in members:
                    if other_m is member:
                        continue

                    # TODO: is check_addr=True too strict?
                    if d.is_independent(other_m, secret_sym, check_constraints=False, check_addr=True):
                        # If the other member is completely independent
                        # from the secret, it's part of the base.
                        base_members.append(other_m)

                        if d.is_independent(other_m, secret_addr, check_constraints=False, check_addr=True):
                            independent_base_members.append(other_m)
                        elif d.is_independent(other_m, secret_addr, check_constraints=False, check_addr=False):
                            indirect_dependent_base.append(other_m)
                        else:
                            direct_dependent_base.append(other_m)
                    else:
                        # Otherwise, it's part of the transmission.
                        t.transmitted_secret.expr += other_m
                        already_added.add(other_m)

                # Create the base.
                if len(base_members) > 0:
                    t.base.expr = generate_addition(base_members)
                else:
                    t.base = None

                # Create base sub-components.
                if len(independent_base_members) > 0:
                    t.independent_base.expr = generate_addition(independent_base_members)
                else:
                    t.independent_base = None

                if len(direct_dependent_base) > 0:
                    t.properties['direct_dependent_base_expr'] = generate_addition(direct_dependent_base)
                else:
                    t.properties['direct_dependent_base_expr'] = None

                if len(indirect_dependent_base) > 0:
                    t.properties['indirect_dependent_base_expr'] = generate_addition(indirect_dependent_base)
                else:
                    t.properties['indirect_dependent_base_expr'] = None

                # Calculate size.
                for component in [t.base, t.secret_address, t.transmission, t.transmitted_secret, t.secret_val, t.independent_base]:
                    if component != None:
                        component.size = component.expr.size()
                        component.max_load_depth = get_load_depth(component.expr)

                transmissions.append(t)

    l.warning("==========================")

    return transmissions
