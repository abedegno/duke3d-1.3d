"""Prove debug-built GUS runtime contributions without counting debug metadata."""
from pathlib import Path
import copy
from dataclasses import replace
import tempfile
import unittest

from tools.prove_module import ROOT,prove,Module,LEImage
from tools.verify_module import verify_module,ModuleError
from tools.object_contributions import without_watcom_debug


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0b/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class GusRecoveryTests(unittest.TestCase):
    def test_complete_debug_built_gus_contributions(self):
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for name,init,bss,fixups,debug_bytes,debug_fixups in [
                ('gus',1057,16,65,1499,8),('gusmidi',2227,14928,125,2764,11)]:
            with self.subTest(module=name),tempfile.TemporaryDirectory() as directory:
                report=prove(name,ROOT/'toolchains/watcom-10.0b',Path(directory))
                raw=Module.parse((Path(directory)/(name+'.obj')).read_bytes())
                module,excluded=without_watcom_debug(raw)
                v=report['verification']
                self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],
                                  v['verified_fixups']),(init,bss,fixups))
                self.assertEqual(sum(s['bytes'] for s in excluded),debug_bytes)
                self.assertEqual(sum(s['fixups'] for s in excluded),debug_fixups)
                self.assertEqual(report['debug_metadata']['excluded_segments'],excluded)
                self.assertIn('/d2',report['options'])
                self.assertTrue(raw.line_numbers)
                self.assertFalse(report['full_executable_rebuilt'])
                # The full raw object must never pass by silently ignoring its
                # debug segments inside the byte verifier itself.
                with self.assertRaises(ModuleError):
                    verify_module(raw,image,report['placements'],v['publics'])
                for index,s in enumerate(module.segments):
                    if not s.size:
                        continue
                    damaged=copy.deepcopy(module)
                    damaged.segments[index].data[-1]^=1
                    with self.subTest(segment=s.name),self.assertRaises(ModuleError):
                        verify_module(damaged,image,report['placements'],v['publics'])
                damaged=copy.deepcopy(module)
                damaged.fixups[0]=replace(damaged.fixups[0],
                                         displacement=damaged.fixups[0].displacement+1)
                with self.assertRaises(ModuleError):
                    verify_module(damaged,image,report['placements'],v['publics'])
