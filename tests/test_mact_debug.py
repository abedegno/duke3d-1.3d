from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
class NormalDebugAvailable(unittest.TestCase):
 def test_complete_normal_descriptor_exists(self):
  self.assertTrue((ROOT/'modules/mact_debug.json').is_file(),'normal complete DEBUG descriptor missing')

import copy,json,shutil,struct,subprocess,sys,tempfile,importlib.util
from dataclasses import replace
from unittest.mock import patch
from tools import probe_mact_debug as capsule,prove_module as driver
from le import LEImage
from tools.verify_module import verify_module,external_anchor_bindings
HOME=ROOT/'toolchains/gnu-omf';DECODER=ROOT/'toolchains/capstone'
class NativeDebug(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.work=Path(tempfile.mkdtemp(prefix='debug-native-test-',dir=ROOT/'build'));cls.report=driver.prove('mact_debug',HOME,cls.work/'parent');cls.native=Path(cls.report['native_build_directory']);cls.stage=cls.native/'source-only';cls.module=capsule.Module.parse(Path(cls.report['object']).read_bytes());cls.original=capsule.Module.parse((ROOT/capsule.LIBRARY).read_bytes()[512:4814]);cls.image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());cls.spec=json.loads((ROOT/capsule.DESCRIPTOR).read_text());cls.guard=capsule.load_guard(cls.stage);cls.source=(cls.stage/'DEBUG.S').read_bytes();cls.listing=(cls.native/'DEBUG.LST').read_text();cls.coff=(cls.native/'DEBUG.COFF').read_bytes();cls.pre=cls.guard.preflight(cls.coff,cls.source,cls.listing);cls.post=cls.guard.postflight(cls.coff,cls.source,cls.listing,Path(cls.report['object']).read_bytes(),cls.pre)
  s=importlib.util.spec_from_file_location('_debug_scope_test',cls.stage/'scope_roles.py');cls.scope=importlib.util.module_from_spec(s);s.loader.exec_module(cls.scope)
 def gate(self,m):return verify_module(m,self.image,self.report['placements'],self.report['symbol_anchors'])
 def project(self,name):
  d=self.work/name;d.mkdir();names=set(capsule.TRACKED_STAGE.values())|set(capsule.PRODUCER_TOOLS)|set(capsule.NOTICES)|{capsule.PROVENANCE,capsule.DESCRIPTOR}
  for n in names:p=d/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,p)
  return d
 def cli(self,d):return subprocess.run([sys.executable,str(d/'tools/probe_mact_debug.py'),'--source-only','--home',str(HOME.resolve()),'--decoder-home',str(DECODER.resolve()),'--build',str(d/'output'),'--report',str(d/'source.json')],capture_output=True,text=True)
 def test_full_fields_callback_scope_and_original_roles(self):
  self.assertEqual(tuple(self.report['verification'][k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']),(1361,4,76));self.assertEqual(tuple(self.report['reference_verification'][k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']),(1361,4,79));self.assertEqual(self.report['verification']['publics'],external_anchor_bindings(self.report['reference_verification']));self.assertEqual(self.report['verification']['local_symbols'],{})
  self.assertEqual([s.size for s in self.module.segments],[0,0,0,1033,176,0,152,4]);self.assertEqual([s.attributes for s in self.module.segments],[169,169,169,41,169,41,41,41]);self.assertEqual((len(self.module.publics),len(self.module.externals)),(20,7));self.assertEqual((self.report['runtime_private_identities'],self.report['absolute_constants'],self.report['assembler_resolved_branches']),(34,4,27));r=self.report['scope_role_correspondence'];self.assertEqual((r['original_roles'],r['native_typed_roles'],r['resolved_same_TU_CALL_roles']),(79,76,3));self.assertEqual(len(r['private_identities']),8);self.assertEqual(r['private_anchor_names'],[]);self.assertTrue(r['all_source_private_names_preserved']);self.assertEqual(len(r['all_original_roles']),79)
  callbacks=[u for u in self.pre['symbolic_uses']if u['kind']=='typed-output-callback'];self.assertEqual([u['name']for u in callbacks],['DBG_ScreenPrint_','DBG_FileStartup_','DBG_FilePrint_','DBG_FileShutdown_']);self.assertEqual([u['source_value']for u in callbacks],[0,16,64,100]);self.assertEqual(self.report['source_credit'],0)
 def test_source_only_standalone_and_fresh_native_children(self):
  d=self.project('standalone');self.assertFalse((d/'reference').exists());self.assertFalse((d/capsule.CALLER).exists());p=self.cli(d);(d/'CLI.LOG').write_text(p.stdout+p.stderr);self.assertEqual(p.returncode,0,p.stdout+p.stderr);r=json.loads((d/'source.json').read_text());self.assertTrue(r['source_only']);self.assertNotIn('verification',r);self.assertFalse(r['original_or_target_read_during_production']);self.assertEqual(r['normal_native_inventory'],self.spec['native_inventory']);self.assertFalse(any('/reference/'in p or '/task422' in p or '/task413' in p for p in r['producer_inputs_sha256']))
  r=driver.prove('mact_debug',HOME,self.work/'parent');self.assertNotEqual(r['native_build_directory'],self.report['native_build_directory']);self.assertEqual(r['verification'],self.report['verification']);self.assertEqual(r['scope_role_correspondence'],self.report['scope_role_correspondence'])
 def test_source_header_caid_tool_and_notice_identity(self):
  for i,n in enumerate(['src/mact/debug.asm','src/mact/debug/debug_counterpart.c','src/mact/debug/include/_debug.h','src/mact/debug/scope_roles.py','src/mact/debug/contract.py','tools/probe_mact_debug.py','profiles/capstone/identity.py']):
   d=self.project('identity-'+str(i));p=d/n;p.write_bytes(p.read_bytes()+b'\n# changed identity\n');r=self.cli(d);self.assertNotEqual(r.returncode,0);self.assertFalse((d/'output').exists())
  d=self.project('notice');p=d/capsule.PROVENANCE;e=json.loads(p.read_text());del e['notice_files_sha256'][capsule.NOTICES[0]];p.write_text(json.dumps(e))
  with patch.object(capsule,'ROOT',d),patch.object(capsule.subprocess,'run')as run:
   with self.assertRaisesRegex(ValueError,'closed notice_files_sha256'):capsule.build_source(HOME,d/'output',DECODER)
   run.assert_not_called()
 def test_private_scope_and_four_callback_relocation_guards(self):
  sp=struct.unpack_from('<I',self.coff,8)[0];sym=next(s for s in self.pre['symbols']if s['name']=='_DBG_Out')
  for off,data in [(sp+sym['index']*18+16,b'\x02'),(sp+sym['index']*18+8,struct.pack('<I',105)),(18,b'\0\0')]:
   bad=bytearray(self.coff);bad[off:off+len(data)]=data
   with self.assertRaises(ValueError):self.guard.preflight(bytes(bad),self.source,self.listing)
  rp=struct.unpack_from('<I',self.coff,20+6*40+24)[0]
  for off,data in [(rp+8,b'\x14\0'),(rp+4,struct.pack('<I',0xffffffff))]:
   bad=bytearray(self.coff);bad[off:off+len(data)]=data
   with self.assertRaises(ValueError):self.guard.preflight(bytes(bad),self.source,self.listing)
  bad=copy.deepcopy(self.pre);del bad['definitions']['_DBG_Out']
  with self.assertRaisesRegex(ValueError,'genuine source private'):capsule.validate_private(bad,self.post,self.spec)
  v=copy.deepcopy(self.report['verification']);v['publics']['_DBG_Out']=[3,67888]
  with self.assertRaisesRegex(ValueError,'anchor leakage'):self.scope.correspondence(self.original,self.module,self.pre,self.post,v)
  o=copy.deepcopy(self.original);o.fixups.pop()
  with self.assertRaises(ValueError):self.scope.correspondence(o,self.module,self.pre,self.post,self.report['verification'])
 def test_whole_tail_fields_storage_and_typed_damage(self):
  for seg,off in [(3,393),(3,1032),(4,16),(6,0),(6,108),(7,0)]:
   m=copy.deepcopy(self.module);m.segments[seg].data[off]^=1
   with self.assertRaises(ValueError):self.gate(m)
  for field,value in [('relative',False),('target_method',1),('location',5)]:
   m=copy.deepcopy(self.module);i=next(i for i,f in enumerate(m.fixups)if f.relative);m.fixups[i]=replace(m.fixups[i],**{field:value})
   with self.assertRaises(ValueError):self.gate(m)
  m=copy.deepcopy(self.module);m.segments[7].size=8
  with self.assertRaisesRegex(ValueError,'native inventory'):capsule.validate_native(m,self.spec)
 def test_real_source_mutations_then_unchanged_target_rejects(self):
  changes=[('default-level','debug_normal,5','debug_normal,6',True),('callback','.long 0,DBG_ScreenPrint_,0','.long 0,DBG_FilePrint_,0',True),('private-export','_DBG_Out:\n','.globl _DBG_Out\n_DBG_Out:\n',False)]
  for name,old,new,succeeds in changes:
   d=self.project(name);p=d/'src/mact/debug.asm';s=p.read_text();self.assertEqual(s.count(old),1);p.write_text(s.replace(old,new));p=d/capsule.PROVENANCE;e=json.loads(p.read_text());e['tracked_sources_sha256']['src/mact/debug.asm']=capsule.digest(d/'src/mact/debug.asm');p.write_text(json.dumps(e));r=self.cli(d);(d/'CLI.LOG').write_text(r.stdout+r.stderr)
   if succeeds:
    self.assertEqual(r.returncode,0,r.stdout+r.stderr);v=json.loads((d/'source.json').read_text());self.assertNotEqual(v['object_sha256'],self.report['object_sha256'])
    with self.assertRaises(ValueError):self.gate(capsule.Module.parse(Path(v['object']).read_bytes()))
   else:self.assertNotEqual(r.returncode,0);self.assertIn('genuine source private',r.stderr)
 def test_full_tool_home_file_set_closed_after_native_run(self):
  # Separate processes let each actual decoder home own its import/library.
  for label,field,source in [('gnu','home',HOME),('decoder','decoder_home',DECODER)]:
   h=self.work/(label+'-copy');shutil.copytree(source,h);d=self.project('extra-'+label)
   code="""import sys
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,sys.argv[1])
from tools import probe_mact_debug as p
h=Path(sys.argv[2]);real=p.subprocess.run
def invoke(cmd,**kw):
 r=real(cmd,**kw)
 if Path(cmd[0]).name=='objconv':(h/'unexpected-file').write_text('unapproved addition')
 return r
with patch.object(p.subprocess,'run',side_effect=invoke):
 try:p.build_source(Path(sys.argv[3]),Path(sys.argv[4]),Path(sys.argv[5]))
 except ValueError as e:
  assert 'file set' in str(e),str(e)
  print('POST_HOME_REJECTED',e)
 else:raise AssertionError('extra home file accepted')
"""
   r=subprocess.run([sys.executable,'-c',code,str(d),str(h),str(h if field=='home'else HOME.resolve()),str(d/'output'),str(h if field=='decoder_home'else DECODER.resolve())],capture_output=True,text=True);(d/'POST_HOME.LOG').write_text(r.stdout+r.stderr);self.assertEqual(r.returncode,0,r.stdout+r.stderr);self.assertIn('POST_HOME_REJECTED',r.stdout)
 def test_current_normal_zone_source_header_options_and_typed_calls(self):
  from tools import probe_mact_zone as zone
  d=self.project('caller');names=set(zone.TRACKED_STAGE.values())|set(zone.PRODUCER_TOOLS)|set(zone.NOTICES)|{zone.PROVENANCE,zone.DESCRIPTOR,capsule.CALLER}
  for n in names:p=d/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,p)
  (d/'toolchains').mkdir();(d/'toolchains/gnu-omf').symlink_to(HOME.resolve(),target_is_directory=True);(d/'toolchains/capstone').symlink_to(DECODER.resolve(),target_is_directory=True)
  with patch.object(capsule,'ROOT',d):a,_=capsule.caller_anchors(d/'baseline')
  self.assertEqual(a,{'DBG_DbgString_':(1,545200)})
  p=d/'src/mact/zone/include/_zone.h';old=p.read_bytes();p.write_bytes(old+b'\n')
  with patch.object(capsule,'ROOT',d),self.assertRaises(ValueError):capsule.caller_anchors(d/'bad-header')
  p.write_bytes(old);p=d/capsule.CALLER;old=p.read_bytes();v=json.loads(old);v['commands'][0][1]='-different-option';p.write_text(json.dumps(v))
  with patch.object(capsule,'ROOT',d),patch.object(capsule,'CALLER_SHA256',capsule.digest(p)),self.assertRaisesRegex(ValueError,'producer options'):capsule.caller_anchors(d/'bad-options')
  p.write_bytes(old);v=json.loads(old);v['constraints'][next(i for i,q in enumerate(v['constraints'])if q.get('symbol')=='DBG_DbgString_')]['value']=[1,545201];p.write_text(json.dumps(v))
  with patch.object(capsule,'ROOT',d),patch.object(capsule,'CALLER_SHA256',capsule.digest(p)),self.assertRaisesRegex(ValueError,'typed DEBUG caller'):capsule.caller_anchors(d/'bad-edge')
 def test_closed_options_original_alignment_and_private_contract(self):
  for label,field,value in [('options','options',{'assembler':['-n'],'converter':['-fomf32','-wex']}),('alignment','original_logical_alignment',{'_TEXT':1,'CONST':4,'_DATA':4,'_BSS':16}),('scope','original_private_definitions',{})]:
   d=self.project('finite-'+label);p=d/capsule.DESCRIPTOR;e=json.loads(p.read_text());e[field]=value;p.write_text(json.dumps(e));p=d/capsule.PROVENANCE;e=json.loads(p.read_text());e['descriptor_sha256']=capsule.digest(d/capsule.DESCRIPTOR);p.write_text(json.dumps(e))
   with patch.object(capsule,'ROOT',d),self.assertRaises(ValueError):capsule.read_provenance()
