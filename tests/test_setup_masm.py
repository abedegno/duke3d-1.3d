import hashlib
import importlib
from pathlib import Path
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
BINARY=ROOT/'toolchains/archives/masm-5.10-msdos4.exe'


class MasmSetupTests(unittest.TestCase):
    def test_wrong_binary_never_publishes(self):
        setup=importlib.import_module('tools.setup_masm')
        with tempfile.TemporaryDirectory() as directory:
            work=Path(directory);source=work/'bad.exe';source.write_bytes(b'bad')
            with self.assertRaisesRegex(ValueError,'identity'):
                setup.prepare(source,work/'home')
            self.assertFalse((work/'home').exists())

    @unittest.skipUnless(BINARY.is_file(),'private MASM tool download required')
    def test_real_setup_and_existing_destination_preservation(self):
        setup=importlib.import_module('tools.setup_masm')
        original=BINARY.read_bytes()
        with tempfile.TemporaryDirectory() as directory:
            home=Path(directory)/'home';report=setup.prepare(BINARY,home)
            self.assertEqual((home/'MASM.EXE').read_bytes(),original)
            self.assertEqual(report['tools']['MASM.EXE']['sha256'],
                             hashlib.sha256(original).hexdigest())
            (home/'sentinel').write_text('keep')
            with self.assertRaises(FileExistsError):
                setup.prepare(BINARY,home)
            self.assertEqual((home/'sentinel').read_text(),'keep')
        self.assertEqual(BINARY.read_bytes(),original)
