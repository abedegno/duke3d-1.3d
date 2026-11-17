"""Complete normal CONTROL and exact symbolic runtime-owner attribution."""
from pathlib import Path
import unittest,importlib.util
ROOT=Path(__file__).resolve().parents[1]
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
class ControlOwnerGrammar(unittest.TestCase):
 def test_cancelled_competing_owner_rejected_before_native(self):
  base=ROOT/'src/mact/control_complete';g=load('control_guard_red',base/'elf_contract.py');model=load('control_model_red',base/'models.py');text=(base/'CONTROL.S').read_text().replace('.include "CONTROL_LITERALS.INC"',model.generate()[0]);text=text.replace('call dword ptr [_GetTime]','call dword ptr [_CONTROL_LastAxes + 1576 + (_GetTime - _GetTime)]',1)
  with self.assertRaisesRegex(ValueError,'owner'):g.source_preflight(text,model)
 def test_entire_memory_operand_suffix_prefix_and_brackets_reject(self):
  base=ROOT/'src/mact/control_complete';g=load('control_entire_operand_red',base/'elf_contract.py');model=load('control_entire_model_red',base/'models.py');text=(base/'CONTROL.S').read_text().replace('.include "CONTROL_LITERALS.INC"',model.generate()[0])
  for part in ['dword ptr [_GetTime] + (_CONTROL_LastAxes +1576-_GetTime)','dword ptr (_CONTROL_LastAxes+1576-_GetTime)[_GetTime]','dword ptr [[_GetTime]]']:
   with self.subTest(operand=part):
    bad=text.replace('call dword ptr [_GetTime]','call '+part,1)
    with self.assertRaisesRegex(ValueError,'memory operand'):g.source_preflight(bad,model)
 def test_section_base_substitution_rejected_before_native(self):
  base=ROOT/'src/mact/control_complete';g=load('control_guard_red2',base/'elf_contract.py');model=load('control_model_red2',base/'models.py');text=(base/'CONTROL.S').read_text().replace('.include "CONTROL_LITERALS.INC"',model.generate()[0]).replace('call dword ptr [_GetTime]','call dword ptr [_CONTROL_LastAxes + 1576]',1)
  with self.assertRaisesRegex(ValueError,'owner'):g.source_preflight(text,model)

