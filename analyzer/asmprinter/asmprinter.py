import angr
import claripy
import sys
from pathlib import Path
from enum import Enum

# autopep8: off
from ..shared.transmission import Transmission
from ..shared.taintedFunctionPointer import TaintedFunctionPointer
from ..shared.halfGadget import HalfGadget
from ..shared.secretDependentBranch import SecretDependentBranch
from ..shared import utils
from ..scanner import annotations as annotations_module
from ..scanner.annotations import (LoadAnnotation, SecretAnnotation,
                                   TransmissionAnnotation)
# autopep8: on


def get_branch_comments(branches):
    comments = {}
    for addr, condition, taken in branches:
        comments[addr] = str(taken) + "   " + utils.truncate_str(str(condition))

    return comments


def replace_secret_annotations_with_name(annotations, name):
    new_annotations = []
    for anno in annotations:
        if isinstance(anno, (SecretAnnotation, TransmissionAnnotation)):
            new_annotations.append(LoadAnnotation(
                None, name, anno.address, None))
        else:
            new_annotations.append(anno)

    return new_annotations


def get_load_comments(expr: claripy.ast.BV, secret_load_pc):
    annotations = {}
    for v in utils.get_vars(expr):
        load_anno = annotations_module.get_load_annotation(v)

        if load_anno != None:
            if load_anno.address == secret_load_pc:
                # We load the secret value
                loaded_name = "Secret"
            else:
                # We load an attacker indirect value
                loaded_name = "Attacker"

            addr_annos = replace_secret_annotations_with_name(
                utils.get_annotations(load_anno.read_address_ast), "Attacker")
            val_annos = replace_secret_annotations_with_name(
                utils.get_annotations(v), loaded_name)
            annotations[load_anno.address] = (utils.sorted_set_str(addr_annos) + " -> "
                                              + utils.sorted_set_str(val_annos))

            annotations.update(get_load_comments(
                load_anno.read_address_ast, secret_load_pc))

    return annotations


def print_annotations(t: Transmission):
    print(f"Printing comments for {t.transmission.expr}")
    a = get_load_comments(t.transmission.expr)
    print(a)


class GadgetType(Enum):
    TRANSMISSION = 0,
    TFP = 1,
    HALF = 2,
    SDB = 3,
    UNKNOWN = 3


def get_disassembled_trace_text(proj, bbls, color=True):

    prev_block = None
    output = ""
    for bbl_addr in bbls:
        # Symbol
        symbol = proj.loader.find_symbol(bbl_addr, fuzzy=True)
        # We want a symbol add every non-fallthrough
        # As Disassembly adds a symbol at the start of the function, we do not
        if symbol != None and symbol.rebased_addr != bbl_addr and \
                (prev_block == None or prev_block.addr + prev_block.size != bbl_addr):
            # Non-fallthrough and Capstone did not add a symbol
            bytes_width = (bbl_addr.bit_length() + 3) // 4 + 2
            output += " " * bytes_width + \
                f";{symbol.name}+{bbl_addr - symbol.rebased_addr}:\n"

        # Add the assembly code
        block = proj.factory.block(bbl_addr)
        prev_block = block
        output += proj.analyses.Disassembly(
            ranges=[(block.addr, block.addr + block.size)]).render(color=color)

        output += "\n"

    return output


def print_annotated_assembly(proj: angr.Project, bbls, branches, expr, pc,
                             secret_load_pc, type: GadgetType, color=True):
    # Branches.
    proj.kb.comments = get_branch_comments(branches)
    # Loads.
    proj.kb.comments.update(get_load_comments(expr, secret_load_pc))
    # Transmission
    if type == GadgetType.TFP:
        attacker_annos = replace_secret_annotations_with_name(
            utils.get_annotations(expr), "Attacker")
        proj.kb.comments[pc] = utils.sorted_set_str(attacker_annos)
        proj.kb.comments[pc] += " -> " + "TAINTED FUNCTION POINTER"
    elif type == GadgetType.HALF:
        attacker_annos = replace_secret_annotations_with_name(
            utils.get_annotations(expr), "Attacker")
        proj.kb.comments[pc] = utils.sorted_set_str(attacker_annos)
        proj.kb.comments[pc] += " -> " + "HALF GADGET"
    elif type == GadgetType.TRANSMISSION:
        all_annotations = set(utils.get_annotations(expr))
        secret_annotations = {a for a in all_annotations if isinstance(
            a, LoadAnnotation) and a.address == secret_load_pc}
        annotations = replace_secret_annotations_with_name(
            secret_annotations, "Secret")
        annotations += replace_secret_annotations_with_name(
            all_annotations - secret_annotations, "Attacker")
        proj.kb.comments[pc] = utils.sorted_set_str(annotations)
        proj.kb.comments[pc] += " -> " + "TRANSMISSION"
    elif type == GadgetType.SDB:
        all_annotations = set(utils.get_annotations(expr))
        secret_annotations = {a for a in all_annotations if isinstance(
            a, LoadAnnotation) and a.address == secret_load_pc}
        annotations = replace_secret_annotations_with_name(
            secret_annotations, "Secret")
        annotations += replace_secret_annotations_with_name(
            all_annotations - secret_annotations, "Attacker")
        proj.kb.comments[pc] = utils.sorted_set_str(annotations)
        proj.kb.comments[pc] += " -> " + "SECRET DEPENDENT BRANCH"

    output = get_disassembled_trace_text(proj, bbls, color)

    proj.kb.comments = {}
    return output


