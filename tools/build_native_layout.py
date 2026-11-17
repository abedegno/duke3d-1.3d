"""Finite opt-in CODE record layouts over freshly source-built ELF/COFF.

Default source objects and their complete guard receipts remain immutable.
No old OMF is a converter input, no target payload or addresses appear in plans.
"""
from pathlib import Path
import hashlib,json,re,subprocess,sys,tempfile,shutil
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from profiles.gnu_elf_omf_layouts.identity import checked_home,profile
from omf32 import Module
CATALOG='candidates/native_layouts.json'
def need(q,s):
 if not q:raise ValueError('Native layout: '+s)
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,v):Path(p).write_text(json.dumps(v,indent=2,default=str)+'\n')
def unchanged(pins):need(all(Path(p).is_file()and sha(p)==h for p,h in pins.items()),'live/staged/output identity changed')
def parse_plan(text,extent):
 need(type(text)is str and'\x00'not in text,'ASCII plan text');lines=text.splitlines();need(len(lines)>=4 and lines[0]=='OMF_PACKETS_V1'and lines[-1]=='end','closed descriptor grammar');m=re.fullmatch(r'section (_TEXT) ([0-9]+)',lines[1]);need(m is not None,'one exact named CODE section');number=lambda t:int(t)if re.fullmatch(r'[0-9]+',t)and int(t)<=0xffffffff else None;size=number(m[2]);need(size==extent and size>0,'source extent');packets=[];at=0
 for line in lines[2:-1]:
  m=re.fullmatch(r'packet ([0-9]+) ([0-9]+)',line);need(m is not None,'only offset/length CODE metadata');a,n=number(m[1]),number(m[2]);need(a is not None and n is not None and a==at and 0<n<=1022 and a+n<=extent,'bounded contiguous source coverage');packets.append((a,n));at+=n
 need(at==extent,'complete source CODE coverage');return{'section':'_TEXT','extent':extent,'packets':packets}
def read_plan(path,extent):return parse_plan(Path(path).read_text('ascii'),extent)
def catalog_snapshot():
 path=ROOT/CATALOG;raw=path.read_bytes();r=json.loads(raw);pins={str(path):hashlib.sha256(raw).hexdigest()};plans={};need(r['schema']==1 and r['source_credit_added']==0 and r['whole_target_match']is False,'candidate scope');need(len(r['modules'])==22,'finite approved module set')
 for alias,s in r['modules'].items():
  need(re.fullmatch(r'O[0-9]{3}\.OBJ',alias)is not None,'owned alias');need(re.fullmatch(r'src/native_layout/[a-z_0-9]+\.plan',s['plan'])is not None,'closed named source plan');p=ROOT/s['plan'];data=p.read_bytes();digest=hashlib.sha256(data).hexdigest();need(digest==s['plan_sha256'],'declared plan identity');plans[alias]=parse_plan(data.decode('ascii'),s['code_extent']);pins[str(p)]=digest;need(s['target_addresses_or_payload_bytes']is False,'no target/payload plan')
 unchanged(pins);return r,pins,plans
def catalog():return catalog_snapshot()[0]

def check_native(default,planned,plan):
 need(set(vars(default))==set(vars(planned)),'complete native metadata shape')
 for key in vars(default):
  if key!='fixup_encodings':need(getattr(default,key)==getattr(planned,key),'nonpacket native change '+key)
 need(len(default.fixup_encodings)==len(planned.fixup_encodings)==len(planned.fixups),'all native fixup encodings')
 for old,new in zip(default.fixup_encodings,planned.fixup_encodings):
  need({k:v for k,v in old.items()if k not in('raw_bytes','raw_locat')}=={k:v for k,v in new.items()if k not in('raw_bytes','raw_locat')},'complete encoding role except LOCAT');need(old['raw_bytes'][2:]==new['raw_bytes'][2:]and old['raw_locat'][0]&252==new['raw_locat'][0]&252,'only packet-relative LOCAT bits')
  f=planned.fixups[new['fixup']]
  if planned._segment(f.segment).name!='_TEXT':need(old==new,'nonCODE encoding untouched');continue
  span=[(a,n)for a,n in plan['packets']if a<=f.offset and f.offset+f.width<=a+n];need(len(span)==1,'every real field wholly inside one declared span');loc=((new['raw_locat'][0]&3)<<8)|new['raw_locat'][1];need(loc==f.offset-span[0][0],'actual packet-relative field offset')
 return{'all_native_properties_literal_except_packet_LOCAT':True,'all_complete_typed_fields':len(planned.fixups),'all_fields_inside_source_spans':True}

