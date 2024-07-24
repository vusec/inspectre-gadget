from dataclasses import dataclass

import claripy
import sys
from . import RangeStrategy

# autopep8: off
from ...shared.ranges import *
from ...shared.transmission import *
from ...shared.utils import *
from ...shared.logger import *
from ...shared.config import *
# autopep8: on

l = get_logger("InferIsolated")

debug = False

class RangeStrategyInferIsolated(RangeStrategy):

    def find_range(self, constraints, ast : claripy.ast.bv.BVS,
                   ast_min : int = None, ast_max : int = None):

        # We only support isolated ranges
        if constraints:
            return None

        if ast_min == None or ast_max == None:

            s = claripy.Solver(timeout=global_config["Z3Timeout"])

            if ast_min == None:
                ast_min = s.min(ast)
            if ast_max == None:
                ast_max = s.max(ast)

        if ast.depth == 1:
            return range_simple(ast_min, ast_max, ast.size(), 1, True)

        range_map = get_range_map_from_ast(ast)

        if range_map.unknown:

            # We try an extra optimization: separating the concrete value
            # from addition. This covers cases like:
            # 0xffffffff81000000 + <BV32 AST >
            # get_range_map_from_ast() cannot handle 'overflows', so we
            # split the AST and add the concrete value manually to the range.
            if ast.op == '__add__' and any(not arg.symbolic for arg in ast.args):

                concrete_value =  next(arg for arg in ast.args if not arg.symbolic).args[0]
                sub_ast = sum([arg for arg in ast.args if arg.symbolic])

                range_map = get_range_map_from_ast(sub_ast)

                if range_map.unknown:
                    return None

                range_map = range_map.switch_to_stride_mode(sub_ast.length)

                if range_map.unknown:
                    return None

                s = claripy.Solver(timeout=global_config["Z3Timeout"])
                sym_ast_min = s.min(sub_ast)
                sym_ast_max = s.max(sub_ast)

                return range_from_symbolic_concrete_addition(ast, ast_min, ast_max,
                                                      sym_ast_min, sym_ast_max, range_map.stride,
                                                      concrete_value)

            else:
                return None


        if range_map.stride_mode:
            return range_simple(ast_min, ast_max, ast.size(), range_map.stride, isolated=True)

        else:
            return range_complex(ast_min, ast_max, ast.size(), True, None, range_map.and_mask, range_map.or_mask, True)


def is_linear_mask(and_mask, or_mask):

    mask = and_mask & ~or_mask

    highest_bit = mask.bit_length()
    lowest_bit = (mask & -mask).bit_length() - 1

    stride_mask = (2 ** highest_bit - 1) & ~(2 ** lowest_bit - 1)

    return mask == stride_mask

