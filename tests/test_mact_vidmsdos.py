"""Full VID native proof, real helper/source controls and preserved C-only negative."""
import copy,json,shutil,tempfile,unittest
from pathlib import Path
from dataclasses import replace
from unittest.mock import patch
try:
 from tools import probe_mact_vidmsdos as capsule
except ImportError:
 capsule=None
from tools import prove_module as driver
ROOT=Path(__file__).resolve().parents[1];HOME=ROOT/'toolchains/watcom-10.0-ga'
class VIDTests(unittest.TestCase):
 def test_normal_source_producer_available(self):
  self.assertIsNotNone(capsule,'normal complete VID producer is missing')
 @classmethod
 def setUpClass(cls):
  if capsule is None:return
  (ROOT/'build').mkdir(exist_ok=True)
  cls.work=Path(tempfile.mkdtemp(prefix='vid-tests-',dir=ROOT/'build'))
  cls.context=capsule._replay_origin(HOME,cls.work/'context')
  cls.report=driver.prove('mact_vidmsdos',HOME,cls.work/'normal-parent')
  cls.native=Path(cls.report['native_build_directory'])
  cls.module=capsule.Module.parse((cls.native/'VIDMSDOS.OBJ').read_bytes())
  cls.image=capsule.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
  cls.spec=json.loads((ROOT/capsule.DESCRIPTOR).read_text())
  (cls.work/'whole-proof.json').write_text(json.dumps(cls.report,indent=2)+'\n')
 def check(self,m):return capsule.verify_native(m,self.image,self.spec,self.context)
 def test_whole_native_source_and_complete_roles(self):
  p=self.report['verification']
  self.assertEqual((p['initialized_bytes'],p['zero_fill_bytes'],p['verified_fixups']),(1297,64048,54))
  self.assertEqual([s.size for s in self.module.segments],[1153,0,0,144,64048])
  self.assertEqual(len(self.module.publics),29);self.assertEqual(len(self.module.local_publics),8)
  self.assertEqual(len(self.module.externals),16);self.assertEqual(len(self.module.local_externals),8)
  self.assertEqual(self.module.local_publics,set(self.spec['native_inventory']['local_publics']))
  self.assertEqual((self.native/'VIDMSDOS.C').read_bytes(),(ROOT/capsule.SOURCE).read_bytes())
  self.assertTrue(self.report['humanization_backlog']);self.assertFalse(self.report['full_executable_rebuilt'])
  self.assertEqual(self.module.publics['_ExtendedKeyFlag'],(5,64008))
  self.assertNotIn('ClearExtendedKeyPrefix_',self.module.publics)
  self.assertNotIn('ClearExtendedKeyPrefix_',self.module.externals)
 def test_reference_only_complete_raw_runtime_equality(self):
  # SDK bytes enter this test only after independent source production.
  library=(ROOT/'reference/duke3d-reconstructions/MACT386.LIB').read_bytes()
  import hashlib
  self.assertEqual(hashlib.sha256(library).hexdigest(),'957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db')
  raw=library[33792:37718]
  self.assertEqual(hashlib.sha256(raw).hexdigest(),'970a2ccd6c58f051780089b549aa6ec34dc6adbc7f7dd3e242181969e68f472e')
  original=capsule.Module.parse(raw)
  self.assertEqual([bytes(s.data) for s in self.module.segments],[bytes(s.data) for s in original.segments])
  for field in ['publics','local_publics','externals','local_externals','groups','fixups','code_data_ranges','default_libraries']:
   self.assertEqual(getattr(self.module,field),getattr(original,field),field)
  self.assertEqual([(s.name,s.class_name,s.size,s.attributes,s.access) for s in self.module.segments],[(s.name,s.class_name,s.size,s.attributes,s.access) for s in original.segments])
 def test_source_only_fresh_children_and_no_original_object_dependency(self):
  # The producer has no target/SDK/context parameters or observer calls.
  d=self.work/'standalone';d.mkdir();s=d/'SOURCE.C';shutil.copyfile(ROOT/capsule.SOURCE,s)
  shutil.copytree(ROOT/capsule.HEADERS,d/'headers')
  with patch.object(capsule,'verify_native',side_effect=AssertionError('observer entered compiler')):
   native=capsule.compile_only(HOME,s,d/'headers',d/'outputs')
   second=capsule.compile_only(HOME,s,d/'headers',d/'outputs')
  self.assertNotEqual(native,second)
  for path in [native,second]:
   self.assertFalse(list(path.glob('*.LIB')));self.assertFalse(list(path.glob('*.EXE')))
   m=capsule.Module.parse((path/'VIDMSDOS.OBJ').read_bytes())
   self.assertEqual(self.check(m)['verification'],self.report['verification'])
 def test_c_only185_wrong_irq_is_retained_negative(self):
  native=capsule.compile_only(HOME,ROOT/capsule.COUNTERPART,ROOT/capsule.HEADERS,self.work/'c-only')
  m=capsule.Module.parse((native/'VIDMSDOS.OBJ').read_bytes())
  self.assertEqual(m.publics,self.module.publics);self.assertEqual(m.local_publics,self.module.local_publics)
  self.assertEqual(bytes(m.segments[3].data),bytes(self.module.segments[3].data))
  self.assertEqual(m.segments[4].size,64048)
  with self.assertRaises(ValueError):self.check(m)
  with self.assertRaisesRegex(ValueError,'fixup target mismatch'):
   capsule.verify_module(m,self.image,self.report['placements'],self.report['symbol_anchors'],logical_origins=(self.context,))
 def test_actual_source_helper_and_semantic_controls(self):
  source=(ROOT/capsule.SOURCE).read_bytes()
  cases=[('nonzero-prefix',b'"xor esi,esi"',b'"mov esi,1"'),
         ('wrong-destination',b'"mov dword ptr [ExtendedKeyFlag],esi"',b'"mov dword ptr [PauseCount],esi"'),
         ('palette-width',b'palette[i] >> 2',b'palette[i] >> 1')]
  # First two tests independently exercise the real helper's value and destination.
  for name,old,new in cases:
   self.assertIn(old,source);d=self.work/name;d.mkdir();s=d/'SOURCE.C';s.write_bytes(source.replace(old,new,1))
   native=capsule.compile_only(HOME,s,ROOT/capsule.HEADERS,d/'native')
   m=capsule.Module.parse((native/'VIDMSDOS.OBJ').read_bytes())
   with self.subTest(name=name),self.assertRaises(ValueError):self.check(m)
   with self.subTest(generic=name),self.assertRaises(ValueError):
    capsule.verify_module(m,self.image,self.report['placements'],self.report['symbol_anchors'],logical_origins=(self.context,))
 def test_tail_data_scope_and_typed_relocation_controls(self):
  for name in ['code-tail','data-tail','scope','external-scope','group','storage','fixup-target','fixup-width','fixup-frame','encoding','metadata']:
   m=copy.deepcopy(self.module)
   if name=='code-tail':m.segments[0].data[-1]^=1
   elif name=='data-tail':m.segments[3].data[-1]^=1
   elif name=='scope':m.local_publics.remove('_ExtendedKeyFlag')
   elif name=='external-scope':m.local_externals.remove(9)
   elif name=='group':m.groups[0]=('DGROUP',(2,3,4))
   elif name=='storage':m.segments[4].size-=1;m.segments[4].data.pop()
   elif name=='fixup-target':m.fixups[0]=replace(m.fixups[0],target=11)
   elif name=='fixup-width':m.fixups[-1]=replace(m.fixups[-1],width=2)
   elif name=='fixup-frame':m.fixups[-1]=replace(m.fixups[-1],frame=1)
   elif name=='encoding':m.fixup_encodings[-1]['raw_fixdat']^=1
   else:m.unrecognized=True
   with self.subTest(name=name),self.assertRaises(ValueError):self.check(m)
 def test_context_and_caller_binding_guards_remain_strict(self):
  with self.assertRaises(ValueError):capsule.verify_native(self.module,self.image,self.spec,None)
  with self.assertRaises(TypeError):copy.copy(self.context)
  with self.assertRaises(ValueError):capsule.verify_native(self.module,self.image,self.spec,object())
  places=copy.deepcopy(self.report['placements']);symbols=copy.deepcopy(self.report['symbol_anchors'])
  symbols['_ExtendedKeyFlag']=(3,1863764)
  with self.assertRaises(ValueError):capsule.verify_module(self.module,self.image,places,symbols,logical_origins=(self.context,))
  spec=copy.deepcopy(self.spec);spec['symbol_anchors']['KB_KeyEvent_'][1]+=1
  with self.assertRaises(ValueError):capsule.verify_native(self.module,self.image,spec,self.context)
 def stage(self,name):
  d=self.work/name;d.mkdir()
  paths=[capsule.SOURCE,capsule.COUNTERPART,capsule.DESCRIPTOR,capsule.PROVENANCE,capsule.LINEAGE,*capsule.TOOLS]
  for name in paths:
   p=d/name;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/name,p)
  shutil.copytree(ROOT/capsule.HEADERS,d/capsule.HEADERS)
  p=d/'reference/DUKE3D.EXE';p.parent.mkdir();p.symlink_to(ROOT/'reference/DUKE3D.EXE')
  return d
 def test_source_header_tool_descriptor_lineage_identity_reject_before_compile(self):
  for name,target in [('source',capsule.SOURCE),('counterpart',capsule.COUNTERPART),('header',capsule.HEADERS+'/TYPES.H'),('tool','tools/match_function.py'),('descriptor',capsule.DESCRIPTOR),('lineage',capsule.LINEAGE)]:
   d=self.stage('identity-'+name);p=d/target;p.write_bytes(p.read_bytes()+b'\nchanged\n')
   with patch.object(capsule,'ROOT',d),patch.object(capsule,'compile_only') as compile:
    with self.subTest(name=name),self.assertRaises((ValueError,json.JSONDecodeError)):capsule.probe(HOME,d/'build')
    compile.assert_not_called()
  fake=self.work/'wrong-tool';(fake/'BINB').mkdir(parents=True);(fake/'BINB/wcc386.exe').write_bytes(b'wrong')
  (fake/'H').symlink_to(HOME/'H',target_is_directory=True)
  (fake/'BIN').mkdir();(fake/'BIN/w32run.exe').symlink_to(HOME/'BIN/w32run.exe')
  with patch.object(capsule,'compile_only') as compile:
   with self.assertRaises(ValueError):capsule.probe(fake,self.work/'bad-tool')
   compile.assert_not_called()
 def test_source_freshness_after_native_compile(self):
  d=self.stage('race-source');real=capsule.compile_only
  def changed(*args,**kwargs):
   result=real(*args,**kwargs);p=d/capsule.SOURCE;p.write_bytes(p.read_bytes()+b'\n/* changed */\n');return result
  with patch.object(capsule,'ROOT',d),patch.object(capsule,'compile_only',side_effect=changed):
   with self.assertRaisesRegex(ValueError,'changed during production'):capsule.probe(HOME,d/'outputs')
if __name__=='__main__':unittest.main()
