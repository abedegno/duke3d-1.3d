"""Complete native SCRIPLIB contract and meaningful corruption controls."""
import copy
import dataclasses
import importlib
import json
from pathlib import Path
import shutil
import sys
import subprocess
import os
import tempfile
import unittest
from unittest import mock

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]

class ScriplibContract(unittest.TestCase):
    def test_complete_producer_contract_exists(self):
        self.assertTrue((ROOT/'modules/mact_scriplib.json').is_file(),
                        'missing complete SCRIPLIB native contract')
        h=importlib.import_module('tools.probe_mact_scriplib')
        spec=h.load_spec()
        self.assertEqual(spec['expected'],dict(initialized_bytes=5616,zero_fill_bytes=80,verified_fixups=225))
        self.assertEqual(len(spec['inventory']['publics']),38)
        self.assertEqual(spec['inventory']['local_publics'],['_scriptfiles','_scriptlibrarycalled'])
        self.assertEqual(len(spec['inventory']['fixups']),225)

class NativeScriplib(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.h=importlib.import_module('tools.probe_mact_scriplib')
        cls.temp=tempfile.TemporaryDirectory(prefix='scriplib-test-')
        cls.build=Path(cls.temp.name);cls.home=ROOT/'toolchains/watcom-10.0-ga'
        cls.report=cls.h.probe(cls.home,cls.build/'baseline')
        cls.obj=Path(cls.report['actual_build_directory'])/'scriplib.obj'
        cls.module=cls.h.Module.parse(cls.obj.read_bytes())
        cls.image=cls.h.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())

    @classmethod
    def tearDownClass(cls):cls.temp.cleanup()

    def reject(self,m):
        with self.assertRaises(ValueError):self.h.check_module(m,self.image)

    def test_complete_native_storage_exports_private_state_and_folded_pairs(self):
        p=self.report['verification']
        self.assertTrue(p['verified'])
        self.assertEqual((p['initialized_bytes'],p['zero_fill_bytes'],p['verified_fixups']),(5616,80,225))
        self.assertEqual([(v['target_object'],v['target_offset'],v['compared_bytes']) for v in p['segments']],
                         [(1,559840,4201),(3,24076,1411),(3,68300,4),(3,1864176,80)])
        self.assertEqual(self.report['unique_CODE_intervals'],34)
        self.assertEqual(len(self.report['global_exports']),36)
        self.assertEqual(self.report['private_definitions'],{'_scriptfiles':(3,1864176),'_scriptlibrarycalled':(3,68300)})
        self.assertEqual(self.module.local_externals,{1,2})
        self.assertEqual(self.module.externals[-3:],['_fltused_','__init_387_emulator','__8087'])
        self.assertEqual(self.module.default_libraries,['math387r','emu387'])
        self.assertEqual(self.module.segments[3].data,bytearray(4))
        self.assertEqual(self.module.segments[4].data,bytearray(80))
        for a,b in self.report['compiler_folded_export_pairs']:
            self.assertEqual(self.module.publics[a],self.module.publics[b])
        self.assertTrue(self.report['independent_CODE_anchor']['verified'])
        self.assertFalse(self.report['original_member_used_by_producer'])
        self.assertFalse(self.report['historical_source_identity'])
        self.assertFalse(self.report['full_executable_rebuilt'])
        self.assertEqual(self.report['source_credit'],0)

    def test_all_real_definitions_scope_alias_geometry_unused_imports_and_groups_reject(self):
        for name in self.module.publics:
            m=copy.deepcopy(self.module);del m.publics[name]
            with self.subTest(missing_definition=name):self.reject(m)
        for name in self.module.publics:
            m=copy.deepcopy(self.module)
            if name in m.local_publics:m.local_publics.remove(name)
            else:m.local_publics.add(name)
            with self.subTest(changed_scope=name):self.reject(m)
        for name in ('SCRIPT_PutSection_','SCRIPT_PutRaw_'):
            m=copy.deepcopy(self.module);seg,off=m.publics[name];m.publics[name]=(seg,off+1)
            with self.subTest(folded_export=name):self.reject(m)
        for index in range(len(self.module.externals)):
            m=copy.deepcopy(self.module);m.externals[index]='wrong_role_'
            with self.subTest(import_index=index+1):self.reject(m)
        for attr in ('local_externals','default_libraries','groups','far_call_optimization_segments'):
            m=copy.deepcopy(self.module);getattr(m,attr).clear()
            with self.subTest(metadata=attr):self.reject(m)
        for index in range(5):
            m=copy.deepcopy(self.module);m.segments[index].size+=1
            with self.subTest(segment_extent=index+1):self.reject(m)

    def test_all_function_tails_const_gaps_data_and_bss_reject(self):
        ends=sorted({off for seg,off in self.module.publics.values() if seg==1})[1:]+[4201]
        self.assertEqual(len(ends),34)
        # Every complete public interval includes its compiler alignment/tail.
        for end in ends:
            m=copy.deepcopy(self.module);m.segments[0].data[end-1]^=1
            with self.subTest(CODE_tail=end-1):self.reject(m)
        for index,positions in [(1,(0,49,1410)),(3,range(4)),(4,range(80))]:
            for pos in positions:
                m=copy.deepcopy(self.module);m.segments[index].data[pos]^=1
                with self.subTest(segment=index+1,byte=pos):self.reject(m)
        m=copy.deepcopy(self.module);m.segments[1].data.pop()
        self.reject(m)

    def test_representative_typed_fixup_fields_reject(self):
        # First/middle/final native fields exercise every consumed OMF role;
        # complete descriptor equality already requires all225 records.
        for index in (0,112,224):
            f=self.module.fixups[index]
            fields={'segment':2,'offset':f.offset+1,'width':2,'location':3,
                    'relative':not f.relative,'frame_method':0,'frame':999,
                    'target_method':3,'target':999,'displacement':1}
            for field,value in fields.items():
                m=copy.deepcopy(self.module);m.fixups[index]=dataclasses.replace(f,**{field:value})
                with self.subTest(fixup=index,field=field):self.reject(m)

    def test_actual_source_semantics_callee_storage_scope_and_const_reject(self):
        text=(ROOT/'src/mact/scriplib.c').read_text()
        controls=[('initialization','scriptlibrarycalled = true;','scriptlibrarycalled = false;'),
                  ('default-number','if (*raw==SCRIPTDEFAULTVALUE) return true;','if (*raw==SCRIPTDEFAULTVALUE) return false;'),
                  ('comment-mode','TOKEN_CommentAvailable(tokenhandle,true)','TOKEN_CommentAvailable(tokenhandle,false)'),
                  ('wrong-existing-callee','TOKEN_Free(tokenhandle);','TOKEN_Reset(tokenhandle);'),
                  ('wrapper-role','    SCRIPT_AddSection(handle,sectionname);\n}\n\nvoid SCRIPT_PutRaw','    SCRIPT_SectionExists(handle,sectionname);\n}\n\nvoid SCRIPT_PutRaw'),
                  ('private-storage','static script_t *scriptfiles','script_t *scriptfiles')]
        for name,before,after in controls:
            self.assertEqual(text.count(before),1,name)
            source=self.build/(name+'.c');source.write_text(text.replace(before,after))
            obj=source.with_suffix('.obj')
            self.h.compile_source(self.home,source,obj,self.h.OPTIONS,30,include_dirs=[ROOT/'src/mact/scriplib'])
            with self.subTest(native_source=name):self.reject(self.h.Module.parse(obj.read_bytes()))
        # The literal's size/address stay fixed: its CODE still matches while
        # actual EOL text changes. The whole CONST gate must catch the change.
        before='SCRIPT_PutComment(handle,sectionname," '+r'\0\0'+'");'
        after='SCRIPT_PutComment(handle,sectionname,"'+r'\0\0\0'+'");'
        self.assertEqual(text.count(before),1)
        source=self.build/'EOL.c';source.write_text(text.replace(before,after));obj=source.with_suffix('.obj')
        self.h.compile_source(self.home,source,obj,self.h.OPTIONS,30,include_dirs=[ROOT/'src/mact/scriplib'])
        m=self.h.Module.parse(obj.read_bytes())
        from tools.match_function import compare_range
        p=compare_range(m,1,0,self.image,1,559840,4201,self.report['verification']['publics'],self.report['placements'])
        self.assertTrue(p['match'])
        self.reject(m)

    def staged_inputs(self,name):
        stage=self.build/name;stage.mkdir()
        files=['tools/probe_mact_scriplib.py','modules/mact_scriplib.json','evidence/mact-scriplib-source-reference.json',
               'src/mact/scriplib.c',*self.h.PROOF_TOOLS]
        files += [str(p.relative_to(ROOT)) for p in (ROOT/'src/mact/scriplib').glob('*.h')]
        for file in files:
            dest=stage/file;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/file,dest)
        (stage/'reference').mkdir();shutil.copyfile(ROOT/'reference/DUKE3D.EXE',stage/'reference/DUKE3D.EXE')
        return stage

    def test_source_only_staging_without_sdk_objects_research_or_coverage(self):
        stage=self.staged_inputs('source-only')
        self.assertFalse(list(stage.rglob('*.obj')))
        self.assertFalse(list(stage.rglob('*.LIB')))
        self.assertFalse((stage/'build').exists())
        self.assertFalse((stage/'evidence/mact_scriplib-module.json').exists())
        report_path=self.build/'standalone-proof.json'
        result=subprocess.run([sys.executable,str(stage/'tools/probe_mact_scriplib.py'),
            '--home',str(self.home),'--build',str(self.build/'source-only-output'),
            '--report',str(report_path)],cwd=stage,env={**os.environ,'PYTHONPATH':''},
            capture_output=True,text=True,timeout=60)
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        report=json.loads(report_path.read_text())
        self.assertEqual(report['verification'],json.loads(json.dumps(self.report['verification'])))
        self.assertEqual(report['source_geometry'],self.report['source_geometry'])
        self.assertFalse(report['original_member_used_by_producer'])

    def test_real_compile_source_and_header_races_reject_and_preserve_logs(self):
        for name,relative in [('source-race','src/mact/scriplib.c'),
                              ('header-race','src/mact/scriplib/types.h')]:
            stage=self.staged_inputs(name);original=self.h.compile_source
            def compile_and_change(*args,**kwargs):
                value=original(*args,**kwargs)
                p=stage/relative;p.write_bytes(p.read_bytes()+b'\n/* changed after compile */\n')
                return value
            with mock.patch.object(self.h,'ROOT',stage),mock.patch.object(self.h,'compile_source',compile_and_change):
                with self.subTest(race=name),self.assertRaisesRegex(ValueError,'changed during production'):
                    self.h.probe(self.home,self.build/(name+'-output'))
            self.assertTrue(list((self.build/(name+'-output')).rglob('scriplib.obj')))
            self.assertTrue(list((self.build/(name+'-output')).rglob('scriplib.log')))

    def test_descriptor_lineage_and_existing_header_identity_reject_before_compile(self):
        for name,relative in [('descriptor','modules/mact_scriplib.json'),
                              ('lineage','evidence/mact-scriplib-source-reference.json'),
                              ('header','src/mact/scriplib/types.h')]:
            stage=self.staged_inputs('identity-'+name);p=stage/relative;p.write_bytes(p.read_bytes()+b' ')
            with mock.patch.object(self.h,'ROOT',stage),mock.patch.object(self.h,'compile_source') as compiler:
                with self.subTest(identity=name),self.assertRaises(ValueError):
                    self.h.probe(self.home,self.build/('identity-'+name+'-output'))
                compiler.assert_not_called()

if __name__=='__main__':unittest.main()
