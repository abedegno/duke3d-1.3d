from pathlib import Path
import copy,json,subprocess,sys,types,unittest
from unittest.mock import patch,Mock
ROOT=Path(__file__).resolve().parents[1]
class PreparedGameRoute(unittest.TestCase):
 def module(self):
  from tools import build_complete as p
  return p
 def test_default_and_native_recipes_literal_unchanged(self):
  p=self.module();normal=p.read_recipe();before=copy.deepcopy(normal)
  self.assertEqual(p.select_recipe(normal,native_layout=False,prepare_game_residue=False),before)
  from tools.build_native_layout import prepare_recipe
  self.assertEqual(p.select_recipe(normal,native_layout=True,prepare_game_residue=False),prepare_recipe(before));self.assertEqual(normal,before)
 def test_flag_requires_native_before_inputs(self):
  p=self.module()
  with patch.object(Path,'read_bytes',side_effect=RuntimeError('input read')):
   with self.assertRaisesRegex(ValueError,'requires --native-layout'):p.build('unused',assets='unused',vendor_prefix='unused',prepare_game_residue=True)
 def test_prepared_recipe_has_truthful_source_and_scope(self):
  p=self.module();r=p.select_recipe(p.read_recipe(),native_layout=True,prepare_game_residue=True);q=next(q for q in r['owned']if q['alias']=='O071.OBJ');self.assertEqual(q['source'],'src/game/game.c');self.assertEqual(q['producer_module'],'tools.build_game_c');self.assertEqual(len(r['owned']),121);self.assertEqual(r['expected_native_sha256'],'a5fd6a00453c9f923b6c453a91be2401bfafad3ce55ee6ff741727f2346be88a');self.assertTrue(r['preparation_only']);self.assertFalse(r['adoption_approved']);self.assertFalse(r['whole_target_match'])
 def test_actual_selected_API_and_same_argument_contract(self):
  p=self.module()
  for prepared,module in [(False,'tools.build_game_symbolic'),(True,'tools.build_game_c')]:
   fn=Mock(return_value={'source_only':True,'marker':prepared});fake=types.SimpleNamespace(build_source=fn)
   from tools import build_game_c
   with patch.object(build_game_c,'build_source',fn), patch.object(p.importlib,'import_module',return_value=fake)as load:
    self.assertEqual(p.build_game(Path('own-source'),prepare_game_residue=prepared)['marker'],prepared)
    if prepared:
     fn.assert_called_once_with(ROOT/'toolchains/watcom-10.0-ga',Path('own-source')/'GAME',assembler_home=ROOT/'toolchains/gnu-elf-omf-game')
    else:
     load.assert_called_once_with(module);fn.assert_called_once_with(ROOT/'toolchains/gnu-elf-omf-game',Path('own-source')/'GAME',decoder_home=ROOT/'toolchains/capstone',watcom_home=ROOT/'toolchains/watcom-10.0-ga')
 def test_cli_requires_explicit_native_flag_normal_and_O(self):
  for opts in[[],['-O']]:
   p=subprocess.run([sys.executable,*opts,str(ROOT/'tools/build_complete.py'),'--prepare-game-residue','--vendor-prefix','unused','--report','unused'],capture_output=True,text=True)
   self.assertNotEqual(p.returncode,0);self.assertIn('requires --native-layout',p.stderr)
if __name__=='__main__':unittest.main()
