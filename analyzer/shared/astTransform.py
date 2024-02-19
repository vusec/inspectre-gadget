"""
Transformations that are performed on the AST of ANGR's symbolic expressions to
normalize their form and ease analysis.
"""

import claripy
import itertools
from enum import Enum
from itertools import chain

from .utils import *
from .logger import *

l = get_logger("AstTransform")

class ConditionType(Enum):
    """
    Track which instruction is associated to a given condition.
    """
    CMOVE = 0,
    SIGN_EXT = 1,
    UNKNOWN = 2

class SignExtAnnotation(claripy.Annotation):
    """
    Signals that a symbolic expression comes from a SignExt.
    """
    def __init__(self, addr):
        self.addr = addr

    @property
    def eliminatable(self):
        return True

    @property
    def relocatable(self):
        return False

    def copy(self):
        return SignExtAnnotation(self.addr)

    def __str__(self):
        return f"SignExtAnnotation@{hex(self.addr)}"

    def __repr__(self):
        return f"SignExtAnnotation@{hex(self.addr)}"

def getSignExtAnnotation(ast: claripy.BV):
    for a in ast.annotations:
        if isinstance(a, SignExtAnnotation):
            return a

    return None


class CmoveAnnotation(claripy.Annotation):
    """
    Signals that a symbolic expression comes from a CMOVE-like instruction.
    """

    def __init__(self, addr):
        self.addr = addr

    @property
    def eliminatable(self):
        return True

    @property
    def relocatable(self):
        return False

    def copy(self):
        return CmoveAnnotation(self.addr)

    def __str__(self):
        return f"CmoveAnnotation@{hex(self.addr)}"

    def __repr__(self):
        return f"CmoveAnnotation@{hex(self.addr)}"

def getCmoveAnnotation(ast: claripy.BV):
    for a in ast.annotations:
        if isinstance(a, CmoveAnnotation):
            return a

    return None


class ConditionalAst:
    """
    Ast with a set of constraints associated to it.
    """
    def __init__(self, expr, conds) -> None:
        self.expr = expr
        self.conditions = set(conds)

    def __repr__(self) -> str:
        return f"{self.expr}  ({self.conditions})"


def split_if_statements(ast: claripy.BV, ast_addr) -> list[ConditionalAst]:
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
        anno = getSignExtAnnotation(ast)
        if  anno != None:
            cond_type = ConditionType.SIGN_EXT
            addr = anno.addr

        else:
            anno = getCmoveAnnotation(ast)
            if anno != None:
                cond_type = ConditionType.CMOVE
                addr = anno.addr
            else:
                cond_type = ConditionType.UNKNOWN
                addr = ast_addr

        cond_splitted = split_if_statements(ast.args[0], addr)
        arg1_splitted = split_if_statements(ast.args[1], addr)
        arg2_splitted = split_if_statements(ast.args[2], addr)

        for arg in arg1_splitted:
            for c in cond_splitted:
                new_conds = []
                new_conds.extend(arg.conditions)
                new_conds.extend(c.conditions)
                new_conds.append((addr, c.expr,cond_type))

                splitted_asts.append(ConditionalAst(expr=arg.expr, conds=new_conds))

        for arg in arg2_splitted:
            for c in cond_splitted:
                new_conds = []
                new_conds.extend(arg.conditions)
                new_conds.extend(c.conditions)
                new_conds.append((addr, claripy.Not(c.expr),cond_type))
                splitted_asts.append(ConditionalAst(expr=arg.expr, conds=new_conds))

        return splitted_asts

    # Other operations: cartesian product of arguments.
    splitted_args = [split_if_statements(arg, ast_addr) for arg in ast.args]
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


def sign_ext_to_sum(ast: claripy.BV, addr):
    """
    Transform SignExt(A, n) into (if A[last] == 0 then 0..A else 0xfffff..A)
    """

    # If this AST is a constant, do nothing.
    if not isinstance(ast, claripy.ast.BV) or ast.concrete or is_sym_var(ast):
        return ast

    # If this node is a signext, transform it.
    if ast.op == "SignExt":
        extend_size = ast.args[0]
        base = sign_ext_to_sum(ast.args[1], addr)
        base_size = base.size()
        sign_bit = base[base_size -1]

        upper_expr = claripy.If(sign_bit == 0,
                                claripy.Concat(claripy.BVV(0, extend_size), base),
                                claripy.Concat(claripy.BVV((2**extend_size)-1, extend_size), base))
        upper_expr = upper_expr.annotate(SignExtAnnotation(addr))

        return upper_expr


    # Visit arguments.
    new_expr = ast
    for arg in ast.args:
        if not isinstance(arg, claripy.ast.base.BV) or arg.concrete or is_sym_var(arg):
            continue
        new_expr = new_expr.replace(arg,sign_ext_to_sum(arg, addr))

    return new_expr


