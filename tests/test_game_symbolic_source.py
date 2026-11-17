"""Focused normal GAME source, ABI/ownership/field and actual race controls."""
from pathlib import Path
import copy,dataclasses,importlib.util,json,os,shutil,struct,sys,tempfile,unittest
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from tools import build_game_symbolic as b
from profiles.gnu_elf_omf.elf32 import elf
from omf32 import Module
GNU=Path(os.environ.get('GAME_GNU_HOME',ROOT/'toolchains/gnu-elf-omf-game'));CAP=Path(os.environ.get('CAPSTONE_HOME',ROOT/'toolchains/capstone'));GA=Path(os.environ.get('WATCOM_HOME',ROOT/'toolchains/watcom-10.0-ga'))
class SourceTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.tmp=tempfile.TemporaryDirectory(prefix='game-symbolic-tests-',dir=ROOT/'build');cls.result=b.build_source(GNU,Path(cls.tmp.name),decoder_home=CAP,watcom_home=GA);cls.w=Path(cls.result['native_build_directory']);cls.e=elf(cls.w/'GAME.ELF');cls.m=Module.parse((cls.w/'GAME.OBJ').read_bytes());cls.text=(ROOT/b.SOURCE/'GAME.S').read_text();cls.pre=json.loads((cls.w/'source-ELF-proof.json').read_text())
 @classmethod
 def tearDownClass(cls):cls.tmp.cleanup()
 def test_complete_source_native_object_and_tail(self):
  self.assertEqual(self.result['object_sha256'],'050676f7b3d07d0317d339848ed310766878bfc16caf79d729cc2ef9f1719f95');self.assertEqual(self.result['tail_object_sha256'],'9f565d79c0c6f192d75a8ae0f53e0563699a28c8804490e99ca821d530923684');self.assertEqual(len(self.pre['all5018_fields']),5018);self.assertEqual(len(self.m.publics),109);self.assertEqual(self.m.groups,[('DGROUP',(2,3,4,5)),('FLAT',())]);self.assertFalse(self.result['full_target_match']);self.assertFalse(self.result['source_credit'])
 def test_source_owner_cancellation_prefix_suffix_and_alias(self):
  old='call KB_Shutdown_';self.assertIn(old,self.text)
  for new in ['call CONTROL_Shutdown_','call (_sprite-_sprite+KB_Shutdown_)','call [KB_Shutdown_] + (_sprite-_sprite)','call (_sprite-_sprite)[KB_Shutdown_]']:
   with self.subTest(new=new),self.assertRaises(ValueError):b.contract.source_preflight(self.text.replace(old,new,1))
 def test_private_public_scope_rejected(self):
  with self.assertRaises(ValueError):b.contract.source_preflight(self.text.replace('.local _frameval','.globl _frameval',1))
 def test_typed_fields_public_coordinates_and_segment_class(self):
  for mutation in['public','class','access','field','private','import']:
   m=copy.deepcopy(self.m)
   if mutation=='public':s,o=m.publics['spawn_'];m.publics['spawn_']=(s,o+1)
   elif mutation=='class':m.segments[3].class_name='CONST'
   elif mutation=='access':m.segments[3].access=1
   elif mutation=='field':m.fixups[0]=dataclasses.replace(m.fixups[0],target=m.fixups[0].target+1)
   elif mutation=='private':m.local_publics.add('spawn_')
   else:m.externals[0]+='_unused'
   with self.subTest(mutation=mutation),self.assertRaises(ValueError):b.contract.postflight(self.e,m,self.pre)
 def test_elf_private_coordinate_and_field_bijection(self):
  for kind in['private','duplicate']:
   e=copy.deepcopy(self.e)
   if kind=='private':next(q for tab in e['symbols'].values()for q in tab if q['name']=='_frameval')['value']+=1
   else:e['relocations'][1]=copy.deepcopy(e['relocations'][0])
   with self.subTest(kind=kind),self.assertRaises(ValueError):b.contract.preflight(self.w/'GAME.ELF',self.text,(self.w/'GAME.LST').read_text(),e)
 def test_coff_duplicate_actual_field_rejected(self):
  with tempfile.TemporaryDirectory(dir=self.tmp.name)as d:
   d=Path(d);raw=bytearray((self.w/'GAME.COFF').read_bytes());c=b.coff.coff(self.w/'GAME.COFF');s=next(s for s in c['sections']if s['reloc_count']>1);at=s['reloc_offset'];raw[at+10:at+20]=raw[at:at+10];(d/'GAME.COFF').write_bytes(raw)
   with self.assertRaisesRegex(ValueError,'bijection'):b.coff.check(d,self.e,self.m)
 def test_full_final_tail_and_data_bytes_rejected(self):
  for number,index in[(0,-1),(1,47),(3,0),(4,-1)]:
   m=copy.deepcopy(self.m);m.segments[number].data[index]^=1
   with self.subTest(segment=number),self.assertRaises(ValueError):b.contract.postflight(self.e,m,self.pre)
 def test_copy_race_uses_live_before_copy_expected_digest(self):
  real=shutil.copyfile
  def corrupt(src,dst,*a,**kw):
   v=real(src,dst,*a,**kw)
   if str(dst).endswith('/GAME.S'):Path(dst).write_bytes(Path(dst).read_bytes()+b'\n# actual staged race\n')
   return v
  with patch.object(b.shutil,'copyfile',side_effect=corrupt),patch.object(b.subprocess,'run')as tool:
   with self.assertRaisesRegex(ValueError,'identity changed'):b.build_source(GNU,Path(self.tmp.name),decoder_home=CAP,watcom_home=GA)
   tool.assert_not_called()
 def test_final_gnu_home_extra_file_race_rejects(self):
  # Copy only this small normal GNU home; never mutate a shared tool home.
  with tempfile.TemporaryDirectory(dir=self.tmp.name)as q:
   home=Path(q)/'gnu';shutil.copytree(GNU,home);real=b.subprocess.run
   def extra(args,*a,**kw):
    r=real(args,*a,**kw);(home/'unexpected-race-file').write_text('actual post-tool addition');return r
   with patch.object(b.subprocess,'run',side_effect=extra),self.assertRaisesRegex(ValueError,'file set'):b.build_source(home,Path(self.tmp.name),decoder_home=CAP,watcom_home=GA)
 def test_no_target_sdk_or_ignored_research_producer_input(self):
  self.assertFalse(self.result['target_SDK_Cobject_decoder_emitter_read'])
  for p in self.result['inputs_sha256']:
   self.assertNotIn('/build/task',p);self.assertNotIn('/reference/',p);self.assertNotIn('/.superpowers/',p)

if __name__=='__main__':unittest.main()
