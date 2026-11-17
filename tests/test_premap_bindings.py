"""Individually matching functions must still share one external address map."""
from dataclasses import replace
from pathlib import Path
import sys
import unittest
from tools.probe_premap import check_source_interval,check_intervals,Module,LEImage
from tools.infer_bindings import BindingError
from omf32 import Segment,Fixup
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'profiles/watcom/tests'))
from test_le import with_fixups


class PremapBindingTests(unittest.TestCase):
    def fixture(self,second=24):
        records=b'\x07\0\x01\0\x01\x14\0'+b'\x07\0\x09\0\x01'+second.to_bytes(2,'little')
        data=bytearray(with_fixups(records))
        function=lambda address:b'\xa1'+address.to_bytes(4,'little')+b'\xc3\x90\x90'
        data[0x440:0x450]=function(20)+function(second)
        image=LEImage.parse(bytes(data))
        module=Module(segments=[Segment('_TEXT','CODE',16,0x69,bytearray(function(0)*2))],
                      publics={'first_':(1,0),'second_':(1,8)},externals=['_shared'],
                      groups=[('FLAT',())],
                      fixups=[Fixup(1,off,4,9,False,1,1,2,1,0) for off in [1,9]])
        return module,image,{'first_':(0,8),'second_':(8,8)}

    def test_rejects_individual_matches_that_require_conflicting_globals(self):
        module,image,definitions=self.fixture()
        # Both ranges really match, but only under incompatible address maps.
        for name,(target,size) in definitions.items():
            self.assertTrue(check_source_interval(module,image,name,target,size,{})['comparison']['match'])
        with self.assertRaisesRegex(BindingError,'conflicting.*_shared'):
            check_intervals(module,image,definitions,{})

    def test_rejects_conflicting_unnamed_data_segment_placements(self):
        module,image,definitions=self.fixture()
        module.externals=[]
        module.segments.append(Segment('CONST','DATA',4,0x29,bytearray(b'DATA')))
        module.fixups=[replace(f,target_method=0,target=2) for f in module.fixups]
        for name,(target,size) in definitions.items():
            self.assertTrue(check_source_interval(module,image,name,target,size,{})['comparison']['match'])
        with self.assertRaisesRegex(BindingError,'conflicting.*segment'):
            check_intervals(module,image,definitions,{})
        module,image,definitions=self.fixture(20)
        module.externals=[]
        module.segments.append(Segment('CONST','DATA',4,0x29,bytearray(b'DATA')))
        module.fixups=[replace(f,target_method=0,target=2) for f in module.fixups]
        self.assertEqual(len(check_intervals(module,image,definitions,{})),2)

    def test_owned_data_publics_share_one_segment_even_with_external_fixups(self):
        def fixture(second):
            module,image,definitions=self.fixture(second)
            module.segments.append(Segment('_DATA','DATA',8,0x29,bytearray(8)))
            module.publics.update({'_a':(2,0),'_b':(2,4)})
            module.externals=['_a','_b']
            module.fixups[1]=replace(module.fixups[1],target=2)
            return module,image,definitions
        module,image,definitions=fixture(28)
        for name,(target,size) in definitions.items():
            self.assertTrue(check_source_interval(module,image,name,target,size,{})['comparison']['match'])
        with self.assertRaisesRegex(BindingError,'conflicting'):
            check_intervals(module,image,definitions,{})
        module,image,definitions=fixture(24)
        rows=check_intervals(module,image,definitions,{})
        self.assertEqual(len(rows),2)
        self.assertTrue(all(r['placements'][2]==(1,20) for r in rows))

    def test_agreement_and_independent_anchor_are_retained(self):
        module,image,definitions=self.fixture(20)
        known={'_shared':(1,20)}
        rows=check_intervals(module,image,definitions,known)
        self.assertEqual(len(rows),2)
        self.assertTrue(all(r['comparison']['match'] for r in rows))
        self.assertEqual(known,{'_shared':(1,20)})
        with self.assertRaisesRegex(BindingError,'conflicting.*_shared'):
            check_intervals(module,image,definitions,{'_shared':(1,24)})
