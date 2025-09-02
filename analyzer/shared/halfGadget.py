"""
HalfGadget object (a.k.a. MDS gadgets).
"""

import claripy
from enum import Enum
import json
from collections import OrderedDict

from . import ranges
from . import utils
from .transmission import TransmissionComponent, Requirements, component_to_dict


class HalfGadget():
    """
    Object that represents a "half" Spectre gadget.
    A half-spectre gadget consist only of an attacker-controlled load,
    which can be used to either prefetch a secret into the cache (for Meltdown
    attacks), into the LFB (for MDS attacks), or even for Rowhammer attacks
    (ProbeHammer).
    """
    uuid: str
    name: str
    pc: int
    n_instr: int
    contains_spec_stop: bool
    max_load_depth: int

    loaded: TransmissionComponent
    # Components.
    base: TransmissionComponent
    attacker: TransmissionComponent
    # Portion of the base that is uncontrolled (but not constant)
    uncontrolled_base: TransmissionComponent

    # Properties found at scanning time.
    aliases: list[claripy.ast.BV]
    branches: list[tuple[int, claripy.ast.BV]]
    branch_requirements: Requirements

    constraints: list[claripy.ast.BV]
    constraint_requirements: Requirements

    all_requirements: Requirements

    def __init__(self, expr: claripy.ast.BV, pc: int, n_instr: int,
                 contains_spec_stop: bool, aliases, constraints, branches, bbls):
        self.uuid = ""
        self.name = ""
        self.pc = pc
        self.n_instr = n_instr
        self.contains_spec_stop = contains_spec_stop
        self.max_load_depth = 0

        self.loaded = TransmissionComponent()
        self.loaded.expr = expr
        self.base = TransmissionComponent()
        self.uncontrolled_base = TransmissionComponent()
        self.attacker = TransmissionComponent()

        self.aliases = aliases
        for x in aliases:
            assert (' if ' not in str(x))
        self.branches = branches
        self.bbls = bbls
        # TODO check if branches contain if-then-else
        self.constraints = constraints
        self.properties = {}

        self.branch_requirements = Requirements()
        self.constraint_requirements = Requirements()
        self.all_requirements = Requirements()
        self.all_requirements_w_branches = Requirements()

    def __repr__(self):
        return f"""
        uuid: {self.uuid}
        name: {self.name}
        pc: {hex(self.pc)}
        expr: {self.loaded.expr}

        loaded:
            {self.loaded}
          └── base:
            {self.base}
                └── uncontrolled part:
                {self.uncontrolled_base}
          └── attacker-controlled:
            {self.attacker}


        branches: {utils.ordered_branches(self.branches)}
        bbls: {[hex(x) for x in self.bbls]}
        branch requirements: {self.branch_requirements}

        constraints: {utils.ordered_constraints(self.constraints)}
        constraint requirements: {self.constraint_requirements}

        all requirements: {self.all_requirements}
        all requirements_w_branches: {self.all_requirements_w_branches}

        aliases: {self.aliases}
        n_instr: {self.n_instr}
        n_dependent_loads: {self.max_load_depth}
        """

    def to_dict(self):
        d = OrderedDict()

        d['uuid'] = self.uuid
        d['name'] = self.name
        d['pc'] = hex(self.pc)
        d['expr'] = self.loaded.expr
        d['n_instr'] = self.n_instr
        d['n_dependent_loads'] = self.max_load_depth
        d['contains_spec_stop'] = self.contains_spec_stop
        d['bbls'] = str([hex(x) for x in self.bbls])

        d['loaded'] = component_to_dict(self.loaded)
        d['base'] = component_to_dict(self.base)
        d['uncontrolled_base'] = component_to_dict(self.uncontrolled_base)
        d['attacker'] = component_to_dict(self.attacker)

        d['branches'] = utils.ordered_branches(self.branches)
        d['branch_requirements'] = self.branch_requirements
        d['constraints'] = utils.ordered_constraints(self.constraints)
        d['constraint_requirements'] = self.constraint_requirements
        d['all_requirements'] = self.all_requirements
        d['all_requirements_w_branches'] = self.all_requirements_w_branches

        d['aliases'] = [str(x.to_BV()) for x in self.aliases]

        return d
