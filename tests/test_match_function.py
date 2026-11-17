from pathlib import Path
from dataclasses import replace
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT/'exhume/profiles/watcom/tools'),
               str(ROOT/'exhume/profiles/watcom/tests')]
from le import LEImage
from omf32 import Module, Segment, Fixup
from test_le import with_fixups
from tools.match_function import match_function, MatchError, is_alignment_padding


class FunctionMatchTests(unittest.TestCase):
    def test_accepts_observed_486_zero_effect_alignment(self):
        self.assertTrue(is_alignment_padding(bytes.fromhex('8d442000')))
        self.assertTrue(is_alignment_padding(bytes.fromhex('8d80000000008d5200')))
        self.assertTrue(is_alignment_padding(bytes.fromhex('8d80000000008d92000000008bc0')))
        self.assertFalse(is_alignment_padding(bytes.fromhex('8d442001')))
        self.assertFalse(is_alignment_padding(bytes.fromhex('b800000000')))

    def fixture(self):
        image=LEImage.parse(with_fixups(b'\x07\x00\x01\x00\x01\x18\x00'))
        data=bytearray(image.data)
        data[0x440:0x446]=b'\xa1\x18\0\0\0\xc3'
        image=LEImage.parse(bytes(data))
        module=Module(name='test',segments=[Segment('_TEXT','CODE',6,0x69,bytearray(b'\xa1\0\0\0\0\xc3'))],
                      publics={'read_':(1,0)},externals=['_value'],groups=[('FLAT',())],
                      fixups=[Fixup(1,1,4,9,False,1,1,2,1,0)])
        return module,image

    def test_resolves_symbol_and_verifies_le_fixup(self):
        module,image=self.fixture()
        r=match_function(module,'read_',image,1,0,6,{'_value':(1,24)})
        self.assertTrue(r['match'])
        self.assertEqual(r['verified_fixups'],1)
        self.assertEqual(r['compared_bytes'],6)

    def test_accepts_explicit_frame_identical_to_target_index_only(self):
        module,image=self.fixture()
        original=module.fixups[0]
        module.fixups[0]=replace(original,frame_method=2,frame=1)
        self.assertTrue(match_function(module,'read_',image,1,0,6,
                                       {'_value':(1,24)})['match'])
        module.segments.append(Segment('_DATA','DATA',4,0xa9,bytearray(4)))
        module.externals.append('_other')
        module.fixups[0]=replace(original,frame_method=0,frame=2,target_method=0,target=2)
        self.assertTrue(match_function(module,'read_',image,1,0,6,{},
                                       {2:(1,24)})['match'])
        for fix in [replace(original,frame_method=2,frame=2),
                    replace(original,frame_method=0,frame=1),
                    replace(module.fixups[0],frame=1)]:
            module.fixups[0]=fix
            with self.subTest(frame=fix),self.assertRaisesRegex(MatchError,'frame'):
                match_function(module,'read_',image,1,0,6,{'_value':(1,24)},
                               {2:(1,24)})

    def test_wrong_symbol_target_is_not_hidden_by_mask(self):
        module,image=self.fixture()
        with self.assertRaisesRegex(MatchError,'target'):
            match_function(module,'read_',image,1,0,6,{'_value':(1,25)})

    def test_unaccounted_target_fixup_fails_even_when_bytes_match(self):
        module,image=self.fixture()
        module.fixups=[]
        module.segments[0].data[:]=b'\xa1\x18\0\0\0\xc3'
        with self.assertRaisesRegex(MatchError,'unaccounted'):
            match_function(module,'read_',image,1,0,6,{})

    def test_real_opcode_difference_is_reported(self):
        module,image=self.fixture()
        module.segments[0].data[0]=0xa3
        r=match_function(module,'read_',image,1,0,6,{'_value':(1,24)})
        self.assertFalse(r['match'])
        self.assertEqual(r['differing_offsets'],[0])

    def test_relative_call_resolved_without_loader_fixup(self):
        module,image=self.fixture()
        from test_le import fixture
        data=fixture();data[0x440:0x446]=b'\xe8\x13\0\0\0\xc3'
        image=LEImage.parse(bytes(data))
        module.segments[0].data[:]=b'\xe8\0\0\0\0\xc3'
        module.fixups[0]=Fixup(1,1,4,9,True,1,1,2,1,0)
        r=match_function(module,'read_',image,1,0,6,{'_value':(1,24)})
        self.assertTrue(r['match'])

    def test_matching_prefix_does_not_prove_complete_function(self):
        module,image=self.fixture()
        module.publics['next_']=(1,5)
        with self.assertRaisesRegex(MatchError,'extent'):
            match_function(module,'read_',image,1,0,1,{})

    def test_range_cannot_cross_next_public(self):
        module,image=self.fixture()
        module.publics['next_']=(1,5)
        with self.assertRaisesRegex(MatchError,'extent'):
            match_function(module,'read_',image,1,0,6,{'_value':(1,24)})

    def test_negative_addend_wraps_as_32_bit_relocation(self):
        module,image=self.fixture()
        from test_le import fixture
        data=fixture();data[0x440:0x446]=b'\xe8\x07\0\0\0\xc3'
        image=LEImage.parse(bytes(data))
        module.segments[0].data[:]=b'\xe8\xfc\xff\xff\xff\xc3'
        module.fixups[0]=Fixup(1,1,4,9,True,1,1,2,1,0)
        self.assertTrue(match_function(module,'read_',image,1,0,6,{'_value':(1,16)})['match'])

    def test_duplicate_fixup_rejected(self):
        module,image=self.fixture();module.fixups.append(module.fixups[0])
        with self.assertRaisesRegex(MatchError,'overlap'):
            match_function(module,'read_',image,1,0,6,{'_value':(1,24)})


if __name__=='__main__':
    unittest.main()
