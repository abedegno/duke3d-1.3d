"""Exact independent profile, including native unused resolution obligations."""
from pathlib import Path
import os,shutil,sys,tempfile,unittest
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT))
from profiles.gnu_elf_omf_imports.identity import profile,checked_home,digest
from profiles.gnu_elf_omf_imports.apply_fork import apply
class ImportsProfile(unittest.TestCase):
 def test_exact_cumulative_three_source_changes(self):
  p=profile();a=p['converter_fork']['original_source_files'];b=p['converter_fork']['derived_source_files'];self.assertEqual(len(a),42);self.assertEqual(set(a),set(b));self.assertEqual({n for n in a if a[n]!=b[n]},{'omf.h','cof2omf.cpp','elf2cof.cpp'});self.assertEqual(p['tools']['bin/objconv']['sha256'],'36d4106f49fba444e75ce1a9a26fb9ba6585b3fa8201684e34e329636c627752')
 def test_exact_home_source_set_notices(self):
  home=Path(os.environ.get('GNU_ELF_IMPORTS_HOME',ROOT/'toolchains/gnu-elf-omf-imports'));before=checked_home(home)
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as d:
   h=Path(d)/'home';shutil.copytree(home,h);self.assertEqual(checked_home(h),before)
   for n in ['sources/objconv/elf2cof.cpp','notices/GNU-COPYING3','sources/unused-imports.patch']:
    data=(h/n).read_bytes();(h/n).write_bytes(data+b'\n')
    with self.assertRaises(ValueError):checked_home(h)
    (h/n).write_bytes(data)
   (h/'extra').write_text('unapproved')
   with self.assertRaises(ValueError):checked_home(h)
  self.assertEqual(checked_home(home),before)
 def test_patch_reapplication_rejects_without_mutation(self):
  home=Path(os.environ.get('GNU_ELF_IMPORTS_HOME',ROOT/'toolchains/gnu-elf-omf-imports'))
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as d:
   h=Path(d)/'source';shutil.copytree(home/'sources/objconv',h);before={p.name:digest(p)for p in h.iterdir()}
   with self.assertRaises(ValueError):apply(h)
   self.assertEqual({p.name:digest(p)for p in h.iterdir()},before)

