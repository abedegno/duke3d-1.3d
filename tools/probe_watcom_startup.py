"""Opt-in supplied startup emitted-byte and single-STACK envelope, not inventory credit.

Default parsing/inference/verification are untouched. Full stock members are read
unmodified; no source/compiler/linker is run, and no input records are rewritten.
"""
from pathlib import Path
from dataclasses import asdict,is_dataclass
import argparse,hashlib,json,sys,tempfile
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from omf32 import Module,Cursor,parse_startup,OMFError
from le import LEImage
from tools.infer_bindings import infer_bindings
from tools.verify_module import verify_module,external_anchor_bindings
from tools.match_function import compare_range
PROFILE='profiles/watcom/startup-profile.json'
PROFILE_SHA256='1164f1ea79d039254b3fb438606b7faa75cb3b16a547379be9742f02ff22743c'
TARGET_SHA256='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'
HELPERS=['tools/probe_watcom_startup.py',PROFILE,'profiles/watcom/tools/omf32.py',
 'profiles/watcom/tools/le.py','profiles/watcom/tools/runner.py','tools/match_function.py','tools/infer_bindings.py','tools/verify_module.py',
 'tools/inventory_watcom_runtime.py','tools/watcom_runtime_105.py','tools/prove_module.py','tools/object_contributions.py','tools/preserve.py']
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
_LOADED={p:sha(ROOT/p)for p in HELPERS if p!=PROFILE}
def encoded(v):
 if is_dataclass(v):return encoded(asdict(v))
 if isinstance(v,(bytes,bytearray)):return {'hex':bytes(v).hex()}
 if isinstance(v,dict):return {k:encoded(x)for k,x in v.items()}
 if isinstance(v,(set,list,tuple)):return [encoded(x)for x in(sorted(v)if isinstance(v,set)else v)]
 return v
def inventory(m):
 if set(vars(m))!=set(vars(Module())):raise ValueError('unknown startup module metadata')
 return {**{k:encoded(v)for k,v in vars(m).items()if k!='segments'},'segments':[
  {'name':s.name,'class':s.class_name,'size':s.size,'attributes':s.attributes,'access':s.access}for s in m.segments]}
def ranges_identity(ranges):
 if any(any(type(r[k])is not int for k in ['object','start','end'])or type(r['owner'])is not str for r in ranges):raise ValueError('invalid accepted range type')
 rows=sorted((int(r['object']),int(r['start']),int(r['end']),str(r['owner']))for r in ranges)
 if any(o<=0 or a<0 or z<a for o,a,z,n in rows):raise ValueError('invalid accepted range')
 return hashlib.sha256(json.dumps(rows,separators=(',',':')).encode()).hexdigest()
def profile():
 p=ROOT/PROFILE
 raw=p.read_bytes()
 if hashlib.sha256(raw).hexdigest()!=PROFILE_SHA256:raise ValueError('changed closed startup profile')
 return json.loads(raw)
def read_member(spec):
 p=ROOT/spec['library'];raw=p.read_bytes()
 if hashlib.sha256(raw).hexdigest()!=spec['library_sha256']:raise ValueError('changed startup dependency library')
 member=raw[spec['offset']:spec['offset']+spec['size']]
 if hashlib.sha256(member).hexdigest()!=spec['sha256']:raise ValueError('changed complete startup dependency')
 return member

