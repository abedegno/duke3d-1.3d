"""The optional native record writer is built from the pinned vendor source."""
from pathlib import Path
import importlib,io,zipfile,json,tempfile,unittest,hashlib
ROOT=Path(__file__).resolve().parents[1]
class NativeLayoutProfile(unittest.TestCase):
 def source(self,directory):
  profile=importlib.import_module('profiles.gnu_elf_omf_layouts.identity').profile();raw=(ROOT/'toolchains/archives/objconv.zip').read_bytes();self.assertEqual(hashlib.sha256(raw).hexdigest(),profile['source_archives']['objconv']['sha256'])
  with zipfile.ZipFile(io.BytesIO(raw))as outer:
   with zipfile.ZipFile(io.BytesIO(outer.read('source.zip')))as source:
    for name in source.namelist():(directory/name).write_bytes(source.read(name))
  return profile
 def test_exact_derived_source_graph(self):
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
   directory=Path(directory);profile=self.source(directory);module=importlib.import_module('profiles.gnu_elf_omf_layouts.apply_fork');module.apply(directory)
   self.assertEqual({p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in directory.iterdir()},profile['derived_source_files'])
 def test_changed_vendor_source_rejected(self):
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
   directory=Path(directory);self.source(directory);p=directory/'cof2omf.cpp';p.write_bytes(p.read_bytes()+b'\r\n')
   with self.assertRaises(ValueError):importlib.import_module('profiles.gnu_elf_omf_layouts.apply_fork').apply(directory)
if __name__=='__main__':unittest.main()
