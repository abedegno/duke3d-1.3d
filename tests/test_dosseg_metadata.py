"""DOSSEG parsing only: archive framing and private original-GA characterization.

These tests award no inventory acceptance, source credit or link-order proof.
"""
import hashlib
import os
from pathlib import Path
import shutil
import struct
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools')]
from omf32 import Module, OMFError
from runner import run_batch
from tools.inventory_watcom_runtime import read_archive, select_member


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def record(kind, payload):
    head = bytes([kind])+struct.pack('<H',len(payload)+1)+payload
    return head+bytes([-sum(head)&255])


def archive_fixture(member):
    header = b'\xf0\x0d\0'+struct.pack('<IHB',512,1,1)+bytes(6)
    body = header+member
    body += bytes(-len(body)%16)
    body += b'\xf1'+struct.pack('<H',512-len(body)-3)
    body += bytes(512-len(body))
    return body+bytes(512)


class DossegArchiveTests(unittest.TestCase):
    def test_complete_member_retains_directive_without_archive_padding(self):
        member = record(0x80,b'\x04unit')+record(0x88,b'\x40\x9e')+record(0x8a,b'\0')
        raw = archive_fixture(member)
        archive = read_archive(raw)
        spec = {'offset':16,'size':20,'sha256':digest(member),'name':'unit'}
        framed = select_member(raw,archive,spec)
        self.assertEqual((framed['offset'],framed['end'],framed['padding_bytes']),(16,36,12))
        self.assertEqual([r['kind'] for r in framed['records']],[0x80,0x88,0x8a])
        complete = raw[framed['offset']:framed['end']]
        self.assertEqual(complete,member)
        module = Module.parse(complete)
        self.assertEqual(module.dosseg_directives,[0x40])
        self.assertEqual(module.comments,[(0x9e,b'')])
        self.assertEqual((module.segments,module.publics,module.fixups),([],{ },[]))
        for change in ({'offset':17},{'size':32},{'sha256':'0'*64},{'name':'other'}):
            with self.subTest(change=change),self.assertRaises(ValueError):
                select_member(raw,archive,dict(spec,**change))
        for offset in (35,36):  # nonzero bad checksum and first archive padding byte
            broken = bytearray(raw);broken[offset] ^= 1
            with self.subTest(offset=offset),self.assertRaises(ValueError):
                read_archive(bytes(broken))

    def test_framed_nonempty_dosseg_still_fails_complete_native_parse(self):
        member = record(0x80,b'\x04unit')+record(0x88,b'\x80\x9e\0')+record(0x8a,b'\0')
        raw = archive_fixture(member)
        framed = read_archive(raw)['members'][0]
        with self.assertRaisesRegex(OMFError,'DOSSEG'):
            Module.parse(raw[framed['offset']:framed['end']])


HOME = ROOT/'toolchains/watcom-10.0-ga'
SOURCE = (b'.386p\n.model flat\n.dosseg\n'
          b"_TEXT SEGMENT DWORD PUBLIC USE32 'CODE'\n"
          b'PUBLIC dosseg_probe\ndosseg_probe:\n ret\n_TEXT ENDS\nEND\n')


class PrivateDossegTests(unittest.TestCase):
    @unittest.skipUnless((HOME/'LIB386/DOS/clib3r.lib').is_file(),'private original GA library required')
    def test_pinned_original_seg386_complete_metadata_characterization(self):
        raw = (HOME/'LIB386/DOS/clib3r.lib').read_bytes()
        self.assertEqual(digest(raw),'6f250d0e791ba05c6857d57de1ac5e65b6a5db7cb390a7e8f48035e5a4bd4363')
        framed = select_member(raw,read_archive(raw),{
            'offset':85152,'size':116,'name':'seg386',
            'sha256':'0a183c8eec2ab03238d56b6eb5f9e2a0e2878a55e564c65ad52aab3b7aba3819'})
        self.assertEqual((framed['end'],framed['padding_bytes']),(85268,12))
        records = framed['records']
        self.assertEqual([r['kind'] for r in records],
                         [0x80,0x88,0x96,0x99,0x99,0x9a,0x90,0x88,0x8a])
        payloads = [raw[r['offset']+3:r['end']-1] for r in records]
        self.assertEqual(payloads[1],b'\x80\x9e')
        # Two zero-sized USE32 segments; no data or fixup records.
        self.assertEqual(payloads[3:6],[b'\x49'+bytes(4)+b'\x03\x02\x01',
                                       b'\x49'+bytes(4)+b'\x05\x04\x01',b'\x06\xff\x02'])
        self.assertEqual(payloads[6],b'\0\0\0\0\x0a__DOSseg__\x34\x12\0')
        self.assertEqual(payloads[7:], [b'\0\xa2\x01',b'\0'])
        # DOSSEG is now understood, but the unchanged parser still rejects the
        # absolute __DOSseg__ public (value 0x1234). Never strip it to gain credit.
        with self.assertRaisesRegex(OMFError,'unsupported absolute public'):
            Module.parse(raw[framed['offset']:framed['end']])

    @unittest.skipUnless((HOME/'BINB/wasm.exe').is_file() and
                         (os.environ.get('EXHUME_DOSBOX_X') or shutil.which('dosbox-x')),
                         'private original GA assembler and DOSBox-X required')
    def test_fresh_pinned_ga_assembly_retains_complete_object(self):
        self.assertEqual(digest((HOME/'BINB/wasm.exe').read_bytes()),
                         'a4419d0acab40f841d6fd00540f1813f6128d9630fbb150fc4618646c358f7f2')
        self.assertEqual(digest(SOURCE),'42e7d28e4d6edecdb3103b3e9b6e1e899857f33feabfbf14bf72d1a8b4093eca')
        stage = ROOT/'build/task44';stage.mkdir(parents=True,exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='native-',dir=stage) as directory:
            work = Path(directory)
            (work/'SOURCE.ASM').write_bytes(SOURCE)
            run_batch(HOME,work,'@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
                      'wasm SOURCE.ASM -fo=OUT.OBJ > ASSEMBLE.LOG\r\n'
                      'if errorlevel 1 goto failed\r\necho OK>STATUS.TXT\r\ngoto end\r\n'
                      ':failed\r\necho FAILED>STATUS.TXT\r\n:end\r\n',30)
            log = (work/'ASSEMBLE.LOG').read_text()
            (stage/'ASSEMBLE.LOG').write_text(log)
            self.assertEqual((work/'STATUS.TXT').read_text().strip(),'OK',log)
            self.assertIn('9 lines, 0 warnings, 0 errors',log)
            native = (work/'OUT.OBJ').read_bytes()
            self.assertEqual(digest(native),'c72dd4a1cd3aef65fef3796e4b930d462b0e05d8ee967934892df51ef91ffdfb')
            module = Module.parse(native)
            self.assertEqual(module.name,'SOURCE.ASM')
            self.assertEqual(module.dosseg_directives,[0x80])
            self.assertEqual(module.comments,[(0x9e,b''),(0xa2,b'\x01')])
            self.assertEqual([(s.name,s.class_name,s.size,s.attributes,bytes(s.data),s.access)
                              for s in module.segments],
                             [('_TEXT','CODE',1,0xa9,b'\xc3',None),('_DATA','DATA',0,0xa9,b'',None)])
            self.assertEqual(module.groups,[('FLAT',())])
            self.assertEqual(module.publics,{'dosseg_probe':(1,0)})
            self.assertEqual((module.fixups,module.externals,module.default_libraries),([],[],[]))
