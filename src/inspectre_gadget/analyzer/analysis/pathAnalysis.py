"""PathAnalysis

This analysis is responsible of tracking which branches need to be taken or
not taken for the transmission to happen, and how their condition influence
the final transmission.
"""

import claripy
import sys

from .dependencyGraph import DepGraph

# autopep8: off
from ..shared.transmission import Transmission
from ..shared.taintedFunctionPointer import TaintedFunctionPointer
from ..shared.halfGadget import HalfGadget
from ..shared.secretDependentBranch import SecretDependentBranch
from ..shared import utils
from ..shared import logger
# autopep8: on

l = logger.get_logger("PathAnalysis")


def get_deps(d: DepGraph, expr):
    """
    Return all dependencies of the symbols in expr, including constraints.
    """
    return d.get_all_deps(utils.get_vars(expr), include_constraints=True)


def get_component_deps(d: DepGraph, component):
    """
    Return all dependencies of a transmission component (if it exists).
    """
    return [] if component == None else get_deps(d, component.expr)


def analyse(t: Transmission):
    l.warning(f"========= [PATH] ==========")

    t.properties["n_branches"] = len(t.branches)
    # TODO: unsat branches?

    if len(t.branches) == 0 and len(t.constraints) == 0:
        return

    d: DepGraph = t.properties["deps"]

    base_deps = get_component_deps(d, t.base)
    indep_base_deps = get_component_deps(d, t.independent_base)
    secret_addr_deps = get_component_deps(d, t.secret_address)
    secret_deps = get_component_deps(d, t.transmitted_secret)
    transmission_deps = get_component_deps(d, t.transmission)

    for addr, condition, taken in t.branches:
        br_deps = get_deps(d, condition)

        if len(br_deps.intersection(base_deps)):
            t.base.branches.append((addr, condition, taken))
        if len(br_deps.intersection(indep_base_deps)):
            t.independent_base.branches.append((addr, condition, taken))
        if len(br_deps.intersection(secret_addr_deps)):
            t.secret_address.branches.append((addr, condition, taken))
        if len(br_deps.intersection(transmission_deps)):
            t.transmission.branches.append((addr, condition, taken))
        if len(br_deps.intersection(secret_deps)):
            t.transmitted_secret.branches.append((addr, condition, taken))

    l.warning(f"Base branches: {'None' if t.base == None else t.base.branches}")
    l.warning(f"Secret Addr branches: {t.secret_address.branches}")
    l.warning(f"Transmitted Secret branches: {t.transmitted_secret.branches}")
    l.warning(f"Transmission branches: {t.transmission.branches}")

    for addr, cond, ctype in t.constraints:
        constr_deps = get_deps(d, cond)
        if len(constr_deps.intersection(base_deps)):
            t.base.constraints.append((addr, cond, ctype))
        if len(constr_deps.intersection(indep_base_deps)):
            t.independent_base.constraints.append((addr, cond, ctype))
        if len(constr_deps.intersection(secret_addr_deps)):
            t.secret_address.constraints.append((addr, cond, ctype))
        if len(constr_deps.intersection(transmission_deps)):
            t.transmission.constraints.append((addr, cond, ctype))
        if len(constr_deps.intersection(secret_deps)):
            t.transmitted_secret.constraints.append((addr, cond, ctype))

    l.warning(f"Base constraints: {'None' if t.base == None else t.base.constraints}")
    indep_base_constraints = ('None' if t.independent_base == None
                              else t.independent_base.constraints)
    l.warning(f"Independent Base constraints: {indep_base_constraints}")
    l.warning(f"Secret Addr constraints: {t.secret_address.constraints}")
    l.warning(f"Transmitted Secret constraints: {t.transmitted_secret.constraints}")
    l.warning(f"Transmission constraints: {t.transmission.constraints}")

    for a in t.aliases:
        alias_deps = get_deps(d, a.to_BV())

        if len(alias_deps.intersection(base_deps)):
            t.base.aliases.append(a)
        if len(alias_deps.intersection(indep_base_deps)):
            t.independent_base.aliases.append(a)
        if len(alias_deps.intersection(secret_addr_deps)):
            t.secret_address.aliases.append(a)
        if len(alias_deps.intersection(transmission_deps)):
            t.transmission.aliases.append(a)
        if len(alias_deps.intersection(secret_deps)):
            t.transmitted_secret.aliases.append(a)

    l.warning(f"Base aliases: {'None' if t.base == None else t.base.aliases}")
    indep_base_aliases = ('None' if t.independent_base == None
                          else t.independent_base.aliases)
    l.warning(f"Independent Base aliases: {indep_base_aliases}")
    l.warning(f"Secret Addr aliases: {t.secret_address.aliases}")
    l.warning(f"Transmitted Secret aliases: {t.transmitted_secret.aliases}")
    l.warning(f"Transmission aliases: {t.transmission.aliases}")

    l.warning(f"==========================")


