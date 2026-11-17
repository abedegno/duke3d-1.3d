"""Complete native MACT CRC recovery, recurrence, ABI and corruption gates."""
import copy
import ctypes
from dataclasses import replace
import importlib
import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
HOME = ROOT/'toolchains/watcom-10.0-ga'


class ProductionCRCContractTests(unittest.TestCase):
    def test_complete_crc_production_route(self):
        self.assertIsNotNone(importlib.util.find_spec('tools.probe_mact_crc'),
                             'complete native source proof route is absent')
        probe = importlib.import_module('tools.probe_mact_crc')
        with tempfile.TemporaryDirectory() as directory:
            result = probe.prove(HOME,Path(directory))
        self.assertEqual(result['verification']['initialized_bytes'],592)


@unittest.skipUnless((HOME/'BINB/wcc386.exe').is_file() and
                     (ROOT/'reference/DUKE3D.EXE').is_file(),
                     'private target and pinned C compiler required')
class NativeCRCRecoveryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.probe = importlib.import_module('tools.probe_mact_crc')
        cls.temp = tempfile.TemporaryDirectory(prefix='mact-crc-test-')
        cls.build = Path(cls.temp.name)
        cls.report = cls.probe.prove(HOME,cls.build/'native')
        cls.module = cls.probe.Module.parse((cls.build/'native/crc.obj').read_bytes())
        cls.image = cls.probe.target_image()

    @classmethod
    def tearDownClass(cls): cls.temp.cleanup()

    def test_complete_native_code_data_and_local_table_scope(self):
        proof = self.report['verification']
        self.assertTrue(proof['verified'])
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),(592,0,2))
        self.assertEqual(proof['publics'],{'UpdateCRC_':(1,570880),'CalculateCRC_':(1,570904),'_crc16tab':(3,71184)})
        self.assertEqual(proof['local_symbols'],{'_crc16tab':(3,71184)})
        self.assertFalse(self.report['full_executable_rebuilt'])
        self.assertTrue(self.report['original_reference']['reference_only'])
        self.assertTrue(self.report['original_reference']['verification']['verified'])

    def test_mathematical_table_and_host_algorithm_vectors(self):
        table = self.probe.generate_table()
        self.assertEqual(table[:8],[0,0xc0c1,0xc181,0x0140,0xc301,0x03c0,0x0280,0xc241])
        self.assertEqual(table[-1],0x4040)
        for data,want in [(b'',0),(b'123456789',0xbb3d),(bytes(range(256)),0xbad3),(b'\xff',0x4040)]:
            crc = 0
            for byte in data:
                crc ^= byte
                for _ in range(8): crc = (crc >> 1) ^ (0xa001 if crc & 1 else 0)
            self.assertEqual(crc,want)
        # Run the recovered ordinary C with a host compiler too; CRC roles use
        # int32 arithmetic, short16 table entries and unsigned8 buffer reads.
        library = self.build/'crc.dylib'
        subprocess.run(['cc','-shared','-fPIC',str(ROOT/'src/mact/crc.c'),'-o',str(library)],check=True,capture_output=True)
        native = ctypes.CDLL(str(library))
        native.CalculateCRC.argtypes = [ctypes.c_void_p,ctypes.c_uint]
        native.CalculateCRC.restype = ctypes.c_int
        native.UpdateCRC.argtypes = [ctypes.c_int,ctypes.c_int]
        native.UpdateCRC.restype = ctypes.c_int
        for data,want in [(b'',0),(b'123456789',0xbb3d),(bytes(range(256)),0xbad3),(b'\xff',0x4040)]:
            buf = ctypes.create_string_buffer(data)
            self.assertEqual(native.CalculateCRC(buf,len(data)),want)
            crc = 0
            for byte in data: crc = native.UpdateCRC(crc,byte) & 0xffff
            self.assertEqual(crc,want)

    def test_real_native_operand_loop_seed_and_public_mutants(self):
        text = (ROOT/'src/mact/crc.c').read_text()
        mutants = [
            ('(crc ^ data) & 255','(crc ^ data) & 127'),
            ('crc >> 8','crc >> 7'),
            ('int crc = 0;','int crc = 1;'),
            ('i < length','i + 1 < length'),
            ('crc >>= 8;','crc >>= 7;'),
            ('return crc;','return crc ^ 1;'),
            ('int UpdateCRC(','int DifferentCRC('),
        ]
        for i,(old,new) in enumerate(mutants):
            with self.subTest(mutation=new):
                self.assertIn(old,text)
                source = self.build/f'mutant{i}.c'; source.write_text(text.replace(old,new,1))
                obj = self.build/f'mutant{i}.obj'
                self.probe.compile_source(HOME,source,obj,self.probe.OPTIONS,include_dirs=[ROOT/'src/mact'])
                with self.assertRaises(ValueError):
                    self.probe.check_module(self.probe.Module.parse(obj.read_bytes()),self.image)

    def test_real_native_polynomial_and_table_byte_mutants(self):
        for i,values in enumerate([self.probe.generate_table(0xa003),self.probe.generate_table()]):
            if i == 1: values[-1] ^= 1
            headers = self.build/f'table{i}'; headers.mkdir()
            (headers/'crctable.h').write_text(self.probe.render_table(values))
            obj = self.build/f'table{i}.obj'
            self.probe.compile_source(HOME,ROOT/'src/mact/crc.c',obj,self.probe.OPTIONS,include_dirs=[headers])
            with self.subTest(table=i),self.assertRaises(ValueError):
                self.probe.check_module(self.probe.Module.parse(obj.read_bytes()),self.image)

    def test_complete_tails_fixups_public_scope_and_bindings(self):
        for segment in (0,3):
            damaged = copy.deepcopy(self.module); damaged.segments[segment].data[-1] ^= 1
            with self.assertRaises(ValueError): self.probe.check_module(damaged,self.image)
        damaged = copy.deepcopy(self.module)
        damaged.fixups[0] = replace(damaged.fixups[0],displacement=damaged.fixups[0].displacement+1)
        with self.assertRaises(ValueError): self.probe.check_module(damaged,self.image)
        damaged = copy.deepcopy(self.module); del damaged.publics['CalculateCRC_']
        with self.assertRaises(ValueError): self.probe.check_module(damaged,self.image)
        damaged = copy.deepcopy(self.module); damaged.local_publics.clear()
        with self.assertRaises(ValueError): self.probe.check_module(damaged,self.image)
        with self.assertRaises(ValueError): self.probe.check_module(self.module,self.image,code_offset=570896)
        with self.assertRaises(ValueError): self.probe.check_module(self.module,self.image,known={'_crc16tab':(3,71186)})

    def test_header_identity_race_and_wrong_compiler_are_rejected(self):
        # Preserve the actual native compilation and mutate the real input at
        # its boundary; restore owned files even when the assertion fails.
        real_compile = self.probe.compile_source
        for index,path in enumerate([ROOT/'src/mact/crc.c',ROOT/'src/mact/crctable.h']):
            original = path.read_bytes()
            def compile_then_change_input(*args,**kwargs):
                result = real_compile(*args,**kwargs)
                path.write_bytes(original+b'\n/* changed during compilation */\n')
                return result
            try:
                with patch.object(self.probe,'compile_source',side_effect=compile_then_change_input):
                    with self.assertRaisesRegex(ValueError,'input identity changed'):
                        self.probe.prove(HOME,self.build/f'race{index}')
            finally:
                path.write_bytes(original)
        fake_home = self.build/'wrong-toolchain'; (fake_home/'BINB').mkdir(parents=True)
        (fake_home/'BINB/wcc386.exe').write_bytes(b'wrong compiler')
        with self.assertRaisesRegex(ValueError,'compiler identity'):
            self.probe.prove(fake_home,self.build/'wrong-toolchain-build')

    def test_original_archive_identity_and_full_member_reference(self):
        raw = (ROOT/'reference/duke3d-reconstructions/MACT386.LIB').read_bytes()
        ref = self.probe.original_reference(self.image)
        self.assertEqual((ref['member']['offset'],ref['member']['size']),(94208,1156))
        with self.assertRaises(ValueError): self.probe.original_reference(self.image,raw[:-1])
        damaged = bytearray(raw); damaged[94300] ^= 1
        with self.assertRaises(ValueError): self.probe.original_reference(self.image,bytes(damaged))
