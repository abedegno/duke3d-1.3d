"""Normal source-first late TASK_MAN physical/selected-owner capsule.

The generic whole-module verifier MUST reject the duplicate public binding.
The module-specific envelope preserves physical definitions and selected
references separately; it never edits a Module or relaxes generic helpers.
"""
from pathlib import Path
from dataclasses import is_dataclass
import argparse,hashlib,json,os,shutil,sys,tempfile
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from runner import compile_source,compiler_bin
from omf32 import Module
SOURCE='src/mact/taskman_late/task_man.c';MODEL='src/mact/taskman_late';DESCRIPTOR='modules/mact_taskman_late.json';PROVENANCE='evidence/mact-taskman-late-source-reference.json';PROFILE='profiles/watcom/mact-taskman-late-tools.json'
HEADERS={n.lower():'dukenukem3d/extras/'+n for n in ['TYPES.H','DEVELOP.H','LINKLIST.H','TASK_MAN.H','UTIL_LIB.H']}
SOURCES=[SOURCE,*HEADERS.values()];NOTICES=[MODEL+'/README.md',MODEL+'/gpl.txt'];TOOLS=['tools/probe_mact_taskman_late.py','profiles/watcom/tools/runner.py','profiles/watcom/tools/omf32.py',PROFILE]
OBSERVERS=['tools/prove_module.py','tools/infer_bindings.py','tools/map_candidates.py','tools/match_function.py','tools/verify_module.py','profiles/watcom/tools/le.py']
OPTIONS=['/omaxnet','/zp4','/5r'];EXPECTED={'initialized_bytes':1191,'zero_fill_bytes':42,'verified_fixups':82};COMPILER_SHA='1b97a68f7b8a3efd89b05f64ce99836b1e533f398699305f96dc423254939d6a';TARGET_SHA='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4';LIB='reference/duke3d-reconstructions/MACT386.LIB';MEMBER_SHA='2936ab97cc5adc043dcbe233907ce8134a2a889c3f6bb2b6c35159ae59da2343';DEFAULT_CONFLICT='conflicting binding for public _TS_InInterrupt'
PRIVATE={'TS_FreeTaskList_','TS_SetClockSpeed_','TS_SetTimer_','TS_SetTimerToMaxTaskRate_','TS_ServiceSchedule_','TS_Startup_','TS_AddTask_','_TaskList','_TaskServiceRate','_TaskServiceCount','_TS_Installed','_HeadTask','_OldInt8'}
NONEMPTY={1:('_TEXT','CODE',1171,105),4:('_DATA','DATA',20,169),5:('_BSS','BSS',42,105)}
def need(q,msg):
 if not q:raise ValueError(msg)
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,d):Path(p).parent.mkdir(parents=True,exist_ok=True);Path(p).write_text(json.dumps(d,indent=2)+'\n')
def snapshot(paths):return {str(p):digest(p)for p in paths}
def unchanged(pins):need(all(Path(p).is_file()and digest(p)==h for p,h in pins.items()),'late TASK_MAN source/tool/stage/output changed')
def tree(root):return {str(p.relative_to(root)):digest(p)for p in sorted(Path(root).rglob('*'))if p.is_file()}
def encode(x):
 if isinstance(x,(bytes,bytearray)):return bytes(x).hex()
 if is_dataclass(x):return encode(vars(x))
 if isinstance(x,dict):return {str(k):encode(v)for k,v in x.items()}
 if isinstance(x,set):return sorted(encode(v)for v in x)
 if isinstance(x,(list,tuple)):return [encode(v)for v in x]
 return x
def inventory(m,stable=False):
 need(set(vars(m))==set(vars(Module())),'unknown late TASK_MAN native metadata');d=encode(vars(m));d['segments']=[{'name':s.name,'class_name':s.class_name,'size':s.size,'attributes':s.attributes,'access':s.access,'data_sha256':hashlib.sha256(bytes(s.data)).hexdigest()}for s in m.segments]
 if stable:
  seen=0
  for i,(kind,payload)in enumerate(m.comments):
   if kind==233 and payload:
    need(len(payload)>=6 and payload[4]==len(payload)-5,'unmeasured late TASK_MAN E9 source record')
    try:path=payload[5:].decode('ascii')
    except UnicodeDecodeError:raise ValueError('non-ASCII late TASK_MAN source provenance')
    d['comments'][i]=[233,{'native_timestamp_bytes':4,'path':path,'record_payload_bytes':len(payload)}];seen+=1
  need(seen>1,'missing late TASK_MAN source/header provenance')
 return d
