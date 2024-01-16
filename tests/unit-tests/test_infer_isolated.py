import unittest

import claripy

from analyzer.analysis.range_strategies import *
from analyzer.shared.config import *


class RangeStrategyInferIsolatedTestCase(unittest.TestCase):

    range_strategy : RangeStrategyInferIsolated

    def setUp(self):
        init_config({})
        self.range_strategy = RangeStrategyInferIsolated()

    def test_unbound_with_symbolic_add(self):
        a = claripy.BVS("a", 64)
        b = claripy.BVS("b", 64)
        ast = a + (b & 0xfc)
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 2 ** 64 -1)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)


    def test_linear_mask_concrete_add(self):

        a = claripy.BVS("a", 32)
        ast = (a & 0xe) + 10
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 10)
        self.assertEqual(ast_range.max, 24)
        self.assertEqual(ast_range.stride, 2)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

    def test_linear_mask_concrete_add(self):

        a = claripy.BVS("a", 32)
        ast = ((a.zero_extend(32) << 2) + 13) << 2
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 52)
        self.assertEqual(ast_range.max, 0x1000000024)
        self.assertEqual(ast_range.stride, 0x10)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

    def test_concat_with_shift(self):

        a = claripy.BVS("a", 32)
        b = claripy.BVS("b", 32)
        ast =  claripy.Concat(a << 2, b << 4)
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0xfffffffcfffffff0)
        self.assertEqual(ast_range.stride, 16)
        self.assertEqual(ast_range.and_mask, 0xfffffffcfffffff0)
        self.assertEqual(ast_range.or_mask, None)

    def test_extract(self):

        a = claripy.BVS("a", 32)
        ast = (a << 2)[17:2]

        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0xffff)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

    def test_right_shift_extract(self):

        a = claripy.BVS("a", 32)
        ast = claripy.LShR(a, 2)[31:16]

        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0x3fff)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

    def test_mask_extract(self):

        a = claripy.BVS("a", 32)
        ast = (a & 0x27)[8:1]

        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0x13)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, 0x13)
        self.assertEqual(ast_range.or_mask, None)



    def test_right_left_shift(self):

        a = claripy.BVS("a", 64)

        ast = claripy.LShR((a + 1), 0x17) << 3
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0xffffffffff8)
        self.assertEqual(ast_range.stride, 8)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

    def test_shift_mask_shift(self):

        a = claripy.BVS("a", 32)
        ast = ((a << 2) & 122) << 2
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 480)
        self.assertEqual(ast_range.stride, 32)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)


    def test_shift_mul(self):

        a = claripy.BVS("a", 32)

        ast = (claripy.Concat(claripy.BVV(0, 32), a) << 2) * 8
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0x1fffffffe0)
        self.assertEqual(ast_range.stride, 32)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

    def test_and_or_and_normal(self):

        a = claripy.BVS("a", 64)
        ast =  ((a & 0xff) | 0x8) & 0x7

        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 7)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

    def test_and_or_and_or_mask(self):

        a = claripy.BVS("a", 64)
        ast =  (a & 0xe | 0x4) & 0xff

        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 4)
        self.assertEqual(ast_range.max, 14)
        self.assertEqual(ast_range.stride, 2)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, 4)

    def test_if_then_unbound_else_unbound(self):

        a = claripy.BVS("a", 64)
        b = claripy.BVS("b", 64)
        ast = claripy.If(a == 0, b, a)
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 2 ** 64 -1)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

    def test_non_linear_ranges(self):

        a = claripy.BVS("a", 8)
        ast = (a.zero_extend(8) + 10) & 10
        ast_range = self.range_strategy.find_range([], ast)

        self.assertIsNone(ast_range)

        a = claripy.BVS("a", 8)
        ast = (a.zero_extend(8) << 4) * 500
        ast_range = self.range_strategy.find_range([], ast)

        self.assertIsNone(ast_range)

    def test_mul(self):

        a = claripy.BVS("a", 32).zero_extend(32)

        ast = ((a * 3) + 10) << 2
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 40)
        self.assertEqual(ast_range.max, 0xc0000001c)
        self.assertEqual(ast_range.stride, 12)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

        a = claripy.BVS("a", 32).zero_extend(32)

        ast = (a << 2) * 7
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0x1bffffffe4)
        self.assertEqual(ast_range.stride, 0x1c)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

    def test_disjoint_range(self):

        # wrap-around with full range -- we should not care
        a = claripy.BVS("a", 64)

        ast = a + 0xffffffff81000000
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0xffffffffffffffff)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

        # Simple wrap-around
        a = claripy.BVS("a", 32).zero_extend(32)

        ast = a + 0xffffffff81000000
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0xffffffff81000000)
        self.assertEqual(ast_range.max, 0x80ffffff)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

        # Wrap-around while preserving stride info
        a = claripy.BVS("a", 64)

        ast = (a << 2) + 0xffffffff81000000
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0xfffffffffffffffc)
        self.assertEqual(ast_range.stride, 4)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)

        # Wrap-around with different offset, due to different base of addition
        a = claripy.BVS("a", 64)

        ast = (a << 2) + 0xffffffff81000002
        ast_range = self.range_strategy.find_range([], ast)

        self.assertEqual(ast_range.min, 2)
        self.assertEqual(ast_range.max, 0xfffffffffffffffe)
        self.assertEqual(ast_range.stride, 4)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)


        # Non-linear range: we should bail out
        a = claripy.BVS("a", 64)

        ast = ((a << 2) & 0x16) + 0xffffffff81000002
        ast_range = self.range_strategy.find_range([], ast)

        self.assertIsNone(ast_range)
