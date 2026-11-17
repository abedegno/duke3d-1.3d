"""Closed ordinary-C TIME_DOS source owner; reference observation follows production."""
from pathlib import Path
from dataclasses import is_dataclass
import argparse,hashlib,json,os,shutil,sys,tempfile
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from runner import compile_source,compiler_bin
from omf32 import Module
SOURCE='src/mact/time/time_dos.c';MODEL='src/mact/time';DESCRIPTOR='modules/mact_time.json';PROVENANCE='evidence/mact-time-source-reference.json';PROFILE='profiles/watcom/mact-time-tools.json';CALLER='evidence/mact-time-taskman-caller.json'
SOURCES=[SOURCE,*[MODEL+'/include/'+p for p in ['types.h','timer.h','task_man.h']]];NOTICES=[MODEL+'/README.md',MODEL+'/gpl.txt']
TOOLS=['tools/probe_mact_time.py','profiles/watcom/tools/runner.py','profiles/watcom/tools/omf32.py',PROFILE]
OBSERVERS=['tools/prove_module.py','tools/infer_bindings.py','tools/match_function.py','tools/verify_module.py','profiles/watcom/tools/le.py']
OPTIONS=['/omaxnet','/zp4','/5r'];EXPECTED={'initialized_bytes':232,'zero_fill_bytes':80,'verified_fixups':16};TARGET_SHA='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4';LIB='reference/duke3d-reconstructions/MACT386.LIB';MEMBER_SHA='a5644251b347bdade408b958d758d2f92f0fcbef0751cb4a78adc3c8620641bd'
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,d):Path(p).parent.mkdir(parents=True,exist_ok=True);Path(p).write_text(json.dumps(d,indent=2)+'\n')
def snapshot(paths):return {str(p):digest(p)for p in paths}
def unchanged(pins):
 if any(digest(p)!=h for p,h in pins.items()):raise ValueError('changed TIME source/tool/output identity')
def encode(x):
 if isinstance(x,(bytes,bytearray)):return x.hex()
 if is_dataclass(x):return encode(vars(x))
 if isinstance(x,dict):return {str(k):encode(v)for k,v in x.items()}
 if isinstance(x,set):return sorted(encode(v)for v in x)
 if isinstance(x,(list,tuple)):return [encode(v)for v in x]
 return x
def inventory(m):
 d=encode(vars(m));d['segments']=[{k:v for k,v in s.items()if k!='data'}for s in d['segments']];comments=[]
 for kind,p in m.comments:
  if kind==0xe9 and p:
   if len(p)<5 or p[4]!=len(p)-5 or p[5:]not in [b'C:\\SOURCE.C',*[('C:\\INC0\\'+n).encode()for n in ['types.h','timer.h','task_man.h']]]:raise ValueError('unexpected TIME provenance record')
   comments.append([kind,{'native_timestamp':'variable','path':p[5:].decode()}])
  else:comments.append([kind,p.hex()])
 d['comments']=comments;return d
def validate_native(m,s):
 if inventory(m)!=s['native_inventory']:raise ValueError('changed complete native TIME contract')
 if [x.size for x in m.segments]!=[228,0,0,4,80]or m.local_publics!={'IncrementCounter_','_TimeStarted','_Timer'}or m.local_externals!={1,2,3}or len(m.fixups)!=16 or any(len(x.data)!=x.size for x in m.segments):raise ValueError('changed complete TIME extent/private scope')
def read_provenance():
 e=json.loads((ROOT/PROVENANCE).read_text());s=json.loads((ROOT/DESCRIPTOR).read_text())
 for field,names in [('sources_sha256',SOURCES),('notices_sha256',NOTICES),('producer_tools_sha256',TOOLS)]:
  if set(e[field])!=set(names):raise ValueError('changed closed TIME '+field)
  for p,h in e[field].items():
   if digest(ROOT/p)!=h:raise ValueError('changed TIME input '+p)
 if s['name']!='mact_time'or s['source']!=SOURCE or s['options']!=OPTIONS or s['expected']!=EXPECTED or digest(ROOT/DESCRIPTOR)!=e['descriptor_sha256']:raise ValueError('changed fixed TIME descriptor')
 return e,s,snapshot([ROOT/p for p in [*SOURCES,*NOTICES,*TOOLS,PROVENANCE,DESCRIPTOR]])
