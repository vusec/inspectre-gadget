import angr
import claripy
import sys
from pathlib import Path
from enum import Enum

# autopep8: off
from ..shared.logger import *
from ..shared.transmission import *
from ..shared.taintedFunctionPointer import *
from ..shared.halfGadget import HalfGadget
from ..shared.secretDependentBranch import SecretDependentBranch
from ..shared.utils import *
from ..scanner.annotations import *
# autopep8: on


def get_branch_comments(branches):
    comments = {}
    for addr, condition, taken in branches:
        comments[addr] = str(taken) + "   " + str(condition)

    return comments


def replace_secret_annotations_with_name(annotations, name):
    new_annotations = []
    for anno in annotations:
        if isinstance(anno, SecretAnnotation) or isinstance(anno, TransmissionAnnotation):
            new_annotations.append(LoadAnnotation(
                None, name, anno.address, None))
        else:
            new_annotations.append(anno)

    return new_annotations


def get_load_comments(expr: claripy.ast.BV, secret_load_pc):
    annotations = {}
    for v in get_vars(expr):
        load_anno = get_load_annotation(v)

        if load_anno != None:
            if load_anno.address == secret_load_pc:
                # We load the secret value
                annotations[load_anno.address] = str(set(replace_secret_annotations_with_name(
                    get_annotations(load_anno.read_address_ast), "Attacker")))
                annotations[load_anno.address] += " -> " + str(
                    set(replace_secret_annotations_with_name(get_annotations(v), "Secret")))
            else:
                # We load an attacker indirect value
                annotations[load_anno.address] = str(set(replace_secret_annotations_with_name(
                    get_annotations(load_anno.read_address_ast), "Attacker")))
                annotations[load_anno.address] += " -> " + str(
                    set(replace_secret_annotations_with_name(get_annotations(v), "Attacker")))

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
                f";{symbol.name}+{bbl_addr-symbol.rebased_addr}:\n"

        # Add the assembly code
        block = proj.factory.block(bbl_addr)
        prev_block = block
        output += proj.analyses.Disassembly(
            ranges=[(block.addr, block.addr + block.size)]).render(color=color)

        output += "\n"

    return output


def print_annotated_assembly(proj: angr.Project, bbls, branches, expr, pc, secret_load_pc, type: GadgetType, color=True):
    # Branches.
    proj.kb.comments = get_branch_comments(branches)
    # Loads.
    proj.kb.comments.update(get_load_comments(expr, secret_load_pc))
    # Transmission
    if type == GadgetType.TFP:
        proj.kb.comments[pc] = str(
            set(replace_secret_annotations_with_name(get_annotations(expr), "Attacker")))
        proj.kb.comments[pc] += " -> " + "TAINTED FUNCTION POINTER"
    elif type == GadgetType.HALF:
        proj.kb.comments[pc] = str(
            set(replace_secret_annotations_with_name(get_annotations(expr), "Attacker")))
        proj.kb.comments[pc] += " -> " + "HALF GADGET"
    elif type == GadgetType.TRANSMISSION:
        all_annotations = set(get_annotations(expr))
        secret_annotations = {a for a in all_annotations if isinstance(
            a, LoadAnnotation) and a.address == secret_load_pc}
        annotations = replace_secret_annotations_with_name(
            secret_annotations, "Secret")
        annotations += replace_secret_annotations_with_name(
            all_annotations - secret_annotations, "Attacker")
        proj.kb.comments[pc] = str(set(annotations))
        proj.kb.comments[pc] += " -> " + "TRANSMISSION"
    elif type == GadgetType.SDB:
        all_annotations = set(get_annotations(expr))
        secret_annotations = {a for a in all_annotations if isinstance(
            a, LoadAnnotation) and a.address == secret_load_pc}
        annotations = replace_secret_annotations_with_name(
            secret_annotations, "Secret")
        annotations += replace_secret_annotations_with_name(
            all_annotations - secret_annotations, "Attacker")
        proj.kb.comments[pc] = str(set(annotations))
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
    o.write(f"""
{'-'*48}
uuid: {t.uuid}
transmitter: {t.transmitter}

Secret Address:
  - Expr: {t.secret_address.expr}
  - Range: {t.secret_address.range}
Transmitted Secret:
  - Expr: {t.transmitted_secret.expr}
  - Range: {t.transmitted_secret.range}
  - Spread: {t.inferable_bits.spread_low} - {t.inferable_bits.spread_high}
  - Number of Bits Inferable: {t.inferable_bits.number_of_bits_inferable}
Base:
  - Expr: {'None' if t.base == None else t.base.expr}
  - Range: {'None' if t.base == None else t.base.range}
  - Independent Expr: {'None' if t.independent_base == None else t.independent_base.expr}
  - Independent Range: {'None' if t.independent_base == None else t.independent_base.range}
Transmission:
  - Expr: {t.transmission.expr}
  - Range: {t.transmission.range}

Register Requirements: {t.all_requirements.regs}
Constraints: {[(hex(addr),cond, str(ctype)) for addr,cond,ctype in t.constraints]}
Branches: {[(hex(addr), expr, outcome) for addr, expr, outcome in t.branches]}
{'-'*48}
""")
    o.close()