def parse_seg386(raw):
 """Exact typed zero-runtime DOSSEG member; no absolute-public default extension."""
 expected=[0x80,0x88,0x96,0x99,0x99,0x9a,0x90,0x88,0x8a]
 # Nine records: header/directive/names/two SEGDEF/group/ABS/separator/MODEND.
 pos=0;rows=[];values=[]
 while pos<len(raw):
  if pos+3>len(raw):raise OMFError('truncated seg386 record')
  size=int.from_bytes(raw[pos+1:pos+3],'little');end=pos+3+size
  if not size or end>len(raw)or sum(raw[pos:end])&255:raise OMFError('invalid seg386 checksum/extent')
  rows.append({'ordinal':len(rows),'offset':pos,'kind':raw[pos],'bytes':end-pos,'sha256':hashlib.sha256(raw[pos:end]).hexdigest()});values.append(raw[pos+3:end-1]);pos=end
 if [r['kind']for r in rows]!=expected:raise OMFError('unmeasured seg386 record inventory')
 c=Cursor(values[0]);name=c.name()
 if name!='seg386'or c.left():raise OMFError('changed seg386 module name')
 if values[1]!=b'\x80\x9e':raise OMFError('missing exact DOSSEG directive')
 c=Cursor(values[2]);names=['']
 while c.left():names.append(c.name())
 if names!=['','','CODE','_TEXT','DATA','_DATA','DGROUP']:raise OMFError('changed seg386 names')
 segs=[]
 for payload in values[3:5]:
  c=Cursor(payload);attr=c.uint(1);size=c.uint(4);n,k,o=c.index(),c.index(),c.index()
  if c.left()or attr!=0x49 or size or o!=1:raise OMFError('seg386 must remain zero-runtime')
  segs.append({'name':names[n]if n<len(names)else None,'class':names[k]if k<len(names)else None,'attributes':attr,'size':size})
 if segs!=[{'name':'_TEXT','class':'CODE','attributes':73,'size':0},{'name':'_DATA','class':'DATA','attributes':73,'size':0}]:raise OMFError('changed seg386 empty geometry')
 c=Cursor(values[5])
 if(c.index(),c.uint(1),c.index(),c.left())!=(6,255,2,0):raise OMFError('changed seg386 DGROUP')
 c=Cursor(values[6]);group,segment=c.index(),c.index();frame=c.uint(2);symbol=c.name();value=c.uint(2);type_index=c.index()
 if(group,segment,frame,symbol,value,type_index,c.left())!=(0,0,0,'__DOSseg__',0x1234,0,0):raise OMFError('changed non-address DOSSEG ABS definition')
 if values[7]!=b'\0\xa2\1'or values[8]!=b'\0':raise OMFError('changed seg386 pass/end framing')
 return {'name':name,'segments':segs,'groups':[['DGROUP',[2]]],'absolute_non_address_publics':{symbol:{'frame':frame,'value':value}},'DOSSEG_flags':128,'runtime_bytes':0,'fixups':0,'records':rows}

def check_inventory(envelope,spec):
 m=envelope.module
 if envelope.profile!=spec['reader_profile'] or not isinstance(envelope.entry,dict):raise ValueError('changed startup envelope profile/entry')
 annotations=[{k:encoded(v)for k,v in a.items()if k not in ['raw_record','record_offset','record_ordinal']}for a in envelope.annotations]
 records=[{'ordinal':r['ordinal'],'offset':r['offset'],'kind':r['kind'],'bytes':len(r['raw_record'])}for r in envelope.records]
 if annotations!=spec['annotations'] or records!=spec['record_inventory']:raise ValueError('changed complete startup phase/record inventory')
 if inventory(m)!=spec['native_inventory']:raise ValueError('changed complete startup scope/metadata/typed inventory')
 entry={k:encoded(v)for k,v in envelope.entry.items()if k not in ['raw_record','record_offset','record_ordinal']}
 if entry!=spec['entry']:raise ValueError('changed startup entry metadata')
 if any(len(s.data)!=s.size for s in m.segments):raise ValueError('incomplete startup backing model')
 return m

