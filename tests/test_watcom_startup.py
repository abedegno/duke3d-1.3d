"""Complete supplied startup envelope; no new native producer or inventory credit."""
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
class Availability(unittest.TestCase):
 def test_separate_startup_envelope_exists(self):
  self.assertTrue((ROOT/'tools/probe_watcom_startup.py').is_file(),'separate startup envelope is missing')

import copy,json,sys,tempfile,os,hashlib,subprocess
from dataclasses import replace
from unittest.mock import patch
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from tools import probe_watcom_startup as c
from le import LEImage

class LedgerTypes(unittest.TestCase):
 def test_numeric_text_and_boolean_cannot_evade_overlap_comparisons(self):
  for key,value in [('object','3'),('start','12'),('end','13'),('object',True),('owner',7)]:
   row={'object':3,'start':12,'end':13,'owner':'held-out'};row[key]=value
   with self.subTest(key=key,value=value),self.assertRaisesRegex(ValueError,'range type'):c.ranges_identity([row])

class NativeEnvelope(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.spec=c.profile();cls.env=c.parse_startup(c.read_member(cls.spec['members']['startup']));cls.m=cls.env.module;cls.image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());cls.work=Path(tempfile.mkdtemp(prefix='startup-tests-',dir=ROOT/'build'))
  audit=Path(os.environ.get('STARTUP_ACCEPTED_RANGES',str(ROOT/'build/startup-accepted-ranges.json')));cls.audit=audit
  cls.report=c.probe(cls.work/'normal',audit);cls.pl={int(n):tuple(v)for n,v in cls.report['placements'].items()};cls.symbols={row['target']:tuple(row['binding'])for row in cls.report['typed_field_bindings']if isinstance(row['target'],str)}
 def test_complete_counts_source_metadata_and_unused_symbols(self):
  r=self.report;v=r['verification'];self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),(755,0,34));self.assertEqual((v['input_stack_bytes'],v['linked_stack_reservation_bytes'],v['linker_stack_enlargement_bytes']),(4096,51200,47104));self.assertEqual(len(r['native_inventory']['segments']),18);self.assertEqual(len(r['source_publics']),11);self.assertEqual(len(v['publics']),9)
  self.assertEqual(set(r['preserved_unbound_zero_publics']),{'__start_TI','__end_TI'});self.assertFalse(set(r['preserved_unbound_zero_publics'])&set(c.external_anchor_bindings(v)));self.assertEqual(r['source_publics']['__start_TI'],[7,0]);self.assertEqual(r['source_publics']['__end_TI'],[9,0]);self.assertEqual(len(r['empty_segments_preserved_without_target_claim']),13)
  self.assertEqual(r['unused_external_declarations'],['__DOSseg__','__FPE_handler','___FPE_handler','__child']);self.assertNotIn('__DOSseg__',v['publics']);self.assertEqual(r['dependency_envelopes']['seg386']['absolute_non_address_publics'],{'__DOSseg__':{'frame':0,'value':0x1234}});p=r['dependency_envelopes']['crwd386']['verification'];self.assertEqual((p['initialized_bytes'],p['verified_fixups']),(66,1));self.assertEqual(r['source_credit'],0);self.assertEqual(r['supplied_runtime_credit'],0)
 def test_envelope_phase_record_and_entry_contract(self):
  q=copy.deepcopy(self.env);q.annotations[0]['pass_two']=False
  with self.assertRaises(ValueError):c.check_inventory(q,self.spec['members']['startup'])
  with self.assertRaises(ValueError):c.check_inventory(replace(self.env,records=self.env.records[:-1]),self.spec['members']['startup'])
  with self.assertRaises(ValueError):c.check_inventory(replace(self.env,entry=None),self.spec['members']['startup'])
  self.assertEqual(b''.join(x['raw_record']for x in self.env.records),c.read_member(self.spec['members']['startup']))
 def test_all_four_initialized_segments_include_annotated_bytes_and_tail(self):
  for number,off in [(1,120),(1,2),(1,726),(2,0),(3,0),(4,3)]:
   m=copy.deepcopy(self.m);m.segments[number-1].data[off]^=1
   with self.subTest(segment=number,offset=off),self.assertRaises(ValueError):c.verify_initialized(m,self.image,self.pl,self.symbols)
 def test_same_DGROUP_requires_explicit_separate_STACK_envelope(self):
  places=copy.deepcopy(self.pl);places.pop(18)
  with self.assertRaisesRegex(ValueError,'group frame member'):c.verify_initialized(self.m,self.image,places,self.symbols)
 def test_closed_profile_and_loaded_helper_identity_reject_before_output(self):
  with patch.object(c,'PROFILE_SHA256','0'*64),self.assertRaisesRegex(ValueError,'closed startup profile'):c.profile()
  with patch.dict(c._LOADED,{'tools/verify_module.py':'0'*64}),self.assertRaisesRegex(ValueError,'changed after loading'):c.probe(self.work/'helper-damage-output',self.audit)
  self.assertFalse((self.work/'helper-damage-output').exists())
 def test_typed_scope_group_empty_and_unknown_metadata_controls(self):
  for name in ['fixup-width','fixup-frame','fixup-target','missing-fixup','local-public','extra-import','group','empty-public','empty-storage','unknown']:
   q=copy.deepcopy(self.env);m=q.module
   if name=='fixup-width':m.fixups[0]=replace(m.fixups[0],width=2)
   elif name=='fixup-frame':m.fixups[0]=replace(m.fixups[0],frame_method=3,frame=1)
   elif name=='fixup-target':m.fixups[0]=replace(m.fixups[0],target=2)
   elif name=='missing-fixup':m.fixups.pop()
   elif name=='local-public':m.local_publics.add('__GETDS')
   elif name=='extra-import':m.externals.append('fake_')
   elif name=='group':m.groups[0][1].append(1) if isinstance(m.groups[0][1],list)else m.groups.__setitem__(0,('DGROUP',(1,)))
   elif name=='empty-public':m.publics['__start_TI']=(9,0)
   elif name=='empty-storage':m.segments[6].size=1;m.segments[6].data.append(0)
   else:m.unknown=True
   with self.subTest(name=name),self.assertRaises(ValueError):c.check_inventory(q,self.spec['members']['startup'])
 def test_stack_source_minimum_and_no_extra_initialized_or_FIXUPP(self):
  for name in ['size','attributes','class','content','fixup','extra-STACK','LEDATA']:
   m=copy.deepcopy(self.m);rs=self.env.records
   if name=='size':m.segments[17].size=4095
   elif name=='attributes':m.segments[17].attributes=0x69
   elif name=='class':m.segments[17].class_name='BSS'
   elif name=='content':m.segments[17].data[0]=1
   elif name=='fixup':m.fixups.append(replace(m.fixups[0],segment=18,offset=0))
   elif name=='extra-STACK':m.segments.append(copy.deepcopy(m.segments[17]))
   else:
    payload=b'\x12\0\0'+bytes(4);raw=bytes([0xa0])+(len(payload)+1).to_bytes(2,'little')+payload;raw+=bytes([-sum(raw)&255]);rs=rs+({'kind':0xa0,'raw_record':raw},)
   with self.subTest(name=name),self.assertRaises(ValueError):c.stack_envelope(m,rs,self.image,self.symbols,self.spec['stack_policy'])
 def test_stack_base_top_object_backing_loader_and_overlap(self):
  for name in ['end','BSSbegin','top','object','extent','policy','backing','loader','overlap']:
   im=copy.deepcopy(self.image);sy=copy.deepcopy(self.symbols);policy=copy.deepcopy(self.spec['stack_policy'])
   if name=='end':sy['_end']=(3,sy['_end'][1]+16)
   elif name=='BSSbegin':sy['_edata']=(3,0xffffffff)
   elif name=='top':im.stack_offset+=16
   elif name=='object':im.stack_object=1
   elif name=='extent':im.objects=tuple(replace(o,size=o.size+16)if i==2 else o for i,o in enumerate(im.objects))
   elif name=='policy':policy['linked_reservation_bytes']=51216
   if name=='backing':
    with patch.object(im,'file_offset',return_value=0),self.assertRaisesRegex(ValueError,'backing'):c.stack_envelope(self.m,self.env.records,im,sy,policy)
   elif name=='loader':
    fake=replace(im.read_fixups()[0],source_object=3,source_offset=self.report['stack']['start'],width=4)
    with patch.object(im,'read_fixups',return_value=[fake]),self.assertRaisesRegex(ValueError,'loader'):c.stack_envelope(self.m,self.env.records,im,sy,policy)
   elif name=='overlap':
    with self.assertRaisesRegex(ValueError,'overlaps'):c.no_overlap(self.report['verified_regions'],[{'owner':'held-out','object':3,'start':self.report['stack']['start']+16,'end':self.report['stack']['start']+17}])
   else:
    with self.subTest(name=name),self.assertRaises(ValueError):c.stack_envelope(self.m,self.env.records,im,sy,policy)
 def test_exact_typed_seg386_not_absolute_RAM_or_default_parser_extension(self):
  raw=c.read_member(self.spec['members']['seg386'])
  with self.assertRaises(c.OMFError):c.Module.parse(raw)
  def damage(kind,change):
   out=[];at=0;done=False
   while at<len(raw):
    end=at+3+int.from_bytes(raw[at+1:at+3],'little');payload=raw[at+3:end-1]
    if raw[at]==kind and not done:payload=change(payload);done=True
    r=raw[at:at+1]+(len(payload)+1).to_bytes(2,'little')+payload;out.append(r+bytes([-sum(r)&255]));at=end
   return b''.join(out)
  for kind,fn in [(0x90,lambda p:p.replace(b'\x34\x12',b'\x35\x12')),(0x88,lambda p:b'\0'+p[1:]),(0x99,lambda p:p[:1]+(1).to_bytes(4,'little')+p[5:]),(0x9a,lambda p:p[:-1]+b'\1')]:
   with self.subTest(kind=kind),self.assertRaises(c.OMFError):c.parse_seg386(damage(kind,fn))
 def test_current_ledger_pin_and_input_race_before_publication(self):
  bad=self.work/'wrong-ranges.json';bad.write_text(json.dumps({'ranges':json.loads(self.audit.read_text())['ranges'][:-2]}))
  with self.assertRaisesRegex(ValueError,'ownership ledger'):c.probe(self.work/'wrong-ledger-output',bad)
  raced=self.work/'raced-ranges.json';raced.write_bytes(self.audit.read_bytes());read=c.read_member
  def changed(spec):
   value=read(spec);raced.write_bytes(self.audit.read_bytes()+b'\n');return value
  with patch.object(c,'read_member',side_effect=changed),self.assertRaisesRegex(ValueError,'changed during'):c.probe(self.work/'race-output',raced)
  self.assertFalse((self.work/'race-output').exists())

