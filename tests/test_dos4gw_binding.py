"""The preserved extender must never stand in for rebuilt game output."""
import importlib
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BIN/wlink.exe').is_file(),
                     'private target and native compiler/linker required')
class VendorBindingTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from tools.prove_module import prepare_headers  # initializes profile imports
        from runner import compile_source,run_batch
        cls.temporary=tempfile.TemporaryDirectory()
        cls.addClassCleanup(cls.temporary.cleanup)
        cls.work=Path(cls.temporary.name)
        source=cls.work/'MAIN.C';source.write_text('int main(void) { return 0; }\n')
        home=ROOT/'toolchains/watcom-10.0-ga'
        compile_source(home,source,cls.work/'MAIN.OBJ',['/4r','/s','/ort'],30)
        (cls.work/'LINK.LNK').write_text('system dos4g\noption quiet,map=LINK.MAP,stack=4096\n'
                                       'name NATIVE.EXE\nfile MAIN.OBJ\n')
        batch=('@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
               'set LIB=D:\\LIB386;D:\\LIB386\\DOS\r\nwlink @LINK.LNK > LINK.LOG\r\n'
               'if errorlevel 1 goto failed\r\necho OK>LINK.STA\r\ngoto end\r\n'
               ':failed\r\necho FAILED>LINK.STA\r\n:end\r\n')
        run_batch(home,cls.work,batch,30)
        if (cls.work/'LINK.STA').read_text().strip()!='OK':
            raise AssertionError((cls.work/'LINK.LOG').read_text())
        cls.reference=(ROOT/'reference/DUKE3D.EXE').read_bytes()
        cls.program=(cls.work/'NATIVE.EXE').read_bytes()

    def api(self):
        self.assertTrue((ROOT/'tools/bind_dos4gw.py').is_file(),
                        'measured vendor binding implementation missing')
        return importlib.import_module('tools.bind_dos4gw')

    def test_vendor_boundary_and_native_program_remain_separate(self):
        api=self.api()
        from le import LEImage
        report=api.inspect_reference(self.reference)
        self.assertEqual(report['vendor_bytes'],217764)
        self.assertEqual([(r['offset'],r['next_header'],r['name']) for r in report['frames']],
                         [(62580,123076,'VMM.EXP'),(123076,217764,'4GWPRO.EXP')])
        bound,proof=api.bind(self.reference,self.program)
        self.assertEqual(bound[:217764],self.reference[:217764])
        self.assertEqual(bound[217764:],self.program)
        a,b=LEImage.parse(self.program),LEImage.parse(bound)
        self.assertEqual((b.origin,b.header_offset),(217764,228412))
        self.assertEqual(a.objects,b.objects)
        self.assertEqual(a.read_fixups(),b.read_fixups())
        for i in range(1,len(a.objects)+1):self.assertEqual(a.object_bytes(i),b.object_bytes(i))
        self.assertFalse(proof['whole_file_identity']['match'])
        self.assertFalse(proof['source_rebuild_verified'])
        self.assertEqual(proof['reused_target_game_bytes'],0)
        self.assertEqual(proof['native_program_bytes'],len(self.program))
        self.assertGreater(proof['whole_file_identity']['differing_bytes'],0)

    def test_bad_vendor_frames_and_unidentified_bytes_are_rejected(self):
        api=self.api();prefix=self.reference[:217764]
        cases=[]
        for offset,value in [(62580,b'BX'),(62580+28,struct.pack('<I',62580)),
                             (62580+28,struct.pack('<I',0xffffffff)),
                             (62580+26,struct.pack('<H',2000)),
                             (62580+2,struct.pack('<H',512)),
                             (123076+112,b'GAME.EXP'),(1000,bytes([prefix[1000]^1]))]:
            damaged=bytearray(prefix);damaged[offset:offset+len(value)]=value
            cases.append(bytes(damaged))
        cases.extend([prefix[:-1],prefix+b'\0'])
        for damaged in cases:
            with self.subTest(length=len(damaged)):
                with self.assertRaises(ValueError):api._inspect_prefix(damaged)
        damaged=bytearray(self.reference);damaged[-1]^=1
        with self.assertRaisesRegex(ValueError,'reference identity'):
            api.inspect_reference(bytes(damaged))

    def test_bad_program_stub_and_double_binding_are_rejected(self):
        api=self.api();bound,_=api.bind(self.reference,self.program)
        for program in [b'',self.program[:40],bound]:
            with self.assertRaises(ValueError):api.bind(self.reference,program)
        damaged=bytearray(self.program);damaged[100]^=1
        with self.assertRaisesRegex(ValueError,'native MZ stub'):
            api.bind(self.reference,bytes(damaged))

    def test_cli_preserves_inputs_and_refuses_output_aliases(self):
        api=self.api();reference=self.work/'REFERENCE.EXE';reference.write_bytes(self.reference)
        program=self.work/'PROGRAM.EXE';program.write_bytes(self.program)
        output=self.work/'BOUND.EXE';report=self.work/'REPORT.JSON'
        command=[sys.executable,str(ROOT/'tools/bind_dos4gw.py'),'--reference',str(reference),
                 '--program',str(program),'--output',str(output),'--report',str(report)]
        run=subprocess.run(command,capture_output=True,text=True)
        self.assertEqual(run.returncode,0,run.stderr)
        self.assertEqual(output.read_bytes(),api.bind(self.reference,self.program)[0])
        self.assertFalse(json.loads(report.read_text())['whole_file_identity']['match'])
        for name in ('--output','--report'):
            bad=list(command);bad[bad.index(name)+1]=str(program)
            run=subprocess.run(bad,capture_output=True,text=True)
            self.assertNotEqual(run.returncode,0)
        alias=self.work/'HARDLINK.EXE';alias.hardlink_to(program)
        bad=list(command);bad[bad.index('--output')+1]=str(alias)
        run=subprocess.run(bad,capture_output=True,text=True)
        self.assertNotEqual(run.returncode,0)
        self.assertEqual(reference.read_bytes(),self.reference)
        self.assertEqual(program.read_bytes(),self.program)
