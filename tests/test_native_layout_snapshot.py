"""Parse only the manifest bytes whose identity was validated."""
from pathlib import Path
from unittest.mock import patch
import copy, importlib, json, unittest, tempfile, shutil

class NativeLayoutSnapshots(unittest.TestCase):
 def test_profile_parse_uses_validated_snapshot(self):
  module=importlib.import_module('profiles.gnu_elf_omf_layouts.identity')
  expected=module.profile(); bad=copy.deepcopy(expected)
  bad['tools']['bin/objconv']['sha256']='0'*64
  path=module.ROOT/'profiles/gnu_elf_omf_layouts/profile.json'
  original=Path.read_text
  def changed(p,*a,**kw):
   return json.dumps(bad) if p==path else original(p,*a,**kw)
  with patch.object(Path,'read_text',changed):
   self.assertEqual(module.profile(),expected)
 def test_base_manifest_parse_uses_validated_snapshot(self):
  module=importlib.import_module('profiles.gnu_elf_omf_layouts.identity')
  expected=module.expected_files()
  path=module.ROOT/'profiles/gnu_elf_omf_imports/profile.json'
  bad=json.loads(path.read_bytes());bad['converter_fork']['patch_sha256']='0'*64
  original=Path.read_text
  def changed(p,*a,**kw):
   return json.dumps(bad) if p==path else original(p,*a,**kw)
  with patch.object(Path,'read_text',changed):
   self.assertEqual(module.expected_files(),expected)
 def test_changed_setup_receipt_is_not_admitted(self):
  module=importlib.import_module('profiles.gnu_elf_omf_layouts.identity')
  with tempfile.TemporaryDirectory(dir=module.ROOT/'build') as directory:
   home=Path(directory)/'home';shutil.copytree(module.ROOT/'toolchains/gnu-elf-omf-layouts',home)
   receipt=home/'setup.json';changed=json.loads(receipt.read_bytes());changed['profile_sha256']='0'*64
   original_bytes=Path.read_bytes;original_text=Path.read_text;fired=[]
   def after_read(p,value):
    if p==receipt and not fired:
     fired.append(True);p.write_text(json.dumps(changed))
    return value
   def raw(p,*a,**kw):return after_read(p,original_bytes(p,*a,**kw))
   def text(p,*a,**kw):return after_read(p,original_text(p,*a,**kw))
   with patch.object(Path,'read_bytes',raw),patch.object(Path,'read_text',text):
    with self.assertRaises(ValueError):module.checked_home(home)
   self.assertTrue(fired)
if __name__=='__main__':unittest.main()