def output_gadget_to_file(t: Transmission, proj, path):
    Path(path).mkdir(parents=True, exist_ok=True)
    o = open(f"{path}/gadget_{t.name}_{hex(t.pc)}_{t.uuid}.asm", "a+")
    o.write(f"----------------- TRANSMISSION -----------------\n")
    o.write(print_annotated_assembly(proj, t.bbls, t.branches, t.transmission.expr,
            t.pc, t.secret_load_pc, type=GadgetType.TRANSMISSION, color=False))

    if t.independent_base == None:
        indep_expr = indep_range = 'None'
    else:
        indep_expr = utils.truncate_str(t.independent_base.expr)
        indep_range = utils.truncate_str(t.independent_base.range)

    o.write(f"""
{'-' * 48}
uuid: {t.uuid}
transmitter: {t.transmitter}

Secret Address:
  - Expr: {utils.truncate_str(t.secret_address.expr)}
  - Range: {t.secret_address.range}
Transmitted Secret:
  - Expr: {utils.truncate_str(t.transmitted_secret.expr)}
  - Range: {t.transmitted_secret.range}
  - Spread: {t.inferable_bits.spread_low} - {t.inferable_bits.spread_high}
  - Number of Bits Inferable: {t.inferable_bits.number_of_bits_inferable}
Base:
  - Expr: {'None' if t.base == None else utils.truncate_str(t.base.expr)}
  - Range: {'None' if t.base == None else t.base.range}
  - Independent Expr: {indep_expr}
  - Independent Range: {indep_range}
Transmission:
  - Expr: {utils.truncate_str(t.transmission.expr)}
  - Range: {t.transmission.range}

Register Requirements: {t.all_requirements.to_dict()['regs']}
Constraints: {utils.ordered_constraints(t.constraints)}
Branches: {utils.ordered_branches(t.branches)}
{'-' * 48}
""")
    o.close()


def output_tfp_to_file(t: TaintedFunctionPointer, proj, path):
    Path(path).mkdir(parents=True, exist_ok=True)
    o = open(f"{path}/tfp_{t.name}_{hex(t.pc)}_{t.uuid}.asm", "a+")
    o.write(f"--------------------- TFP ----------------------\n")
    o.write(print_annotated_assembly(proj, t.bbls, t.branches,
            t.expr, t.pc, None, type=GadgetType.TFP, color=False))
    o.write(f"""
{'-' * 48}
uuid: {t.uuid}

Reg: {t.reg}
Expr: {utils.truncate_str(t.expr)}
Tainted Function Pointer:
  - Reg: {t.reg}
  - Expr: {utils.truncate_str(t.expr)}
  - Control: {t.control}
  - Register Requirements: {t.requirements.to_dict()['regs']}

Constraints: {utils.ordered_constraints(t.constraints)}
Branches: {utils.ordered_branches(t.branches)}

""")

    o.write(f"Controlled Regs:\n")
    for r in t.controlled:
        reg = t.registers[r]
        o.write(f"  - Reg: {r}\n")
        o.write(f"    Expr: {utils.truncate_str(reg.expr)}\n")
        o.write(f"    ControlType: {reg.control_type}\n")
        o.write(f"    Controlled Expr: {utils.truncate_str(reg.controlled_expr)}\n")
        o.write(f"    Controlled Range: {reg.controlled_range}\n")
        o.write(f"    Controlled Range w Branches:"
                f"{reg.controlled_range_with_branches}\n")

    o.write(f"\nRegisters aliasing with tfp:\n")
    for r in t.aliasing:
        o.write(f"  - Reg: {r}\n")
        o.write(f"    Expr: {utils.truncate_str(t.registers[r].expr)}\n")
        o.write(f"    Range: {t.registers[r].range}\n")
        o.write(f"    ControlType: {t.registers[r].control_type}\n")

    o.write(f"\n")
    o.write(f"Uncontrolled Regs: {t.uncontrolled}\n")
    o.write(f"Unmodified Regs: {t.unmodified}\n")
    o.write(f"Potential Secrets: {t.secrets}\n")

    o.write(f"""
{'-' * 48}
""")
    o.close()