def derive_fields(m,image,code_anchor):
 if m.publics.get('__GETDS')!=(1,716)or '__GETDS'in m.local_publics:raise ValueError('changed startup GETDS scope')
 obj,base=code_anchor[0],code_anchor[1]-716
 if(obj,base)!=(image.entry_object,image.entry_offset):raise ValueError('entry contradicts independent GETDS')
 places={1:(obj,base)};symbols={};edges=[];loads={(f.source_object,f.source_offset):f for f in image.read_fixups()}
 def put(d,k,v):
  if k in d and d[k]!=v:raise ValueError('contradictory startup field binding')
  d[k]=v
 for f in m.fixups:
  if f.segment!=1 or f.width!=4 or f.location!=9 or f.displacement:raise ValueError('unsupported startup field')
  at=base+f.offset;add=int.from_bytes(m.segments[0].data[f.offset:f.offset+4],'little');loader=loads.get((obj,at))
  if f.relative:
   if loader is not None:raise ValueError('unexpected startup relative loader')
   value=(obj,at+4+int.from_bytes(image.object_bytes(obj)[at:at+4],'little',signed=True)-add)
  else:
   if loader is None or(loader.source_type,loader.width,loader.alias)!=(7,4,False):raise ValueError('missing typed startup absolute field')
   value=(loader.target_object,loader.target_offset-add)
  key=m.externals[f.target-1]if f.target_method==2 else f.target
  if f.target_method not in(0,2):raise ValueError('unsupported startup target method')
  put(symbols if f.target_method==2 else places,key,value);edges.append({'field':f.offset,'target':key,'binding':value,'relative':f.relative})
 if set(places)!={1,2,3}:raise ValueError('incomplete emitted startup placements')
 return places,symbols,edges

def stack_envelope(m,records,image,symbols,policy,other_modules=()):
 if [n for n,s in enumerate(m.segments,1)if s.class_name=='STACK']!=[18]or any(s.class_name=='STACK'for x in other_modules for s in x.segments):raise ValueError('unsupported extra STACK input')
 s=m.segments[17]
 if(s.name,s.class_name,s.attributes,s.size,len(s.data))!=('STACK','STACK',0x75,4096,4096)or any(s.data):raise ValueError('changed measured uninitialized STACK input')
 if any(f.segment==18 or(f.target_method==0 and f.target==18)or(f.frame_method==0 and f.frame==18)for f in m.fixups):raise ValueError('unmeasured STACK fixup')
 for r in records:
  if r['kind']in(0xa0,0xa1,0xa2,0xa3)and Cursor(r['raw_record'][3:-1]).index()==18:raise ValueError('STACK has initialized data record')
 end_obj,end=symbols['_end'];begin_obj,begin=symbols['_edata'];start=(end+15)&~15;top=image.stack_offset
 if end_obj!=3 or begin_obj!=3 or not 0<=begin<=end<=start<top or image.stack_object!=3:raise ValueError('invalid linker BSS/STACK envelope')
 if(image._object(3).base+start)%16 or top-start!=policy['linked_reservation_bytes']or policy['input_bytes']!=4096 or policy['linked_reservation_bytes']!=51200:raise ValueError('changed single-STACK size/alignment policy')
 if top!=image._object(3).size:raise ValueError('STACK top must equal measured object extent')
 if any(image.file_offset(3,p)is not None for p in range(start,top)):raise ValueError('STACK reservation has file backing')
 if any(f.source_object==3 and f.source_offset<top and start<f.source_offset+f.width for f in image.read_fixups()):raise ValueError('STACK reservation has loader writes')
 return {'input_stack_bytes':4096,'linked_stack_reservation_bytes':51200,'linker_stack_enlargement_bytes':47104,'object':3,'start':start,'end':top,'linker_BSS_begin':begin,'linker_BSS_end':end,'file_backing':False,'loader_writes':False,'runtime_usable_call_stack_size_claimed':False}

def no_overlap(regions,accepted):
 for i,r in enumerate(regions):
  for other in regions[:i]+accepted:
   if r['object']==other['object']and r['start']<other['end']and other['start']<r['end']:raise ValueError('startup/dependency/STACK overlaps '+str(other.get('owner','another contribution')))

def verify_initialized(m,image,places,symbols):
 reports=[]
 for n in [1,2,3,4]:
  s=m.segments[n-1];obj,start=places[n];alignment={1:1,2:2,3:16,4:256,5:4}.get(s.attributes>>5)
  if alignment is None or(image._object(obj).base+start)%alignment or start<0 or start+s.size>image._object(obj).size:raise ValueError('startup initialized extent/alignment')
  p=compare_range(m,n,0,image,obj,start,s.size,symbols,places,group_frames={1:(3,0)},label=s.name)
  if not p['match']:raise ValueError('startup initialized bytes differ: '+s.name)
  reports.append(p)
 if(sum(p['compared_bytes']for p in reports),sum(p['verified_fixups']for p in reports))!=(755,34):raise ValueError('incomplete startup initialized proof')
 return reports

