"""Uncredited full CONTROL source candidate, preserving every known negative."""
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
class CandidateAvailability(unittest.TestCase):
 def test_separate_uncredited_route_exists(self):
  self.assertTrue((ROOT/'candidates/mact_control.json').is_file(),'CONTROL candidate route is missing')

from copy import deepcopy
from dataclasses import replace
import hashlib,json,shutil,tempfile,os
from unittest.mock import patch
from tools import build_control_candidate as candidate
from omf32 import Module
from le import LEImage
from runner import compile_source
from tools.match_function import compare_range
HOME=Path(os.environ.get('WATCOM_HOME',str(ROOT/'toolchains/watcom-10.0-ga')))
REFERENCE=Path(os.environ.get('CONTROL_REFERENCE_ROOT',str(ROOT/'reference')))
class NativeCONTROL(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  (ROOT/'build').mkdir(exist_ok=True);cls.work=Path(tempfile.mkdtemp(prefix='control344-',dir=ROOT/'build'))
  cls.spec=candidate.read_spec();cls.result=candidate.compile_candidate(cls.work/'normal',home=HOME)
  cls.module=Module.parse(Path(cls.result['object']).read_bytes());cls.image=LEImage.parse((REFERENCE/'DUKE3D.EXE').read_bytes())
  cls.observation=candidate.observe_candidate(cls.result['object'],REFERENCE,build=cls.work/'observer')
  cls.places={int(k):tuple(v)for k,v in cls.observation['original_bindings']['placements'].items()};cls.symbols={n:tuple(v)for n,v in cls.observation['source_owned_symbols'].items()}
 def test_complete_actual_source_runtime_and_no_coverage_registration(self):
  self.assertEqual(self.result['runtime'],{'initialized_bytes':7312,'zero_fill_bytes':1612,'fixups':467})
  self.assertEqual([s.size for s in self.module.segments],[6189,1055,0,68,1612]);self.assertEqual(len(self.module.publics),90);self.assertEqual(len(self.module.local_publics),30)
  self.assertEqual(len(self.result['global_definitions']),60);self.assertEqual(len([x for x in self.module.publics.values()if x[0]==1]),49)
  self.assertEqual(len([x for x in self.module.publics.values()if x[0]==5]),25)
  self.assertEqual(bytes(self.module.segments[3].data[17:20]),bytes.fromhex('6e6467'))
  self.assertFalse(self.result['complete_module']);self.assertFalse(self.result['fixed_target_layout_verified']);self.assertEqual(self.result['source_credit'],0)
  self.assertFalse((ROOT/'modules/mact_control.json').exists());self.assertNotIn("module_name=='mact_control'",(ROOT/'tools/prove_module.py').read_text())
 def test_original_whole_and_real_source_negatives_preserved(self):
  o=self.observation;p=o['original_whole_verification'];self.assertEqual((p['initialized_bytes'],p['zero_fill_bytes'],p['verified_fixups']),(7452,1612,470))
  self.assertEqual(o['source_whole_error'],self.spec['strict_whole_error']);self.assertEqual(o['source_owned_whole_error'],self.spec['strict_source_owned_error'])
  self.assertEqual(o['actual_DATA_differing_offsets'],[17,18,19]);self.assertEqual(o['raw_CODE_equal_count'],37);self.assertEqual(len(o['raw_CODE_different_functions']),12);self.assertEqual(len(o['all_49_function_diagnostics']),49)
  self.assertTrue(o['all25_BSS_roles_equal']);self.assertTrue(o['complete_nonCODE']['2']['match']);self.assertTrue(o['complete_nonCODE']['5']['match']);self.assertFalse(o['complete_nonCODE']['4']['match'])
 def stage(self,name):
  root=self.work/name;root.mkdir()
  notice=json.loads((ROOT/candidate.PROVENANCE).read_text())['notice_and_lineage_sha256']
  for rel in [candidate.SPEC,candidate.SOURCE,candidate.PROVENANCE,*candidate.TOOLS,*notice]:
   p=root/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/rel,p)
  shutil.copytree(ROOT/candidate.HEADERS,root/candidate.HEADERS);return root
 def test_reference_free_source_project_and_distinct_native_children(self):
  d=self.stage('standalone');self.assertFalse((d/'reference').exists())
  with patch.object(candidate,'ROOT',d):
   a=candidate.compile_candidate(d/'output',home=HOME);b=candidate.compile_candidate(d/'output',home=HOME)
  self.assertNotEqual(a['native_build_directory'],b['native_build_directory']);self.assertEqual(a['runtime_sha256'],b['runtime_sha256']);self.assertEqual(a['runtime_sha256'],self.spec['source_runtime_sha256'])
  for r in[a,b]:
   self.assertFalse(r['original_or_target_read_during_production']);f=json.loads(Path(r['producer_input_freeze']).read_text())
   self.assertFalse(any('reference/'in p or p.endswith('.LIB')or p.endswith('DUKE3D.EXE')for p in f['live']))
   self.assertEqual(len(list((Path(r['native_build_directory'])/'source-only/include').iterdir())),7)
 def test_real_getter_behavior_and_early_named_call_role_controls(self):
  raw=(ROOT/candidate.SOURCE).read_bytes();old=b'return (CONTROL_MouseSensitivity - MINIMUMMOUSESENSITIVITY);';self.assertEqual(raw.count(old),1)
  d=self.work/'wrong-sensitivity';d.mkdir();s=d/'control.c';s.write_bytes(raw.replace(old,b'return (CONTROL_MouseSensitivity + MINIMUMMOUSESENSITIVITY);',1));obj=d/'mutant.obj'
  includes=Path(self.result['native_build_directory'])/'source-only/include';compile_source(HOME,s,obj,candidate.OPTIONS,45,include_dirs=[includes]);self.assertIn('0 warnings, 0 errors',obj.with_suffix('.log').read_text());m=Module.parse(obj.read_bytes())
  with self.assertRaisesRegex(ValueError,'runtime mismatch'):candidate.assert_runtime(m,self.spec)
  p=compare_range(m,1,112,self.image,1,self.spec['code_offset']+112,12,self.symbols,self.places);self.assertFalse(p['match'])
  m=deepcopy(self.module);f=m.fixups[0];self.assertEqual(m.externals[f.target-1],'MOUSE_GetDelta_');m.fixups[0]=replace(f,target=m.externals.index('MOUSE_GetButtons_')+1)
  with self.assertRaisesRegex(ValueError,'runtime mismatch'):candidate.assert_runtime(m,self.spec)
  p=compare_range(m,1,0,self.image,1,self.spec['code_offset'],112,self.symbols,self.places);self.assertFalse(p['match'])
 def test_full_storage_const_tail_scope_typed_and_gap_controls(self):
  for name in['CONST-first','CONST-last','CODE-tail','local-public','local-external','BSS-role','BSS-size','DATA-tail','DATA-gap','typed-frame','typed-width','raw-encoding','extra-import','unknown-metadata']:
   m=deepcopy(self.module)
   if name=='CONST-first':m.segments[1].data[0]^=1
   elif name=='CONST-last':m.segments[1].data[-1]^=1
   elif name=='CODE-tail':m.segments[0].data[-1]^=1
   elif name=='local-public':m.local_publics.remove(next(iter(m.local_publics)))
   elif name=='local-external':m.local_externals.remove(next(iter(m.local_externals)))
   elif name=='BSS-role':n=next(n for n,v in m.publics.items()if v[0]==5);s,o=m.publics[n];m.publics[n]=(s,o+4)
   elif name=='BSS-size':m.segments[4].size-=4;del m.segments[4].data[-4:]
   elif name=='DATA-tail':m.segments[3].data[-1]^=1
   elif name=='DATA-gap':m.segments[3].data[17:20]=b'\0\0\0'
   elif name=='typed-frame':m.fixups[0]=replace(m.fixups[0],frame_method=5,frame=None)
   elif name=='typed-width':m.fixups[-1]=replace(m.fixups[-1],width=2)
   elif name=='raw-encoding':m.fixup_encodings[-1]['raw_fixdat']^=1
   elif name=='extra-import':m.externals.append('dummy_')
   else:m.unmeasured=True
   with self.subTest(name=name),self.assertRaisesRegex(ValueError,'runtime mismatch'):candidate.assert_runtime(m,self.spec)
   if name.startswith('CONST'):
    p=compare_range(m,2,0,self.image,*self.places[2],1055,self.symbols,self.places);self.assertFalse(p['match'])
 def test_source_header_tools_recipe_identity_and_real_native_race(self):
  for label,rel in [('source',candidate.SOURCE),('header',candidate.HEADERS+'/_control.h'),('tool','tools/build_gf1_init_candidate.py'),('lineage',candidate.LINEAGE)]:
   d=self.stage('wrong-'+label);p=d/rel;p.write_bytes(p.read_bytes()+b'\nchanged\n')
   with patch.object(candidate,'ROOT',d),patch.object(candidate,'compile_source')as native:
    with self.subTest(label=label),self.assertRaises(ValueError):candidate.compile_candidate(d/'output',home=HOME)
    native.assert_not_called()
  d=self.stage('wrong-provenance');p=d/candidate.PROVENANCE;j=json.loads(p.read_text());j['source_credit']=1;p.write_text(json.dumps(j))
  with patch.object(candidate,'ROOT',d),patch.object(candidate,'compile_source',side_effect=RuntimeError('compiler reached wrong metadata'))as native:
   with self.assertRaises(ValueError):candidate.compile_candidate(d/'output',home=HOME)
   native.assert_not_called()
  d=self.stage('wrong-recipe');p=d/candidate.SPEC;j=json.loads(p.read_text());j['complete_module']=True;p.write_text(json.dumps(j))
  with patch.object(candidate,'ROOT',d),patch.object(candidate,'compile_source')as native:
   with self.assertRaises(ValueError):candidate.compile_candidate(d/'output',home=HOME)
   native.assert_not_called()
  d=self.stage('native-race');real=candidate.compile_source
  def race(*args,**kwargs):
   result=real(*args,**kwargs);p=d/candidate.SOURCE;p.write_bytes(p.read_bytes()+b'\n/* changed */\n');return result
  with patch.object(candidate,'ROOT',d),patch.object(candidate,'compile_source',side_effect=race):
   with self.assertRaisesRegex(ValueError,'changed during compilation'):candidate.compile_candidate(d/'output',home=HOME)

if __name__=='__main__':unittest.main()