def tool_home(home):
 home=Path(home).resolve();actual={str(p.relative_to(home)):digest(p)for p in sorted(home.rglob('*'))if p.is_file()and'.git'not in p.relative_to(home).parts}
 if actual!=json.loads((ROOT/PROFILE).read_text()):raise ValueError('changed complete TIME GA tool home')
 return actual
def build_source(home,build):
 e,s,before=read_provenance();home=Path(home).resolve();tools=tool_home(home);emulator=Path(os.environ.get('EXHUME_DOSBOX_X')or shutil.which('dosbox-x')or'').resolve()
 if not emulator.is_file()or digest(emulator)!=e['emulator_sha256']:raise ValueError('changed TIME emulator')
 before.update({str(home/p):h for p,h in tools.items()});before.update(snapshot([emulator,Path(sys.executable).resolve()]));parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);work=Path(tempfile.mkdtemp(prefix='mact-time-',dir=parent));stage=work/'source-only';stage.mkdir()
 for p in [*SOURCES,*NOTICES]:q=stage/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,q)
 staged=snapshot(p for p in stage.rglob('*')if p.is_file());obj=work/'TIME_DOS.OBJ';compile_source(home,stage/SOURCE,obj,OPTIONS,45,include_dirs=[stage/MODEL/'include']);log=obj.with_suffix('.log')
 text=log.read_text()
 if '0 warnings, 0 errors'not in text or 'Warning!'in text or 'Error!'in text:raise ValueError('unexpected TIME compiler diagnostics')
 m=Module.parse(obj.read_bytes());validate_native(m,s);outputs=snapshot([obj,log]);unchanged(before);unchanged(staged);unchanged(outputs);tool_home(home)
 return {'module':'mact_time','source':SOURCE,'source_sha256':digest(ROOT/SOURCE),'object':str(obj),'object_sha256':digest(obj),'native_build_directory':str(work),'source_only':True,'original_or_target_read_during_production':False,'source_credit':0,'producer_inputs_sha256':before,'staged_inputs_sha256':staged,'outputs_sha256':outputs,'tool_home_sha256':tools,'normal_native_inventory':inventory(m)}
def caller_anchors(e,work):
 from tools.prove_module import prepare_headers
 from tools.verify_module import external_anchor_bindings
 p=ROOT/CALLER
 if digest(p)!=e['caller_receipt_sha256']:raise ValueError('changed accepted TASK_MAN receipt')
 c=json.loads(p.read_text());descriptor=ROOT/c['descriptor'];s=json.loads(descriptor.read_text());source=ROOT/c['source'];home=ROOT/'toolchains/watcom-10.5';compiler=home/compiler_bin(home)/'wcc386.exe';paths=[p,descriptor,source,compiler]
 if digest(source)!=c['source_sha256']or digest(descriptor)!=c['descriptor_sha256']or digest(compiler)!=c['compiler_sha256']or c['options']!=s['options']or c['options']!=OPTIONS or c['target_sha256']!=TARGET_SHA:raise ValueError('changed live TASK_MAN source/ABI/profile')
 directory=work/'caller-headers';prepare_headers(ROOT/s['reference_headers'],ROOT/s.get('overlay_headers','src/include'),directory);headers={q.name:digest(q)for q in directory.iterdir()if q.is_file()}
 if headers!=c['headers_sha256']or len(headers)!=42:raise ValueError('changed live TASK_MAN42 header graph')
 for folder in [ROOT/s['reference_headers'],ROOT/s.get('overlay_headers','src/include')]:paths +=[q for q in folder.iterdir()if q.is_file()and q.suffix.lower()=='.h']
 proof=c['verification']
 if not proof['verified']or 'local_symbols'not in proof or any(proof[k]!=v for k,v in s['expected'].items()):raise ValueError('incomplete current TASK_MAN proof')
 anchors=external_anchor_bindings(proof);return {n:anchors[n]for n in ['TS_Shutdown_','TS_ScheduleTask_','TS_Terminate_','TS_Dispatch_']},snapshot(paths)
