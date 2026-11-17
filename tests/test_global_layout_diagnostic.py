from pathlib import Path
import tempfile
import unittest
from tools.probe_game_globals import ROOT,probe,digest


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class GlobalDiagnosticTests(unittest.TestCase):
    def test_native_diagnostic_retains_failed_bytes_and_rejects_bss_layout(self):
        original=ROOT/'reference/duke3d-reconstructions/GLOBAL.C'
        identity=digest(original)
        with tempfile.TemporaryDirectory() as directory:
            build=Path(directory)/'probe'
            report=probe(ROOT/'toolchains/watcom-10.0-ga',build)
            self.assertIn(b'#define MAXSPRITES 4096',(build/'include/build.h').read_bytes())
            self.assertIn('struct weaponhit hittype[2048]',(build/'global.c').read_text())
            with self.assertRaises(FileExistsError):
                probe(ROOT/'toolchains/watcom-10.0-ga',build)
        self.assertEqual(digest(original),identity)
        self.assertEqual(report['data_observation']['size'],64)
        self.assertEqual(report['data_observation']['differing_bytes'],[
            {'offset':38,'source':0,'target':77},
            {'offset':39,'source':0,'target':78}])
        self.assertFalse(report['data_observation']['byte_identical'])
        self.assertFalse(report['full_module_verified'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['new_recovered_contributions'],0)
        bases={tuple(b) for row in report['binding_diagnostics']
               if row['source_segment']==5 for b in row['implied_segment_bases']}
        self.assertGreater(len(bases),1)