def receipt_pins(receipt):
 """Recheck source/ELF/COFF/native receipts emitted in this invocation."""
 pins={}
 def visit(value):
  if not isinstance(value,dict):return
  for key,item in value.items():
   if isinstance(item,dict):
    if key.endswith('sha256'):
     for name,h in item.items():
      if type(name)is str and Path(name).is_absolute()and type(h)is str and re.fullmatch('[0-9a-f]{64}',h):
       need(name not in pins or pins[name]==h,'conflicting source receipt pin');pins[name]=h
    visit(item)
   elif isinstance(item,list):
    for q in item:visit(q)
 visit(receipt);need(receipt.get('source_only')is True and pins,'fresh source-only normal receipt');unchanged(pins);return pins

def emit(alias,normal,build,*,home=None):
 """Fresh normal source object/ELF comes from the caller's live source API.

 This function is not exposed as an object/receipt-reuse CLI. The normal
 complete-source invocation calls it immediately after source production.
 """
 table,catalog_pins,parsed_plans=catalog_snapshot();need(alias in table['modules'],'finite layout owner');spec=table['modules'][alias];need(spec['source_format']in('elf','coff'),'special source backend required first');home=Path(home or ROOT/'toolchains/gnu-elf-omf-layouts').resolve();tools=checked_home(home);pins=receipt_pins(normal);pins.update(catalog_pins);default=Path(normal['object']).resolve();need(sha(default)==normal['object_sha256'],'normal source object publication');suffix='.ELF'if spec['source_format']=='elf'else'.COFF';source=default.with_suffix(suffix);need(str(source)in pins,'fresh ELF/COFF is a pinned normal producer output');need(source.read_bytes()[:4]==b'\x7fELF'if suffix=='.ELF'else source.read_bytes()[:2]==b'\x4c\x01','actual source compilation format');pins.update({str(home/n):h for n,h in tools.items()});pins.update({str(Path(__file__).resolve()):sha(__file__),str(Path(sys.executable).resolve()):sha(Path(sys.executable).resolve())});normal_raw=default.read_bytes();need(hashlib.sha256(normal_raw).hexdigest()==normal['object_sha256'],'same validated normal RAW snapshot');baseline=Module.parse(normal_raw);plan=parsed_plans[alias];code=[s for s in baseline.segments if s.size and s.class_name.upper()=='CODE'];need(len(code)==1 and code[0].name=='_TEXT'and code[0].size==spec['code_extent'],'exact complete source CODE extent')
 parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='native-layout-',dir=parent));stage=w/'source-only';stage.mkdir();plan_path=stage/'layout.plan';shutil.copyfile(ROOT/spec['plan'],plan_path);staged={str(plan_path):spec['plan_sha256']};unchanged(staged);flags=['-packet-plan='+str(plan_path)]
 if alias=='O071.OBJ':
  group_candidates=[Path(p)for p in pins if p.endswith('/src/game/symbolic/groups.plan')and'/source-only/'in p];need(len(group_candidates)==1,'actual source-owned GAME group plan');groups=stage/'groups.plan';shutil.copyfile(group_candidates[0],groups);staged[str(groups)]=pins[str(group_candidates[0])];flags+=['-group-plan='+str(groups),'-omit-unused-gnu-defaults']

 if alias in('O035.OBJ','O099.OBJ'):
  declared=normal.get('native_layout_converter_flags')
  if alias=='O035.OBJ':declared=['-group-plan='+normal['native_layout_groups_plan']]
  need(type(declared)is list and len(declared)in(1,2),'finite IRQ/DRAM source metadata flags')
  for flag in declared:
   if flag.startswith('-group-plan='):
    source_group=Path(flag.split('=',1)[1]);need(str(source_group)in pins,'pinned actual source groups');groups=stage/'groups.plan';shutil.copyfile(source_group,groups);staged[str(groups)]=pins[str(source_group)];flags.append('-group-plan='+str(groups))
   else:need(alias=='O099.OBJ'and flag=='-omit-unused-gnu-defaults','only actual DRAM default scaffolding option');flags.append(flag)
 unchanged(pins);unchanged(staged);command=[str(home/'bin/objconv'),'-fomf32','-wex',*flags,str(source),str(w/default.name)];p=subprocess.run(command,capture_output=True,text=True);log_raw=(p.stdout+p.stderr).encode();(w/'CONVERT.LOG').write_bytes(log_raw);need(p.returncode==0 and not p.stderr and'warning'not in p.stdout.lower(),'native converter diagnostics');unchanged(pins);unchanged(staged);planned_raw=(w/default.name).read_bytes();planned_sha=hashlib.sha256(planned_raw).hexdigest();planned=Module.parse(planned_raw);proof=check_native(baseline,planned,plan);outputs={str(w/default.name):planned_sha,str(w/'CONVERT.LOG'):hashlib.sha256(log_raw).hexdigest()};unchanged(outputs);need(checked_home(home)==tools,'final complete toolhome namespace');unchanged(pins);unchanged(staged)
 result={'source_only':True,'target_or_original_OMF_input':False,'normal_source':normal,'object':str(w/default.name),'object_sha256':planned_sha,'normal_default_object':str(default),'normal_default_object_sha256':normal['object_sha256'],'descriptor':spec,'proof':proof,'inputs_sha256':pins,'staged_sha256':staged,'outputs_sha256':outputs,'command':command,'source_credit_added':0,'whole_target_match':False};path=w/'source-build.json';receipt_raw=(json.dumps(result,indent=2,default=str)+'\n').encode();dump(path,result)
 try:need(path.read_bytes()==receipt_raw,'same validated receipt RAW');unchanged(pins);unchanged(staged);unchanged(outputs);need(checked_home(home)==tools,'post-receipt toolhome namespace')
 except Exception:path.unlink(missing_ok=True);raise
 return result

