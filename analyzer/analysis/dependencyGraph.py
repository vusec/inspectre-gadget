"""DependencyGraph

The dependency graph is used to calculate sets of symbolic variables that
should be considered dependent from each other, i.e. they are tied together
by either aliases or constraints that involve each other.
"""

import claripy
import sys
import random

# autopep8: off
from ..scanner.annotations import *
from ..shared.logger import *
# autopep8: on

l = get_logger("DepGraph")

def is_controlled(var):
    if not is_sym_var(var):
        return False

    load_anno = get_load_annotation(var)
    uncontrolled_anno = get_uncontrolled_annotation(var)

    if uncontrolled_anno != None:
        return False

    if load_anno != None and load_anno.controlled == False:
        return False

    return True

def is_expr_controlled(expr):
    if not is_sym_expr(expr):
        return False

    return any(is_controlled(x) for x in get_vars(expr))

def is_uncontrolled(var):
    if not is_sym_var(var):
        return False

    load_anno = get_load_annotation(var)
    uncontrolled_anno = get_uncontrolled_annotation(var)

    if uncontrolled_anno != None:
        return True

    if load_anno != None and load_anno.controlled == False:
        return True

    return False

def is_expr_uncontrolled(expr):
    if not is_sym_expr(expr):
        return False

    if len(get_vars(expr)) == 0:
        return False

    return any(is_uncontrolled(x) for x in get_vars(expr))

class DepNode:
    """
    Represents a symbolic expression and its dependencies.
    """
    aliases: set[claripy.BV]
    constraints: set[claripy.BV]
    syms: set[claripy.BV]
    controlled: bool

    def __init__(self, syms, controlled):
        self.syms = set(syms)
        self.aliases = set()
        self.constraints = set()
        self.controlled = controlled

    def __repr__(self) -> str:
        return  f"""
            [
                syms:{self.syms}
                aliases:{self.aliases}
                constraints:{self.constraints}
            ]
                """

    def dependencies(self, include_constraints):
        deps = self.syms.union(self.aliases)
        if include_constraints:
            deps.update(self.constraints)

        return deps

    def is_independent_from(self, other_nodes, include_constraints):
        """
        Check if there is at least one symbol in this node that does not depend
        on a set of other nodes, i.e.:
        - is not part of the other nodes symbols
        - is not part of the other nodes aliases
        - (optionally) is not part of the other nodes constraints
        """
        deps = set()
        for n in other_nodes:
            for d in n.dependencies(include_constraints):
                deps.add(d)

        diff = set.difference(self.syms, deps)
        return len(diff) > 0

class ExprNode(DepNode):
    """
    Represents the dependencies of a complex symbolic expression.
    """
    expr: claripy.BV

    def __init__(self, expr):
        super().__init__(get_vars(expr), is_expr_controlled(expr))
        self.expr = expr

class SymNode(DepNode):
    """
    Represents the dependencies of a single symbolic variable.
    """
    def __init__(self, sym):
        super().__init__([sym], is_controlled(sym))


class LoadNode(SymNode):
    """
    Represents the dependencies of a symbol that was materialized from a load.
    """
    addr: claripy.BV

    def __init__(self, val, addr):
        super().__init__(val)
        self.addr = addr

class RegNode(SymNode):
    """
    Represents a symbolic register/stack location.
    """
    def __init__(self, sym):
        super().__init__(sym)

def is_addr_controllable(tree, sym: claripy.BV, fixed_syms: list[claripy.BV], check_constraints: bool):
    # l.info(f"Checking address: {sym}")
    node = tree.get_node(sym)
    assert(isinstance(node, SymNode))

    if not node.controlled:
        return False

    if isinstance(node, LoadNode) and is_sym_expr(node.addr):
        return tree.is_independently_controllable(node.addr, fixed_syms, check_constraints, True)
    else:
        return True

def is_addr_independent(tree, expr1: claripy.BV, expr2: claripy.BV, check_constraints: bool):
    # l.info(f"Checking address: {sym}")
    node = tree.get_node(expr1)
    assert(isinstance(node, SymNode))

    if isinstance(node, LoadNode) and is_sym_expr(node.addr):
        return tree.is_independent(node.addr, expr2, check_constraints, True)
    else:
        return tree.is_independent(expr1, expr2, check_constraints, False)


