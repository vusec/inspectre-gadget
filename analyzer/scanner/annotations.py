# Annotations are effectively taint labels that we attach to symbolic values
# to track which expressions contain an attacker-controlled register or a secret.

import claripy
import sys

# autopep8: off
from ..shared.utils import *
from ..shared.transmission import Requirements, ControlType
# autopep8: on


class LoadAnnotation(claripy.Annotation):
    """
    This annotation is attached to any symbol that is created as a result
    of a load (both concrete loads and symbolic loads).
    """
    read_address_ast: claripy.BV
    name: str
    address: int
    requirements: Requirements
    controlled: bool
    depth: int

    def __init__(self, read_address_ast, name, address, controlled):
        self.read_address_ast = read_address_ast
        self.name = name
        self.address = address
        self.controlled = controlled

        self.requirements = Requirements()
        self.depth = 0

        if is_sym_expr(read_address_ast):
            self.requirements.mem.add(read_address_ast)
            max_depth = 0

            for v in get_vars(read_address_ast):
                load_anno = None
                for a in v.annotations:
                    if isinstance(a, LoadAnnotation):
                        load_anno = a

                if load_anno == None:
                    self.requirements.regs.add(v)
                else:
                    self.requirements.merge(load_anno.requirements)
                    max_depth = max(max_depth, load_anno.depth)

            self.depth = max_depth + 1
        else:
            self.requirements.const_mem.add(read_address_ast)

    @property
    def eliminatable(self):
        return True

    @property
    def relocatable(self):
        return True

    def __str__(self):
        return f"{self.name}@{hex(self.address)}"

    def __repr__(self):
        return f"{self.name}@{hex(self.address)}"

    def to_str(self, custom_name=None):
        if custom_name:
            return f"{custom_name}@{hex(self.address)}"
        else:
            return self.__repr__()


class SecretAnnotation(LoadAnnotation):
    """
    This symbol comes from loading an attacker-controlled address.
    """
    def __init__(self, read_address_ast, address, controlled):
        super().__init__(read_address_ast, "Secret", address, controlled)

    def copy(self):
        return SecretAnnotation(self.read_address_ast, self.address, self.controlled)


class TransmissionAnnotation(LoadAnnotation):
    """
    This symbol comes from loading/storing/calling a secret-dependent address.
    """
    def __init__(self, read_address_ast, address, controlled):
        super().__init__(read_address_ast, "Transmission", address, controlled)

    def copy(self):
        return TransmissionAnnotation(self.read_address_ast, self.address, self.controlled)


class UncontrolledLoadAnnotation(LoadAnnotation):
    """
    This symbol comes from loading a uncontrolled address.
    """
    def __init__(self, read_address_ast, address):
        super().__init__(read_address_ast, "UncontrolledLoad", address, controlled=False)

    def copy(self):
        return UncontrolledLoadAnnotation(self.read_address_ast, self.address)


class AttackerAnnotation(claripy.Annotation):
    register: str

    def __init__(self, register):
        self.register = register

    @property
    def eliminatable(self):
        return True

    @property
    def relocatable(self):
        return True

    def __str__(self):
        return f"Attacker@{self.register}"

    def __repr__(self):
        return f"Attacker@{self.register}"

    def copy(self):
        return AttackerAnnotation(self.register)

class UncontrolledAnnotation(claripy.Annotation):
    """
    Some memory might be symbolic but already known to be uncontrolled.
    """
    register: str

    def __init__(self, register):
        self.register = register

    @property
    def eliminatable(self):
        return True

    @property
    def relocatable(self):
        return True

    def __str__(self):
        return f"Uncontrolled@{self.register}"

    def __repr__(self):
        return f"Uncontrolled@{self.register}"

    def copy(self):
        return UncontrolledAnnotation(self.register)


def propagate_annotations(ast: claripy.BV, address):
    """
    Given the AST of a symbolic address, return the annotation of the loaded value.
    This basically implements how taint evolves through memory operations.
    """
    # For constant addresses, we might be able to massage the content.
    if not ast.symbolic:
        return UncontrolledLoadAnnotation(ast, address)

    is_attack = False
    is_secret = False
    is_transmission = False

    can_be_controlled = False

    for anno in get_annotations(ast):
        if isinstance(anno, AttackerAnnotation):
            is_attack = True
            can_be_controlled = True
        if isinstance(anno, SecretAnnotation):
            is_secret = True
            if anno.controlled:
                can_be_controlled = True
        if isinstance(anno, TransmissionAnnotation):
            is_transmission = True
            if anno.controlled:
                can_be_controlled = True


    if is_secret or is_transmission:
        return TransmissionAnnotation(ast, address, controlled=can_be_controlled)
    elif is_attack:
        return SecretAnnotation(ast, address, controlled=True)
    else:
        """ In some cases a load from an uncontrolled value could still be
        seen as a secret, but for now this is out of scope """
        return UncontrolledLoadAnnotation(ast, address)


def contains_secret(ast: claripy.BV):
    if not is_sym_expr(ast):
        return False

    for anno in get_annotations(ast):
        if isinstance(anno, SecretAnnotation) or isinstance(anno, TransmissionAnnotation):
            return True

    return False


def get_load_annotation(x):
    if is_sym_var(x):
        for anno in get_annotations(x):
            if isinstance(anno, LoadAnnotation):
                return anno
    return None

def get_load_depth(x):
    max_depth = 0
    if is_sym_expr(x):
        for anno in get_annotations(x):
            if isinstance(anno, LoadAnnotation):
                max_depth = max(max_depth, anno.depth)


    return max_depth


def get_attacker_annotation(x):
    if is_sym_var(x):
        for anno in get_annotations(x):
            if isinstance(anno, AttackerAnnotation):
                return anno
    return None

def get_uncontrolled_annotation(x):
    if is_sym_var(x):
        for anno in get_annotations(x):
            if isinstance(anno, UncontrolledAnnotation):
                return anno
    return None

def get_dep_set(expr):
    depset = set()

    for v in get_vars(expr):
        depset.add(v)
        anno = get_load_annotation(v)
        if anno:
            depset.update(anno.dep_set)

    return depset

def is_attacker_controlled(ast):
    for anno in get_annotations(ast):
        if isinstance(anno, AttackerAnnotation) | isinstance(anno, SecretAnnotation) | isinstance(anno, TransmissionAnnotation):
            return True
    return False
