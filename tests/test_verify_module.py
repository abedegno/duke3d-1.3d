from pathlib import Path
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT/'profiles/watcom/tools'),str(ROOT/'profiles/watcom/tests')]
from le import LEImage
from omf32 import Module,Segment,Fixup
from test_le import with_fixups
from tools.verify_module import verify_module, ModuleError, external_anchor_bindings


class ModuleProofTests(unittest.TestCase):
    def fixture(self):
        data=bytearray(with_fixups(b'\x07\0\x01\0\x01\x08\0'))
        data[0x440:0x446]=b'\xa1\x08\0\0\0\xc3'
        data[0x448:0x44c]=b'ABCD'
        image=LEImage.parse(bytes(data))
        mod=Module(name='test',segments=[
            Segment('_TEXT','CODE',6,0x69,bytearray(b'\xa1\0\0\0\0\xc3')),
            Segment('_DATA','DATA',4,0xa9,bytearray(b'ABCD')),
            Segment('_BSS','BSS',4,0xa9,bytearray(4))],
            publics={'read_':(1,0),'_value':(2,0),'_buffer':(3,0)},
            externals=['_value'],groups=[('FLAT',())],
            fixups=[Fixup(1,1,4,9,False,1,1,2,1,0)])
        return mod,image,{1:(1,0),2:(1,8),3:(1,24)}

    def test_accounts_for_all_code_data_and_bss(self):
        mod,image,places=self.fixture()
        report=verify_module(mod,image,places,{})
        self.assertTrue(report['verified'])
        self.assertEqual(report['initialized_bytes'],10)
        self.assertEqual(report['zero_fill_bytes'],4)
        self.assertEqual(report['verified_fixups'],1)

    def test_private_symbols_still_proved_but_not_cross_module_anchors(self):
        mod,image,places=self.fixture()
        mod.local_publics={'_buffer'}
        mod.externals.append('private_reference')
        mod.local_externals={2}
        report=verify_module(mod,image,places,{'private_reference':(1,0)})
        self.assertEqual(report['local_symbols'],{'_buffer':(1,24),'private_reference':(1,0)})
        shared=external_anchor_bindings(report)
        self.assertNotIn('_buffer',shared)
        self.assertNotIn('private_reference',shared)
        self.assertEqual(shared['_value'],(1,8))
        self.assertEqual(report['zero_fill_bytes'],4)
        damaged=dict(report);damaged['local_symbols']={'_buffer':(1,25)}
        with self.assertRaisesRegex(ValueError,'scope'):
            external_anchor_bindings(damaged)
        damaged=dict(report);del damaged['local_symbols']
        with self.assertRaisesRegex(ValueError,'scope'):
            external_anchor_bindings(damaged)

    def test_changed_initialized_data_fails(self):
        mod,image,places=self.fixture();mod.segments[1].data[0]=0
        with self.assertRaises(ModuleError):verify_module(mod,image,places,{})

    def test_unplaced_nonempty_segment_fails(self):
        mod,image,places=self.fixture();del places[3]
        with self.assertRaises(ModuleError):verify_module(mod,image,places,{})

    def test_nonzero_target_bss_fails(self):
        mod,image,places=self.fixture();places[3]=(1,12)
        with self.assertRaises(ModuleError):verify_module(mod,image,places,{})

    def test_conflicting_public_binding_fails(self):
        mod,image,places=self.fixture()
        with self.assertRaises(ModuleError):verify_module(mod,image,places,{'_value':(1,9)})

    def test_overlapping_segment_placements_fail(self):
        mod,image,places=self.fixture();places[3]=(1,8)
        with self.assertRaises(ModuleError):verify_module(mod,image,places,{})

    def test_file_backed_zeros_do_not_prove_bss_ownership(self):
        mod,image,places=self.fixture()
        raw=bytearray(image.data);raw[0x44c:0x450]=bytes(4)
        image=LEImage.parse(bytes(raw));places[3]=(1,12)
        with self.assertRaisesRegex(ModuleError,'backing'):
            verify_module(mod,image,places,{})

    def test_segment_alignment_is_enforced(self):
        mod,image,places=self.fixture();places[3]=(1,21)
        with self.assertRaisesRegex(ModuleError,'alignment'):
            verify_module(mod,image,places,{})
