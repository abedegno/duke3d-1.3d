from pathlib import Path
import tempfile
import unittest
from tools.prove_functions import ROOT, prove


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class EngineSquareRootTests(unittest.TestCase):
    def test_complete_ksqrt_body_and_table_fixups(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove(ROOT/'toolchains/watcom-10.0-ga',Path(directory))
        result=next((r for r in report['results'] if r['symbol']=='ksqrt_'),None)
        self.assertIsNotNone(result,'engine ksqrt proof is missing')
        self.assertIs(result['match'],True)
        self.assertEqual(result['compared_bytes'],54)
        self.assertEqual(result['verified_fixups'],2)
        self.assertFalse(report['full_executable_rebuilt'])
