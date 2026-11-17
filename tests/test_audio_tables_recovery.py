from pathlib import Path
import tempfile
import unittest

from tools.prove_module import ROOT,prove,Module,LEImage
from tools.verify_module import verify_module,ModuleError


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0b/BINB/wcc386.exe').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and compiler required')
class AudioTableRecoveryTests(unittest.TestCase):
    def test_complete_user_and_instrument_table(self):
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for name,home,size,fixups in [('user','10.0b',195,9),('gmtimbre','10.0-ga',3328,0)]:
            with self.subTest(module=name),tempfile.TemporaryDirectory() as directory:
                report=prove(name,ROOT/'toolchains'/('watcom-'+home),Path(directory))
                m=Module.parse((Path(directory)/(name+'.obj')).read_bytes());v=report['verification']
                self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],
                                  v['verified_fixups']),(size,0,fixups))
                if name=='gmtimbre':
                    self.assertEqual(v['publics']['_ADLIB_TimbreBank'],(3,64456))
                    self.assertFalse(any(s.size for s in m.segments if s.class_name=='CODE'))
                else:
                    self.assertEqual(v['publics']['USER_CheckParameter_'],(1,475120))
                    self.assertEqual(v['publics']['USER_GetText_'],(1,475216))
                self.assertFalse(report['full_executable_rebuilt'])
                for segment in m.segments:
                    if segment.size:
                        segment.data[-1]^=1
                        break
                with self.assertRaises(ModuleError):
                    verify_module(m,image,report['placements'],v['publics'])
