"""Native linker experiment: segment order, alignment, and layout controls."""
import json
from pathlib import Path
import shutil
import tempfile
import unittest

from tools.probe_bss_order import probe

ROOT=Path(__file__).resolve().parents[1]


class BSSOrderTests(unittest.TestCase):
    @unittest.skipUnless(
        (ROOT/'toolchains/watcom-10.0-ga/BIN/wlink.exe').is_file()
        and (ROOT/'toolchains/masm-5.10/MASM.EXE').is_file()
        and shutil.which('dosbox-x'), 'private native linker/assembler inputs unavailable')
    def test_native_segment_order_alignment_and_reverse_controls(self):
        with tempfile.TemporaryDirectory(prefix='bss-order-') as temporary:
            report=probe(ROOT/'toolchains/watcom-10.0-ga',
                         ROOT/'toolchains/masm-5.10',Path(temporary)/'native')
        self.assertEqual(report['link_response_order'],
                         ['menues','player','premap','sector','sounds'])
        self.assertEqual(report['experiments']['paragraph']['public_offsets'],
                         {'player_state':0,'premap_state':32,'sector_state':48})
        self.assertEqual(report['experiments']['dword']['public_offsets'],
                         {'player_state':0,'premap_state':20,'sector_state':24})
        self.assertEqual(report['experiments']['reverse']['public_offsets'],
                         {'sector_state':0,'premap_state':16,'player_state':32})
        for name,case in report['experiments'].items():
            self.assertEqual(case['warning_codes'],[1014,1023])
            self.assertEqual(case['segment_bytes'],{'player':18,'premap':4,'sector':5})
            self.assertEqual(case['segment_attributes'],
                             {'player':0xa9,'premap':0xa9,'sector':0xa9}
                             if name=='dword' else
                             {'player':0x69,'premap':0x69,'sector':0x69})
            self.assertEqual(len(case['source_sha256']),3)
        self.assertFalse(report['target_bss_ownership_verified'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['new_complete_contributions'],0)
        json.dumps(report)