def native_hash(m):return hashlib.sha256(json.dumps(inventory(m,True),sort_keys=True,separators=(',',':')).encode()).hexdigest()
def validate_native(m,s):
 need(inventory(m,True)==s['native_inventory'],'changed full late TASK_MAN native bytes/metadata/E9 path contract')
 need([x.size for x in m.segments]==[1171,0,0,20,42]and all(len(x.data)==x.size for x in m.segments),'changed complete late TASK_MAN extents')
 need(m.local_publics==PRIVATE and len(m.local_externals)==9 and len(m.fixups)==82,'changed genuine late TASK_MAN private scope/fields')
def read_contract():
 e=json.loads((ROOT/PROVENANCE).read_text());s=json.loads((ROOT/DESCRIPTOR).read_text())
 for field,names in [('sources_sha256',SOURCES),('notices_sha256',NOTICES),('producer_tools_sha256',TOOLS)]:
  need(type(e.get(field))is dict and set(e[field])==set(names),'changed closed late TASK_MAN '+field)
  for p,h in e[field].items():need((ROOT/p).is_file()and digest(ROOT/p)==h,'changed late TASK_MAN input '+p)
 need(set(e.get('observer_tools_sha256',{}))==set(OBSERVERS),'changed late TASK_MAN observer keyset')
 need(digest(ROOT/DESCRIPTOR)==e['descriptor_sha256']and s['name']=='mact_taskman_late'and s['source']==SOURCE and s['options']==OPTIONS and s['expected']==EXPECTED and s['header_recipe']==HEADERS,'changed fixed late TASK_MAN descriptor')
 need(e['source_credit']==0 and e['whole_default_verification_supported']is False and e['full_executable_rebuilt']is False,'changed late TASK_MAN physical-only scope')
 return e,s,snapshot(ROOT/p for p in[*SOURCES,*NOTICES,*TOOLS,DESCRIPTOR,PROVENANCE])
def tool_home(home):
 home=Path(home).resolve();expected=json.loads((ROOT/PROFILE).read_text());actual=tree(home);need(len(expected)==1114 and actual==expected,'changed complete1114-file TASK_MAN10.5 tool home');need(digest(home/compiler_bin(home)/'wcc386.exe')==COMPILER_SHA,'wrong actual TASK_MAN compiler identity');return actual
def runtime_inputs(e):
 emulator=Path(os.environ.get('EXHUME_DOSBOX_X')or shutil.which('dosbox-x')or'').resolve();python=Path(sys.executable).resolve();need(emulator.is_file()and digest(emulator)==e['emulator_sha256']and python.is_file()and digest(python)==e['python_sha256'],'changed TASK_MAN emulator/Python');return snapshot([emulator,python])
