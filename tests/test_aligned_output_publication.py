"""A producer must publish the exact native bytes its guard parsed."""
from pathlib import Path
import importlib.util
import tempfile
import unittest
import json
import shutil
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
CASES=[('gf1_note','GF1NOTE'),('gf1_digital','DIGITAL'),('gf1_sound','GF1SOUND'),('mact_zone','ZONE'),('mact_debug','DEBUG')]
class AlignedOutputPublication(unittest.TestCase):
 def test_model_snapshot_is_bound_before_native_execution(self):
  for name,stem in CASES:
   with self.subTest(module=name),tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
    spec=importlib.util.spec_from_file_location('model_publication_'+name,ROOT/('tools/build_'+name+'_elf.py'));module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    project=Path(directory)/'project';original=json.loads((ROOT/module.MODEL).read_text());files=set(original['inputs_sha256'])|{module.MODEL,'profiles/gnu_elf_omf/identity.py','profiles/gnu_elf_omf/profile.json','profiles/gnu_elf_omf/elf32.py','profiles/watcom/tools/omf32.py',str(Path(module.CONTRACT).with_name('README.md'))}
    if name.startswith('gf1_'):files|={'src/gf1/note/COPYRIGH','src/gf1/note/README'}
    for relative in files:
     target=project/relative;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/relative,target)
    module.ROOT=project;model=project/module.MODEL;bad=json.loads(json.dumps(original));public=next(iter(bad['native_inventory']['publics']));bad['native_inventory']['publics'][public][1]+=1;changed=[];actual_bytes=Path.read_bytes;actual_text=Path.read_text
    def change(path,data):
     if path==model and not changed:changed.append(path);path.write_text(json.dumps(bad))
     return data
    def bytes_race(path):return change(path,actual_bytes(path))
    def text_race(path,*args,**kwargs):return change(path,actual_text(path,*args,**kwargs))
    with patch.object(Path,'read_bytes',bytes_race),patch.object(Path,'read_text',text_race),patch.object(module.subprocess,'run',wraps=module.subprocess.run)as run:
     with self.assertRaisesRegex(ValueError,'changed'):module.build_source(ROOT/'toolchains/gnu-elf-omf',Path(directory)/'native')
     self.assertEqual(len(changed),1);run.assert_not_called()
 def test_change_after_native_read_is_rejected_before_receipt(self):
  for name,stem in CASES:
   with self.subTest(module=name),tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
    spec=importlib.util.spec_from_file_location('output_publication_'+name,ROOT/('tools/build_'+name+'_elf.py'));module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);parent=Path(directory);actual=Path.read_bytes;changed=[]
    def race(path):
     data=actual(path)
     if path.name==stem+'.OBJ'and path.is_relative_to(parent)and not changed:
      changed.append(path);path.write_bytes(data+b'\0')
     return data
    with patch.object(Path,'read_bytes',race):
     with self.assertRaisesRegex(ValueError,'changed'):
      module.build_source(ROOT/'toolchains/gnu-elf-omf',parent/'native')
    self.assertEqual(len(changed),1)
    self.assertFalse((changed[0].parent/'source-build.json').exists())
if __name__=='__main__':unittest.main()
