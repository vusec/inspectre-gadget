import unittest

import claripy

from analyzer.shared.config import *
from analyzer.shared.astTransform import *
from analyzer.shared.utils import *
from analyzer.scanner.annotations import *
from analyzer.shared.logger import disable_logging


class MatchSignExtTestCase(unittest.TestCase):

    def setUp(self):
        init_config({})
        disable_logging()

    def test_match_sign_ext(self):
        x = claripy.BVS("x", 8)
        y = claripy.BVS("y", 8)
        z = claripy.BVS("z", 8)

        res = match_sign_ext(x, 0)
        self.assertTrue(res.structurally_match(x))
        self.assertTrue(getSignExtAnnotation(res) == None)

        res = match_sign_ext(claripy.Concat(y, x[7:7],x[7:7],x[7:7],x[7:7],x, z), 0)

        const_0 = claripy.BVV(0, 4)
        const_1 = claripy.BVV(0xf, 4)
        expected = claripy.Concat(y,
                                  claripy.If(x[7:7] == 0,
                                             claripy.Concat(const_0,x),
                                             claripy.Concat(const_1,x)),
                                  z)
        self.assertTrue(res.structurally_match(expected))
        self.assertTrue(getSignExtAnnotation(res.args[1]) != None)

        res = match_sign_ext(claripy.Concat(const_0, x), 0)
        self.assertTrue(res.structurally_match(claripy.Concat(const_0, x)))
        self.assertTrue(getSignExtAnnotation(res) == None)

        res = match_sign_ext(claripy.Concat(y, x[7:7],x[7:7],x[7:7],x[7:7],x), 0)

        const_0 = claripy.BVV(0, 4)
        const_1 = claripy.BVV(0xf, 4)
        expected = claripy.Concat(y,
                                  claripy.If(x[7:7] == 0,
                                             claripy.Concat(const_0,x),
                                             claripy.Concat(const_1,x)) )
        self.assertTrue(res.structurally_match(expected))
        self.assertTrue(getSignExtAnnotation(res.args[1]) != None)

        res = match_sign_ext(claripy.Concat(y, x[7:7],x[7:7],x[7:7],x[7:7],z), 0)
        expected = claripy.Concat(y, x[7:7],x[7:7],x[7:7],x[7:7],z)

        self.assertTrue(res.structurally_match(expected))
        self.assertTrue(getSignExtAnnotation(res.args[1]) == None)


    def test_sign_ext_to_sum(self):
        x = claripy.BVS("x", 8)
        y = claripy.BVS("y", 8)
        z = claripy.BVS("z", 8)

        res = sign_ext_to_sum(x, 0)
        self.assertTrue(res.structurally_match(x))
        self.assertTrue(getSignExtAnnotation(res) == None)

        expr = claripy.Concat(y,claripy.SignExt(4,x),z)
        res = sign_ext_to_sum(expr, 0)

        const_0 = claripy.BVV(0, 4)
        const_1 = claripy.BVV(0xf, 4)
        expected = claripy.Concat(y,
                                  claripy.If(x[7:7] == 0,
                                             claripy.Concat(const_0,x),
                                             claripy.Concat(const_1,x)),
                                  z)
        self.assertTrue(res.structurally_match(expected))
        self.assertTrue(getSignExtAnnotation(res.args[1]) != None)


    def test_annotations_simplification(self):
        x = claripy.BVS("x", 8).annotate(AttackerAnnotation("rsi"))
        y = claripy.BVS("y", 8).annotate(AttackerAnnotation("rdi"))
        z = claripy.BVS("z", 8).annotate(SecretAnnotation(x+y, 0, True))

        self.assertTrue(len(get_annotations(x)) == 1)
        self.assertTrue(len(get_annotations(x + y)) == 2)
        self.assertTrue(len(get_annotations(x + y + z)) == 3)

        self.assertTrue(len(get_annotations(x + y + z)) == 3)
        c =claripy.Concat(x, y, z)
        self.assertTrue(len(get_annotations(c)) == 3)
        d = c[7:0]
        self.assertTrue(len(get_annotations(d)) == 1)
        d = c[8:0]
        self.assertTrue(len(get_annotations(d)) == 2)
