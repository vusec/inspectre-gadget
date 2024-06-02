"""PathAnalysis

This analysis is responsible of tracking which branches need to be taken or
not taken for the transmission to happen, and how their condition influence
the final transmission.
"""

import claripy
import sys

from .dependencyGraph import DepGraph

# autopep8: off
from ..shared.transmission import *
from ..shared.taintedFunctionPointer import *
from ..shared.utils import *
from ..shared.logger import *
# autopep8: on

l = get_logger("PathAnalysis")


def analyse(t: Transmission):
    l.warning(f"========= [PATH] ==========")

    t.properties["n_branches"] = len(t.branches)
    # TODO: unsat branches?

    if len(t.branches) == 0 and len(t.constraints) == 0:
        return

    d: DepGraph = t.properties["deps"]

    base_deps = [] if t.base == None else d.get_all_deps(get_vars(t.base.expr), include_constraints=False)
    secret_addr_deps = d.get_all_deps(get_vars(t.secret_address.expr), include_constraints=False)
    secret_deps = d.get_all_deps(get_vars(t.transmitted_secret.expr), include_constraints=False)
    transmission_deps = d.get_all_deps(get_vars(t.transmission.expr), include_constraints=False)

    for addr,condition,taken in t.branches:
        br_deps = d.get_all_deps(get_vars(condition), include_constraints=False)

        if len(br_deps.intersection(base_deps)):
            t.base.branches.append((addr, condition, taken))
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

    for addr,cond,ctype in t.constraints:
        constr_deps = d.get_all_deps(get_vars(cond), include_constraints=False)

        if len(constr_deps.intersection(base_deps)):
            t.base.constraints.append((addr,cond,ctype))
        if len(constr_deps.intersection(secret_addr_deps)):
            t.secret_address.constraints.append((addr,cond,ctype))
        if len(constr_deps.intersection(transmission_deps)):
            t.transmission.constraints.append((addr,cond,ctype))
        if len(constr_deps.intersection(secret_deps)):
            t.transmitted_secret.constraints.append((addr,cond,ctype))

    l.warning(f"Base constraints: {'None' if t.base == None else t.base.constraints}")
    l.warning(f"Secret Addr constraints: {t.secret_address.constraints}")
    l.warning(f"Transmitted Secret constraints: {t.transmitted_secret.constraints}")
    l.warning(f"Transmission constraints: {t.transmission.constraints}")

    l.warning(f"==========================")


def analyse_tfp(t: TaintedFunctionPointer):
    l.warning(f"========= [PATH] ==========")

    d = DepGraph()
    d.add_nodes(t.expr)
    for r in t.registers:
        d.add_nodes(t.registers[r].expr)
    d.add_aliases(t.aliases)
    d.add_constraints([x[1] for x in t.all_constraints])
    d.add_constraints([x[1] for x in t.all_branches])
    d.resolve_dependencies()

    reg_deps = {}
    for r in t.registers:
        reg_deps[t.registers[r].reg] = d.get_all_deps(get_vars(t.registers[r].expr), include_constraints=False)

    if t.reg not in reg_deps:
        reg_deps[t.reg] = d.get_all_deps(get_vars(t.expr), include_constraints=False)

    for addr,condition,taken in t.all_branches:
        br_deps = d.get_all_deps(get_vars(condition), include_constraints=False)

        # Check for all registers
        for r in t.registers:
            if len(br_deps.intersection(reg_deps[r])):
                t.registers[r].branches.append((addr, condition, taken))

        # Check for tfp expr
        if len(br_deps.intersection(reg_deps[t.reg])):
            t.branches.append((addr, condition, taken))



    for addr,c,ctype in t.all_constraints:
        constr_deps = d.get_all_deps(get_vars(c), include_constraints=False)

        # Check for all registers
        for r in t.registers:
            if len(constr_deps.intersection(reg_deps[r])):
                t.registers[r].constraints.append((addr, c,ctype))

        # Check for tfp expr
        if len(constr_deps.intersection(reg_deps[t.reg])):
            t.constraints.append((addr, c,ctype))

    l.warning("==========================")