@dataclass
class RangeMap:

    stride_mode : bool
    unknown : bool

    # mask mode
    or_mask : int    # bits which are always one are set
    and_mask : int   # bits which are always zero are unset

    # stride mode
    stride : int

    def __init__(self, bit_length, unknown=False):

        self.and_mask = 2 ** bit_length - 1
        self.or_mask = 0

        self.unknown = unknown

        self.stride_mode = False
        self.stride = 0

    def switch_to_stride_mode(self, int_length):

        if self.stride_mode:
            return self

        if not is_linear_mask(self.and_mask, self.or_mask):
            return unknown_range()

        self.stride = get_stride_from_mask(self.and_mask, self.or_mask)
        self.and_mask = 0
        self.stride_mode = True

        if self.stride >  2 ** int_length - 1:
            return unknown_range()


        return self

    def has_range(self):
        if self.unknown:
            return False

        if self.stride_mode:
            return True

        return self.and_mask != 0

    def is_full_range(self, int_length):
        if self.and_mask == 2 ** int_length - 1:
            return True

        return False

    def concat_range_map(self, other, own_length, int_length):

        if self.stride_mode:
            return unknown_range()

        other.shift_left(own_length, int_length)
        self.and_mask = self.and_mask | other.and_mask
        self.or_mask = self.or_mask | other.or_mask

        return self

    def concrete_add(self, value, int_length):
        if (self.and_mask + value) >= (2 ** int_length):
            # add has a overflow, we are not gonna try it
            return unknown_range()

        # We have to switch to STRIDE mode if possible
        return self.switch_to_stride_mode(int_length)

    def concrete_mul(self, value, int_length):

        # Check if we are in mask mode & multiplication is power of 2
        if (not self.stride_mode) and (value != 0) and (value & (value-1) == 0):
            # Power of two
            return self.shift_left(value.bit_length() - 1, int_length)


        if (self.and_mask * value) >= (2 ** int_length):
            # mul has a overflow, we are not gonna try it
            return unknown_range()

        # Multiply stride by multiplication
        new_map = self.switch_to_stride_mode(int_length)
        if not new_map.unknown:
            new_map.stride = new_map.stride * value

            if new_map.stride >  2 ** int_length - 1:
                return unknown_range()

        return new_map

    def op_and(self, and_mask):

        if self.stride_mode:
            if self.stride == 0 and is_linear_mask(and_mask, 0):
                new_stride = get_stride_from_mask(and_mask, 0)
                self.stride = new_stride

                return self
            else:
                return unknown_range()
        else:

            self.and_mask &= and_mask
            self.or_mask &= and_mask

            return self

    def op_or(self, or_mask):

        if self.stride_mode:
            if self.stride == 0 and is_linear_mask(or_mask, 0):
                self.stride = get_stride_from_mask(~or_mask, 0)
                return self

            else:
                return unknown_range()
        else:

            self.and_mask |= or_mask
            self.or_mask |= or_mask

            return self

    def op_extract(self, start, end):

        if self.stride_mode:
            return self

        else:

            # zero out up to end
            end_mask = (2 ** (end + 1)) -1
            self.and_mask &= end_mask
            self.or_mask &= end_mask

            # shift bits to start
            self.and_mask = self.and_mask >> start
            self.or_mask = self.or_mask >> start

            return self


    def invert(self):

        if self.stride_mode:
            return unknown_range()

        else:

            self.and_mask = ~self.or_mask
            self.or_mask = ~self.and_mask

            return self


    def shift_left(self, shift, int_length):
        if self.stride_mode:
            self.stride = self.stride * (2 ** shift)

            if self.stride >  2 ** int_length - 1:
                return unknown_range()

            return self
        else:

            self.and_mask = self.and_mask << shift
            self.and_mask &= 2 ** int_length - 1

            self.or_mask = self.or_mask << shift
            self.or_mask &= 2 ** int_length - 1

            return self

    def shift_right(self, shift):
        if self.stride_mode:

            if self.stride:
                return unknown_range()

            return self

        else:

            self.and_mask = self.and_mask >> shift
            self.or_mask = self.or_mask >> shift

            return self



def unknown_range():
    return RangeMap(0, unknown=True)

def op_zero_ext(ast, range_maps):
    # zeros .. src : arg[0] .. arg[1]
    return range_maps[1]

def op_concat(ast, range_maps):
    # arg0 .. arg1 .. _

    base_map = None
    cur_length = 0

    for idx, arg in reversed(list(enumerate(ast.args))):

        if range_maps[idx]:

            if base_map:
                base_map = base_map.concat_range_map(range_maps[idx], cur_length, ast.length)
            else:
                base_map = range_maps[idx]
                if cur_length != 0:
                    base_map = base_map.shift_left(cur_length, ast.length)

        elif ast.args[idx].symbolic:
            return unknown_range()

        elif not ast.args[idx].symbolic and ast.args[idx].args[0] != 0:
            return unknown_range()

        cur_length += arg.length

    return base_map

def op_extract(ast, range_maps):
    # src[end:start] : arg[2][arg[0]:arg[1]]
    base_map = range_maps[2]
    return base_map.op_extract(ast.args[1], ast.args[0])

def op_or(ast, range_maps):
    # arg0 | arg1

    base_map = None
    mask = None

    for idx, arg in enumerate(ast.args):

        if not arg.symbolic:
            if mask == None:
                mask = arg.args[0]
            else:
                mask |= arg.args[0]

        elif base_map == None:
            base_map = range_maps[idx]

        else:
            # Mask by symbolic variable, we can't know the range
            return unknown_range()

    return base_map.op_or(mask)

def op_and(ast, range_maps):
    # arg0 & arg1

    base_map = None
    mask = None

    for idx, arg in enumerate(ast.args):

        if not arg.symbolic:
            if mask == None:
                mask = arg.args[0]
            else:
                mask &= arg.args[0]

        elif base_map == None:
            base_map = range_maps[idx]

        else:
            # Mask by symbolic variable, we can't know the range
            return unknown_range()

    return base_map.op_and(mask)

