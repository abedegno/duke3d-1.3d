"""Stock preparation extracts whole, pinned compiler members only."""
from pathlib import Path
import importlib.util,json,tempfile,unittest
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
def load():
 s=importlib.util.spec_from_file_location('stock_runtime_prepare',ROOT/'tools/prepare_stock_runtime.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
class StockRuntimePreparation(unittest.TestCase):
 def test_fresh_complete_stock_inputs(self):
  m=load()
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
   r=m.prepare(Path(directory));self.assertEqual(r['stock_objects'],177);self.assertEqual(r['stock_libraries'],5);self.assertFalse(r['target_or_game_archive_read']);self.assertEqual(len(r['outputs_sha256']),182)
   for name,h in r['outputs_sha256'].items():self.assertEqual(m.digest(Path(r['directory'])/name),h)
 def test_interior_member_offset_is_rejected(self):
  m=load()
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
   p=Path(directory);j=json.loads((ROOT/m.MANIFEST).read_text());j['objects'][0]['offset']+=1;manifest=p/'bad.json';manifest.write_text(json.dumps(j))
   with self.assertRaisesRegex(ValueError,'member'):m.prepare(p/'output',manifest=manifest)
   self.assertFalse(list((p/'output').rglob('runtime-inputs.json')))
 def test_changed_manifest_snapshot_is_rejected(self):
  m=load()
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
   p=Path(directory);manifest=p/'model.json';manifest.write_bytes((ROOT/m.MANIFEST).read_bytes());actual=Path.read_bytes;changed=[]
   def race(path):
    raw=actual(path)
    if path==manifest and not changed:changed.append(path);path.write_bytes(raw+b'\n')
    return raw
   with patch.object(Path,'read_bytes',race):
    with self.assertRaisesRegex(ValueError,'changed'):m.prepare(p/'output',manifest=manifest)
   self.assertEqual(len(changed),1);self.assertFalse(list((p/'output').rglob('runtime-inputs.json')))
if __name__=='__main__':unittest.main()
