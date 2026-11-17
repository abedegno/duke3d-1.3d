"""Registered utilities route retains its standalone whole-source producer."""
from pathlib import Path
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from tools.prove_module import prove
from tools.verify_module import external_anchor_bindings

class MactUtilityDriverTests(unittest.TestCase):
    def test_standard_route_rebuilds_complete_utilities_with_private_state(self):
        with tempfile.TemporaryDirectory(prefix='utility-driver-',dir=ROOT/'build') as directory:
            try:
                first=prove('mact_util',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
            except ValueError as error:
                self.fail('standard complete utility route unavailable: '+str(error))
            second=prove('mact_util',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
            self.assertEqual(first['verification'],second['verification'])
        proof=first['verification']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),
                         (1107,28,61))
        self.assertEqual(len(proof['local_symbols']),6)
        exports=external_anchor_bindings(proof)
        for name in proof['local_symbols']:
            self.assertNotIn(name,exports)
        self.assertFalse(first['original_member_used_by_producer'])
        self.assertFalse(first['full_executable_rebuilt'])

if __name__=='__main__':unittest.main()
