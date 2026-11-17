from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
class NormalZoneAvailable(unittest.TestCase):
 def test_normal_module_exists(self):
  self.assertTrue((ROOT/'modules/mact_zone.json').is_file(),'normal complete ZONE descriptor missing')

import copy,json,shutil,struct,subprocess,sys,tempfile,importlib.util
from dataclasses import replace
from unittest.mock import patch
from tools import probe_mact_zone as capsule,prove_module as driver
from le import LEImage
from tools.verify_module import external_anchor_bindings,verify_module
HOME=ROOT/'toolchains/gnu-omf';DECODER=ROOT/'toolchains/capstone'
class NativeZone(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.work=Path(tempfile.mkdtemp(prefix='zone-native-test-',dir=ROOT/'build'));cls.report=driver.prove('mact_zone',HOME,cls.work/'parent');cls.native=Path(cls.report['native_build_directory']);cls.stage=cls.native/'source-only';cls.module=capsule.Module.parse(Path(cls.report['object']).read_bytes());cls.original=capsule.Module.parse((ROOT/capsule.LIBRARY).read_bytes()[15360:23400]);cls.image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());cls.spec=json.loads((ROOT/capsule.DESCRIPTOR).read_text());cls.guard=capsule.load_guard(cls.stage);cls.source=(cls.stage/'ZONE.S').read_bytes();cls.listing=(cls.native/'ZONE.LST').read_text();cls.coff=(cls.native/'ZONE.COFF').read_bytes();cls.pre=cls.guard.preflight(cls.coff,cls.source,cls.listing);cls.post=cls.guard.postflight(cls.coff,cls.source,cls.listing,Path(cls.report['object']).read_bytes(),cls.pre)
  s=importlib.util.spec_from_file_location('_zone_test_scope',cls.stage/'scope_roles.py');cls.scope=importlib.util.module_from_spec(s);s.loader.exec_module(cls.scope)
 def gate(self,m):return verify_module(m,self.image,self.report['placements'],self.report['symbol_anchors'])
 def project(self,name):
  d=self.work/name;d.mkdir();names=set(capsule.TRACKED_STAGE.values())|set(capsule.PRODUCER_TOOLS)|set(capsule.NOTICES)|{capsule.PROVENANCE,capsule.DESCRIPTOR}
  for n in names:p=d/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,p)
  return d
 def cli(self,d):return subprocess.run([sys.executable,str(d/'tools/probe_mact_zone.py'),'--source-only','--home',str(HOME.resolve()),'--decoder-home',str(DECODER.resolve()),'--build',str(d/'output'),'--report',str(d/'source.json')],capture_output=True,text=True)
 def test_complete_geometry_raw_fields_and_truthful_scope(self):
  v=self.report['verification'];o=self.report['reference_verification'];self.assertEqual(tuple(v[k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']),(3826,48,78));self.assertEqual(tuple(o[k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']),(3826,48,114));self.assertEqual(v['publics'],external_anchor_bindings(o));self.assertEqual(v['local_symbols'],{});self.assertEqual(set(o['local_symbols']),set(self.spec['original_private_definitions']));self.assertEqual(len(self.module.publics),22);self.assertEqual(len(self.module.externals),8);self.assertEqual([s.size for s in self.module.segments],[0,0,0,2367,1427,0,32,48]);self.assertEqual([s.attributes for s in self.module.segments],[169,169,169,41,41,41,41,41])
  self.assertEqual((self.report['runtime_private_identities'],self.report['absolute_constants'],self.report['assembler_resolved_branches']),(127,17,122));r=self.report['scope_role_correspondence'];self.assertEqual((r['original_roles'],r['native_typed_roles'],r['resolved_same_TU_CALL_roles']),(114,78,36));self.assertEqual(len(r['all_original_roles']),114);self.assertEqual(len(r['private_identities']),7);self.assertTrue(r['all_source_private_names_preserved']);self.assertEqual(r['private_anchor_names'],[])
  self.assertEqual(bytes(self.module.segments[4].data),bytes(self.original.segments[1].data));self.assertEqual(bytes(self.module.segments[6].data),bytes(self.original.segments[3].data));self.assertEqual(bytes(self.module.segments[7].data),bytes(48));self.assertEqual(self.report['source_credit'],0)
  for n in ['LargestBlockAvail','LargestLockablePage','LinAddrSpace']:self.assertIn(n,{x['name']for x in self.post['private_identities']})
  self.assertEqual(self.report['commands'][0][1:6],['-n','-march=i386','--fatal-warnings','-L','-no-pad-sections'])
 def test_fresh_children_and_standalone_without_reference(self):
  r=driver.prove('mact_zone',HOME,self.work/'parent');self.assertNotEqual(r['native_build_directory'],self.report['native_build_directory']);self.assertEqual(r['verification'],self.report['verification']);self.assertEqual(r['scope_role_correspondence'],self.report['scope_role_correspondence'])
  d=self.project('standalone');self.assertFalse((d/'reference').exists());p=self.cli(d);(d/'CLI.LOG').write_text(p.stdout+p.stderr);self.assertEqual(p.returncode,0,p.stdout+p.stderr);r=json.loads((d/'source.json').read_text());self.assertTrue(r['source_only']);self.assertNotIn('verification',r);self.assertFalse(r['original_or_target_read_during_production']);self.assertEqual(r['normal_native_inventory'],self.spec['native_inventory']);self.assertFalse(any('/reference/'in p or '/zone181/'in p or '/task403-'in p for p in r['producer_inputs_sha256']))
 def test_source_caid_headers_model_scope_and_decoder_pins(self):
  for i,n in enumerate(['src/mact/zone.asm','src/mact/zone/zone_counterpart.c','src/mact/zone/zone_diagnostics.py','src/mact/zone/include/_zone.h','src/mact/zone/scope_roles.py','profiles/capstone/identity.py','tools/probe_mact_zone.py']):
   d=self.project('identity-'+str(i));p=d/n;p.write_bytes(p.read_bytes()+b'\n# identity changed\n');r=self.cli(d);self.assertNotEqual(r.returncode,0);self.assertFalse((d/'output').exists())
 def test_required_notices_and_finite_options(self):
  d=self.project('notice-drop');p=d/capsule.PROVENANCE;e=json.loads(p.read_text());del e['notice_files_sha256'][capsule.NOTICES[0]];p.write_text(json.dumps(e))
  with patch.object(capsule,'ROOT',d),patch.object(capsule.subprocess,'run')as run:
   with self.assertRaisesRegex(ValueError,'closed notice_files_sha256'):capsule.build_source(HOME,d/'output',DECODER)
   run.assert_not_called()
  d=self.project('options');p=d/capsule.DESCRIPTOR;e=json.loads(p.read_text());e['options']['assembler'].remove('-L');p.write_text(json.dumps(e));p=d/capsule.PROVENANCE;e=json.loads(p.read_text());e['descriptor_sha256']=capsule.digest(d/capsule.DESCRIPTOR);p.write_text(json.dumps(e))
  with patch.object(capsule,'ROOT',d),self.assertRaisesRegex(ValueError,'finite ZONE producer options'):capsule.read_provenance()
  for label,field,new in [('align','original_logical_alignment',{'_TEXT':1,'CONST':4,'_DATA':4,'_BSS':16}),('private','original_private_definitions',{})]:
   d=self.project('contract-'+label);p=d/capsule.DESCRIPTOR;e=json.loads(p.read_text());e[field]=new;p.write_text(json.dumps(e));p=d/capsule.PROVENANCE;e=json.loads(p.read_text());e['descriptor_sha256']=capsule.digest(d/capsule.DESCRIPTOR);p.write_text(json.dumps(e))
   with patch.object(capsule,'ROOT',d),self.assertRaisesRegex(ValueError,'finite original ZONE'):capsule.read_provenance()

 def test_source_private_names_scopes_bss_and_role_completeness(self):
  sp=struct.unpack_from('<I',self.coff,8)[0];s=next(x for x in self.pre['symbols']if x['name']=='_MemoryZone');bad=bytearray(self.coff);bad[sp+18*s['index']+16]=2
  with self.assertRaises(ValueError):self.guard.preflight(bytes(bad),self.source,self.listing)
  bad=bytearray(self.coff);struct.pack_into('<I',bad,20+40*7+36,3222274112)
  with self.assertRaises(ValueError):self.guard.preflight(bytes(bad),self.source,self.listing)
  bad=copy.deepcopy(self.pre);del bad['definitions']['_MemInfo']
  with self.assertRaisesRegex(ValueError,'genuine source private'):capsule.validate_private(bad,self.post,self.spec)
  v=copy.deepcopy(self.report['verification']);v['publics']['_MemoryZone']=(3,67984)
  with self.assertRaisesRegex(ValueError,'anchor leakage'):self.scope.correspondence(self.original,self.module,self.pre,self.post,v)
  o=copy.deepcopy(self.original);o.fixups.pop()
  with self.assertRaises(ValueError):self.scope.correspondence(o,self.module,self.pre,self.post,self.report['verification'])
 def test_complete_instruction_resolved_call_storage_and_typed_damage(self):
  resolved=next(x for x in self.report['scope_role_correspondence']['all_original_roles']if x['representation'].startswith('assembler-resolved'))
  for seg,off in [(3,1140),(3,resolved['native_field'][1]),(3,2366),(4,1426),(6,31),(7,0),(7,47)]:
   m=copy.deepcopy(self.module);m.segments[seg].data[off]^=1
   with self.assertRaises(ValueError):self.gate(m)
  m=copy.deepcopy(self.module);i=next(i for i,f in enumerate(m.fixups)if f.target_method==2);m.fixups[i]=replace(m.fixups[i],target=2 if m.fixups[i].target!=2 else 1)
  with self.assertRaises(ValueError):self.gate(m)
  m=copy.deepcopy(self.module);m.segments[4].size=1428
  with self.assertRaisesRegex(ValueError,'native inventory'):capsule.validate_native(m,self.spec)
 def test_actual_compiled_source_semantic_and_scope_controls(self):
  changes=[('threshold','MIN_FRAGMENT equ 64','MIN_FRAGMENT equ 63',True),('private-export','extrn Error_:near','public Z_GetZonePtr_\nextrn Error_:near',False),('private-rename','_MemInfo','_WrongMemInfo',False)]
  for name,old,new,succeeds in changes:
   d=self.project(name);p=d/'src/mact/zone.asm';s=p.read_text();self.assertIn(old,s);p.write_text(s.replace(old,new));p=d/capsule.PROVENANCE;e=json.loads(p.read_text());e['tracked_sources_sha256']['src/mact/zone.asm']=capsule.digest(d/'src/mact/zone.asm');p.write_text(json.dumps(e,indent=2)+'\n');r=self.cli(d);(d/'CLI.LOG').write_text(r.stdout+r.stderr)
   if succeeds:
    self.assertEqual(r.returncode,0,r.stdout+r.stderr);v=json.loads((d/'source.json').read_text());self.assertNotEqual(v['object_sha256'],self.report['object_sha256'])
    with self.assertRaisesRegex(ValueError,'differing bytes at \\[1257\\]'):self.gate(capsule.Module.parse(Path(v['object']).read_bytes()))
   else:self.assertNotEqual(r.returncode,0);self.assertIn('genuine source private',r.stderr)
 def test_current_game_source_options_and_header_witness(self):
  d=self.project('caller');paths=[capsule.CALLER,'src/game/game.c']
  from tools import build_game_compound as game
  _,_,pins=game.read_contract();paths +=[str(Path(n).relative_to(ROOT))for n in pins]
  for x in ['reference/duke3d-reconstructions','reference/duke3d-reconstructions/MACT','src/include','src/game/include','src/engine/include']:
   for p in (ROOT/x).iterdir():
    if p.is_file()and p.suffix.lower()=='.h':paths.append(str(p.relative_to(ROOT)))
  for n in paths:p=d/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,p)
  with patch.object(capsule,'ROOT',d):a,_=capsule.caller_anchors(d/'baseline')
  self.assertEqual(a,{'Z_AvailHeap_':(1,549564)})
  p=d/capsule.CALLER;old=p.read_bytes();e=json.loads(old);e['options'][0]='/5r';p.write_text(json.dumps(e))
  with patch.object(capsule,'ROOT',d),patch.object(capsule,'CALLER_SHA256',capsule.digest(p)),self.assertRaisesRegex(ValueError,'source/options/compiler/target'):capsule.caller_anchors(d/'bad-options')
  p.write_bytes(old);p=d/'src/game/game.c';old=p.read_bytes();p.write_bytes(old+b'\n/* changed source */\n')
  with patch.object(capsule,'ROOT',d),self.assertRaisesRegex(ValueError,'source/options/compiler/target'):capsule.caller_anchors(d/'bad-source')
  p.write_bytes(old);overlay=d/'src/game/compound/include/duke3d.h';raw=overlay.read_bytes();overlay.write_bytes(raw+b'\n/* changed GAME-only graph */\n')
  with patch.object(capsule,'ROOT',d),self.assertRaisesRegex(ValueError,'header context'):capsule.caller_anchors(d/'bad-compound-header')
  overlay.write_bytes(raw);p=d/'src/game/include/duke3d.h';self.assertTrue(p.is_file());p.write_bytes(p.read_bytes()+b'\n/* changed header witness */\n')
  with patch.object(capsule,'ROOT',d),self.assertRaisesRegex(ValueError,'header'):capsule.caller_anchors(d/'bad-header')
 def test_complete_GNU_home_file_set_race_rejects(self):
  d=self.project('GNU-home-set-race');home=d/'private-gnu-home';shutil.copytree(HOME.resolve(),home);actual=subprocess.run;done=[]
  def race(command,*args,**kw):
   result=actual(command,*args,**kw)
   if not done:done.append(True);(home/'unexpected-extra').write_text('not in pinned GNU tool-home file set')
   return result
  with patch.object(capsule,'ROOT',d),patch.object(capsule.subprocess,'run',side_effect=race):
   with self.assertRaisesRegex(ValueError,'file set changed'):capsule.build_source(home,d/'output',DECODER)
 def test_live_and_staged_input_races_reject(self):
  actual=subprocess.run
  for name,staged in [('live-race',False),('stage-race',True)]:
   d=self.project(name);done=[]
   def race(command,*a,**kw):
    r=actual(command,*a,**kw)
    if not done:
     done.append(True);p=next((d/'output').glob('*/source-only/authored/ZONE.ASM'))if staged else d/'src/mact/zone.asm';p.write_bytes(p.read_bytes()+b'\n; changed after snapshot\n')
    return r
   with patch.object(capsule,'ROOT',d),patch.object(capsule.subprocess,'run',side_effect=race):
    with self.assertRaises((ValueError,AssertionError)):capsule.build_source(HOME,d/'output',DECODER)
