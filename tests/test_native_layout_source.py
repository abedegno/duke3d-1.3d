"""One real source-native owner exercises the common opt-in emission boundary."""
from pathlib import Path
import copy,dataclasses,json,tempfile,unittest,shutil
from unittest import mock
from tools import build_native_layout as p
from tools.probe_pawe_nrpn import build_source
from omf32 import Module
ROOT=Path(__file__).resolve().parents[1]
class NativeLayoutSource(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.temp=tempfile.TemporaryDirectory(prefix='native-layout-test-',dir=ROOT/'build');cls.root=Path(cls.temp.name);cls.normal=build_source(ROOT/'toolchains/gnu-omf',cls.root/'normal');cls.r=p.emit('O101.OBJ',cls.normal,cls.root/'planned');cls.a=Module.parse(Path(cls.normal['object']).read_bytes());cls.b=Module.parse(Path(cls.r['object']).read_bytes());cls.plan=p.read_plan(ROOT/'src/native_layout/nrpn.plan',next(s.size for s in cls.a.segments if s.name=='_TEXT'))
 @classmethod
 def tearDownClass(cls):cls.temp.cleanup()
 def test_actual_source_ELF_COFF_runtime_identity_and_LOCAT(self):
  self.assertTrue(self.r['proof']['all_native_properties_literal_except_packet_LOCAT']);self.assertFalse(self.r['target_or_original_OMF_input']);self.assertEqual(len(self.b.fixups),149)
 def test_actual_public_scope_field_segment_and_data_controls(self):
  for kind in['public','private','field','data','class']:
   b=copy.deepcopy(self.b)
   if kind=='public':n=next(iter(b.publics));s,o=b.publics[n];b.publics[n]=(s,o+1)
   elif kind=='private':b.local_publics.add(next(iter(b.publics)))
   elif kind=='field':b.fixups[0]=dataclasses.replace(b.fixups[0],offset=b.fixups[0].offset+1)
   elif kind=='data':next(s for s in b.segments if s.name=='_TEXT').data[-1]^=1
   else:next(s for s in b.segments if s.name=='_TEXT').class_name='DATA'
   with self.subTest(kind=kind),self.assertRaises(ValueError):p.check_native(self.a,b,self.plan)
 def test_plan_that_splits_a_real_field_rejects_before_publication(self):
  f=next(f for f in self.b.fixups if f.width==4);plan=copy.deepcopy(self.plan);extent=plan['extent'];cut=f.offset+1;plan['packets']=[(0,cut),(cut,extent-cut)]
  with self.assertRaises(ValueError):p.check_native(self.a,self.b,plan)
 def test_copied_plan_race_rejects_before_converter(self):
  original=p.shutil.copyfile
  def changed(source,dest,*a,**k):
   value=original(source,dest,*a,**k)
   if Path(dest).name=='layout.plan':Path(dest).write_text(Path(dest).read_text().replace('packet 0 ', 'packet 1 ',1))
   return value
  with mock.patch.object(p.shutil,'copyfile',side_effect=changed),mock.patch.object(p.subprocess,'run')as run,self.assertRaises(ValueError):p.emit('O101.OBJ',self.normal,self.root/'plan-race')
  run.assert_not_called()
 def test_actual_extra_toolhome_file_after_native_rejects(self):
  home=self.root/'private-home';shutil.copytree((ROOT/'toolchains/gnu-elf-omf-layouts').resolve(),home);original=p.subprocess.run
  def changed(*a,**k):
   result=original(*a,**k);(home/'unexpected-file').write_text('real post-tool namespace mutation');return result
  with mock.patch.object(p.subprocess,'run',side_effect=changed),self.assertRaises(ValueError):p.emit('O101.OBJ',self.normal,self.root/'home-race',home=home)
  self.assertFalse(list((self.root/'home-race').rglob('source-build.json')))
 def test_receipt_publication_object_race_removes_receipt(self):
  original=p.dump
  def changed(path,value):
   original(path,value);obj=Path(value['object']);raw=bytearray(obj.read_bytes());raw[-1]^=1;obj.write_bytes(raw)
  with mock.patch.object(p,'dump',side_effect=changed),self.assertRaises(ValueError):p.emit('O101.OBJ',self.normal,self.root/'publication-race')
  self.assertFalse(list((self.root/'publication-race').rglob('source-build.json')))
 def test_receipt_bytes_are_validated_before_publication(self):
  original=p.dump
  def changed(path,value):
   original(path,value);Path(path).write_text('{}\n')
  with mock.patch.object(p,'dump',side_effect=changed),self.assertRaises(ValueError):p.emit('O101.OBJ',self.normal,self.root/'receipt-race')
  self.assertFalse(list((self.root/'receipt-race').rglob('source-build.json')))
if __name__=='__main__':unittest.main()
