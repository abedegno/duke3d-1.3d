"""Normal GAME C/private-prefix plus six real public tail objects; still partial."""
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
class Availability(unittest.TestCase):
 def test_closed_source_only_compound_producer_exists(self):
  self.assertTrue((ROOT/'tools/build_game_compound.py').is_file(),'normal compound GAME producer is missing')
 def test_GAME_only_header_delays_only_the_real_ending_palette(self):
  shared=(ROOT/'src/game/include/duke3d.h').read_bytes()
  variant=ROOT/'src/game/compound/include/duke3d.h'
  self.assertTrue(variant.is_file(),'tracked GAME-only header context is missing')
  old=b'extern char boardfilename[128],waterpal[768],slimepal[768],titlepal[768],drealms[768],endingpal[768];'
  self.assertEqual(shared.count(old),1)
  self.assertEqual(variant.read_bytes(),shared.replace(old,old.replace(b',endingpal[768]',b'')))
  self.assertIn(b'char waterpal[768], slimepal[768], titlepal[768], drealms[768], endingpal[768];',(ROOT/'src/game/game.c').read_bytes())

from copy import deepcopy
from unittest.mock import patch
import json,os,shutil,subprocess,sys,tempfile
from tools import build_game_compound as producer
from tools import probe_game as observer
HOME=Path(os.environ.get('WATCOM_HOME',str(ROOT/'toolchains/watcom-10.0-ga')))
class GameCompoundNative(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  (ROOT/'build').mkdir(exist_ok=True);cls.work=Path(tempfile.mkdtemp(prefix='game-compound-tests-',dir=ROOT/'build'));cls.report=observer.probe(HOME,cls.work/'normal');cls.built=cls.report['source_build'];cls.native=Path(cls.built['native_build_directory']);cls.c=producer.Module.parse(Path(cls.built['C_object']).read_bytes());cls.tail=producer.Module.parse(Path(cls.built['tail_object']).read_bytes());cls.e,cls.spec,_=producer.read_contract()
  from le import LEImage
  cls.image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());producer.dump(cls.work/'whole-partial-proof.json',cls.report)
 def stage(self,name):
  d=self.work/name;d.mkdir()
  for p in[*producer.SOURCES,*producer.NOTICES,*producer.TOOLS,producer.DESCRIPTOR,producer.PROVENANCE,*self.e['header_sources_sha256']]:q=d/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,q)
  for p in producer.REFERENCES+producer.OVERLAYS:(d/p).mkdir(parents=True,exist_ok=True)
  return d
 def test_complete_existing_proofs_and_honest_partial_storage(self):
  r=self.report;s=r['compound_storage'];self.assertEqual((len(r['functions']),r['matched_function_bytes'],r['matched_function_fixups']),(78,66094,4314));self.assertEqual(r['leading_code_prefix']['compared_bytes'],448);self.assertEqual(r['initialized_data_projection']['initialized_bytes'],864);self.assertFalse(r['full_module_gate']['verified']);self.assertFalse(r['bss_verified']);self.assertEqual(r['new_complete_contributions'],0);self.assertFalse(r['full_executable_rebuilt']);self.assertTrue(r['original_and_target_observed_only_after_source_production']);self.assertEqual(len(self.built['tool_home_sha256']),500);self.assertEqual(len(self.built['headers_sha256']),32)
  self.assertEqual(s['C_prefix_zero_fill_range']['compared_bytes'],4160);self.assertTrue(s['C_prefix_zero_fill_range']['match']);self.assertEqual(s['combined_source_BSS_bytes'],4175);self.assertEqual(s['tail_whole_verification']['zero_fill_bytes'],15);self.assertEqual(len(s['C_prefix_CODE_anchored_roles']),9);self.assertEqual(len(s['unproved_prefix_target_role_names']),2);self.assertFalse(s['all_historical_prefix_name_addresses_verified']);self.assertEqual(s['C_private_scope']['_dmval'],'LPUB only; no target-role anchor');self.assertEqual(r['unverified_code_publics'],['checkcommandline_','spawn_','wallswitchcheck_']);self.assertEqual(r['cheat_buffer_observations']['source_size'],10)
 def test_real_palette_owners_and_independent_consumers(self):
  physical=self.report['compound_storage']['C_physical_definitions']
  expected={'_endingpal':(3,73864),'_titlepal':(3,74632),'_waterpal':(3,75400),'_drealms':(3,76168),'_slimepal':(3,76936)}
  roles=self.report['compound_storage']['palette_consumer_evidence']['public_roles']
  self.assertEqual(roles,expected)
  self.assertEqual({n:physical[n]for n in expected},expected)
  self.assertEqual(len(self.report['compound_storage']['C_prefix_qualified_target_roles']),11)
  self.assertEqual(self.report['compound_storage']['unproved_prefix_target_role_names'],['_dmval','_tempwallptr'])
  for n in expected:self.assertNotIn(n,self.c.local_publics)
  previous=[r for r in self.report['functions']if r['symbol']not in ('Logo_','dobonus_')]
  self.assertEqual((len(previous),sum(r['size']for r in previous),sum(r['comparison']['verified_fixups']for r in previous)),(76,59806,3824))
 def test_only_the_declared_GAME_header_delta_can_reach_native(self):
  for name in ['restore-ending','remove-water','extra-directive','missing-variant']:
   d=self.stage('bad-palette-'+name);q=d/producer.GAME_ONLY_HEADER
   shared=(d/producer.SHARED_GAME_HEADER).read_bytes()
   if name=='restore-ending':q.write_bytes(shared)
   elif name=='remove-water':q.write_bytes(q.read_bytes().replace(b',waterpal[768]',b''))
   elif name=='extra-directive':q.write_bytes(q.read_bytes()+b'\n#define arbitrary_context 1\n')
   else:q.unlink()
   # An honest new input identity cannot waive the finite semantic header delta.
   f=d/producer.PROVENANCE;e=json.loads(f.read_text())
   if q.exists():e['header_sources_sha256'][producer.GAME_ONLY_HEADER]=producer.digest(q);e['prepared_headers_sha256']['duke3d.h']=producer.digest(q)
   f.write_text(json.dumps(e,indent=2)+'\n')
   with self.subTest(context=name),patch.object(producer,'ROOT',d),patch.object(producer,'compile_source')as native,self.assertRaises(ValueError):producer.build_source(HOME,d/'native')
   native.assert_not_called()
 def test_actual_original_header_context_is_retained_negative(self):
  d=self.work/'original-header-native';d.mkdir();shutil.copytree(self.native/'include',d/'include');shutil.copyfile(ROOT/producer.SHARED_GAME_HEADER,d/'include/duke3d.h')
  producer.compile_source(HOME,ROOT/producer.SOURCE,d/'game.obj',producer.OPTIONS,45,include_dirs=[d/'include'])
  producer.check_diagnostics(d/'game.log');m=producer.Module.parse((d/'game.obj').read_bytes())
  self.assertEqual([s.data for s in m.segments],[s.data for s in self.c.segments]);self.assertEqual(m.fixups,self.c.fixups);self.assertEqual(m.externals,self.c.externals);self.assertEqual(m.local_publics,self.c.local_publics)
  self.assertEqual(m.publics['_endingpal'],(5,2600));self.assertEqual(self.c.publics['_endingpal'],(5,296))
  with self.assertRaises(ValueError):producer.validate_native(m,self.tail,self.spec)
  from tools.probe_premap import check_source_interval
  known={n:tuple(v)for r in self.report['functions']for n,v in r['bindings'].items()}
  for n,t,z in [('Logo_',63968,1072),('dobonus_',75744,5216)]:
   with self.subTest(original_palette_context=n),self.assertRaises(ValueError):check_source_interval(m,self.image,n,t,z,known)
 def test_independent_palette_consumer_conflict_rejected(self):
  d=self.work/'wrong-independent-palette';d.mkdir()
  for n in ['evidence/premap-module.json','evidence/player-module.json','src/game/premap.c','src/game/player.c','modules/premap.json','modules/player.json']:
   q=d/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
  q=d/'evidence/premap-module.json';e=json.loads(q.read_text());e['verification']['publics']['_endingpal'][1]+=768;q.write_text(json.dumps(e)+'\n')
  with patch.object(observer,'ROOT',d),self.assertRaises(ValueError):observer.check_compound_storage(self.c,self.tail,self.image,self.report['functions'])
 def test_minimal_standalone_python_O_no_target_SDK_objects_or_callers(self):
  d=self.stage('standalone');self.assertFalse((d/'reference/DUKE3D.EXE').exists());self.assertFalse(list((d/'reference').rglob('*.LIB')));script=d/'source-boundary.py';script.write_text("""from pathlib import Path
import runpy,sys,json
R=Path(__file__).parent.resolve();denied=[]
def guard(event,args):
 if event=='open'and isinstance(args[0],(str,bytes)):
  n=str(args[0]).lower();name=Path(n).name
  if name=='duke3d.exe'or('/reference/'in n and name.endswith(('.lib','.obj')))or name.endswith('-module.json')or name=='game-progress.json'or'/task531-'in n:
   denied.append(str(args[0]));raise RuntimeError('source-only forbidden SDK/target/caller/research read')
sys.addaudithook(guard)
for n in ['reference/DUKE3D.EXE','reference/MACT386.LIB']:
 try:(R/n).read_bytes()
 except RuntimeError:pass
 else:raise RuntimeError('source-only guard probe was not rejected')
sys.argv=[str(R/'tools/build_game_compound.py'),*sys.argv[1:]]
runpy.run_path(str(R/'tools/build_game_compound.py'),run_name='__main__')
(R/'denied-probes.json').write_text(json.dumps(denied,indent=2)+'\\n')
""");cmd=[sys.executable,'-O',str(script),'--home',str(HOME),'--build',str(d/'native'),'--report',str(d/'output.json')];p=subprocess.run(cmd,capture_output=True,text=True);(d/'execution.log').write_text(p.stdout+p.stderr);self.assertEqual(p.returncode,0,p.stderr);r=json.loads((d/'output.json').read_text());self.assertTrue(r['source_only']);self.assertFalse(r['original_binary_SDK_object_or_caller_read']);self.assertEqual(r['C_stable_native_inventory_sha256'],self.built['C_stable_native_inventory_sha256']);self.assertEqual(r['tail_object_sha256'],self.built['tail_object_sha256']);self.assertNotEqual(r['native_build_directory'],self.built['native_build_directory'])
  self.assertEqual(len(json.loads((d/'denied-probes.json').read_text())),2)
  fresh=producer.Module.parse(Path(r['C_object']).read_bytes());self.assertEqual([s.data for s in fresh.segments],[s.data for s in self.c.segments]);self.assertEqual(fresh.fixups,self.c.fixups);self.assertEqual(fresh.externals,self.c.externals);self.assertEqual(fresh.publics,self.c.publics);self.assertEqual(fresh.local_publics,self.c.local_publics)
  p=d/producer.TAIL;p.write_bytes(p.read_bytes()+b'\n; actual source change\n');z=subprocess.run(cmd,capture_output=True,text=True);self.assertNotEqual(z.returncode,0);self.assertIn('ValueError',z.stderr)
 def test_actual_swap_same_fifteen_bytes_six_publics_rejects_CODE_bindings(self):
  d=self.work/'swapped';d.mkdir();src=(ROOT/producer.TAIL).read_text();old='_everyothertime db ?\n_cheatbuflen db ?';self.assertEqual(src.count(old),1);(d/'GMTAIL.ASM').write_text(src.replace(old,'_cheatbuflen db ?\n_everyothertime db ?'));producer.run_batch(HOME,d,'@echo off\r\nset PATH=D:\\BINB;D:\\BIN\r\nwasm /zq GMTAIL.ASM > ASSEMBLE.LOG\r\n',45);self.assertFalse((d/'ASSEMBLE.LOG').read_bytes());m=producer.Module.parse((d/'GMTAIL.OBJ').read_bytes());self.assertEqual(sum(s.size for s in m.segments),15);self.assertEqual(set(m.publics),set(self.tail.publics))
  with self.assertRaises(ValueError):observer.check_compound_storage(self.c,m,self.image,self.report['functions'])
 def test_actual_private_C_owner_promotion_rejects_native_scope(self):
  d=self.work/'private-export';d.mkdir();src=(ROOT/producer.SOURCE).read_bytes();old=b'static long frameval[AVERAGEFRAMES], framecnt = 0;';self.assertEqual(src.count(old),1);p=d/'scope.c';p.write_bytes(src.replace(old,b'long frameval[AVERAGEFRAMES], framecnt = 0;'));producer.compile_source(HOME,p,d/'game.obj',producer.OPTIONS,45,include_dirs=[self.native/'include']);producer.check_diagnostics(d/'game.log');m=producer.Module.parse((d/'game.obj').read_bytes());self.assertNotIn('_frameval',m.local_publics)
  with self.assertRaises(ValueError):producer.validate_native(m,self.tail,self.spec)
  with self.assertRaises(ValueError):observer.check_compound_storage(m,self.tail,self.image,self.report['functions'])
 def test_native_scope_payload_extent_and_E9_path_guards(self):
  for name in ['private','tail-private','tail-export','extra-byte','C-byte','CONST-byte','field','E9path']:
   a=deepcopy(self.c);b=deepcopy(self.tail)
   if name=='private':a.local_publics.remove('_dmval')
   elif name=='tail-private':b.local_publics.add('_everyothertime')
   elif name=='tail-export':b.publics['invented_']=(3,0)
   elif name=='extra-byte':b.segments[2].size+=1;b.segments[2].data.append(0)
   elif name=='C-byte':a.segments[0].data[500]^=1
   elif name=='CONST-byte':a.segments[1].data[100]^=1
   elif name=='field':a.fixup_encodings[0]['raw_fixdat']^=1
   else:
    i=next(i for i,(k,p)in enumerate(a.comments)if k==233 and p);k,p=a.comments[i];a.comments[i]=(k,p[:-1]+b'X')
   with self.subTest(name=name),self.assertRaises(ValueError):producer.validate_native(a,b,self.spec)
 def test_closed_sources_notices_headers_and_recipe_before_native(self):
  for name,p in [('source',producer.SOURCE),('tail',producer.TAIL),('notice',producer.NOTICES[1]),('tool',producer.TOOLS[0]),('descriptor',producer.DESCRIPTOR),('header',next(iter(self.e['header_sources_sha256'])))]:
   d=self.stage('bad-'+name);q=d/p;q.write_bytes(q.read_bytes()+b'\nchanged')
   with self.subTest(name=name),patch.object(producer,'ROOT',d),patch.object(producer,'compile_source')as native,self.assertRaises(ValueError):producer.build_source(HOME,d/'native')
   native.assert_not_called()
  d=self.stage('extra-header');folder=d/producer.OVERLAYS[0];(folder/'extra.h').write_text('/* actual extra source input */')
  with patch.object(producer,'ROOT',d),patch.object(producer,'compile_source')as native,self.assertRaises(ValueError):producer.build_source(HOME,d/'native')
  native.assert_not_called()
 def test_private_copied_tool_home_extra_file_race(self):
  home=self.work/'private-GA';shutil.copytree(HOME,home,symlinks=True);real=producer.run_batch
  def race(*args,**kw):real(*args,**kw);(home/'EXTRA.FILE').write_text('actual new native tool-home file')
  with patch.object(producer,'run_batch',side_effect=race),self.assertRaisesRegex(ValueError,'complete GAME GA tool home'):producer.build_source(home,self.work/'tool-race')
 def test_actual_staged_and_live_input_races(self):
  real=producer.compile_source
  for kind in ['staged','live']:
   d=self.stage('race-'+kind)
   def raced(home,source,*args,**kw):
    real(home,source,*args,**kw);q=Path(source)if kind=='staged'else d/producer.SOURCE;q.write_bytes(q.read_bytes()+b'\n/* race */\n')
   with self.subTest(kind=kind),patch.object(producer,'ROOT',d),patch.object(producer,'compile_source',side_effect=raced),self.assertRaisesRegex(ValueError,'changed during production'):producer.build_source(HOME,d/'native')
 def test_all_raw_metadata_preserved_except_typed_timestamp_values(self):
  a=deepcopy(self.c);i=next(i for i,(k,p)in enumerate(a.comments)if k==233 and p);k,p=a.comments[i];a.comments[i]=(k,bytes(x^255 for x in p[:4])+p[4:]);self.assertNotEqual(producer.inventory(a),producer.inventory(self.c));self.assertEqual(producer.inventory_sha(a),producer.inventory_sha(self.c));self.assertEqual([p[5:].decode()if p else None for k,p in self.c.comments if k==233],self.spec['C_E9_ordered_paths'])
if __name__=='__main__':unittest.main()