def observe(result):
 from le import LEImage
 from tools.infer_bindings import infer_bindings
 from tools.verify_module import verify_module,external_anchor_bindings
 e,s,pins=read_provenance()
 if set(e['observer_tools_sha256'])!=set(OBSERVERS):raise ValueError('changed TIME observer set')
 for p,h in e['observer_tools_sha256'].items():
  if digest(ROOT/p)!=h:raise ValueError('changed TIME observer identity')
  pins[str(ROOT/p)]=h
 work=Path(result['native_build_directory']);anchors,caller=caller_anchors(e,work);pins.update(caller);obj=Path(result['object']);target=ROOT/'reference/DUKE3D.EXE';lib=ROOT/LIB;pins.update(snapshot([obj,target,lib]))
 if digest(target)!=TARGET_SHA or digest(lib)!=e['original_library_sha256']:raise ValueError('changed TIME original/target')
 raw=lib.read_bytes()[44032:45244]
 if len(raw)!=1212 or hashlib.sha256(raw).hexdigest()!=MEMBER_SHA:raise ValueError('changed whole TIME original member')
 original=Module.parse(raw);m=Module.parse(obj.read_bytes());validate_native(m,s);image=LEImage.parse(target.read_bytes())
 # Genuine private callback pointer at CODE108 -> IncrementCounter CODE0.
 # It nominates candidates; no private target address enters public anchors.
 refs=[f for f in image.read_fixups()if f.source_object==f.target_object==1 and f.source_type==7 and f.width==4 and not f.alias and f.source_offset-f.target_offset==108];results=[];accepted=[]
 for f in refs:
  try:
   b=infer_bindings(m,image,1,f.target_offset,known_symbols=anchors);proof=verify_module(m,image,b['placements'],b['symbols']);ob=infer_bindings(original,image,1,f.target_offset,known_symbols=anchors);old=verify_module(original,image,ob['placements'],ob['symbols'])
   if proof!=old or any(proof[k]!=v for k,v in EXPECTED.items()):raise ValueError('incomplete TIME whole source/original proof')
   accepted.append((b,proof,old));results.append({'base':[1,f.target_offset],'whole_pass':True})
  except ValueError as error:results.append({'base':[1,f.target_offset],'rejection':str(error)})
 if len(refs)!=2 or len(accepted)!=1:raise ValueError('TIME needs finite2 nominees and unique full proof')
 b,proof,old=accepted[0];left=encode(vars(original));right=encode(vars(m))
 for k in ['name','comments','line_numbers']:left.pop(k);right.pop(k)
 if left!=right:raise ValueError('changed original/source complete TIME runtime contract')
 if set(external_anchor_bindings(proof))&{'IncrementCounter_','_TimeStarted','_Timer'}:raise ValueError('TIME private anchor leak')
 unchanged(pins)
 for field in ['producer_inputs_sha256','staged_inputs_sha256','outputs_sha256']:unchanged(result[field])
 return {**result,'source_only':False,'descriptor':DESCRIPTOR,'descriptor_sha256':digest(ROOT/DESCRIPTOR),'source_reference':PROVENANCE,'source_reference_sha256':digest(ROOT/PROVENANCE),'caller_receipt':CALLER,'caller_receipt_sha256':digest(ROOT/CALLER),'verification':proof,'reference_verification':old,'placements':b['placements'],'symbol_anchors':external_anchor_bindings(proof),'binding_symbols':b['symbols'],'caller_symbol_anchors':anchors,'callback_self_edge_candidates':results,'observer_inputs_sha256':pins,'full_executable_rebuilt':False}
def probe(home,build):return observe(build_source(home,build))
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga');p.add_argument('--build',type=Path,required=True);p.add_argument('--source-only',action='store_true');p.add_argument('--report',type=Path);a=p.parse_args();r=build_source(a.home,a.build)if a.source_only else probe(a.home,a.build)
 if a.report:dump(a.report,r)
 print(json.dumps(r,indent=2))
if __name__=='__main__':main()
