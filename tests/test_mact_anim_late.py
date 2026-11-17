"""Late ANIMLIB physical definitions remain distinct from selected globals."""
from pathlib import Path
import unittest,tempfile,json,os,hashlib,shutil,copy,dataclasses,subprocess
ROOT=Path(__file__).resolve().parents[1]
class NativeLateAnim(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools.probe_mact_anim_late import build_source,observe
  cls.parent=Path(tempfile.mkdtemp(prefix='anim-late-test-',dir=ROOT/'build'));cls.home=Path(os.environ.get('GNU_ELF_OMF_HOME',ROOT/'toolchains/gnu-elf-omf'));cls.work=build_source(cls.home,cls.parent);cls.report=observe(cls.work)
 def test_physical_whole_and_both_strict_public_conflicts(self):
  r=self.report;self.assertEqual(tuple(r['physical_verification'][k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']),(1140,0,47));self.assertEqual(r['strict_default_rejections'],{'source':'conflicting binding for public CheckAnimStarted_','original':'conflicting binding for public CheckAnimStarted_'});self.assertEqual(r['private_references'],23);self.assertEqual(r['selected_self_calls'],13);self.assertFalse(r['private_external_anchor_names']);self.assertFalse(r['whole_module_default_verified'])
 def project_copy(self,name):
  from tools import probe_mact_anim_late as p
  project=self.parent/name/'project';project.mkdir(parents=True)
  for n in p.SOURCES+p.NOTICES+p.PRODUCERS+[p.DESCRIPTOR,p.PROVENANCE]:
   q=project/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
  return project
 def update_source(self,project,path,text):
  from tools import probe_mact_anim_late as p
  (project/path).write_text(text);f=project/p.PROVENANCE;j=json.loads(f.read_text());j['tracked_sources_sha256'][path]=hashlib.sha256((project/path).read_bytes()).hexdigest();f.write_text(json.dumps(j,indent=2)+'\n')
 def test_reusable_parent_and_complete_COFF_source_scope(self):
  from tools import probe_mact_anim_late as p
  w=p.build_source(self.home,self.parent);self.assertNotEqual(w,self.work);self.assertEqual((w/'ANIMLIB.OBJ').read_bytes(),(self.work/'ANIMLIB.OBJ').read_bytes());c=json.loads((w/'coff-audit.json').read_text());self.assertEqual(len(c['symbols']),55);self.assertEqual(len(c['relations']),47);self.assertTrue(c['private37_ABS1_retained'])
 def test_ELF_COFF_OBJ_races_never_publish(self):
  from tools import probe_mact_anim_late as p
  from unittest.mock import patch
  for phase in ['ELF','COFF','OBJ']:
   with self.subTest(phase=phase):
    project=self.project_copy('native-'+phase);parent=self.parent/('native-race-'+phase)
    if phase=='ELF':
     run=p.subprocess.run
     def racing_run(cmd,*a,**kw):
      result=run(cmd,*a,**kw)
      if '-fomf32'in cmd:q=Path(cmd[-2]);q.write_bytes(q.read_bytes()+b'\0')
      return result
     with patch.object(p.subprocess,'run',side_effect=racing_run):
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    elif phase=='COFF':
     load=p.load
     def racing_load(name,path):
      m=load(name,path)
      if name=='closed_anim_late_contract':
       original=m.coff
       def side_effect(raw,e):
        result=original(raw,e);q=next(parent.glob('anim_late-*/ANIMLIB.COFF'));q.write_bytes(q.read_bytes()+b'\0');return result
       m.coff=side_effect
      return m
     with patch.object(p,'load',side_effect=racing_load):
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    else:
     check=p.check_native
     def racing_check(m,spec):
      check(m,spec);q=next(parent.glob('anim_late-*/ANIMLIB.OBJ'));q.write_bytes(q.read_bytes()+b'\0')
     with patch.object(p,'check_native',side_effect=racing_check):
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    self.assertFalse(list(parent.rglob('source-build.json')))
 def test_complete_home_after_conversion_closes_before_publication(self):
  from tools import probe_mact_anim_late as p
  from unittest.mock import patch
  project=self.project_copy('home-race');h=self.parent/'copy-home';shutil.copytree(self.home,h);run=p.subprocess.run;parent=self.parent/'home-race-native'
  def racing(cmd,*a,**kw):
   result=run(cmd,*a,**kw)
   if '-fomf32'in cmd:q=h/'sources/objconv/elf2cof.cpp';q.write_bytes(q.read_bytes()+b'\n// home race\n')
   return result
  with patch.object(p.subprocess,'run',side_effect=racing):
   with self.assertRaises(ValueError):p.build_source(h,parent,project=project)
  self.assertFalse(list(parent.rglob('source-build.json')))
 def test_standalone_source_only_optimized_no_prototype_inputs(self):
  from tools import probe_mact_anim_late as p
  project=self.project_copy('standalone');script=project/'run.py';script.write_text('''from pathlib import Path
import runpy,sys
R=Path(__file__).parent.resolve()
def guard(event,args):
 if event=='open'and isinstance(args[0],(str,bytes)):
  n=str(args[0]).lower()
  if '/reference/'in n or n.endswith(('duke3d.exe','mact386.lib'))or'/task466/'in n or'/task470-'in n:raise RuntimeError('forbidden source producer observer/research read')
sys.addaudithook(guard)
try:(R/'reference/DUKE3D.EXE').read_bytes()
except RuntimeError:pass
else:raise RuntimeError('audit hook not active')
sys.argv=[str(R/'tools/probe_mact_anim_late.py'),'--source-only','--elf-home',sys.argv[1],'--build',str(R/'native'),'--report',str(R/'receipt.json')]
runpy.run_path(str(R/'tools/probe_mact_anim_late.py'),run_name='__main__')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(self.home.resolve())],capture_output=True,text=True);(project/'run.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);receipt=json.loads((project/'receipt.json').read_text());self.assertEqual(Path(receipt['object']).read_bytes(),(self.work/'ANIMLIB.OBJ').read_bytes());self.assertFalse((project/'reference').exists())
 def test_all47_field_modes_strict_under_python_O(self):
  script=self.parent/'roles-O.py';script.write_text('''from pathlib import Path
import sys,json,dataclasses,importlib.util
R=Path(sys.argv[1]);sys.path[:0]=[str(R),str(R/'profiles/watcom/tools')]
from omf32 import Module
sp=importlib.util.spec_from_file_location('strict_anim_late',R/'src/mact/anim_late/contract.py');c=importlib.util.module_from_spec(sp);sp.loader.exec_module(c)
w=Path(sys.argv[2]);m=Module.parse((w/'ANIMLIB.OBJ').read_bytes());e=json.loads((w/'preflight.json').read_text())['elf'];coff=json.loads((w/'coff-audit.json').read_text());c.native(m,e,coff)
for i,f in enumerate(m.fixups):
 m.fixups[i]=dataclasses.replace(f,relative=not f.relative)
 try:c.native(m,e,coff)
 except ValueError:pass
 else:raise RuntimeError('wrong relative mode admitted')
 m.fixups[i]=f
print('PYTHON_O_ALL47_FIELDS_REJECT')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(ROOT),str(self.work)],capture_output=True,text=True);(self.parent/'roles-O.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);self.assertIn('PYTHON_O_ALL47_FIELDS_REJECT',r.stdout)
 def test_duplicate_COFF_field_record_cannot_replace_another(self):
  import struct,importlib.util
  sp=importlib.util.spec_from_file_location('strict_coff_duplicate',ROOT/'src/mact/anim_late/contract.py');c=importlib.util.module_from_spec(sp);sp.loader.exec_module(c);raw=bytearray((self.work/'ANIMLIB.COFF').read_bytes());rel=struct.unpack_from('<I',raw,20+40*3+24)[0];raw[rel+10:rel+20]=raw[rel:rel+10];e=json.loads((self.work/'preflight.json').read_text())['elf']
  with self.assertRaises(ValueError):c.coff(bytes(raw),e)
 def test_live_copy_and_preflight_source_races_never_recapture(self):
  from tools import probe_mact_anim_late as p
  from unittest.mock import patch
  for phase in ['live-copy','preflight']:
   with self.subTest(phase=phase):
    project=self.project_copy('race-'+phase);parent=self.parent/('race-native-'+phase)
    if phase=='live-copy':
     copier=p.shutil.copyfile
     def race(src,dst,*a,**kw):
      result=copier(src,dst,*a,**kw)
      if str(src).endswith('/ANIMLIB.S'):q=Path(src);q.write_bytes(q.read_bytes()+b'\n# live source race\n')
      return result
     with patch.object(p.shutil,'copyfile',side_effect=race),patch.object(p.subprocess,'run',side_effect=RuntimeError('must not run'))as run:
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
      run.assert_not_called()
    else:
     load=p.load
     def race(name,path):
      m=load(name,path)
      if name=='closed_anim_late_contract':
       source=m.source
       def changed(text):
        result=source(text);q=Path(path).parent/'ANIMLIB.S';q.write_bytes(q.read_bytes()+b'\n# source preflight side effect\n');return result
       m.source=changed
      return m
     with patch.object(p,'load',side_effect=race),patch.object(p.subprocess,'run',side_effect=RuntimeError('must not run'))as run:
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
      run.assert_not_called()
    self.assertFalse(list(parent.rglob('source-build.json')))
 def reference(self):
  from omf32 import Module
  from le import LEImage
  from tools import probe_mact_anim_late as p
  return Module.parse((ROOT/p.LIBRARY).read_bytes()[125952:129124]),LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
 def test_actual_decoder_private_and_same_literal_capacity_controls(self):
  from tools import probe_mact_anim_late as p
  from omf32 import Module
  original,image=self.reference();selected={n:tuple(v)for n,v in self.report['selected_reference_bindings'].items()};base=tuple(self.report['all_candidate_gates'][0]['nomination'])
  for name,a,z in [('decoder-counter','dec bx','dec cx'),('private-owner','cmp dword ptr [_Anim_Started], 0','cmp dword ptr [_anim], 0'),('post-NUL-capacity','.asciz "drawframe"','.asciz "drawframe\\0X"')]:
   with self.subTest(name=name):
    project=self.project_copy(name);path=p.MODEL+'/ANIMLIB.S';text=(project/path).read_text();self.assertGreaterEqual(text.count(a),1);self.update_source(project,path,text.replace(a,z,1));w=p.build_source(self.home,self.parent/(name+'-native'),project=project);m=Module.parse((w/'ANIMLIB.OBJ').read_bytes());self.assertEqual(p.inventory(m),self.report['source_build']['native_inventory'])
    with self.assertRaisesRegex(ValueError,'differing bytes|LE fixup target mismatch'):p.physical(original,m,image,*base,selected)
 def test_physical_globals_cannot_be_substituted_for_actual_selected_globals(self):
  from tools import probe_mact_anim_late as p
  from omf32 import Module
  original,image=self.reference();m=Module.parse((self.work/'ANIMLIB.OBJ').read_bytes());selected={n:tuple(v)for n,v in self.report['selected_reference_bindings'].items()};self.assertFalse(set(selected)&p.PRIVATE)
  for n,v in self.report['physical_definitions'].items():
   if n not in p.PRIVATE:selected[n]=tuple(v)
  base=tuple(self.report['all_candidate_gates'][0]['nomination'])
  with self.assertRaisesRegex(ValueError,'selected'):p.physical(original,m,image,*base,selected)
 def test_scope_notice_header_and_data_guard_before_native(self):
  from tools import probe_mact_anim_late as p
  from unittest.mock import patch
  for name in ['private-export','header','notice','storage','payload']:
   with self.subTest(name=name):
    project=self.project_copy(name)
    if name=='notice':
     n=p.NOTICES[0];(project/n).unlink();f=project/p.PROVENANCE;j=json.loads(f.read_text());del j['notice_files_sha256'][n];f.write_text(json.dumps(j)+'\n')
    elif name=='header':
     path=p.MODEL+'/C-counterpart/headers/_animlib.h';self.update_source(project,path,(project/path).read_text()+'\n/* changed header */\n')
    else:
     path=p.MODEL+'/ANIMLIB.S';s=(project/path).read_text();a,z={'private-export':('_anim:','.globl _anim\n_anim:'),'storage':('.long 0 # actual private boolean false','.long 0\n.long 0'),'payload':('ret ','ret ; .byte 0x90')}[name];self.assertIn(a,s);self.update_source(project,path,s.replace(a,z,1))
    with patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as run:
     with self.assertRaises(ValueError):p.build_source(self.home,self.parent/(name+'-prenative'),project=project)
     run.assert_not_called()
 def test_held_out_code_const_data_and_all_private_scope_controls(self):
  import struct
  from tools import probe_mact_anim_late as p
  from omf32 import Module
  from profiles.gnu_elf_omf.elf32 import elf
  original,image=self.reference();m=Module.parse((self.work/'ANIMLIB.OBJ').read_bytes());selected={n:tuple(v)for n,v in self.report['selected_reference_bindings'].items()};base=tuple(self.report['all_candidate_gates'][0]['nomination']);c=p.load('damage_late_anim',ROOT/p.MODEL/'contract.py')
  for seg,off in [(4,1004),(5,126),(7,7)]:
   q=copy.deepcopy(m);q._segment(seg).data[off]^=1
   with self.assertRaises(ValueError):p.physical(original,q,image,*base,selected)
  raw=(self.work/'ANIMLIB.ELF').read_bytes();h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);st=struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*10)[4];e=json.loads((self.work/'preflight.json').read_text())['elf'];logical=c.source((ROOT/p.MODEL/'ANIMLIB.S').read_text());listing=(self.work/'ANIMLIB.LST').read_text()
  for private in ['_anim','_Anim_Started']:
   sym=next(s for t in e['symbols'].values()for s in t if s['name']==private)
   for kind,off,fmt,v in [('global',st+16*sym['index']+12,'B',16),('COMMON',st+16*sym['index']+14,'H',65522)]:
    q=bytearray(raw);struct.pack_into('<'+fmt,q,off,v);path=self.parent/(private+kind+'.ELF');path.write_bytes(q)
    with self.assertRaises(ValueError):c.elf(bytes(q),elf(path),logical,listing)
  coff=bytearray((self.work/'ANIMLIB.COFF').read_bytes());table=struct.unpack_from('<I',coff,8)[0];audit=json.loads((self.work/'coff-audit.json').read_text());sym=next(s for s in audit['symbols']if s['name']=='_anim');coff[table+18*sym['index']+16]=2
  with self.assertRaises(ValueError):c.coff(bytes(coff),e)
 def test_real_caller_header_identity_rejects_before_recompile(self):
  from tools import probe_mact_anim_late as p
  from unittest.mock import patch
  from tools import prove_module
  project=self.project_copy('caller-header');e=json.loads((ROOT/p.PROVENANCE).read_text());recipe=e['accepted_caller_recipe']
  for name in p.WITNESS_INPUTS+list(recipe['utility_reference_inputs_sha256']):
   q=project/name
   if q.exists():continue
   q.parent.mkdir(parents=True,exist_ok=True);q.symlink_to(ROOT/name)
  refs=project/'dukenukem3d/source';refs.mkdir(parents=True);(project/'src/include').mkdir(parents=True)
  for q in(self.work/'early-headers').iterdir():shutil.copyfile(q,refs/q.name)
  h=refs/'animlib.h';h.write_bytes(h.read_bytes()+b'\n/* changed real caller header input */\n')
  with patch.object(p,'ROOT',project),patch.object(prove_module,'prove',side_effect=RuntimeError('caller must not compile'))as call:
   with self.assertRaisesRegex(ValueError,'prepared graph'):p.witness(ROOT/'toolchains/watcom-10.0-ga',self.parent/'wrong-caller-header',e)
   call.assert_not_called()
