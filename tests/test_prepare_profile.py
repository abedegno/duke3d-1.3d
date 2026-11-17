from pathlib import Path
import tempfile
import unittest

from tools.prepare_profile import prepare_profile


class PrepareProfileTests(unittest.TestCase):
    def test_links_tracked_overlay_and_is_repeatable(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            (root/'profiles/watcom').mkdir(parents=True)
            (root/'profiles/watcom/proof').write_text('tracked')
            (root/'exhume/profiles').mkdir(parents=True)
            prepare_profile(root)
            prepare_profile(root)
            self.assertEqual((root/'exhume/profiles/watcom/proof').read_text(),'tracked')
            self.assertTrue((root/'exhume/profiles/watcom').is_symlink())

    def test_refuses_to_replace_existing_profile(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            (root/'profiles/watcom').mkdir(parents=True)
            existing=root/'exhume/profiles/watcom'
            existing.mkdir(parents=True)
            (existing/'keep').write_text('original')
            with self.assertRaises(FileExistsError):
                prepare_profile(root)
            self.assertEqual((existing/'keep').read_text(),'original')
