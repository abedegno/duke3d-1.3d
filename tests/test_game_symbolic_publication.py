"""GAME source input and main/tail publication snapshots remain consistent."""
from pathlib import Path
import importlib.util,shutil,tempfile,unittest
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
GNU=ROOT/'toolchains/gnu-elf-omf-game';CAP=ROOT/'toolchains/capstone';GA=ROOT/'toolchains/watcom-10.0-ga'
def load():
 s=importlib.util.spec_from_file_location('game_publication',ROOT/'tools/build_game_symbolic.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
class GameSymbolicPublication(unittest.TestCase):
 def test_declared_source_change_before_staging_rejects(self):
  m=load()
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
   p=Path(directory);project=p/'project'
   for n in set(m.SOURCES+m.NOTICES+m.TOOLS+m.OBSERVERS+[m.REFERENCE,m.DESCRIPTOR]):
    q=project/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,q)
   m.ROOT=project;source=project/m.SOURCE/'GAME.S';real=m.digest;changed=[]
   def race(path):
    h=real(path)
    if Path(path)==source and not changed:changed.append(path);source.write_bytes(source.read_bytes()+b'\n')
    return h
   with patch.object(m,'digest',race),patch.object(m.subprocess,'run',wraps=m.subprocess.run)as native:
    with self.assertRaisesRegex(ValueError,'changed'):m.build_source(GNU,p/'native',decoder_home=CAP,watcom_home=GA)
    self.assertEqual(len(changed),1);native.assert_not_called()
 def test_tail_change_after_parsed_read_rejects(self):
  m=load()
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
   parent=Path(directory);real=Path.read_bytes;changed=[]
   def race(path):
    raw=real(path)
    if path.name=='GMTAIL.OBJ'and path.is_relative_to(parent)and not changed:changed.append(path);path.write_bytes(raw+b'\0')
    return raw
   with patch.object(Path,'read_bytes',race):
    with self.assertRaisesRegex(ValueError,'changed'):m.build_source(GNU,parent,decoder_home=CAP,watcom_home=GA)
   self.assertEqual(len(changed),1);self.assertFalse((changed[0].parent/'source-build.json').exists())
 def test_main_change_at_receipt_write_rejects_and_removes_receipt(self):
  m=load()
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
   parent=Path(directory);real=Path.write_text;changed=[]
   def race(path,data,*args,**kwargs):
    result=real(path,data,*args,**kwargs)
    if path.name=='source-build.json'and path.is_relative_to(parent)and not changed:
     native=path.parent/'GAME.OBJ';changed.append(native);native.write_bytes(native.read_bytes()+b'\0')
    return result
   with patch.object(Path,'write_text',race):
    with self.assertRaisesRegex(ValueError,'changed'):m.build_source(GNU,parent,decoder_home=CAP,watcom_home=GA)
   self.assertEqual(len(changed),1);self.assertFalse((changed[0].parent/'source-build.json').exists())
if __name__=='__main__':unittest.main()
