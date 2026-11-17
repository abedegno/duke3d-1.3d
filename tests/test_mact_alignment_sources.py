"""Source-only alignment-preserving ZONE/DEBUG production."""
from pathlib import Path
import importlib.util
import tempfile
import unittest
from unittest.mock import patch
import struct
ROOT=Path(__file__).resolve().parents[1]
CASES={'zone':('ZONE',91,[['.text',0,41],['.data',0,41],['.bss',0,41],['_TEXT',2367,105],['CONST',1427,169],['CONST2',0,169],['_DATA',32,169],['_BSS',48,105]]),
       'debug':('DEBUG',79,[['.text',0,41],['.data',0,41],['.bss',0,41],['_TEXT',1033,105],['CONST',176,169],['CONST2',0,169],['_DATA',152,169],['_BSS',4,105]])}
def load(name):
 spec=importlib.util.spec_from_file_location('mact_'+name+'_elf',ROOT/('tools/build_mact_'+name+'_elf.py'));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
class MactAlignmentSources(unittest.TestCase):
 def test_native_and_closed_elf(self):
  for name,(stem,fields,segments) in CASES.items():
   with self.subTest(module=name),tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
    m=load(name);r=m.build_source(ROOT/'toolchains/gnu-elf-omf',Path(directory));self.assertTrue(r['source_only']);self.assertFalse(r['original_or_target_read_during_production']);self.assertEqual(r['native_fields'],fields);self.assertEqual(r['segments'],segments)
    work=Path(r['object']).parent;raw=(work/(stem+'.ELF')).read_bytes();e=m.elf(work/(stem+'.ELF'));source=(work/'source-only'/(stem+'.S')).read_text();listing=(work/(stem+'.LST')).read_text();h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);bss=next(s['index'] for s in e['sections'] if s['name']=='_BSS');ns={};exec(compile((ROOT/m.CONTRACT).read_bytes(),str(ROOT/m.CONTRACT),'exec'),ns)
    for label,offset,fmt,value in [('machine',18,'H',62),('CODE_align',h[5]+40*4+32,'I',1),('BSS_align',h[5]+40*bss+32,'I',1),('backed_BSS',h[5]+40*bss+4,'I',1)]:
     damaged=bytearray(raw);struct.pack_into('<'+fmt,damaged,offset,value)
     with self.subTest(damage=label),self.assertRaises(ValueError):ns['check'](bytes(damaged),e,source,listing)
 def test_changed_source_before_native(self):
  for name in CASES:
   with self.subTest(module=name),tempfile.TemporaryDirectory(dir=ROOT/'build')as directory:
    m=load(name);old=m.digest
    def changed(p):return'0'*64 if Path(p)==ROOT/m.SOURCE else old(p)
    with patch.object(m,'digest',side_effect=changed),patch.object(m.subprocess,'run')as run:
     with self.assertRaisesRegex(ValueError,'source/contract changed'):m.build_source(ROOT/'toolchains/gnu-elf-omf',Path(directory))
     run.assert_not_called()
if __name__=='__main__':unittest.main()
