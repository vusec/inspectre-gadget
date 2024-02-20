import angr
import claripy
import sys
from pathlib import Path

# autopep8: off
from ..shared.logger import *
from ..shared.transmission import *
from ..shared.taintedFunctionPointer import *
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
            new_annotations.append(LoadAnnotation(None, name, anno.address, None))
        else:
            new_annotations.append(anno)

    return new_annotations


def get_load_comments(expr: claripy.BV, secret_load_pc):
    annotations = {}
    for v in get_vars(expr):
        load_anno = get_load_annotation(v)

        if load_anno != None:
            if load_anno.address == secret_load_pc:
                # We load the secret value
                annotations[load_anno.address] = str(set(replace_secret_annotations_with_name(get_annotations(load_anno.read_address_ast), "Attacker")))
                annotations[load_anno.address] += " -> " + str(set(replace_secret_annotations_with_name(get_annotations(v), "Secret")))
            else:
                # We load an attacker indirect value
                annotations[load_anno.address] = str(set(replace_secret_annotations_with_name(get_annotations(load_anno.read_address_ast), "Attacker")))
                annotations[load_anno.address] += " -> " + str(set(replace_secret_annotations_with_name(get_annotations(v), "Attacker")))

            annotations.update(get_load_comments(load_anno.read_address_ast, secret_load_pc))

    return annotations

def print_annotations(t: Transmission):
    print(f"Printing comments for {t.transmission.expr}")
    a = get_load_comments(t.transmission.expr)
    print(a)


def print_annotated_assembly(proj, bbls, branches, expr, pc, secret_load_pc, is_tfp=False, color=True):
    # Branches.
    proj.kb.comments = get_branch_comments(branches)
    # Loads.
    proj.kb.comments.update(get_load_comments(expr,secret_load_pc))
    # Transmission
    if is_tfp:
        proj.kb.comments[pc] = str(set(replace_secret_annotations_with_name(get_annotations(expr), "Attacker")))
        proj.kb.comments[pc] += " -> " + "TAINTED FUNCTION POINTER"
    else:
        all_annotations = set(get_annotations(expr))
        secret_annotations = {a for a in all_annotations if isinstance(a, LoadAnnotation) and a.address == secret_load_pc}
        annotations = replace_secret_annotations_with_name(secret_annotations, "Secret")
        annotations += replace_secret_annotations_with_name(all_annotations - secret_annotations, "Attacker")
        proj.kb.comments[pc] = str(set(annotations))
        proj.kb.comments[pc] += " -> " + "TRANSMISSION"


    output = ""
    for bbl_addr in bbls:
        block = proj.factory.block(bbl_addr)
        output += proj.analyses.Disassembly(ranges=[(block.addr, block.addr + block.size)]).render(color=color)
        output += "\n"

    proj.kb.comments = {}
    return output

def output_gadget_to_file(t : Transmission, proj, path):
    Path(path).mkdir(parents=True, exist_ok=True)
    o = open(f"{path}/gadget_{t.name}_{hex(t.pc)}_{t.uuid}.asm", "a+")
    o.write(f"----------------- TRANSMISSION -----------------\n")
    o.write(print_annotated_assembly(proj, t.bbls, t.branches, t.transmission.expr, t.pc, t.secret_load_pc, is_tfp=False, color=False))
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


def has_aliasing(reg):
    return reg.control == TFPRegisterControlType.DEPENDS_ON_TFP_EXPR or reg.control == TFPRegisterControlType.INDIRECTLY_DEPENDS_ON_TFP_EXPR

def output_tfp_to_file(t : TaintedFunctionPointer, proj, path):
    Path(path).mkdir(parents=True, exist_ok=True)
    o = open(f"{path}/tfp_{t.name}_{hex(t.pc)}_{t.uuid}.asm", "a+")
    o.write(f"--------------------- TFP ----------------------\n")
    o.write(print_annotated_assembly(proj, t.bbls, t.branches, t.expr, t.pc, None, is_tfp=True, color=False))
    o.write(f"""
{'-'*48}
uuid: {t.uuid}

Reg: {t.reg}
Expr: {t.expr}

Constraints: {[(hex(addr),cond, str(ctype)) for addr,cond,ctype in t.constraints]}
Branches: {[(hex(addr), expr, outcome) for addr, expr, outcome in t.branches]}

""")

    o.write(f"CONTROLLED:\n")
    for r in t.controlled:
        o.write(f"{r}: {t.registers[r].expr}\n")

    o.write(f"\nREGS ALIASING WITH TFP:\n")
    for r in t.aliasing:
        o.write(f"{r}: {t.registers[r].expr}\n")

    o.write(f"\n")
    o.write(f"Uncontrolled Regs: {t.uncontrolled}\n")
    o.write(f"Unmodified Regs: {t.unmodified}\n")
    o.write(f"Potential Secrets: {t.secrets}\n")

    o.write(f"""
{'-'*48}
""")
    o.close()
