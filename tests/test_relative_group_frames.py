"""Native F1 group-relative32 proof, with retained fresh output per invocation.

The failing behavior is an unconditional relative-group rejection. The native
producer uses ordinary group-qualified CALL; adversarial AST/LE mutations are
explicitly test conditions, never claimed assembler output.
"""
from copy import deepcopy
from dataclasses import asdict, replace
import hashlib
import json
from pathlib import Path
import struct
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import compile_source, run_batch
from tools.verify_module import verify_module, ModuleError
from tools.match_function import match_function


class RelativeGroupFrameTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        parent = ROOT/'build/relative-group-frames'
        parent.mkdir(parents=True, exist_ok=True)
        # Retain each run separately. Never read old native objects as inputs.
        cls.work = work = Path(tempfile.mkdtemp(prefix='native-', dir=parent))
        home = ROOT/'toolchains/watcom-10.0-ga'
        (work/'MAIN.C').write_text('extern int call_group(void);\n'
                                  'int main(void) { return call_group() != 42; }\n')
        (work/'CALLEE.C').write_text('int callee(void) { return 41; }\n')
        (work/'CALLER.ASM').write_text(""".386
_TEXT segment dword public use32 'CODE'
_TEXT ends
CGROUP group _TEXT
_TEXT segment dword public use32 'CODE'
assume cs:CGROUP
extrn callee_:near
public call_group_
call_group_ proc near
 call near ptr CGROUP:callee_
 add eax,1
 ret
call_group_ endp
_TEXT ends
end
""")
        (work/'GROUP.LNK').write_text('system dos4g\n'
            'option quiet,map=GROUP.MAP,stack=4096\n'
            'name GROUP.EXE\nfile MAIN.OBJ,CALLER.OBJ,CALLEE.OBJ\n')
        cls.inputs = [work/n for n in ('MAIN.C','CALLEE.C','CALLER.ASM','GROUP.LNK')]
        cls.inputs += [home/n for n in ('BINB/wcc386.exe','BINB/wasm.exe','BIN/wlink.exe',
                                       'BIN/wlink.lnk','BINB/wstub.exe','BIN/dos4gw.exe',
                                       'LIB386/DOS/clib3r.lib')]
        cls.inputs += [ROOT/'profiles/watcom/tools/runner.py']
        cls.input_hashes = cls.hashes(cls.inputs)
        for name in ('MAIN','CALLEE'):
            compile_source(home, work/(name+'.C'), work/(name+'.OBJ'), ['/4r','/s','/ort'])
        run_batch(home, work,
            '@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
            'set LIB=D:\\LIB386;D:\\LIB386\\DOS\r\n'
            'wasm CALLER.ASM -fo=CALLER.OBJ > ASM.LOG\r\n'
            'if errorlevel 1 goto failed\r\nwlink @GROUP.LNK > LINK.LOG\r\n'
            'if errorlevel 1 goto failed\r\nGROUP.EXE > EXEC.LOG\r\n'
            'if errorlevel 1 goto failed\r\necho OK>STATUS.TXT\r\ngoto end\r\n'
            ':failed\r\necho FAILED>STATUS.TXT\r\n:end\r\n', 30)
        if (work/'STATUS.TXT').read_text().strip() != 'OK':
            raise AssertionError(f'native build/execution failed; retained at {work}')
        cls.modules = {n:Module.parse((work/(n+'.OBJ')).read_bytes())
                       for n in ('MAIN','CALLER','CALLEE')}
        cls.module = cls.modules['CALLER']
        cls.image = LEImage.parse((work/'GROUP.EXE').read_bytes())
        cls.symbols = {'main_':(2,0), 'call_group_':(2,20), 'callee_':(2,32)}
        cls.outputs = [work/n for n in ('MAIN.OBJ','CALLER.OBJ','CALLEE.OBJ','GROUP.EXE','GROUP.MAP')]
        cls.output_hashes = cls.hashes(cls.outputs)
        (work/'snapshot.json').write_text(json.dumps({
            'inputs':cls.input_hashes,'native_outputs':cls.output_hashes}, indent=2)+'\n')

    @staticmethod
    def hashes(paths):
        return {str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}

    @classmethod
    def tearDownClass(cls):
        if cls.hashes(cls.inputs) != cls.input_hashes or cls.hashes(cls.outputs) != cls.output_hashes:
            raise AssertionError('native fixture source/tool/output changed during tests')

    def prove(self, module=None, image=None, placements=None, symbols=None, frames=None):
        return verify_module(module or self.module, image or self.image,
            placements if placements is not None else {1:(2,20)},
            symbols if symbols is not None else self.symbols,
            group_frames=frames if frames is not None else {1:(2,0)})

    def test_complete_native_modules_and_real_execution(self):
        self.assertEqual((self.work/'STATUS.TXT').read_text().strip(),'OK')
        mapping = (self.work/'GROUP.MAP').read_text()
        self.assertIn('CGROUP                          0002:00000000', mapping)
        self.assertRegex(mapping,r'0002:00000014[ *+]\s+call_group_')
        self.assertRegex(mapping,r'0002:00000020[ *+]\s+callee_')
        totals = [0,0,0]
        for name, start, want in (('MAIN',0,(17,0,1)), ('CALLER',20,(10,0,1)), ('CALLEE',32,(6,0,0))):
            proof = verify_module(self.modules[name],self.image,{1:(2,start)},self.symbols,
                                  group_frames={1:(2,0)} if name=='CALLER' else None)
            actual = tuple(proof[k] for k in ('initialized_bytes','zero_fill_bytes','verified_fixups'))
            self.assertEqual(actual,want)
            totals = [a+b for a,b in zip(totals,actual)]
        self.assertEqual(totals,[33,0,2])

    def test_native_raw_fixup_fields_and_linked_equation(self):
        self.assertEqual(self.module.groups,[('CGROUP',(1,))])
        self.assertEqual(self.module.publics,{'call_group_':(1,0)})
        self.assertEqual(self.module.externals,['callee_'])
        self.assertEqual([asdict(f) for f in self.module.fixups],[{
            'segment':1,'offset':2,'width':4,'location':9,'relative':True,
            'frame_method':1,'frame':1,'target_method':2,'target':1,'displacement':0}])
        self.assertEqual(self.module.fixup_encodings,[{
            'fixup':0,'record_kind':0x9c,'raw_bytes':bytes.fromhex('a402160101'),
            'raw_location':9,'raw_locat':bytes.fromhex('a402'),'raw_fixdat':0x16,
            'raw_frame_field':1,'raw_target_field':2,'frame_thread':False,
            'target_thread':False,'frame_definition':None,'target_definition':None,
            'displacement_present':False,'displacement_width':0}])
        self.assertEqual(bytes(self.module.segments[0].data),bytes.fromhex('2ee80000000083c001c3'))
        self.assertEqual(self.image.object_bytes(2)[20:30],bytes.fromhex('2ee80600000083c001c3'))
        self.assertFalse([f for f in self.image.read_fixups()
                          if f.source_object==2 and 20<=f.source_offset<30])
        before = deepcopy(self.module)
        proof = match_function(self.module,'call_group_',self.image,2,20,10,
                               self.symbols,{1:(2,20)},group_frames={1:(2,0)})
        self.assertEqual((proof['match'],proof['verified_fixups']),(True,1))
        self.assertEqual(self.module,before)

    def test_invalid_or_missing_group_bindings_reject(self):
        for frames in ({},{1:(1,0)},{1:(2,4)},{2:(2,0)},
                       {1:(2,0),'1':(2,0)},{1:(99,0)}):
            with self.subTest(frames=frames),self.assertRaises(ModuleError):
                self.prove(frames=frames)

    def test_external_resolution_must_stay_in_bound_object_and_bounds(self):
        for symbols in ({},{'callee_':(1,0)}, {'callee_':(2,self.image._object(2).size+1)}):
            with self.subTest(symbols=symbols),self.assertRaises(ModuleError):
                self.prove(symbols=symbols)

    def test_unknown_methods_and_unsupported_location_or_width_reject(self):
        for change in ({'width':2},{'location':5},{'target_method':1},{'frame_method':3}):
            m = deepcopy(self.module);m.fixups[0]=replace(m.fixups[0],**change)
            with self.subTest(change=change),self.assertRaises(ModuleError):self.prove(module=m)

    def test_instruction_addend_and_displacement_changes_are_not_masked(self):
        for off in (0,2,6,9):
            m=deepcopy(self.module);m.segments[0].data[off]^=1
            with self.subTest(offset=off),self.assertRaisesRegex(ModuleError,'differing bytes'):
                self.prove(module=m)
        m=deepcopy(self.module);m.fixups[0]=replace(m.fixups[0],displacement=1)
        with self.assertRaisesRegex(ModuleError,'differing bytes'):self.prove(module=m)

    def test_nonzero_displacement_and_addend_are_consumed_exactly(self):
        # Test ASTs resolve target31 plus1 to actual native callee32; never new producer evidence.
        for displacement,addend in ((1,0),(0,1),(2,3)):
            m=deepcopy(self.module)
            m.fixups[0]=replace(m.fixups[0],displacement=displacement)
            m.segments[0].data[2:6]=addend.to_bytes(4,'little')
            proof=self.prove(module=m,symbols={**self.symbols,'callee_':(2,32-displacement-addend)})
            self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),(10,1))

    def test_overlapping_fixups_reject(self):
        m=deepcopy(self.module);m.fixups.append(m.fixups[0])
        with self.assertRaisesRegex(ModuleError,'overlapping OMF'):self.prove(module=m)

    def member_module(self):
        # Independent segment-target AST control using the own native callee contribution.
        m=deepcopy(self.module);m.segments.append(deepcopy(self.modules['CALLEE'].segments[0]))
        m.fixups[0]=replace(m.fixups[0],target_method=0,target=2)
        return m

    def test_internal_target_requires_actual_group_membership(self):
        m=self.member_module()
        with self.assertRaisesRegex(ModuleError,'member|belong'):
            self.prove(module=m,placements={1:(2,20),2:(2,32)})
        m.groups=[('CGROUP',(1,2))]
        proof=self.prove(module=m,placements={1:(2,20),2:(2,32)})
        self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),(16,1))

    def test_nonempty_group_member_cannot_be_unplaced_or_split(self):
        m=self.member_module();m.groups=[('CGROUP',(1,2))]
        for placements in ({1:(2,20)},{1:(2,20),2:(1,0)}):
            with self.subTest(placements=placements),self.assertRaisesRegex(ModuleError,'group frame member'):
                self.prove(module=m,placements=placements)

    def test_foreign_source_cannot_use_valid_target_frame_object(self):
        m=self.member_module();m.groups=[('CGROUP',(2,))]
        # Frame member + target are both object2; source is object1. No wrong-group shortcut.
        with self.assertRaisesRegex(ModuleError,'cross-object relative'):
            self.prove(module=m,placements={1:(1,0),2:(2,32)},symbols={'callee_':(2,32)})

    def loader_negative(self,source_offset):
        # A structurally parsed derived LE corruption, not a patched producer OBJ.
        data=bytearray(self.image.data);h=self.image.header_offset
        page=self.image._object(2).first_page-1
        insertion=self.image.fixup_record_start+self.image.fixup_page_offsets[page+1]
        record=bytes([7,0])+struct.pack('<hBH',source_offset,2,32)
        data[insertion:insertion]=record
        for off in (48,128):
            struct.pack_into('<I',data,h+off,struct.unpack_from('<I',data,h+off)[0]+len(record))
        fp=h+struct.unpack_from('<I',data,h+104)[0]
        for i in range(page+1,len(self.image.pages)+1):
            struct.pack_into('<I',data,fp+i*4,self.image.fixup_page_offsets[i]+len(record))
        return LEImage.parse(bytes(data))

    def test_loader_fixup_on_relative_operand_rejects(self):
        image=self.loader_negative(22)
        self.assertTrue(any(f.source_object==2 and f.source_offset==22 for f in image.read_fixups()))
        with self.assertRaisesRegex(ModuleError,'unexpected loader fixup'):self.prove(image=image)

    def test_unaccounted_loader_fixup_cannot_hide_between_operands(self):
        with self.assertRaisesRegex(ModuleError,'unaccounted target LE fixups'):
            self.prove(image=self.loader_negative(23))

    def test_no_group_name_is_privileged(self):
        m=deepcopy(self.module);m.groups=[('arbitrary',(1,))]
        self.assertEqual(self.prove(module=m)['verified_fixups'],1)


if __name__=='__main__':unittest.main()
