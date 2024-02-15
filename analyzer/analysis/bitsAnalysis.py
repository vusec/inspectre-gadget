"""BitsAnalysis

This analysis infers how bits of the secret are spread in the transmission
expression.
"""

import claripy

# autopep8: off
from ..shared.transmission import *
from ..shared.utils import *
from ..shared.logger import *
from ..scanner.annotations import *
from ..shared.config import *
# autopep8: on

BITMAP_SPREAD = 0
BITMAP_DIRECT = 1

l = get_logger("BitsAnalysis")


def get_list_of_bits_set(mask):
    bits_set = []
    idx = 0
    bit = 1

    while mask >= bit:
        if mask & bit:
            bits_set.append(idx)
        bit = bit << 1
        idx +=1

    return bits_set

class FlowMap:
    is_direct : bool # direct or spread

    # DIRECT
    direct_map : dict

    # SPREAD
    spread: list
    inferable_bits : list

    sign_extended : bool

    @property
    def spread_low(self):
        if self.is_direct:
            return 0 if len(self.direct_map) == 0 else min(self.direct_map)
        else:
            return 0 if len(self.spread) == 0 else min(self.spread)


    @property
    def spread_high(self):
        if self.is_direct:
            return 0 if len(self.direct_map) == 0 else max(self.direct_map)
        else:
            return 0 if len(self.spread) == 0 else max(self.spread)

    @property
    def spread_total(self):
        if self.is_direct:
            return len(self.direct_map)
        else:
            return len(self.spread)


    @property
    def all_inferable_bits(self):
        if self.is_direct:
            return list(self.direct_map.values())
        else:
            return list(set(self.inferable_bits))

    @property
    def number_of_bits_inferable(self):
        if self.is_direct:
            return len(set(self.direct_map.values()))
        else:
            return len(set(self.inferable_bits))



    def to_string(self):
        return f"""
            spread high: {hex(self.spread_high)}
            spread low: {hex(self.spread_low)}
            spread total: {hex(self.spread_total)}
            # inferable bits: {hex(self.number_of_bits_inferable)}
        """

    def to_dict(self):
        return OrderedDict([
            ("spread_high", self.spread_high),
            ("spread_low", self.spread_low),
            ("spread_total", self.spread_total),
            ("n_inferable_bits", self.number_of_bits_inferable)
        ])

    def __repr__(self):
        return self.to_string()

    def __str__(self):
        return self.to_string()

    def __init__(self, direct_map : dict, spread : list, inferable_bits : list):

        if direct_map:
            self.is_direct = BITMAP_DIRECT
        else:
            self.is_direct = BITMAP_SPREAD

        self.direct_map = direct_map
        self.spread = spread
        self.inferable_bits = inferable_bits
        self.sign_extended = False

    def is_empty(self):

        if self.is_direct:
            return not self.direct_map
        else:
            return not self.spread or not self.inferable_bits


    def convert_to_spread(self):
        # Convert the flow-map to spread
        if not self.is_direct:
            return

        self.spread = [k for k in self.direct_map]
        self.inferable_bits = [b for b in self.direct_map.values()]
        self.direct_map = None
        self.is_direct = BITMAP_SPREAD

    def merge_inferable_bits(self, other):

        self.sign_extended = self.sign_extended | other.sign_extended

        if self.is_direct:
            self.convert_to_spread()

        if other.is_direct:
            other.convert_to_spread()

        self.inferable_bits += other.inferable_bits
        # deduplicate
        self.inferable_bits = list(set(self.inferable_bits))

    ###########################################################################
    # Spread modification functions
    # for the callee, 'end' is including, 'int_length' is excluding

    def set_spread(self, spread):

        if self.is_direct:
            self.convert_to_spread()

        self.spread = spread

    def spread_to_one(self):
        self.set_spread(range(0, 1))

    def widen_spread(self, start, end):

        if self.is_direct:
            self.convert_to_spread()

        if not self.spread:
            return

        self_min = min(self.spread)
        if self_min < start:
            start = self_min

        self_max = max(self.spread)
        if self_max > end:
            end = self_max

        self.set_spread(range(start, end + 1))

    def spread_to_right(self, start):

        if self.is_direct:
            self.convert_to_spread()

        if not self.spread:
            return

        max_spread = max(self.spread)
        self.set_spread(range(start, max_spread + 1))


    def spread_to_left(self, end):

        if self.is_direct:
            self.convert_to_spread()

        if not self.spread:
            return

        min_spread = min(self.spread)
        self.set_spread(range(min_spread, end + 1))

    def spread_to_left_by(self, to_spread, int_length):

        if self.is_direct:
            self.convert_to_spread()

        if not self.spread:
            return

        new_max = max(self.spread) + to_spread + 1   # last excluding
        if new_max > int_length:
            # we have a overflow, we set spread to all
            self.spread = range(0, int_length)
        else:
            old_min = min(self.spread)
            self.spread = range(old_min, new_max)

    def spread_to_left_by_one(self, int_length):

        self.spread_to_left_by(1, int_length)

    def spread_to_right_by_one(self, int_length):

        if self.is_direct:
            self.convert_to_spread()

        if not self.spread:
            return

        new_min = min(self.spread) - 1
        if new_min < 0:
            # we have a underflow, we set spread to all
            self.spread = range(0, int_length)
        else:
            old_max = max(self.spread)
            self.spread = range(new_min, old_max + 1)

    ###########################################################################
    # Operation functions

    def extract(self, start, end):

        to_extract = range(start, end + 1)

        if self.is_direct:
            new_map = {}

            for new_idx, old_idx in enumerate(to_extract):
                if old_idx in self.direct_map:
                    new_map[new_idx] = self.direct_map[old_idx]

            self.direct_map = new_map
        else:
            spread = [(s - start) for s in self.spread if s in to_extract]
            self.spread = spread

    def concat_flow_map(self, other, self_length):

        self.merge_inferable_bits(other)

        for bit in other.spread:
            self.spread = list(self.spread)
            self.spread.append(bit + self_length)

    def add_flow_map(self, other, int_length):

        self.merge_inferable_bits(other)

        self.widen_spread(min(other.spread), max(other.spread))

        self.spread_to_left_by_one(int_length)

    def add_of_size(self, int_length, add_length):

        # self.spread_to_left_by_one(int_length)

        if self.is_direct:
            self.convert_to_spread()

        new_max = max(self.spread)

        # Take the max length of both additions
        if new_max < add_length:
            new_max = add_length

        # Add one to it, we assume one bit to the left for the addition
        new_max += 1

        if new_max > int_length:
            # we have an overflow
            self.set_spread(range(0, int_length))
        else:
            self.spread_to_left(new_max)

    def sub_flow_map(self, other):

        self.merge_inferable_bits(other)
        self.widen_spread(0, max(other.spread))

    def mul_flow_map(self, other, int_length):

        # We merge the inferable bits
        self.merge_inferable_bits(other)

        # We set the spread to the complete length
        self.set_spread(range(0, int_length))


    def shift_left(self, shift, int_length):

        if self.is_direct:
            new_map = {}

            for idx in self.direct_map:
                new_idx = idx + shift
                if new_idx >= int_length:
                    continue

                new_map[new_idx] = self.direct_map[idx]

            self.direct_map = new_map

        else:

            if isinstance(self.spread, range):
                new_start = self.spread.start + shift
                new_stop = self.spread.stop + shift
                if new_start >= int_length:
                    new_start = int_length - 1
                if new_stop > int_length:
                    new_stop = int_length

                new_spread = range(new_start, new_stop)
            else:
                new_spread = []

                for idx in self.spread:
                    new_idx = idx + shift
                    if new_idx >= int_length:
                        continue
                    new_spread.append(new_idx)

            self.spread = new_spread

    def shift_right(self, shift):

        if self.is_direct:
            new_map = {}

            for idx in self.direct_map:
                new_idx = idx - shift
                if new_idx < 0:
                    continue

                new_map[new_idx] = self.direct_map[idx]

            self.direct_map = new_map

        else:

            if isinstance(self.spread, range):
                new_start = self.spread.start - shift
                new_stop = self.spread.stop - shift
                if new_start < 0:
                    new_start = 0
                if new_stop < 0:
                    new_stop = 0

                new_spread = range(new_start, new_stop)
            else:
                new_spread = []

                for idx in self.spread:
                    new_idx = idx - shift
                    if new_idx < 0:
                        continue
                    new_spread.append(new_idx)

            self.spread = new_spread

    def shift_arithmetic_right(self, shift, int_length):
        # SAR instruction, we preserve the MSB
        msb = int_length - 1
        sign_bit = None

        if self.is_direct:

            if msb in self.direct_map:
                sign_bit = self.direct_map[msb]

                # now do a normal shift
                self.shift_right(shift)
                # Preserve the msb
                self.direct_map[msb] = sign_bit
            else:
                # just do a normal shift
                self.shift_right(shift)

        else:
            if msb in self.spread:
                # now do a normal shift
                self.shift_right(shift)
                # Replace the msb
                self.spread = list(self.spread)
                self.spread.append(msb)
            else:
                # just do a normal shift
                self.shift_right(shift)



    def and_mask(self, mask):

        # First get the list of bits to preserve
        to_preserve = get_list_of_bits_set(mask)

        # Now apply the mask

        if self.is_direct:
            new_map = {}
            for idx in to_preserve:
                bit = self.direct_map.pop(idx, None)

                if bit != None:
                    new_map[idx] = bit

            self.direct_map = new_map

        else:
            new_spread = []
            for idx in to_preserve:
                if idx in self.spread:
                    new_spread.append(idx)

            self.spread = new_spread

    def or_mask(self, mask):

        # First get the list of bits to preserve
        to_remove = get_list_of_bits_set(mask)

        # Now apply the mask

        if self.is_direct:
            new_map = {}

            for idx in self.direct_map:
                if idx in to_remove:
                    continue

                new_map[idx] = self.direct_map[idx]

            self.direct_map = new_map

        else:
            new_spread = []

            for idx in self.spread:
                if idx in to_remove:
                    continue

                new_spread.append(idx)

            self.spread = new_spread