def match_sign_ext(ast: claripy.BV, addr):
    """
    Transform
        SYM .. a[7:7] .. a[7:7] .. a[7:7] .. a[7:7] .. a
    into
        SYM .. (if a[7:7] == 0 then 0.. a else 0xf.. a)
    """

    # If this AST is a constant, do nothing.
    if not isinstance(ast, claripy.ast.base.BV) or ast.concrete or is_sym_var(ast):
        return ast

    # If this node is a concat, check if it's a sign extension.
    if ast.op == "Concat":

        sign_sym = ast.args[0]
        sign_ext_size = 0
        new_args = []

        for i in range(1,len(ast.args)):
            # Recursively check args.
            arg = match_sign_ext(ast.args[i], addr)

            # Symbol equal to previous one: add 1 to length.
            if is_sym_expr(arg) and arg.op == "Extract" and arg.size() == 1 and arg.structurally_match(sign_sym):
                sign_ext_size += 1
            # Symbol different to previous one: push new arg.
            else:
                if sign_sym == None:
                    sign_sym = arg
                elif sign_ext_size == 0:
                    new_args.append(sign_sym)
                    sign_sym = arg
                elif is_sym_expr(arg) and arg.structurally_match(sign_sym.args[2]):
                        if_expr = claripy.If(sign_sym == 0,
                                claripy.Concat(claripy.BVV(0, sign_ext_size+1), arg),
                                claripy.Concat(claripy.BVV((2**(sign_ext_size+1))-1, sign_ext_size+1), arg))
                        if_expr = if_expr.annotate(SignExtAnnotation(addr))
                        new_args.append(if_expr)

                        sign_sym = None
                        sign_ext_size = 0
                else:
                    for i in range(sign_ext_size + 1):
                        new_args.append(sign_sym)

                    sign_sym = arg
                    sign_ext_size = 0

        if sign_sym != None:
            for i in range(sign_ext_size + 1):
                new_args.append(sign_sym)


        new_expr = claripy.Concat(*new_args)

        return new_expr

    # Recursively check args.
    new_expr = ast
    for arg in ast.args:
        if not isinstance(arg, claripy.ast.base.BV) or arg.concrete or is_sym_var(arg):
            continue

        new_expr = new_expr.replace(arg, match_sign_ext(arg, addr))

    return new_expr


def split_conditions(expr: claripy.BV, simplify: bool, addr) -> list[ConditionalAst]:
    """
    Split any AST that contains CMOVEs, SignExtensions and If-Then-Else
    statements into separate ASTs with an associated condition.
    """
    # Turn SExt-like Concat expressions into if-then-else.
    new_expr = match_sign_ext(expr, addr)
    # Turn SExt into an if-then-else sum.
    new_expr = sign_ext_to_sum(new_expr, addr)

    # Optionally simplify the expression.
    if simplify:
        new_expr = simplify_conservative(new_expr)

    # Split if-then-else statements into separate ConditionalASTs.
    return split_if_statements(new_expr, addr)


def simplify_conservative(e: claripy.T) -> claripy.T:
    """
    Simplify the expression and, in contrast to claripy.simplify, discard
    annotations from the expression that are simplified away.

    For example, assume <BV64 attacker + ( 0x0 & secret)>, it will be
    simplified to <BV64 attacker > with only the attacker annotation attached
    to it. Claripy would keep both attacker and the secret annotation.
    """

    # Code below is copied from claripy/ast/base.py

    if isinstance(e, claripy.ast.Base) and e.op in claripy.operations.leaf_operations:
        return e

    s = e._first_backend("simplify")
    if s is None:
        return e
    else:
        # Copy some parameters (that should really go to the Annotation backend)
        s._uninitialized = e.uninitialized
        s._uc_alloc_depth = e._uc_alloc_depth
        s._simplified = claripy.ast.Base.FULL_SIMPLIFY

        # dealing with annotations
        if e.annotations:
            ast_args = tuple(a for a in e.args if isinstance(a, claripy.ast.Base))
            annotations = tuple(
                set(chain(chain.from_iterable(a._relocatable_annotations for a in ast_args), tuple(a for a in e.annotations)))
            )
            if annotations != s.annotations:
                l.warning(f"SafeSimplify: Experimental feature executed, annotations removed by simplification operation. Old: {e} {annotations} New: {s} {s.annotations} ")

                # Claripy does instead:
                # s = s.remove_annotations(s.annotations)
                # s = s.annotate(*annotations)

        return s