def analyse_sdb(sdb: SecretDependentBranch):
    # First analyze the transmission components
    analyse(sdb)

    if len(sdb.branches) == 0 and len(sdb.constraints) == 0:
        return

    d: DepGraph = sdb.properties["deps"]

    # cmp_value/controlled_cmp_value are derived from the SDB's own guard,
    # which may involve vars not yet part of the pre-built graph.
    d.add_nodes(sdb.cmp_value.expr)
    if sdb.controlled_cmp_value != None:
        d.add_nodes(sdb.controlled_cmp_value.expr)

    cmp_value_deps = get_deps(d, sdb.cmp_value.expr)
    controlled_cmp_value_deps = get_component_deps(d, sdb.controlled_cmp_value)

    for addr, condition, taken in sdb.branches:
        br_deps = get_deps(d, condition)

        if len(br_deps.intersection(cmp_value_deps)):
            sdb.cmp_value.branches.append((addr, condition, taken))
        if len(br_deps.intersection(controlled_cmp_value_deps)):
            sdb.controlled_cmp_value.branches.append((addr, condition, taken))

    l.warning(f"Cmp Value branches: {sdb.cmp_value.branches}")
    controlled_branches = ('None' if sdb.controlled_cmp_value == None
                           else sdb.controlled_cmp_value.branches)
    l.warning(f"Controlled Cmp Value branches: {controlled_branches}")

    for addr, cond, ctype in sdb.constraints:
        constr_deps = get_deps(d, cond)

        if len(constr_deps.intersection(cmp_value_deps)):
            sdb.cmp_value.constraints.append((addr, cond, ctype))
        if len(constr_deps.intersection(controlled_cmp_value_deps)):
            sdb.controlled_cmp_value.constraints.append((addr, cond, ctype))

    l.warning(f"Cmp Value constraints: {sdb.cmp_value.constraints}")
    controlled_constraints = ('None' if sdb.controlled_cmp_value == None
                              else sdb.controlled_cmp_value.constraints)
    l.warning(f"Controlled Cmp Value constraints: {controlled_constraints}")

    for a in sdb.aliases:
        alias_deps = get_deps(d, a.to_BV())

        if len(alias_deps.intersection(cmp_value_deps)):
            sdb.cmp_value.aliases.append(a)
        if len(alias_deps.intersection(controlled_cmp_value_deps)):
            sdb.controlled_cmp_value.aliases.append(a)

    l.warning(f"Cmp Value aliases: {sdb.cmp_value.aliases}")
    controlled_aliases = ('None' if sdb.controlled_cmp_value == None
                          else sdb.controlled_cmp_value.aliases)
    l.warning(f"Controlled Cmp Value aliases: {controlled_aliases}")

    l.warning(f"==========================")


def analyse_tfp(t: TaintedFunctionPointer):
    l.warning(f"========= [PATH] ==========")

    d = DepGraph()
    d.add_nodes(t.expr)
    for r in t.registers:
        d.add_nodes(t.registers[r].expr)
    d.add_aliases([a.to_BV() for a in t.aliases])
    d.add_constraints([x[1] for x in t.all_constraints])
    d.add_constraints([x[1] for x in t.all_branches])
    d.resolve_dependencies()

    reg_deps = {}
    for r in t.registers:
        reg_deps[t.registers[r].reg] = get_deps(d, t.registers[r].expr)

    if t.reg not in reg_deps:
        reg_deps[t.reg] = get_deps(d, t.expr)

    for addr, condition, taken in t.all_branches:
        br_deps = get_deps(d, condition)

        # Check for all registers
        for r in t.registers:
            if len(br_deps.intersection(reg_deps[r])):
                t.registers[r].branches.append((addr, condition, taken))

        # Check for tfp expr
        if len(br_deps.intersection(reg_deps[t.reg])):
            t.branches.append((addr, condition, taken))

    for addr, c, ctype in t.all_constraints:
        constr_deps = get_deps(d, c)

        # Check for all registers
        for r in t.registers:
            if len(constr_deps.intersection(reg_deps[r])):
                t.registers[r].constraints.append((addr, c, ctype))

        # Check for tfp expr
        if len(constr_deps.intersection(reg_deps[t.reg])):
            t.constraints.append((addr, c, ctype))

    for a in t.aliases:
        alias_deps = get_deps(d, a.to_BV())

        # Check for all registers
        for r in t.registers:
            if len(alias_deps.intersection(reg_deps[r])):
                t.registers[r].aliases.append(a)

    l.warning("==========================")


