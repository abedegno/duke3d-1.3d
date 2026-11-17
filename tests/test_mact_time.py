"""Complete ordinary-C timer: source-only before reference; true private scope."""
import dataclasses,json,os,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
from tools import probe_mact_time as c
from tools import prove_module as driver
ROOT=Path(__file__).resolve().parents[1];HOME=ROOT/'toolchains/watcom-10.0-ga'
class NativeTime(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  (ROOT/'build').mkdir(exist_ok=True);cls.work=Path(tempfile.mkdtemp(prefix='mact-time-tests-',dir=ROOT/'build'));cls.report=driver.prove('mact_time',HOME,cls.work/'normal')
 def module(self):return c.Module.parse(Path(self.report['object']).read_bytes())
 def project(self,label):
  p=self.work/label;p.mkdir();names=set(c.SOURCES+c.NOTICES+c.TOOLS+[c.PROVENANCE,c.DESCRIPTOR])
  for n in names:q=p/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
  return p
 def test_whole_source_original_and_private_contract(self):
  r=self.report;self.assertEqual(r['verification'],r['reference_verification']);self.assertEqual(tuple(r['verification'][k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']),(232,80,16));self.assertFalse(set(r['symbol_anchors'])&{'IncrementCounter_','_TimeStarted','_Timer'});self.assertEqual(r['source_credit'],0);self.assertFalse(r['original_or_target_read_during_production']);self.assertEqual(set(r['verification']['local_symbols']),{'IncrementCounter_','_TimeStarted','_Timer'});self.assertEqual([x.size for x in self.module().segments],[228,0,0,4,80]);self.assertEqual(len(r['callback_self_edge_candidates']),2);self.assertEqual(sum(x.get('whole_pass',False)for x in r['callback_self_edge_candidates']),1)
 def test_standalone_source_only_and_fresh_parent(self):
  r=c.build_source(HOME,self.work/'normal');self.assertNotEqual(r['native_build_directory'],self.report['native_build_directory']);self.assertEqual(r['normal_native_inventory'],self.report['normal_native_inventory']);p=self.project('standalone');self.assertFalse((p/'reference').exists());self.assertFalse((p/c.CALLER).exists());cmd=[sys.executable,str(p/'tools/probe_mact_time.py'),'--source-only','--home',str(HOME.resolve()),'--build',str(p/'native'),'--report',str(p/'source.json')];o=subprocess.run(cmd,capture_output=True,text=True);(p/'CLI.LOG').write_text(o.stdout+o.stderr);self.assertEqual(o.returncode,0,o.stderr);result=json.loads((p/'source.json').read_text());self.assertTrue(result['source_only']);self.assertNotIn('verification',result);self.assertFalse(any('/reference/'in x or '/task433'in x for x in result['producer_inputs_sha256']))
 def test_primary_types_notices_GPL_preserved(self):
  expected={'types.h':'d00c4f7e2968f4315613558e1fb3a1b86f19a50cfd02b42a028cde436e298cf1','timer.h':'9d143947cc46b906570bf13e4a32e14d098395e7626548c8b7997773342a41ba','task_man.h':'20b11da5d7a0a0c21568dd240796cf998213d96682351a6ecdefec6bb5545b72'}
  for n,h in expected.items():self.assertEqual(c.digest(ROOT/c.MODEL/'include'/n),h)
  self.assertEqual(c.digest(ROOT/c.MODEL/'gpl.txt'),'3f9d5f29ecf12b61c4c20045e23e01c717182fa862bb1e97afa19a91a0ef68c4');self.assertIn(b'Reconstructed DOS timer implementation',(ROOT/c.SOURCE).read_bytes())
 def test_closed_sources_notices_profile_before_native(self):
  for i,n in enumerate(c.SOURCES+['tools/probe_mact_time.py',c.PROFILE]):
   p=self.project('changed-'+str(i));q=p/n;q.write_bytes(q.read_bytes()+b'\nchanged')
   with patch.object(c,'ROOT',p),patch.object(c,'compile_source')as run:
    with self.assertRaises(ValueError):c.build_source(HOME,p/'output')
    run.assert_not_called()
  for i,n in enumerate(c.NOTICES):
   p=self.project('notice-'+str(i));e=json.loads((p/c.PROVENANCE).read_text());del e['notices_sha256'][n];c.dump(p/c.PROVENANCE,e);(p/n).unlink()
   with patch.object(c,'ROOT',p),patch.object(c,'compile_source')as run:
    with self.assertRaisesRegex(ValueError,'closed TIME notices'):c.build_source(HOME,p/'output')
    run.assert_not_called()
 def test_raw_metadata_scope_BSS_import_and_all_field_controls(self):
  s=json.loads((ROOT/c.DESCRIPTOR).read_text())
  for label in ['name','comments','public','private','lextern','groups','BSS','alignment','unknown']:
   m=self.module()
   if label=='name':m.name='OTHER'
   elif label=='comments':m.comments.append((0xa1,b'extra'))
   elif label=='public':m.local_publics.remove('IncrementCounter_')
   elif label=='private':m.publics['_invented']=(5,79);m.local_publics.add('_invented')
   elif label=='lextern':m.local_externals.remove(3)
   elif label=='groups':m.groups=[]
   elif label=='BSS':m.segments[-1].size-=1
   elif label=='alignment':m.segments[0].attributes^=32
   else:m.unexpected_runtime_field=True
   with self.subTest(label=label),self.assertRaises(ValueError):c.validate_native(m,s)
  for i in range(16):
   m=self.module();f=m.fixups[i];m.fixups[i]=dataclasses.replace(f,offset=f.offset+1)
   with self.subTest(fixup=i),self.assertRaises(ValueError):c.validate_native(m,s)
 def test_real_C_counter_behavior_and_scheduler_priority_controls(self):
  from le import LEImage
  from tools.verify_module import verify_module
  image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());s=json.loads((ROOT/c.DESCRIPTOR).read_text())
  for label,old,new in [('counter',b'Task->data)++;',b'Task->data)--;'),('priority',b'TicksPerSecond, 1,',b'TicksPerSecond, 2,'),('capacity',b'Timer[10]',b'Timer[11]')]:
   d=self.work/label;shutil.copytree(ROOT/c.MODEL,d);p=d/'time_dos.c';b=p.read_bytes();self.assertEqual(b.count(old),1);p.write_bytes(b.replace(old,new));obj=d/'SOURCE.OBJ';c.compile_source(HOME,p,obj,c.OPTIONS,45,include_dirs=[d/'include']);m=c.Module.parse(obj.read_bytes())
   if label=='counter':
    c.validate_native(m,s)
    with self.assertRaisesRegex(ValueError,'differing bytes'):verify_module(m,image,self.report['placements'],self.report['binding_symbols'])
   else:
    with self.assertRaises(ValueError):c.validate_native(m,s)
 def test_complete_home_races_without_mutating_real_toolchain(self):
  original=c.compile_source
  # Private hardlinked files reuse immutable tool bytes without copying36MB;
  # only a new private leaf is written, never an existing linked file.
  d=self.work/'own-home';shutil.copytree(HOME,d,copy_function=os.link)
  def race(*a,**k):
   out=original(*a,**k);(d/'UNEXPECTED.TXT').write_text('new actual home leaf');return out
  with patch.object(c,'compile_source',race),self.assertRaisesRegex(ValueError,'complete TIME GA tool home'):c.build_source(d,self.work/'home-race')
 def test_staged_and_output_races_reject(self):
  original=c.compile_source
  for label in ['stage','object']:
   def race(home,src,obj,*a,**k):
    out=original(home,src,obj,*a,**k)
    if label=='stage':Path(src).write_bytes(Path(src).read_bytes()+b'\nchanged')
    else:Path(obj).write_bytes(Path(obj).read_bytes()[:-1]+b'\x01')
    return out
   with patch.object(c,'compile_source',race),self.assertRaises(ValueError):c.build_source(HOME,self.work/('race-'+label))
 def test_current_TASKMAN_anchors_schema_and_rejection(self):
  e,_,_=c.read_provenance();w=self.work/'caller-only';w.mkdir();anchors,pins=c.caller_anchors(e,w);self.assertEqual(set(anchors),{'TS_Shutdown_','TS_ScheduleTask_','TS_Terminate_','TS_Dispatch_'});self.assertFalse(any('/task433'in p for p in pins));self.assertEqual(len(list((w/'caller-headers').iterdir())),42);e['caller_receipt_sha256']='0'*64
  with self.assertRaises(ValueError):c.caller_anchors(e,w)
if __name__=='__main__':unittest.main()
