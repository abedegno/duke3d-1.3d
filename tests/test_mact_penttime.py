"""Complete PENTTIME normal source capsule; genuine unused imports retained."""
from pathlib import Path
import unittest,tempfile,json,os,hashlib,shutil,copy,dataclasses,subprocess
ROOT=Path(__file__).resolve().parents[1]
class NativePenttime(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools.probe_mact_penttime import build_source,observe
  cls.parent=Path(tempfile.mkdtemp(prefix='penttime-test-',dir=ROOT/'build'));cls.home=Path(os.environ.get('GNU_ELF_IMPORTS_HOME',ROOT/'toolchains/gnu-elf-omf-imports'));cls.work=build_source(cls.home,cls.parent);cls.report=observe(cls.work)
 def test_complete_source_original_scopes_and_unused_imports(self):
  p=self.report;self.assertEqual(tuple(p['verification'][k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']),(609,24,46));self.assertEqual(len(p['all_original_roles']['roles']),46);self.assertEqual(p['all_original_roles']['private_reference_counts'],{'_PENT_timer':11,'_PENT_overhead':5,'_PENT_megahertz':3});self.assertEqual(p['genuine_unused_imports'],['_fltused_','__init_387_emulator','__8087']);self.assertEqual(p['timing_provider']['component'],'normal_mact_time');self.assertFalse(p['private_anchor_names'])
 def project_copy(self,name):
  from tools import probe_mact_penttime as p
  project=self.parent/name/'project';project.mkdir(parents=True)
  for n in p.SOURCES+p.NOTICES+p.PRODUCERS+[p.DESCRIPTOR,p.PROVENANCE]:
   q=project/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
  return project
 def update_source(self,project,path,text):
  from tools import probe_mact_penttime as p
  (project/path).write_text(text);f=project/p.PROVENANCE;j=json.loads(f.read_text());j['tracked_sources_sha256'][path]=hashlib.sha256((project/path).read_bytes()).hexdigest();f.write_text(json.dumps(j,indent=2)+'\n')
 def test_reusable_parent_and_source_only_reproducibility(self):
  from tools import probe_mact_penttime as p
  w=p.build_source(self.home,self.parent);self.assertNotEqual(w,self.work);self.assertEqual((w/'PENTTIME.OBJ').read_bytes(),(self.work/'PENTTIME.OBJ').read_bytes())
 def test_actual_calibration_input_and_scalar_controls(self):
  from tools import probe_mact_penttime as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):v for k,v in self.report['placements'].items()};symbols=self.report['verification']['publics']
  for name,a,z in [('tick-frequency','mov eax,100','mov eax,101'),('sample-average','calibration_average: .double 0.1','calibration_average: .double 0.2')]:
   with self.subTest(name=name):
    project=self.project_copy(name);path=p.MODEL+'/PENTTIME.S';s=(project/path).read_text();self.assertEqual(s.count(a),1);self.update_source(project,path,s.replace(a,z));w=p.build_source(self.home,self.parent/(name+'-native'),project=project);m=Module.parse((w/'PENTTIME.OBJ').read_bytes());self.assertEqual(p.inventory(m),self.report['native_inventory'])
    with self.assertRaisesRegex(ValueError,'differing bytes'):verify_module(m,image,places,symbols)
 def test_scope_storage_import_payload_and_notice_fail_before_native(self):
  from tools import probe_mact_penttime as p
  from unittest.mock import patch
  cases={'private-export':('.local _PENT_megahertz,_PENT_timer,_PENT_overhead','.globl _PENT_megahertz,_PENT_timer,_PENT_overhead'),'extra-storage':('_PENT_timer: .zero 8','_PENT_timer: .zero 16'),'unused-import-loss':('.globl _fltused_,__init_387_emulator,__8087','.globl _fltused_,__init_387_emulator'),'payload':(' xor edx,edx',' xor edx,edx; .byte 0x90')}
  for name in [*cases,'notice']:
   with self.subTest(name=name):
    project=self.project_copy(name)
    if name=='notice':
     n=p.NOTICES[0];(project/n).unlink();f=project/p.PROVENANCE;j=json.loads(f.read_text());del j['notice_files_sha256'][n];f.write_text(json.dumps(j)+'\n')
    else:
     a,z=cases[name];path=p.MODEL+'/PENTTIME.S';s=(project/path).read_text();self.assertIn(a,s);self.update_source(project,path,s.replace(a,z,1))
    with patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as run:
     with self.assertRaises(ValueError):p.build_source(self.home,self.parent/(name+'-pre-native'),project=project)
     run.assert_not_called()
 def test_preflight_generation_race_does_not_rebaseline_source(self):
  from tools import probe_mact_penttime as p
  from unittest.mock import patch
  project=self.project_copy('source-race');original=p.load
  def racing_load(name,path):
   m=original(name,path)
   if name=='closed_penttime_contract':
    source=m.source
    def side_effect(text):
     result=source(text);q=Path(path).parent/'PENTTIME.S';q.write_bytes(q.read_bytes()+b'\n# staged side effect\n');return result
    m.source=side_effect
   return m
  with patch.object(p,'load',side_effect=racing_load),patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as run:
   with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,self.parent/'race-out',project=project)
   run.assert_not_called()
  self.assertFalse(list((self.parent/'race-out').rglob('source-build.json')))
 def test_native_ELF_and_final_OBJ_races_never_publish(self):
  from tools import probe_mact_penttime as p
  from unittest.mock import patch
  for phase in ['ELF','OBJ']:
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
    else:
     check=p.check_native
     def racing_check(m,spec):
      check(m,spec);q=next(parent.glob('penttime-*/PENTTIME.OBJ'));q.write_bytes(q.read_bytes()+b'\0')
     with patch.object(p,'check_native',side_effect=racing_check):
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    self.assertFalse(list(parent.rglob('source-build.json')))
 def test_complete_home_race_after_native_is_rejected(self):
  from tools import probe_mact_penttime as p
  from unittest.mock import patch
  project=self.project_copy('home-race');h=self.parent/'copy-home';shutil.copytree(self.home,h);run=p.subprocess.run;parent=self.parent/'home-race-native'
  def racing(cmd,*a,**kw):
   result=run(cmd,*a,**kw)
   if '-fomf32'in cmd:q=h/'sources/objconv/elf2cof.cpp';q.write_bytes(q.read_bytes()+b'\n// home race\n')
   return result
  with patch.object(p.subprocess,'run',side_effect=racing):
   with self.assertRaises(ValueError):p.build_source(h,parent,project=project)
  self.assertFalse(list(parent.rglob('source-build.json')))
 def test_standalone_source_only_under_python_O(self):
  from tools import probe_mact_penttime as p
  project=self.project_copy('standalone');script=project/'run.py';script.write_text('''from pathlib import Path
import runpy,sys
R=Path(__file__).parent.resolve()
def guard(event,args):
 if event=='open'and isinstance(args[0],(str,bytes)):
  n=str(args[0]).lower()
  if '/reference/'in n or n.endswith(('duke3d.exe','mact386.lib'))or'/task482-'in n or'/task479-'in n:raise RuntimeError('forbidden source producer observer/research read')
sys.addaudithook(guard)
try:(R/'reference/DUKE3D.EXE').read_bytes()
except RuntimeError:pass
else:raise RuntimeError('audit hook not active')
sys.argv=[str(R/'tools/probe_mact_penttime.py'),'--source-only','--elf-home',sys.argv[1],'--build',str(R/'native'),'--report',str(R/'receipt.json')]
runpy.run_path(str(R/'tools/probe_mact_penttime.py'),run_name='__main__')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(self.home.resolve())],capture_output=True,text=True);(project/'run.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);receipt=json.loads((project/'receipt.json').read_text());self.assertEqual(Path(receipt['object']).read_bytes(),(self.work/'PENTTIME.OBJ').read_bytes());self.assertFalse((project/'reference').exists())
 def test_all46_typed_fields_remain_strict_under_python_O(self):
  script=self.parent/'roles-O.py';script.write_text('''from pathlib import Path
import sys,json,dataclasses,importlib.util
R=Path(sys.argv[1]);sys.path[:0]=[str(R),str(R/'profiles/watcom/tools')]
from omf32 import Module
sp=importlib.util.spec_from_file_location('strict_pent',R/'src/mact/penttime/contract.py');c=importlib.util.module_from_spec(sp);sp.loader.exec_module(c)
w=Path(sys.argv[2]);m=Module.parse((w/'PENTTIME.OBJ').read_bytes());e=json.loads((w/'preflight.json').read_text())['elf'];c.native(m,e)
for i,f in enumerate(m.fixups):
 m.fixups[i]=dataclasses.replace(f,relative=not f.relative)
 try:c.native(m,e)
 except ValueError:pass
 else:raise RuntimeError('wrong relative mode admitted')
 m.fixups[i]=f
print('PYTHON_O_ALL46_FIELDS_REJECT')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(ROOT),str(self.work)],capture_output=True,text=True);(self.parent/'roles-O.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);self.assertIn('PYTHON_O_ALL46_FIELDS_REJECT',r.stdout)
 def test_full_tail_BSS_scope_and_raw_ELF_controls(self):
  import struct,importlib.util
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  from profiles.gnu_elf_omf.elf32 import elf
  sp=importlib.util.spec_from_file_location('raw_pent_contract',ROOT/'src/mact/penttime/contract.py');c=importlib.util.module_from_spec(sp);sp.loader.exec_module(c);m=Module.parse((self.work/'PENTTIME.OBJ').read_bytes());image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):v for k,v in self.report['placements'].items()};symbols=self.report['verification']['publics']
  for seg,off in [(4,526),(5,81),(8,23)]:
   q=copy.deepcopy(m);q._segment(seg).data[off]^=1
   with self.assertRaises(ValueError):verify_module(q,image,places,symbols)
  raw=(self.work/'PENTTIME.ELF').read_bytes();h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);symtab=struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*10)[4];logical=c.source((ROOT/'src/mact/penttime/PENTTIME.S').read_text());private_index=11
  for name,off,fmt,v in [('BYTE_CODE',h[5]+40*4+32,'I',1),('backed_BSS',h[5]+40*9+4,'I',1),('internal_marker',h[5]+40*7+4,'I',0xffffff99),('weak_private',symtab+16*private_index+12,'B',32),('COMMON_private',symtab+16*private_index+14,'H',65522)]:
   q=bytearray(raw);struct.pack_into('<'+fmt,q,off,v);path=self.parent/(name+'.ELF');path.write_bytes(q)
   with self.assertRaises(ValueError):c.elf(bytes(q),elf(path),logical)
