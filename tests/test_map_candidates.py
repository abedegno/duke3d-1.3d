from pathlib import Path
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'profiles/watcom/tools'))
from omf32 import Module,Segment,Fixup
from tools.map_candidates import locate


class CandidateTests(unittest.TestCase):
    def module(self):
        return Module(name='test',segments=[Segment('_TEXT','CODE',8,0x69,
            bytearray(b'AB\0\0\0\0CD'))],publics={'f_':(1,0)},
            fixups=[Fixup(1,2,4,9,False,5,None,2,1,0)])

    def test_relocation_difference_is_candidate_not_proof(self):
        result=locate(self.module(),{1:b'xxAB1234CDyy'},min_anchor=2)
        self.assertEqual(result[0]['locations'],[{'object':1,'offset':2}])
        self.assertEqual(result[0]['status'],'candidate')

    def test_opcode_difference_rejects_candidate(self):
        self.assertEqual(locate(self.module(),{1:b'AB1234CE'},min_anchor=2)[0]['locations'],[])

    def test_duplicate_locations_preserved(self):
        row=locate(self.module(),{1:b'AB1234CDAB5678CD'},min_anchor=2)[0]
        self.assertEqual(row['locations'],[{'object':1,'offset':0},{'object':1,'offset':8}])
        self.assertEqual(row['status'],'ambiguous')

    def test_anchor_cannot_place_function_outside_image(self):
        self.assertEqual(locate(self.module(),{1:b'CD'},min_anchor=2)[0]['locations'],[])

    def test_fully_relocated_function_is_not_a_candidate(self):
        mod=self.module();mod.segments[0].data=bytearray(4);mod.segments[0].size=4
        mod.fixups=[Fixup(1,0,4,9,False,5,None,2,1,0)]
        self.assertEqual(locate(mod,{1:bytes(20)},min_anchor=2)[0]['status'],'insufficient_anchor')
