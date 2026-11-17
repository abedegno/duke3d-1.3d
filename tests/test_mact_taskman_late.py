"""Normal late TASK_MAN physical owner, selected earlier global, strict defaults."""
import importlib.util,json,os,shutil,subprocess,sys,tempfile,unittest,copy,dataclasses
from unittest.mock import patch
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class LateTaskMan(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools import probe_mact_taskman_late as c
  cls.c=c;cls.home=ROOT/'toolchains/watcom-10.5';cls.work=Path(tempfile.mkdtemp(prefix='mact-taskman-late-tests-',dir=ROOT/'build'));cls.report=c.probe(cls.home,cls.work/'normal')
 def project(self,name):
  c=self.c;p=self.work/name;p.mkdir();paths=set(c.SOURCES+c.NOTICES+c.TOOLS+[c.DESCRIPTOR,c.PROVENANCE])
  for n in paths:q=p/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
  return p
 def test_normal_source_capsule_and_required_duplicate_rejection(self):
  self.assertTrue((ROOT/'tools/probe_mact_taskman_late.py').is_file(),'normal late TASK_MAN capsule is missing')
  from tools import probe_mact_taskman_late as c
  r=self.report
  p=r['physical_verification'];self.assertTrue(p['verified']);self.assertEqual((p['initialized_bytes'],p['zero_fill_bytes'],p['verified_fixups']),(1191,42,82));self.assertEqual(r['default_whole_verification_failures'],{'source':'conflicting binding for public _TS_InInterrupt','original':'conflicting binding for public _TS_InInterrupt'});self.assertEqual(r['selected_early_interrupt_global'],[3,58380]);self.assertEqual(r['physical_global_definitions']['_TS_InInterrupt'],[3,68292]);self.assertEqual(len(r['private_symbols']),13);self.assertEqual(r['private_reference_count'],69);self.assertEqual(r['source_credit'],0);self.assertFalse(r['whole_module_default_verified'])

 def test_observer_rechecks_current_emulator_before_early_native_replay(self):
  c=self.c;fake=self.work/'untrusted-emulator';fake.write_text('actual different bytes, never execute')
  with patch.dict(os.environ,{'EXHUME_DOSBOX_X':str(fake)}),patch.object(c,'early_owner',side_effect=AssertionError('observer must reject before invoking native'))as native:
   with self.assertRaisesRegex(ValueError,'emulator/Python'):c.observe(self.report,self.home)
   native.assert_not_called()


 def module(self):return self.c.Module.parse(Path(self.report['object']).read_bytes())
 def test_standalone_source_only_and_optimized_guards(self):
  c=self.c;p=self.project('standalone');cmd=[sys.executable,'-O',str(p/'tools/probe_mact_taskman_late.py'),'--source-only','--home',str(self.home.resolve()),'--build',str(p/'native'),'--report',str(p/'source.json')];run=subprocess.run(cmd,capture_output=True,text=True);(p/'CLI.LOG').write_text(run.stdout+run.stderr);self.assertEqual(run.returncode,0,run.stderr);r=json.loads((p/'source.json').read_text());self.assertTrue(r['source_only']);self.assertFalse(r['target_SDK_or_caller_read_during_production']);self.assertEqual(r['normal_native_inventory'],self.report['normal_native_inventory']);self.assertFalse((p/'reference').exists());self.assertFalse(any('/reference/'in x or '/task475'in x for x in r['inputs_sha256']))
  q=self.project('optimized-missing-notice');e=json.loads((q/c.PROVENANCE).read_text());del e['notices_sha256'][c.NOTICES[0]];c.dump(q/c.PROVENANCE,e);(q/c.NOTICES[0]).unlink();bad=[sys.executable,'-O',str(q/'tools/probe_mact_taskman_late.py'),'--source-only','--home',str(self.home.resolve()),'--build',str(q/'native'),'--report',str(q/'source.json')];run=subprocess.run(bad,capture_output=True,text=True);self.assertNotEqual(run.returncode,0);self.assertIn('closed late TASK_MAN notices',run.stderr);self.assertFalse(list(q.rglob('*.OBJ')))
 def test_exact_source_notices_and_live_primary_recipe(self):
  c=self.c;self.assertEqual(c.digest(ROOT/c.SOURCE),'a7e33dd80ddc6c9ebb43f9e39b0e46230223da80259d0618bf8bf747d6f23a5d');self.assertEqual(c.digest(ROOT/c.MODEL/'gpl.txt'),'3f9d5f29ecf12b61c4c20045e23e01c717182fa862bb1e97afa19a91a0ef68c4');self.assertEqual(set(c.HEADERS),{'types.h','develop.h','linklist.h','task_man.h','util_lib.h'});self.assertEqual(self.report['compiler_sha256'],c.COMPILER_SHA);self.assertEqual(len(self.report['tool_home_sha256']),1114)
 def test_source_header_notice_profile_keysets_reject_before_native(self):
  c=self.c
  for i,path in enumerate([c.SOURCE,next(iter(c.HEADERS.values())),c.NOTICES[0],c.PROFILE]):
   p=self.project('changed-'+str(i));q=p/path;q.write_bytes(q.read_bytes()+b'\nchanged')
   with patch.object(c,'ROOT',p),patch.object(c,'compile_source')as native:
    with self.assertRaises(ValueError):c.build_source(self.home,p/'native')
    native.assert_not_called()
  for i,field in enumerate(['sources_sha256','notices_sha256','producer_tools_sha256','observer_tools_sha256']):
   p=self.project('missing-map-'+str(i));e=json.loads((p/c.PROVENANCE).read_text());del e[field][next(iter(e[field]))];c.dump(p/c.PROVENANCE,e)
   with patch.object(c,'ROOT',p),patch.object(c,'compile_source')as native:
    with self.assertRaises(ValueError):c.build_source(self.home,p/'native')
    native.assert_not_called()
 def test_copy_snapshot_stage_and_output_races(self):
  c=self.c;p=self.project('copy-race');original_copy=c.shutil.copyfile
  def copied(src,dst,*a,**kw):
   ret=original_copy(src,dst,*a,**kw)
   if Path(src)==p/c.SOURCE:(p/c.SOURCE).write_bytes((p/c.SOURCE).read_bytes()+b'\nactual live change')
   return ret
  with patch.object(c,'ROOT',p),patch.object(c.shutil,'copyfile',copied),patch.object(c,'compile_source')as native:
   with self.assertRaises(ValueError):c.build_source(self.home,p/'native')
   native.assert_not_called()
  original_compile=c.compile_source
  def staged(home,src,obj,*a,**kw):
   ret=original_compile(home,src,obj,*a,**kw);Path(src).write_bytes(Path(src).read_bytes()+b'\nactual staged change');return ret
  with patch.object(c,'compile_source',staged),self.assertRaisesRegex(ValueError,'staged TASK_MAN'):c.build_source(self.home,self.work/'stage-race')
  original_snapshot=c.snapshot;hit=[]
  def outputs(paths):
   paths=list(paths);pins=original_snapshot(paths)
   for path in paths:
    if Path(path).suffix=='.OBJ':
     b=Path(path).read_bytes();Path(path).write_bytes(b[:-1]+bytes([b[-1]^1]));hit.append(str(path))
   return pins
  with patch.object(c,'snapshot',outputs),self.assertRaisesRegex(ValueError,'output changed'):c.build_source(self.home,self.work/'output-race')
  self.assertEqual(len(hit),1)
 def test_complete_home_extra_file_race(self):
  c=self.c;own=self.work/'private-home';shutil.copytree(self.home,own,copy_function=os.link);original=c.compile_source
  def race(*a,**kw):
   r=original(*a,**kw);(own/'UNEXPECTED.META').write_text('new private leaf only');return r
  with patch.object(c,'compile_source',race),self.assertRaisesRegex(ValueError,'complete1114-file'):c.build_source(own,self.work/'home-race')
 def test_all_native_scope_data_E9_and_typed_metadata_enforced(self):
  c=self.c;s=json.loads((ROOT/c.DESCRIPTOR).read_text())
  for what in ['scope','lextern','far-owner','data','tail','unknown','field']:
   m=self.module()
   if what=='scope':m.local_publics.remove('_TaskList')
   elif what=='lextern':m.local_externals.remove(2)
   elif what=='far-owner':m.publics['_OldInt8']=(5,32)
   elif what=='data':m._segment(4).data[12]^=1
   elif what=='tail':m._segment(1).size-=1;m._segment(1).data.pop()
   elif what=='unknown':m.unexpected_scope=1
   else:m.fixups[-1]=dataclasses.replace(m.fixups[-1],target=2)
   with self.subTest(what=what),self.assertRaises(ValueError):c.validate_native(m,s)
  m=self.module();idx=next(i for i,(k,b)in enumerate(m.comments)if k==233 and b);k,b=m.comments[idx];m.comments[idx]=(k,bytes([b[0]^1])+b[1:]);c.validate_native(m,s);self.assertNotEqual(c.inventory(m),c.inventory(self.module()))
  m.comments[idx]=(k,b[:5]+b'X'+b[6:])
  with self.assertRaises(ValueError):c.validate_native(m,s)
 def test_real_C_IRQ_and_PIT_behavior_full_interval_negatives(self):
  c=self.c;from le import LEImage
  image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):tuple(v)for k,v in self.report['physical_placements'].items()};bindings={**self.report['selected_reference_bindings'],**self.report['private_symbols']};positive=self.module();src=(ROOT/c.SOURCE).read_bytes()
  for name,old,new in [('IRQ-count',b'ptr->count -= ptr->rate;',b'ptr->count += ptr->rate;'),('PIT-command',b'outp( 0x43, 0x36 );',b'outp( 0x43, 0x34 );')]:
   d=self.work/name;d.mkdir();p=d/'task_man.c';self.assertIn(old,src);p.write_bytes(src.replace(old,new,1));obj=d/'CHANGE.OBJ';c.compile_source(self.home,p,obj,c.OPTIONS,45,include_dirs=[Path(self.report['native_build_directory'])/'source-only/include']);m=c.Module.parse(obj.read_bytes());self.assertEqual(m.publics,positive.publics);self.assertEqual(m.fixups,positive.fixups)
   with self.subTest(name=name),self.assertRaisesRegex(ValueError,'differing bytes'):c.physical_checks(m,image,places,bindings)
 def test_private_reference_no_alias_and_full_final_byte_controls(self):
  c=self.c;from le import LEImage
  image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());p={int(k):tuple(v)for k,v in self.report['physical_placements'].items()};b={**self.report['selected_reference_bindings'],**self.report['private_symbols']};m=self.module();wrong={**b,'_TS_InInterrupt':tuple(self.report['physical_global_definitions']['_TS_InInterrupt'])}
  with self.assertRaises(ValueError):c.physical_checks(m,image,p,wrong)
  m=self.module();m._segment(1).data[-1]^=1
  with self.assertRaisesRegex(ValueError,'differing bytes'):c.physical_checks(m,image,p,b)
  m=self.module();m.publics['_OldInt8']=(5,32)
  with self.assertRaises(ValueError):c.derive_physical(m,image,1,p[1][1],self.report['selected_early_interrupt_global'])

if __name__=='__main__':unittest.main()
