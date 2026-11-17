"""Registered RGB source route retains its complete C/ASM scope and storage."""
from pathlib import Path
import sys
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from tools.prove_module import prove
from tools.verify_module import external_anchor_bindings

class RGBDriverTests(unittest.TestCase):
    def test_repeated_standard_route_keeps_fresh_objects_and_private_scope(self):
        with tempfile.TemporaryDirectory(prefix='rgb-driver-',dir=ROOT/'build') as directory:
            try:
                first=prove('mact_rgb',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
            except ValueError as error:
                self.fail('registered complete RGB route unavailable: '+str(error))
            second=prove('mact_rgb',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
            self.assertEqual(first['verification'],second['verification'])
            self.assertNotEqual(first['actual_build_directory'],second['actual_build_directory'])
            for report in (first,second):self.assertTrue(Path(report['actual_build_directory']).is_dir())
        proof=first['verification']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),
                         (795,265232,23))
        private=proof['components']['rgb_c']['local_symbols']
        self.assertEqual(len(private),6)
        self.assertEqual(proof['local_symbols'],{})
        exports=external_anchor_bindings(proof)
        self.assertEqual(len(first['global_exports']),6)
        self.assertTrue(set(first['global_exports'])<=set(exports))
        for name in private:self.assertNotIn(name,exports)
        self.assertEqual(tuple(exports['RGB_MakeColorTable_']),(1,564468))
        self.assertFalse(first['full_executable_rebuilt'])
if __name__=='__main__':unittest.main()
