"""Native mnemonic MACT recovery; original objects are reference inputs only."""
import copy
from dataclasses import replace
import importlib
from pathlib import Path
from unittest.mock import patch
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HOME = ROOT/'toolchains/watcom-10.0-ga'


class ProductionMactContractTests(unittest.TestCase):
    def test_recovered_sources_and_strict_native_route_exist(self):
        # A missing production contribution must be RED before private seeds move.
        for name in ('pent', 'precise', 'joystick'):
            self.assertTrue((ROOT/'src/mact'/f'{name}.asm').is_file(), name)
        self.assertTrue((ROOT/'tools/probe_mact_asm.py').is_file())


@unittest.skipUnless((HOME/'BINB/wasm.exe').is_file() and
                     (ROOT/'reference/DUKE3D.EXE').is_file(),
                     'private target and pinned native WASM required')
class NativeMactRecoveryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.probe = importlib.import_module('tools.probe_mact_asm')
        cls.temp = tempfile.TemporaryDirectory(prefix='mact-test-')
        cls.build = Path(cls.temp.name)
        cls.reports = {}
        cls.modules = {}
        for name in ('pent', 'precise', 'joystick'):
            cls.reports[name] = cls.probe.prove(name, HOME, cls.build/name)
            cls.modules[name] = cls.probe.Module.parse((cls.build/name/f'{name}.obj').read_bytes())
        cls.image = cls.probe.target_image()

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def test_three_complete_native_proofs(self):
        for name, initialized, fixups in [('pent',72,6),('precise',63,7),('joystick',110,5)]:
            with self.subTest(name=name):
                report = self.reports[name]
                proof = report['verification']
                self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),
                                 (initialized,0,fixups))
                self.assertTrue(proof['verified'])
                self.assertFalse(report['full_executable_rebuilt'])
                self.assertEqual(report['object1_code_bytes'],0)
                self.assertEqual(report['assembler_sha256'],
                                 'a4419d0acab40f841d6fd00540f1813f6128d9630fbb150fc4618646c358f7f2')
        self.assertEqual(self.reports['pent']['verification']['publics']['PENT_Stop_'],(2,22))
        self.assertEqual(self.reports['precise']['verification']['publics']['PRECISION_Low_'],(2,99))
        self.assertEqual(self.reports['joystick']['verification']['publics']['_Joy_mask'],(3,67982))

    def test_original_members_are_separately_verified_reference_only(self):
        refs = self.probe.original_references(self.image)
        self.assertEqual([(r['member']['offset'],r['member']['size']) for r in refs],
                         [(5120,282),(14336,276),(14848,334)])
        self.assertTrue(all(r['reference_only'] and r['verification']['verified'] for r in refs))

    def test_native_semantic_mutants_are_rejected(self):
        mutants = [
            ('pent','mov previous_high,edx','mov previous_low,edx'),
            ('pent','mov _PENT_timeh,edx','mov _PENT_timel,edx'),
            ('pent','public PENT_Start_, PENT_Stop_','public PENT_Start_'),
            ('pent','TEXT segment para private use32',"TEXT segment para private use32 'CODE'"),
            ('precise','and control_word,0fcffh','and control_word,0fdffh'),
            ('precise','or control_word,0300h','or control_word,0200h'),
            ('joystick','and al,ah','xor al,ah'),
            ('joystick','cmp edi,5000','cmp edi,5001'),
            ('joystick','mov _Joy_x2,ebp','mov _Joy_y2,ebp'),
        ]
        for index,(name,old,new) in enumerate(mutants):
            with self.subTest(name=name,mutation=new):
                source = ROOT/'src/mact'/f'{name}.asm'
                text = source.read_text()
                self.assertIn(old,text)
                mutant = self.build/f'mutant{index}.asm'
                mutant.write_text(text.replace(old,new,1))
                obj = self.build/f'mutant{index}.obj'
                self.probe.assemble_native(HOME,mutant,obj)
                module = self.probe.Module.parse(obj.read_bytes())
                with self.assertRaises(ValueError):
                    self.probe.check_module(name,module,self.image)

    def test_all_tails_and_fixups_are_checked(self):
        for name,module in self.modules.items():
            for segment in (1,2):
                damaged = copy.deepcopy(module)
                damaged.segments[segment].data[-1] ^= 1
                with self.subTest(name=name,tail=segment),self.assertRaises(ValueError):
                    self.probe.check_module(name,damaged,self.image)
            damaged = copy.deepcopy(module)
            damaged.fixups[0] = replace(damaged.fixups[0], displacement=damaged.fixups[0].displacement+1)
            with self.subTest(name=name,fixup=True),self.assertRaises(ValueError):
                self.probe.check_module(name,damaged,self.image)

    def test_missing_publics_segment_geometry_and_bindings_are_rejected(self):
        for name,module in self.modules.items():
            spec = self.probe.load_spec(name)
            damaged = copy.deepcopy(module)
            damaged.publics.pop(next(iter(damaged.publics)))
            with self.assertRaises(ValueError): self.probe.check_module(name,damaged,self.image)
            for field,value in [('class_name','CODE'),('attributes',105),('size',module.segments[2].size-1)]:
                damaged = copy.deepcopy(module)
                setattr(damaged.segments[2],field,value)
                with self.assertRaises(ValueError): self.probe.check_module(name,damaged,self.image)
            bad = copy.deepcopy(spec)
            bad['placements']['3'][1] += 16
            with self.assertRaises(ValueError): self.probe.check_module(name,module,self.image,bad)
            bad = copy.deepcopy(spec)
            bad['symbol_anchors'][next(iter(bad['symbol_anchors']))][1] += 1
            with self.assertRaises(ValueError): self.probe.check_module(name,module,self.image,bad)

    def test_instruction_payload_and_invalid_native_source_are_rejected(self):
        for payload in ['db 090h','incbin "payload.bin"','org 56','previous_high dd 0,0']:
            with self.subTest(payload=payload),self.assertRaises(ValueError):
                self.probe.validate_source('pent',payload)
        bad = self.build/'invalid.asm'
        bad.write_text('.586\nthis_is_not_an_instruction\nend\n')
        out = self.build/'invalid.obj'
        with self.assertRaises(self.probe.CompilerError): self.probe.assemble_native(HOME,bad,out)
        self.assertFalse(out.exists())
        self.assertTrue(out.with_suffix('.log').exists())

    def test_source_race_and_wrong_assembler_never_publish_objects(self):
        source = self.build/'race.asm'
        source.write_bytes((ROOT/'src/mact/pent.asm').read_bytes())
        out = self.build/'race.obj'
        real_run = self.probe.run_batch

        def assemble_then_change_source(*args):
            real_run(*args)
            source.write_text(source.read_text()+'; changed during assembly\n')

        # Keep the actual native assembler; only introduce the input race at
        # its boundary so publication must recheck identity after it returns.
        with patch.object(self.probe,'run_batch',side_effect=assemble_then_change_source):
            with self.assertRaisesRegex(ValueError,'identity changed'):
                self.probe.assemble_native(HOME,source,out)
        self.assertFalse(out.exists())
        fake_home = self.build/'wrong-toolchain'
        (fake_home/'BINB').mkdir(parents=True)
        (fake_home/'BINB/wasm.exe').write_bytes(b'wrong executable identity')
        with self.assertRaisesRegex(self.probe.CompilerError,'identity mismatch'):
            self.probe.assemble_native(fake_home,source,out)
        self.assertFalse(out.exists())

    def test_strict_archive_rejects_truncation_and_identity_change(self):
        raw = (ROOT/'reference/duke3d-reconstructions/MACT386.LIB').read_bytes()
        with self.assertRaises(ValueError): self.probe.original_references(self.image,raw[:-1])
        damaged = bytearray(raw); damaged[5125] ^= 1
        with self.assertRaises(ValueError): self.probe.original_references(self.image,bytes(damaged))
