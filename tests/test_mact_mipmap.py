"""Complete normal MIPMAP source, exact imports/ABI/storage and source-only closure."""
from pathlib import Path
import unittest,tempfile,json,os,hashlib,shutil,copy,dataclasses,subprocess
ROOT=Path(__file__).resolve().parents[1]
class NativeMipmap(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools.probe_mact_mipmap import build_source,observe
  cls.parent=Path(tempfile.mkdtemp(prefix='mipmap-test-',dir=ROOT/'build'));cls.home=Path(os.environ.get('GNU_ELF_IMPORTS_HOME',ROOT/'toolchains/gnu-elf-omf-imports'));cls.work=build_source(cls.home,cls.parent);cls.report=observe(cls.work)
 def test_complete_source_original_scopes_imports_and_roles(self):
  p=self.report;self.assertEqual(p['verification'],p['reference_verification']);self.assertEqual(tuple(p['verification'][k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']),(1141,0,10));self.assertEqual(len(p['all_original_roles']),10);self.assertEqual(p['genuine_unused_imports'],['_fltused_','__init_387_emulator','__8087']);self.assertEqual(p['source_private_definitions'],15);self.assertEqual(p['runtime_private_definitions'],0);self.assertFalse(p['private_anchor_names'])
 def project_copy(self,name):
  from tools import probe_mact_mipmap as p
  project=self.parent/name/'project';project.mkdir(parents=True)
  for n in p.SOURCES+p.NOTICES+p.PRODUCERS+[p.DESCRIPTOR,p.PROVENANCE]:
   q=project/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
  return project
 def update_source(self,project,path,text):
  from tools import probe_mact_mipmap as p
  (project/path).write_text(text);f=project/p.PROVENANCE;j=json.loads(f.read_text());j['tracked_sources_sha256'][path]=hashlib.sha256((project/path).read_bytes()).hexdigest();f.write_text(json.dumps(j,indent=2)+'\n')
 def test_reusable_parent_and_complete_COFF_source_scope(self):
  from tools import probe_mact_mipmap as p
  w=p.build_source(self.home,self.parent);self.assertNotEqual(w,self.work);self.assertEqual((w/'MIPMAP.OBJ').read_bytes(),(self.work/'MIPMAP.OBJ').read_bytes());c=json.loads((w/'coff-audit.json').read_text());self.assertEqual(len(c['symbols']),56);self.assertEqual(len(c['relations']),10);self.assertTrue(c['private15_ABS30_retained'])
 def test_actual_semantic_scale_palette_and_ABI_controls(self):
  from tools import probe_mact_mipmap as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):v for k,v in self.report['placements'].items()};symbols=self.report['verification']['publics']
  for name,a,z in [('scale','channel_scale: .double 0.00390625','channel_scale: .double 0.0078125'),('inclusive-endpoint','push 256','push 255'),('stack-cleanup','ret 12','ret 8'),('neighbor-blue','fld qword ptr [edx+PIXEL_BYTES+PIXEL_BLUE]','fld qword ptr [edx+PIXEL_BYTES+PIXEL_GREEN]')]:
   with self.subTest(name=name):
    project=self.project_copy(name);path=p.MODEL+'/MIPMAP.S';s=(project/path).read_text();self.assertGreaterEqual(s.count(a),1);self.update_source(project,path,s.replace(a,z,1));w=p.build_source(self.home,self.parent/(name+'-native'),project=project);m=Module.parse((w/'MIPMAP.OBJ').read_bytes());self.assertEqual(p.inventory(m),self.report['native_inventory'])
    with self.assertRaisesRegex(ValueError,'differing bytes'):verify_module(m,image,places,symbols)
 def test_scope_import_payload_header_and_notice_controls_before_native(self):
  from tools import probe_mact_mipmap as p
  from unittest.mock import patch
  cases={'private-export':('channel_scale: .double','.globl channel_scale\nchannel_scale: .double'),'unused-import-loss':('.globl _fltused_,__init_387_emulator,__8087','.globl _fltused_,__init_387_emulator'),'payload':('xor edx, edx','xor edx, edx; .byte 0x90'),'storage':('channel_scale: .double 0.00390625','channel_scale: .double 0.00390625\n.double 0.0')}
  for name in [*cases,'header','notice']:
   with self.subTest(name=name):
    project=self.project_copy(name)
    if name=='notice':
     n=p.NOTICES[0];(project/n).unlink();f=project/p.PROVENANCE;j=json.loads(f.read_text());del j['notice_files_sha256'][n];f.write_text(json.dumps(j)+'\n')
    elif name=='header':
     path=p.MODEL+'/include/mipmap.h';s=(project/path).read_text();self.update_source(project,path,s.replace('int32 origw','int16 origw'))
    else:
     a,z=cases[name];path=p.MODEL+'/MIPMAP.S';s=(project/path).read_text();self.assertIn(a,s);self.update_source(project,path,s.replace(a,z,1))
    with patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as run:
     with self.assertRaises(ValueError):p.build_source(self.home,self.parent/(name+'-pre-native'),project=project)
     run.assert_not_called()
 def test_preflight_side_effect_does_not_rebaseline_source(self):
  from tools import probe_mact_mipmap as p
  from unittest.mock import patch
  project=self.project_copy('source-race');load=p.load
  def racing(name,path):
   m=load(name,path)
   if name=='closed_mipmap_contract':
    original=m.source
    def side_effect(text):
     result=original(text);q=Path(path).parent/'MIPMAP.S';q.write_bytes(q.read_bytes()+b'\n# staged mutation\n');return result
    m.source=side_effect
   return m
  with patch.object(p,'load',side_effect=racing),patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as run:
   with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,self.parent/'source-race-native',project=project)
   run.assert_not_called()
  self.assertFalse(list((self.parent/'source-race-native').rglob('source-build.json')))
 def test_ELF_COFF_OBJ_races_never_publish(self):
  from tools import probe_mact_mipmap as p
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
      if name=='closed_mipmap_contract':
       original=m.coff
       def side_effect(raw,e):
        result=original(raw,e);q=next(parent.glob('mipmap-*/MIPMAP.COFF'));q.write_bytes(q.read_bytes()+b'\0');return result
       m.coff=side_effect
      return m
     with patch.object(p,'load',side_effect=racing_load):
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    else:
     check=p.check_native
     def racing_check(m,spec):
      check(m,spec);q=next(parent.glob('mipmap-*/MIPMAP.OBJ'));q.write_bytes(q.read_bytes()+b'\0')
     with patch.object(p,'check_native',side_effect=racing_check):
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    self.assertFalse(list(parent.rglob('source-build.json')))
 def test_complete_home_after_conversion_closes_before_publication(self):
  from tools import probe_mact_mipmap as p
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
  from tools import probe_mact_mipmap as p
  project=self.project_copy('standalone');script=project/'run.py';script.write_text('''from pathlib import Path
import runpy,sys
R=Path(__file__).parent.resolve()
def guard(event,args):
 if event=='open'and isinstance(args[0],(str,bytes)):
  n=str(args[0]).lower()
  if '/reference/'in n or n.endswith(('duke3d.exe','mact386.lib'))or'/task488-'in n or'/task497-'in n:raise RuntimeError('forbidden source producer observer/research read')
sys.addaudithook(guard)
try:(R/'reference/DUKE3D.EXE').read_bytes()
except RuntimeError:pass
else:raise RuntimeError('audit hook not active')
sys.argv=[str(R/'tools/probe_mact_mipmap.py'),'--source-only','--elf-home',sys.argv[1],'--build',str(R/'native'),'--report',str(R/'receipt.json')]
runpy.run_path(str(R/'tools/probe_mact_mipmap.py'),run_name='__main__')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(self.home.resolve())],capture_output=True,text=True);(project/'run.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);receipt=json.loads((project/'receipt.json').read_text());self.assertEqual(Path(receipt['object']).read_bytes(),(self.work/'MIPMAP.OBJ').read_bytes());self.assertFalse((project/'reference').exists())
 def test_all10_field_modes_strict_under_python_O(self):
  script=self.parent/'roles-O.py';script.write_text('''from pathlib import Path
import sys,json,dataclasses,importlib.util
R=Path(sys.argv[1]);sys.path[:0]=[str(R),str(R/'profiles/watcom/tools')]
from omf32 import Module
sp=importlib.util.spec_from_file_location('strict_mipmap',R/'src/mact/mipmap/contract.py');c=importlib.util.module_from_spec(sp);sp.loader.exec_module(c)
w=Path(sys.argv[2]);m=Module.parse((w/'MIPMAP.OBJ').read_bytes());e=json.loads((w/'preflight.json').read_text())['elf'];coff=json.loads((w/'coff-audit.json').read_text());c.native(m,e,coff)
for i,f in enumerate(m.fixups):
 m.fixups[i]=dataclasses.replace(f,relative=not f.relative)
 try:c.native(m,e,coff)
 except ValueError:pass
 else:raise RuntimeError('wrong relative mode admitted')
 m.fixups[i]=f
print('PYTHON_O_ALL10_FIELDS_REJECT')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(ROOT),str(self.work)],capture_output=True,text=True);(self.parent/'roles-O.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);self.assertIn('PYTHON_O_ALL10_FIELDS_REJECT',r.stdout)
 def test_complete_tail_scalar_ELF_COFF_scope_and_alignment_controls(self):
  import struct,importlib.util
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  from profiles.gnu_elf_omf.elf32 import elf
  sp=importlib.util.spec_from_file_location('closed_mip_raw',ROOT/'src/mact/mipmap/contract.py');c=importlib.util.module_from_spec(sp);sp.loader.exec_module(c);m=Module.parse((self.work/'MIPMAP.OBJ').read_bytes());image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):v for k,v in self.report['placements'].items()};symbols=self.report['verification']['publics']
  for seg,off in [(4,1132),(5,7)]:
   q=copy.deepcopy(m);q._segment(seg).data[off]^=1
   with self.assertRaises(ValueError):verify_module(q,image,places,symbols)
  raw=(self.work/'MIPMAP.ELF').read_bytes();h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);symtab=struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*10)[4];e=json.loads((self.work/'preflight.json').read_text())['elf'];private=next(s for tab in e['symbols'].values()for s in tab if s['name']=='channel_scale');logical=c.source((ROOT/'src/mact/mipmap/MIPMAP.S').read_text());listing=(self.work/'MIPMAP.LST').read_text()
  for name,off,fmt,v in [('BYTE_CODE',h[5]+40*4+32,'I',1),('extra_BSS',h[5]+40*9+20,'I',4),('internal_marker',h[5]+40*7+4,'I',0xffffff99),('weak_private',symtab+16*private['index']+12,'B',32),('COMMON_private',symtab+16*private['index']+14,'H',65522)]:
   q=bytearray(raw);struct.pack_into('<'+fmt,q,off,v);path=self.parent/(name+'.ELF');path.write_bytes(q)
   with self.assertRaises(ValueError):c.elf(bytes(q),elf(path),logical,listing)
  raw=(self.work/'MIPMAP.COFF').read_bytes();table=struct.unpack_from('<I',raw,8)[0];audit=json.loads((self.work/'coff-audit.json').read_text());private=next(s for s in audit['symbols']if s['name']=='channel_scale');q=bytearray(raw);q[table+18*private['index']+16]=2
  with self.assertRaises(ValueError):c.coff(bytes(q),e)
 def test_duplicate_COFF_field_record_cannot_replace_another(self):
  import struct,importlib.util
  sp=importlib.util.spec_from_file_location('strict_coff_duplicate',ROOT/'src/mact/mipmap/contract.py');c=importlib.util.module_from_spec(sp);sp.loader.exec_module(c);raw=bytearray((self.work/'MIPMAP.COFF').read_bytes());rel=struct.unpack_from('<I',raw,20+40*3+24)[0];raw[rel+10:rel+20]=raw[rel:rel+10];e=json.loads((self.work/'preflight.json').read_text())['elf']
  with self.assertRaises(ValueError):c.coff(bytes(raw),e)
