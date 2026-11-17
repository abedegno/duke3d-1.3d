import importlib.util
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
def guard():
 p=ROOT/'src/game/symbolic/contract.py';s=importlib.util.spec_from_file_location('game_symbolic_guard_test',p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
class OperandTests(unittest.TestCase):
 def test_real_owner_and_exact_brackets(self):
  g=guard();p=g.operand_plan('call dword ptr [_GetTime]\nmov eax, dword ptr [ebx*4 + _sprite + 12]',{'_GetTime','_sprite'},{})
  self.assertEqual([(x['owner'],x['addend'])for x in p],[('_GetTime',0),('_sprite',12)])
 def test_competing_canceled_prefix_suffix_and_section_alias(self):
  g=guard();bad=['call dword ptr [_GetTime] + (_sprite+1576-_GetTime)','call dword ptr (_sprite+1576-_GetTime)[_GetTime]','call dword ptr [_sprite+1576+(_GetTime-_GetTime)]','call dword ptr [[_GetTime]]','call dword ptr [_GetTime+0*_sprite]']
  for text in bad:
   with self.subTest(text=text),self.assertRaises(ValueError):g.operand_plan(text,{'_GetTime','_sprite'},{})
 def test_quoted_hash_and_numeric_ABS(self):
  g=guard();self.assertEqual(g.statement('.ascii "level#\\000" #comment'),'.ascii "level#\\000"');self.assertEqual(g.operand_plan('.att_syntax prefix\ncmpw $TILE,%ax\n.intel_syntax noprefix',{'_sprite'},{'TILE':99}),[])
if __name__=='__main__':unittest.main()
