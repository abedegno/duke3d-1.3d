"""Complete normal WAD source capsule; native tools/decoder required, no skips."""
from pathlib import Path
import unittest,tempfile,json,os,hashlib,shutil,copy,dataclasses,subprocess
ROOT=Path(__file__).resolve().parents[1]
class NativeWad(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools.probe_mact_wad import build_source,observe
  cls.parent=Path(tempfile.mkdtemp(prefix='wad-test-',dir=ROOT/'build'));cls.home=Path(os.environ.get('GNU_ELF_OMF_HOME',ROOT/'toolchains/gnu-elf-omf'));cls.work=build_source(cls.home,cls.parent);cls.report=observe(cls.work)
 def test_complete_whole_scope_and_roles(self):
  p=self.report;self.assertEqual((p['verification']['initialized_bytes'],p['verification']['zero_fill_bytes'],p['verification']['verified_fixups']),(4384,140,245));self.assertEqual(len(p['private_correspondences']),9);self.assertEqual(p['private_references'],81);self.assertEqual(p['public_self_call_fields'],14);self.assertEqual(len(p['complete_CODE_listing']),1157)
 def test_reusable_parent(self):
  from tools.probe_mact_wad import build_source
  w=build_source(self.home,self.parent);self.assertNotEqual(w,self.work);self.assertEqual((w/'WAD.OBJ').read_bytes(),(self.work/'WAD.OBJ').read_bytes())
 def project_copy(self,name):
  from tools import probe_mact_wad as p
  project=self.parent/name/'project';project.mkdir(parents=True)
  for n in p.SOURCES+p.NOTICES+p.PRODUCERS+[p.DESCRIPTOR,p.PROVENANCE]:
   q=project/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
  return project
 def update_source(self,project,path,text):
  from tools import probe_mact_wad as p
  (project/path).write_text(text);f=project/p.PROVENANCE;e=json.loads(f.read_text());e['tracked_sources_sha256'][path]=hashlib.sha256((project/path).read_bytes()).hexdigest();f.write_text(json.dumps(e,indent=2)+'\n')
 def test_real_seek_and_string_pointer_controls(self):
  from tools import probe_mact_wad as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):tuple(v)for k,v in self.report['placements'].items()};symbols=self.report['verification']['publics']
  for case in ['seek','pointer']:
   project=self.project_copy(case);path=p.MODEL+'/WAD.S';text=(project/path).read_text()
   if case=='seek':
    a=text.index('WAD_WriteWadTable_:');head,tail=text[:a],text[a:];self.assertIn('mov ebx,1',tail);text=head+tail.replace('mov ebx,1','mov ebx,2',1)
   else:self.assertIn('.long lt_unknown,lt_pic,lt_lpic,lt_post',text);text=text.replace('.long lt_unknown,lt_pic,lt_lpic,lt_post','.long lt_unknown,lt_lpic,lt_lpic,lt_post',1)
   self.update_source(project,path,text);w=p.build_source(self.home,self.parent/(case+'-native'),project=project);m=Module.parse((w/'WAD.OBJ').read_bytes());self.assertEqual(p.inventory(m),self.report['native_inventory'])
   with self.assertRaises(ValueError):verify_module(m,image,places,symbols)
 def test_standalone_under_optimized_python(self):
  from tools import probe_mact_wad as p
  project=self.project_copy('standalone');script=project/'run.py';script.write_text('''from pathlib import Path
import sys,runpy
R=Path(__file__).parent.resolve()
def guard(event,args):
 if event=='open' and isinstance(args[0],(str,bytes)):
  p=str(args[0])
  if '/reference/' in p or p.lower().endswith(('duke3d.exe','mact386.lib')):raise RuntimeError('reference read during source production')
sys.addaudithook(guard)
sys.argv=[str(R/'tools/probe_mact_wad.py'),'--source-only','--elf-home',sys.argv[1],'--build',str(R/'native'),'--report',str(R/'receipt.json')]
runpy.run_path(str(R/'tools/probe_mact_wad.py'),run_name='__main__')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(self.home)],capture_output=True,text=True);(project/'standalone.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);receipt=json.loads((project/'receipt.json').read_text());self.assertFalse((project/'reference').exists());self.assertEqual(Path(receipt['object']).read_bytes(),(self.work/'WAD.OBJ').read_bytes())
 def test_scope_payload_notice_and_private_owner_controls(self):
  from tools import probe_mact_wad as p
  from unittest.mock import patch
  for case in ['private','payload','notice']:
   project=self.project_copy('pre-'+case)
   if case=='notice':
    n=p.NOTICES[0];(project/n).unlink();f=project/p.PROVENANCE;e=json.loads(f.read_text());del e['notice_files_sha256'][n];f.write_text(json.dumps(e)+'\n')
   else:
    path=p.MODEL+'/WAD.S';text=(project/path).read_text();text=text.replace('_wadfilename:','.globl _wadfilename\n_wadfilename:',1)if case=='private'else text.replace('push ebx','push ebx; .byte 0x90',1);self.update_source(project,path,text)
   with patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as run:
    with self.assertRaises(ValueError):p.build_source(self.home,self.parent/('pre-native-'+case),project=project)
    run.assert_not_called()
 def test_preflight_generation_boundary_race(self):
  from tools import probe_mact_wad as p
  from unittest.mock import patch
  project=self.project_copy('preflight-race');load=p.load;parent=self.parent/'preflight-race-native';changed=[]
  def racing_load(name,path):
   m=load(name,path)
   if name=='closed_wad_source':
    check=m.check
    def race(text):
     result=check(text);q=Path(path).parent/'WAD.S';q.write_bytes(q.read_bytes()+b'\n# actual preflight staged source race\n');changed.append(str(q));return result
    m.check=race
   return m
  with patch.object(p,'load',side_effect=racing_load),patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as run:
   with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
   run.assert_not_called()
  self.assertEqual(len(changed),1);self.assertFalse(list(parent.rglob('source-build.json')))
 def test_private_tail_DATA_BSS_field_and_alignment_damage(self):
  from tools import probe_mact_wad as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  m=Module.parse((self.work/'WAD.OBJ').read_bytes());image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):tuple(v)for k,v in self.report['placements'].items()};symbols=self.report['verification']['publics'];spec=json.loads((ROOT/p.DESCRIPTOR).read_text())
  for sn,off in [(4,0),(4,3325),(5,17),(7,0),(8,139)]:
   z=copy.deepcopy(m);z._segment(sn).data[off]^=1
   with self.assertRaises(ValueError):verify_module(z,image,places,symbols)
  wrong=dict(places);wrong[4]=(places[4][0],places[4][1]+1)
  with self.assertRaisesRegex(ValueError,'alignment'):verify_module(m,image,wrong,symbols)
  z=copy.deepcopy(m);z.publics['_wadfilename']=(8,0)
  with self.assertRaises(ValueError):p.check_native(z,spec)
 def test_all245_named_roles_remain_guarded_under_python_O(self):
  script=self.parent/'roles-optimized.py';script.write_text('''from pathlib import Path
import sys,dataclasses,json
R=Path(sys.argv[1]);sys.path[:0]=[str(R),str(R/'profiles/watcom/tools')]
from tools import probe_mact_wad as p
from omf32 import Module
m=Module.parse(Path(sys.argv[2]).read_bytes());spec=json.loads((R/p.DESCRIPTOR).read_text());p.check_native(m,spec)
for i,f in enumerate(m.fixups):
 old=m.fixups[i];m.fixups[i]=dataclasses.replace(f,relative=not f.relative)
 try:p.check_native(m,spec)
 except ValueError:pass
 else:raise RuntimeError('optimized Python admitted wrong typed role')
 m.fixups[i]=old
print('ALL245_ROLES_REJECT')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(ROOT),str(self.work/'WAD.OBJ')],capture_output=True,text=True);(self.parent/'roles-optimized.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);self.assertIn('ALL245_ROLES_REJECT',r.stdout)
 def home_links(self,name):
  home=self.parent/name;home.mkdir()
  for src in self.home.rglob('*'):
   if src.is_file():q=home/src.relative_to(self.home);q.parent.mkdir(parents=True,exist_ok=True);os.link(src,q)
  return home
 def test_whole_toolhome_after_each_native_stage(self):
  from tools import probe_mact_wad as p
  from unittest.mock import patch
  real=p.subprocess.run
  for phase in ['as','OBJ','COFF']:
   home=self.home_links('home-race-'+phase);parent=self.parent/('home-race-native-'+phase)
   def run(cmd,*a,**kw):
    r=real(cmd,*a,**kw);match=Path(cmd[0]).name=='as-new'if phase=='as'else Path(cmd[-1]).suffix=='.'+phase
    if match:(home/'unexpected-after-native').write_text('race\n')
    return r
   with patch.object(p.subprocess,'run',side_effect=run):
    with self.assertRaisesRegex(ValueError,'file set'):p.build_source(home,parent)
   self.assertFalse(list(parent.rglob('source-build.json')))
 def test_source_stage_and_prior_output_cannot_change(self):
  from tools import probe_mact_wad as p
  from unittest.mock import patch
  real=p.subprocess.run
  for phase in ['project','stage','ELF','OBJ']:
   project=self.project_copy('input-race-'+phase);parent=self.parent/('input-race-native-'+phase)
   def run(cmd,*a,**kw):
    r=real(cmd,*a,**kw)
    if Path(cmd[0]).name=='as-new'and phase in ['project','stage']:
     q=project/p.MODEL/'WAD.C'if phase=='project'else Path(cmd[-1]).parent/'WAD.C';q.write_bytes(q.read_bytes()+b'\n/* actual source race */\n')
    if Path(cmd[0]).name=='objconv'and phase=='ELF':q=Path(cmd[-2]);q.write_bytes(q.read_bytes()+b'\0')
    if Path(cmd[-1]).suffix=='.COFF'and phase=='OBJ':q=Path(cmd[-1]).with_suffix('.OBJ');q.write_bytes(q.read_bytes()+b'\0')
    return r
   with patch.object(p.subprocess,'run',side_effect=run):
    with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
   self.assertFalse(list(parent.rglob('source-build.json')))
 def test_raw_ELF_source_scope_and_relocation_damage(self):
  from tools import probe_mact_wad as p
  from profiles.gnu_elf_omf.elf32 import elf
  import struct
  raw=(self.work/'WAD.ELF').read_bytes();e=json.loads((self.work/'preflight.json').read_text());source=(ROOT/p.MODEL/'WAD.S').read_text();c=p.load('wadrawtest',ROOT/p.MODEL/'elf_contract.py');h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);ss=[struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*i)for i in range(14)];pub=next(s for s in e['symbols'].get('11',e['symbols'].get(11))if s['name']=='WAD_ReadHeader_');po=ss[11][4]+16*pub['index'];damages=[(7,b'\x03'),(h[5]+4*40+32,struct.pack('<I',1)),(h[5]+10*40+4,struct.pack('<I',1)),(ss[5][4]+4,struct.pack('<I',999<<8|1)),(ss[9][4]+4,struct.pack('<I',1<<8|3)),(po+12,b'\x20'),(po+13,b'\x02'),(po+14,b'\xf2\xff')]
  for offset,data in damages:
   z=bytearray(raw);z[offset:offset+len(data)]=data
   with self.assertRaises((ValueError,IndexError,struct.error)):c.check(z,e,source)
