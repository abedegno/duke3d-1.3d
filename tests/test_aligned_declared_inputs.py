"""Declared source hashes must survive validation-to-staging changes."""
from pathlib import Path
import importlib.util
import json
import shutil
import tempfile
import unittest
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
CASES=['gf1_note','gf1_digital','gf1_sound','mact_zone','mact_debug']
class DeclaredAlignedInputs(unittest.TestCase):
 def test_source_change_after_validation_stops_before_native(self):
  for name in CASES:
   with self.subTest(module=name),tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
    spec=importlib.util.spec_from_file_location('declared_inputs_'+name,ROOT/('tools/build_'+name+'_elf.py'));module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);project=Path(directory)/'project';model=json.loads((ROOT/module.MODEL).read_text());files=set(model['inputs_sha256'])|{module.MODEL,'profiles/gnu_elf_omf/identity.py','profiles/gnu_elf_omf/profile.json','profiles/gnu_elf_omf/elf32.py','profiles/watcom/tools/omf32.py',str(Path(module.CONTRACT).with_name('README.md'))}
    if name.startswith('gf1_'):files|={'src/gf1/note/COPYRIGH','src/gf1/note/README'}
    for relative in files:
     target=project/relative;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/relative,target)
    module.ROOT=project;source=project/module.SOURCE;actual=module.digest;changed=[]
    def race(path):
     value=actual(path)
     if Path(path)==source and not changed:changed.append(path);source.write_bytes(source.read_bytes()+b'\n')
     return value
    with patch.object(module,'digest',side_effect=race),patch.object(module.subprocess,'run',wraps=module.subprocess.run)as run:
     with self.assertRaisesRegex(ValueError,'changed'):module.build_source(ROOT/'toolchains/gnu-elf-omf',Path(directory)/'native')
     self.assertEqual(len(changed),1);run.assert_not_called()
if __name__=='__main__':unittest.main()
