"""Complete source-built VECTOR: source-only native production before observation."""
from pathlib import Path
from dataclasses import is_dataclass
import argparse,hashlib,json,os,re,shutil,sys,tempfile
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from runner import run_batch,compile_source
from omf32 import Module
SOURCE='src/mact/vector/vector.asm';MODEL='src/mact/vector';COUNTERPART=MODEL+'/vector-counterpart.c.txt';PROFILE='profiles/watcom/mact-vector-tools.json';DESCRIPTOR='modules/mact_vector.json';PROVENANCE='evidence/mact-vector-source-reference.json'
SOURCES=[SOURCE,COUNTERPART,*[MODEL+'/include/'+n for n in['vector.h','types.h','develop.h']]]
NOTICES=[MODEL+'/README.md',MODEL+'/gpl.txt'];TOOLS=['tools/probe_mact_vector.py','profiles/watcom/tools/runner.py','profiles/watcom/tools/omf32.py',PROFILE];OBSERVERS=['tools/prove_module.py','tools/map_candidates.py','tools/infer_bindings.py','tools/verify_module.py','tools/match_function.py','profiles/watcom/tools/le.py']
PUBLICS={'FP_VectorAdd_':(1,0),'FP_VectorSub_':(1,28),'FP_ScaleVector_':(1,56),'FP_VectorLength_':(1,84),'FP_NormalizeVector_':(1,124),'FP_2x2Det_':(1,192),'FP_CrossProduct_':(1,216),'FP_TripleProduct_':(1,400),'FP_DecomposeVector_':(1,444),'FP_RotateVAV_':(1,524)}
IMPORTS=['__get_errno_ptr_','_fltused_','__init_387_emulator','__8087'];OPTIONS=['/zq'];EXPECTED={'initialized_bytes':735,'zero_fill_bytes':0,'verified_fixups':3};REFERENCE_EXPECTED={**EXPECTED,'verified_fixups':5};LIBRARY='reference/duke3d-reconstructions/MACT386.LIB';MEMBER_SHA='4315e32dae8c515e9d8a072668f6617c6dc446467eb186a793f7831e43c5558f';TARGET_SHA='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'
def need(ok,why):
 if not ok:raise ValueError(why)
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,d):Path(p).parent.mkdir(parents=True,exist_ok=True);Path(p).write_text(json.dumps(d,indent=2)+'\n')
def snapshot(paths):return {str(p):digest(p)for p in paths}
def unchanged(pins):need(all(digest(p)==h for p,h in pins.items()),'VECTOR input/output changed during production')
def encode(x):
 if isinstance(x,(bytes,bytearray)):return {'hex':bytes(x).hex()}
 if is_dataclass(x):return encode(vars(x))
 if isinstance(x,dict):return {str(k):encode(v)for k,v in x.items()}
 if isinstance(x,set):return sorted(encode(v)for v in x)
 if isinstance(x,(list,tuple)):return [encode(v)for v in x]
 return x
def inventory(m):
 need(set(vars(m))==set(vars(Module())),'unknown VECTOR module metadata');r=encode(vars(m));r['segments']=[{k:v for k,v in s.items()if k!='data'}for s in r['segments']];return r
def preflight(raw):
 lines=[line.partition(';')[0].strip()for line in raw.decode('ascii').splitlines()];pub=[];ext=[];procs=[];libs=[]
 for line in lines:
  if not line:continue
  if line.lower().startswith('public '):pub+=line.split(None,1)[1].split(',')
  if line.lower().startswith('extrn '):ext.append(line.split(None,1)[1].split(':')[0])
  if re.fullmatch(r'\w+ proc near',line):procs.append(line.split()[0])
  if line.lower().startswith('includelib '):libs.append(line.split()[1])
  need(not re.search(r'(?i)\b(?:db|dw|dd|dq|dt|org|incbin|include|macro)\b',line),'VECTOR forbids encoded payload/storage/include grammar')
 need(len(pub)==10 and set(pub)==set(PUBLICS)and procs==list(PUBLICS),'all ten genuine VECTOR functions/scope')
 need(ext==IMPORTS,'all four real VECTOR imports including unused FPU metadata')
 need(libs==['math387r','emu387'],'both actual VECTOR default library requirements')
 return {'public_names':pub,'procedures':procs,'imports':ext,'default_libraries':libs}