def irq_source(normal,build,*,home=None):
 """Reviewed606 mechanical directive-only port of the SAME guarded NASM source."""
 import os
 from profiles.gnu_elf_omf.elf32 import elf
 from tools.probe_actors_composite import checked_nasm
 need(not os.environ.get('NASMENV'),'ambient NASMENV');pins=receipt_pins(normal);default=Path(normal['object']);default_raw=default.read_bytes();need(hashlib.sha256(default_raw).hexdigest()==normal['object_sha256'],'normal IRQ source object');source=Path(normal['native_build_directory'])/'source-only/src/audio/irq_symbolic/IRQ.ASM';need(str(source)in pins,'guarded exact IRQ source stage');source_raw=source.read_bytes();need(hashlib.sha256(source_raw).hexdigest()==pins[str(source)],'same pinned IRQ source RAW');text=source_raw.decode();mappings={'segment _TEXT public align=16 use32 class=CODE':'section _TEXT progbits alloc exec nowrite align=16','segment CONST public align=4 use32 class=DATA':'section CONST progbits alloc noexec write align=4','segment CONST2 public align=4 use32 class=DATA':'section CONST2 progbits alloc noexec write align=4','segment _DATA public align=16 use32 class=DATA':'section _DATA progbits alloc noexec write align=16','segment _BSS public align=16 use32 class=BSS':'section _BSS nobits alloc noexec write align=16'};port=[]
 for line in text.splitlines():
  if line.startswith('group '):continue
  port.append(mappings.get(line,line))
 def body(value):return[line.split(';',1)[0].strip()for line in value.splitlines()if line.split(';',1)[0].strip()and not line.startswith(('segment ','section ','group '))]
 generated='\n'.join(port)+'\n';need(body(generated)==body(text)and all(text.splitlines().count(k)==1 for k in mappings),'only five actual section declarations change')
 home=Path(home or ROOT/'toolchains/gnu-elf-omf-layouts').resolve();tools=checked_home(home);pins.update({str(home/n):h for n,h in tools.items()});binary=ROOT/'toolchains/support/nasm-2.16.03/nasm';checked_nasm(binary);pins[str(binary)]=sha(binary);parent=Path(build);parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='irq-source-elf-',dir=parent));(w/'IRQ-ELF.ASM').write_text(generated);groups=w/'groups.plan';groups.write_text('OMF_GROUPS_V1\ngroup DGROUP CONST CONST2 _DATA _BSS\nflat FLAT\nend\n');stage={str(w/'IRQ-ELF.ASM'):hashlib.sha256(generated.encode()).hexdigest(),str(groups):sha(groups)};unchanged(pins);unchanged(stage)
 command=[str(binary),'-f','elf32','-l',str(w/'IRQ.LST'),'-o',str(w/'IRQ.ELF'),str(w/'IRQ-ELF.ASM')];p=subprocess.run(command,capture_output=True,text=True);(w/'AS.LOG').write_text(p.stdout+p.stderr);need(p.returncode==0 and not(p.stdout or p.stderr),'source-only IRQ ELF diagnostics');unchanged(pins);unchanged(stage);need(not os.environ.get('NASMENV'),'ambient options after source assembly');command2=[str(home/'bin/objconv'),'-fomf32','-wex','-group-plan='+str(groups),str(w/'IRQ.ELF'),str(w/'IRQ.OBJ')];p=subprocess.run(command2,capture_output=True,text=True);(w/'CONVERT.LOG').write_text(p.stdout+p.stderr);need(p.returncode==0 and not p.stderr and'warning'not in p.stdout.lower(),'IRQ default ELF conversion');unchanged(pins);unchanged(stage);raw_outputs={n:(w/n).read_bytes()for n in['IRQ.ELF','IRQ.LST','IRQ.OBJ','AS.LOG','CONVERT.LOG']};outputs={str(w/n):hashlib.sha256(raw).hexdigest()for n,raw in raw_outputs.items()};unchanged(outputs);a=Module.parse(default_raw);b=Module.parse(raw_outputs['IRQ.OBJ']);ev=elf(w/'IRQ.ELF');unchanged(outputs);proof=check_irq_projection(a,b,ev);unchanged(outputs);unchanged(pins);unchanged(stage);need(checked_home(home)==tools,'final source home');result={'source_only':True,'normal_source':normal,'native_build_directory':str(w),'object':str(w/'IRQ.OBJ'),'object_sha256':outputs[str(w/'IRQ.OBJ')],'inputs_sha256':pins,'staged_sha256':stage,'outputs_sha256':outputs,'native_layout_groups_plan':str(groups),'projection':proof,'source_credit_added':0};path=w/'source-build.json';receipt_raw=(json.dumps(result,indent=2,default=str)+'\n').encode();dump(path,result)
 try:need(path.read_bytes()==receipt_raw,'same validated receipt RAW');unchanged(pins);unchanged(stage);unchanged(outputs);need(checked_home(home)==tools,'post-receipt IRQ toolhome namespace');checked_nasm(binary);need(not os.environ.get('NASMENV'),'post-receipt NASMENV')
 except Exception:path.unlink(missing_ok=True);raise
 return result