def flow_maps_merge_inferable_bits(flow_maps, self=None):

    base_map = self

    for map in flow_maps:
        if not map or map == base_map:
            continue
        if not base_map:
            base_map = map
        else:
            base_map.merge_inferable_bits(map)

    return base_map



def op_zero_ext(ast, flow_maps):
    # zeros .. src : arg[0] .. arg[1]
    return flow_maps[1]

def op_sign_ext(ast, flow_maps):
    # extendSize .. src : arg[0] .. arg[1]
    base_map = flow_maps[1]

    # We do not adjust the map to comply the sign extension. This limits
    # the reasoning about the exploitable. We can always leak only ASCII
    # characters and thus we can ignore sign extension
    # base_map.sign_ext(ast.args[1].length, ast.args[0])

    # Instead: mark secret as sign extended
    base_map.sign_extended = True

    return base_map

def op_concat(ast, flow_maps):
    # arg0 .. arg1 .. _

    base_map = None
    cur_length = 0

    for idx, arg in reversed(list(enumerate(ast.args))):

        if flow_maps[idx]:

            if base_map:
                base_map.concat_flow_map(flow_maps[idx], cur_length)
            else:
                base_map = flow_maps[idx]
                if cur_length != 0:
                    base_map.shift_left(cur_length, ast.length)

        cur_length += arg.length

    return base_map