class NativeControl(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  import tempfile,os
  from tools import probe_mact_control as p
  cls.p=p;cls.parent=Path(tempfile.mkdtemp(prefix='control540-tests-',dir=ROOT/'build'));cls.home=Path(os.environ.get('GNU_ELF_OMF_HOME',ROOT/'toolchains/gnu-elf-omf')).resolve();cls.decoder=Path(os.environ.get('CAPSTONE_HOME',ROOT/'toolchains/capstone')).resolve();cls.work=p.build_source(cls.home,cls.parent,decoder_home=cls.decoder);cls.report=p.observe(cls.work)
 def project(self,name):
  import shutil
  p=self.p;q=self.parent/name/'project';q.mkdir(parents=True)
  for path in p.SOURCES+p.NOTICES+p.PRODUCERS+[p.DESCRIPTOR,p.PROVENANCE]:
   dst=q/path;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/path,dst)
  return q
 def revise(self,project,path,text):
  import json,hashlib
  p=self.p;(project/path).write_text(text);ref=project/p.PROVENANCE;r=json.loads(ref.read_text());r['tracked_sources_sha256'][path]=hashlib.sha256((project/path).read_bytes()).hexdigest();ref.write_text(json.dumps(r,indent=2)+'\n')
 def test_complete_whole_all_owners_roles_and_original_alignment(self):
  import json
  r=self.report;self.assertEqual([r['verification'][k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']],[7452,1612,470]);self.assertEqual(self.p.digest(self.work/'CONTROL.OBJ'),'505f7cd93f17f455ccd0e0bebf90865f441cfb024284077210c9bb54e2fa77df');q=r['role_closure'];self.assertEqual(len(q['named_private_definitions']),30);self.assertEqual(q['private_reference_count'],228);self.assertEqual(q['self_global_REL32_still_actual_named_fields'],57);self.assertEqual(len(q['all25_BSS_owner_coordinates']),25);self.assertEqual(q['instruction_count'],2022);self.assertEqual(q['actual_switch_tables'],5);self.assertFalse(q['private_external_anchor_names']);self.assertEqual(len(r['callee_verifications']),9);pre=json.loads((self.work/'preflight.json').read_text());self.assertEqual(len(pre['operand_field_roles']),470);coff=json.loads((self.work/'coff-identity.json').read_text());self.assertEqual(len(coff['all347_primary_identities']),347);self.assertEqual(len(coff['all470_REL_correspondences']),470)
 def test_owner_cancellation_repetition_coefficient_and_aliases_before_tools(self):
  from unittest.mock import patch
  p=self.p;base=(ROOT/p.MODEL/'CONTROL.S').read_text()
  for name,new in [('cancel','_CONTROL_LastAxes +1576+(_GetTime-_GetTime)'),('repeat','_GetTime+(_GetTime-_GetTime)'),('coefficient','2*_GetTime'),('base','_CONTROL_LastAxes+1576')]:
   project=self.project('alias-'+name);path=p.MODEL+'/CONTROL.S';self.revise(project,path,base.replace('call dword ptr [_GetTime]','call dword ptr ['+new+']',1))
   with patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as native:
    with self.assertRaisesRegex(ValueError,'owner'):p.build_source(self.home,self.parent/('alias-native-'+name),project=project,decoder_home=self.decoder)
    native.assert_not_called()
 def test_actual_GAS_outside_prefix_suffix_cannot_reach_native_tools(self):
  from unittest.mock import patch
  p=self.p;base=(ROOT/p.MODEL/'CONTROL.S').read_text()
  for name,operand in [('suffix','dword ptr [_GetTime]+(_CONTROL_LastAxes+1576-_GetTime)'),('prefix','dword ptr (_CONTROL_LastAxes+1576-_GetTime)[_GetTime]'),('nested','dword ptr [[_GetTime]]')]:
   project=self.project('outside-'+name);self.revise(project,p.MODEL+'/CONTROL.S',base.replace('call dword ptr [_GetTime]','call '+operand,1))
   with patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as native:
    with self.assertRaisesRegex(ValueError,'memory operand'):p.build_source(self.home,self.parent/('outside-native-'+name),project=project,decoder_home=self.decoder)
    native.assert_not_called()
 def test_actual_semantic_clock_deadline_and_deadband_controls(self):
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  p=self.p;base=(ROOT/p.MODEL/'CONTROL.S').read_text();image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places=self.report['placements'];symbols=self.report['verification']['publics']
  for name,old,new in [('deadline','jl control_buttons_double','jle control_buttons_double'),('clock','add edx, 5','add edx, 4'),('deadband','shl edx,2','shl edx,3')]:
   project=self.project('semantic-'+name);self.assertIn(old,base);self.revise(project,p.MODEL+'/CONTROL.S',base.replace(old,new,1));w=p.build_source(self.home,self.parent/('semantic-native-'+name),project=project,decoder_home=self.decoder);m=Module.parse((w/'CONTROL.OBJ').read_bytes());self.assertEqual(p.inventory(m),self.report['native_inventory'])
   with self.assertRaises(ValueError):verify_module(m,image,places,symbols)
 def test_owner_rejection_remains_nonoptional_under_python_O(self):
  import subprocess,sys
  script=self.parent/'owners-optimized.py';script.write_text("""from pathlib import Path
import sys,importlib.util
R=Path(sys.argv[1]);B=R/'src/mact/control_complete'
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
g=load('owners_O',B/'elf_contract.py');model=load('model_O',B/'models.py');text=(B/'CONTROL.S').read_text().replace('.include \"CONTROL_LITERALS.INC\"',model.generate()[0])
for operand in ['dword ptr [_CONTROL_LastAxes+1576+(_GetTime-_GetTime)]','dword ptr [_CONTROL_LastAxes+1576]','dword ptr [_GetTime+(_GetTime-_GetTime)]','dword ptr [2*_GetTime]','dword ptr [_GetTime]+(_CONTROL_LastAxes+1576-_GetTime)','dword ptr (_CONTROL_LastAxes+1576-_GetTime)[_GetTime]','dword ptr [[_GetTime]]']:
 try:g.source_preflight(text.replace('call dword ptr [_GetTime]','call '+operand,1),model)
 except ValueError:pass
 else:raise RuntimeError('optimized Python admitted wrong owner')
print('ALL7_OWNERS_REJECT_PYTHON_O')
""")
  r=subprocess.run([sys.executable,'-O',str(script),str(ROOT)],capture_output=True,text=True);(self.parent/'owners-optimized.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);self.assertIn('ALL7_OWNERS_REJECT_PYTHON_O',r.stdout)
 def test_true_table_and_private_key_owner_mutations_reject(self):
  from unittest.mock import patch
  p=self.p;base=(ROOT/p.MODEL/'CONTROL.S').read_text()
  for name,old,new in [('enum','.long control_case_68,control_case_71,control_case_70,control_case_69,control_case_72,control_case_73','.long control_case_68,control_case_69,control_case_70,control_case_71,control_case_72,control_case_73'),('private-key','mov byte ptr [_CONTROL_KeyMapping','mov byte ptr [_CONTROL_DeviceButtonMapping')]:
   if old not in base:
    old='[ecx*2 + _CONTROL_KeyMapping]';new='[ecx*2 + _CONTROL_DeviceButtonMapping]'
   self.assertIn(old,base);project=self.project('owner-'+name);self.revise(project,p.MODEL+'/CONTROL.S',base.replace(old,new,1))
   with patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as native:
    with self.assertRaises(ValueError):p.build_source(self.home,self.parent/('owner-native-'+name),project=project,decoder_home=self.decoder)
    native.assert_not_called()
 def test_word_vector_width_and_public_stack_cleanup_reject(self):
  p=self.p;base=(ROOT/p.MODEL/'CONTROL.S').read_text()
  for name,old,new in [('vector-width','mov ax, word ptr [esi + 2]','movzx eax, byte ptr [esi + 2]'),('cleanup','ret 4','ret')]:
   self.assertIn(old,base);project=self.project('ABI-'+name);self.revise(project,p.MODEL+'/CONTROL.S',base.replace(old,new,1))
   if name=='cleanup':
    with self.assertRaises(ValueError):p.build_source(self.home,self.parent/('ABI-native-'+name),project=project,decoder_home=self.decoder)
   else:
    from omf32 import Module
    from le import LEImage
    from tools.verify_module import verify_module
    w=p.build_source(self.home,self.parent/('ABI-native-'+name),project=project,decoder_home=self.decoder);m=Module.parse((w/'CONTROL.OBJ').read_bytes());image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
    with self.assertRaises(ValueError):verify_module(m,image,self.report['placements'],self.report['verification']['publics'])
 def test_terminal_literal_real_model_and_full_source_segment_gate(self):
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  p=self.p;project=self.project('literal');path=p.MODEL+'/models.py';self.revise(project,path,(project/path).read_text().replace('ThrustMaster Present','ThrustMaster present'));model=p.load('wrong_control_literal',project/path);self.revise(project,p.MODEL+'/CONTROL_LITERALS.INC',model.generate()[0]);w=p.build_source(self.home,self.parent/'literal-native',project=project,decoder_home=self.decoder);m=Module.parse((w/'CONTROL.OBJ').read_bytes());image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
  with self.assertRaises(ValueError):verify_module(m,image,self.report['placements'],self.report['verification']['publics'])
 def test_private_public_scope_and_exact_notice_keys(self):
  import json
  from unittest.mock import patch
  p=self.p
  for case in ['scope','notice']:
   project=self.project('pre-'+case)
   if case=='notice':
    n=p.NOTICES[0];(project/n).unlink();f=project/p.PROVENANCE;r=json.loads(f.read_text());del r['notice_files_sha256'][n];f.write_text(json.dumps(r)+'\n')
   else:
    path=p.MODEL+'/CONTROL.S';self.revise(project,path,(project/path).read_text().replace('.extern MOUSE_GetDelta_','.globl _GetTime\n.extern MOUSE_GetDelta_',1))
   with patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as native:
    with self.assertRaises(ValueError):p.build_source(self.home,self.parent/('pre-native-'+case),project=project,decoder_home=self.decoder)
    native.assert_not_called()
 def test_all470_typed_roles_and_final_tail_DATA_CONST_BSS(self):
  import json,copy,dataclasses
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  p=self.p;m=Module.parse((self.work/'CONTROL.OBJ').read_bytes());spec=json.loads((ROOT/p.DESCRIPTOR).read_text());image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());pre=json.loads((self.work/'preflight.json').read_text());guard=p.load('control_native_damage',ROOT/p.MODEL/'elf_contract.py')
  for i,f in enumerate(m.fixups):
   old=m.fixups[i];m.fixups[i]=dataclasses.replace(f,relative=not f.relative)
   with self.assertRaises(ValueError):p.check_native(m,spec)
   m.fixups[i]=old
  for sn,off in [(4,6328),(5,1054),(7,0),(8,1611)]:
   z=copy.deepcopy(m);z._segment(sn).data[off]^=1
   with self.assertRaises(ValueError):verify_module(z,image,self.report['placements'],self.report['verification']['publics'])
  z=copy.deepcopy(m);z._segment(4).size-=1;z._segment(4).data.pop()
  with self.assertRaises(ValueError):guard.postflight(pre['ELF'],z,pre)
  places=dict(self.report['placements']);places[4]=(places[4][0],places[4][1]+1)
  with self.assertRaisesRegex(ValueError,'alignment'):verify_module(m,image,places,self.report['verification']['publics'])
 def test_raw_COFF_symbols_and_field_owner_damage_reject(self):
  import json,struct
  from omf32 import Module
  p=self.p;e=json.loads((self.work/'preflight.json').read_text())['ELF'];m=Module.parse((self.work/'CONTROL.OBJ').read_bytes());c=p.load('control_coff_damage',ROOT/p.MODEL/'coff_contract.py');raw=(self.work/'CONTROL.COFF').read_bytes();view=c.coff(self.work/'CONTROL.COFF');w=self.parent/'coff-damage';w.mkdir()
  public=next(s for s in view['symbols']if s['name']=='_CONTROL_LastAxes');sp=struct.unpack_from('<I',raw,8)[0];damages=[(sp+public['index']*18+16,b'\x02'),(20+3*40+36,struct.pack('<I',0x60500040))]
  for off,value in damages:
   z=bytearray(raw);z[off:off+len(value)]=value;(w/'CONTROL.COFF').write_bytes(z)
   with self.assertRaises(ValueError):c.check(w,e,m)
 def test_actual_COFF_duplicate_field_cannot_hide_missing_field(self):
  import json
  from omf32 import Module
  p=self.p;e=json.loads((self.work/'preflight.json').read_text())['ELF'];m=Module.parse((self.work/'CONTROL.OBJ').read_bytes());c=p.load('control_coff_duplicate',ROOT/p.MODEL/'coff_contract.py');view=c.coff(self.work/'CONTROL.COFF');section=next(s for s in view['sections']if s['name']=='_TEXT');self.assertEqual(section['reloc_count'],470);raw=bytearray((self.work/'CONTROL.COFF').read_bytes());a=section['reloc_offset'];self.assertNotEqual(raw[a:a+10],raw[a+10:a+20]);raw[a+10:a+20]=raw[a:a+10];w=self.parent/'coff-duplicate';w.mkdir();(w/'CONTROL.COFF').write_bytes(raw)
  with self.assertRaisesRegex(ValueError,'bijection'):c.check(w,e,m)
 def test_input_copy_generation_and_prior_output_races(self):
  from unittest.mock import patch
  p=self.p;copyfile=p.shutil.copyfile;write=Path.write_text;native=p.subprocess.run
  for case in ['copy-live','stage-generated','ELF','OBJ']:
   project=self.project('race-'+case);parent=self.parent/('race-native-'+case)
   def copied(src,dst,*a,**kw):
    r=copyfile(src,dst,*a,**kw)
    if case=='copy-live'and Path(src)==project/p.MODEL/'CONTROL.S':write(Path(src),Path(src).read_text()+'\n# actual post-copy live change\n')
    return r
   def written(self,text,*a,**kw):
    r=write(self,text,*a,**kw)
    if case=='stage-generated'and self.name=='CONTROL_GENERATED.S':q=self.with_name('CONTROL.S');write(q,q.read_text()+'\n# actual generation race\n')
    return r
   def ran(cmd,*a,**kw):
    r=native(cmd,*a,**kw)
    if Path(cmd[0]).name=='objconv'and ((case=='ELF'and Path(cmd[-1]).suffix=='.OBJ')or(case=='OBJ'and Path(cmd[-1]).suffix=='.COFF')):
     q=Path(cmd[-2])if case=='ELF'else Path(cmd[-1]).with_suffix('.OBJ');q.write_bytes(q.read_bytes()+b'\0')
    return r
   with patch.object(p.shutil,'copyfile',copied),patch.object(Path,'write_text',written),patch.object(p.subprocess,'run',side_effect=ran):
    with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project,decoder_home=self.decoder)
   self.assertFalse(list(parent.rglob('source-build.json')))
 def test_whole_private_GNU_home_extra_file_after_each_native_stage(self):
  import os
  from unittest.mock import patch
  p=self.p;native=p.subprocess.run
  for phase in ['AS','OBJ','COFF']:
   home=self.parent/('private-home-'+phase);home.mkdir()
   for src in self.home.rglob('*'):
    if src.is_file():q=home/src.relative_to(self.home);q.parent.mkdir(parents=True,exist_ok=True);os.link(src,q)
   def ran(cmd,*a,**kw):
    r=native(cmd,*a,**kw)
    if (phase=='AS'and Path(cmd[0]).name=='as-new')or(phase!='AS'and Path(cmd[-1]).suffix=='.'+phase):(home/'UNEXPECTED.META').write_text('actual private-home race\n')
    return r
   with patch.object(p.subprocess,'run',side_effect=ran):
    with self.assertRaisesRegex(ValueError,'file set'):p.build_source(home,self.parent/('home-native-'+phase),decoder_home=self.decoder)
 def test_standalone_source_only_under_Python_O_no_reference_or_research(self):
  import json,subprocess,sys
  p=self.p;project=self.project('standalone');script=project/'run.py';script.write_text('''from pathlib import Path
import sys,runpy
R=Path(__file__).parent.resolve()
def denied(event,args):
 if event=='open'and isinstance(args[0],(str,bytes)):
  p=str(args[0])
  if any(n in p for n in ['/reference/','/control528/','/task525-control','/analysis/','own_draft_aid']):raise RuntimeError('forbidden observer/research input '+p)
sys.addaudithook(denied)
sys.argv=[str(R/'tools/probe_mact_control.py'),'--source-only','--elf-home',sys.argv[1],'--decoder-home',sys.argv[2],'--build',str(R/'native'),'--report',str(R/'receipt.json')]
runpy.run_path(str(R/'tools/probe_mact_control.py'),run_name='__main__')
''');r=subprocess.run([sys.executable,'-O',str(script),str(self.home),str(self.decoder)],capture_output=True,text=True);(project/'standalone.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);j=json.loads((project/'receipt.json').read_text());self.assertFalse((project/'reference').exists());self.assertEqual(Path(j['object']).read_bytes(),(self.work/'CONTROL.OBJ').read_bytes())

if __name__=='__main__':unittest.main()