def validate_native(m,s):
 need(inventory(m)==s['native_inventory'],'changed complete VECTOR native metadata/scope/fields')
 need(m.publics==PUBLICS and not(m.local_publics or m.local_externals)and m.externals==IMPORTS,'VECTOR actual scope/import identities')
 need([(x.name,x.class_name,x.size,x.attributes,x.access)for x in m.segments]==[('_TEXT','CODE',735,105,None),('_DATA','DATA',0,169,None),('CONST','DATA',0,169,None),('CONST2','DATA',0,169,None),('_BSS','BSS',0,105,None)],'VECTOR complete geometry/alignment')
 need(all(len(x.data)==x.size for x in m.segments),'VECTOR full storage backing')
def read_provenance():
 e=json.loads((ROOT/PROVENANCE).read_text());s=json.loads((ROOT/DESCRIPTOR).read_text())
 for field,names in [('sources_sha256',SOURCES),('notices_sha256',NOTICES),('producer_tools_sha256',TOOLS)]:
  need(set(e[field])==set(names),'changed closed VECTOR '+field)
  for p,h in e[field].items():need(digest(ROOT/p)==h,'changed VECTOR source/tool/notice '+p)
 need(s['name']=='mact_vector'and s['source']==SOURCE and s['counterpart']==COUNTERPART and s['options']==OPTIONS and s['expected']==EXPECTED and s['reference_expected']==REFERENCE_EXPECTED and digest(ROOT/DESCRIPTOR)==e['descriptor_sha256'],'changed fixed VECTOR descriptor')
 need(e['historical_assembly_identity']is False and e['full_executable_rebuilt']is False and e['source_credit']==0 and e['humanization_backlog']==list(PUBLICS),'changed VECTOR lineage/backlog/credit limits')
 return e,s,snapshot(ROOT/p for p in[*SOURCES,*NOTICES,*TOOLS,DESCRIPTOR,PROVENANCE])
def tool_home(home):
 home=Path(home).resolve();actual={str(p.relative_to(home)):digest(p)for p in sorted(home.rglob('*'))if p.is_file()and'.git'not in p.relative_to(home).parts};expected=json.loads((ROOT/PROFILE).read_text());need(len(expected)==500 and actual==expected,'changed complete VECTOR GA tool home');return actual
def runtime_inputs(e):
 emulator=Path(os.environ.get('EXHUME_DOSBOX_X')or shutil.which('dosbox-x')or'').resolve();python=Path(sys.executable).resolve()
 need(emulator.is_file()and digest(emulator)==e['emulator_sha256']and digest(python)==e['python_sha256'],'changed VECTOR emulator/Python identity');return snapshot([emulator,python])
def assemble(home,source,build):
 """Standalone fixed-profile native source build: no SDK/target/caller reads."""
 home,source,build=Path(home).resolve(),Path(source).resolve(),Path(build).resolve();tools=tool_home(home);preflight(source.read_bytes());build.mkdir(parents=True,exist_ok=True);work=Path(tempfile.mkdtemp(prefix='mact-vector-',dir=build));stage=work/'VECTOR.ASM';shutil.copyfile(source,stage);pins=snapshot([source,stage,Path(sys.executable).resolve()]);pins.update({str(home/p):h for p,h in tools.items()});emulator=Path(os.environ.get('EXHUME_DOSBOX_X')or shutil.which('dosbox-x')or'').resolve();need(emulator.is_file(),'missing VECTOR DOSBox-X');pins.update(snapshot([emulator]));dump(work/'source-only-inputs.json',pins);dump(work/'source-preflight.json',preflight(stage.read_bytes()))
 run_batch(home,work,'@echo off\r\nset PATH=D:\\BINB;D:\\BIN\r\nwasm /zq VECTOR.ASM > ASSEMBLE.LOG\r\nif errorlevel 1 goto failed\r\necho OK>STATUS.TXT\r\ngoto done\r\n:failed\r\necho FAILED>STATUS.TXT\r\n:done\r\n',45)
 need((work/'STATUS.TXT').read_text().strip()=='OK'and not(work/'ASSEMBLE.LOG').read_bytes(),'actual VECTOR native assembly failure/diagnostics');unchanged(pins);tool_home(home);return work

