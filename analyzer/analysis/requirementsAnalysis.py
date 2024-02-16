"""RequirementsAnalysis

This analysis calculates which registers and memory locations have to be
controlled or leaked by the attacker in order to trigger a transmission.
"""

import claripy
import sys

# autopep8: off
from ..shared.transmission import *
from ..shared.taintedFunctionPointer import *
from ..shared.utils import *
from ..shared.astTransform import *
from ..shared.logger import *
from ..scanner.annotations import *
# autopep8: on

l = get_logger("ReqAnalysis")


def get_requirements(expr: claripy.BV) -> Requirements:
    req = Requirements()
    syms = get_vars(expr)

    l.info(f"Analyzing: {expr}")

    # Gather all the requirements.
    for s in syms:
        load_anno = get_load_annotation(s)

        if load_anno == None:
            req.regs.add(s)
        else:
            req.merge(load_anno.requirements)

    # Check which registers are used directly in the expression and which
    # are used indirectly through loads.
    ind_regs = {}
    for reg in req.regs:
        if reg in syms:
            req.direct_regs.add(reg)
        else:
            ind_regs[reg] = []

    # Check if any of the indirect registers is used with a constant offset.
    for mem in req.mem:
        const_part = 0
        var_part = None
        for v in extract_summed_vals(mem):
            # If there's exactly one variable, save it.
            if get_attacker_annotation(v) != None:
                if var_part == None:
                    var_part = v
                else:
                    var_part = None
                    break
            # If all the rest is concrete values, save them also
            elif v.concrete:
                const_part += v.concrete_value
            # Whenever we encounter a symbolic variable, bail out.
            else:
                var_part = None
                break

        if var_part != None and var_part not in req.direct_regs:
            ind_regs[var_part].append(hex(const_part))
    # Save indirect registers information.
    req.indirect_regs = ind_regs

    l.info(f"   direct: {req.direct_regs},   indirect: {ind_regs}")
    return req

def get_control(c: TransmissionComponent) -> ControlType:
    # TODO: check aliasing
    if len(c.requirements.const_mem) == 0 and len(c.requirements.mem) == 0 and len(c.requirements.regs) == 0:
            return ControlType.NO_CONTROL

    controlled = False
    has_uncontrolled_components = False
    for v in get_vars(c.expr):
        load_anno = get_load_annotation(v)
        uncontrolled_anno = get_uncontrolled_annotation(v)

        l.info(f"{v}:     {load_anno}    {uncontrolled_anno}")

        if uncontrolled_anno == None and (load_anno == None  or load_anno.controlled == True):
            controlled = True
        else:
            has_uncontrolled_components = True

    if not controlled:  # and has_uncontrolled_components:
        # return ControlType.REQUIRES_MEM_MASSAGING
        return ControlType.NO_CONTROL

    if controlled and not has_uncontrolled_components:
        return ControlType.CONTROLLED

    if controlled and has_uncontrolled_components:
        return ControlType.REQUIRES_MEM_LEAK

    return ControlType.NO_CONTROL

def get_transmission_control(t: Transmission):
    if t.secret_address.control == ControlType.NO_CONTROL:
        return ControlType.NO_CONTROL

    if (t.base != None and t.base.control == ControlType.REQUIRES_MEM_LEAK) or t.secret_address.control == ControlType.REQUIRES_MEM_LEAK:
        return ControlType.REQUIRES_MEM_LEAK

    return ControlType.CONTROLLED



def analyse(t: Transmission):
    l.warning(f"========= [REQS] ==========")

    for c in [t.base, t.transmitted_secret, t.secret_address, t.transmission, t.independent_base]:
        if c != None:
            c.requirements = get_requirements(c.expr)
            c.control = get_control(c)

    t.transmission.control = get_transmission_control(t)

    t.branch_requirements = Requirements()
    for b in t.branches:
        t.branch_requirements.merge(get_requirements(b[1]))

    t.constraint_requirements = Requirements()
    for addr,c,ctype in t.constraints:
        t.constraint_requirements.merge(get_requirements(c))

    t.all_requirements = Requirements()
    t.all_requirements.merge(t.transmission.requirements)
    t.all_requirements.merge(t.secret_address.requirements)
    t.all_requirements.merge(t.constraint_requirements)

    t.all_requirements_w_branches = Requirements()
    t.all_requirements_w_branches.merge(t.all_requirements)
    t.all_requirements_w_branches.merge(t.branch_requirements)

    l.warning(f"base_requirements:  {'NONE' if t.base == None else t.base.requirements}")
    l.warning(f"secret_address_requirements:  {t.secret_address.requirements}")
    l.warning(f"transmitted_secret_requirements:  {t.transmitted_secret.requirements}")
    l.warning(f"transmission_requirements:  {t.transmission.requirements}")
    l.warning("==========================")

    # TODO ?
    # t.properties["base_requirements_w_constraints"] = get_requirements(t.base, constraints=True)
    # t.properties["secret_address_requirements_w_constraints"] = get_requirements(t.secret_addr, constraints=True)
    # t.properties["transmission_requirements_w_constraints"] = get_requirements(t.transmission_expr, constraints=True)

def analyse_tfp(t: TaintedFunctionPointer):
    l.warning(f"========= [REQS] ==========")
    for r in t.registers:
        t.registers[r].requirements = get_requirements(t.registers[r].expr)

    t.requirements = get_requirements(t.expr)
    l.warning("==========================")
