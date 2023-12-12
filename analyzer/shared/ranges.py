"""
Range object.
"""

from dataclasses import dataclass
import math
import time
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

    def __init__(self, min, max, exact, entropy=None, isolated=False, and_mask=None, or_mask=None, values=[], intervals=[]):
        self.min = min
        self.max = max
        self.window = max - min

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
        return AstRange(min=self.min, max=self.max, exact=self.exact,
                        entropy=self.entropy, isolated=self.isolated,
                        and_mask=self.and_mask, or_mask=self.or_mask,
                        values=self.values, intervals=self.intervals)

    def __str__(self):

        return self.to_string()

    def __repr__(self):
        return self.to_string()


def range_static(value, isolated):
    interval = Interval(min=value, max=value+1, stride=1)

    return AstRange(min=value, max=value, exact=True, entropy=0, isolated=isolated, intervals=[interval])


def range_simple(min, max, stride, isolated):
    return AstRange(min=min, max=max, exact=True, isolated=isolated, intervals=[Interval(min, max, stride)])


def get_stride_from_mask(and_mask, or_mask):
    mask = and_mask & ~or_mask

    if mask == 0:
        return 0

    lowest_bit = (mask & -mask).bit_length() - 1

    return 2 ** lowest_bit


def range_complex(min, max, exact, entropy, and_mask, or_mask, isolated=False):
    stride = get_stride_from_mask(and_mask, or_mask)

    highest_bit = max.bit_length()
    lowest_bit = (and_mask & -and_mask).bit_length() - 1

    stride_mask = (2 ** highest_bit  - 1) & ~(2 ** lowest_bit - 1)

    # mask higher than the highest bit are redundant
    and_mask &= stride_mask

    if stride_mask == and_mask:
        # We dont need the mask, stride is enough
        and_mask = None

    return AstRange(min=min, max=max,exact=exact, entropy=entropy,
                    isolated=isolated, and_mask=and_mask, or_mask=or_mask,
                    intervals=[Interval(min, max, stride)])

