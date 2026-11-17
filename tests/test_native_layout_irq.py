"""Finite directive-only source projection; no instruction/body changes."""
from pathlib import Path
import copy,dataclasses,tempfile,unittest
from unittest import mock
from tools import build_native_layout as p
from tools.probe_irq_symbolic import build_source
from profiles.gnu_elf_omf.elf32 import elf
from omf32 import Module
ROOT=Path(__file__).resolve().parents[1]
class IRQLayoutSource(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.temp=tempfile.TemporaryDirectory(prefix='irq-layout-test-',dir=ROOT/'build');cls.root=Path(cls.temp.name);normal=build_source(ROOT/'toolchains/watcom-10.5',cls.root/'normal');cls.r=p.irq_source(normal,cls.root/'elf');cls.a=Module.parse(Path(normal['object']).read_bytes());cls.b=Module.parse(Path(cls.r['object']).read_bytes());cls.e=elf(Path(cls.r['object']).with_suffix('.ELF'));cls.planned=p.emit('O035.OBJ',cls.r,cls.root/'planned')
 @classmethod
 def tearDownClass(cls):cls.temp.cleanup()
 def test_source_projection_and_all_fields(self):
  self.assertTrue(self.r['projection']['all102_effective_roles_and_one_private_CALL']);self.assertEqual(self.planned['object_sha256'],'266d9c288fdf9ca81ba1befda66da21e322cefbb40563ec2c43c91da0f544a16');self.assertEqual(len(self.b.fixups),102)
 def test_frame_scope_and_private_coordinates_reject(self):
  for kind in ['frame','scope','coordinate','data','field']:
   b=copy.deepcopy(self.b);e=copy.deepcopy(self.e)
   if kind=='frame':b.fixups[0]=dataclasses.replace(b.fixups[0],frame=1)
   elif kind=='scope':b.publics['_irq_state']=(5,0)
   elif kind=='coordinate':
    for tab in e['symbols'].values():
     for q in tab:
      if q['name']=='_irq_state':q['value']+=1
   elif kind=='data':b.segments[0].data[-1]^=1
   else:b.fixups[0]=dataclasses.replace(b.fixups[0],offset=b.fixups[0].offset+1)
   with self.subTest(kind=kind),self.assertRaises(ValueError):p.check_irq_projection(self.a,b,e)
 def test_actual_CODE_change_after_projection_rejects(self):
  parent=self.root/'postread-race';original=p.check_irq_projection;changed=[]
  def mutate(a,b,e):
   proof=original(a,b,e);obj=next(parent.rglob('IRQ.OBJ'));raw=bytearray(obj.read_bytes());code=bytes(b.segments[0].data);pos=raw.find(code[:24]);self.assertGreaterEqual(pos,0);self.assertEqual(raw.find(code[:24],pos+1),-1);raw[pos]^=1;at=0
   while at<len(raw):
    size=int.from_bytes(raw[at+1:at+3],'little');end=at+3+size
    if at+3<=pos<end-1:raw[end-1]=0;raw[end-1]=(-sum(raw[at:end]))&255;break
    at=end
   else:self.fail('actual native LEDATA record not found')
   obj.write_bytes(raw);fresh=Module.parse(bytes(raw));self.assertNotEqual(fresh.segments[0].data,b.segments[0].data);changed.append(True);return proof
  with mock.patch.object(p,'check_irq_projection',side_effect=mutate),self.assertRaises(ValueError):p.irq_source(self.r['normal_source'],parent)
  self.assertEqual(changed,[True]);self.assertFalse(list(parent.rglob('source-build.json')))
if __name__=='__main__':unittest.main()
