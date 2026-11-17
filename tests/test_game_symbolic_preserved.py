"""Prepared preservation is isolated; no approval or default-adoption claim."""
from pathlib import Path
import ast,copy,hashlib,importlib,json,tempfile,unittest
ROOT=Path(__file__).resolve().parents[1]
class PreservedGAME(unittest.TestCase):
 def api(self):return importlib.import_module('tools.build_game_symbolic_preserved')
 def test_exact_seven_data_only_source_changes(self):
  p=self.api();old=(ROOT/'src/game/symbolic/GAME.S').read_text();new=(ROOT/'src/game/symbolic_preserved/GAME.S').read_text();a=old.splitlines();b=new.splitlines();self.assertEqual(len(a),len(b));changed=[i for i,(x,y)in enumerate(zip(a,b))if x!=y];self.assertEqual(len(changed),4);self.assertTrue(all(a[i].strip().startswith('.ascii ')and b[i].strip().startswith('.ascii ')for i in changed));self.assertEqual(p.PRESERVED_CONST,{47:16,93:86,94:7,98:3,99:216,134:160,135:86})
  for i,capacity,nul in zip(changed,[48,48,4,36],[46,44,1,33]):
   before=ast.literal_eval(a[i].strip()[7:]).encode('latin1');after=ast.literal_eval(b[i].strip()[7:]).encode('latin1');self.assertEqual(len(before),capacity);self.assertEqual(len(after),capacity);self.assertEqual(before.index(0),nul);self.assertEqual(after.index(0),nul);self.assertEqual(before[:nul+1],after[:nul+1])
 def test_closed_guard_rejects_default_zero_or_changed_logical_literal(self):
  p=self.api();model=p.contract.model();text=(ROOT/'src/game/symbolic_preserved/GAME.S').read_text();p.contract.source_preflight(text,model)
  for bad in [(ROOT/'src/game/symbolic/GAME.S').read_text(),text.replace('You cannot play Duke','You cannot play Duko',1)]:
   with self.assertRaises(ValueError):p.contract.source_preflight(bad,model)
 def test_pending_scope_and_unchanged_default_builder(self):
  p=self.api();e,d,pins=p.read_contract();self.assertFalse(d['whole_target_match']);self.assertEqual(d['adoption_status'],'prepared; permission unanswered');self.assertEqual(d['source_credit'],0);self.assertNotEqual(p.REFERENCE,'evidence/game-symbolic-source-reference.json');self.assertIn('strict seven CONST negative',(ROOT/'tools/observe_game_symbolic.py').read_text());self.assertFalse(any('task608' in str(n)for n in pins))

class PreservedNative(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools import build_game_symbolic_preserved as p
  from profiles.gnu_elf_omf.elf32 import elf
  from omf32 import Module
  cls.p=p;cls.temp=tempfile.TemporaryDirectory(prefix='prepared-game-tests-',dir=ROOT/'build');cls.r=p.build_source(ROOT/'toolchains/gnu-elf-omf-game',Path(cls.temp.name),decoder_home=ROOT/'toolchains/capstone',watcom_home=ROOT/'toolchains/watcom-10.0-ga');cls.w=Path(cls.r['native_build_directory']);cls.m=Module.parse(Path(cls.r['object']).read_bytes());cls.e=elf(cls.w/'GAME.ELF');cls.pre=json.loads((cls.w/'source-ELF-proof.json').read_text())
 @classmethod
 def tearDownClass(cls):cls.temp.cleanup()
 def test_complete_native_bytes_geometry_fields_and_scope_unchanged(self):
  old=json.loads((ROOT/'src/game/symbolic/contract-model.json').read_text());self.assertEqual(self.p.contract.inventory(self.m),old['native_inventory']);self.assertEqual(len(self.m.fixups),5018);self.assertEqual(len(self.m.publics),109);self.assertFalse(self.r['adoption_approved']);self.assertFalse(self.r['full_target_match']);self.assertEqual(self.r['tail_object_sha256'],'9f565d79c0c6f192d75a8ae0f53e0563699a28c8804490e99ca821d530923684')
  for s in self.m.segments:
   if s.name!='CONST':self.assertEqual(hashlib.sha256(bytes(s.data)).hexdigest(),old['native_data_sha256'][s.name])
  self.assertEqual(hashlib.sha256(bytes(self.m.segments[1].data)).hexdigest(),'75f6e2c089e9908722a6446d597dfde4f06e23e9fc8a7463b9bc1f13d2cc2d09')
 def test_each_residue_byte_and_native_scope_controls_reject(self):
  for offset in self.p.PRESERVED_CONST:
   m=copy.deepcopy(self.m);m.segments[1].data[offset]^=1
   with self.subTest(offset=offset),self.assertRaises(ValueError):self.p.contract.postflight(self.e,m,self.pre)
  m=copy.deepcopy(self.m);s,at=m.publics['spawn_'];m.publics['spawn_']=(s,at+1)
  with self.assertRaises(ValueError):self.p.contract.postflight(self.e,m,self.pre)
 def test_default_guard_keeps_its_strict_zero_model(self):
  from tools import build_game_symbolic as old
  with self.assertRaises(ValueError):old.contract.postflight(self.e,self.m,self.pre)
 def test_copy_mutation_rejects_before_native(self):
  from unittest import mock
  p=self.p;original=p.shutil.copyfile
  def changed(source,dest,*a,**k):
   result=original(source,dest,*a,**k)
   if str(dest).endswith('/GAME.S'):Path(dest).write_bytes(Path(dest).read_bytes()+b'\n# staged mutation\n')
   return result
  with mock.patch.object(p.shutil,'copyfile',side_effect=changed),mock.patch.object(p.subprocess,'run')as run,self.assertRaises(ValueError):p.build_source(ROOT/'toolchains/gnu-elf-omf-game',Path(self.temp.name),decoder_home=ROOT/'toolchains/capstone',watcom_home=ROOT/'toolchains/watcom-10.0-ga')
  run.assert_not_called()

if __name__=='__main__':unittest.main()