def build_source(home,build):
 e,s,pins=read_contract();home=Path(home).resolve();homes=tool_home(home);pins.update({str(home/p):h for p,h in homes.items()});pins.update(runtime_inputs(e));parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='mact-taskman-late-',dir=parent));stage=w/'source-only';expected={}
 for p in[SOURCE,*NOTICES]:
  q=stage/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,q);expected[str(q.relative_to(stage))]=pins[str(ROOT/p)]
 for name,p in HEADERS.items():
  q=stage/'include'/name;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,q);expected[str(q.relative_to(stage))]=pins[str(ROOT/p)]
 unchanged(pins);need(tree(stage)==expected,'changed copied TASK_MAN source/header stage');staged={str(stage/p):h for p,h in expected.items()};obj=w/'TASK_MAN.OBJ';compile_source(home,stage/SOURCE,obj,OPTIONS,45,include_dirs=[stage/'include']);log=obj.with_suffix('.log');text=log.read_text();need('0 warnings, 0 errors'in text and'Warning!'not in text and'Error!'not in text,'unexpected TASK_MAN native diagnostics');m=Module.parse(obj.read_bytes());validate_native(m,s);raw=w/'raw-native-inventory.json';dump(raw,inventory(m));outputs=snapshot([obj,log,raw]);unchanged(pins);need(tree(stage)==expected,'changed staged TASK_MAN files during tools');unchanged(staged);unchanged(outputs);tool_home(home);runtime_inputs(e)
 r={'module':'mact_taskman_late','source':SOURCE,'source_sha256':digest(ROOT/SOURCE),'source_only':True,'target_SDK_or_caller_read_during_production':False,'source_credit':0,'whole_module_default_verified':False,'full_executable_rebuilt':False,'native_build_directory':str(w),'object':str(obj),'object_sha256':digest(obj),'options':OPTIONS,'compiler_sha256':COMPILER_SHA,'inputs_sha256':pins,'staged_inputs_sha256':staged,'outputs_sha256':outputs,'tool_home_sha256':homes,'normal_native_inventory':inventory(m,True),'raw_native_inventory':str(raw),'timestamp_scope':'Only actual4-byte timestamps of the fixed complete E9 vector vary in stable metadata. Raw comments/object are retained; no runtime/scope/field normalization.'};dump(w/'source-build.json',r);return r

def check_freshness(result,home):
 e,_,_=read_contract();runtime_inputs(e);unchanged(result['inputs_sha256']);unchanged(result['staged_inputs_sha256']);unchanged(result['outputs_sha256']);need(tree(Path(result['native_build_directory'])/'source-only')=={str(Path(p).relative_to(Path(result['native_build_directory'])/'source-only')):h for p,h in result['staged_inputs_sha256'].items()},'changed TASK_MAN stage file set');tool_home(home)

def early_owner(home,w,e):
 from tools.prove_module import prove,prepare_headers
 from tools.verify_module import external_anchor_bindings
 spec=json.loads((ROOT/'modules/task_man.json').read_text());need(spec['source']=='src/audio/task_man.c'and spec['options']==OPTIONS,'changed accepted early TASK_MAN recipe');paths=[ROOT/'modules/task_man.json',ROOT/spec['source'],ROOT/'tools/prove_module.py',ROOT/'tools/infer_bindings.py',ROOT/'tools/verify_module.py',ROOT/'tools/match_function.py',home/compiler_bin(home)/'wcc386.exe'];headers=w/'early-source-headers';prepare_headers(ROOT/spec['reference_headers'],ROOT/spec.get('overlay_headers','src/include'),headers);prepared={p.name:digest(p)for p in headers.iterdir()if p.is_file()}
 for folder in [ROOT/spec['reference_headers'],ROOT/spec.get('overlay_headers','src/include')]:paths.extend(p for p in folder.iterdir()if p.is_file()and p.suffix.lower()=='.h')
 witness=e['early_owner_recipe'];need(digest(ROOT/spec['source'])==witness['source_sha256']and digest(ROOT/'modules/task_man.json')==witness['descriptor_sha256']and prepared==witness['prepared_headers_sha256'],'changed live accepted early TASK_MAN inputs');pins=snapshot(paths);report=prove('task_man',home,w/'early-owner-native');v=report['verification'];need(v['verified']and all(v[k]==n for k,n in {'initialized_bytes':1380,'zero_fill_bytes':42,'verified_fixups':103}.items())and report['compiler_sha256']==COMPILER_SHA,'incomplete actual early TASK_MAN10.5 replay');raw=Module.parse((w/'early-owner-native/task_man.obj').read_bytes());need('_TS_InInterrupt'in raw.publics and'_TS_InInterrupt'not in raw.local_publics and raw.publics['_TS_InInterrupt']==(4,16),'early interrupt byte is not real source-owned global');anchors=external_anchor_bindings(v);unchanged(pins);return report,tuple(anchors['_TS_InInterrupt']),pins