def analyse_half_gadget(g: HalfGadget):
    l.warning(f"========= [PATH] ==========")

    d = DepGraph()
    d.add_nodes(g.loaded.expr)
    d.add_aliases([a.to_BV() for a in g.aliases])
    d.add_constraints([x[1] for x in g.constraints])
    d.add_constraints([x[1] for x in g.branches])
    d.resolve_dependencies()

    base_deps = get_component_deps(d, g.base)
    uncontrolled_base_deps = get_component_deps(d, g.uncontrolled_base)
    attacker_deps = get_deps(d, g.attacker.expr)
    loaded_deps = get_deps(d, g.loaded.expr)

    for addr, condition, taken in g.branches:
        br_deps = get_deps(d, condition)

        if len(br_deps.intersection(base_deps)):
            g.base.branches.append((addr, condition, taken))
        if len(br_deps.intersection(attacker_deps)):
            g.attacker.branches.append((addr, condition, taken))
        if len(br_deps.intersection(uncontrolled_base_deps)):
            g.uncontrolled_base.branches.append((addr, condition, taken))
        if len(br_deps.intersection(loaded_deps)):
            g.loaded.branches.append((addr, condition, taken))

    l.warning(f"Base branches: {'None' if g.base == None else g.base.branches}")
    uncontrolled_branches = ('None' if g.uncontrolled_base == None
                             else g.uncontrolled_base.branches)
    l.warning(f"Uncontrolled Base branches: {uncontrolled_branches}")
    l.warning(f"Attacker branches: {g.attacker.branches}")
    l.warning(f"Loaded branches: {g.loaded.branches}")

    for addr, cond, ctype in g.constraints:
        constr_deps = get_deps(d, cond)

        if len(constr_deps.intersection(base_deps)):
            g.base.constraints.append((addr, cond, ctype))
        if len(constr_deps.intersection(uncontrolled_base_deps)):
            g.uncontrolled_base.constraints.append((addr, cond, ctype))
        if len(constr_deps.intersection(attacker_deps)):
            g.attacker.constraints.append((addr, cond, ctype))
        if len(constr_deps.intersection(loaded_deps)):
            g.loaded.constraints.append((addr, cond, ctype))

    l.warning(f"Base constraints: {'None' if g.base == None else g.base.constraints}")
    uncontrolled_constraints = ('None' if g.uncontrolled_base == None
                                else g.uncontrolled_base.constraints)
    l.warning(f"Uncontrolled Base constraints: {uncontrolled_constraints}")
    l.warning(f"Attacker constraints: {g.attacker.constraints}")
    l.warning(f"Loaded constraints: {g.loaded.constraints}")

    for a in g.aliases:
        alias_deps = get_deps(d, a.to_BV())

        if len(alias_deps.intersection(base_deps)):
            g.base.aliases.append(a)
        if len(alias_deps.intersection(uncontrolled_base_deps)):
            g.uncontrolled_base.aliases.append(a)
        if len(alias_deps.intersection(attacker_deps)):
            g.attacker.aliases.append(a)
        if len(alias_deps.intersection(loaded_deps)):
            g.loaded.aliases.append(a)

    l.warning(f"Base aliases: {'None' if g.base == None else g.base.aliases}")
    uncontrolled_aliases = ('None' if g.uncontrolled_base == None
                            else g.uncontrolled_base.aliases)
    l.warning(f"Uncontrolled Base aliases: {uncontrolled_aliases}")
    l.warning(f"Attacker aliases: {g.attacker.aliases}")
    l.warning(f"Loaded aliases: {g.loaded.aliases}")

    l.warning("==========================")
