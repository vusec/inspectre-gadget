"""
Transformations that are performed on the AST of ANGR's symbolic expressions to
normalize their form and ease analysis.
"""

import claripy
import itertools

from .utils import *
from .logger import *

thel = get_logger("AstTransform")


class ConditionalAst:
    """
    Ast used to split conditional movs.
    """
    def __init__(self, expr, conds) -> None:
        self.expr = expr
        self.conditions = conds

    def __repr__(self) -> str:
        return f"{self.expr}  ({self.conditions})"


def split_if_statements(ast: claripy.BV) -> list[ConditionalAst]:
    """
    Split expressions that contain if-the-else trees in separate asts.
    """

    # Leaf: just return the ast.
    if not isinstance(ast, claripy.ast.base.Base) or ast.concrete:
        return [ConditionalAst(expr=ast, conds=[])]
    if len(ast.args) == 0 or ast.depth == 1:
        return [ConditionalAst(expr=ast, conds=[])]

    # If statement: split ast in two different asts, each with a condition
    # associated to it.
    splitted_asts = []
    if ast.op == "If":
        cond_splitted = split_if_statements(ast.args[0])
        arg1_splitted = split_if_statements(ast.args[1])
        arg2_splitted = split_if_statements(ast.args[2])

        for arg in arg1_splitted:
            for c in cond_splitted:
                new_conds = []
                new_conds.extend(arg.conditions)
                new_conds.extend(c.conditions)
                new_conds.append(c.expr)
                splitted_asts.append(ConditionalAst(expr=remove_spurious_annotations(arg.expr), conds=new_conds))

        for arg in arg2_splitted:
            for c in cond_splitted:
                new_conds = []
                new_conds.extend(arg.conditions)
                new_conds.extend(c.conditions)
                new_conds.append(claripy.Not(c.expr))
                splitted_asts.append(ConditionalAst(expr=remove_spurious_annotations(arg.expr), conds=new_conds))

        return splitted_asts

    # Other operations: cartesian product of arguments.
    splitted_args = [split_if_statements(arg) for arg in ast.args]
    for combination in itertools.product(*splitted_args):
        new_expr = ast
        new_conds = []
        for i in range(0, len(ast.args)):
            if not is_sym_expr(ast.args[i]):
                continue
            new_expr = new_expr.replace(ast.args[i], combination[i].expr)
            new_conds.extend(combination[i].conditions)
        splitted_asts.append(ConditionalAst(expr=new_expr, conds=new_conds))

    return splitted_asts

def remove_spurious_annotations(expr):
    annos = set()
    for v in get_vars(expr):
        annos.update(v.annotations)

    expr = expr.annotate(*annos, remove_annotations=expr.annotations)
    return expr


def extract_summed_vals(ast: claripy.BV):
    """
    Given an addition node, possibly prefixed by a Zero/Sign extension, returns
    the complete list of addenda (including nested adds).
    """

    # If this AST does not contain an operation, return the expression itself.
    if not isinstance(ast, claripy.ast.base.Base) or ast.concrete or ast.depth == 1:
        return [ast]

    # If it's a sign/zero extension, drill through it.
    if ast.op == "ZeroExt" or ast.op == "SignExt":
        return [claripy.ZeroExt(ast.size() - x.size(), x) for x in extract_summed_vals(ast.args[1])]

    sum_ops = ["__add__",
               "__radd__",
               "__sub__",
               "__rsub__"]

    summed_vals = []

    # If this expression is an addition, recursively gather the addenda.
    if ast.op in sum_ops:
        for arg in ast.args:
            summed_vals.extend(extract_summed_vals(arg))

    if len(summed_vals) > 0:
        return summed_vals

    # In any other case, do nothing.
    return [ast]

def generate_addition(addenda):
    """
    Add together all the addenda in a single expression.
    """
    if len(addenda) == 0:
        return None
    if len(addenda) == 1:
        return addenda[0]

    expr = addenda[0]
    for a in addenda[1:]:
        expr += a

    return expr


def sign_ext_to_sum(ast: claripy.BV,):
    """
    Transform SignExt(A, n) into (A  + (if A[last] == 0 then 0 else 0xfffff) << n)
    """

    # If this AST is a constant, do nothing.
    if not isinstance(ast, claripy.ast.BV) or ast.concrete or is_sym_var(ast):
        return ast

    # If this node is a concat, transform it into a shift.
    if ast.op == "SignExt":
        extend_size = ast.args[0]
        base = sign_ext_to_sum(ast.args[1])
        base_size = base.size()
        sign_bit = base[base_size -1]

        upper_expr = claripy.If(sign_bit == 0,
                                claripy.BVV(0, base_size+extend_size),
                                claripy.BVV((2**extend_size)-1, base_size+extend_size))

        return base.zero_extend(extend_size) + (upper_expr << base_size)


    # Visit arguments.
    new_expr = ast
    for arg in ast.args:
        if not isinstance(arg, claripy.ast.base.BV) or arg.concrete or is_sym_var(arg):
            continue
        new_expr = new_expr.replace(arg,sign_ext_to_sum(arg))

    return new_expr


def match_sign_ext(ast: claripy.BV):
    """
    Transform
        SYM .. a[7:7] .. a[7:7] .. a[7:7] .. a[7:7] .. a
    into
        SYM .. (if a[7:7] == 0 then 0#4 else 0xf) .. a
    """

    # If this AST is a constant, do nothing.
    if not isinstance(ast, claripy.ast.base.BV) or ast.concrete or is_sym_var(ast):
        return ast

    # If this node is a concat, check if it's a sign extension.
    if ast.op == "Concat":

        sign_sym = None
        sign_ext_size = 0
        new_args = []

        for i in range(len(ast.args) + 1):

            # Recursively check args.
            if i < len(ast.args):
                arg = match_sign_ext(ast.args[i])
            else:
                arg = None

            # First symbol: save.
            if sign_sym == None:
                sign_sym = arg
            # Symbol equal to previous one: add 1 to length.
            elif is_sym_expr(arg) and arg.size() == 1 and arg.structurally_match(sign_sym):
                sign_ext_size += 1
            # Symbol different to previous one: push new arg.
            else:
                if sign_ext_size == 0:
                    new_args.append(sign_sym)
                else:
                    new_args.append(claripy.If(sign_sym == 0,
                            claripy.BVV(0, sign_ext_size+1),
                            claripy.BVV((2**sign_ext_size+1)-1, sign_ext_size+1)))
                sign_ext_size = 0
                sign_sym = arg

        return claripy.Concat(*new_args)

    # Recursively check args.
    new_expr = ast
    for arg in ast.args:
        if not isinstance(arg, claripy.ast.base.BV) or arg.concrete or is_sym_var(arg):
            continue
        new_expr = new_expr.replace(arg, match_sign_ext(arg))

    return new_expr
