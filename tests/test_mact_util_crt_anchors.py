"""Every real utility import must have complete independent native evidence."""
from pathlib import Path
import json
import sys
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from tools.probe_mact_util import probe

class UtilityCRTAnchorsTests(unittest.TestCase):
    def test_all_imports_are_independently_verified_including_varargs_and_reallocation(self):
        with tempfile.TemporaryDirectory(prefix='utility-crt-',dir=ROOT/'build') as directory:
            report=probe(ROOT/'toolchains/watcom-10.0-ga',Path(directory))
        geometry=report['source_geometry']
        imports={name for index,name in enumerate(geometry['externals'],1)
                 if index not in geometry['local_externals'] and name not in geometry['publics']}
        self.assertEqual(set(report['independently_anchored_imports']),imports)
        self.assertEqual(report['selected_member_call_nominations'],{})
        witnesses=report['independent_anchor_verifications']
        for member,symbol,size,fixups,offset in (
            ('vprintf','vprintf_',17,2,591233),
            ('nrealloc','realloc_',158,9,591259)):
            proof=witnesses[member]['verification']
            self.assertTrue(proof['verified'])
            self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],
                              proof['verified_fixups']),(size,0,fixups))
            self.assertEqual(tuple(proof['publics'][symbol]),(1,offset))
        self.assertFalse(report['full_executable_rebuilt'])
if __name__=='__main__':unittest.main()
