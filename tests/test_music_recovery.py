from pathlib import Path
import copy
import tempfile
import unittest

from tools.prove_module import ROOT, prove, Module, LEImage
from tools.verify_module import verify_module, ModuleError


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0b/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class MusicRecoveryTests(unittest.TestCase):
    def test_complete_music_contribution(self):
        with tempfile.TemporaryDirectory() as directory:
            report = prove('music', ROOT/'toolchains/watcom-10.0b', Path(directory))
            module = Module.parse((Path(directory)/'music.obj').read_bytes())
        verification = report['verification']
        self.assertIs(verification['verified'], True)
        self.assertEqual((verification['initialized_bytes'],verification['zero_fill_bytes'],
                          verification['verified_fixups']), (2147,64,204))
        self.assertEqual(verification['publics']['MUSIC_ErrorString_'], (1,490486))
        self.assertEqual(verification['publics']['MUSIC_Init_'], (1,490648))
        self.assertEqual(verification['publics']['_MUSIC_MidiFunctions'], (3,1743304))
        self.assertEqual(verification['publics']['_MUSIC_EndingFadeVolume'], (3,1743288))
        self.assertEqual(verification['publics']['_MUSIC_FadeLength'], (3,1743348))
        self.assertFalse(report['full_executable_rebuilt'])

        image = LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for segment_name,offset in [('CONST',10),('_BSS',63)]:
            damaged = copy.deepcopy(module)
            segment = next(s for s in damaged.segments if s.name == segment_name and s.size)
            segment.data[offset] ^= 1
            with self.subTest(segment=segment_name), self.assertRaises(ModuleError):
                verify_module(damaged,image,report['placements'],verification['publics'])
