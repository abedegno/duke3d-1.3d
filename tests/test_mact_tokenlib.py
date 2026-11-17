"""Complete native TOKENLIB candidate contract and real source-only consumer."""
import importlib
import copy
import dataclasses
import os
import shutil
import subprocess
import tempfile
from unittest import mock
import json
from pathlib import Path
import sys
import unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]

class TokenlibContract(unittest.TestCase):
    def test_complete_producer_contract_exists(self):
        self.assertTrue((ROOT/'modules/mact_tokenlib.json').is_file(),'missing complete TOKENLIB native contract')
        h=importlib.import_module('tools.probe_mact_tokenlib');spec=h.load_spec()
        self.assertEqual(spec['expected'],dict(initialized_bytes=3033,zero_fill_bytes=208,verified_fixups=131))
        self.assertEqual(len(spec['inventory']['publics']),23)
        self.assertEqual(spec['inventory']['local_publics'],['_tokenfiles','_tokenlibrarycalled'])
        self.assertEqual(len(spec['inventory']['fixups']),131)

class NativeTokenlib(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.h=importlib.import_module('tools.probe_mact_tokenlib')
        cls.temp=tempfile.TemporaryDirectory(prefix='tokenlib-test-');cls.build=Path(cls.temp.name)
        cls.home=ROOT/'toolchains/watcom-10.0-ga'
        cls.report=cls.h.probe(cls.home,cls.build/'baseline')
        cls.obj=Path(cls.report['actual_build_directory'])/'tokenlib.obj'
        cls.module=cls.h.Module.parse(cls.obj.read_bytes())
        cls.image=cls.h.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())

    @classmethod
    def tearDownClass(cls):cls.temp.cleanup()

    def reject(self,module):
        with self.assertRaises(ValueError):self.h.check_module(module,self.image)

    def test_whole_native_storage_scopes_roles_and_all_public_geometry(self):
        p=self.report['verification'];self.assertTrue(p['verified'])
        self.assertEqual((p['initialized_bytes'],p['zero_fill_bytes'],p['verified_fixups']),(3033,208,131))
        self.assertEqual([(v['target_object'],v['target_offset'],v['compared_bytes']) for v in p['segments']],
                         [(1,557728,2110),(3,23156,919),(3,68296,4),(3,1863968,208)])
        self.assertEqual(len(self.module.publics),23);self.assertEqual(len(self.report['global_exports']),21)
        self.assertEqual(self.report['unique_CODE_intervals'],20)
        self.assertEqual(self.report['global_exports']['_token'],(3,1864048))
        self.assertEqual(self.report['private_definitions'],{'_tokenfiles':(3,1863968),'_tokenlibrarycalled':(3,68296)})
        self.assertEqual(self.module.local_externals,{1,15})
        self.assertEqual(self.module.externals[-3:],['_fltused_','__init_387_emulator','__8087'])
        self.assertEqual(self.module.default_libraries,['math387r','emu387'])
        self.assertEqual(self.module.segments[3].data,bytearray(4));self.assertEqual(self.module.segments[4].data,bytearray(208))
        self.assertTrue(self.report['independent_CODE_anchor']['verified'])
        self.assertFalse(self.report['original_member_used_by_producer'])
        self.assertFalse(self.report['historical_source_identity']);self.assertFalse(self.report['full_executable_rebuilt'])
        self.assertEqual(self.report['source_credit'],0)

    def test_all_definition_scope_import_and_segment_contract_mutations_reject(self):
        for name in self.module.publics:
            m=copy.deepcopy(self.module);del m.publics[name]
            with self.subTest(missing=name):self.reject(m)
            m=copy.deepcopy(self.module)
            if name in m.local_publics:m.local_publics.remove(name)
            else:m.local_publics.add(name)
            with self.subTest(scope=name):self.reject(m)
        for index in range(len(self.module.externals)):
            m=copy.deepcopy(self.module);m.externals[index]='wrong_role_'
            with self.subTest(import_index=index+1):self.reject(m)
        for attr in ('local_externals','groups','default_libraries','far_call_optimization_segments'):
            m=copy.deepcopy(self.module);getattr(m,attr).clear()
            with self.subTest(metadata=attr):self.reject(m)
        for index in range(5):
            m=copy.deepcopy(self.module);m.segments[index].size+=1
            with self.subTest(segment=index+1):self.reject(m)

    def test_whole_function_tails_const_gap_terminal_state_and_bss_boundaries_reject(self):
        ends=sorted({off for seg,off in self.module.publics.values() if seg==1})[1:]+[2110]
        self.assertEqual(len(ends),20)
        for end in ends:
            m=copy.deepcopy(self.module);m.segments[0].data[end-1]^=1
            with self.subTest(CODE_tail=end-1):self.reject(m)
        for index,positions in [(1,(0,46,918)),(3,range(4)),(4,(0,79,80,207))]:
            for pos in positions:
                m=copy.deepcopy(self.module);m.segments[index].data[pos]^=1
                with self.subTest(segment=index+1,offset=pos):self.reject(m)
        m=copy.deepcopy(self.module);m.segments[1].data.pop();self.reject(m)

    def test_representative_complete_typed_fixup_fields_reject(self):
        for index in (0,65,130):
            f=self.module.fixups[index]
            fields={'segment':2,'offset':f.offset+1,'width':2,'location':3,'relative':not f.relative,
                    'frame_method':0,'frame':999,'target_method':3,'target':999,'displacement':1}
            for field,value in fields.items():
                m=copy.deepcopy(self.module);m.fixups[index]=dataclasses.replace(f,**{field:value})
                with self.subTest(fixup=index,field=field):self.reject(m)

    def test_actual_native_source_behavior_callee_scope_and_const_controls(self):
        text=(ROOT/'src/mact/tokenlib.c').read_text()
        controls=[('initial-state','tokenlibrarycalled=true;','tokenlibrarycalled=false;'),
                  ('unget','TOKENFILE(handle,tokenready)=true;','TOKENFILE(handle,tokenready)=false;'),
                  ('crossline','if (!crossline)','if (crossline)'),
                  ('raw-copy','memcpy(token,start,length+1);','memcpy(token,start,length);'),
                  ('line-limit','if (length<MAXTOKEN-1)','if (length<MAXTOKEN)'),
                  ('record-restore','memcpy(tokenfiles[handle],&saved,sizeof(token_t));','memcpy(tokenfiles[handle],&saved,sizeof(token_t)-4);'),
                  ('wrong-existing-callee','TOKEN_Get(handle,crossline);\n    *number=atoi(token);','TOKEN_GetLine(handle,crossline);\n    *number=atoi(token);'),
                  ('private-state','static token_t *tokenfiles','token_t *tokenfiles'),
                  ('literal','TOKEN_GetLineNumber: not a valid tokenhandle','TOKEN_GetLineNumber: not a Valid tokenhandle')]
        for name,a,b in controls:
            self.assertIn(a,text,name);source=self.build/(name+'.c');source.write_text(text.replace(a,b,1));obj=source.with_suffix('.obj')
            self.h.compile_source(self.home,source,obj,self.h.OPTIONS,30,include_dirs=[ROOT/'src/mact/tokenlib'])
            m=self.h.Module.parse(obj.read_bytes())
            if name=='literal':
                from tools.match_function import compare_range
                q=compare_range(m,1,0,self.image,1,557728,2110,self.report['verification']['publics'],self.report['placements'])
                self.assertTrue(q['match'])
            with self.subTest(native_source=name):self.reject(m)

    def staged_inputs(self,name):
        stage=self.build/name;stage.mkdir()
        files=['tools/probe_mact_tokenlib.py','modules/mact_tokenlib.json','evidence/mact-tokenlib-source-reference.json',
               'src/mact/tokenlib.c',*self.h.PROOF_TOOLS]
        files += [str(p.relative_to(ROOT)) for p in (ROOT/'src/mact/tokenlib').glob('*.h')]
        for file in files:
            dest=stage/file;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/file,dest)
        (stage/'reference').mkdir();shutil.copyfile(ROOT/'reference/DUKE3D.EXE',stage/'reference/DUKE3D.EXE')
        return stage

    def test_standalone_cli_without_sdk_research_or_prior_receipts(self):
        stage=self.staged_inputs('standalone');report_path=self.build/'standalone-proof.json'
        self.assertFalse(list(stage.rglob('*.obj')));self.assertFalse(list(stage.rglob('*.LIB')))
        result=subprocess.run([sys.executable,str(stage/'tools/probe_mact_tokenlib.py'),'--home',str(self.home),
            '--build',str(self.build/'standalone-output'),'--report',str(report_path)],cwd=stage,
            env={**os.environ,'PYTHONPATH':''},capture_output=True,text=True,timeout=60)
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        report=json.loads(report_path.read_text())
        self.assertEqual(report['verification'],json.loads(json.dumps(self.report['verification'])))
        self.assertEqual(report['source_geometry'],self.report['source_geometry'])

    def test_real_source_and_header_races_reject(self):
        for name,relative in [('source','src/mact/tokenlib.c'),('header','src/mact/tokenlib/types.h')]:
            stage=self.staged_inputs('race-'+name);original=self.h.compile_source
            def compile_and_change(*args,**kwargs):
                value=original(*args,**kwargs);p=stage/relative;p.write_bytes(p.read_bytes()+b'\n/* postcompile change */\n');return value
            with mock.patch.object(self.h,'ROOT',stage),mock.patch.object(self.h,'compile_source',compile_and_change):
                with self.subTest(race=name),self.assertRaisesRegex(ValueError,'changed during production'):
                    self.h.probe(self.home,self.build/('race-'+name+'-output'))

    def test_precompile_source_header_descriptor_and_lineage_identity_reject(self):
        for name,relative in [('source','src/mact/tokenlib.c'),('header','src/mact/tokenlib/types.h'),
                              ('descriptor','modules/mact_tokenlib.json'),('lineage','evidence/mact-tokenlib-source-reference.json')]:
            stage=self.staged_inputs('identity-'+name);p=stage/relative;p.write_bytes(p.read_bytes()+b' ')
            with mock.patch.object(self.h,'ROOT',stage),mock.patch.object(self.h,'compile_source') as compiler:
                with self.subTest(identity=name),self.assertRaises(ValueError):
                    self.h.probe(self.home,self.build/('identity-'+name+'-output'))
                compiler.assert_not_called()

    def test_source_only_consumer_with_real_full_mact_file_util_and_stock_crt(self):
        from runner import compile_source,run_batch
        from tools import probe_mact_util,probe_mact_file
        folder=self.build/'consumer';folder.mkdir()
        for label,source,checker in [('UTIL','src/mact/util_lib.c',probe_mact_util),('FILE','src/mact/file_lib.c',probe_mact_file)]:
            obj=folder/(label+'.OBJ');compile_source(self.home,ROOT/source,obj,self.h.OPTIONS,30)
            checker.check_module(self.h.Module.parse(obj.read_bytes()),self.image)
        compile_source(self.home,ROOT/'tests/fixtures/mact-tokenlib-consumer.c',folder/'MAIN.OBJ',self.h.OPTIONS,30,
                       include_dirs=[ROOT/'src/mact/tokenlib'])
        shutil.copyfile(self.obj,folder/'TOKEN.OBJ')
        (folder/'LINK.LNK').write_text('system dos4g\noption quiet,map=LINK.MAP,stack=8192\nname LINK.EXE\nfile MAIN.OBJ,TOKEN.OBJ,UTIL.OBJ,FILE.OBJ\n')
        batch=('@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
               'set LIB=D:\\LIB386;D:\\LIB386\\DOS\r\nwlink @LINK.LNK > LINK.LOG\r\n'
               'if errorlevel 1 goto failed\r\necho OK>LINK.STA\r\nLINK.EXE > RUN.LOG\r\n'
               'if errorlevel 1 goto failed\r\necho OK>RUN.STA\r\ngoto end\r\n:failed\r\necho FAILED>LINK.STA\r\n:end\r\n')
        run_batch(self.home,folder,batch,30)
        self.assertEqual((folder/'LINK.STA').read_text().strip(),'OK',(folder/'LINK.LOG').read_text())
        self.assertEqual((folder/'RUN.STA').read_text().strip(),'OK',(folder/'RUN.LOG').read_text())
        self.assertIn('TOKENLIB_OK',(folder/'RUN.LOG').read_text())
        self.assertTrue((folder/'LINK.EXE').is_file())
        # A client naming the real private table must fail native linkage.
        private=folder/'PRIVATE.C'
        private.write_text('#include "types.h"\n#include "_tokenli.h"\n'
                           'extern token_t *tokenfiles[MAXTOKENFILES];\n'
                           'int main(void) { return tokenfiles[0] != 0; }\n')
        compile_source(self.home,private,folder/'PRIVATE.OBJ',self.h.OPTIONS,30,include_dirs=[ROOT/'src/mact/tokenlib'])
        (folder/'PRIV.LNK').write_text('system dos4g\noption quiet,map=PRIV.MAP\nname PRIV.EXE\nfile PRIVATE.OBJ,TOKEN.OBJ,UTIL.OBJ,FILE.OBJ\n')
        run_batch(self.home,folder,'@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
                  'set LIB=D:\\LIB386;D:\\LIB386\\DOS\r\nwlink @PRIV.LNK > PRIV.LOG\r\n'
                  'if errorlevel 1 goto failed\r\necho OK>PRIV.STA\r\ngoto end\r\n:failed\r\necho FAILED>PRIV.STA\r\n:end\r\n',30)
        self.assertEqual((folder/'PRIV.STA').read_text().strip(),'FAILED')
        self.assertRegex((folder/'PRIV.LOG').read_text(),r'(?i)_tokenfiles.*undefined|undefined.*_tokenfiles')
        self.assertFalse((folder/'PRIV.EXE').exists())

if __name__=='__main__':unittest.main()
