"""Complete normal TLIBDOS source; exact native tools required, no skips."""
from pathlib import Path
import unittest,tempfile,json,os,hashlib,shutil,copy,dataclasses,subprocess
ROOT=Path(__file__).resolve().parents[1]
class NativeTlibdos(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools.probe_mact_tlibdos import build_source,observe
  cls.parent=Path(tempfile.mkdtemp(prefix='tlibdos-test-',dir=ROOT/'build'));cls.home=Path(os.environ.get('GNU_ELF_OMF_HOME',ROOT/'toolchains/gnu-elf-omf'));cls.work=build_source(cls.home,cls.parent);cls.report=observe(cls.work)
 def test_full_original_and_source_equal(self):
  p=self.report;self.assertEqual(p['verification'],p['reference_verification']);self.assertEqual((p['verification']['initialized_bytes'],p['verification']['zero_fill_bytes'],p['verification']['verified_fixups']),(329,8,6));self.assertEqual(p['runtime_private_definitions'],0);self.assertEqual(len(p['all_original_roles']),6)
 def test_reusable_parent_source_only(self):
  from tools.probe_mact_tlibdos import build_source
  w=build_source(self.home,self.parent);self.assertNotEqual(w,self.work);r=json.loads((w/'source-build.json').read_text());self.assertTrue(r['source_only']);self.assertFalse(r['original_or_target_read']);self.assertEqual(Path(r['object']).read_bytes(),(self.work/'TLIBDOS.OBJ').read_bytes())
 def project_copy(self,name):
  from tools import probe_mact_tlibdos as p
  d=self.parent/name;d.mkdir();project=d/'project'
  for name in p.SOURCES+p.NOTICES+p.PRODUCERS+[p.DESCRIPTOR,p.PROVENANCE]:
   q=project/name;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/name,q)
  return project
 def update_source(self,project,path,text):
  from tools import probe_mact_tlibdos as p
  (project/path).write_text(text);f=project/p.PROVENANCE;e=json.loads(f.read_text());e['tracked_sources_sha256'][path]=hashlib.sha256((project/path).read_bytes()).hexdigest();f.write_text(json.dumps(e,indent=2)+'\n')
 def test_actual_clock_arithmetic_controls_full_gate(self):
  from tools import probe_mact_tlibdos as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):tuple(v)for k,v in self.report['placements'].items()};symbols=self.report['verification']['publics']
  for name,before,after in [('hour','HOUR_MS = 3600000','HOUR_MS = 3600001'),('hundredths','lea eax,[ebx*4]','lea eax,[ebx*2]')]:
   with self.subTest(name=name):
    project=self.project_copy(name);path=p.MODEL+'/TLIBDOS.S';text=(project/path).read_text();self.assertIn(before,text);self.update_source(project,path,text.replace(before,after));w=p.build_source(self.home,self.parent/(name+'-native'),project=project);m=Module.parse((w/'TLIBDOS.OBJ').read_bytes());self.assertEqual(p.inventory(m),self.report['native_inventory'])
    with self.assertRaises(ValueError):verify_module(m,image,places,symbols)
 def test_scope_alias_storage_and_notice_controls_before_native(self):
  from tools import probe_mact_tlibdos as p
  from unittest.mock import patch
  cases={'payload':('xor eax,eax','xor eax,eax; .byte 0x90'),'alias':('.globl I_Time_,TIMELIB_StartTiming_,TIMELIB_StopTiming_','.globl I_Time_,TIMELIB_StartTiming_,TIMELIB_StopTiming_,fake_alias_'),'padding':(' nop\n',' .zero 1\n'),'owners':('_stoptics: .zero 4\n_starttics: .zero 4','_starttics: .zero 4\n_stoptics: .zero 4')}
  for name in list(cases)+['notice']:
   with self.subTest(name=name):
    project=self.project_copy('pre-'+name)
    if name=='notice':
     n=p.NOTICES[0];(project/n).unlink();f=project/p.PROVENANCE;e=json.loads(f.read_text());del e['notice_files_sha256'][n];f.write_text(json.dumps(e)+'\n')
    else:
     before,after=cases[name];path=p.MODEL+'/TLIBDOS.S';text=(project/path).read_text();self.assertIn(before,text);self.update_source(project,path,text.replace(before,after))
    with patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as run:
     with self.assertRaises(ValueError):p.build_source(self.home,self.parent/('pre-native-'+name),project=project)
     run.assert_not_called()
 def test_preflight_side_effect_cannot_rebaseline_staged_source(self):
  from tools import probe_mact_tlibdos as p
  from unittest.mock import patch
  project=self.project_copy('preflight-race');load=p.load;parent=self.parent/'preflight-race-native';modified=[]
  def racing_load(name,path):
   m=load(name,path)
   if name=='closed_tlibdos_contract':
    source=m.source
    def side_effect(text):
     result=source(text);q=Path(path).parent/'TLIBDOS.S';q.write_bytes(q.read_bytes()+b'\n# staged race\n');modified.append(str(q));return result
    m.source=side_effect
   return m
  with patch.object(p,'load',side_effect=racing_load),patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as run:
   with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
   run.assert_not_called()
  self.assertEqual(len(modified),1);self.assertFalse(list(parent.rglob('source-build.json')))
 def test_standalone_optimized_python_needs_no_observers(self):
  from tools import probe_mact_tlibdos as p
  project=self.project_copy('standalone');script=project/'run.py';script.write_text('''from pathlib import Path
import runpy,sys
R=Path(__file__).parent.resolve()
def guard(event,args):
 if event=='open' and isinstance(args[0],(str,bytes)):
  p=str(args[0])
  if '/reference/' in p or p.lower().endswith(('duke3d.exe','mact386.lib')):raise RuntimeError('reference producer read')
sys.addaudithook(guard)
sys.argv=[str(R/'tools/probe_mact_tlibdos.py'),'--source-only','--elf-home',sys.argv[1],'--build',str(R/'native'),'--report',str(R/'receipt.json')]
runpy.run_path(str(R/'tools/probe_mact_tlibdos.py'),run_name='__main__')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(self.home)],capture_output=True,text=True);(project/'run.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);receipt=json.loads((project/'receipt.json').read_text());self.assertFalse((project/'reference').exists());self.assertFalse((project/'evidence/watcom-runtime-components.json').exists());self.assertEqual(Path(receipt['object']).read_bytes(),(self.work/'TLIBDOS.OBJ').read_bytes())
 def test_all_six_roles_remain_strict_under_python_O(self):
  from tools import probe_mact_tlibdos as p
  script=self.parent/'optimized_roles.py';script.write_text('''from pathlib import Path
import sys,dataclasses,importlib.util
R=Path(sys.argv[1]);sys.path[:0]=[str(R),str(R/'profiles/watcom/tools')]
from omf32 import Module
s=importlib.util.spec_from_file_location('tlib_contract',R/'src/mact/tlibdos/contract.py');c=importlib.util.module_from_spec(s);s.loader.exec_module(c)
o=Module.parse((R/'reference/duke3d-reconstructions/MACT386.LIB').read_bytes()[12800:13862]);m=Module.parse(Path(sys.argv[2]).read_bytes());c.roles(o,m)
for i,f in enumerate(m.fixups):
 old=m.fixups[i];m.fixups[i]=dataclasses.replace(f,relative=not f.relative)
 try:c.roles(o,m)
 except ValueError:pass
 else:raise RuntimeError('optimized interpreter admitted wrong role')
 m.fixups[i]=old
print('PYTHON_O_ALL6_ROLES_REJECT')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(ROOT),str(self.work/'TLIBDOS.OBJ')],capture_output=True,text=True);(self.parent/'optimized-roles.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);self.assertIn('PYTHON_O_ALL6_ROLES_REJECT',r.stdout)
 def test_code_tail_BSS_scope_and_alignment_controls(self):
  from tools import probe_mact_tlibdos as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  m=Module.parse((self.work/'TLIBDOS.OBJ').read_bytes());image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):tuple(v)for k,v in self.report['placements'].items()};symbols=self.report['verification']['publics'];spec=json.loads((ROOT/p.DESCRIPTOR).read_text())
  for segment,offset in [(4,0),(4,328),(8,7)]:
   z=copy.deepcopy(m);z._segment(segment).data[offset]^=1
   with self.assertRaises(ValueError):verify_module(z,image,places,symbols)
  z=copy.deepcopy(m);z.local_publics.add('_starttics')
  with self.assertRaises(ValueError):p.check_native(z,spec)
  wrong=dict(places);wrong[8]=(places[8][0],places[8][1]+1)
  with self.assertRaisesRegex(ValueError,'alignment'):verify_module(m,image,wrong,symbols)
 def home_links(self,name):
  # Child-only mutations; linked source/tool bytes are never modified.
  home=self.parent/name;home.mkdir()
  for src in self.home.rglob('*'):
   if src.is_file():q=home/src.relative_to(self.home);q.parent.mkdir(parents=True,exist_ok=True);os.link(src,q)
  return home
 def test_whole_toolhome_after_each_native_stage(self):
  from tools import probe_mact_tlibdos as p
  from unittest.mock import patch
  real=p.subprocess.run
  for phase in ['as-new','objconv']:
   with self.subTest(phase=phase):
    home=self.home_links('home-race-'+phase);parent=self.parent/('home-race-native-'+phase)
    def run(cmd,*a,**kw):
     r=real(cmd,*a,**kw)
     if Path(cmd[0]).name==phase:(home/'unexpected-after-native').write_text('race\n')
     return r
    with patch.object(p.subprocess,'run',side_effect=run):
     with self.assertRaisesRegex(ValueError,'file set'):p.build_source(home,parent)
    self.assertFalse(list(parent.rglob('source-build.json')))
 def test_source_stage_and_native_intermediate_freshness(self):
  from tools import probe_mact_tlibdos as p
  from unittest.mock import patch
  real=p.subprocess.run
  for phase in ['project','stage','native']:
   with self.subTest(phase=phase):
    project=self.project_copy('input-race-'+phase);parent=self.parent/('input-race-native-'+phase)
    def run(cmd,*a,**kw):
     r=real(cmd,*a,**kw)
     if Path(cmd[0]).name=='as-new'and phase in ['project','stage']:
      q=project/p.MODEL/'tlibdos-counterpart.c'if phase=='project'else Path(cmd[-1]).parent/'tlibdos-counterpart.c';q.write_bytes(q.read_bytes()+b'\n/* actual source race */\n')
     if Path(cmd[0]).name=='objconv'and phase=='native':q=Path(cmd[-2]);q.write_bytes(q.read_bytes()+b'\0')
     return r
    with patch.object(p.subprocess,'run',side_effect=run):
     with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    self.assertFalse(list(parent.rglob('source-build.json')))
 def test_raw_ELF_symbol_field_and_backing_damage(self):
  from tools import probe_mact_tlibdos as p
  import struct
  c=p.load('test_tlib_raw',ROOT/p.MODEL/'contract.py');pre=json.loads((self.work/'preflight.json').read_text());raw=(self.work/'TLIBDOS.ELF').read_bytes();e=pre['elf'];logical=pre['logical_source'];h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);ss=[struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*i)for i in range(13)];symbol=ss[10][4]+4*16
  cases=[(7,b'\x03'),(h[5]+4*40+32,struct.pack('<I',1)),(h[5]+9*40+4,struct.pack('<I',1)),(ss[5][4]+4,struct.pack('<I',999<<8|1)),(ss[5][4]+4,struct.pack('<I',9<<8|3)),(symbol+12,b'\x20'),(symbol+13,b'\x02'),(symbol+14,b'\xf2\xff')]
  for offset,data in cases:
   with self.subTest(offset=offset,data=data):
    z=bytearray(raw);z[offset:offset+len(data)]=data
    with self.assertRaises((ValueError,IndexError,struct.error)):c.elf(z,e,logical)
 def test_consistently_parsed_duplicate_REL_is_rejected(self):
  from tools import probe_mact_tlibdos as p
  from profiles.gnu_elf_omf.elf32 import elf
  import struct
  pre=json.loads((self.work/'preflight.json').read_text());raw=bytearray((self.work/'TLIBDOS.ELF').read_bytes());h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);rel=struct.unpack_from('<IIIIIIIIII',raw,h[5]+5*40);struct.pack_into('<I',raw,rel[4]+8,8);path=self.parent/'duplicate-role.ELF';path.write_bytes(raw);c=p.load('test_tlib_duplicate',ROOT/p.MODEL/'contract.py')
  with self.assertRaisesRegex(ValueError,'complete REL offsets'):c.elf(raw,elf(path),pre['logical_source'])
