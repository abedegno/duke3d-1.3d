"""Require the complete engine while the whole-executable gate stays open."""
import importlib
import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools.prove_module import ROOT


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.5/BINW/wcc386.exe').is_file() and
                     (ROOT/'reference/historical/kenbuild-related-archives-20241213/BUILD_MISC_199604/OBJLIBS/ENGINE.OBJ').is_file(),
                     'private target, historical object and compiler required')
class EngineProbeTests(unittest.TestCase):
    def test_complete_engine_and_unfinished_executable_gate(self):
        engine = importlib.import_module('tools.probe_engine')
        with tempfile.TemporaryDirectory() as directory:
            report = engine.probe(ROOT/'toolchains/watcom-10.5', Path(directory))
            compiled = (Path(directory)/'engine.obj').read_bytes()
            module = engine.Module.parse(compiled)
        self.assertEqual(report['total_functions'], 135)
        self.assertEqual(report['matched_functions'], 135)
        rows = {row['symbol']:row for row in report['functions']}
        for name,size in [('drawmasks_',1574), ('initksqrt_',144),
                          ('ceilscan_',1915), ('florscan_',1955),
                          ('wallmost_',2565), ('grouscan_',3323),
                          ('dorotatesprite_',7345), ('draw2dgrid_',675),
                          ('drawsprite_',12325), ('drawvox_',3410),
                          ('drawmapview_',5386), ('drawalls_',7975)]:
            with self.subTest(symbol=name):
                self.assertIs(rows[name]['match'], True)
                self.assertEqual(rows[name]['compared_bytes'], size)
        self.assertIs(report['bss_layout']['match'], True)
        self.assertEqual(report['bss_layout']['bytes'],1061535)
        self.assertEqual(report['bss_layout']['publics'],268)
        self.assertTrue(report['module_verification']['verified'])
        self.assertEqual(report['module_verification']['initialized_bytes'],127211)
        self.assertEqual(report['module_verification']['zero_fill_bytes'],1061535)
        self.assertEqual(report['module_verification']['verified_fixups'],6540)
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['module_verification']['local_symbols']['_tempbuf'],(3,911744))
        from tools.verify_module import external_anchor_bindings
        shared=external_anchor_bindings(report['module_verification'])
        self.assertNotIn('_tempbuf',shared)
        self.assertEqual(shared['_waloff'],(3,1026752))

        reference = engine.Module.parse(engine.REFERENCE.read_bytes())
        anchors = json.loads(engine.ANCHORS.read_text())
        image = engine.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        placements = {int(k):tuple(v) for k,v in anchors['placements'].items()}
        for index,segment in enumerate(module.segments):
            if not segment.size:
                continue
            with self.subTest(corrupt_segment=segment.name):
                damaged = copy.deepcopy(module)
                damaged.segments[index].data[-1] ^= 1
                with self.assertRaises(engine.ModuleError):
                    engine.verify_module(damaged,image,placements,
                                         anchors['verification']['publics'])
        # Keep the tested publics and their actual next-public bounds. Other
        # reference names can fail as missing without repeatedly checking all
        # 135 functions in each independent mutation test.
        bounded = copy.deepcopy(module)
        names = {'drawmasks_', 'initksqrt_'}
        for name in tuple(names):
            segment,offset = module.publics[name]
            next_offset = min(o for n,o in module.publics.values() if n == segment and o > offset)
            names.update(k for k,v in module.publics.items() if v == (segment,next_offset))
        bounded.publics = {k:v for k,v in module.publics.items() if k in names}
        corrupt = copy.deepcopy(bounded)
        segment,offset = corrupt.publics['drawmasks_']
        corrupt.segments[segment-1].data[offset] ^= 1
        damaged = {r['symbol']:r for r in engine.compare_functions(corrupt,image,reference,anchors)}
        self.assertIs(damaged['drawmasks_']['match'], False)
        self.assertIs(damaged['initksqrt_']['match'], True)

        wrong_binding = copy.deepcopy(anchors)
        wrong_binding['verification']['publics']['_tsprite'][1] += 4
        damaged = {r['symbol']:r for r in engine.compare_functions(bounded,image,reference,wrong_binding)}
        self.assertIs(damaged['drawmasks_']['match'], False)

        shifted = copy.deepcopy(module)
        segment,offset = shifted.publics['_sqrtable']
        shifted.publics['_sqrtable'] = (segment,offset+2)
        self.assertIs(engine.bss_layout(shifted,reference)['match'], False)

        # A source edit during compilation must not attach the new hash to an
        # object built from an earlier version. Keep all mutations in a clone.
        with tempfile.TemporaryDirectory() as directory:
            clone = Path(directory)
            for path in [*engine.INPUTS, 'reference/DUKE3D.EXE', 'evidence/watcom-10.5.json']:
                dest = clone/path
                dest.parent.mkdir(parents=True,exist_ok=True)
                dest.write_bytes((ROOT/path).read_bytes())

            def changing_compile(home, source, output, *args, **kwargs):
                header = clone/'src/engine/include/build.h'
                header.write_bytes(header.read_bytes()+b'\n/* concurrent edit */\n')
                output.write_bytes(compiled)

            # Rejected identities must fail before any compiler is invoked.
            target = clone/'reference/DUKE3D.EXE'
            original_target = target.read_bytes()
            target.write_bytes(b'bad target')
            with patch.object(engine,'ROOT',clone), patch.object(engine,'compile_source') as compile_mock:
                with self.assertRaisesRegex(ValueError,'executable identity mismatch'):
                    engine.probe(ROOT/'toolchains/watcom-10.5',clone/'out')
                compile_mock.assert_not_called()
            target.write_bytes(original_target)
            bad_compiler = clone/'compiler/BINW/wcc386.exe'
            bad_compiler.parent.mkdir(parents=True)
            bad_compiler.write_bytes(b'bad compiler')
            with patch.object(engine,'ROOT',clone), patch.object(engine,'compile_source') as compile_mock:
                with self.assertRaisesRegex(ValueError,'compiler identity mismatch'):
                    engine.probe(clone/'compiler',clone/'out')
                compile_mock.assert_not_called()
            with patch.object(engine,'ROOT',clone), patch.object(engine,'compile_source') as compile_mock:
                with patch.object(engine,'verify_module',side_effect=engine.ModuleError('reference proof rejected')):
                    with self.assertRaisesRegex(engine.ModuleError,'reference proof rejected'):
                        engine.probe(ROOT/'toolchains/watcom-10.5',clone/'out')
                compile_mock.assert_not_called()

            with patch.object(engine,'ROOT',clone), patch.object(engine,'compile_source',changing_compile):
                with self.assertRaisesRegex(ValueError,'source input changed'):
                    engine.probe(ROOT/'toolchains/watcom-10.5',clone/'out')
