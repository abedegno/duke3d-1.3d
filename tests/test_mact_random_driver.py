"""Standard RNG dispatch retains the complete owned producer contract."""
from pathlib import Path
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from tools.prove_module import prove
from tools.verify_module import external_anchor_bindings


class MactRandomDriverTests(unittest.TestCase):
    def test_standard_route_rebuilds_whole_rng_with_private_indices(self):
        with tempfile.TemporaryDirectory(prefix='rng-driver-',dir=ROOT/'build') as temporary:
            try:
                first=prove('mact_random',ROOT/'toolchains/watcom-10.0-ga',Path(temporary))
            except ValueError as error:
                self.fail('standard complete RNG route unavailable: '+str(error))
            second=prove('mact_random',ROOT/'toolchains/watcom-10.0-ga',Path(temporary))
            self.assertEqual(first['verification'],second['verification'])
        proof=first['verification']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],
                          proof['verified_fixups']),(2279,4,13))
        self.assertEqual(set(proof['local_symbols']),{'_rndindex','_sndindex'})
        exports=external_anchor_bindings(proof)
        self.assertNotIn('_rndindex',exports)
        self.assertNotIn('_sndindex',exports)
        self.assertEqual(exports['_RandomTable'],(3,68356))
        self.assertFalse(first['full_executable_rebuilt'])


if __name__=='__main__':unittest.main()