def op_extract(ast, flow_maps):
    # src[end:start] : arg2[arg1:arg0]

    if flow_maps[2]:
        # Normal case, src has a flow map
        base_map = flow_maps[2]

        if isinstance(ast.args[0], claripy.ast.base.Base) \
            or isinstance(ast.args[1], claripy.ast.base.Base):
            # Extract operations are symbolic, so we can't know which
            # bytes are extracted. We have to convert to spread
            flow_maps_merge_inferable_bits(flow_maps, base_map)
            base_map.convert_to_spread()

        else:
            base_map.extract(ast.args[1], ast.args[0])

        return base_map

    elif flow_maps[0] or flow_maps[1]:
        # The extract operator has a flow_map, we only
        # can merge the inferable_bits and take the src length as spread
        base_map = flow_maps_merge_inferable_bits(flow_maps)
        base_map.set_spread(range(0, ast.length))
        return base_map

def op_and(ast, flow_maps):
    # arg0 & arg1 & ...

    # get the first flow_map
    for map in flow_maps:
        if map:
            base_map = map
            break

    for idx, map in enumerate(flow_maps):
        if map == base_map:
            continue

        if ast.args[idx].symbolic:
            # Symbolic and, merge inferable bits if any and convert to spread
            if map:
                base_map.merge_inferable_bits(map)
            else:
                base_map.convert_to_spread()
        else:
            # apply the mask
            mask = ast.args[idx].args[0]
            base_map.and_mask(mask)

    return base_map