def build_source(home,build):
 e,s,pins=read_provenance();pins.update(runtime_inputs(e));parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);stage=Path(tempfile.mkdtemp(prefix='vector-source-',dir=parent))
 for p in[*SOURCES,*NOTICES]:q=stage/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,q)
 staged=snapshot(p for p in stage.rglob('*')if p.is_file());work=assemble(home,stage/SOURCE,parent);obj=work/'VECTOR.OBJ';m=Module.parse(obj.read_bytes());validate_native(m,s);outputs=snapshot([obj,work/'VECTOR.ASM',work/'ASSEMBLE.LOG']);unchanged(pins);unchanged(staged);unchanged(outputs);tool_home(home)
 result={'module':'mact_vector','home':str(Path(home).resolve()),'source':SOURCE,'source_sha256':digest(ROOT/SOURCE),'object':str(obj),'object_sha256':digest(obj),'native_build_directory':str(work),'source_only':True,'original_or_target_read_during_production':False,'source_credit':0,'producer_inputs_sha256':pins,'staged_inputs_sha256':staged,'outputs_sha256':outputs,'tool_home_sha256':tool_home(home),'normal_native_inventory':inventory(m)}
 dump(work/'source-build.json',result);return result
def reference_module(raw,e):
 need(hashlib.sha256(raw).hexdigest()==e['original_library_sha256'],'changed original VECTOR library');member=raw[37888:39838];need(len(member)==1950 and hashlib.sha256(member).hexdigest()==MEMBER_SHA,'changed original VECTOR member');return Module.parse(member)
def check_module(m,image,original,base,s,code_object=1):
 from tools.infer_bindings import infer_bindings
 from tools.verify_module import verify_module,external_anchor_bindings
 validate_native(m,s);need(original.publics==PUBLICS and not(original.local_publics or original.local_externals)and original.externals==['__get_errno_ptr_','FP_CrossProduct_','_fltused_','__init_387_emulator','__8087']and original.default_libraries==m.default_libraries,'changed original VECTOR inventory')
 b=infer_bindings(m,image,code_object,base);ob=infer_bindings(original,image,code_object,base);v=verify_module(m,image,b['placements'],b['symbols']);ov=verify_module(original,image,ob['placements'],ob['symbols'])
 need(all(v[k]==x for k,x in EXPECTED.items())and all(ov[k]==x for k,x in REFERENCE_EXPECTED.items()),'incomplete VECTOR whole proof');need(external_anchor_bindings(v)==external_anchor_bindings(ov),'changed VECTOR nonlocal roles');need(b['placements']=={1:(code_object,base)}and not b['unplaced_segments'],'VECTOR unexpected placement')
 need(len(original.fixups)==5 and len(m.fixups)==3,'all five VECTOR fields');native_fields={f.offset:f for f in m.fixups};roles=[];loader={(f.source_object,f.source_offset)for f in image.read_fixups()};code=m.segments[0].data
 for rf in original.fixups:
  name=original.externals[rf.target-1];sf=native_fields.get(rf.offset)
  need(rf.segment==1 and rf.width==4 and rf.location==9 and rf.relative and rf.displacement==0 and rf.target_method==2 and rf.frame_method==1 and original.groups[rf.frame-1]==('FLAT',()),'original VECTOR canonical field')
  if sf:
   need(name=='__get_errno_ptr_'and (sf.segment,sf.width,sf.location,sf.relative,sf.frame_method,sf.frame,sf.target_method,sf.target,sf.displacement)==(1,4,9,True,5,None,2,1,0),'VECTOR real errno-call frame/role');roles.append({'field':rf.offset,'name':name,'kind':'actual external F5 source versus F1FLAT C'})
  else:
   target=rf.offset+4+int.from_bytes(code[rf.offset:rf.offset+4],'little',signed=True);need(name=='FP_CrossProduct_'and code[rf.offset-1]==232 and target==216 and(code_object,base+rf.offset)not in loader and image.object_bytes(code_object)[base+rf.offset:base+rf.offset+4]==code[rf.offset:rf.offset+4],'VECTOR genuine resolved self-call/no loader');roles.append({'field':rf.offset,'name':name,'kind':'resolved same-TU E8','target':target,'loader_present':False})
 return {'placements':b['placements'],'binding_symbols':b['symbols'],'symbol_anchors':external_anchor_bindings(v),'constraints':b['constraints'],'verification':v,'reference_verification':ov,'all_original_roles':roles,'source_native_inventory':inventory(m),'reference_native_inventory':inventory(original)}
