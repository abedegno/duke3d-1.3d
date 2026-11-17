"""Closed complete VECTOR source owner and real ABI behavior."""
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
class Availability(unittest.TestCase):
 def test_normal_source_producer_exists(self):
  self.assertTrue((ROOT/'tools/probe_mact_vector.py').is_file(),'normal VECTOR producer is missing')
if __name__=='__main__':unittest.main()

from copy import deepcopy
from dataclasses import replace
from unittest.mock import patch
import json,os,shutil,subprocess,sys,tempfile
from tools import probe_mact_vector as c
from tools import prove_module as driver
HOME=Path(os.environ.get('WATCOM_HOME',str(ROOT/'toolchains/watcom-10.0-ga')))
class VectorNative(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  (ROOT/'build').mkdir(exist_ok=True);cls.work=Path(tempfile.mkdtemp(prefix='vector-tests-',dir=ROOT/'build'));cls.report=driver.prove('mact_vector',HOME,cls.work/'normal');cls.native=Path(cls.report['native_build_directory']);cls.module=c.Module.parse((cls.native/'VECTOR.OBJ').read_bytes());cls.e,cls.spec,_=c.read_provenance()
  from le import LEImage
  cls.image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());cls.original=c.reference_module((ROOT/c.LIBRARY).read_bytes(),cls.e);cls.base=cls.report['placements'][1][1];c.dump(cls.work/'whole-proof.json',cls.report)
 def check(self,m):return c.check_module(m,self.image,self.original,self.base,self.spec)
 def stage(self,name):
  d=self.work/name;d.mkdir()
  for p in[*c.SOURCES,*c.NOTICES,*c.TOOLS,c.DESCRIPTOR,c.PROVENANCE]:q=d/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,q)
  return d
 def test_normal_complete_native_roles_and_all_metadata(self):
  self.assertEqual(self.report['verification']['initialized_bytes'],735);self.assertEqual(self.report['verification']['verified_fixups'],3);self.assertEqual(self.report['reference_verification']['verified_fixups'],5);self.assertEqual(self.module.publics,c.PUBLICS);self.assertEqual(self.module.externals,c.IMPORTS);self.assertEqual(self.module.default_libraries,['math387r','emu387']);self.assertEqual(len(self.report['all_original_roles']),5)
  self.assertEqual(self.report['nomination']['size'],211);self.assertEqual(self.report['nomination']['unmasked_bytes'],211);self.assertEqual(len(self.report['all_candidates']),1);self.assertTrue(self.report['all_candidates'][0]['full_source_and_original_pass']);self.assertEqual(len(self.report['tool_home_sha256']),500);self.assertFalse(self.report['full_executable_rebuilt']);self.assertEqual((self.native/'VECTOR.ASM').read_bytes(),(ROOT/c.SOURCE).read_bytes());self.assertEqual(self.report['normal_native_inventory'],c.inventory(self.module))
 def test_standalone_minimal_source_only_and_python_O_guards(self):
  d=self.stage('standalone');self.assertFalse((d/'reference').exists());target=d/'producer.json';cmd=[sys.executable,'-O',str(d/'tools/probe_mact_vector.py'),'--source-only','--home',str(HOME),'--build',str(d/'native'),'--report',str(target)];p=subprocess.run(cmd,capture_output=True,text=True);(d/'execution.log').write_text(p.stdout+p.stderr);self.assertEqual(p.returncode,0,p.stderr);r=json.loads(target.read_text());self.assertTrue(r['source_only']);self.assertFalse(r['original_or_target_read_during_production']);self.assertFalse(any('reference/'in p for p in r['producer_inputs_sha256']));self.assertEqual(r['object_sha256'],self.report['object_sha256']);self.assertEqual(r['normal_native_inventory'],self.report['normal_native_inventory'])
  bad=d/c.SOURCE;bad.write_bytes(bad.read_bytes().replace(b'extrn _fltused_:byte',b''));p=subprocess.run(cmd,capture_output=True,text=True);self.assertNotEqual(p.returncode,0);self.assertIn('ValueError',p.stderr)
 def test_observer_starts_only_after_fresh_object(self):
  state={'built':False};real=c.build_source;observe=c.reference_module
  def built(*args,**kw):r=real(*args,**kw);self.assertTrue(Path(r['object']).is_file());state['built']=True;return r
  def observed(*args,**kw):self.assertTrue(state['built']);return observe(*args,**kw)
  with patch.object(c,'build_source',side_effect=built),patch.object(c,'reference_module',side_effect=observed):self.assertEqual(c.probe(HOME,self.work/'ordered')['verification'],self.report['verification'])
 def test_actual_semantic_ABI_and_resolved_call_source_controls(self):
  source=(ROOT/c.SOURCE).read_bytes();cases=[('sqrt',b' fsqrt',b' fabs'),('normalization',b' fdiv qword ptr [esp+LENGTH_HOME]',b' fmul qword ptr [esp+LENGTH_HOME]'),('cross-callee',b' call FP_CrossProduct_',b' call FP_VectorAdd_'),('stack-cleanup',b' ret 16',b' ret 12')]
  for name,old,new in cases:
   self.assertIn(old,source);d=self.work/name;d.mkdir();p=d/'VECTOR.ASM';p.write_bytes(source.replace(old,new,1));native=c.assemble(HOME,p,d/'native');m=c.Module.parse((native/'VECTOR.OBJ').read_bytes());self.assertEqual(c.inventory(m),c.inventory(self.module))
   with self.subTest(name=name),self.assertRaises(ValueError):self.check(m)
 def test_unused_import_default_library_and_export_reject_before_native(self):
  source=(ROOT/c.SOURCE).read_bytes()
  for name,old,new in[('unused',b'extrn _fltused_:byte',b''),('defaultlib',b'includelib emu387',b''),('export',b'public FP_VectorAdd_',b'public invented_,FP_VectorAdd_')]:
   self.assertIn(old,source);d=self.work/name;d.mkdir();p=d/'VECTOR.ASM';p.write_bytes(source.replace(old,new,1))
   with self.subTest(name=name),patch.object(c,'run_batch')as native,self.assertRaises(ValueError):c.assemble(HOME,p,d/'native')
   native.assert_not_called()
 def test_complete_raw_inventory_private_scope_field_and_fulltail_controls(self):
  for name in['localpub','localext','unused-import','lib','group','segment','encoding','field','width','unknown','tail','trim']:
   m=deepcopy(self.module)
   if name=='localpub':m.local_publics.add('FP_VectorAdd_')
   elif name=='localext':m.local_externals.add(1)
   elif name=='unused-import':m.externals.pop()
   elif name=='lib':m.default_libraries.pop()
   elif name=='group':m.groups.reverse()
   elif name=='segment':m.segments[1].size=1;m.segments[1].data.append(0)
   elif name=='encoding':m.fixup_encodings[0]['raw_fixdat']^=1
   elif name=='field':m.fixups[0]=replace(m.fixups[0],target=2)
   elif name=='width':m.fixups[0]=replace(m.fixups[0],width=2)
   elif name=='unknown':m.extra=True
   elif name=='tail':m.segments[0].data[-1]^=1
   else:m.segments[0].size-=1;m.segments[0].data.pop()
   with self.subTest(name=name),self.assertRaises(ValueError):self.check(m)
 def test_source_counterpart_notice_tools_and_closed_keysets(self):
  for name,p in[('source',c.SOURCE),('counterpart',c.COUNTERPART),('notice',c.NOTICES[0]),('tool','profiles/watcom/tools/runner.py'),('descriptor',c.DESCRIPTOR)]:
   d=self.stage('bad-'+name);q=d/p;q.write_bytes(q.read_bytes()+b'\nchanged')
   with self.subTest(name=name),patch.object(c,'ROOT',d),patch.object(c,'assemble')as native,self.assertRaises(ValueError):c.build_source(HOME,d/'native')
   native.assert_not_called()
  d=self.stage('bad-notice-key');p=d/c.PROVENANCE;e=json.loads(p.read_text());del e['notices_sha256'][c.NOTICES[0]];p.write_text(json.dumps(e))
  with patch.object(c,'ROOT',d),patch.object(c,'assemble')as native,self.assertRaises(ValueError):c.build_source(HOME,d/'native')
  native.assert_not_called()
 def test_actual_private_tool_home_extra_file_race(self):
  home=self.work/'private-GA';shutil.copytree(HOME,home,symlinks=True);real=c.run_batch
  def race(*args,**kw):real(*args,**kw);(home/'EXTRA.FILE').write_text('real unexpected tool-home file')
  with patch.object(c,'run_batch',side_effect=race),self.assertRaisesRegex(ValueError,'complete VECTOR GA tool home'):c.assemble(home,ROOT/c.SOURCE,self.work/'tool-race')
 def test_actual_staged_and_live_source_races(self):
  real=c.assemble
  for kind in['staged','live']:
   d=self.stage('race-'+kind)
   def race(home,source,build):
    r=real(home,source,build);p=Path(source)if kind=='staged'else d/c.SOURCE;p.write_bytes(p.read_bytes()+b'\n; race\n');return r
   with self.subTest(kind=kind),patch.object(c,'ROOT',d),patch.object(c,'assemble',side_effect=race),self.assertRaisesRegex(ValueError,'changed during production'):c.build_source(HOME,d/'native')
 def test_real_source_only_consumer_all_ten_APIs(self):
  d=self.work/'consumer';d.mkdir();source=ROOT/'tests/fixtures/mact-vector-consumer.c';obj=d/'MAIN.OBJ';c.compile_source(HOME,source,obj,['/omaxnet','/zp4','/5r'],45,include_dirs=[ROOT/c.MODEL/'include']);shutil.copyfile(self.native/'VECTOR.OBJ',d/'VECTOR.OBJ');(d/'LINK.LNK').write_text('system dos4g\noption quiet\nname OUT.EXE\noption map=OUT.MAP\nfile MAIN.OBJ\nfile VECTOR.OBJ\n');c.run_batch(HOME,d,'@echo off\r\nset PATH=D:\\BINB;D:\\BIN\r\nset WATCOM=D:\r\nset LIB=D:\\LIB386;D:\\LIB386\\DOS\r\nwlink @LINK.LNK > LINK.LOG\r\nif errorlevel 1 goto failed\r\nOUT.EXE > RUN.LOG\r\nif errorlevel 1 goto failed\r\necho PASS>STATUS.TXT\r\ngoto done\r\n:failed\r\necho FAILED>STATUS.TXT\r\n:done\r\n',45);self.assertEqual((d/'STATUS.TXT').read_text().strip(),'PASS');self.assertFalse(list(d.glob('*.LIB')))

 def test_every_nominee_requires_whole_gate(self):
  from tools import map_candidates
  real=map_candidates.locate
  def extra(*args,**kw):
   rows=real(*args,**kw);row=next(r for r in rows if r['symbol']=='FP_RotateVAV_');row['locations'].insert(0,{'object':1,'offset':row['locations'][0]['offset']+1});return rows
  with patch.object(map_candidates,'locate',side_effect=extra):r=c.probe(HOME,self.work/'extra-nominee')
  self.assertEqual(len(r['all_candidates']),2);self.assertIn('rejection',r['all_candidates'][0]);self.assertTrue(r['all_candidates'][1]['full_source_and_original_pass']);self.assertEqual(r['verification'],self.report['verification'])
