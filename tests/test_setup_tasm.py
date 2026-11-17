"""Replay checksum-gated extraction without executing the historical installer."""
from pathlib import Path
import hashlib
import importlib
import tempfile
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]
ARCHIVE=ROOT/'toolchains/archives/borland-cpp-3.1.7z'


class TasmSetupTests(unittest.TestCase):
    def test_wrong_archive_never_publishes(self):
        setup=importlib.import_module('tools.setup_tasm')
        with tempfile.TemporaryDirectory() as directory:
            work=Path(directory);archive=work/'wrong.7z';archive.write_bytes(b'invalid')
            with self.assertRaisesRegex(ValueError,'archive identity'):
                setup.prepare(archive,work/'home')
            self.assertFalse((work/'home').exists())

    @unittest.skipUnless(ARCHIVE.is_file(),'private Borland media archive required')
    def test_real_extraction_and_existing_destination_preservation(self):
        setup=importlib.import_module('tools.setup_tasm')
        before=hashlib.sha256(ARCHIVE.read_bytes()).hexdigest()
        with tempfile.TemporaryDirectory() as directory:
            home=Path(directory)/'home';report=setup.prepare(ARCHIVE,home)
            self.assertEqual(report['tools']['TASM.EXE']['sha256'],
                '80534cd6a1e2c2b4376ae3f21954c6dbfa77a6998d5e0bf8b8bee6153f3174ea')
            self.assertEqual(set(p.name for p in home.iterdir()),{'TASM.EXE','TASMX.EXE'})
            for name,entry in report['tools'].items():
                self.assertEqual(hashlib.sha256((home/name).read_bytes()).hexdigest(),entry['sha256'])
            (home/'sentinel').write_text('keep')
            with self.assertRaises(FileExistsError):
                setup.prepare(ARCHIVE,home)
            self.assertEqual((home/'sentinel').read_text(),'keep')
            rejected=Path(directory)/'rejected'
            with patch.dict(setup.TOOLS,{'TASM.EXE':'0'*64}):
                with self.assertRaisesRegex(ValueError,'executable identity'):
                    setup.prepare(ARCHIVE,rejected)
            self.assertFalse(rejected.exists())
        self.assertEqual(hashlib.sha256(ARCHIVE.read_bytes()).hexdigest(),before)