def op_or(ast, flow_maps):
    # arg0 | arg1 | ...

    # get the first flow_map
    for map in flow_maps:
        if map:
            base_map = map
            break

    for idx, map in enumerate(flow_maps):
        if map == base_map:
            continue

        if ast.args[idx].symbolic:
            # Symbolic or, merge inferable bits if any and convert to spread
            if map:
                base_map.merge_inferable_bits(map)
            else:
                base_map.convert_to_spread()
        else:
            # apply the mask
            mask = ast.args[idx].args[0]
            base_map.or_mask(mask)

    return base_map

def op_invert(ast, flow_maps):
    # ~ arg[0]
    # There are multiple ways to handle this situation. We just return the
    # flow map, since no secret information is lost only the bits are inverted
    return flow_maps[0]

def op_lshift(ast, flow_maps):
    # arg0 << arg1 : dst << shift

    if flow_maps[0]:
        base_map = flow_maps[0]

        if ast.args[1].symbolic:
            # Symbolic shift, merge inferable bits and just spread to
            # all left
            if flow_maps[1]:
                base_map.merge_inferable_bits(flow_maps[1])
            base_map.spread_to_left(ast.length)

        else:
            # Non symbolic shift
            shift = ast.args[1].args[0]
            base_map.shift_left(shift, ast.length)

        return base_map

    else:
        # The shift it self has a flow map
        base_map = flow_maps[1]
        base_map.set_spread(range(0, ast.length))

        return base_map

def op_lshr(ast, flow_maps):
    # arg0 >> arg1 : dst >> shift

    if flow_maps[0]:
        base_map = flow_maps[0]

        if ast.args[1].symbolic:
            # Symbolic shift, merge inferable bits and just spread to right
            if flow_maps[1]:
                base_map.merge_inferable_bits(flow_maps[1])
            base_map.spread_to_right(0)

        else:
            # Non symbolic shift
            shift = ast.args[1].args[0]
            base_map.shift_right(shift)

        return base_map

    else:
        # The shift it self has a flow map
        base_map = flow_maps[1]
        base_map.set_spread(range(0, ast.length))
        return base_map

def op_rshift(ast, flow_maps):
    # sar arg0 arg1 : sar dst shift

    # We treat the arithmetic right shift as a normal right shift.
    # Otherwise the most-significant bits are set to the MsB, which an
    # attacker can circumvent by leaking ASCII characters.

    if flow_maps[0]:
        base_map = flow_maps[0]
    else:
        base_map = flow_maps[1]

    base_map.sign_extended = True
    return op_lshr(ast, flow_maps)

def op_add(ast, flow_maps):
    # arg0 + arg1 + _


    # get the first flow_map
    for map in flow_maps:
        if map:
            base_map = map
            break

    # For every addition, merge the flow_map
    # or increase spread by one
    for idx, map in enumerate(flow_maps):
        if map == base_map:
            continue

        if map:
            base_map.add_flow_map(map, ast.length)
        else:

            if ast.args[idx].symbolic:
                size = ast.args[idx].length
            else:
                value = ast.args[idx].args[0]
                size = value.bit_length()

            base_map.add_of_size(ast.length, size)

    return base_map

def op_sub(ast, flow_maps):
    # arg0 - arg1 - _
    return op_add(ast, flow_maps)

