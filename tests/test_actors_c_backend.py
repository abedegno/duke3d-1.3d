"""Fresh C emission, complete metadata conservation and input lifetime gates."""
from pathlib import Path
import hashlib
import json
import shutil
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


class ActorsCBackend(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from tools import build_actors_c as api
        cls.api = api
        cls.home = ROOT / 'toolchains/watcom-10.0-ga'
        if not cls.home.is_dir() or not (ROOT / 'toolchains/support/nasm-2.16.03/nasm').is_file() or not shutil.which('dosbox-x'):
            raise unittest.SkipTest('install the pinned GA/NASM tools and DOSBox-X')
        (ROOT / 'build').mkdir(exist_ok=True)
        cls.temp = tempfile.TemporaryDirectory(prefix='actors-c-tests-', dir=ROOT / 'build')
        cls.parent = Path(cls.temp.name)
        cls.normal = api.build_source(cls.home, cls.parent / 'normal')

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def test_source_compiles_real_c_and_complete_layout_is_metadata_only(self):
        api = self.api
        m = api.Module.parse(Path(self.normal['object']).read_bytes())
        self.assertEqual(self.normal['source_translation_units'], 2)
        self.assertEqual(self.normal['emitting_c_functions'], 36)
        self.assertEqual(len(m.fixups), 2812)
        self.assertEqual(sum(s.size for s in m.segments if s.class_name != 'BSS'), 61741)
        self.assertEqual(m.default_libraries, ['math387r', 'emu387'])
        self.assertEqual(m.local_publics, {'_dmval', '_radius_status_record'})
        spec = json.loads((ROOT / 'candidates/native_layouts.json').read_bytes())['modules']['O001.OBJ']
        result = api.apply_layout(self.normal, self.parent / 'layout', ROOT / spec['plan'], spec['plan_sha256'])
        self.assertEqual(result['packet_count'], 356)
        self.assertTrue(result['proof']['all_native_properties_literal_except_packet_LOCAT'])
        self.assertTrue(result['proof']['all_fields_inside_source_spans'])

    def test_staged_source_change_rejects_before_compiler(self):
        api = self.api
        original = api.copy_verified
        def changed(snapshot, destination):
            result = original(snapshot, destination)
            if Path(destination).name == 'ACTORS.C':
                Path(destination).write_bytes(result.raw + b'\n/* changed after copy */\n')
            return result
        with patch.object(api, 'copy_verified', side_effect=changed), patch.object(api, 'compile_source') as compile_:
            with self.assertRaises(ValueError):
                api.build_source(self.home, self.parent / 'copy-race')
            compile_.assert_not_called()

    def test_disk_output_must_be_the_verified_serialized_buffer(self):
        api = self.api
        original = Path.write_bytes
        def changed(path, raw):
            if path.name == 'ACTORS.OBJ':
                raw = raw[:-1] + bytes([raw[-1] ^ 1])
            return original(path, raw)
        parent = self.parent / 'output-race'
        with patch.object(Path, 'write_bytes', changed), self.assertRaises(ValueError):
            api.build_source(self.home, parent)
        self.assertFalse(list(parent.rglob('source-build.json')))

    def test_changed_output_cannot_be_published_as_source_success(self):
        api = self.api
        original = api.publish_json
        def changed(path, value, pins):
            output = Path(value['object'])
            raw = bytearray(output.read_bytes())
            raw[-1] ^= 1
            output.write_bytes(raw)
            return original(path, value, pins)
        parent = self.parent / 'publication-race'
        with patch.object(api, 'publish_json', side_effect=changed), self.assertRaises(ValueError):
            api.build_source(self.home, parent)
        self.assertFalse(list(parent.rglob('source-build.json')))

    def test_layout_rejects_an_added_staged_source_file(self):
        api = self.api
        stage = Path(self.normal['staging_root'])
        extra = stage / 'unexpected.inc'
        extra.write_text('unexpected staged input')
        try:
            with self.assertRaisesRegex(ValueError, 'staged source namespace'):
                api.apply_layout(self.normal, self.parent / 'namespace-race',
                                 ROOT / 'src/game/actors_native/ACTORS-whole-C-owned.plan',
                                 hashlib.sha256((ROOT / 'src/game/actors_native/ACTORS-whole-C-owned.plan').read_bytes()).hexdigest())
        finally:
            extra.unlink()

    def test_layout_rejects_a_non_source_link_receipt(self):
        bad = dict(self.normal, source_native_omf_link=False)
        with self.assertRaisesRegex(ValueError, 'fresh source-native'):
            self.api.apply_layout(bad, self.parent / 'bad-receipt', ROOT / 'unused.plan', '0' * 64)


if __name__ == '__main__':
    unittest.main()
