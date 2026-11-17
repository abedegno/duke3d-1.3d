"""Prove entire assembly contributions with the real historical assembler."""
from pathlib import Path
import copy
from dataclasses import replace
import tempfile
import unittest

from tools.prove_module import ROOT,prove,Module,LEImage
from tools.verify_module import verify_module,ModuleError


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/tasm-3.1/TASM.EXE').is_file(),
                     'private target and historical assembler required')
class AudioAssemblyRecoveryTests(unittest.TestCase):
    def test_complete_mixer_and_reverb_contributions(self):
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for name,size,fixups,symbol,offset in [
                ('mv_mix',901,56,'MV_Mix8BitMono_',493376),
                ('mv_mix16',971,57,'MV_Mix8BitMono16_',492404),
                ('mvreverb',151,2,'MV_16BitReverb_',492252)]:
            with self.subTest(module=name),tempfile.TemporaryDirectory() as directory:
                report=prove(name,ROOT/'toolchains/tasm-3.1',Path(directory))
                module=Module.parse((Path(directory)/(name+'.obj')).read_bytes())
                v=report['verification']
                self.assertTrue(v['verified'])
                self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],
                                  v['verified_fixups']),(size,0,fixups))
                self.assertEqual(v['publics'][symbol],(1,offset))
                self.assertEqual(report['assembler_sha256'],
                    '80534cd6a1e2c2b4376ae3f21954c6dbfa77a6998d5e0bf8b8bee6153f3174ea')
                self.assertFalse(report['full_executable_rebuilt'])
                for index,s in enumerate(module.segments):
                    if not s.size:
                        continue
                    damaged=copy.deepcopy(module)
                    damaged.segments[index].data[-1]^=1
                    with self.assertRaises(ModuleError):
                        verify_module(damaged,image,report['placements'],v['publics'])
                # Relocations, including local self-modifying-code references,
                # must remain checked even when all literal bytes are intact.
                damaged=copy.deepcopy(module)
                damaged.fixups[0]=replace(damaged.fixups[0],
                                         displacement=damaged.fixups[0].displacement+1)
                with self.assertRaises(ModuleError):
                    verify_module(damaged,image,report['placements'],v['publics'])