def op_mul(ast, flow_maps):
    # arg0 * ag1 * _

    # get the first flow_map
    for map in flow_maps:
        if map:
            base_map = map
            break

    # For every multiplication
    for idx, map in enumerate(flow_maps):
        if map == base_map:
            continue
        if map:
            base_map.mul_flow_map(map, ast.length)
        elif ast.args[idx].symbolic:
            # Mul with symbolic variable
            base_map.set_spread(range(0, ast.length))
        else:
            # Mul with concrete value
            # We first shift with the smallest multiplication of 2
            value = ast.args[idx].args[0]
            min_shift = value.bit_length() - 1
            remainder = value - (2 ** min_shift)

            if remainder == 0:
                # Multiplication with base 2, we can treat it like a shift
                base_map.shift_left(min_shift, ast.length)

            else:
                # We spread to left by min_shift + 1. We do not have
                # to spread to right
                base_map.spread_to_left_by(min_shift + 1, ast.length)

    return base_map

def op_eq_neq(ast, flow_maps):
    # arg0 == arg1 or arg0 != arg1

    if flow_maps[0]:
        base_map = flow_maps[0]

        if flow_maps[1]:
            base_map.merge_inferable_bits(flow_maps[1])

    else:
        base_map = flow_maps[1]

    # Set the spread to one bit
    base_map.spread_to_one()
    return base_map

def op_if(ast, flow_maps):
    # if arg0 then arg1 else arg2

    # We merge all flow_maps, next we set the spread
    base_map = flow_maps_merge_inferable_bits(flow_maps)

    if not ast.args[1].symbolic and not ast.args[2].symbolic:
        # Both operands are non-symbolic, we can limit the
        # spread to the bitwise-or of both

        all_bits = ast.args[1].args[0] | ast.args[2].args[0]

        new_spread = get_list_of_bits_set(all_bits)

    if ast.args[1].cardinality <= 2 and  ast.args[2].cardinality <=2:
        # Both operations have a small cardinality, lets solve it
        # and limit the spread to the bitwise-or of both

        s = claripy.Solver(timeout=global_config["Z3Timeout"])
        all_solutions = s.eval(ast.args[1], 2)
        all_solutions += s.eval(ast.args[2], 2)

        all_bits = 0
        for s in all_solutions:
            all_bits |= s

        new_spread = get_list_of_bits_set(all_bits)
    else:
        # We set the spread to the complete ast length
        new_spread = range(0, ast.length)

    base_map.set_spread(new_spread)

    return base_map

def op_unsupported(ast, flow_maps):
    return None



operators = {
    'ZeroExt'       : op_zero_ext,
    'SignExt'       : op_sign_ext,
    'Concat'        : op_concat,
    'Extract'       : op_extract,
    '__and__'       : op_and,
    '__or__'        : op_or,
    '__invert__'    : op_invert,
    '__lshift__'    : op_lshift,
    'LShR'          : op_lshr,
    '__rshift__'    : op_rshift,
    '__add__'       : op_add,
    '__sub__'       : op_sub,
    '__mul__'       : op_mul,
    '__eq__'        : op_eq_neq,
    '__ne__'        : op_eq_neq,
    'If'            : op_if,
    # unsupported
    '__xor__'       : op_unsupported
}


def get_inferable_bits(ast : claripy.ast.bv.BVS, source : claripy.ast.bv.BVS):

    if not isinstance(ast, claripy.ast.base.Base) or not ast.symbolic:
        return None

    elif ast is source:
        direct_map = {v : v for v in range(0, source.length)}

        return FlowMap(direct_map, None, None)

    elif ast.depth == 1:
        return None
    else:

        # first get flow maps of child operations

        args_flow_maps = []
        for sub_ast in ast.args:
            args_flow_maps.append(get_inferable_bits(sub_ast, source))

        if all(v is None for v in args_flow_maps):
            return None

        if ast.op in operators:
            new_map = operators[ast.op](ast, args_flow_maps)

            if not new_map or new_map.is_empty():
                return None
            return new_map


        l.warning(f"Unsupported operation: {ast.op}")


def analyse(t: Transmission):
    l.warning(f"========= [BITS] ==========")

    t.inferable_bits = get_inferable_bits(t.transmitted_secret.expr, t.secret_val.expr)
    if t.inferable_bits == None:
        t.inferable_bits = FlowMap({}, [], [])

    l.warning(f"==========================")
