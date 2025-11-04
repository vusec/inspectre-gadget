import claripy
import capstone
import itertools
import traceback
from .config import global_config

def is_sym_expr(x) -> bool:
    return isinstance(x, claripy.ast.base.Base) and x.symbolic


def is_sym_var(x) -> bool:
    return is_sym_expr(x) and x.depth == 1


def get_vars(expr) -> set[claripy.ast.BV]:
    if not is_sym_expr(expr):
        return []

    return set([leaf for leaf in expr.leaf_asts() if is_sym_expr(leaf)])


def get_annotations(expr):
    annos = set()
    for v in get_vars(expr):
        annos.update(v.annotations)

    return annos


def get_x86_indirect_thunks(proj):
    symbol_names = {"__x86_indirect_thunk_array": "rax",
                    "__x86_indirect_thunk_r10": "r10",
                    "__x86_indirect_thunk_r11": "r11",
                    "__x86_indirect_thunk_r12": "r12",
                    "__x86_indirect_thunk_r13": "r13",
                    "__x86_indirect_thunk_r14": "r14",
                    "__x86_indirect_thunk_r15": "r15",
                    "__x86_indirect_thunk_r8": "r8",
                    "__x86_indirect_thunk_r9": "r9",
                    "__x86_indirect_thunk_rax": "rax",
                    "__x86_indirect_thunk_rbp": "rbp",
                    "__x86_indirect_thunk_rbx": "rbx",
                    "__x86_indirect_thunk_rcx": "rcx",
                    "__x86_indirect_thunk_rdi": "rdi",
                    "__x86_indirect_thunk_rdx": "rdx",
                    "__x86_indirect_thunk_rsi": "rsi",
                    }
    ind_calls = {}

    for symbol, reg in symbol_names.items():
        addr = proj.loader.find_symbol(symbol)
        if addr:
            ind_calls[addr.rebased_addr] = reg

    return ind_calls


def get_x86_registers():
    return ["rax", "rbx", "rcx", "rdx", "rsi",
            "rdi", "rbp", "rsp", "r8", "r9",
            "r10", "r11", "r12", "r13", "r14", "r15"]


def report_error(error: Exception, where="dunno", start_addr="dunno", error_type="GENERIC"):
    ins_addr = None
    if hasattr(error, 'ins_addr') and isinstance(error.ins_addr, int):
        ins_addr = hex(error.ins_addr)

    o = open("fail.txt", "a+")
    o.write(f"---------------- [ {error_type} ERROR ] ----------------\n")
    o.write(
        f"where: {where}     started at: {start_addr} {f'instruction addr: {ins_addr}' if ins_addr else ''}\n")
    o.write(str(error) + "\n")
    o.write(traceback.format_exc())
    o.write("\n")
    o.close()


def report_unsupported(error: Exception, proj, where="dunno", start_addr="dunno", error_type="GENERIC"):
    if hasattr(error, 'ins_addr') and isinstance(error.ins_addr, int):
        where = hex(error.ins_addr)

    try:
        mnemonic = get_mnemonic_at_address(proj, int(where, 16))
    except ValueError:
        mnemonic = ''

    if mnemonic == 'ud2':
        return

    o = open("unsupported.txt", "a+")
    o.write(
        f"---------------- [ {error_type} UNSUPPORTED INSTRUCTION ] ----------------\n")
    o.write(
        f"instruction addr: {where}     started at: {start_addr}     mnemonic: '{mnemonic}'\n")
    o.write(str(error) + "\n")
    o.write("\n")
    o.close()


def get_outcome(cond, source, target):
    if cond.concrete:
        if cond.is_true():
            return "Taken"
        else:
            return "Not Taken"
    elif target.symbolic:
        return "Indirect JMP"
    else:
        # TODO: this is an approximation, find a better way to
        # understand if the branch was taken or not.
        target_addr = target.concrete_value
        if target_addr == source + 2:
            return "Not Taken"
        else:
            return "Taken"


def ordered_branches(branches):
    branches = sorted(branches, key=lambda x: x[0])
    return [(hex(addr), truncate_str(cond), taken) for addr, cond, taken in branches]


def ordered_constraints(constraints):
    constraints = sorted(constraints, key=lambda x: x[0])
    return [(hex(addr), truncate_str(cond), str(ctype)) for addr, cond, ctype in constraints]


def get_mnemonic_at_address(proj, address):
    proj.loader.memory.seek(address)
    bytes = proj.loader.memory.read(10)
    if not bytes:
        return ''

    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.detail = True
    instructions = list(md.disasm(bytes, 0))
    if not instructions:
        return ''

    return instructions[0].mnemonic

def truncate_str(s, width=1000):
    placeholder = '[...]'
    s = str(s)

    if not global_config["OutputTruncatedASTs"]:
        return s

    assert(width > len(placeholder) + 20)

    if len(s) > width:
        return s[:width - 20 - len(placeholder)] + placeholder + s[-20:]

    return s


def sorted_set_str(s: set) -> str:
    return "{" + ", ".join(sorted([str(x) for x in s])) + "}"

def merge_dependent_sets(sets: list) -> list:
    """
    Merge a list of sets into a list of independent sets, e.g.:
    [{1, 2}, {3, 4}, {5, 1}] -> [{1, 2, 5}, {3, 4}]
    """
    merged = True
    while merged:
        merged = False
        result = []
        while sets:
            first, *rest = sets
            rest2 = []
            for s in rest:
                if first & s:  # overlap
                    first |= s  # merge
                    merged = True
                else:
                    rest2.append(s)
            sets = rest2
            result.append(first)
        sets = result
    return sets
