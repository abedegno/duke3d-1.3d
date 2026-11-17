"""Native emission plans preserve source bytes and reject invalid record layouts."""
from pathlib import Path
import tempfile,subprocess,sys,unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'profiles/watcom/tools'))
from omf32 import Module
from profiles.gnu_elf_omf_layouts.identity import checked_home
HOME=ROOT/'toolchains/gnu-elf-omf-layouts'
SOURCE='''.intel_syntax noprefix
.code32
.section _TEXT,"ax",@progbits
.globl own_,helper_
own_:
mov eax,dword ptr[_value]
call helper_
ret
helper_:
inc eax
ret
.section _DATA,"aw",@progbits
.globl _value
_value:
.long 41
'''
class NativeLayoutWriter(unittest.TestCase):
 def fixture(self,d):
  checked_home(HOME);source=d/'OWN.S';source.write_text(SOURCE);elf=d/'OWN.ELF';p=subprocess.run([str(HOME/'bin/as-new'),'--32','-n','-o',str(elf),str(source)],capture_output=True,text=True);self.assertEqual((p.returncode,p.stderr),(0,''));return elf
 def convert(self,elf,out,*flags):return subprocess.run([str(HOME/'bin/objconv'),'-fomf32','-wex',*flags,str(elf),str(out)],capture_output=True,text=True)
 def test_valid_plan_retains_full_native_semantics(self):
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
   d=Path(directory);elf=self.fixture(d);base=d/'base.OBJ';self.assertEqual(self.convert(elf,base).returncode,0);old=d/'old'/'base.OBJ';old.parent.mkdir();p=subprocess.run([str(ROOT/'toolchains/gnu-elf-omf-imports/bin/objconv'),'-fomf32','-wex',str(elf),str(old)],capture_output=True,text=True);self.assertEqual(p.returncode,0,p.stdout+p.stderr);self.assertEqual(base.read_bytes(),old.read_bytes());plan=d/'record.plan';plan.write_text('OMF_PACKETS_V1\nsection _TEXT 13\npacket 0 5\npacket 5 5\npacket 10 3\nend\n');out=d/'planned.OBJ';p=self.convert(elf,out,'-packet-plan='+str(plan));self.assertEqual(p.returncode,0,p.stdout+p.stderr);a=Module.parse(base.read_bytes());b=Module.parse(out.read_bytes());self.assertEqual(a.segments,b.segments);self.assertEqual(a.publics,b.publics);self.assertEqual(a.externals,b.externals);self.assertEqual(a.groups,b.groups);self.assertEqual(a.fixups,b.fixups)
 def test_bad_numbers_crossing_and_omf_inputs_rejected(self):
  with tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
   d=Path(directory);elf=self.fixture(d);good='OMF_PACKETS_V1\nsection _TEXT 13\npacket 0 5\npacket 5 5\npacket 10 3\nend\n';bad={'overflow':good.replace('section _TEXT 13','section _TEXT 4294967309'),'crossing':'OMF_PACKETS_V1\nsection _TEXT 13\npacket 0 2\npacket 2 11\nend\n','gap':'OMF_PACKETS_V1\nsection _TEXT 13\npacket 0 5\npacket 6 7\nend\n','signed':good.replace('packet 0 5','packet +0 5')}
   for name,text in bad.items():
    plan=d/(name+'.plan');plan.write_text(text);out=d/(name+'.OBJ');p=self.convert(elf,out,'-packet-plan='+str(plan));self.assertNotEqual(p.returncode,0,name);self.assertFalse(out.exists(),name)
   base=d/'base.OBJ';self.assertEqual(self.convert(elf,base).returncode,0);plan=d/'good.plan';plan.write_text(good);out=d/'from-old-omf.OBJ';p=self.convert(base,out,'-packet-plan='+str(plan));self.assertNotEqual(p.returncode,0);self.assertFalse(out.exists())
if __name__=='__main__':unittest.main()
