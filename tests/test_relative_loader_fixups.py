"""Executed original-tool witnesses for cross-object LE relative32 fixups."""
from copy import copy, deepcopy
from dataclasses import replace
import re
from pathlib import Path
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from runner import compile_source,run_batch
from tools.probe_mact_asm import assemble_native
from omf32 import Module
from le import LEImage
from tools.infer_bindings import infer_bindings,BindingError
from tools.verify_module import verify_module,ModuleError


class RelativeLoaderTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        parent=ROOT/'build/relative-loader-tests';parent.mkdir(parents=True,exist_ok=True)
        cls.work=Path(tempfile.mkdtemp(prefix='native-',dir=parent))
        cls.cases={}
        home=ROOT/'toolchains/watcom-10.0-ga'
        for label,wrapped in [('flat',False),('addend',True)]:
            stage=cls.work/label;stage.mkdir()
            callee='wrapper' if wrapped else 'cross_callee'
            (stage/'MAIN.C').write_text('int '+callee+'(int);\nint main(void){return '+callee+'(23)!=42;}\n')
            compile_source(home,stage/'MAIN.C',stage/'MAIN.OBJ',['/4r','/s','/or'])
            prefix=('public prefix_\nprefix_ proc near\n mov eax,1\n ret\nprefix_ endp\n' if wrapped else '')
            (stage/'CALLEE.ASM').write_text(".586\n.model flat\n_TEXT segment word public use32 'CODE'\n_TEXT ends\nTEXT segment para private use32\n"+prefix+
                'public cross_callee_\ncross_callee_ proc near\n'+(' nop\n' if wrapped else '')+
                ' add eax,19\n ret\ncross_callee_ endp\nTEXT ends\nend\n')
            assemble_native(home,stage/'CALLEE.ASM',stage/'CALLEE.OBJ')
            files='MAIN.OBJ,CALLEE.OBJ'
            if wrapped:
                (stage/'WRAP.ASM').write_text(".586\n.model flat\n_TEXT segment word public use32 'CODE'\nextrn cross_callee_:near\npublic wrapper_\nwrapper_ proc near\n call cross_callee_+1\n ret\nwrapper_ endp\n_TEXT ends\nend\n")
                assemble_native(home,stage/'WRAP.ASM',stage/'WRAP.OBJ')
                files='MAIN.OBJ,WRAP.OBJ,CALLEE.OBJ'
            (stage/'LINK.LNK').write_text('system dos4g\noption quiet,map=OUT.MAP,stack=4096\nname OUT.EXE\nfile '+files+'\n')
            run_batch(home,stage,'@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\nset LIB=D:\\LIB386;D:\\LIB386\\DOS\r\nwlink @LINK.LNK > LINK.LOG\r\nif errorlevel 1 goto failed\r\nOUT.EXE > RUN.LOG\r\nif errorlevel 1 goto failed\r\necho OK>STATUS.TXT\r\ngoto end\r\n:failed\r\necho FAILED>STATUS.TXT\r\n:end\r\n',30)
            if (stage/'STATUS.TXT').read_text().strip()!='OK':raise AssertionError('native execution failed')
            image=LEImage.parse((stage/'OUT.EXE').read_bytes())
            symbols={n:(int(o,16),int(v,16)) for o,v,n in re.findall(r'^\s*([0-9a-fA-F]{4}):([0-9a-fA-F]{8})[ *+]+(\w+)\s*$',(stage/'OUT.MAP').read_text(),re.M)}
            modules={name:Module.parse((stage/(name+'.OBJ')).read_bytes()) for name in files.replace('.OBJ','').split(',')}
            rows=[f for f in image.read_fixups() if f.source_type==8]
            if len(rows)!=1:raise AssertionError('fixture did not emit one type8 relocation')
            cls.cases[label]={'stage':stage,'image':image,'symbols':symbols,'modules':modules,'row':rows[0],
                              'caller':modules['WRAP' if wrapped else 'MAIN'],
                              'caller_name':'wrapper_' if wrapped else 'main_'}

    def caller_proof(self,case,module=None,image=None,symbols=None):
        m=module or case['caller'];im=image or case['image'];syms=symbols or case['symbols']
        segment,offset=m.publics[case['caller_name']];obj,start=case['symbols'][case['caller_name']]
        binding=infer_bindings(m,im,obj,start-offset,known_symbols=syms)
        return verify_module(m,im,binding['placements'],binding['symbols'])

    def image_with_rows(self,case,rows):
        image=copy(case['image']);image.read_fixups=lambda:tuple(rows)
        return image

    def test_native_flat_call_and_nonzero_addend_verify_every_own_module(self):
        for label,case in self.cases.items():
            with self.subTest(case=label):
                row=case['row'];self.assertNotEqual(row.source_object,row.target_object)
                self.assertEqual((row.source_type,row.width,row.alias),(8,4,False))
                self.assertTrue(self.caller_proof(case)['verified'])
                for name,module in case['modules'].items():
                    placements={}
                    for public,(segment,offset) in module.publics.items():
                        obj,start=case['symbols'][public];placements[segment]=(obj,start-offset)
                    proof=verify_module(module,case['image'],placements,case['symbols'])
                    self.assertTrue(proof['verified'],name)
                raw=case['image'].object_bytes(row.source_object)[row.source_offset:row.source_offset+4]
                self.assertEqual(int.from_bytes(raw,'little'),int(label=='addend'))
                self.assertEqual(row.target_offset,7 if label=='addend' else 0)

    def test_wrong_loader_kind_alias_width_target_and_same_object_are_rejected(self):
        case=self.cases['addend'];old=case['row'];rows=case['image'].read_fixups()
        for changes in ({'source_type':7},{'alias':True},{'width':2},{'target_offset':8},
                        {'target_object':1},{'target_offset':999999}):
            image=self.image_with_rows(case,[replace(f,**changes) if f==old else f for f in rows])
            with self.subTest(changes=changes),self.assertRaises(ValueError):self.caller_proof(case,image=image)

    def test_missing_duplicate_and_extra_loader_records_are_rejected(self):
        case=self.cases['flat'];old=case['row'];rows=case['image'].read_fixups()
        variants=[[f for f in rows if f!=old],list(rows)+[replace(old,target_offset=1)],
                  list(rows)+[replace(old,source_offset=old.source_offset+4)]]
        for rows in variants:
            with self.subTest(rows=rows),self.assertRaises(ValueError):
                self.caller_proof(case,image=self.image_with_rows(case,rows))

    def test_file_operand_is_checked_instead_of_masked(self):
        case=self.cases['addend'];row=case['row'];raw=bytearray(case['image'].data)
        raw[case['image'].file_offset(row.source_object,row.source_offset)]^=1
        image=LEImage.parse(bytes(raw))
        with self.assertRaises(ValueError):self.caller_proof(case,image=image)

    def test_wrong_external_or_source_addend_cannot_change_resolved_target(self):
        case=self.cases['addend'];symbols=dict(case['symbols']);symbols['cross_callee_']=(2,7)
        with self.assertRaises(ValueError):self.caller_proof(case,symbols=symbols)
        module=deepcopy(case['caller']);module.segments[0].data[module.fixups[0].offset]^=1
        with self.assertRaises(ValueError):self.caller_proof(case,module=module)

    def test_unmeasured_omf_methods_displacement_and_frames_are_rejected(self):
        case=self.cases['addend'];module=case['caller'];fix=module.fixups[0]
        for changes in ({'displacement':1},{'target_method':0},{'frame_method':4},
                        {'location':5},{'width':2}):
            broken=deepcopy(module);broken.fixups[0]=replace(fix,**changes)
            with self.subTest(changes=changes),self.assertRaises(ValueError):self.caller_proof(case,module=broken)


if __name__=='__main__':unittest.main()
