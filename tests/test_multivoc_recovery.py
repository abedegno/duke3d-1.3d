from pathlib import Path
import copy
import tempfile
import unittest

from tools.prove_module import ROOT, prove, Module, LEImage
from tools.verify_module import verify_module, ModuleError


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0b/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class MultiVocRecoveryTests(unittest.TestCase):
    def test_complete_multivoc_contribution(self):
        with tempfile.TemporaryDirectory() as directory:
            report = prove('multivoc', ROOT/'toolchains/watcom-10.0b', Path(directory))
            module = Module.parse((Path(directory)/'multivoc.obj').read_bytes())
        verification = report['verification']
        self.assertIs(verification['verified'], True)
        self.assertEqual((verification['initialized_bytes'],verification['zero_fill_bytes'],
                          verification['verified_fixups']), (12191,37060,815))
        self.assertEqual(verification['publics']['MV_ErrorString_'], (1,494361))
        self.assertEqual(verification['publics']['MV_Init_'], (1,503023))
        self.assertEqual(verification['publics']['MV_PlayVOC_'], (1,501909))
        self.assertEqual(verification['publics']['_MV_VolumeTable'], (3,1747512))
        self.assertFalse(report['full_executable_rebuilt'])

        image = LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for segment_name in ['_TEXT','_BSS']:
            damaged = copy.deepcopy(module)
            segment = next(s for s in damaged.segments if s.name == segment_name and s.size)
            segment.data[-1] ^= 1
            with self.subTest(segment=segment_name), self.assertRaises(ModuleError):
                verify_module(damaged,image,report['placements'],verification['publics'])