def replay_dependencies(image,spec):
 em=Module.parse(read_member(spec['emu387']));b=infer_bindings(em,image,1,spec['emu387']['code_offset']);p=verify_module(em,image,b['placements'],b['symbols'],group_frames=spec['emu387']['group_frames'])
 if(p['initialized_bytes'],p['zero_fill_bytes'],p['verified_fixups'])!=(12960,0,692):raise ValueError('incomplete fresh EMU anchor proof')
 anchors=external_anchor_bindings(p);crwd=Module.parse(read_member(spec['crwd386']))
 if inventory(crwd)!=spec['crwd386']['native_inventory']:raise ValueError('changed complete crwd metadata')
 f=crwd.fixups[0];data_base=anchors['___FPE_handler'][1]-crwd.publics['___FPE_handler'][1];point=data_base+f.offset;load=[x for x in image.read_fixups()if(x.source_object,x.source_offset)==(3,point)]
 if len(load)!=1 or(load[0].source_type,load[0].width,load[0].target_object,load[0].alias)!=(7,4,1,False):raise ValueError('missing crwd code-pointer anchor')
 code=load[0].target_offset-int.from_bytes(crwd.segments[1].data[f.offset:f.offset+4],'little');pl={1:(1,code),2:(3,data_base)};cp=verify_module(crwd,image,pl,{'___FPE_handler':tuple(anchors['___FPE_handler'])})
 if(cp['initialized_bytes'],cp['zero_fill_bytes'],cp['verified_fixups'])!=(66,0,1):raise ValueError('incomplete crwd dependency proof')
 seg=parse_seg386(read_member(spec['seg386']))
 return anchors,crwd,pl,{'emu387':{'verification':p,'placements':b['placements']},'crwd386':{'verification':cp,'placements':pl},'seg386':seg}

