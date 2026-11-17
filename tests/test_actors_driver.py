"""The standard module driver must verify both complete ACTORS producers."""
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools')]
from tools.prove_module import prove


class ActorsDriverTests(unittest.TestCase):
    def test_standard_route_rebuilds_complete_contributions_in_reusable_directory(self):
        with tempfile.TemporaryDirectory(prefix='actors-driver-', dir=ROOT/'build') as temporary:
            try:
                report = prove('actors', ROOT/'toolchains/watcom-10.0-ga', Path(temporary)/'native')
            except (ValueError, KeyError) as error:
                self.fail('complete ACTORS standard route unavailable: '+str(error))
            try:
                repeated = prove('actors', ROOT/'toolchains/watcom-10.0-ga', Path(temporary)/'native')
            except FileExistsError:
                self.fail('standard ACTORS route cannot reuse its build directory')
            self.assertEqual(report['verification'], repeated['verification'])
            self.assertEqual(report['functions'], repeated['functions'])
            stages = [Path(r['native_build_directory']) for r in (report, repeated)]
            self.assertNotEqual(*stages)
            for stage in stages:
                for name in ('actors_c.obj', 'actors_asm.obj'):
                    self.assertTrue((stage/name).is_file())
        proof = report['verification']
        self.assertTrue(proof['verified'])
        self.assertEqual((proof['initialized_bytes'], proof['zero_fill_bytes'],
                          proof['verified_fixups']), (61741,6,2812))
        self.assertEqual(set(proof['components']), {'actors_c', 'actors_asm'})
        self.assertEqual(len(report['functions']), 37)
        self.assertTrue(proof['complete_emitted_union_verified'])
        self.assertFalse(report['full_executable_rebuilt'])


if __name__ == '__main__':
    unittest.main()
