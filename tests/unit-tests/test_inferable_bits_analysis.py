import unittest

import claripy

from analyzer.analysis.bitsAnalysis import *


class InferableBitsAnalysisTestCase(unittest.TestCase):

    def test_sign_extended_simple(self):
        a = claripy.BVS("a", 32)
        ast = a.sign_extend(32)
        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 1)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 32)))
        self.assertEqual(set(flow_map.direct_map.values()), set(range(0, 32)))

    def test_sign_extended_complex(self):

        a = claripy.BVS("a", 32)
        ast = (a.sign_extend(32) + 0x5) << 4
        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 32)
        self.assertEqual(flow_map.spread_low, 4)
        self.assertEqual(flow_map.spread_high, 36)

        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 32)))
        self.assertEqual(set(flow_map.spread), set(range(4, 37)))

    def test_multiplicaton(self):
        ### Mul base of 2
        a = claripy.BVS("a", 32)
        a_ext = claripy.Concat(claripy.BVV(0, 32), a)
        ast = (a_ext << 2) * 8
        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 1)
        self.assertEqual(flow_map.number_of_bits_inferable, 32)
        self.assertEqual(flow_map.spread_low, 5)
        self.assertEqual(flow_map.spread_high, 36)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 32)))

        ### Mul then shift
        a = claripy.BVS("a", 32)
        a_ext = a.zero_extend(32)
        ast = ((a_ext * 5) + 10) << 2
        flow_map = get_inferable_bits(ast, a)


        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 32)
        self.assertEqual(flow_map.spread_low, 2)
        self.assertEqual(flow_map.spread_high, 37)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 32)))

        ### Shift then mul
        a = claripy.BVS("a", 32)
        a_ext = a.zero_extend(32)
        ast = ((a_ext << 4) + 20) * 9
        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 32)
        self.assertEqual(flow_map.spread_low, 4)
        self.assertEqual(flow_map.spread_high, 40)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 32)))

    def test_addition(self):

        ### Concrete add
        a = claripy.BVS("a", 32)
        a_ext = a.zero_extend(32)
        ast = (a_ext + 9)
        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 32)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 32)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 32)))


        ### Concrete add big value
        a = claripy.BVS("a", 16)
        a_ext = a.zero_extend(48)
        ast = (a_ext + 0xffffffff) * 2
        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 16)
        self.assertEqual(flow_map.spread_low, 1)
        self.assertEqual(flow_map.spread_high, 34)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 16)))

        ### Symbolic add
        a = claripy.BVS("a", 32)
        a_ext = a.zero_extend(32)

        b = claripy.BVS("b", 64)
        b_ext = b

        ast = a_ext + b_ext
        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 32)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 63)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 32)))

    def test_addition_complex(self):

        a = claripy.BVS("a", 32)
        a_ext = claripy.BVV(0, 32).concat(a)
        ast = (a_ext >> 4) * 0xfc + (a_ext & 0xf3) * 0x18
        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 30)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 36)
        self.assertEqual(flow_map.all_inferable_bits, [0, 1] + list(range(4, 32)))

    def test_and_operation(self):

        # mask and add again
        a = claripy.BVS("a", 32)
        a_ext = claripy.BVV(0, 32).concat(a)
        ast = (a_ext & 0xff96) + (a_ext & 0x69)

        flow_map = get_inferable_bits(ast, a)

        # This could be a direct map, since all secret locations do not overlap
        # in the addition. However, moving to spread mode is more general
        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 16)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 16)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 16)))

    def test_shift_arithmetic_right(self):

        a = claripy.BVS("a", 64)
        ast = a >> 4
        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 1)
        self.assertEqual(flow_map.number_of_bits_inferable, 60)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 59)
        self.assertEqual(flow_map.all_inferable_bits, list(range(4, 64)))
        self.assertEqual(flow_map.sign_extended, 1)

    def test_eq_neq(self):

        # Concrete value
        a = claripy.BVS("a", 16)
        ast = a == 20

        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 16)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 0)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 16)))

        # Symbolic value
        a = claripy.BVS("a", 16)
        b = claripy.BVS("b", 16)
        ast = a == b

        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 16)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 0)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0, 16)))

    def test_and_or_and_or_mask(self):

        a = claripy.BVS("a", 64)
        ast =  (a & 0xe | 0x4) & 0xff

        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 1)
        self.assertEqual(flow_map.number_of_bits_inferable, 2)
        self.assertEqual(flow_map.spread_low, 1)
        self.assertEqual(flow_map.spread_high, 3)
        self.assertEqual(flow_map.all_inferable_bits, [1, 3])

    def test_extract(self):

        # Extract direct map
        a = claripy.BVS("a", 32)
        ast = a[15:8]

        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 1)
        self.assertEqual(flow_map.number_of_bits_inferable, 8)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 7)
        self.assertEqual(flow_map.all_inferable_bits, list(range(8,16)))

        # Extract spread
        a = claripy.BVS("a", 32)
        a_spread = a + 20
        ast = a_spread[15:8]

        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 32)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 7)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0,32)))

    def test_concat(self):

        # # concat direct map
        a = claripy.BVS("a", 32)
        ast = claripy.Concat(a[0:0], a[1:1], a[3:2], a[31:4])

        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 32)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 31)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0,32)))

        # concat spread
        a = claripy.BVS("a", 32)
        a_spread = a + 20
        ast = claripy.Concat(a_spread[31:31], a_spread[31:31], a_spread[31:31], a_spread[31:3])

        flow_map = get_inferable_bits(ast, a)

        self.assertEqual(flow_map.is_direct, 0)
        self.assertEqual(flow_map.number_of_bits_inferable, 32)
        self.assertEqual(flow_map.spread_low, 0)
        self.assertEqual(flow_map.spread_high, 31)
        self.assertEqual(flow_map.all_inferable_bits, list(range(0,32)))








