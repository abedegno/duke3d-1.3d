from pathlib import Path
import copy
from dataclasses import replace
import tempfile
import unittest

from tools.prove_module import ROOT,prove,Module,LEImage
from tools.verify_module import verify_module,ModuleError


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/masm-5.10/MASM.EXE').is_file(),
                     'private target and MASM 5.10 required')
class EngineAssemblyRecoveryTests(unittest.TestCase):
    def test_complete_native_masm_engine_contribution(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('engine_asm',ROOT/'toolchains/masm-5.10',Path(directory))
            m=Module.parse((Path(directory)/'engine_asm.obj').read_bytes())
        v=report['verification']
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],
                          v['verified_fixups']),(5913,0,443))
        self.assertEqual(v['publics']['sethlinesizes_'],(1,626432))
        self.assertEqual(sum(s.size>0 for s in m.segments),1)
        self.assertEqual(len(m.publics),43)
        self.assertTrue(all(f.frame_method in (0,2) and
                            f.frame_method==f.target_method and f.frame==f.target
                            for f in m.fixups))
        self.assertFalse(report['full_executable_rebuilt'])
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        variants=[]
        damaged=copy.deepcopy(m);damaged.segments[0].data[-1]^=1;variants.append(damaged)
        damaged=copy.deepcopy(m);damaged.fixups[0]=replace(damaged.fixups[0],displacement=m.fixups[0].displacement+1);variants.append(damaged)
        damaged=copy.deepcopy(m);damaged.fixups[0]=replace(damaged.fixups[0],frame_method=2,frame=1);variants.append(damaged)
        for index,damaged in enumerate(variants):
            with self.subTest(corruption=index),self.assertRaises(ModuleError):
                verify_module(damaged,image,report['placements'],v['publics'])
