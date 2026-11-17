"""Normal IRQ symbolic backend: original metadata and all typed/private roles."""
from pathlib import Path
import unittest,tempfile,json,sys
ROOT=Path(__file__).resolve().parents[1]
class Availability(unittest.TestCase):
 def test_named_source_first_capsule_exists(self):
  self.assertTrue((ROOT/'tools/probe_irq_symbolic.py').is_file(),'normal source-first IRQ symbolic capsule missing')
class NativeIRQ(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools import prove_module
  cls.work=Path(tempfile.mkdtemp(prefix='irq-symbolic-test-',dir=ROOT/'build'))
  cls.report=prove_module.prove('irq',ROOT/'toolchains/watcom-10.5',cls.work)
 def test_normal_route_has_genuine_original_PARA_DATA_and_resolved_role(self):
  from omf32 import Module
  r=self.report;m=Module.parse(Path(r['source_build']['object']).read_bytes())
  self.assertEqual((r['verification']['initialized_bytes'],r['verification']['zero_fill_bytes'],r['verification']['verified_fixups']),(1016,54,102))
  self.assertEqual(m._segment(4).attributes,105)
  self.assertEqual(r['all_original_roles']['original_fields'],103)
  self.assertEqual(r['all_original_roles']['resolved_private_relative_calls'],1)
  self.assertEqual(r['default_absolute_alignment_negative'],'segment _DATA violates SEGDEF alignment')
  self.assertEqual(r['original_linkage_requirements'],['math387r','emu387'])
  self.assertEqual(m.default_libraries,[])
  self.assertEqual(r['source_credit'],0)
 def test_normal_independent_caller_and_C_reference_are_fresh(self):
  r=self.report
  self.assertEqual(r['fresh_caller']['module'],'sndscape')
  self.assertTrue(r['fresh_caller']['verification']['verified'])
  self.assertEqual(r['C_reference']['verification']['verified_fixups'],103)
  self.assertNotIn('task574',json.dumps(r))
  self.assertFalse(r['private_external_anchor_names'])
 def project(self,name):
  import shutil
  from tools import probe_irq_symbolic as p
  d=self.work/name;d.mkdir()
  for n in p.SOURCES+p.NOTICES+p.PRODUCERS+[p.DESCRIPTOR,p.PROVENANCE]:
   q=d/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
  return d
 def repin(self,d,n):
  import hashlib
  from tools import probe_irq_symbolic as p
  q=d/p.PROVENANCE;e=json.loads(q.read_text());e['tracked_sources_sha256'][n]=hashlib.sha256((d/n).read_bytes()).hexdigest();q.write_text(json.dumps(e))
 def test_alias_cancellation_scope_storage_prefix_and_operand_grammar_reject_before_native(self):
  from tools import probe_irq_symbolic as p
  from unittest.mock import patch
  cases={'alias':lambda s:s.replace('dword [_irq_state + STATE_REGS]','dword [invented_state + STATE_REGS]',1)+'\ninvented_state equ _irq_state\n','cancel':lambda s:s.replace('[_irq_state + STATE_REGS]','[_irq_state + STATE_REGS + _IRQ_Callback - _IRQ_Callback]',1),'private-export':lambda s:s+'\nglobal _irq_state\n','hidden-public':lambda s:s.replace('global rmcallback_','',1),'data-align':lambda s:s.replace('segment _DATA public align=16','segment _DATA public align=4'),'payload':lambda s:s.replace('D32DosMemAlloc_:\n','D32DosMemAlloc_:\n db 0x90\n',1),'prefix':lambda s:s.replace('o16\n    mov edx, dword gs:','mov dx, word gs:',1),'ABI':lambda s:s.replace('ret 8','ret 4',1)}
  for name,mutate in cases.items():
   with self.subTest(name=name):
    d=self.project('grammar-'+name);n=p.MODEL+'/IRQ.ASM';q=d/n;q.write_text(mutate(q.read_text()));self.repin(d,n)
    with patch.object(p.subprocess,'run')as run,self.assertRaisesRegex(ValueError,'statement/operand-owner grammar'):p.build_source(build=d/'output',project=d)
    run.assert_not_called();self.assertFalse((d/'output').exists())
 def test_real_semantic_instruction_variant_reaches_complete_raw_gate(self):
  from tools import probe_irq_symbolic as p
  from omf32 import Module
  from le import LEImage
  from tools.prove_logical_data_origin import replay_target_data_origin
  from tools.verify_module import verify_module
  d=self.project('service');n=p.MODEL+'/IRQ.ASM';q=d/n;q.write_text(q.read_text().replace('DPMI_GET_PROTECTED_VECTOR equ 0x0204','DPMI_GET_PROTECTED_VECTOR equ 0x0205'));self.repin(d,n)
  n=p.MODEL+'/irq.c';q=d/n;q.write_text(q.read_text().replace('irq_state.Regs.w.ax = 0x0204;','irq_state.Regs.w.ax = 0x0205;',1));self.repin(d,n)
  r=p.build_source(build=d/'native',project=d);m=Module.parse(Path(r['object']).read_bytes());image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());ctx=replay_target_data_origin(home=ROOT/'toolchains/watcom-10.0-ga',build=d/'origin')
  with self.assertRaisesRegex(ValueError,'_TEXT.*230'):verify_module(m,image,self.report['placements'],self.report['verification']['publics'],group_frames={1:(3,0)},logical_origins=(ctx,))
 def test_stage_copy_must_match_pre_copy_live_pin(self):
  from tools import probe_irq_symbolic as p
  from unittest.mock import patch
  d=self.project('copy-race');actual=p.shutil.copyfile
  def race(src,dst,*a,**kw):
   result=actual(src,dst,*a,**kw)
   if Path(dst).name=='IRQ.ASM':Path(dst).write_text(Path(dst).read_text().replace('mov edx, 0x100','mov edx, 0x101',1))
   return result
  with patch.object(p.shutil,'copyfile',side_effect=race),patch.object(p.subprocess,'run')as run,self.assertRaisesRegex(ValueError,'identity changed'):p.build_source(build=d/'native',project=d)
  run.assert_not_called();self.assertFalse(list((d/'native').rglob('source-build.json')))
 def test_native_scope_public_coordinate_access_and_typed_member_guards(self):
  import copy
  from dataclasses import replace
  from tools import probe_irq_symbolic as p
  from omf32 import Module
  spec=json.loads((ROOT/p.DESCRIPTOR).read_text());base=Module.parse(Path(self.report['source_build']['object']).read_bytes())
  for name,mutate in [('public+1',lambda m:m.publics.__setitem__('rmcallback_',(1,73))),('promote',lambda m:m.publics.__setitem__('_irq_state',(5,0))),('DATAaccess',lambda m:setattr(m._segment(4),'access',2)),('DATAalign',lambda m:setattr(m._segment(4),'attributes',169)),('typedmember',lambda m:m.fixups.__setitem__(0,replace(m.fixups[0],displacement=2)))]:
   with self.subTest(name=name):
    m=copy.deepcopy(base);mutate(m)
    with self.assertRaises(ValueError):p.check_native(m,spec)
 def test_loaded_policy_missing_notice_source_header_and_extra_stage_reject(self):
  from tools import probe_irq_symbolic as p
  from unittest.mock import patch
  for name,n in [('notice',p.NOTICES[0]),('source',p.SOURCES[0]),('header',p.MODEL+'/i86.h')]:
   d=self.project('identity-'+name);(d/n).unlink()
   with patch.object(p.subprocess,'run')as run,self.assertRaises(ValueError):p.build_source(build=d/'native',project=d)
   run.assert_not_called()
  d=self.project('loaded-policy')
  with patch.dict(p._LOADED,{'tools/probe_irq_symbolic.py':'0'*64}),patch.object(p.subprocess,'run')as run,self.assertRaisesRegex(ValueError,'loaded producer'):p.build_source(build=d/'native',project=d)
  run.assert_not_called()
 def test_observer_staged_repin_rejects_before_target_read(self):
  import copy,shutil
  from tools import probe_irq_symbolic as p
  from unittest.mock import patch
  r=copy.deepcopy(self.report['source_build']);old=Path(r['native_build_directory']);d=self.work/'observer-forgery';shutil.copytree(old,d)
  r['native_build_directory']=str(d);r['object']=str(d/'IRQ.OBJ')
  for k in ['staged_sha256','outputs_sha256']:r[k]={str(d/Path(n).relative_to(old)):h for n,h in r[k].items()}
  q=d/'source-only'/p.MODEL/'IRQ.ASM';q.write_text(q.read_text().replace('mov edx, 0x100','mov edx, 0x101',1));r['staged_sha256'][str(q)]=p.sha(q)
  with patch.object(p,'sha',wraps=p.sha)as observed,self.assertRaisesRegex(ValueError,'pre-copy expected stage'):p.observe(r)
  self.assertFalse(any(Path(call.args[0]).name in ('DUKE3D.EXE','AUDIO_WF.LIB')for call in observed.call_args_list))
 def test_standalone_source_only_and_Python_O_without_target_or_archive(self):
  import shutil,subprocess
  from tools import probe_irq_symbolic as p
  d=self.project('standalone');(d/'toolchains/support').mkdir(parents=True);(d/'toolchains/support/nasm-2.16.03').symlink_to(ROOT/'toolchains/support/nasm-2.16.03',target_is_directory=True)
  for flags in ([],['-O']):
   output=d/('O' if flags else 'normal');r=subprocess.run([sys.executable,*flags,str(d/'tools/probe_irq_symbolic.py'),'--build',str(output),'--report',str(output.with_suffix('.json')),'--source-only'],capture_output=True,text=True);self.assertEqual(r.returncode,0,r.stderr);self.assertTrue(json.loads(output.with_suffix('.json').read_text())['source_only'])
  self.assertFalse((d/'reference').exists())
 def test_actual_return_ABI_control_is_native_shape_positive_and_whole_negative(self):
  import subprocess
  from tools import probe_irq_symbolic as p
  from omf32 import Module
  from le import LEImage
  from tools.prove_logical_data_origin import replay_target_data_origin
  from tools.verify_module import verify_module
  d=self.work/'actual-ABI';d.mkdir();q=d/'IRQ.ASM';q.write_text((ROOT/p.MODEL/'IRQ.ASM').read_text().replace('ret 8','ret 4',1));obj=d/'IRQ.OBJ'
  binary=ROOT/'toolchains/support/nasm-2.16.03/nasm';r=subprocess.run([str(binary),'-f','obj','-o',str(obj),str(q)],capture_output=True,text=True);self.assertEqual(r.returncode,0,r.stderr)
  m=Module.parse(obj.read_bytes());p.check_native(m,json.loads((ROOT/p.DESCRIPTOR).read_text()));ctx=replay_target_data_origin(home=ROOT/'toolchains/watcom-10.0-ga',build=d/'origin');image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
  with self.assertRaisesRegex(ValueError,'_TEXT.*123'):verify_module(m,image,self.report['placements'],self.report['verification']['publics'],group_frames={1:(3,0)},logical_origins=(ctx,))
 def test_post_native_live_stage_and_extra_file_races_reject(self):
  from tools import probe_irq_symbolic as p
  from unittest.mock import patch
  actual=p.subprocess.run
  for selected in ('live','stage','extra'):
   d=self.project('post-native-'+selected)
   def race(cmd,*a,**kw):
    r=actual(cmd,*a,**kw)
    if '-f' in cmd:
     q=d/p.MODEL/'IRQ.ASM' if selected=='live' else Path(cmd[-1])
     if selected=='extra':q.parent.joinpath('unused_extra.h').write_text('outside closed source set')
     else:q.write_bytes(q.read_bytes()+b'\n; after-native source race\n')
    return r
   with patch.object(p.subprocess,'run',side_effect=race),self.assertRaisesRegex(ValueError,'identity changed|staged file set'):p.build_source(build=d/'native',project=d)
   self.assertFalse(list((d/'native').rglob('source-build.json')))
 def test_object_read_race_rejects_before_whole_receipt_publication(self):
  from tools import probe_irq_symbolic as p
  from unittest.mock import patch
  r=p.build_source(ROOT/'toolchains/watcom-10.5',self.work/'read-race');obj=Path(r['object']);actual=Path.read_bytes;reads=0
  def race(path):
   nonlocal reads
   data=actual(path)
   if path==obj:
    reads+=1
    if reads==3:path.write_bytes(data+b'\0')
   return data
  with patch.object(Path,'read_bytes',race),self.assertRaisesRegex(ValueError,'identity changed'):p.observe(r)
  self.assertGreaterEqual(reads,3);self.assertFalse((Path(r['native_build_directory'])/'whole-proof.json').exists())