def derive_physical(m,image,obj,base,selected_early):
 places={1:(obj,base)};selected={'_TS_InInterrupt':tuple(selected_early)};fields={(f.source_object,f.source_offset):f for f in image.read_fixups()};pending=list(m.fixups);ledger=[]
 def put(d,k,v):
  need(k not in d or d[k]==v,'conflicting TASK_MAN typed coordinate '+str(k));d[k]=v
 while pending:
  progress=False
  for f in pending[:]:
   if f.segment not in places:continue
   progress=True;pending.remove(f);need(f.width==4 and f.location==9 and f.target_method==2,'unmeasured TASK_MAN typed operand');so,start=places[f.segment];at=start+f.offset;source=m._segment(f.segment);need(0<=f.offset<=source.size-4,'TASK_MAN operand outside source');inline=int.from_bytes(source.data[f.offset:f.offset+4],'little')+f.displacement;lf=fields.get((so,at));name=m.externals[f.target-1]
   if f.relative:
    need(lf is None,'unexpected TASK_MAN relative loader relocation');actual=(so,at+4+int.from_bytes(image.object_bytes(so)[at:at+4],'little',signed=True)-inline)
   else:
    need(lf is not None and lf.source_type==7 and lf.width==4 and not lf.alias,'missing actual TASK_MAN full-width loader field');need(int.from_bytes(image.object_bytes(so)[at:at+4],'little')==lf.target_offset,'TASK_MAN pointer bytes disagree with loader field');actual=(lf.target_object,lf.target_offset-inline)
   if f.target in m.local_externals:
    need(name in PRIVATE and name in m.local_publics,'private TASK_MAN reference lost real scope');sn,off=m.publics[name];put(places,sn,(actual[0],actual[1]-off));kind='same-TU genuine private'
   else:
    need(name not in PRIVATE,'TASK_MAN private external-anchor leak');put(selected,name,actual);kind='fresh earlier selected global'if name=='_TS_InInterrupt'else'actual external import, original scope corroborated after production'
   ledger.append({'source_segment':f.segment,'field_offset':f.offset,'name':name,'private':f.target in m.local_externals,'actual_reference_minus_inline_A':actual,'kind':kind})
  need(progress,'unplaced TASK_MAN source segment/typed fields')
 need(set(places)==set(NONEMPTY),'incomplete late TASK_MAN physical segment set');private={n:(places[sn][0],places[sn][1]+off)for n,(sn,off)in m.publics.items()if n in m.local_publics};need(set(private)==PRIVATE and not(set(private)&set(selected)),'TASK_MAN private scope/anchor leak');need(sum(x['private']for x in ledger)==69 and len(ledger)==82,'incomplete69private/82field ledger');return places,selected,private,ledger

def physical_checks(m,image,places,bindings):
 from tools.match_function import compare_range
 from tools.verify_module import verify_module
 need({i:(s.name,s.class_name,s.size,s.attributes)for i,s in enumerate(m.segments,1)if s.size}==NONEMPTY,'changed complete TASK_MAN physical geometry');ranges=[];reports=[]
 for sn,(name,kind,size,attr)in NONEMPTY.items():
  obj,start=places[sn];seg=m._segment(sn);alignment={1:1,2:2,3:16,4:256,5:4}[attr>>5];need(0<=start and start+size<=image._object(obj).size and(image._object(obj).base+start)%alignment==0,'TASK_MAN bounds/alignment failure');need(all(not(o==obj and start<end and start+size>begin)for o,begin,end in ranges),'overlapping TASK_MAN physical ranges');ranges.append((obj,start,start+size))
  if kind=='BSS':need(not any(seg.data)and all(image.file_offset(obj,start+i)is None for i in range(size)),'TASK_MAN BSS is not whole unbacked zero-fill')
  else:need(all(image.file_offset(obj,start+i)is not None for i in range(size)),'TASK_MAN initialized interval lacks backing')
  q=compare_range(m,sn,0,image,obj,start,size,bindings,places,label=name);need(q['match'],'TASK_MAN full '+name+' differing bytes '+str(q['differing_offsets']));reports.append(q)
 need(sum(q['verified_fixups']for q in reports)==82,'incomplete TASK_MAN physical fields')
 try:verify_module(m,image,places,bindings)
 except ValueError as err:failure=str(err)
 else:raise ValueError('default TASK_MAN verifier unexpectedly accepted duplicate owner')
 need(failure==DEFAULT_CONFLICT,'wrong default TASK_MAN duplicate-public rejection: '+failure)
 return {'verified':True,'scope':'explicit physical segments with separately selected real references; not generic whole-module admission',**EXPECTED,'segments':reports},failure

