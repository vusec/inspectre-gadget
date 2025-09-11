"""RequirementsAnalysis

This analysis calculates which registers and memory locations have to be
controlled or leaked by the attacker in order to trigger a transmission.
"""

import claripy
import sys

# autopep8: off
from ..shared.transmission import *
from ..shared.taintedFunctionPointer import *
from ..shared.halfGadget import HalfGadget
from ..shared.utils import *
from ..shared.astTransform import *
from ..shared.logger import *
from ..scanner.annotations import *
# autopep8: on

l = get_logger("ReqAnalysis")


def get_requirements(expr: claripy.ast.BV) -> Requirements:
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


def get_control(c: TransmissionComponent, report_massaging=False) -> ControlType:
    # TODO: check aliasing
    if len(c.requirements.const_mem) == 0 and len(c.requirements.mem) == 0 and len(c.requirements.regs) == 0:
        return ControlType.NO_CONTROL

    # At least one component is controlled
    has_controlled_components = False
    # At least one component is explicitly marked as uncontrolled
    has_uncontrolled_components = False

    # Check the annotations of all the symbols in the expression
    for v in get_vars(c.expr):
        for anno in v.annotations:
            if isinstance(anno, AttackerAnnotation):
                # Attacker symbols are directly controlled
                has_controlled_components = True
            elif isinstance(anno, LoadAnnotation) and anno.controlled == True:
                # Controlled load
                has_controlled_components = True
            else:
                # Symbolic value that is not controlled
                has_uncontrolled_components = True

    if has_controlled_components:
        if has_uncontrolled_components:
            # If an expression has both controlled and uncontrolled symbols,
            # it means that you can control the final value of the expression
            # only if you know the value of the uncontrolled part.
            return ControlType.REQUIRES_MEM_LEAK
        else:
            # All symbols are controlled.
            return ControlType.CONTROLLED
    else:
        # If we are here, the expression has at least one symbol, but none of the
        # symbols are controlled, so for sure we have at least one uncontrolled symbol.
        assert (has_uncontrolled_components)
        if report_massaging:
            # If an expression contains only _uncontrolled_ symbols, i.e. symbols
            # that are not derived by the initial attacker-controlled registers,
            # an attacker might still be able to influence these values through
            # memory massaging, e.g. by placing attacker-controlled data in
            # these uncontrolled positions.
            # Since we don't do an analysis of what is considered "massageable",
            # we let the user decide whether such gadgets should be reported
            # or not.
            return ControlType.REQUIRES_MEM_MASSAGING
        else:
            # There are no attacker-controlled components in this expression.
            return ControlType.NO_CONTROL

    # Unreachable
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
    for addr, c, ctype in t.constraints:
        t.constraint_requirements.merge(get_requirements(c))

    t.all_requirements = Requirements()
    t.all_requirements.merge(t.transmission.requirements)
    t.all_requirements.merge(t.secret_address.requirements)
    t.all_requirements.merge(t.constraint_requirements)

    t.all_requirements_w_branches = Requirements()
    t.all_requirements_w_branches.merge(t.all_requirements)
    t.all_requirements_w_branches.merge(t.branch_requirements)

    l.warning(
        f"base_requirements:  {'NONE' if t.base == None else t.base.requirements}")
    l.warning(f"secret_address_requirements:  {t.secret_address.requirements}")
    l.warning(
        f"transmitted_secret_requirements:  {t.transmitted_secret.requirements}")
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
        t.registers[r].control = get_control(t.registers[r])

        if t.registers[r].control in (ControlType.REQUIRES_MEM_LEAK, ControlType.REQUIRES_MEM_MASSAGING, ControlType.CONTROLLED):
            t.controlled.append(r)

    t.requirements = get_requirements(t.expr)
    t.control = get_control(t)

    l.warning("==========================")


def analyse_half_gadget(g: HalfGadget):
    l.warning(f"========= [REQS] ==========")

    # Calculate for main expression.
    g.loaded.requirements = get_requirements(g.loaded.expr)
    g.loaded.control = get_control(g.loaded, report_massaging=True)

    # Calculate for components.
    for c in [g.base, g.uncontrolled_base, g.attacker]:
        if c != None:
            c.requirements = get_requirements(c.expr)
            c.control = get_control(c,)

    g.branch_requirements = Requirements()
    for b in g.branches:
        g.branch_requirements.merge(get_requirements(b[1]))

    g.constraint_requirements = Requirements()
    for addr, c, ctype in g.constraints:
        g.constraint_requirements.merge(get_requirements(c))

    g.all_requirements = Requirements()
    if g.base is not None:
        g.all_requirements.merge(g.base.requirements)
    g.all_requirements.merge(g.attacker.requirements)
    g.all_requirements.merge(g.constraint_requirements)

    g.all_requirements_w_branches = Requirements()
    g.all_requirements_w_branches.merge(g.all_requirements)
    g.all_requirements_w_branches.merge(g.branch_requirements)

    l.warning(
        f"base_requirements:  {'NONE' if g.base == None else g.base.requirements}")
    l.warning(
        f"uncontrolled_base_requirements:  {'NONE' if g.uncontrolled_base == None else g.uncontrolled_base.requirements}")
    l.warning(f"attacker_requirements:  {g.attacker.requirements}")
    l.warning("==========================")
