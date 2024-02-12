"""
Range object.
"""

from dataclasses import dataclass
from collections import OrderedDict

import claripy

@dataclass
class Interval():
    min: int
    max: int
    stride : int

    def get_tuple(self):
        return (self.min, self.max, self.stride)

    def __str__(self):
        return f"({hex(self.min)},{hex(self.max)}, {hex(self.stride)})"

    def __repr__(self):
        return f"({hex(self.min)},{hex(self.max)}, {hex(self.stride)})"


class AstRange:
    min : int
    max : int
    window : int
    entropy: int

    isolated : bool

    and_mask : int
    or_mask : int

    values = list

    intervals: list
    exact : bool

    @property
    def stride(self):
        if len(self.intervals) == 1:
            return self.intervals[0].stride
        else:
            # TODO: Handle multiple intervals
            None

    def __init__(self, min, max, ast_size, exact, entropy=None, isolated=False, and_mask=None, or_mask=None, values=[], intervals=[]):
        self.min = min
        self.max = max
        self.__ast_size = ast_size

        if min <= max:
            self.window = max - min
        else:
            assert(ast_size > 0)
            # wrap around range
            # window = 0:max + min:ast_size
            self.window = ((1 << ast_size) - 1) - (min - 1) + max

        self.entropy = entropy
        self.isolated = isolated

        self.and_mask = and_mask
        self.or_mask = or_mask
        if self.or_mask == 0:
            self.or_mask = None

        self.intervals = intervals
        self.values = values

        self.exact = exact

    def to_dict(self):
        return OrderedDict([
            ('min', self.min),
            ('max', self.max),
            ('window', self.window),
            ('stride', 'None' if self.stride == None else self.stride),
            ('and_mask', 'None' if self.and_mask == None else self.and_mask),
            ('or_mask', 'None' if self.or_mask == None else self.or_mask),
            ('exact', self.exact)
        ])

    def short_string(self):

        if self.min == self.max:
            return f"{hex(self.min)}"
        else:
            return f"(min:{hex(self.min)}, max: {hex(self.max)})"


    def to_string(self):

        if self.min == self.max:
            return f"{hex(self.min)}"

        if self.intervals:
            s = ",".join([str(i) for i in self.intervals]) + f" Exact: {self.exact}"
            if self.and_mask != None:
                s += f", and_mask: {hex(self.and_mask)}"
            if self.or_mask:
                s += f", or_mask: {hex(self.or_mask)}"
            return s
        else:
            return ",".join([hex(i) for i in self.values]) + f" Exact: {self.exact}"

    def copy(self):
        return AstRange(min=self.min, max=self.max, ast_size=self.__ast_size,
                        exact=self.exact, entropy=self.entropy,
                        isolated=self.isolated, and_mask=self.and_mask,
                        or_mask=self.or_mask, values=self.values,
                        intervals=self.intervals)

    def __str__(self):

        return self.to_string()

    def __repr__(self):
        return self.to_string()


def range_static(value, isolated):
    interval = Interval(min=value, max=value, stride=1)

    return AstRange(min=value, max=value, ast_size=0, exact=True, entropy=0, isolated=isolated, intervals=[interval])


def range_simple(min, max, ast_size, stride, isolated):
    return AstRange(min=min, max=max, ast_size=ast_size, exact=True, isolated=isolated, intervals=[Interval(min, max, stride)])


def range_from_symbolic_concrete_addition(ast, ast_min, ast_max, sym_ast_min, sym_ast_max, sym_ast_stride, concrete_value):
    isolated_ast_min = sym_ast_min + concrete_value
    isolated_ast_max = sym_ast_max + concrete_value

    # handle overflows
    isolated_ast_min &= (1 << ast.size()) - 1
    isolated_ast_max &= (1 << ast.size()) - 1

    if isolated_ast_min - isolated_ast_max == sym_ast_stride:
        # The 'gap' is the size of the stride, so actually it is not a gap
        # and we do not need a disjoint range
        # We replace the disjoint range with a normal range.
        s = claripy.Solver()
        isolated_ast_min = s.min(ast)
        isolated_ast_max = s.max(ast)

    # incorporate non-isolated min and max, only adjust if they are
    # tighter
    # Note: Conditions hold for both normal and disjoint ranges
    ast_min = ast_min if isolated_ast_min < ast_min else isolated_ast_min
    ast_max = ast_max if isolated_ast_max > ast_max else isolated_ast_max

    return range_simple(ast_min, ast_max, ast.size(), sym_ast_stride, isolated=True)


def get_stride_from_mask(and_mask, or_mask):
    mask = and_mask & ~or_mask

    if mask == 0:
        return 0

    lowest_bit = (mask & -mask).bit_length() - 1

    return 2 ** lowest_bit


def range_complex(min, max, ast_size, exact, entropy, and_mask, or_mask, isolated=False):
    stride = get_stride_from_mask(and_mask, or_mask)

    highest_bit = max.bit_length()
    lowest_bit = (and_mask & -and_mask).bit_length() - 1

    stride_mask = (2 ** highest_bit  - 1) & ~(2 ** lowest_bit - 1)

    # mask higher than the highest bit are redundant
    and_mask &= stride_mask

    if stride_mask == and_mask:
        # We dont need the mask, stride is enough
        and_mask = None

    return AstRange(min=min, max=max, ast_size=ast_size, exact=exact,
                    entropy=entropy, isolated=isolated, and_mask=and_mask,
                    or_mask=or_mask, intervals=[Interval(min, max, stride)])