def check_irq_projection(a,b,e):
 need(a.publics==b.publics and a.local_publics==b.local_publics and a.local_externals==b.local_externals and set(a.externals)==set(b.externals),'IRQ scopes/PUB coordinates/import roles');need([(s.name,s.class_name,s.size,s.attributes,s.access)for s in a.segments]==[(s.name,s.class_name,s.size,s.attributes,s.access)for s in b.segments]and a.groups==b.groups,'IRQ all five segments/groups');fa={(a._segment(f.segment).name,f.offset):f for f in a.fixups};fb={(b._segment(f.segment).name,f.offset):f for f in b.fixups};need(len(fa)==len(a.fixups)==len(fb)==len(b.fixups)==102 and set(fa)==set(fb),'IRQ complete unique102 source fields');covered={s.name:set()for s in a.segments}
 def role(m,f):
  value=(int.from_bytes(m._segment(f.segment).data[f.offset:f.offset+f.width],'little')+f.displacement)&0xffffffff
  if f.target_method==0:return('section',m._segment(f.target).name,value)
  need(f.target_method==2,'IRQ actual target method');return('external',m.externals[f.target-1],value)
 for key,f in fa.items():
  g=fb[key];need((f.width,f.location,f.relative)==(g.width,g.location,g.relative)and role(a,f)==role(b,g),'IRQ effective named/private field role')
  if f.relative:need((f.frame_method,f.frame)==(g.frame_method,g.frame)==(5,None),'IRQ actual near-call F5 frame')
  else:
   flat=next(i for i,(n,_)in enumerate(b.groups,1)if n=='FLAT');dgroup=next(i for i,(n,_)in enumerate(a.groups,1)if n=='DGROUP');need((g.frame_method,g.frame)==(1,flat),'IRQ ELF absolute frame is genuine FLAT');need((f.frame_method,f.frame)==(1,dgroup)or(f.frame_method,f.frame)==(5,None)and f.target_method==0 and a._segment(f.target).name=='_TEXT','IRQ finite original frame projection')
  covered[key[0]].update(range(f.offset,f.offset+f.width))
 for x,y in zip(a.segments,b.segments):need(all(v==z for i,(v,z)in enumerate(zip(x.data,y.data))if i not in covered[x.name]),'IRQ complete nonfield bytes')
 sections={s['index']:s['name']for s in e['sections']};symbols={q['name']:q for tab in e['symbols'].values()for q in tab if q['name']};model_path=ROOT/'src/audio/irq_symbolic/source-model.json';model_raw=model_path.read_bytes();model=json.loads(model_raw);need(hashlib.sha256(model_raw).hexdigest()==sha(model_path),'same IRQ model RAW snapshot')
 for name,(kind,offset)in model['private_source_owners'].items():
  q=symbols[name];need((q['binding'],sections[q['section']],q['value'])==(0,{'CODE':'_TEXT','DATA':'_DATA','BSS':'_BSS'}[kind],offset)and name not in b.publics and name not in b.externals,'IRQ true private source coordinate')
 fields={(sections[r['source_section']],r['offset']):r for r in e['relocations']};need(len(fields)==len(e['relocations'])==102 and set(fields)==set(fb)and all(r['type']in(1,2)for r in fields.values()),'IRQ finite ELF field schema');need(a._segment(1).data[501:506]==b._segment(1).data[501:506],'IRQ resolved private call literal');return{'all102_effective_roles_and_one_private_CALL':True,'all_source_bytes_scopes_geometry_groups_retained':True,'finite_projection':'source filename, imported order, explicit frame/addend representation only'}

def prepare_recipe(normal):
 """Opt-in source compiland substitution; default recipe remains unchanged."""
 import copy
 r=copy.deepcopy(normal);r['owned']=[q for q in r['owned']if q['alias']!='O002.OBJ'];r['link']['files'].remove('O002.OBJ')
 for q in r['owned']:
  if q['alias']in('O001.OBJ','O099.OBJ'):
   actor=q['alias']=='O001.OBJ';q.clear();q.update({'alias':'O001.OBJ'if actor else'O099.OBJ','kind':'api','name':'whole ACTORS source compiland'if actor else'GF1DRAM ELF source backend','module':'tools.build_actors_native'if actor else'tools.build_gf1_dram_elf','function':'build_source','args':[{'tool_home':'gnu-elf-omf-layouts'}],'kwargs':{}})
 r['native_layout']=True;r['expected_native_sha256']='59d14397f95bfd77efea7093e490a955f957a03f3adc6d09c90b6393121f9c3b';r['source_credit_added']=0;r['whole_target_match']=False;return r
