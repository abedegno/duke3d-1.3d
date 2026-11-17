"""Focused normal ELF ROX route; native tools required, never silently skipped."""
from pathlib import Path
import unittest, tempfile, json, os, hashlib, shutil, copy
ROOT=Path(__file__).resolve().parents[1]
class RoxProfile(unittest.TestCase):
 def test_distinct_elf_profile_and_source_fork(self):
  from profiles.gnu_elf_omf.identity import profile
  p=profile();self.assertEqual(p['tools']['bin/as-new']['sha256'],'55218742bd2ef982d53e5f46246bff3cd3a949a72c3a69fda62a021fb4e28ce6');self.assertEqual(set(p['converter_fork']['changed_files']),{'omf.h','cof2omf.cpp'})
 def test_setup_rejects_unpinned_tool_before_publication(self):
  from profiles.gnu_elf_omf.setup import stage
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as d:
   p=Path(d);bad=p/'bad';bad.write_bytes(b'not a compiler')
   with self.assertRaises(ValueError):stage(p/'home',bad,bad,bad,bad)
   self.assertFalse((p/'home').exists())
class NativeRox(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools.probe_mact_rox import build_source,observe
  cls.parent=Path(tempfile.mkdtemp(prefix='rox-test-',dir=ROOT/'build'));cls.home=Path(os.environ.get('GNU_ELF_OMF_HOME',ROOT/'toolchains/gnu-elf-omf'));cls.work=build_source(cls.home,cls.parent);cls.report=observe(cls.work)
 def test_whole_bytes_scope_and_all_roles(self):
  p=self.report;self.assertEqual((p['verification']['initialized_bytes'],p['verification']['zero_fill_bytes'],p['verification']['verified_fixups']),(1570,256,89));self.assertEqual(len(p['private_correspondences']),5);self.assertEqual(p['private_references'],29);self.assertEqual(p['public_self_call_fields'],12)
 def test_source_only_and_fresh_parent(self):
  from tools.probe_mact_rox import build_source
  w=build_source(self.home,self.parent);self.assertNotEqual(w,self.work);a=json.loads((w/'source-build.json').read_text());self.assertTrue(a['source_only']);self.assertFalse(a['original_or_target_read']);self.assertEqual(Path(a['object']).read_bytes(),(self.work/'ROX.OBJ').read_bytes())
 def project_copy(self,name):
  from tools import probe_mact_rox as p
  d=self.parent/name;d.mkdir();project=d/'project'
  for n in p.SOURCES+p.NOTICES+p.PRODUCERS+[p.DESCRIPTOR,p.PROVENANCE]:
   q=project/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
  return project
 def update_source_pin(self,project,path):
  from tools import probe_mact_rox as p
  f=project/p.PROVENANCE;e=json.loads(f.read_text());e['tracked_sources_sha256'][path]=hashlib.sha256((project/path).read_bytes()).hexdigest();f.write_text(json.dumps(e,indent=2)+'\n')
 def test_real_copy_bound_and_post_NUL_capacity_native_controls(self):
  from tools import probe_mact_rox as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):tuple(v)for k,v in self.report['placements'].items()};symbols=self.report['symbol_anchors']
  for name in ['copy-bound','literal-capacity']:
   with self.subTest(name=name):
    project=self.project_copy(name)
    if name=='copy-bound':
     path=p.MODEL+'/ROX.S';q=project/path;text=q.read_text();self.assertIn('mov ebx, ENTRY_NAME_BYTES',text);q.write_text(text.replace('mov ebx, ENTRY_NAME_BYTES','mov ebx, SECTION_NAME_BYTES',1))
    else:
     path=p.MODEL+'/literals.json';q=project/path;rows=json.loads(q.read_text());row=next(r for r in rows if(-len(r['text'])-1)%4>=2);row['text']+='\0X';q.write_text(json.dumps(rows,indent=2)+'\n')
    self.update_source_pin(project,path);w=p.build_source(self.home,self.parent/(name+'-native'),project=project);m=Module.parse((w/'ROX.OBJ').read_bytes());self.assertEqual(p.inventory(m),self.report['native_inventory'])
    with self.assertRaises(ValueError):verify_module(m,image,places,symbols)
 def test_scope_payload_and_notice_omission_before_native(self):
  from tools import probe_mact_rox as p
  from unittest.mock import patch
  for name in ['scope','payload','notice']:
   with self.subTest(name=name):
    project=self.project_copy('pre-'+name)
    if name=='notice':
     n=p.NOTICES[0];(project/n).unlink();f=project/p.PROVENANCE;e=json.loads(f.read_text());del e['notice_files_sha256'][n];f.write_text(json.dumps(e)+'\n')
    else:
     path=p.MODEL+'/ROX.S';q=project/path;t=q.read_text();t=t.replace('_ROX_started:','.globl _ROX_started\n_ROX_started:',1)if name=='scope'else t.replace('push ebx','.byte 0x53',1);q.write_text(t);self.update_source_pin(project,path)
    with patch.object(p.subprocess,'run',side_effect=AssertionError('native must not run'))as native:
     with self.assertRaises((ValueError,AssertionError)):p.build_source(self.home,self.parent/('reject-'+name),project=project)
     native.assert_not_called()
 def test_standalone_has_no_sdk_target_or_caller_inputs(self):
  from tools import probe_mact_rox as p
  import subprocess
  project=self.project_copy('standalone');script=project/'run.py';script.write_text('''from pathlib import Path
import sys,runpy
R=Path(__file__).parent.resolve()
def guard(event,args):
 if event=='open' and isinstance(args[0],(str,bytes)):
  q=str(args[0]);assert '/reference/' not in q and not q.lower().endswith(('duke3d.exe','mact386.lib')),q
sys.addaudithook(guard)
sys.argv=[str(R/'tools/probe_mact_rox.py'),'--source-only','--elf-home',sys.argv[1],'--build',str(R/'native'),'--report',str(R/'receipt.json')]
runpy.run_path(str(R/'tools/probe_mact_rox.py'),run_name='__main__')
''');z=subprocess.run([os.sys.executable,str(script),str(self.home)],capture_output=True,text=True);(project/'standalone.log').write_text(z.stdout+z.stderr);self.assertEqual(z.returncode,0,z.stderr);a=json.loads((project/'receipt.json').read_text());self.assertEqual(Path(a['object']).read_bytes(),(self.work/'ROX.OBJ').read_bytes());self.assertFalse((project/'reference').exists());self.assertFalse((project/'evidence/mact_util-module.json').exists())
 def test_every_field_metadata_and_alignment_damage(self):
  from tools import probe_mact_rox as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  import dataclasses
  image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());m=Module.parse((self.work/'ROX.OBJ').read_bytes());places={int(k):tuple(v)for k,v in self.report['placements'].items()};symbols=self.report['symbol_anchors'];spec=json.loads((ROOT/p.DESCRIPTOR).read_text())
  # All89 actual typed roles are independently required by the native contract.
  for i,f in enumerate(m.fixups):
   with self.subTest(field=i):
    z=copy.deepcopy(m);z.fixups[i]=dataclasses.replace(f,relative=not f.relative)
    with self.assertRaises(ValueError):p.check_native(z,spec)
  for segment,offset in [(4,0),(4,1216),(5,70),(6,0),(7,255)]:
   with self.subTest(segment=segment,offset=offset):
    z=copy.deepcopy(m);z._segment(segment).data[offset]^=1
    with self.assertRaises(ValueError):verify_module(z,image,places,symbols)
  wrong=dict(places);wrong[4]=(places[4][0],places[4][1]+1)
  with self.assertRaisesRegex(ValueError,'alignment'):verify_module(m,image,wrong,symbols)
  z=copy.deepcopy(m);z.publics['_ROX_started']=(6,0)
  with self.assertRaises(ValueError):p.check_native(z,spec)
  z=copy.deepcopy(m);z.default_libraries=['math387r']
  with self.assertRaises(ValueError):p.check_native(z,spec)
 def test_closed_raw_ELF_guards(self):
  from tools import probe_mact_rox as p
  import struct
  pre=json.loads((self.work/'preflight.json').read_text());raw=(self.work/'ROX.ELF').read_bytes();e=pre['elf'];guard=p.load('rox_schema_test',ROOT/p.MODEL/'source_guard.py');contract=p.load('rox_elf_test',ROOT/p.MODEL/'elf_contract.py');h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);ss=[struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*i)for i in range(12)];symbol=next(s for s in pre['symbols']if s['name']=='ROX_CreateSection_');off=ss[9][4]+16*symbol['index']
  damages=[(7,b'\x03'),(16,b'\x02\0'),(36,b'\x01\0\0\0'),(h[5]+4*40+32,struct.pack('<I',1)),(h[5]+8*40+4,struct.pack('<I',1)),(ss[5][4]+4,struct.pack('<I',999<<8|1)),(ss[5][4],struct.pack('<I',1215)),(off+12,b'\x20'),(off+13,b'\x02'),(off+14,b'\xf2\xff'),(off+12,b'\x16'),(off+14,b'\xf1\xff')]
  for where,data in damages:
   with self.subTest(where=where,data=data):
    z=bytearray(raw);z[where:where+len(data)]=data
    with self.assertRaises((AssertionError,ValueError,IndexError,struct.error)):contract.check(z,e,guard)
 def home_links(self,name):
  # Read-only hardlinks avoid copying large binaries. Only new child paths are
  # added/unlinked; original tool/source/notice bytes are never modified.
  home=self.parent/name;home.mkdir()
  for src in self.home.rglob('*'):
   if src.is_file():q=home/src.relative_to(self.home);q.parent.mkdir(parents=True,exist_ok=True);os.link(src,q)
  return home
 def test_tool_notice_required_before_native(self):
  from tools import probe_mact_rox as p
  from unittest.mock import patch
  home=self.home_links('missing-tool-notice');(home/'notices/GNU-COPYING3').unlink()
  with patch.object(p.subprocess,'run',side_effect=AssertionError('native must not run'))as native:
   with self.assertRaises(ValueError):p.build_source(home,self.parent/'bad-tool-native')
   native.assert_not_called()
 def test_full_home_inventory_after_assembler_and_converter(self):
  from tools import probe_mact_rox as p
  from unittest.mock import patch
  real=p.subprocess.run
  for phase in ['as-new','objconv']:
   with self.subTest(phase=phase):
    home=self.home_links('tool-race-'+phase);parent=self.parent/('tool-race-native-'+phase)
    def run(cmd,*a,**kw):
     r=real(cmd,*a,**kw)
     if Path(cmd[0]).name==phase:(home/'sources/unexpected-after-native').write_text('race\n')
     return r
    with patch.object(p.subprocess,'run',side_effect=run):
     with self.assertRaisesRegex(ValueError,'file set'):p.build_source(home,parent)
    self.assertFalse(list(parent.rglob('source-build.json')))
    if phase=='as-new':self.assertFalse(list(parent.rglob('*.OBJ')))
 def test_source_stage_and_native_output_races_reject(self):
  from tools import probe_mact_rox as p
  from unittest.mock import patch
  real=p.subprocess.run
  for phase in ['project','stage','native']:
   with self.subTest(phase=phase):
    project=self.project_copy('input-race-'+phase);parent=self.parent/('input-race-native-'+phase)
    def run(cmd,*a,**kw):
     r=real(cmd,*a,**kw)
     if Path(cmd[0]).name=='as-new'and phase in ['project','stage']:
      q=project/p.MODEL/'C-counterpart/rox.c'if phase=='project'else Path(cmd[-1]).parent/'C-counterpart/rox.c';q.write_bytes(q.read_bytes()+b'\n/* race */\n')
     if Path(cmd[0]).name=='objconv'and phase=='native':
      q=Path(cmd[-2]);q.write_bytes(q.read_bytes()+b'\0')
     return r
    with patch.object(p.subprocess,'run',side_effect=run):
     with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    self.assertFalse(list(parent.rglob('source-build.json')))
 def test_source_change_between_validation_and_snapshot_is_rejected(self):
  from tools import probe_mact_rox as p
  from unittest.mock import patch
  project=self.project_copy('snapshot-race');read=p.read_provenance
  def validate(*a,**kw):
   result=read(*a,**kw);q=project/p.MODEL/'C-counterpart/rox.c';q.write_bytes(q.read_bytes()+b'\n/* changed after validation */\n');return result
  with patch.object(p,'read_provenance',side_effect=validate),patch.object(p.subprocess,'run',side_effect=AssertionError('native must not run'))as native:
   with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,self.parent/'snapshot-race-native',project=project)
   native.assert_not_called()
 def test_logical_generation_cannot_recapture_changed_staged_source(self):
  from tools import probe_mact_rox as p
  from unittest.mock import patch
  project=self.project_copy('literal-generation-race');parent=self.parent/'literal-generation-race-native';load=p.load;mutated=[]
  def racing_load(name,path):
   module=load(name,path)
   if name=='logical_rox_literals':
    generate=module.generate
    def race():
     result=generate();source=Path(path).parent/'ROX.S';source.write_bytes(source.read_bytes()+b'\n# real generation-time staged source race\n');mutated.append(str(source));return result
    module.generate=race
   return module
  with patch.object(p,'load',side_effect=racing_load):
   with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
  self.assertEqual(len(mutated),1);self.assertFalse(list(parent.rglob('source-build.json')));self.assertFalse(list(parent.rglob('ROX.ELF')))