def probe(build,accepted_ranges):
 if any(sha(ROOT/p)!=v for p,v in _LOADED.items()):raise ValueError('startup helper changed after loading')
 spec=profile();target=ROOT/'reference/DUKE3D.EXE';audit=Path(accepted_ranges).resolve()
 from tools.inventory_watcom_runtime import inventory as stock_inventory,LIBRARIES
 paths={ROOT/p for p in HELPERS};paths|={ROOT/p for p in LIBRARIES};paths.add(ROOT/'evidence/watcom_rand-module.json');paths|={ROOT/v['library']for v in spec['members'].values()};paths|={target,audit};before={str(p):sha(p)for p in paths}
 target_raw=target.read_bytes()
 if hashlib.sha256(target_raw).hexdigest()!=TARGET_SHA256:raise ValueError('changed startup target')
 accepted=json.loads(audit.read_text())['ranges']
 if len(accepted)!=spec['source_ranges']['count']or ranges_identity(accepted)!=spec['source_ranges']['identity']:raise ValueError('changed reviewed source ownership ledger')
 image=LEImage.parse(target_raw);anchors,crwd,crwd_places,deps=replay_dependencies(image,spec['members']);env=parse_startup(read_member(spec['members']['startup']));m=check_inventory(env,spec['members']['startup']);places,symbols,edges=derive_fields(m,image,anchors['__GETDS'])
 # DOSSEG metadata and installed linker/own MAP evidence justify the first BEGDATA coordinate.
 if deps['seg386']['DOSSEG_flags']!=128 or (m.segments[3].name,m.segments[3].class_name,bytes(m.segments[3].data))!=('_NULL','BEGDATA',b'\1\1\1\0'):raise ValueError('changed measured DOSSEG/NULL obligation')
 places[4]=(3,0);stack=stack_envelope(m,env.records,image,symbols,spec['stack_policy'],(crwd,));places[18]=(3,stack['start']);proofs=verify_initialized(m,image,places,symbols)
 known={n:(places[s][0],places[s][1]+o)for n,(s,o)in m.publics.items()if s in places};unbound={n:{'source_segment':s,'source_offset':o,'target_address_asserted':False}for n,(s,o)in m.publics.items()if s not in places}
 if set(unbound)!={'__start_TI','__end_TI'}or any(m.segments[v['source_segment']-1].size for v in unbound.values()):raise ValueError('unexpected unbound source public')
 regions=[{'owner':'startup:'+m.segments[n-1].name,'object':places[n][0],'start':places[n][1],'end':places[n][1]+m.segments[n-1].size}for n in [1,2,3,4]]+[{'owner':'linker:single-STACK','object':3,'start':stack['start'],'end':stack['end']}]+[{'owner':'dependency:crwd386','object':o,'start':a,'end':a+crwd.segments[n-1].size}for n,(o,a)in crwd_places.items()]
 # Accepted supplied anchors are freshly replayed; existing global vendor/source overlaps elsewhere are not reclassified here.
 supplied=stock_inventory(image.data,{n:(ROOT/n).read_bytes()for n in LIBRARIES},{'ranges':[]})
 if len(supplied['components'])!=134:raise ValueError('unexpected supplied baseline')
 if any(s['class']=='STACK'for component in supplied['components']for s in component['metadata']['segments']):raise ValueError('unsupported supplied extra STACK input')
 no_overlap(regions,accepted+[r for c in supplied['components']for r in c['target_ranges']])
 # All23 declarations persist, including four unused imports; real dependency definitions are retained separately.
 used={m.externals[f.target-1]for f in m.fixups if f.target_method==2};unused=sorted(set(m.externals)-used)
 if unused!=['__DOSseg__','__FPE_handler','___FPE_handler','__child']:raise ValueError('changed unused startup link declarations')
 verification={'verified':True,'scope':'Complete supplied startup emitted contribution and declared single-STACK storage envelope; not registered credit or final link','initialized_bytes':755,'zero_fill_bytes':0,'verified_fixups':34,'segments':proofs,'publics':known,'local_symbols':{},'group_frames':{1:(3,0)},'input_stack_bytes':4096,'linked_stack_reservation_bytes':51200,'linker_stack_enlargement_bytes':47104,'full_executable_rebuilt':False}
 if any(sha(p)!=v for p,v in before.items()):raise ValueError('startup input changed during observation')
 parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);work=Path(tempfile.mkdtemp(prefix='startup-envelope-',dir=parent));result={'kind':'Opt-in complete supplied startup envelope; no inventory registration','profile':PROFILE,'profile_sha256':sha(ROOT/PROFILE),'inputs_sha256':before,'native_inventory':inventory(m),'startup_record_receipts':[{'ordinal':r['ordinal'],'offset':r['offset'],'kind':r['kind'],'bytes':len(r['raw_record']),'sha256':hashlib.sha256(r['raw_record']).hexdigest()}for r in env.records],'source_annotations':encoded(env.annotations),'entry':encoded(env.entry),'source_publics':encoded(m.publics),'preserved_unbound_zero_publics':unbound,'empty_segments_preserved_without_target_claim':[n for n,s in enumerate(m.segments,1)if not s.size],'placements':places,'typed_field_bindings':edges,'unused_external_declarations':unused,'dependency_envelopes':deps,'stack':stack,'verified_regions':regions,'verification':verification,'supplied_overlap_baseline':{'complete_components':134,'verification_dictionaries_sha256':hashlib.sha256(json.dumps(encoded([x['verification']for x in supplied['components']]),sort_keys=True,separators=(',',':')).encode()).hexdigest(),'additional_STACK_inputs':0},'source_credit':0,'supplied_runtime_credit':0,'registered_runtime_inventory_changed':False,'historical_member_selection_padding_and_final_EXE_identity_proved':False,'actual_build_directory':str(work)}
 (work/'proof.json').write_text(json.dumps(result,indent=2)+'\n');return result

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--accepted-ranges',type=Path,required=True);p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True);a=p.parse_args();r=probe(a.build,a.accepted_ranges);a.report.parent.mkdir(parents=True,exist_ok=True);a.report.write_text(json.dumps(r,indent=2)+'\n');print('startup755init/0BSS/34fixups; inputSTACK4096/linkSTACK51200; no registration/credit')
if __name__=='__main__':main()