def output_tfp_to_file(t: TaintedFunctionPointer, proj, path):
    Path(path).mkdir(parents=True, exist_ok=True)
    o = open(f"{path}/tfp_{t.name}_{hex(t.pc)}_{t.uuid}.asm", "a+")
    o.write(f"--------------------- TFP ----------------------\n")
    o.write(print_annotated_assembly(proj, t.bbls, t.branches,
            t.expr, t.pc, None, type=GadgetType.TFP, color=False))
    o.write(f"""
{'-'*48}
uuid: {t.uuid}

Reg: {t.reg}
Expr: {t.expr}
Tainted Function Pointer:
  - Reg: {t.reg}
  - Expr: {t.expr}
  - Control: {t.control}
  - Register Requirements: {t.requirements.regs}

Constraints: {[(hex(addr),cond, str(ctype)) for addr,cond,ctype in t.constraints]}
Branches: {[(hex(addr), expr, outcome) for addr, expr, outcome in t.branches]}

""")

    o.write(f"Controlled Regs:\n")
    for r in t.controlled:
        o.write(f"  - Reg: {r}\n")
        o.write(f"    Expr: {t.registers[r].expr}\n")
        o.write(f"    ControlType: {t.registers[r].control_type}\n")
        o.write(f"    Controlled Expr: {t.registers[r].controlled_expr}\n")
        o.write(f"    Controlled Range: {t.registers[r].controlled_range}\n")
        o.write(f"    Controlled Range w Branches:"
                f"{t.registers[r].controlled_range_with_branches}\n")

    o.write(f"\nRegisters aliasing with tfp:\n")

    o.write(f"\nRegisters aliasing with tfp:\n")
    for r in t.aliasing:
        o.write(f"  - Reg: {r}\n")
        o.write(f"    Expr: {t.registers[r].expr}\n")
        o.write(f"    Range: {t.registers[r].range}\n")
        o.write(f"    ControlType: {t.registers[r].control_type}\n")

    o.write(f"\n")
    o.write(f"Uncontrolled Regs: {t.uncontrolled}\n")
    o.write(f"Unmodified Regs: {t.unmodified}\n")
    o.write(f"Potential Secrets: {t.secrets}\n")

    o.write(f"""
{'-'*48}
""")
    o.close()


def output_half_gadget_to_file(g: HalfGadget, proj, path):
    Path(path).mkdir(parents=True, exist_ok=True)
    o = open(f"{path}/halfgadget_{g.name}_{hex(g.pc)}_{g.uuid}.asm", "a+")
    o.write(f"--------------------- HALF GADGET ----------------------\n")
    o.write(print_annotated_assembly(proj, g.bbls, g.branches,
            g.loaded.expr, g.pc, None, type=GadgetType.HALF, color=False))
    o.write(f"""
{'-'*48}
uuid: {g.uuid}

Expr: {g.loaded.expr}
Base: {'None' if g.base == None else g.base.expr}
Attacker: {g.attacker.expr}
ControlType: {g.loaded.control}

Constraints: {[(hex(addr),cond, str(ctype)) for addr,cond,ctype in g.constraints]}
Branches: {[(hex(addr), expr, outcome) for addr, expr, outcome in g.branches]}

""")

    o.write(f"""
{'-'*48}
""")
    o.close()


def output_secret_dependent_branch_to_file(sdb: SecretDependentBranch, proj, path):
    Path(path).mkdir(parents=True, exist_ok=True)
    o = open(f"{path}/sdb_{sdb.name}_{hex(sdb.pc)}_{sdb.uuid}.asm", "a+")
    o.write(f"------------ SECRET DEPENDENT BRANCH ------------\n")
    o.write(print_annotated_assembly(proj, sdb.bbls, sdb.branches, sdb.sdb_expr,
            sdb.pc, sdb.secret_load_pc, GadgetType.SDB, color=False))
    o.write(f"""
{'-'*48}
uuid: {sdb.uuid}
transmitter: {sdb.transmitter}
CMP operation: {sdb.cmp_operation}

Secret Dependent Branch:
  - Expr: {sdb.sdb_expr}
Secret Address:
  - Expr: {sdb.secret_address.expr}
  - Range: {sdb.secret_address.range}
Transmitted Secret:
  - Expr: {sdb.transmitted_secret.expr}
  - Range: {sdb.transmitted_secret.range}
  - Spread: {sdb.inferable_bits.spread_low} - {sdb.inferable_bits.spread_high}
  - Number of Bits Inferable: {sdb.inferable_bits.number_of_bits_inferable}
Base:
  - Expr: {'None' if sdb.base == None else sdb.base.expr}
  - Range: {'None' if sdb.base == None else sdb.base.range}
  - Independent Expr: {'None' if sdb.independent_base == None else sdb.independent_base.expr}
  - Independent Range: {'None' if sdb.independent_base == None else sdb.independent_base.range}
Transmission:
  - Expr: {sdb.transmission.expr}
  - Range: {sdb.transmission.range}

CMP Value:
  - Expr: {sdb.cmp_value.expr}
  - Range: {sdb.cmp_value.range}
  - Controlled Expr: {'None' if sdb.controlled_cmp_value == None else sdb.controlled_cmp_value.expr}
  - Controlled Range: {'None' if sdb.controlled_cmp_value == None else sdb.controlled_cmp_value.range}

Register Requirements:
  - All: {sdb.all_requirements.regs}
  - Transmission: {sdb.transmission.requirements.regs}
  - CMP Value: {sdb.cmp_value.requirements.regs}

Constraints: {[(hex(addr),cond, str(ctype)) for addr,cond,ctype in sdb.constraints]}
Branches: {[(hex(addr), expr, outcome) for addr, expr, outcome in sdb.branches]}
{'-'*48}
""")
    o.close()
