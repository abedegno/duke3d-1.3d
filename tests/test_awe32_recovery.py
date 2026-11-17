from pathlib import Path
import copy
import tempfile
import unittest

from tools.prove_module import ROOT, prove, Module, LEImage
from tools.verify_module import verify_module, ModuleError


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0a/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class AWE32RecoveryTests(unittest.TestCase):
    def test_complete_awe32_contribution(self):
        with tempfile.TemporaryDirectory() as directory:
            report = prove('awe32', ROOT/'toolchains/watcom-10.0a', Path(directory))
            module = Module.parse((Path(directory)/'awe32.obj').read_bytes())
        verification = report['verification']
        self.assertIs(verification['verified'], True)
        self.assertEqual((verification['initialized_bytes'], verification['zero_fill_bytes'],
                          verification['verified_fixups']), (2933, 262, 179))
        self.assertEqual(verification['publics']['InitMPU_'], (1, 536720))
        self.assertEqual(verification['publics']['ShutdownMPU_'], (1, 537304))
        self.assertEqual(verification['publics']['_AWE32_packet_storage'], (3, 62396))
        self.assertEqual(verification['publics']['_lBankSizes'], (3, 62440))
        self.assertEqual(verification['publics']['_NoteFlags'], (3, 1796296))
        self.assertEqual(verification['publics']['_wEMUBaseAddx'], (3, 1796556))
        self.assertFalse(report['full_executable_rebuilt'])

        image = LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        # Both the literal residue and packed-packet alignment remain within
        # the complete contribution gate; neither is masked as padding.
        for segment_name,offset in [('CONST',10),('_DATA',42)]:
            damaged = copy.deepcopy(module)
            segment = next(s for s in damaged.segments if s.name == segment_name and s.size)
            segment.data[offset] ^= 1
            with self.subTest(segment=segment_name), self.assertRaises(ModuleError):
                verify_module(damaged,image,report['placements'],verification['publics'])
