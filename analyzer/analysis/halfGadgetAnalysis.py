"""HalfGadgetAnalysis

This analysis is responsible of identifying the basic components of a half-spectre
gadget.
"""

import sys
import claripy.ast.base
import itertools
import copy

# autopep8: off
from ..shared.logger import *
from ..shared.astTransform import *
from ..shared.config import *
from ..shared.halfGadget import *
from ..scanner.annotations import *
from .transmissionAnalysis import canonicalize
# autopep8: on

l = get_logger("HalfSpectreAnalysis")

def analyse(gadget: HalfGadget):
    l.warning(f"========= [HalfGadget] ==========")
    l.warning(f"Analyzing @{hex(gadget.pc)}: {gadget.loaded.expr}")

    # Extract members of the transmission.
    canonical_exprs = canonicalize(gadget.loaded.expr, gadget.pc)

    gadgets = []
    for canonical_expr in canonical_exprs:
        g = copy.deepcopy(gadget)
        g.loaded.expr = canonical_expr.expr
        g.loaded.constraints.extend(canonical_expr.conditions)

        l.warning(
            f"POTENTIAL HALF GADGET: {canonical_expr}")
        members = extract_summed_vals(canonical_expr.expr)
        l.error(f"aliases:  {gadget.aliases}")

        # Analyze each member.
        already_added = set()
        base_members = []
        uncontrolled_base_members = []
        attacker_members = []
        for member in members:
            l.warning(f"  └── MEMBER = {member}")

            if member in already_added:
                l.warning("     skipping")
                continue

            if is_attacker_controlled(member):
                # Note that this includes both direct control (e.g. rdi)
                # and indirect control (e.g. LOAD[LOAD[RDI]]).
                attacker_members.append(member)
            else:
                base_members.append(member)
                if get_uncontrolled_load_annotation(member) is not None:
                    # These are members that contain code loaded from
                    # uncontrolled locations (constants or GS).
                    uncontrolled_base_members.append(member)

        # Create the base.
        if len(base_members) > 0:
            g.base.expr = generate_addition(base_members)
        else:
            g.base = None
        if len(uncontrolled_base_members) > 0:
            g.uncontrolled_base.expr = generate_addition(
                uncontrolled_base_members)
        else:
            g.uncontrolled_base = None
        # Create the attacker-controlled component.
        assert (len(attacker_members) > 0)
        g.attacker.expr = generate_addition(attacker_members)

        # Calculate size.
        for component in [g.loaded, g.base, g.attacker, g.uncontrolled_base]:
            if component != None:
                component.size = component.expr.size()
                component.max_load_depth = get_load_depth(
                    component.expr)

        gadgets.append(g)

    l.warning("==========================")

    return gadgets