class DepGraph:
    """
    Graph of dependencies between symbolic expressions.
    """
    def __init__(self):
        self.sym_nodes = dict()
        self.expr_nodes = dict()

    def dump(self):
        print("====== DepGraph ======")
        print("=== Syms")
        print(self.sym_nodes)
        print("=== Expr")
        print(self.expr_nodes)
        print("====================")

    def __repr__(self) -> str:
        return  f"""
        ====== DepGraph ======
        === Syms
        {self.sym_nodes}
        === Expr
        {self.expr_nodes}
        ====================
                """

    def get_node(self, expr):
        """
        Return the node associated to a given symbolic expression, if any.
        """
        if not is_sym_expr(expr):
            return None

        if expr.depth == 1:
            return self.sym_nodes[expr]
        else:
            return self.expr_nodes[expr]

    def add_nodes(self, expr):
        """
        Add a node to represent the dependencies of expr. If expr is a complex
        expression, we also add one node for each of its base symbols.
        """
        # Not a symbolic expression.
        if not is_sym_expr(expr):
            return

        # Already added.
        if expr in self.sym_nodes or expr in self.expr_nodes:
            return

        # Symbolic variable.
        if expr.depth == 1:
            attacker_annos = [a for a in get_annotations(expr) if isinstance(a, AttackerAnnotation)]
            load_annos = [a for a in get_annotations(expr) if isinstance(a, LoadAnnotation)]
            uncontrolled_annos = [a for a in get_annotations(expr) if isinstance(a, UncontrolledAnnotation)]

            if len(attacker_annos) + len(load_annos) + len(uncontrolled_annos) == 0:
                print("TODO: something wrong is happening")
                anno = UncontrolledAnnotation(f"unknown_{random.randint(0, 256)}")
                uncontrolled_annos = [anno]
                expr.annotate(anno)
            else:
                assert(len(attacker_annos) + len(load_annos) + len(uncontrolled_annos) == 1)

            if len(attacker_annos) > 0 or len(uncontrolled_annos) > 0:
                self.sym_nodes[expr] = RegNode(expr)
            elif len(load_annos) > 0:
                self.add_nodes(load_annos[0].read_address_ast)
                self.sym_nodes[expr] = LoadNode(expr, load_annos[0].read_address_ast)

        # Symbolic expression.
        else:
            for v in get_vars(expr):
                self.add_nodes(v)
            self.expr_nodes[expr] = ExprNode(expr)

    def add_aliases(self, aliases):
        """
        Add equality constraints like "x == y". X and Y will be considered
        synonyms when calculating dependencies, e.g. all the dependencies of
        X are considered also dependencies for Y.
        """
        for a in aliases:
            alias_set = get_vars(a)
            for sym in alias_set:
                assert(is_sym_var(sym))
                self.add_nodes(sym)
                self.sym_nodes[sym].aliases.update(alias_set)

    def add_constraints(self, constraints):
        """
        Add constraints like X > Y.
        """
        for c in constraints:
            involved_vars = get_vars(c)
            for sym in involved_vars:
                self.add_nodes(sym)
                self.sym_nodes[sym].constraints.update(involved_vars)

    def resolve_dependencies(self):
        """
        Calculate the transitive closure of alias sets and constraint sets for
        each symbol.
        """
        visit_stack = set(self.sym_nodes.keys())
        visited = set()

        # Calculate transitive closure for symbols.
        while len(visit_stack) > 0:
            to_check = visit_stack.pop()
            visited.add(to_check)

            union_of_aliases = set()
            # Unite all alias_set of symbols that are aliasing together.
            for a in self.sym_nodes[to_check].aliases:
                union_of_aliases.update(self.sym_nodes[a].aliases)
            # Update the alias_set of all aliasing symbols.
            for a in union_of_aliases:
                self.sym_nodes[a].aliases = union_of_aliases

            visit_stack.update(set.difference(union_of_aliases, visited))

            union_of_constraints = set()
            # For the nodes that are involved in a constraint with this symbol,
            # gather all of their aliases and constraints.
            for a in self.sym_nodes[to_check].constraints:
                union_of_constraints.update(self.sym_nodes[a].constraints)
                union_of_constraints.update(self.sym_nodes[a].aliases)
            # Update the constraint set of all symbols involved in a constraint
            # with this symbol.
            for a in union_of_constraints:
                self.sym_nodes[a].constraints = union_of_constraints

            visit_stack.update(set.difference(union_of_constraints, visited))

        # Calculate aliases and constraints for complex expressions.
        for e in self.expr_nodes.values():
            for s in e.syms:
                e.aliases.update(self.sym_nodes[s].aliases)
                e.constraints.update(self.sym_nodes[s].constraints)

    def get_all_deps(self, exprs, include_constraints: bool):
        deps = set()
        for e in exprs:
            if not is_sym_expr(e):
                continue
            n = self.get_node(e)
            assert(n)
            deps.update(n.dependencies(include_constraints))

        return deps


    def is_independently_controllable(self, expr: claripy.BV, fixed_syms: list[claripy.BV], check_constraints: bool, check_addr: bool):
        """
        Check if expr contains at least one symbol that is not influenced by any
        of the symbols in fixed_syms.
        If include_constraints is true, two symbols that appear together in any
        of the tree's constraints will be considered dependent from each other.
        """
        if not is_expr_controlled(expr):
            return False

        # l.info(f"Checking if {expr} can be controlled independently from {fixed_syms}")
        expr_syms = set(get_vars(expr))
        deps_to_check = set(self.get_all_deps(fixed_syms, check_constraints))

        # Get all symbols in the expr that are not among the symbols, aliases or
        # constraints of any of the symbols of fixed_sym.
        sym_diff = set.difference(expr_syms, deps_to_check)
        diff = set([elem for elem in filter(lambda x: is_expr_controlled(x), sym_diff)])

        # If there's none left, expr completely depends on fixed_syms.
        if len(diff) == 0:
            return False


        # If we are not checking load addresses, we're done.
        if not check_addr:
            return True

        # Else, check each of the remaining symbols recursively and exclude those
        # that were loaded from an address that completely depends on fixed_syms.
        return any([is_addr_controllable(self, x, fixed_syms, check_constraints) for x in diff])


    def is_independent(self, expr1: claripy.BV, expr2: claripy.BV, check_constraints: bool, check_addr: bool):
        """
        Check if expr1 and expr2 have any symbol in common, accounting for aliases
        and (optionally) constraints.
        """
        expr1_syms = set(get_vars(expr1))
        expr2_syms = set(get_vars(expr2))
        dep1 = set(self.get_all_deps(expr1_syms, check_constraints))
        dep2 = set(self.get_all_deps(expr2_syms, check_constraints))

        intersect = set.intersection(dep1, dep2)

        if len(intersect) > 0:
            return False

        # If we are not checking load addresses, we're done.
        if not check_addr:
            return True

        # Else, recursively check the address expression, following loads.
        return all([is_addr_independent(self, x, expr2, check_constraints) for x in expr1_syms])
