import claripy
import itertools
import traceback

def is_sym_expr(x) -> bool:
    return isinstance(x, claripy.ast.base.Base) and x.symbolic

def is_sym_var(x) -> bool:
    return is_sym_expr(x) and x.depth == 1

def get_vars(expr) -> set[claripy.BV]:
    if not is_sym_expr(expr):
        return []

    return set([leaf for leaf in expr.leaf_asts() if is_sym_expr(leaf)])

def get_x86_indirect_thunks(proj):
    symbol_names = {"__x86_indirect_thunk_array" : "rax",
                    "__x86_indirect_thunk_r10" : "r10",
                    "__x86_indirect_thunk_r11" : "r11",
                    "__x86_indirect_thunk_r12" : "r12",
                    "__x86_indirect_thunk_r13" : "r13",
                    "__x86_indirect_thunk_r14" : "r14",
                    "__x86_indirect_thunk_r15" : "r15",
                    "__x86_indirect_thunk_r8" : "r8",
                    "__x86_indirect_thunk_r9" : "r9",
                    "__x86_indirect_thunk_rax" : "rax",
                    "__x86_indirect_thunk_rbp" : "rbp",
                    "__x86_indirect_thunk_rbx" : "rbx",
                    "__x86_indirect_thunk_rcx" : "rcx",
                    "__x86_indirect_thunk_rdi" : "rdi",
                    "__x86_indirect_thunk_rdx" : "rdx",
                    "__x86_indirect_thunk_rsi" : "rsi",
                    }
    ind_calls = {}

    for symbol, reg in symbol_names.items():
        addr = proj.loader.find_symbol(symbol)
        if addr:
            ind_calls[addr.rebased_addr] = reg

    return ind_calls

def get_x86_registers():
    return  ["rax", "rbx", "rcx", "rdx", "rsi",
             "rdi", "rbp", "rsp", "r8" , "r9",
             "r10", "r11", "r12", "r13", "r14", "r15"]


def report_error(error: Exception, where="dunno", start_addr="dunno"):
    o = open("fail.txt", "a+")
    o.write(f"---------------- [ ERROR ] ----------------\n")
    o.write(f"where: {where}     started at:{start_addr}\n")
    o.write(str(error) + "\n")
    o.write(traceback.format_exc())
    o.write("\n")
    o.close()


def branch_outcomes(history):
    outcomes = []
    for cond, source, target in zip(history.jump_guards, history.jump_sources, history.jump_targets):
        if cond.concrete:
            if cond.is_true():
                outcomes.append("Taken")
            else:
                outcomes.append("Not Taken")
        elif target.symbolic:
            outcomes.append("Indirect JMP")
        else:
            target_addr = target.concrete_value
            if target_addr == source + 2:
                outcomes.append("Not Taken")
            else:
                outcomes.append("Taken")

    return outcomes
