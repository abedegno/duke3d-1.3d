"""Complete normal CLRMAP, generated semantic constants and real CS table."""
from pathlib import Path
import unittest,tempfile,json,os,hashlib,shutil,copy,dataclasses,subprocess
ROOT=Path(__file__).resolve().parents[1]
class NativeClrmap(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools.probe_mact_clrmap import build_source,observe
  cls.parent=Path(tempfile.mkdtemp(prefix='clrmap-test-',dir=ROOT/'build'));cls.home=Path(os.environ.get('GNU_ELF_IMPORTS_HOME',ROOT/'toolchains/gnu-elf-omf-imports'));cls.work=build_source(cls.home,cls.parent);cls.report=observe(cls.work)
 def test_full_source_original_private_table_and_unused_imports(self):
  p=self.report;self.assertEqual(tuple(p['verification'][k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']),(5383,16,120));self.assertEqual(len(p['all_original_roles']['roles']),120);self.assertEqual(p['all_original_roles']['private_references'],3);self.assertEqual(len(p['typed_CODE_table']),6);self.assertEqual(p['source_private_definitions'],154);self.assertEqual(p['genuine_unused_imports'],['_fltused_','__init_387_emulator','__8087']);self.assertFalse(p['private_anchor_names'])
 def project_copy(self,name):
  from tools import probe_mact_clrmap as p
  project=self.parent/name/'project';project.mkdir(parents=True)
  for n in p.SOURCES+p.NOTICES+p.PRODUCERS+[p.DESCRIPTOR,p.PROVENANCE]:
   q=project/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
  return project
 def update_source(self,project,path,text):
  from tools import probe_mact_clrmap as p
  (project/path).write_text(text);f=project/p.PROVENANCE;j=json.loads(f.read_text());j['tracked_sources_sha256'][path]=hashlib.sha256((project/path).read_bytes()).hexdigest();f.write_text(json.dumps(j,indent=2)+'\n')
 def test_reusable_parent_and_complete_COFF_source_scope(self):
  from tools import probe_mact_clrmap as p
  w=p.build_source(self.home,self.parent);self.assertNotEqual(w,self.work);self.assertEqual((w/'CLRMAP.OBJ').read_bytes(),(self.work/'CLRMAP.OBJ').read_bytes());c=json.loads((w/'coff-audit.json').read_text());self.assertEqual(len(c['symbols']),203);self.assertEqual(len(c['relations']),120);self.assertTrue(c['private154_ABS15_retained'])
 def test_ELF_COFF_OBJ_races_never_publish(self):
  from tools import probe_mact_clrmap as p
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
      if name=='closed_clrmap_contract':
       original=m.coff
       def side_effect(raw,e):
        result=original(raw,e);q=next(parent.glob('clrmap-*/CLRMAP.COFF'));q.write_bytes(q.read_bytes()+b'\0');return result
       m.coff=side_effect
      return m
     with patch.object(p,'load',side_effect=racing_load):
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    else:
     check=p.check_native
     def racing_check(m,spec):
      check(m,spec);q=next(parent.glob('clrmap-*/CLRMAP.OBJ'));q.write_bytes(q.read_bytes()+b'\0')
     with patch.object(p,'check_native',side_effect=racing_check):
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    self.assertFalse(list(parent.rglob('source-build.json')))
 def test_complete_home_after_conversion_closes_before_publication(self):
  from tools import probe_mact_clrmap as p
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
  from tools import probe_mact_clrmap as p
  project=self.project_copy('standalone');script=project/'run.py';script.write_text('''from pathlib import Path
import runpy,sys
R=Path(__file__).parent.resolve()
def guard(event,args):
 if event=='open'and isinstance(args[0],(str,bytes)):
  n=str(args[0]).lower()
  if '/reference/'in n or n.endswith(('duke3d.exe','mact386.lib'))or'/task480-'in n or'/task494-'in n:raise RuntimeError('forbidden source producer observer/research read')
sys.addaudithook(guard)
try:(R/'reference/DUKE3D.EXE').read_bytes()
except RuntimeError:pass
else:raise RuntimeError('audit hook not active')
sys.argv=[str(R/'tools/probe_mact_clrmap.py'),'--source-only','--elf-home',sys.argv[1],'--build',str(R/'native'),'--report',str(R/'receipt.json')]
runpy.run_path(str(R/'tools/probe_mact_clrmap.py'),run_name='__main__')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(self.home.resolve())],capture_output=True,text=True);(project/'run.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);receipt=json.loads((project/'receipt.json').read_text());self.assertEqual(Path(receipt['object']).read_bytes(),(self.work/'CLRMAP.OBJ').read_bytes());self.assertFalse((project/'reference').exists())
 def test_all120_field_modes_strict_under_python_O(self):
  script=self.parent/'roles-O.py';script.write_text('''from pathlib import Path
import sys,json,dataclasses,importlib.util
R=Path(sys.argv[1]);sys.path[:0]=[str(R),str(R/'profiles/watcom/tools')]
from omf32 import Module
sp=importlib.util.spec_from_file_location('strict_clrmap',R/'src/mact/clrmap/contract.py');c=importlib.util.module_from_spec(sp);sp.loader.exec_module(c)
w=Path(sys.argv[2]);m=Module.parse((w/'CLRMAP.OBJ').read_bytes());e=json.loads((w/'preflight.json').read_text())['elf'];coff=json.loads((w/'coff-audit.json').read_text());c.native(m,e,coff)
for i,f in enumerate(m.fixups):
 m.fixups[i]=dataclasses.replace(f,relative=not f.relative)
 try:c.native(m,e,coff)
 except ValueError:pass
 else:raise RuntimeError('wrong relative mode admitted')
 m.fixups[i]=f
print('PYTHON_O_ALL120_FIELDS_REJECT')
''');r=subprocess.run([os.sys.executable,'-O',str(script),str(ROOT),str(self.work)],capture_output=True,text=True);(self.parent/'roles-O.log').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stderr);self.assertIn('PYTHON_O_ALL120_FIELDS_REJECT',r.stdout)
 def test_duplicate_COFF_field_record_cannot_replace_another(self):
  import struct,importlib.util
  sp=importlib.util.spec_from_file_location('strict_coff_duplicate',ROOT/'src/mact/clrmap/contract.py');c=importlib.util.module_from_spec(sp);sp.loader.exec_module(c);raw=bytearray((self.work/'CLRMAP.COFF').read_bytes());rel=struct.unpack_from('<I',raw,20+40*3+24)[0];raw[rel+10:rel+20]=raw[rel:rel+10];e=json.loads((self.work/'preflight.json').read_text())['elf']
  with self.assertRaises(ValueError):c.coff(bytes(raw),e)

 def test_real_HSV_scalar_and_palette_source_controls(self):
  from tools import probe_mact_clrmap as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):v for k,v in self.report['placements'].items()};symbols=self.report['verification']['publics']
  for name,file,a,z in [('hsv-sector','CLRMAP.S','cmp edi, 5','cmp edi, 4'),('CS-scale','CLRMAP.S','jmp dword ptr cs:[eax*4 + hsv_sector_table]','jmp dword ptr cs:[eax*2 + hsv_sector_table]'),('named-coefficient','color_constants.py',"('yiq_y_green',.5866)","('yiq_y_green',.5)"),('palette','CLRMAP.S','.byte 0,0,EGA_FULL # blue','.byte 0,EGA_DARK,EGA_FULL # blue')]:
   with self.subTest(name=name):
    project=self.project_copy(name);path=p.MODEL+'/'+file;s=(project/path).read_text();self.assertEqual(s.count(a),1);self.update_source(project,path,s.replace(a,z));w=p.build_source(self.home,self.parent/(name+'-native'),project=project);m=Module.parse((w/'CLRMAP.OBJ').read_bytes());self.assertEqual(p.inventory(m),self.report['native_inventory'])
    with self.assertRaisesRegex(ValueError,'differing bytes'):verify_module(m,image,places,symbols)
 def test_scope_header_notice_payload_and_missing_unused_import_before_native(self):
  from tools import probe_mact_clrmap as p
  from unittest.mock import patch
  cases={'private-export':('_egargb:','.globl _egargb\n_egargb:'),'unused-import':('.globl _fltused_\n',''),'payload':('cmp edi, 5','cmp edi, 5; .byte 0x90'),'extra-storage':('.zero 16 # sixteen actual global palette indices','.zero 16\n.zero 16')}
  for name in [*cases,'header','notice','missing-table-word']:
   with self.subTest(name=name):
    project=self.project_copy(name)
    if name=='notice':
     n=p.NOTICES[1];(project/n).unlink();f=project/p.PROVENANCE;j=json.loads(f.read_text());del j['notice_files_sha256'][n];f.write_text(json.dumps(j)+'\n')
    elif name=='header':
     path=p.MODEL+'/include/_clrmap.h';self.update_source(project,path,(project/path).read_text()+'\n/* changed primary */\n')
    else:
     path=p.MODEL+'/CLRMAP.S';s=(project/path).read_text()
     if name=='missing-table-word':a,z=',hsv_sector_magenta_red\n','\n'
     else:a,z=cases[name]
     self.assertIn(a,s);self.update_source(project,path,s.replace(a,z,1))
    with patch.object(p.subprocess,'run',side_effect=RuntimeError('native must not run'))as run:
     with self.assertRaises(ValueError):p.build_source(self.home,self.parent/(name+'-prenative'),project=project)
     run.assert_not_called()
 def test_copy_live_generation_and_post_assembly_generated_races(self):
  from tools import probe_mact_clrmap as p
  from unittest.mock import patch
  for phase in ['live-copy','generation','generated-post-assembly']:
   with self.subTest(phase=phase):
    project=self.project_copy('race-'+phase);parent=self.parent/('race-native-'+phase)
    if phase=='live-copy':
     copier=p.shutil.copyfile
     def race(src,dst,*a,**kw):
      result=copier(src,dst,*a,**kw)
      if str(src).endswith('/CLRMAP.S'):q=Path(src);q.write_bytes(q.read_bytes()+b'\n# live source changed after copy\n')
      return result
     with patch.object(p.shutil,'copyfile',side_effect=race),patch.object(p.subprocess,'run',side_effect=RuntimeError('must not run'))as run:
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
      run.assert_not_called()
    elif phase=='generation':
     load=p.load
     def race(name,path):
      m=load(name,path)
      if name=='closed_clrmap_colors':
       generate=m.generate
       def changed():
        result=generate();q=Path(path).parent/'CLRMAP.S';q.write_bytes(q.read_bytes()+b'\n# generation side effect\n');return result
       m.generate=changed
      return m
     with patch.object(p,'load',side_effect=race),patch.object(p.subprocess,'run',side_effect=RuntimeError('must not run'))as run:
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
      run.assert_not_called()
    else:
     run=p.subprocess.run
     def race(cmd,*a,**kw):
      result=run(cmd,*a,**kw)
      if str(cmd[0]).endswith('as-new'):q=Path(cmd[-1]).parent/'COLOR_CONSTANTS.INC';q.write_bytes(q.read_bytes()+b'\n# post-assembly generation race\n')
      return result
     with patch.object(p.subprocess,'run',side_effect=race):
      with self.assertRaisesRegex(ValueError,'changed'):p.build_source(self.home,parent,project=project)
    self.assertFalse(list(parent.rglob('source-build.json')))
 def test_complete_raw_scopes_tail_storage_and_typed_CS_controls(self):
  import struct
  from tools import probe_mact_clrmap as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import verify_module
  from profiles.gnu_elf_omf.elf32 import elf
  c=p.load('damage_clrmap_contract',ROOT/p.MODEL/'contract.py');colors=p.load('damage_clrmap_colors',ROOT/p.MODEL/'color_constants.py');m=Module.parse((self.work/'CLRMAP.OBJ').read_bytes());image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());places={int(k):v for k,v in self.report['placements'].items()};symbols=self.report['verification']['publics']
  for seg,off in [(4,4710),(5,623),(7,47)]:
   q=copy.deepcopy(m);q._segment(seg).data[off]^=1
   with self.assertRaises(ValueError):verify_module(q,image,places,symbols)
  raw=(self.work/'CLRMAP.ELF').read_bytes();h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);symtab=struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*10)[4];e=json.loads((self.work/'preflight.json').read_text())['elf'];private=next(s for tab in e['symbols'].values()for s in tab if s['name']=='_egargb');text=(ROOT/p.MODEL/'CLRMAP.S').read_text();logical=c.source(text,colors);listing=(self.work/'CLRMAP.LST').read_text()
  for name,off,fmt,v in [('BYTE_CODE',h[5]+40*4+32,'I',1),('extra_BSS',h[5]+40*9+20,'I',17),('internal_marker',h[5]+40*7+4,'I',0xffffff99),('weak_private',symtab+16*private['index']+12,'B',32),('COMMON_private',symtab+16*private['index']+14,'H',65522)]:
   q=bytearray(raw);struct.pack_into('<'+fmt,q,off,v);path=self.parent/(name+'.ELF');path.write_bytes(q)
   with self.assertRaises(ValueError):c.elf(bytes(q),elf(path),logical,text,colors,listing)
  raw=(self.work/'CLRMAP.COFF').read_bytes();table=struct.unpack_from('<I',raw,8)[0];audit=json.loads((self.work/'coff-audit.json').read_text());private=next(s for s in audit['symbols']if s['name']=='_egargb');q=bytearray(raw);q[table+18*private['index']+16]=2
  with self.assertRaises(ValueError):c.coff(bytes(q),e)
  q=copy.deepcopy(m);f=q.fixups[0];q.fixups[0]=dataclasses.replace(f,relative=True)
  with self.assertRaises(ValueError):c.native(q,e,audit)
