"""
This module is used to model symbolic memory while avoiding concretization.
Basically, it is used to calculate aliases and overlaps between symbolic
addresses.
"""

from enum import Enum

import angr
import claripy
import sys

# autopep8: off
from ..shared.logger import *
from .annotations import *
# autopep8: on

l = get_logger("MemHooks")


class MemOpType(Enum):
    LOAD = 1,
    STORE = 2


class MemOp:
    """
    Symbolic memory operation (load or store).
    """
    pc: int
    addr: claripy.BV
    val: claripy.BV
    size: int
    id: int
    op_type: MemOpType

    def __init__(self, pc: int, addr: claripy.BV, val: claripy.BV, size: int, id: int, op_type: MemOpType):
        self.pc = pc
        self.addr = addr
        self.val = val
        self.size = size
        self.id = id
        self.op_type = op_type

    def __repr__(self) -> str:
        return f"""
        pc : {self.pc}
        addr : {self.addr}
        val : {self.val}
        size : {self.size}
        id : {self.id}
        op_type : {self.op_type}
        """


class RangedSymbol:
    """
    Represents a slice of a symbolic variable.
    """
    sym: claripy.BV
    min: int
    max: int

    def __init__(self, sym, min, max):
        self.sym = sym
        self.min = min
        self.max = max

    def to_BV(self) -> claripy.BV:
        return self.sym[self.max:self.min]

    def __repr__(self) -> str:
        return f"{self.sym}[{self.min}:{self.max}]"


class MemoryAlias:
    """
    Represents an alias between two symbolic variables.
    """
    val1: RangedSymbol
    val2: RangedSymbol

    def __init__(self, val1: RangedSymbol, val2: RangedSymbol):
        self.val1 = val1
        self.val2 = val2

    def get_involved_vars(self):
        return [self.val1.sym, self.val2.sym]

    def __repr__(self) -> str:
        return f"{self.val1} == {self.val2}"

    def is_symbolic(self):
        return is_sym_expr(self.val1.sym) or is_sym_expr(self.val2.sym)

    def to_BV(self):
        return self.val1.to_BV() == self.val2.to_BV()


def overlaps_with(load1: MemOp, load2: MemOp, state: angr.SimState) -> bool:
    """
    Check if the memory region accessed by load1 overlaps the region of
    load2. Note that, since we are dealing with symbolic loads, the result
    is true only if the two symbolic addresses _must_ overlap, i.e. there
    is no possible solution where they don't.
    """
    addr1 = load1.addr
    sz1 = load1.size
    addr2 = load2.addr
    sz2 = load2.size

    # If this condition is satisfiable, there is at least one solution for
    # addr1 and addr2 in which they don't overlap.
    no_overlap = claripy.Or(addr2 >= addr1+sz1, addr1 >= addr2+sz2)

    # In the opposite case (not satisfiable), there is _no_ solution in which
    # they are separate.
    return not state.solver.satisfiable(extra_constraints=[no_overlap])


def get_overlap(load1: MemOp, load2: MemOp, state: angr.SimState):
    """
    Args: two overlapping symbolic memory operations.
    Returns: [memop1, memop2, offset] such that memop1.addr + offset == memop2.
    Note that we don't handle the case in which the two can overlap
    in more than one way.
    """

    # Consider only these offsets for possible overlaps.
    for i in [0, 1, 2, 4]:
        if not state.solver.satisfiable(extra_constraints=[load1.addr != load2.addr+i]):
            l.error("Overlap found: {} ~~ {} (offset {})".format(
                load1.addr, load2.addr, i))
            return load2, load1, i

        if not state.solver.satisfiable(extra_constraints=[load1.addr+i != load2.addr]):
            l.error("Overlap found: {} (offset {}) ~~ {}".format(
                load1.addr, i, load2.addr))
            return load1, load2, i

    return None, None, 0


def is_load_obj(item):
    return


def get_previous_loads(state: angr.SimState):
    return filter(lambda x: isinstance(x, MemOp) and x.op_type == MemOpType.LOAD, state.globals.values())


def get_aliases(state: angr.SimState) -> MemoryAlias:
    return filter(lambda x: isinstance(x, MemoryAlias), state.globals.values())


def get_aliasing_loads(this: MemOp, state: angr.SimState, alias_store) -> list[MemoryAlias]:
    """
    Check if a load aliases with any other previous load.
    """
    aliasing_loads = []
    prev_loads = get_previous_loads(state)

    if alias_store:
        prev_loads = filter(lambda p: p.id >= alias_store.id, prev_loads)

    for prev in prev_loads:
        if overlaps_with(this, prev, state):
            memop1, memop2, off = get_overlap(this, prev, state)

            if memop1 == None:
                # TODO: Handle this properly.
                l.error(
                    f"Bailing out: Unhandled aliasing condition between {this.addr} and {prev.addr}")
            else:
                val1 = memop1.val
                val2 = memop2.val
                sz1 = memop1.size
                sz2 = memop2.size

                #     addr1[0]                   addr1[sz1]
                #       |---------------------------|
                #       | <-off->  |   <-overlap->  |
                #                  |----------------------------|
                #               addr2[0]                    addr2[sz2]
                #
                #                  | <-overlap-> |
                #                  |-------------|
                #              addr2[0]       addr2[sz2]
                #

                # Calculate length of overlap.
                overlap = min(sz1 - off, sz2)

                # Calculate overlapping ranges.
                range1 = RangedSymbol(sym=val1, max=(off+overlap)*8-1, min=off*8)
                range2 = RangedSymbol(sym=val2, max=overlap*8-1, min=0)

                memory_alias = MemoryAlias(range1, range2)

                if claripy.is_true(MemoryAlias(range1, range2).to_BV()):
                    # Alias between the same value, thus always true
                    # We can skip
                    continue

                # Return this overlap.
                aliasing_loads.append(memory_alias)
        # else:
            # l.info("No overlap")
            # TODO: force them to never alias in the opposite case?
            # state.solver.add(prev.addr != cur.addr)

    return aliasing_loads

def get_previous_stores(state: angr.SimState):
    return filter(lambda x: (isinstance(x, MemOp) and x.op_type == MemOpType.STORE), state.globals.values())

def get_aliasing_store(load_addr: claripy.BV, load_size: int, state: angr.SimState):
    """
    Return the latest store that aliases with the given load and its value.
    """
    store = None

    # Get newest store that aliases with this address.
    for s in get_previous_stores(state):
        if not state.solver.satisfiable(extra_constraints=[load_addr != s.addr]):
            if not store or store.id < s.id:
                store = s

    # Return the value of the aliasing store.
    if store:
        returned_store = store
        returned_sym = store.val

        # Account for size mismatch.
        if load_size < store.size:
            returned_sym = store.val[load_size*8-1:0]

        if load_size > store.size:
            # TODO: What to do if the load size is greater than the store size?
            upper_bits = claripy.BVS(name=f"mem@[({load_addr}) + {store.size}]",
                                     size=(load_size - store.size)*8,
                                     annotations=(UncontrolledAnnotation(f'mem@[({load_addr}) + {store.size}]'),))
            returned_sym = claripy.Concat(upper_bits, store.val)

        return returned_store, returned_sym

    return None, None
