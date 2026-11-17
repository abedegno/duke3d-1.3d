"""Native complete MACT math source, not a supplied object dependency."""
from pathlib import Path
from copy import deepcopy
import hashlib
import json
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools')]
from tools.prove_module import prove
from tools.verify_module import verify_module, ModuleError
from omf32 import Module
from le import LEImage


class MactMathTests(unittest.TestCase):
    def test_complete_native_source_contribution(self):
        with tempfile.TemporaryDirectory(prefix='mact-math-', dir=ROOT/'build') as temporary:
            try:
                report = prove('mact_mathutil', ROOT/'toolchains/watcom-10.0-ga',
                               Path(temporary))
            except ValueError as error:
                self.fail('complete MACT math source producer unavailable: '+str(error))
        proof = report['verification']
        self.assertTrue(proof['verified'])
        self.assertEqual((proof['initialized_bytes'], proof['zero_fill_bytes'],
                          proof['verified_fixups']), (527,0,0))
        self.assertEqual(proof['publics'], {
            'FindDistance2D_': (1,566176), 'FindDistance3D_': (1,566268),
            'FindDistance3D_HP_': (1,566356), 'ArcTangentAppx_': (1,566520)})
        self.assertEqual(len(proof['segments']), 1)
        self.assertFalse(report['full_executable_rebuilt'])

    def test_actual_source_semantic_and_descriptor_damage_reject(self):
        source = (ROOT/'src/mact/mathutil.c').read_text(encoding='latin1')
        spec = json.loads((ROOT/'modules/mact_mathutil.json').read_text())
        cases = [
            ('axis', source.replace('if (iy==0) return ix;',
                                    'if (iy==0) return 0;'), None),
            ('rescale', source.replace('FixedSqrtHP(x+y+z) << 5',
                                       'FixedSqrtHP(x+y+z) << 4'), None),
            ('octant-mask', source.replace('#define FINEANGLES 2048',
                                           '#define FINEANGLES 1024'), None),
            ('missing-public', source.replace('int FindDistance2D(',
                                              'static int FindDistance2D('), None),
            ('extent', source, {'code_bytes': 526}),
            ('placement', source, {'code_offset': 566180}),
            ('wrong-public-offset', source, {'expected_publics': {
                **spec['expected_publics'], 'FindDistance3D_': [1,93]}}),
            ('fractional-public-index', source, {'expected_publics': {
                **spec['expected_publics'], 'FindDistance2D_': [1.0,0]}}),
            ('missing-scope-contract', source, {'expected_local_publics': None}),
            ('wrong-private-scope', source, {'expected_local_publics': ['FindDistance2D_']}),
        ]
        with tempfile.TemporaryDirectory(prefix='mact-math-negative-', dir=ROOT/'build') as temporary:
            stage = Path(temporary)
            (stage/'reference').mkdir()
            (stage/'reference/DUKE3D.EXE').symlink_to(ROOT/'reference/DUKE3D.EXE')
            (stage/'src/mact').mkdir(parents=True)
            shutil.copytree(ROOT/'src/mact/include', stage/'src/mact/include')
            (stage/'modules').mkdir()
            for name, text, changes in cases:
                with self.subTest(name=name):
                    (stage/'src/mact/mathutil.c').write_text(text, encoding='latin1')
                    candidate = deepcopy(spec)
                    candidate.update(changes or {})
                    (stage/'modules/mact_mathutil.json').write_text(json.dumps(candidate))
                    with patch('tools.prove_module.ROOT', stage), self.assertRaises(ValueError):
                        prove('mact_mathutil', ROOT/'toolchains/watcom-10.0-ga', stage/name)

    def test_complete_compiled_tail_cannot_hide_behind_matching_functions(self):
        with tempfile.TemporaryDirectory(prefix='mact-math-tail-', dir=ROOT/'build') as temporary:
            stage = Path(temporary)
            prove('mact_mathutil', ROOT/'toolchains/watcom-10.0-ga', stage)
            module = Module.parse((stage/'mact_mathutil.obj').read_bytes())
            module.segments[0].data[-1] ^= 1
            image = LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
            with self.assertRaises(ModuleError):
                verify_module(module, image, {1:(1,566176)}, {})

    def test_source_and_private_headers_retain_recorded_primary_lineage(self):
        lineage = json.loads((ROOT/'evidence/mact-mathutil-source-reference.json').read_text())
        for name, expected in lineage['headers'].items():
            self.assertEqual(hashlib.sha256((ROOT/name).read_bytes()).hexdigest(), expected)
        source = lineage['source']
        self.assertEqual(hashlib.sha256((ROOT/source['path']).read_bytes()).hexdigest(),
                         source['sha256'])
        self.assertFalse(lineage['original_reference']['used_as_build_output'])


if __name__ == '__main__':
    unittest.main()