def op_invert(ast, range_maps):
    # ~ arg[0]

    base_map = range_maps[0]

    return base_map.invert()

def op_lshift(ast, range_maps):
    # arg0 << arg1 : dst << shift
    if ast.args[1].symbolic:
        # Symbolic shift
        return unknown_range()

    else:
        # Non symbolic shift
        base_map = range_maps[0]
        shift = ast.args[1].args[0]
        return base_map.shift_left(shift, ast.length)

def op_lshr(ast, range_maps):
    # arg0 >> arg1 : dst >> shift

    if ast.args[1].symbolic:
        # Symbolic shift
        return unknown_range()

    else:
        # Non symbolic shift
        base_map = range_maps[0]
        shift = ast.args[1].args[0]
        return base_map.shift_right(shift)

def op_rshift(ast, range_maps):
    # sar arg0 arg1 : sar dst shift
    return unknown_range()


def op_add(ast, range_maps):

    non_full_ranges = []
    concrete_ast = None

    for idx, map in enumerate(range_maps):
        if not map:
            if concrete_ast != None:
                concrete_ast += ast.args[idx]
            else:
                concrete_ast = ast.args[idx]

        elif map.is_full_range(ast.length):
            return map

        else:
            non_full_ranges.append(map)

    if len(non_full_ranges) == 1:
        base_map = non_full_ranges[0]
        return base_map.concrete_add(concrete_ast.args[0], ast.length)

    return unknown_range()

def op_sub(ast, range_maps):

    non_full_ranges = []

    for map in range_maps:
        if not map:
            continue

        if map.is_full_range(ast.length):
            return map

        else:
            non_full_ranges.append(map)

    if len(non_full_ranges) == 1:
        return non_full_ranges[0]

    return unknown_range()

def op_mul(ast, range_maps):

    base_map = None
    concrete_ast = None

    for idx, map in enumerate(range_maps):
        # concrete value
        if not map:
            if concrete_ast != None:
                concrete_ast = concrete_ast * ast.args[idx]
            else:
                concrete_ast = ast.args[idx]

        # symbolic value
        elif base_map == None:
            base_map = range_maps[idx]
        else:
            # Mask by symbolic variable, we can't know the range
            return unknown_range()
    return base_map.concrete_mul(concrete_ast.args[0], ast.length)

def op_if(ast, range_maps):
    # if arg0 then arg1 else arg2

    # We return a full range if both the then and else are a full range

    if range_maps[1] and range_maps[2]:

        if range_maps[1].is_full_range(ast.length) and \
            range_maps[2].is_full_range(ast.length):
            # TODO: Equal ranges should be enough
            return range_maps[1]

    return unknown_range()

def op_unsupported(ast, range_maps):
    return unknown_range()



operators = {
    'ZeroExt'       : op_zero_ext,
    'Concat'        : op_concat,
    'Extract'       : op_extract,
    '__or__'        : op_or,
    '__and__'       : op_and,
    '__invert__'    : op_invert,
    '__lshift__'    : op_lshift,
    'LShR'          : op_lshr,
    '__rshift__'    : op_rshift,
    '__add__'       : op_add,
    '__sub__'       : op_sub,
    '__mul__'       : op_mul,
    'If'            : op_if,

    # Unsupported via this method
    '__eq__'        : op_unsupported,
    'SignExt'       : op_unsupported,
    '__ne__'        : op_unsupported,
    '__xor__'       : op_unsupported
}


def get_range_map_from_ast(ast : claripy.ast.bv.BVS):

    if not isinstance(ast, claripy.ast.base.Base) or not ast.symbolic:
        return None

    elif ast.depth == 1:
        return RangeMap(ast.length)

    else:

        args_range_maps = []

        for sub_ast in ast.args:
            args_range_maps.append(get_range_map_from_ast(sub_ast))

        if all(m is None or not m.has_range() for m in args_range_maps):
            return unknown_range()

        if all(m is None or not m.has_range() or m.unknown for m in args_range_maps):
            return unknown_range()

        if ast.op in operators:
            if debug:
                print(f"OP: {ast.op} AST: {ast} MAPS: {args_range_maps}")

            new_map = operators[ast.op](ast, args_range_maps)

            if debug:
                print(f"OUT: {new_map}")

            return new_map

        l.warning(f"Unsupported operation: {ast.op}")

        return unknown_range()


