from pathlib import Path
import copy,importlib,unittest
ROOT=Path(__file__).resolve().parents[1]
class LayoutCatalogTests(unittest.TestCase):
 def api(self):
  self.assertTrue((ROOT/'tools/build_native_layout.py').is_file(),'normal source-owned layout wrapper missing');return importlib.import_module('tools.build_native_layout')
 def test_finite_code_only_catalog_and_default_untouched(self):
  p=self.api();r=p.catalog();self.assertEqual(len(r['modules']),23);self.assertIn('O071.OBJ',r['modules']);self.assertIn('O099.OBJ',r['modules']);self.assertFalse(r['source_credit_added']);self.assertFalse(r['whole_target_match'])
 def test_plans_cover_exact_extents_without_addresses_or_field_order(self):
  p=self.api()
  for alias,spec in p.catalog()['modules'].items():
   plan=p.read_plan(ROOT/spec['plan'],spec['code_extent']);self.assertEqual(plan['section'],'_TEXT');self.assertEqual(sum(n for _,n in plan['packets']),spec['code_extent']);self.assertEqual(plan['packets'][0][0],0)
 def test_descriptor_rejects_gap_sign_overflow_and_trailing(self):
  p=self.api();good='OMF_PACKETS_V1\nsection _TEXT 13\npacket 0 5\npacket 5 8\nend\n'
  for bad in[good.replace('packet 5 8','packet 6 7'),good.replace('packet 0 5','packet +0 5'),good.replace('section _TEXT 13','section _TEXT 4294967309'),good+'target_address 123\n']:
   with self.subTest(bad=bad),self.assertRaises(ValueError):p.parse_plan(bad,13)
 def test_opt_in_recipe_keeps_default_and_removes_duplicate_actors_half(self):
  p=self.api();from tools.build_complete import read_recipe
  normal=read_recipe();before=copy.deepcopy(normal);planned=p.prepare_recipe(normal);self.assertEqual(normal,before);self.assertEqual(len(normal['owned']),122);self.assertEqual(len(planned['owned']),121);self.assertNotIn('O002.OBJ',planned['link']['files']);self.assertEqual(next(q for q in planned['owned']if q['alias']=='O001.OBJ')['module'],'tools.build_actors_c');self.assertEqual(planned['expected_native_sha256'],'59d14397f95bfd77efea7093e490a955f957a03f3adc6d09c90b6393121f9c3b');self.assertFalse(planned['whole_target_match'])
if __name__=='__main__':unittest.main()
