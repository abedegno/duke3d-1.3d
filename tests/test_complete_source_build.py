from pathlib import Path
import copy,importlib,json,unittest
ROOT=Path(__file__).resolve().parents[1]
class RecipeTests(unittest.TestCase):
 def module(self):
  self.assertTrue((ROOT/'tools/build_complete.py').is_file(),'portable complete source recipe implementation is missing')
  return importlib.import_module('tools.build_complete')
 def test_all_owned_objects_and_actual_game_tail_attachment(self):
  b=self.module();r=b.read_recipe();self.assertEqual({q['alias']for q in r['owned']},{f'O{i:03}.OBJ'for i in range(1,123)});self.assertEqual(len(r['owned']),122);self.assertEqual(r['link']['files'][:6],['O071.OBJ','O113.OBJ','O001.OBJ','O002.OBJ','O014.OBJ','UNIDENT.OBJ']);self.assertEqual(next(q for q in r['owned']if q['alias']=='O071.OBJ')['kind'],'game-main');self.assertEqual(next(q for q in r['owned']if q['alias']=='O113.OBJ')['kind'],'game-tail')
 def test_exact_complete_link_graph_and_libraries(self):
  b=self.module();r=b.read_recipe();files=r['link']['files'];self.assertEqual(len(files),300);self.assertEqual(len(set(files)),300);self.assertEqual(r['link']['libraries'],['C105.LIB','M105.LIB','CGA.LIB','MGA.LIB','EGA.LIB']);text=b.link_text(r);self.assertIn('reference _cstart_\n',text);self.assertIn('option stack=50k\n',text);self.assertIn('segment type data loadoncall\n',text);self.assertEqual(files.index('O012.OBJ'),files.index('O073.OBJ')+1);self.assertEqual(files.index('D005.OBJ')+1,files.index('R080.OBJ'))
 def test_research_source_or_duplicate_node_rejected(self):
  b=self.module();r=b.read_recipe()
  for kind in ['research','duplicate','missing']:
   a=copy.deepcopy(r)
   if kind=='research':next(q for q in a['owned']if q['kind']=='generic')['source']='build/taskBAD/template.c'
   elif kind=='duplicate':a['link']['files'][1]=a['link']['files'][0]
   else:a['owned'].pop()
   with self.subTest(kind=kind),self.assertRaises(ValueError):b.validate_recipe(a)
 def test_selected_early_taskman_public_owner_is_actual_O068(self):
  r=self.module().read_recipe();self.assertEqual(r['expected_selected_duplicate_owners']['_TS_InInterrupt'],'O068.OBJ');self.assertEqual(r['expected_selected_duplicate_owners']['ANIM_GetPalette_'],'O004.OBJ')
 def test_baseline_is_native_candidate_not_false_whole_target(self):
  b=self.module();r=b.read_recipe();self.assertEqual(r['source_baseline_native_sha256'],'16778a2885510dbe1f92aacd9d0692511907aac50edba91118dcee293ab7983b');self.assertFalse(r['whole_target_match']);self.assertEqual(r['source_credit_added'],0)

class PrefixBindingTests(unittest.TestCase):
 def test_prefix_only_api_rejects_wrong_vendor_without_reading_game(self):
  from tools import bind_dos4gw as b
  self.assertTrue(callable(getattr(b,'bind_prefix',None)),'prefix-only vendor binding is missing')
  with self.assertRaises(ValueError):b.bind_prefix(b'bad vendor',b'bad program')

class PublicationTests(unittest.TestCase):
 def test_actual_output_mutation_while_writing_receipt_rejected(self):
  import tempfile,hashlib
  from unittest.mock import patch
  b=importlib.import_module('tools.build_complete');self.assertTrue(callable(getattr(b,'publish_checked',None)),'post-publication freshness check is missing')
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as t:
   t=Path(t);artifact=t/'native-output';artifact.write_bytes(b'own output');pins={str(artifact):hashlib.sha256(artifact.read_bytes()).hexdigest()};real=b.dump
   def race(path,value):
    real(path,value);artifact.write_bytes(b'changed during receipt publication')
   with patch.object(b,'dump',side_effect=race),self.assertRaisesRegex(ValueError,'changed'):b.publish_checked(t/'receipt.json',{'kind':'own output receipt'},pins)
 def test_actual_copy_race_rejected_against_before_copy_digest(self):
  import tempfile,shutil
  from unittest.mock import patch
  b=importlib.import_module('tools.build_complete')
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as t:
   t=Path(t);a=t/'native-object';a.write_bytes(b'own artifact');real=shutil.copyfile
   def race(source,dest):real(source,dest);Path(dest).write_bytes(b'changed copy')
   with patch.object(b.shutil,'copyfile',side_effect=race),self.assertRaisesRegex(ValueError,'copied'):b.copy_expected(a,t/'link-object',{})

if __name__=='__main__':unittest.main()
