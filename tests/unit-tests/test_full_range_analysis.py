import unittest

import claripy

from analyzer.analysis.rangeAnalysis import get_ast_ranges
from analyzer.shared.config import *
from analyzer.shared.logger import disable_logging


class RangeStrategyInferIsolatedTestCase(unittest.TestCase):

    def setUp(self):
        init_config({})
        disable_logging()

    def test_constraints(self):


        a = claripy.BVS("a", 64)

        ast = a << 4
        constraints = [ast != 0]
        ast_range = get_ast_ranges(constraints, ast)

        self.assertEqual(ast_range.min, 16)
        self.assertEqual(ast_range.max, 0xfffffffffffffff0)
        self.assertEqual(ast_range.stride, 16)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)
        self.assertTrue(ast_range.exact)

        a = claripy.BVS("a", 64)

        ast = a << 4
        constraints = [ast <= 0xffff, ast >= 0xff]
        ast_range = get_ast_ranges(constraints, ast)

        self.assertEqual(ast_range.min, 0x100)
        self.assertEqual(ast_range.max, 0xfff0)
        self.assertEqual(ast_range.stride, 16)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)
        self.assertTrue(ast_range.exact)

        # Should be solved exact by constraint_bounds followed
        # by infer_isolated
        a = claripy.BVS("a", 64)

        ast = a | (1 << 5)
        constraints = [ast <= 0xffff]
        ast_range = get_ast_ranges(constraints, ast)

        self.assertEqual(ast_range.min, 32)
        self.assertEqual(ast_range.max, 0xffff)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, 32)
        self.assertTrue(ast_range.exact)


        # We fail to do this one exact. The double constraints makes it hard
        # to invert them in _find_sat_distribution
        a = claripy.BVS("a", 32)

        ast = a & 0xfff00
        constraints = [a < 0xffff, a != 0xb00]
        ast_range = get_ast_ranges(constraints, ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0xff00)
        self.assertEqual(ast_range.stride, 256)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)
        self.assertFalse(ast_range.exact)

    def test_disjoint_with_constraints_range(self):


        a = claripy.BVS("a", 32)

        ast = a << 4
        constraints = [ast != 32]
        ast_range = get_ast_ranges(constraints, ast)

        self.assertEqual(ast_range.min, 33)
        self.assertEqual(ast_range.max, 31)
        self.assertEqual(ast_range.stride, 16)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)
        self.assertTrue(ast_range.exact)


        a = claripy.BVS("a", 32)

        ast = a
        constraints = [ast != 0xf, ast <= 0xffff]
        ast_range = get_ast_ranges(constraints, ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0xffff)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)
        self.assertFalse(ast_range.exact)




    def test_disjoint_range(self):

        # wrap-around with full range -- we should not care
        a = claripy.BVS("a", 64)

        ast = a + 0xffffffff81000000
        ast_range = get_ast_ranges([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0xffffffffffffffff)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)
        self.assertTrue(ast_range.exact)

        # Simple wrap-around
        a = claripy.BVS("a", 32).zero_extend(32)

        ast = a + 0xffffffff81000000
        ast_range = get_ast_ranges([], ast)

        self.assertEqual(ast_range.min, 0xffffffff81000000)
        self.assertEqual(ast_range.max, 0x80ffffff)
        self.assertEqual(ast_range.stride, 1)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)
        self.assertTrue(ast_range.exact)

        # Wrap-around while preserving stride info
        a = claripy.BVS("a", 64)

        ast = (a << 2) + 0xffffffff81000000
        ast_range = get_ast_ranges([], ast)

        self.assertEqual(ast_range.min, 0)
        self.assertEqual(ast_range.max, 0xfffffffffffffffc)
        self.assertEqual(ast_range.stride, 4)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)
        self.assertTrue(ast_range.exact)

        # Wrap-around with different offset, due to different base of addition
        a = claripy.BVS("a", 64)

        ast = (a << 2) + 0xffffffff81000002
        ast_range = get_ast_ranges([], ast)

        self.assertEqual(ast_range.min, 2)
        self.assertEqual(ast_range.max, 0xfffffffffffffffe)
        self.assertEqual(ast_range.stride, 4)
        self.assertEqual(ast_range.and_mask, None)
        self.assertEqual(ast_range.or_mask, None)
        self.assertTrue(ast_range.exact)


        # Non-linear range: we have to make a estimation
        a = claripy.BVS("a", 64)

        ast = ((a << 2) & ~0x16) + 0xffffffff81000002
        ast_range = get_ast_ranges([], ast)


        self.assertEqual(ast_range.min, 2)
        self.assertEqual(ast_range.max, 0xffffffffffffffea)
        self.assertEqual(ast_range.stride, 8)
        self.assertFalse(ast_range.exact)