class ExistingNativeStackWitnesses(unittest.TestCase):
 """Observe frozen327/374 execution receipts; never rebuild or execute them."""
 PINS={'stack4096/MAIN.C': '8ac41de9af2a79daea32e4d833a90f5d62d712e04ecf23b6313baed3614c58bd', 'stack4096/DOUBLE.C': '63554225ed390ccffac95c8bf2d899dddda03900bdc106b69cff8876d4ecae2c', 'stack4096/OWNCALL.ASM': 'e8be13a588a6d488938a1becd77059fe7c568e07bda06d5fbfdacef3f54a5e04', 'stack4096/MAIN.OBJ': '81db804dd2d66753ecfe67c0a4a74749ed5346711e58835522b63eedd1f589c2', 'stack4096/DOUBLE.OBJ': '9c0f7fb2db87b18a56fc338cc3b2e368859a3aaf1e152fbe2f7b3cb48cb802a5', 'stack4096/OWNCALL.OBJ': '155b72a983f87e17b2aea88a4a608f33c75be3ae814a34288ca94dd3bf9237a1', 'stack4096/OWN.EXE': 'a5ff99b08f48181cc1cd136a87092dbc08ec14e8ab29f40b1648ca645201854c', 'stack4096/OWN.MAP': 'ec52efcaa5efdca4e855b140c4eed751be5ab175d5ae2e95700c53bffaccd15e', 'stack4096/OWN.LNK': '97db267370e3273d1a0de4e641e746ddd0245e7f8e6d152d2c1eb7421eaf3561', 'stack4096/STATUS.TXT': 'ec07ba3f63b6b32cb664153362e9a56a6ddab4142db2397eba08ddd8aba82968', 'stack50k/MAIN.C': '8ac41de9af2a79daea32e4d833a90f5d62d712e04ecf23b6313baed3614c58bd', 'stack50k/DOUBLE.C': '63554225ed390ccffac95c8bf2d899dddda03900bdc106b69cff8876d4ecae2c', 'stack50k/OWNCALL.ASM': 'e8be13a588a6d488938a1becd77059fe7c568e07bda06d5fbfdacef3f54a5e04', 'stack50k/MAIN.OBJ': '81db804dd2d66753ecfe67c0a4a74749ed5346711e58835522b63eedd1f589c2', 'stack50k/DOUBLE.OBJ': '9c0f7fb2db87b18a56fc338cc3b2e368859a3aaf1e152fbe2f7b3cb48cb802a5', 'stack50k/OWNCALL.OBJ': '155b72a983f87e17b2aea88a4a608f33c75be3ae814a34288ca94dd3bf9237a1', 'stack50k/OWN.EXE': '9704f31d26e33a77f39cb9be6ff4217ac2aad10e5a92c75b4cf28e67c4455076', 'stack50k/OWN.MAP': '259ee2c43941b01ef49d4e6c37239e5c6f1023fb7f591a7b9c97e33602591bc8', 'stack50k/OWN.LNK': '2365a98a552191333be1b29daa1e1541b8aebb38e9b9322d2d06d6a67196bf4f', 'stack50k/STATUS.TXT': 'ec07ba3f63b6b32cb664153362e9a56a6ddab4142db2397eba08ddd8aba82968'}
 def test_documented_single_STACK_enlargement_existing_native_evidence(self):
  import re
  root=Path(os.environ.get('STARTUP_NATIVE_WITNESSES',str(ROOT/'build/startup-native-witnesses')))
  for name,digest in self.PINS.items():
   self.assertEqual(hashlib.sha256((root/name).read_bytes()).hexdigest(),digest,name)
  for name in ['MAIN.C','DOUBLE.C','OWNCALL.ASM','MAIN.OBJ','DOUBLE.OBJ','OWNCALL.OBJ']:
   self.assertEqual((root/'stack4096'/name).read_bytes(),(root/'stack50k'/name).read_bytes())
  old=(root/'stack4096/OWN.LNK').read_bytes();new=(root/'stack50k/OWN.LNK').read_bytes()
  self.assertEqual(old.replace(b'stack=4096',b'stack=50k'),new)
  images=[]
  for label,size in [('stack4096',4096),('stack50k',51200)]:
   self.assertEqual((root/label/'STATUS.TXT').read_text().strip(),'EXIT42')
   rows=re.findall(r'^STACK\s+STACK\s+DGROUP\s+([0-9a-f]+):([0-9a-f]+)\s+([0-9a-f]+)',(root/label/'OWN.MAP').read_text(),re.M|re.I)
   self.assertEqual(len(rows),1);self.assertEqual(tuple(int(v,16)for v in rows[0]),(2,112,size))
   image=LEImage.parse((root/label/'OWN.EXE').read_bytes());images.append(image)
   self.assertEqual((image.stack_object,image.stack_offset),(2,112+size));self.assertEqual(image._object(2).size,112+size)
   self.assertTrue(all(image.file_offset(2,p)is None for p in range(112,112+size)))
  self.assertEqual(images[0].object_bytes(1),images[1].object_bytes(1))

if __name__=='__main__':unittest.main()