def observe(result,home):
 from le import LEImage
 from tools.map_candidates import locate
 e,s,pins=read_contract();need(set(e['observer_tools_sha256'])==set(OBSERVERS),'changed observer contract')
 for p,h in e['observer_tools_sha256'].items():need(digest(ROOT/p)==h,'changed TASK_MAN observer '+p);pins[str(ROOT/p)]=h
 check_freshness(result,home);w=Path(result['native_build_directory']);early,interrupt,early_pins=early_owner(Path(home).resolve(),w,e);pins.update(early_pins);target=ROOT/'reference/DUKE3D.EXE';lib=ROOT/LIB;need(digest(target)==TARGET_SHA and digest(lib)==e['original_library_sha256'],'changed TASK_MAN target/original library');pins.update(snapshot([target,lib]));image=LEImage.parse(target.read_bytes());raw=lib.read_bytes()[45568:49373];need(hashlib.sha256(raw).hexdigest()==MEMBER_SHA,'changed whole TASK_MAN original member');original=Module.parse(raw);m=Module.parse(Path(result['object']).read_bytes());validate_native(m,s)
 # Original SDK is an observer only: it corroborates every actual imported/private
 # role, not a producer template. No cached research receipt is consumed.
 left=inventory(original);right=inventory(m)
 for key in ['name','comments','line_numbers']:left.pop(key);right.pop(key)
 need(left==right,'source/original complete runtime/scope/typed metadata differ')
 locations=locate(m,{i:image.object_bytes(i)for i,o in enumerate(image.objects,1)if o.flags&4});candidates=sorted({(x['object'],x['offset']-row['source_offset'])for row in locations for x in row.get('locations',[])});attempts=[];wins=[]
 for obj,base in candidates:
  try:
   places,selected,private,ledger=derive_physical(m,image,obj,base,interrupt);bindings={**selected,**private};proof,failed=physical_checks(m,image,places,bindings);old,oldfailed=physical_checks(original,image,places,bindings);need(proof==old,'complete TASK_MAN source/original physical proofs differ');wins.append((places,selected,private,ledger,proof,failed,oldfailed));attempts.append({'nomination':[obj,base],'complete_physical_match':True})
  except ValueError as err:attempts.append({'nomination':[obj,base],'complete_physical_match':False,'error':str(err)})
 need(len(wins)==1,'TASK_MAN needs unique whole physical source nomination');places,selected,private,ledger,proof,failed,oldfailed=wins[0];physical={n:[places[sn][0],places[sn][1]+off]for n,(sn,off)in m.publics.items()if n not in m.local_publics};need(tuple(physical['_TS_InInterrupt'])!=interrupt,'late physical global incorrectly aliases selected early global');unchanged(pins);check_freshness(result,home)
 out={**result,'kind':'normal complete late TASK_MAN physical/selected-owner source capsule; default whole conflict retained','descriptor':DESCRIPTOR,'descriptor_sha256':digest(ROOT/DESCRIPTOR),'source_reference':PROVENANCE,'source_reference_sha256':digest(ROOT/PROVENANCE),'physical_verification':proof,'reference_physical_verification':proof,'default_whole_verification_failures':{'source':failed,'original':oldfailed},'whole_module_default_verified':False,'physical_placements':places,'physical_global_definitions':physical,'private_symbols':private,'selected_reference_bindings':selected,'selected_early_interrupt_global':list(interrupt),'private_reference_count':69,'all82typed_reference_ledger':ledger,'private_external_anchor_names':[],'source_first_nominations':locations,'all_complete_candidate_gates':attempts,'early_owner_fresh_source_proof':early,'observer_inputs_sha256':pins,'source_only':False};dump(w/'physical-proof.json',out);return out

def probe(home,build):return observe(build_source(home,build),home)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.5');p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True);p.add_argument('--source-only',action='store_true');a=p.parse_args();r=build_source(a.home,a.build)if a.source_only else probe(a.home,a.build);dump(a.report,r);print('LATE TASK_MAN '+('SOURCE BUILT'if a.source_only else'PHYSICAL VERIFIED1191/42/82; default duplicate-public conflict retained'))
if __name__=='__main__':main()
