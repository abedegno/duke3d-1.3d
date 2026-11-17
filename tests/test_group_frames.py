"""Explicit OMF group frames checked against original GA linked output."""
from copy import deepcopy
from dataclasses import replace
from pathlib import Path
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


class GroupFrameTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.stage = tempfile.TemporaryDirectory(prefix='group-frame-', dir=ROOT/'build')
        work = Path(cls.stage.name)
        cls.work = work
        home = ROOT/'toolchains/watcom-10.0-ga'
        (work/'MAIN.C').write_text(
            'extern unsigned long group_read(void);\n'
            'extern unsigned long group_item;\n'
            'int main(void) { return group_read() != (unsigned long)&group_item; }\n')
        # An ordinary pointer initializer and address return, not target bytes.
        (work/'GROUP.ASM').write_text(""".386
CONST segment dword public use32 'DATA'
CONST ends
_DATA segment dword public use32 'DATA'
_DATA ends
_BSS segment dword public use32 'BSS'
_BSS ends
DGROUP group CONST, _DATA, _BSS
CONST segment dword public use32 'DATA'
public _group_item
_group_item dd 12345678h
CONST ends
_DATA segment dword public use32 'DATA'
public _group_ptr
_group_ptr dd offset DGROUP:_group_item
_DATA ends
_TEXT segment dword public use32 'CODE'
assume ds:DGROUP
public group_read_
group_read_ proc near
 mov eax,offset DGROUP:_group_item
 ret
group_read_ endp
_TEXT ends
end
""")
        (work/'GROUP.LNK').write_text(
            'system dos4g\noption quiet,map=GROUP.MAP,stack=4096\n'
            'name GROUP.EXE\nfile MAIN.OBJ,GROUP.OBJ\n')
        compile_source(home, work/'MAIN.C', work/'MAIN.OBJ', ['/4r','/s','/ort'])
        run_batch(home, work,
            '@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
            'set LIB=D:\\LIB386;D:\\LIB386\\DOS\r\n'
            'wasm GROUP.ASM -fo=GROUP.OBJ > ASM.LOG\r\n'
            'if errorlevel 1 goto failed\r\nwlink @GROUP.LNK > LINK.LOG\r\n'
            'if errorlevel 1 goto failed\r\nGROUP.EXE > EXEC.LOG\r\n'
            'if errorlevel 1 goto failed\r\necho OK>STATUS.TXT\r\ngoto end\r\n'
            ':failed\r\necho FAILED>STATUS.TXT\r\n:end\r\n', 30)
        if (work/'STATUS.TXT').read_text().strip() != 'OK':
            raise AssertionError('native group-frame build/execution failed')
        cls.module = Module.parse((work/'GROUP.OBJ').read_bytes())
        cls.image = LEImage.parse((work/'GROUP.EXE').read_bytes())
        # Hand-checked GA map: main starts at16, assembler function at36;
        # DGROUP begins object2:0, CONST at4, pointer initializer at8.
        cls.placements = {1:(2,4), 2:(2,8), 4:(1,36)}

    @classmethod
    def tearDownClass(cls):
        cls.stage.cleanup()

    def prove(self, module=None, image=None, placements=None, frames=None):
        return verify_module(module or self.module, image or self.image,
            placements or self.placements, {}, group_frames=frames if frames is not None else {1:(2,0)})

    def test_explicit_group_base_proves_native_code_and_data_pointers(self):
        proof = self.prove()
        self.assertEqual((proof['initialized_bytes'], proof['verified_fixups']), (15,2))
        self.assertEqual(proof['group_frames'], {1:(2,0)})
        self.assertEqual(proof['publics']['_group_item'], (2,4))
        self.assertEqual(self.module.groups, [('DGROUP',(3,2,1))])
        self.assertTrue(all(f.frame_method == 1 for f in self.module.fixups))
        self.assertIn('DGROUP                          0002:00000000',
                      (self.work/'GROUP.MAP').read_text())

    def test_unbound_group_still_rejects_by_default(self):
        with self.assertRaisesRegex(ModuleError, 'frame'):
            verify_module(self.module,self.image,self.placements,{})

    def test_function_gate_checks_the_same_explicit_group_reference(self):
        proof=match_function(self.module,'group_read_',self.image,1,36,7,{},
                             self.placements,group_frames={1:(2,0)})
        self.assertTrue(proof['match'])
        self.assertEqual(proof['verified_fixups'],1)

    def test_wrong_group_object_nonzero_base_and_unknown_index_reject(self):
        for frames in ({1:(1,0)}, {1:(2,4)}, {2:(2,0)}, {1:(99,0)}):
            with self.subTest(frames=frames), self.assertRaisesRegex(ModuleError,'group|frame'):
                self.prove(frames=frames)

    def test_external_target_must_resolve_inside_the_explicit_group_object(self):
        module=deepcopy(self.module)
        module.externals=['_referenced_item']
        module.fixups[0]=replace(module.fixups[0],target_method=2,target=1)
        proof=verify_module(module,self.image,self.placements,
                            {'_referenced_item':(2,4)},group_frames={1:(2,0)})
        self.assertEqual(proof['verified_fixups'],2)
        with self.assertRaisesRegex(ModuleError,'group frame object'):
            verify_module(module,self.image,self.placements,
                          {'_referenced_item':(1,4)},group_frames={1:(2,0)})

    def test_duplicate_normalized_group_indices_reject(self):
        with self.assertRaisesRegex(ModuleError,'group frame'):
            self.prove(frames={1:(2,0),'1':(2,0)})

    def test_fractional_group_index_is_not_truncated_to_a_real_group(self):
        with self.assertRaisesRegex(ModuleError,'group frame'):
            self.prove(frames={1.5:(2,0)})

    def test_group_member_in_another_object_rejects(self):
        placements = {**self.placements,1:(1,4)}
        with self.assertRaisesRegex(ModuleError,'group|frame'):
            self.prove(placements=placements)

    def test_same_group_name_without_membership_does_not_prove_target(self):
        module=deepcopy(self.module)
        module.groups=[('DGROUP',(3,2))]
        with self.assertRaisesRegex(ModuleError,'group|frame'):
            self.prove(module=module)

    def test_relative_reference_cannot_cross_from_code_to_group_object(self):
        module=deepcopy(self.module)
        for index,fixup in enumerate(module.fixups):
            if fixup.segment==4:
                module.fixups[index]=replace(fixup,relative=True)
        with self.assertRaisesRegex(ModuleError,'cross-object relative'):
            self.prove(module=module)

    def test_correct_group_does_not_hide_pointer_addend_or_opcode_damage(self):
        for segment,offset in ((2,0),(4,0)):
            module=deepcopy(self.module)
            module.segments[segment-1].data[offset]^=1
            with self.subTest(segment=segment), self.assertRaises(ModuleError):
                self.prove(module=module)

    def test_complete_composite_uses_native_c_and_asm_exports_and_runtime_edges(self):
        from tools.verify_composite import verify_composite
        main = Module.parse((self.work/'MAIN.OBJ').read_bytes())
        # Independent GA map/SEGDEF extents: C at16..35, one linker alignment
        # byte excluded, ASM at36..43, CONST4..8 and DATA8..12 in DGROUP.
        modules = {'C': main, 'ASM': self.module}
        places = {'C': {1: (1,16)}, 'ASM': self.placements}
        expected = [(1,16,19,'initialized'), (1,36,7,'initialized'),
                    (2,4,8,'initialized')]
        proof = verify_composite(modules, self.image, places, {}, expected,
                                 group_frames={'ASM': {1:(2,0)}})
        self.assertEqual((proof['initialized_bytes'], proof['zero_fill_bytes'],
                          proof['verified_fixups']), (34,0,4))
        self.assertEqual(proof['publics']['group_read_'], (1,36))
        self.assertEqual(proof['publics']['_group_item'], (2,4))
        damaged = deepcopy(main)
        damaged.segments[0].data[-1] ^= 1
        with self.assertRaises(ModuleError):
            verify_composite({'C':damaged,'ASM':self.module}, self.image,
                             places, {}, expected,
                             group_frames={'ASM': {1:(2,0)}})


if __name__ == '__main__':
    unittest.main()