class NativeImports(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  import json,subprocess
  cls.home=Path(os.environ.get('GNU_ELF_IMPORTS_HOME',ROOT/'toolchains/gnu-elf-omf-imports'));cls.old=Path(os.environ.get('GNU_ELF_OMF_HOME',ROOT/'toolchains/gnu-elf-omf'));cls.before=checked_home(cls.home)
  sys.path.insert(0,str(ROOT/'profiles/watcom/tools'))
  from omf32 import Module
  cls.Module=Module;cls.subprocess=subprocess;cls.json=json;cls.work=Path(tempfile.mkdtemp(prefix='elf-imports-own-',dir=ROOT/'build'));cls.rows=[]
  from profiles.gnu_elf_omf.identity import checked_home as old_checked
  cls.old_checked=staticmethod(old_checked);cls.oldbefore=old_checked(cls.old)
  for label,extra in [('clean',''),('debug_removed','.section .debug_info,"",@progbits\n.long unused_\n'),('exception_removed','.section .eh_frame,"a",@progbits\n.long unused_\n')]:
   w=cls.work/label;w.mkdir();src=w/'OWN.S';src.write_text('.intel_syntax noprefix\n.section _TEXT,"ax",@progbits\n.p2align 4\n.globl entry_,required_,unused_\nentry_:\ncall required_\nret\n'+extra);cls.call([str(cls.home/'bin/as-new'),*profile()['options']['assembler'],'-o',str(w/'OWN.ELF'),str(src)],w/'as.log')
   for name,home in [('old',cls.old),('new',cls.home)]:
    (w/name).mkdir()
    cls.call([str(home/'bin/objconv'),*profile()['options']['converter'],str(w/'OWN.ELF'),str(w/name/'OWN.OBJ')],w/(name+'.log'))
 @classmethod
 def call(cls,cmd,log):
  before=checked_home(cls.home);oldbefore=cls.old_checked(cls.old);q=cls.subprocess.run(cmd,capture_output=True,text=True);log.write_text(q.stdout+q.stderr)
  if q.returncode or q.stderr or 'warning'in q.stdout.lower():raise ValueError(q.stdout+q.stderr)
  if checked_home(cls.home)!=before or cls.old_checked(cls.old)!=oldbefore:raise ValueError('native operation changed tool home')
 @classmethod
 def tearDownClass(cls):
  if checked_home(cls.home)!=cls.before or cls.old_checked(cls.old)!=cls.oldbefore:raise ValueError('native fixture home freshness')
 def test_actual_unused_global_preserved_without_relocations(self):
  old=self.Module.parse((self.work/'clean/old/OWN.OBJ').read_bytes());new=self.Module.parse((self.work/'clean/new/OWN.OBJ').read_bytes());self.assertEqual(set(old.externals),{'required_'});self.assertEqual(set(new.externals),{'required_','unused_'});self.assertEqual(len(old.fixups),1);self.assertEqual(len(new.fixups),1);self.assertFalse(any(new.externals[f.target-1]=='unused_'for f in new.fixups if f.target_method==2));self.assertEqual(old.publics,new.publics);self.assertEqual([(s.name,s.size,s.data)for s in old.segments],[(s.name,s.size,s.data)for s in new.segments])
 def test_actual_debug_exception_removal_retains_old_behavior(self):
  for label in ['debug_removed','exception_removed']:
   self.assertEqual((self.work/label/'old/OWN.OBJ').read_bytes(),(self.work/label/'new/OWN.OBJ').read_bytes());self.assertEqual(set(self.Module.parse((self.work/label/'new/OWN.OBJ').read_bytes()).externals),{'required_'})
 def test_actual_wlink_missing_unused_provider_blocks(self):
  from runner import run_batch
  home=Path(os.environ.get('WATCOM_HOME',ROOT/'toolchains/watcom-10.0-ga'));w=self.work/'link';w.mkdir();shutil.copyfile(self.work/'clean/old/OWN.OBJ',w/'OLD.OBJ');shutil.copyfile(self.work/'clean/new/OWN.OBJ',w/'NEW.OBJ');prefix=".386p\n.model flat\n_TEXT segment para public use32 'CODE'\n";suffix='_TEXT ends\nend\n'
  for file,sym in [('REQ','required_'),('UNUSED','unused_')]: (w/(file+'.ASM')).write_text(prefix+'public '+sym+'\n'+sym+' proc near\nret\n'+sym+' endp\n'+suffix)
  for name,files in [('OLD',['OLD.OBJ','REQ.OBJ']),('NEW',['NEW.OBJ','REQ.OBJ']),('WITH',['NEW.OBJ','REQ.OBJ','UNUSED.OBJ'])]:(w/(name+'.LNK')).write_text('system dos4g\noption nodefaultlibs\nname '+name+'.EXE\n'+''.join('file '+n+'\n'for n in files))
  cmd='@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\nwasm /zq REQ.ASM > REQ.LOG\r\nwasm /zq UNUSED.ASM > UNUSED.LOG\r\n'+''.join('wlink @'+n+'.LNK > '+n+'.LOG\r\n'for n in ['OLD','NEW','WITH'])
  home=home.resolve();emulator=Path(os.environ.get('EXHUME_DOSBOX_X') or shutil.which('dosbox-x')).resolve()
  inputs=[p for p in home.rglob('*')if p.is_file()]+[p for p in w.iterdir()if p.is_file()]+[emulator,Path(__file__),ROOT/'profiles/watcom/tools/runner.py']
  pins={str(p):digest(p)for p in inputs};run_batch(home,w,cmd,60)
  self.assertEqual({str(p):digest(p)for p in inputs},pins)
  (w/'native-inputs.json').write_text(self.json.dumps(pins,indent=2)+'\n')
  self.assertFalse((w/'REQ.LOG').read_bytes());self.assertFalse((w/'UNUSED.LOG').read_bytes());self.assertTrue((w/'OLD.EXE').exists());self.assertFalse((w/'NEW.EXE').exists());self.assertIn('unused_', (w/'NEW.LOG').read_text());self.assertTrue((w/'WITH.EXE').exists());(w/'result.json').write_text(self.json.dumps({n:{'EXE_exists':(w/(n+'.EXE')).exists(),'log':(w/(n+'.LOG')).read_text()}for n in ['OLD','NEW','WITH']},indent=2)+'\n')

class SetupPublication(unittest.TestCase):
 def test_input_race_blocks_atomic_publication(self):
  from unittest.mock import patch
  from profiles.gnu_elf_omf_imports import setup
  home=Path(os.environ.get('GNU_ELF_IMPORTS_HOME',ROOT/'toolchains/gnu-elf-omf-imports'));archive=Path(os.environ['TASK506_BINUTILS_ARCHIVE']);objarchive=Path(os.environ['TASK506_OBJCONV_ARCHIVE'])
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as d:
   d=Path(d);tool=d/'objconv';shutil.copyfile(home/'bin/objconv',tool);target=d/'new-home';real=setup.checked_home
   def mutate_after_validation(p):
    result=real(p);tool.write_bytes(tool.read_bytes()+b'changed during staging');return result
   with patch.object(setup,'checked_home',mutate_after_validation):
    with self.assertRaisesRegex(ValueError,'input changed'):setup.stage(target,archive,objarchive,home/'bin/as-new',tool)
   self.assertFalse(target.exists());self.assertFalse(list(d.glob('elf-omf-setup-*')))
 def test_wrong_archive_or_tool_blocks_before_publication(self):
  from profiles.gnu_elf_omf_imports.setup import stage
  home=Path(os.environ.get('GNU_ELF_IMPORTS_HOME',ROOT/'toolchains/gnu-elf-omf-imports'));archive=Path(os.environ['TASK506_BINUTILS_ARCHIVE']);objarchive=Path(os.environ['TASK506_OBJCONV_ARCHIVE'])
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as d:
   d=Path(d);bad=d/'bad';bad.write_bytes(b'unapproved tool')
   for args in [(bad,objarchive,home/'bin/as-new',home/'bin/objconv'),(archive,objarchive,home/'bin/as-new',bad)]:
    with self.assertRaises(ValueError):stage(d/'absent',*args)
    self.assertFalse((d/'absent').exists())
 def test_source_only_atomic_setup_and_existing_home_preserved(self):
  from profiles.gnu_elf_omf_imports.setup import stage
  home=Path(os.environ.get('GNU_ELF_IMPORTS_HOME',ROOT/'toolchains/gnu-elf-omf-imports'));archive=Path(os.environ['TASK506_BINUTILS_ARCHIVE']);objarchive=Path(os.environ['TASK506_OBJCONV_ARCHIVE']);before=checked_home(home)
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as d:
   target=Path(d)/'new-home';result=stage(target,archive,objarchive,home/'bin/as-new',home/'bin/objconv');self.assertEqual(set(result),set(before));self.assertEqual(checked_home(target),result)
   with self.assertRaisesRegex(ValueError,'exists'):stage(target,archive,objarchive,home/'bin/as-new',home/'bin/objconv')
   self.assertEqual(checked_home(target),result)
  self.assertEqual(checked_home(home),before)
