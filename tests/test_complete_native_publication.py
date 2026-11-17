"""Actual source-native fixture for the validated-hash→binder boundary."""
from pathlib import Path
import hashlib,importlib,json,os,shutil,sys,tempfile,unittest
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from runner import compile_source,run_batch
from le import LEImage
HOME=Path(os.environ.get('WATCOM_HOME',ROOT/'toolchains/watcom-10.0-ga'))
PREFIX=Path(os.environ.get('DOS4GW_PREFIX',ROOT/'build/assets/dos4gw/vendor-prefix.bin'))
class NativePublicationTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  expected=json.loads((ROOT/'profiles/watcom/game-compound-tools.json').read_text());actual={p.relative_to(HOME).as_posix():hashlib.sha256(p.read_bytes()).hexdigest()for p in HOME.rglob('*')if p.is_file()and'.git'not in p.parts}
  if actual!=expected:raise ValueError('OWN fixture requires exact unmodified500-file GA home')
  cls.temp=tempfile.TemporaryDirectory(prefix='complete-publish-fixture-',dir=ROOT/'build');cls.parent=Path(cls.temp.name);source=cls.parent/'OWN.C';source.write_text('int main(void) { return 173; }\n');compile_source(HOME,source,cls.parent/'OWN.OBJ',['/4r','/s','/ort'],30);(cls.parent/'LINK.LNK').write_text('system dos4g\noption quiet,map=OUT.MAP,stack=4096\nname GAME.EXE\nfile OWN.OBJ\n');run_batch(HOME,cls.parent,'@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\nset LIB=D:\\LIB386;D:\\LIB386\\DOS\r\nwlink @LINK.LNK > LINK.LOG\r\nif errorlevel 1 goto failed\r\necho OK>LINKSTAT.TXT\r\ngoto done\r\n:failed\r\necho FAILED>LINKSTAT.TXT\r\n:done\r\n',30)
  if(cls.parent/'LINKSTAT.TXT').read_text().strip()!='OK':raise ValueError('OWN fixture native link failed')
  cls.native=(cls.parent/'GAME.EXE').read_bytes();cls.digest=hashlib.sha256(cls.native).hexdigest();cls.prefix=PREFIX.read_bytes();im=LEImage.parse(cls.native);offset=im.file_offset(1,im.entry_offset);bad=bytearray(cls.native);bad[offset]^=1;cls.bad=bytes(bad)
 @classmethod
 def tearDownClass(cls):cls.temp.cleanup()
 def module(self):
  b=importlib.import_module('tools.build_complete');self.assertTrue(callable(getattr(b,'validate_native_and_bind',None)),'validated snapshot binder seam missing');return b
 def stage(self):
  w=Path(tempfile.mkdtemp(dir=self.parent));(w/'link').mkdir();(w/'link/GAME.EXE').write_bytes(self.native)
  for n in['LINK.LOG','OUT.MAP','LINKSTAT.TXT']:shutil.copyfile(self.parent/n,w/'link'/n)
  return w
 def test_real_native_positive_binds_same_validated_bytes(self):
  b=self.module();w=self.stage();r=b.validate_native_and_bind(w,self.prefix,self.digest,{})
  self.assertEqual(r['native_sha256'],self.digest);self.assertEqual((w/'DUKE3D.EXE').read_bytes(),self.prefix+self.native);b.unchanged(r['outputs_sha256'])
 def test_actual_mutation_after_validated_hash_cannot_be_adopted(self):
  b=self.module();w=self.stage();program=w/'link/GAME.EXE';real=hashlib.sha256;fired=[]
  def race(raw,*args,**kwargs):
   value=real(raw,*args,**kwargs)
   if raw==self.native and not fired:program.write_bytes(self.bad);fired.append(True)
   return value
  with patch.object(b.hashlib,'sha256',side_effect=race),self.assertRaisesRegex(ValueError,'changed'):
   b.validate_native_and_bind(w,self.prefix,self.digest,{})
  self.assertTrue(fired);self.assertFalse((w/'result.json').exists())
 def test_bound_write_cannot_change_native_or_adopt_new_output_bytes(self):
  b=self.module();w=self.stage();real=Path.write_bytes;fired=[]
  def race(path,raw):
   result=real(path,raw)
   if path==w/'DUKE3D.EXE'and not fired:real(path,raw[:-1]+bytes([raw[-1]^1]));fired.append(True)
   return result
  with patch.object(Path,'write_bytes',race),self.assertRaisesRegex(ValueError,'changed'):b.validate_native_and_bind(w,self.prefix,self.digest,{})
  self.assertTrue(fired)
 def test_exact_reviewer_sha_hook_is_rejected(self):
  b=self.module();w=self.stage();program=w/'link/GAME.EXE';real=b.sha;fired=[]
  def race(path):
   value=real(path)
   if Path(path)==program and value==self.digest and not fired:program.write_bytes(self.bad);fired.append(True)
   return value
  with patch.object(b,'sha',side_effect=race),self.assertRaisesRegex(ValueError,'changed'):b.validate_native_and_bind(w,self.prefix,self.digest,{})
  self.assertTrue(fired)
 def test_prevalidated_log_digest_is_not_later_recaptured(self):
  b=self.module();w=self.stage();log=w/'link/LINK.LOG';pins={str(log):b.sha(log)};real=hashlib.sha256;fired=[]
  def race(raw,*args,**kwargs):
   value=real(raw,*args,**kwargs)
   if raw==self.native and not fired:log.write_bytes(b'changed after validation');fired.append(True)
   return value
  with patch.object(b.hashlib,'sha256',side_effect=race),self.assertRaisesRegex(ValueError,'changed'):b.validate_native_and_bind(w,self.prefix,self.digest,pins)
  self.assertTrue(fired)
 def test_receipt_publication_keeps_validated_native_digest(self):
  b=self.module();w=self.stage();r=b.validate_native_and_bind(w,self.prefix,self.digest,{});real=b.dump
  def race(path,value):real(path,value);(w/'link/GAME.EXE').write_bytes(self.bad)
  with patch.object(b,'dump',side_effect=race),self.assertRaisesRegex(ValueError,'changed'):b.publish_checked(w/'result.json',r,r['outputs_sha256'])
  self.assertFalse((w/'result.json').exists())
if __name__=='__main__':unittest.main()