def output_half_gadget_to_file(g: HalfGadget, proj, path):
    Path(path).mkdir(parents=True, exist_ok=True)
    o = open(f"{path}/halfgadget_{g.name}_{hex(g.pc)}_{g.uuid}.asm", "a+")
    o.write(f"--------------------- HALF GADGET ----------------------\n")
    o.write(print_annotated_assembly(proj, g.bbls, g.branches,
            g.loaded.expr, g.pc, None, type=GadgetType.HALF, color=False))
    o.write(f"""
{'-' * 48}
uuid: {g.uuid}

Expr: {utils.truncate_str(g.loaded.expr)}
Base: {'None' if g.base == None else utils.truncate_str(g.base.expr)}
Attacker: {utils.truncate_str(g.attacker.expr)}
ControlType: {g.loaded.control}

Constraints: {utils.ordered_constraints(g.constraints)}
Branches: {utils.ordered_branches(g.branches)}

""")

    o.write(f"""
{'-' * 48}
""")
    o.close()


def output_secret_dependent_branch_to_file(sdb: SecretDependentBranch, proj, path):
    Path(path).mkdir(parents=True, exist_ok=True)
    o = open(f"{path}/sdb_{sdb.name}_{hex(sdb.pc)}_{sdb.uuid}.asm", "a+")
    o.write(f"------------ SECRET DEPENDENT BRANCH ------------\n")
    o.write(print_annotated_assembly(proj, sdb.bbls, sdb.branches, sdb.sdb_expr,
            sdb.pc, sdb.secret_load_pc, GadgetType.SDB, color=False))

    if sdb.independent_base == None:
        indep_expr = indep_range = 'None'
    else:
        indep_expr = utils.truncate_str(sdb.independent_base.expr)
        indep_range = sdb.independent_base.range

    if sdb.controlled_cmp_value == None:
        controlled_expr = controlled_range = 'None'
    else:
        controlled_expr = utils.truncate_str(sdb.controlled_cmp_value.expr)
        controlled_range = sdb.controlled_cmp_value.range

    o.write(f"""
{'-' * 48}
uuid: {sdb.uuid}
transmitter: {sdb.transmitter}
CMP operation: {sdb.cmp_operation}

Secret Dependent Branch:
  - Expr: {utils.truncate_str(sdb.sdb_expr)}
Secret Address:
  - Expr: {utils.truncate_str(sdb.secret_address.expr)}
  - Range: {sdb.secret_address.range}
Transmitted Secret:
  - Expr: {utils.truncate_str(sdb.transmitted_secret.expr)}
  - Range: {sdb.transmitted_secret.range}
  - Spread: {sdb.inferable_bits.spread_low} - {sdb.inferable_bits.spread_high}
  - Number of Bits Inferable: {sdb.inferable_bits.number_of_bits_inferable}
Base:
  - Expr: {'None' if sdb.base == None else utils.truncate_str(sdb.base.expr)}
  - Range: {'None' if sdb.base == None else sdb.base.range}
  - Independent Expr: {indep_expr}
  - Independent Range: {indep_range}
Transmission:
  - Expr: {utils.truncate_str(sdb.transmission.expr)}
  - Range: {sdb.transmission.range}

CMP Value:
  - Expr: {utils.truncate_str(sdb.cmp_value.expr)}
  - Range: {sdb.cmp_value.range}
  - Controlled Expr: {controlled_expr}
  - Controlled Range: {controlled_range}

Register Requirements:
  - All: {sdb.all_requirements.to_dict()['regs']}
  - Transmission: {sdb.transmission.requirements.regs}
  - CMP Value: {sdb.cmp_value.requirements.regs}

Constraints: {utils.ordered_constraints(sdb.constraints)}
Branches: {utils.ordered_branches(sdb.branches)}
{'-' * 48}
""")
    o.close()