def observe(result):
 from le import LEImage
 from tools.map_candidates import locate
 e,s,pins=read_provenance();need(set(e['observer_tools_sha256'])==set(OBSERVERS),'changed VECTOR observer keyset')
 for p,h in e['observer_tools_sha256'].items():need(digest(ROOT/p)==h,'changed VECTOR observer identity');pins[str(ROOT/p)]=h
 obj=Path(result['object']);target=ROOT/'reference/DUKE3D.EXE';lib=ROOT/LIBRARY;pins.update(snapshot([obj,target,lib]));need(digest(target)==TARGET_SHA,'changed VECTOR target');m=Module.parse(obj.read_bytes());validate_native(m,s);image=LEImage.parse(target.read_bytes());original=reference_module(lib.read_bytes(),e)
 # A complete fresh public body nominates only; every nominee needs both whole gates.
 rows=locate(m,{n:image.object_bytes(n)for n,o in enumerate(image.objects,1)if o.flags&4});row=next(r for r in rows if r['symbol']=='FP_RotateVAV_');need(row['size']==211 and row['source_offset']==524,'VECTOR true longest public-body geometry');candidates=[];accepted=[]
 for location in row['locations']:
  objnum=location['object'];base=location['offset']-row['source_offset']
  try:r=check_module(m,image,original,base,s,objnum);accepted.append(r);candidates.append({'base':[objnum,base],'full_source_and_original_pass':True})
  except ValueError as err:candidates.append({'base':[objnum,base],'rejection':str(err)})
 dump(Path(result['native_build_directory'])/'nomination-candidates.json',{'nomination':row,'candidates':candidates})
 need(len(accepted)==1,'VECTOR requires unique full source/original proof among all nominees');unchanged(pins)
 for field in ['producer_inputs_sha256','staged_inputs_sha256','outputs_sha256']:unchanged(result[field])
 tool_home(Path(result['home']))
 return {**result,'source_only':False,'source_reference':PROVENANCE,'source_reference_sha256':digest(ROOT/PROVENANCE),'descriptor':DESCRIPTOR,'descriptor_sha256':digest(ROOT/DESCRIPTOR),'nomination':row,'all_candidates':candidates,'observer_inputs_sha256':pins,'original_and_target_observed_only_after_source_production':True,'humanization_backlog':list(PUBLICS),'full_executable_rebuilt':False,**accepted[0]}
def probe(home,build):
 result=build_source(home,build);result['home']=str(Path(home).resolve());return observe(result)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga');p.add_argument('--build',type=Path,required=True);p.add_argument('--source-only',action='store_true');p.add_argument('--report',type=Path);a=p.parse_args();r=build_source(a.home,a.build)if a.source_only else probe(a.home,a.build)
 if a.report:dump(a.report,r)
 print(json.dumps(r,indent=2))
if __name__=='__main__':main()
