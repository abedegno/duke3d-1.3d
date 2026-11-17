from pathlib import Path
import copy
import tempfile
import unittest

from tools.prove_module import ROOT, prove, Module, LEImage
from tools.verify_module import verify_module, ModuleError


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class FXManagerRecoveryTests(unittest.TestCase):
    def test_complete_fx_manager_contribution(self):
        with tempfile.TemporaryDirectory() as directory:
            report = prove('fx_man', ROOT/'toolchains/watcom-10.0-ga', Path(directory))
            module = Module.parse((Path(directory)/'fx_man.obj').read_bytes())
        verification = report['verification']
        self.assertIs(verification['verified'], True)
        self.assertEqual((verification['initialized_bytes'], verification['zero_fill_bytes'],
                          verification['verified_fixups']), (2847, 4, 228))
        self.assertEqual(verification['publics']['FX_ErrorString_'], (1, 524260))
        self.assertEqual(verification['publics']['FX_StopRecord_'], (1, 526800))
        self.assertEqual(verification['publics']['_FX_MixRate'], (3, 1796160))
        self.assertNotIn('FX_EndLooping_', module.publics)
        self.assertNotIn('MV_EndLooping_', verification['publics'])
        self.assertFalse(report['full_executable_rebuilt'])

        image = LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        damaged = copy.deepcopy(module)
        damaged.segments[0].data[-1] ^= 1
        with self.assertRaises(ModuleError):
            verify_module(damaged, image, report['placements'], verification['publics'])
        wrong_binding = copy.deepcopy(verification['publics'])
        obj,offset = wrong_binding['MV_PlayVOC_']
        wrong_binding['MV_PlayVOC_'] = (obj, offset+1)
        with self.assertRaises(ModuleError):
            verify_module(module, image, report['placements'], wrong_binding)
