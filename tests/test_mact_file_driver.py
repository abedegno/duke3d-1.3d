"""Registered file utilities rebuild complete code and tracked filename state."""
from pathlib import Path
import sys
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from tools.prove_module import prove
from tools.verify_module import external_anchor_bindings

class MactFileDriverTests(unittest.TestCase):
    def test_registered_file_library_rebuilds_with_private_filename_state(self):
        with tempfile.TemporaryDirectory(prefix='file-driver-',dir=ROOT/'build') as directory:
            try:
                first=prove('mact_file',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
            except ValueError as error:
                self.fail('registered complete file route unavailable: '+str(error))
            second=prove('mact_file',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
            self.assertEqual(first['verification'],second['verification'])
        proof=first['verification']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),
                         (2217,0,70))
        self.assertIn('_FileNames',proof['local_symbols'])
        self.assertNotIn('_FileNames',external_anchor_bindings(proof))
        self.assertFalse(first['full_executable_rebuilt'])
if __name__=='__main__':unittest.main()
