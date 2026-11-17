from pathlib import Path
import tempfile
import unittest
import zipfile

from tools.setup_watcom import extract_zip_tree, install


class SetupTests(unittest.TestCase):
    def test_archive_hash_mismatch_creates_no_home(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory); archive=root/'bad.zip'; archive.write_bytes(b'wrong')
            with self.assertRaisesRegex(ValueError,'SHA-256'):
                install('10.0-ga',archive,root/'home')
            self.assertFalse((root/'home').exists())

    def test_zip_traversal_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory); archive=root/'bad.zip'
            with zipfile.ZipFile(archive,'w') as z:
                z.writestr('BIN/../../escape',b'bad')
            with self.assertRaises(ValueError):
                extract_zip_tree(archive,root/'home')
            self.assertFalse((root/'escape').exists())

    def test_extracts_only_build_components(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory); archive=root/'test.zip'; home=root/'home'
            with zipfile.ZipFile(archive,'w') as z:
                z.writestr('BINB/WCC386.EXE',b'compiler')
                z.writestr('H/STDIO.H',b'header')
                z.writestr('SAMPLES/OTHER.C',b'omit')
            extract_zip_tree(archive,home)
            self.assertEqual((home/'BINB/wcc386.exe').read_bytes(),b'compiler')
            self.assertFalse((home/'SAMPLES').exists())


class PatchSetupTests(unittest.TestCase):
    def test_b_patch_requires_the_verified_a_level_base(self):
        from tools.setup_watcom import install
        archive = Path(__file__).resolve().parents[1]/'toolchains/archives/c_b.zip'
        if not archive.is_file():
            self.skipTest('private historical patch archive required')
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory); base=root/'base'; (base/'BINB').mkdir(parents=True)
            (base/'BINB/wcc386.exe').write_bytes(b'wrong compiler')
            with self.assertRaisesRegex(ValueError,'base compiler'):
                install('10.0b',archive,root/'home',base=base)
            self.assertFalse((root/'home').exists())

    def test_b_patch_replays_without_mutating_the_base(self):
        from tools.setup_watcom import file_hash
        root=Path(__file__).resolve().parents[1]
        archive=root/'toolchains/archives/c_b.zip'; base=root/'toolchains/watcom-10.0a'
        if not archive.is_file() or not (base/'BINB/wcc386.exe').is_file():
            self.skipTest('private historical patch and base compiler required')
        before=file_hash(base/'BINB/wcc386.exe')
        with tempfile.TemporaryDirectory() as directory:
            home=Path(directory)/'home'
            report=install('10.0b',archive,home,base=base)
            self.assertEqual(file_hash(home/'BINB/wcc386.exe'),
                             '2b6672b7cb109452a31cb7fd6bf6776f518f43466f66dc3efd8365708fd243c6')
            self.assertEqual(report['patch_scope'],'wcc386 compiler only; other tools and headers inherited from 10.0a')
            self.assertEqual(report['base_compiler_sha256'],before)
        self.assertEqual(file_hash(base/'BINB/wcc386.exe'),before)

    def test_b_patch_rejects_a_destination_inside_its_base(self):
        from unittest.mock import patch
        root=Path(__file__).resolve().parents[1]
        archive=root/'toolchains/archives/c_b.zip'
        compiler=root/'toolchains/watcom-10.0a/BINB/wcc386.exe'
        if not archive.is_file() or not compiler.is_file():
            self.skipTest('private historical patch and base compiler required')
        with tempfile.TemporaryDirectory() as directory:
            base=Path(directory)/'base'; (base/'BINB').mkdir(parents=True)
            (base/'BINB/wcc386.exe').write_bytes(compiler.read_bytes())
            with patch('tools.setup_watcom.shutil.copytree',
                       side_effect=AssertionError('recursive copy must not start')):
                with self.assertRaisesRegex(ValueError,'destination'):
                    install('10.0b',archive,base/'patched',base=base)
            self.assertEqual(sorted(p.name for p in base.iterdir()),['BINB'])
