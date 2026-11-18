"""Closed native GAME linker regression suite (normal and optimized Python)."""
from pathlib import Path
from dataclasses import replace
import sys,json,unittest,copy
HERE=Path(__file__).resolve().parent;R=HERE.parent
sys.path[:0]=[str(HERE),str(R),str(R/'profiles/watcom/tools')]
from tools import game_omf_link as link
from omf32 import Module,Cursor

def rewrite(raw,fn):
 return b''.join(link.record(t,p)for i,(t,p)in enumerate(link.records(raw))for t,p in fn(i,t,p))
def replace_string(raw,old,new):
 # All tested names have a one-byte OMF name length.
 a,b=link.name(old),link.name(new)
 return rewrite(raw,lambda i,t,p:[(t,p.replace(a,b))])
class NativeGame(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools.build_game_c import build_source
  result=build_source(R/'toolchains/watcom-10.0-ga',R/'build/game-linker-tests')
  cls.result=result
  work=Path(result['directory'])
  cls.c=(work/'C.OBJ').read_bytes();cls.a=(work/'ASM.OBJ').read_bytes()
  cls.d=json.loads((R/'src/game/game_private_imports.json').read_text())
  cls.b=json.loads((R/'src/game/game_text_model.json').read_text())
 def run_link(self,c=None,a=None,d=None,b=None):return link.coalesce(self.c if c is None else c,self.a if a is None else a,self.d if d is None else d,self.b if b is None else b)
 def reject(self,**kw):
  with self.assertRaises((ValueError,IndexError,KeyError)):self.run_link(**kw)
 def test_complete_native_roundtrip(self):
  m,comments,receipt=self.run_link();out=link.serialize(m,comments);link.verify_roundtrip(m,out)
  self.assertEqual([s.size for s in m.segments],[84142,4274,0,864,4160]);self.assertEqual(len(m.fixups),5020)
  self.assertEqual(len([n for n in m.local_publics if n.startswith('_game_text_')]),140)
  self.assertEqual(len([i for i in m.local_externals if m.externals[i-1].startswith('_game_text_')]),140)
  self.assertEqual(m.far_call_optimization_segments,[1]*4);self.assertEqual(m.groups,[('DGROUP',(2,3,4,5)),('FLAT',())])
  self.assertEqual(len(receipt['external_maps']),len(Module.parse(self.c).externals)+len(Module.parse(self.a).externals))
  runs=[r for r in receipt['initialized_records']if r['record_type']=='0xa3'];self.assertEqual(len(runs),6);self.assertEqual(sum(r['expanded_bytes']for r in receipt['initialized_records']),89280)
  self.assertTrue(all(r['native_name'].startswith(link.PREFIX) for r in receipt['external_maps']if r['native_scope']=='GLOBAL undefined transport'))
  self.assertFalse(any(n.startswith(link.PREFIX)for n in [*m.publics,*m.externals]));self.assertEqual(len(receipt['aliases']),17)
 def test_production_native_layout_conserves_all_fields(self):
  from tools.build_native_layout import emit
  result=emit('O071.OBJ',self.result,R/'build/game-linker-tests')
  self.assertEqual(result['proof']['all_complete_typed_fields'],5020)
  self.assertEqual(result['tail_object'],self.result['tail_object'])
 def test_closed_declaration_mutations(self):
  mutations=[('unit','OTHER'),('input_roles',['c','outsider']),('reserved_prefix','__OTHER_')]
  for key,value in mutations:
   with self.subTest(key=key):d=copy.deepcopy(self.d);d[key]=value;self.reject(d=d)
  rowchanges=[('owner','_game_text_checkcommandline_1464'),('owner','_numplayers'),('owner_scope','PUBDEF'),('input_role','outsider'),('owner_input','assembly'),('owner_segment',2),('owner_segment_size',0),('offset',0),('capacity',31),('source_name','game_text_spawn_440')]
  for key,value in rowchanges:
   with self.subTest(key=key,value=value):d=copy.deepcopy(self.d);d['aliases'][0][key]=value;self.reject(d=d)
  d=copy.deepcopy(self.d);d['aliases'].append(d['aliases'][0]);self.reject(d=d)
  d=copy.deepcopy(self.d);d['aliases'].pop();self.reject(d=d)
 def test_duplicate_json_keys(self):
  for raw in ['{"schema":1,"schema":1}','{"aliases":[{"owner":"x","owner":"y"}]}']:
   with self.assertRaisesRegex(ValueError,'duplicate'):link.load_json(raw)
 def test_ordinary_global_spelling_private_owner(self):
  for row in self.d['aliases'][:2]:self.reject(a=replace_string(self.a,row['alias'],row['owner']))
 def test_undeclared_reserved_import(self):
  row=self.d['aliases'][0];self.reject(a=replace_string(self.a,row['alias'],link.PREFIX+'outsider'))
 def test_alias_on_c_side(self):
  self.reject(c=replace_string(self.c,'_game_text_getpackets_0',self.d['aliases'][0]['alias']))
 def test_reserved_definition(self):
  self.reject(a=replace_string(self.a,'spawn_',self.d['aliases'][0]['alias']))
 def test_owner_scope_promotion(self):
  self.reject(c=rewrite(self.c,lambda i,t,p:[(0x91 if t==0xb7 else t,p)]))
 def test_missing_owner(self):
  self.reject(c=replace_string(self.c,self.d['aliases'][0]['owner'],'_missing_private'))
 def test_duplicate_owner(self):
  first=next((t,p)for t,p in link.records(self.c)if t==0xb7)
  self.reject(c=rewrite(self.c,lambda i,t,p:[(t,p),first]if (t,p)==first else[(t,p)]))
 def test_local_global_name_collision(self):
  c=Module.parse(self.c);local=c.externals[next(iter(c.local_externals))-1];globalname=next(n for i,n in enumerate(c.externals,1)if i not in c.local_externals)
  self.reject(c=replace_string(self.c,globalname,local))
 def test_missing_import(self):
  first=True
  def fn(i,t,p):
   nonlocal first
   if t==0x8c and first:first=False;return []
   return[(t,p)]
  self.reject(a=rewrite(self.a,fn))
 def test_unused_alias(self):
  mods=[Module.parse(self.c),Module.parse(self.a)];a=mods[1];alias=self.d['aliases'][0]['alias'];index=a.externals.index(alias)+1
  a.fixups=[replace(f,target=next(i for i,n in enumerate(a.externals,1)if not n.startswith(link.PREFIX)))if f.target_method==2 and f.target==index else f for f in a.fixups]
  self.reject(a=link.serialize(a,[]))
 def test_lidata_damage(self):
  for position,value in [(9,1),(12,1)]:
   # Position 9 changes nesting; final byte changes observed literal from zero.
   first=True
   def fn(i,t,p):
    nonlocal first
    if t==0xa3 and first:
     first=False;q=bytearray(p);q[position]=value;return[(t,bytes(q))]
    return[(t,p)]
   with self.subTest(position=position):self.reject(c=rewrite(self.c,fn))
 def test_missing_bytes_bss_metadata_and_overlap(self):
  dropped=False
  def fn(i,t,p):
   nonlocal dropped
   if t==0xa1 and not dropped:dropped=True;return[]
   return[(t,p)]
  self.reject(c=rewrite(self.c,fn))
  self.reject(c=rewrite(self.c,lambda i,t,p:[(t,p),(t,p)]if t==0xa3 else[(t,p)]))
  self.reject(c=rewrite(self.c,lambda i,t,p:[]if t==0x88 and p[:2]==b'\x80\xfd' else[(t,p)]))
  m,cc,r=self.run_link();m.segments[4].size-=1
  with self.assertRaises(ValueError):link.verify_roundtrip(self.run_link()[0],link.serialize(m,cc))
 def test_raw_erased_metadata(self):
  def type_nonzero(i,t,p):return[(t,p[:-1]+b'\1')]if t in(0x8c,0xb4)else[(t,p)]
  self.reject(c=rewrite(self.c,type_nonzero))
  self.reject(c=rewrite(self.c,lambda i,t,p:[(t,p[:-1]+b'\2')]if t==0x99 else[(t,p)]))
 def test_field_damage_roundtrip_mismatch(self):
  original,cc,r=self.run_link();target=next(i for i,f in enumerate(original.fixups)if f.target_method==2 and original.externals[f.target-1].startswith('_game_text_checkcommandline_'))
  for kw in [dict(displacement=1),dict(relative=True),dict(frame_method=1,frame=2),dict(target=1)]:
   with self.subTest(kw=kw):
    m=copy.deepcopy(original);m.fixups[target]=replace(m.fixups[target],**kw)
    with self.assertRaises(ValueError):link.verify_roundtrip(original,link.serialize(m,cc))
  for kw in [dict(width=2),dict(location=1)]:
   with self.subTest(kw=kw):
    m=copy.deepcopy(original);m.fixups[target]=replace(m.fixups[target],**kw)
    with self.assertRaises(ValueError):link.verify_roundtrip(original,link.serialize(m,cc))
 def test_output_scope_promotion_aliases_missing_fields_bytes(self):
  original,cc,r=self.run_link()
  for damage in ['scope','alias','fields','bytes']:
   with self.subTest(damage=damage):
    m=copy.deepcopy(original)
    if damage=='scope':m.local_publics.remove(self.d['aliases'][0]['owner'])
    elif damage=='alias':m.externals[0]=link.PREFIX+'leftover'
    elif damage=='fields':m.fixups.pop()
    else:m.segments[0].data[0]^=1
    with self.assertRaises(ValueError):link.verify_roundtrip(original,link.serialize(m,cc))
 def test_split_relocation(self):
  m,cc,r=self.run_link();f=m.fixups[0];split=f.offset+1
  spans=[(0,split)];at=split
  while at<m.segments[0].size:n=min(1024,m.segments[0].size-at);spans.append((at,n));at+=n
  with self.assertRaises(ValueError):link.serialize(m,cc,spans)
 def test_companion_alias_cannot_claim_local_scope(self):
  self.reject(a=rewrite(self.a,lambda i,t,p:[(0xb4 if t==0x8c else t,p)]))
 def test_cross_section_relative_fields_and_modular_addends(self):
  native=Module.parse(self.a);cross=[f for f in native.fixups if f.target_method==0 and f.relative]
  self.assertEqual(len(cross),2)
  m,cc,r=self.run_link();maps={row['source_segment']:(row['output_segment'],row['output_offset'])for row in r['contributions']if row['input']=='assembly'}
  for f in cross:
   source,base=maps[f.segment];target,tbase=maps[f.target];linked=next(z for z in m.fixups if z.segment==source and z.offset==base+f.offset)
   self.assertEqual((linked.relative,linked.frame_method,linked.frame,linked.target_method,linked.target,linked.displacement),(True,1,2,0,target,(f.displacement+tbase)&0xffffffff))
  f=cross[0];which=native.fixups.index(f);native.fixups[which]=replace(f,displacement=0xfffffff0)
  changed=rewrite(link.serialize(native,[]),lambda i,t,p:[]if t==0x88 and p[:2]==b'\x80\xa2'else[(t,p)]);actual,_,_=self.run_link(a=changed);source,base=maps[f.segment];target,tbase=maps[f.target];linked=next(z for z in actual.fixups if z.segment==source and z.offset==base+f.offset)
  self.assertEqual(linked.displacement,(0xfffffff0+tbase)&0xffffffff)
 def test_third_input_rejected(self):
  with self.assertRaises(TypeError):link.coalesce(self.c,self.a,self.d,self.b,self.c)
class FreshFixture(unittest.TestCase):
 def test_native_ga_asm_wlink_private_owner_fixture(self):
  import game_omf_native_fixture as native_fixture
  directory=native_fixture.produce();receipt=json.loads((directory/'receipt.json').read_text());self.assertEqual(len(receipt['aliases']),2)
  self.assertEqual(len(receipt['native_fixture_values']),3)
if __name__=='__main__':unittest.main()
