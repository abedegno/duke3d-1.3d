"""A data-only proof requires independently anchored, complete placements."""
import copy
import importlib
import unittest

from tools.prove_module import Module
from omf32 import Segment,Fixup


class DataBindingTests(unittest.TestCase):
    def test_places_complete_data_from_consistent_public_anchors(self):
        infer=importlib.import_module('tools.infer_bindings').infer_data_bindings
        m=Module(segments=[Segment('_DATA','DATA',8,0xa9,bytearray(8))],
                 publics={'a':(1,2),'b':(1,6)})
        result=infer(m,{'a':(3,100),'b':(3,104)})
        self.assertEqual(result['placements'],{1:(3,98)})
        bad=[]
        n=copy.deepcopy(m);n.segments.append(Segment('other','DATA',1,0xa9,bytearray(1)));bad.append((n,{'a':(3,100)}))
        n=copy.deepcopy(m);n.segments[0].class_name='CODE';bad.append((n,{'a':(3,100)}))
        n=copy.deepcopy(m);n.fixups=[Fixup(1,0,4,9,False,4,None,0,1,0)];bad.append((n,{'a':(3,100)}))
        bad.extend([(m,{}),(m,{'unknown':(3,100)}),
                    (m,{'a':(3,100),'b':(3,105)}),(m,{'a':(3,1)})])
        for index,(module,anchors) in enumerate(bad):
            with self.subTest(case=index),self.assertRaises(ValueError):
                infer(module,anchors)
