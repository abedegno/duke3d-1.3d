import hashlib
from pathlib import Path
import tempfile
import unittest

from tools.preserve import write_verified


class PreserveTests(unittest.TestCase):
    def test_validates_before_writing(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'target.exe'
            with self.assertRaises(ValueError):
                write_verified(b'bad input', output, '0' * 64)
            self.assertFalse(output.exists())

    def test_refuses_to_replace_different_existing_file(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'target.exe'
            output.write_bytes(b'keep me')
            with self.assertRaises(FileExistsError):
                write_verified(b'new', output, hashlib.sha256(b'new').hexdigest())
            self.assertEqual(output.read_bytes(), b'keep me')

    def test_writes_valid_input_and_accepts_identical_rerun(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'private' / 'target.exe'
            for _ in range(2):
                write_verified(b'known', output, hashlib.sha256(b'known').hexdigest())
            self.assertEqual(output.read_bytes(), b'known')
