from pathlib import Path
import copy,hashlib,json,os,shutil,subprocess,sys,tempfile,unittest
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
class ActorsNative(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools import build_actors_native as p
  cls.p=p;cls.parent=Path(tempfile.mkdtemp(prefix='actors-native-test-',dir=ROOT/'build'));cls.home=Path(os.environ.get('GNU_LAYOUTS_HOME',ROOT/'toolchains/gnu-elf-omf-layouts'));cls.r=p.build_source(cls.home,cls.parent)
 def test_source_only_build_api_and_complete_whole_gate(self):
  p=self.p;r=self.r;self.assertEqual(r['object_sha256'],'d3ad94db01b800eb6a71a315c5dfe7b786beb53ec34271019b3ce15412342b88');self.assertEqual(r['native_schema']['all_unique_fields'],2812);self.assertEqual(r['native_schema']['all_ELF_COFF_primary_identities'],1881);p.check_freshness(r,self.home)
  from omf32 import Module
  from le import LEImage
  from tools.infer_bindings import infer_bindings
  from tools.verify_module import verify_module
  target=Path(os.environ.get('DUKE13_TARGET',ROOT/'reference/DUKE3D.EXE'));image=LEImage.parse(target.read_bytes());m=Module.parse(Path(r['object']).read_bytes());known={n:tuple(v)for n,v in json.loads((ROOT/'evidence/actors-module.json').read_bytes())['external_bindings'].items()};b=infer_bindings(m,image,1,84160,known_symbols=known);proof=verify_module(m,image,b['placements'],b['symbols']);self.assertEqual(tuple(proof[k]for k in['initialized_bytes','zero_fill_bytes','verified_fixups']),(61741,6,2812));self.assertFalse({'_radius_status_record','_dmval'}&b['symbols'].keys());self.assertEqual(len(m.publics),38)
 def project(self,name):
  p=self.p;root=self.parent/name/'project'
  for n in p.SOURCES+p.NOTICE_PATHS+p.PRODUCERS+[p.PROVENANCE,p.DESCRIPTOR]:
   dest=root/n;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,dest)
  return root
 def test_standalone_Python_O_no_development_target_or_decoder(self):
  project=self.project('standalone');report=self.parent/'standalone.json';cmd=[sys.executable,'-O',str(project/'tools/build_actors_native.py'),'--home',str(self.home),'--build',str(self.parent/'standalone-native'),'--report',str(report)];r=subprocess.run(cmd,cwd=project,capture_output=True,text=True);self.assertEqual(r.returncode,0,r.stdout+r.stderr);got=json.loads(report.read_bytes());self.assertEqual(got['object_sha256'],self.r['object_sha256']);self.assertFalse((project/'reference').exists());self.assertFalse(any(project.rglob('*.obj')));self.assertFalse(any(project.rglob('*capstone*')))
 def test_precopy_source_notice_and_scope_alias_controls_before_native(self):
  p=self.p;real=shutil.copyfile
  for suffix in ['ACTORS.S','GPL-2.0.txt']:
   def mutate(src,dst,**kw):
    v=real(src,dst,**kw)
    if Path(dst).name==suffix:Path(dst).write_bytes(Path(dst).read_bytes()+b'\n# copied-only mutation\n')
    return v
   with self.subTest(suffix=suffix),patch.object(p.shutil,'copyfile',side_effect=mutate),patch.object(p.subprocess,'run')as native:
    with self.assertRaisesRegex(ValueError,'identity changed'):p.build_source(self.home,self.parent/'copy-controls')
    native.assert_not_called()
  project=self.project('scope');s=project/p.SOURCE/'ACTORS.S';text=s.read_text().replace('.local _radius_status_record','.globl _radius_status_record');s.write_text(text);ref=project/p.PROVENANCE;e=json.loads(ref.read_bytes());e['source_files_sha256'][p.SOURCE+'/ACTORS.S']=hashlib.sha256(s.read_bytes()).hexdigest();ref.write_text(json.dumps(e))
  with patch.object(p,'ROOT',project),patch.object(p.subprocess,'run')as native:
   with self.assertRaisesRegex(ValueError,'reviewed source identity'):p.build_source(self.home,self.parent/'scope-control')
   native.assert_not_called()
 def test_JSON_guard_uses_exact_validated_RAW_and_notice_keyset(self):
  p=self.p;root=self.project('json');auth=root/'four';auth.mkdir()
  for n in p.AUTHORED:shutil.copyfile(root/p.SOURCE/n,auth/n)
  guard=p.load_module(root/p.SOURCE/'source_policy.py')
  with patch.object(Path,'read_text',side_effect=RuntimeError('second unvalidated read')):self.assertEqual(guard.check(auth,root/p.SOURCE/'source-policy.json')['instruction_count'],15470)
  ref=root/p.PROVENANCE;e=json.loads(ref.read_bytes());e['notice_files_sha256'].pop(p.NOTICE_PATHS[0]);ref.write_text(json.dumps(e))
  with patch.object(p,'ROOT',root),patch.object(p.subprocess,'run')as native:
   with self.assertRaisesRegex(ValueError,'notice_files_sha256 keyset'):p.build_source(self.home,self.parent/'notice-control')
   native.assert_not_called()
 def test_native_duplicate_field_and_output_publication_cleanup(self):
  p=self.p;work=Path(self.r['native_build_directory']);schema=p.load_module(ROOT/p.SOURCE/'native_schema.py');damage=self.parent/'damaged';damage.mkdir();
  for n in['ACTORS.ELF','ACTORS.OBJ','ACTORS.COFF']:shutil.copyfile(work/n,damage/n)
  import struct
  raw=bytearray((damage/'ACTORS.COFF').read_bytes());h=struct.unpack_from('<8sIIIIIIHHI',raw,20+3*40);at=h[5];raw[at+10:at+20]=raw[at:at+10];(damage/'ACTORS.COFF').write_bytes(raw)
  from omf32 import Module
  with self.assertRaisesRegex(ValueError,'unique2812'):schema.check(damage,Module.parse((damage/'ACTORS.OBJ').read_bytes()),self.r['native_schema']['clock_bounds'])
  original=p.dump;seen=[]
  def damage_after_receipt(path,data):
   original(path,data)
   if Path(path).name=='source-build.json':
    seen.append(Path(path));q=Path(data['object']);q.write_bytes(q.read_bytes()+b'changed')
  with patch.object(p,'dump',side_effect=damage_after_receipt):
   with self.assertRaisesRegex(ValueError,'identity changed'):p.build_source(self.home,self.parent/'publication-control')
  self.assertTrue(seen);self.assertFalse(any(q.exists()for q in seen))
 def test_reusable_parent_and_no_default_mode_edits(self):
  r=self.p.build_source(self.home,self.parent);self.assertNotEqual(r['native_build_directory'],self.r['native_build_directory']);self.assertEqual(r['object_sha256'],self.r['object_sha256']);self.assertEqual(r['opt_in_link_handoff'],{'replace':'O001.OBJ','remove_FILE':'O002.OBJ'})
if __name__=='__main__':unittest.main()
