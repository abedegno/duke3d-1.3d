"""Normal source-only IRQ NASM backend; caller/reference/origin follow production."""
from pathlib import Path
import sys,json,hashlib,shutil,tempfile,subprocess,importlib.util,dataclasses,os
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from omf32 import Module
from tools.probe_actors_composite import checked_nasm,DEFAULT_NASM_SHA256
MODEL='src/audio/irq_symbolic';DESCRIPTOR='modules/irq_symbolic.json';PROVENANCE='evidence/irq-symbolic-source-reference.json'
SOURCES=[MODEL+'/'+n for n in ('IRQ.ASM','irq.c','irq.h','i86.h','contract.py','source-model.json')];NOTICES=[MODEL+'/README.md',MODEL+'/gpl.txt']
PRODUCERS=['tools/probe_irq_symbolic.py','tools/probe_actors_composite.py','profiles/watcom/tools/omf32.py','profiles/watcom/tools/runner.py','profiles/watcom/tools/le.py','tools/infer_bindings.py','tools/match_function.py','tools/verify_module.py','tools/preserve.py','tools/object_contributions.py','tools/prove_module.py','tools/probe_premap.py','tools/probe_actors.py','tools/verify_composite.py']
OBSERVERS=['tools/prove_module.py','tools/probe_audio_layout.py','tools/infer_bindings.py','tools/match_function.py','tools/verify_module.py','profiles/watcom/tools/le.py','tools/prove_logical_data_origin.py','tools/logical_data_origin_inputs.json','tools/logical_segment_origins.py','evidence/audio-layout-source-reference.json','modules/irq.json','src/audio/irq.c']
EXPECTED={'initialized_bytes':1016,'zero_fill_bytes':54,'verified_fixups':102};TARGET='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'
def need(c,m):
 if not c:raise ValueError('IRQ symbolic '+m)
def reject_ambient_nasm():
 need(not os.environ.get('NASMENV'),'NASMENV must be unset or empty; ambient assembler options are not tracked')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,j):Path(p).parent.mkdir(parents=True,exist_ok=True);Path(p).write_text(json.dumps(j,indent=2)+'\n')
def snapshot(paths):return {str(Path(p).resolve()):sha(p) for p in paths}
def unchanged(pins):
 for p,h in pins.items():need(Path(p).is_file()and not Path(p).is_symlink()and sha(p)==h,'live/staged/output identity changed: '+p)
def encode(v):
 if isinstance(v,(bytes,bytearray)):return {'hex':bytes(v).hex()}
 if dataclasses.is_dataclass(v):return encode(vars(v))
 if isinstance(v,dict):return {str(k):encode(x) for k,x in v.items()}
 if isinstance(v,(tuple,list)):return [encode(x) for x in v]
 if isinstance(v,set):return sorted(v)
 return v
def load_contract(path):
 s=importlib.util.spec_from_file_location('closed_irq_contract',path/'contract.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
_LOADED={n:sha(ROOT/n) for n in PRODUCERS}
def read_provenance(project=ROOT,observer=False):
 project=Path(project).resolve();e=json.loads((project/PROVENANCE).read_text());spec=json.loads((project/DESCRIPTOR).read_text())
 for field,names in [('tracked_sources_sha256',SOURCES),('notice_files_sha256',NOTICES),('producer_tools_sha256',PRODUCERS)]+([('observer_tools_sha256',OBSERVERS)]if observer else []):
  need(set(e[field])==set(names),'closed '+field)
  for n,h in e[field].items():need((project/n).is_file()and not(project/n).is_symlink()and(project/n).resolve().is_relative_to(project)and sha(project/n)==h,'changed source/tool/notice: '+n)
 need(all(e['producer_tools_sha256'][n]==h for n,h in _LOADED.items()),'loaded producer identity')
 need(sha(project/DESCRIPTOR)==e['descriptor_sha256']and spec['expected']==EXPECTED and spec['options']==['-f','obj'],'descriptor identity')
 need(sha(Path(sys.executable).resolve())==e['python_sha256'],'Python identity')
 pins=snapshot([project/PROVENANCE,project/DESCRIPTOR,*[project/n for n in SOURCES+NOTICES+PRODUCERS],Path(sys.executable).resolve()])
 if observer:pins.update(snapshot(project/n for n in OBSERVERS))
 unchanged(pins);return e,spec,pins

def check_native(m,spec):
 need([{'name':x.name,'class':x.class_name,'size':x.size,'attributes':x.attributes,'access':x.access}for x in m.segments]==spec['native_segments'],'complete native segment inventory')
 need(encode({k:v for k,v in vars(m).items()if k not in ('name','segments','fixups')})==spec['native_metadata'],'complete native public/private/import/group/default metadata')
 need([vars(f) for f in m.fixups]==spec['expected_fixups'],'complete102 typed native fields')

def expected_stage(work,e):return {str((Path(work)/'source-only'/n).resolve()):e[field][n] for field,names in [('tracked_sources_sha256',SOURCES),('notice_files_sha256',NOTICES)]for n in names}
def check_stage(work,e,claimed=None):
 stage=Path(work)/'source-only';need({p.relative_to(stage).as_posix()for p in stage.rglob('*')if p.is_file()or p.is_symlink()}==set(SOURCES+NOTICES),'closed staged file set')
 need(all(p.is_file()and not p.is_symlink()for p in stage.rglob('*')if not p.is_dir()),'regular staged inputs')
 expected=expected_stage(work,e);need(claimed is None or claimed==expected,'pre-copy expected stage receipt');unchanged(expected);return expected

def build_source(home=None,build=None,*,project=ROOT):
 reject_ambient_nasm()
 project=Path(project).resolve();e,spec,pins=read_provenance(project);semantic=load_contract(project/MODEL).source_contract(project/MODEL)
 binary=(ROOT/'toolchains/support/nasm-2.16.03/nasm').resolve();need(sha(binary)==DEFAULT_NASM_SHA256,'fixed NASM binary');pins[str(binary)]=sha(binary)
 parent=Path(build or project/'build/irq-symbolic').resolve();parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='irq-symbolic-',dir=parent));stage=w/'source-only';stage.mkdir();expected=expected_stage(w,e)
 for n in SOURCES+NOTICES:
  q=stage/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(project/n,q);unchanged({str(q):expected[str(q)]})
 staged=check_stage(w,e);need(staged==expected,'pre-copy source expectation');contract=load_contract(stage/MODEL);need(contract.source_contract(stage/MODEL)==semantic,'live/staged semantic family');unchanged(pins);checked_nasm()
 cmd=[str(binary),'-f','obj','-l',str(w/'IRQ.LST'),'-o',str(w/'IRQ.OBJ'),str(stage/MODEL/'IRQ.ASM')];p=subprocess.run(cmd,capture_output=True,text=True,timeout=30);(w/'IRQ.LOG').write_text(p.stdout+p.stderr);need(p.returncode==0 and not(p.stdout or p.stderr),'native diagnostics');unchanged(pins);check_stage(w,e,staged);checked_nasm();need(contract.source_contract(stage/MODEL)==semantic,'staged source after native')
 m=Module.parse((w/'IRQ.OBJ').read_bytes());contract.native_contract(m);check_native(m,spec);need(m.name==str(stage/MODEL/'IRQ.ASM'),'actual THEADR staged path');outputs=snapshot(w/n for n in ('IRQ.OBJ','IRQ.LST','IRQ.LOG'));unchanged(outputs)
 receipt={'source_only':True,'original_or_target_read_during_production':False,'project':str(project),'source':MODEL+'/IRQ.ASM','source_sha256':e['tracked_sources_sha256'][MODEL+'/IRQ.ASM'],'C_reference_home':str(Path(home or ROOT/'toolchains/watcom-10.5').resolve()),'native_build_directory':str(w),'object':str(w/'IRQ.OBJ'),'object_sha256':sha(w/'IRQ.OBJ'),'inputs_sha256':pins,'staged_sha256':staged,'outputs_sha256':outputs,'semantic':semantic,'command':cmd,'source_credit':0};dump(w/'source-build.json',receipt);return receipt

def validate_receipt(r,e,spec,pins):
 reject_ambient_nasm()
 project=Path(r['project']);w=Path(r['native_build_directory']);binary=(ROOT/'toolchains/support/nasm-2.16.03/nasm').resolve();expected=dict(pins);expected[str(binary)]=sha(binary)
 # Observer-only tools were not producer inputs.
 for n in OBSERVERS:
  if n not in PRODUCERS:expected.pop(str((project/n).resolve()),None)
 need(r['inputs_sha256']==expected,'complete live input pin closure');unchanged(r['inputs_sha256']);unchanged(r['outputs_sha256']);check_stage(w,e,r['staged_sha256'])
 need(set(r['outputs_sha256'])=={str((w/n).resolve())for n in ('IRQ.OBJ','IRQ.LST','IRQ.LOG')},'complete native output pins')
 need(r['source']==MODEL+'/IRQ.ASM'and r['source_sha256']==e['tracked_sources_sha256'][r['source']]and r['object']==str(w/'IRQ.OBJ')and sha(r['object'])==r['object_sha256'],'source/object receipt')
 need(r['semantic']==load_contract(project/MODEL).source_contract(project/MODEL)==load_contract(w/'source-only'/MODEL).source_contract(w/'source-only'/MODEL),'live/staged semantic receipt')
 need(r['source_only']and not r['original_or_target_read_during_production']and r['source_credit']==0,'source-only receipt scope');checked_nasm()

def observe(receipt):
 reject_ambient_nasm()
 from le import LEImage
 from tools import probe_audio_layout as audio
 from tools.infer_bindings import infer_bindings
 from tools.verify_module import verify_module,external_anchor_bindings
 from tools.prove_logical_data_origin import replay_target_data_origin
 from tools.prove_module import assert_contributions
 r=receipt;project=Path(r['project']);need(project==ROOT,'observer project identity');e,spec,pins=read_provenance(project,True);validate_receipt(r,e,spec,pins);w=Path(r['native_build_directory']);m=Module.parse(Path(r['object']).read_bytes());check_native(m,spec);load_contract(project/MODEL).native_contract(m);need(m.name==str(w/'source-only'/MODEL/'IRQ.ASM'),'actual observer THEADR staged path');need(e['C_reference_source']==spec['C_reference_source']=='src/audio/irq.c'and sha(project/e['C_reference_source'])==e['C_reference_source_sha256'],'live genuine C reference source')
 target=project/'reference/DUKE3D.EXE';need(sha(target)==TARGET,'target identity');image=LEImage.parse(target.read_bytes());observer=snapshot([target,*[project/n for n in OBSERVERS]])
 # Both are fresh normal source recipes. The retained C descriptor/source are
 # genuine independent reference inputs, never the experimental574 full link.
 caller=audio.probe('sndscape',ROOT/'toolchains/watcom-10.0a',w/'normal-caller');cref=audio.probe('irq',Path(r['C_reference_home']),w/'C-reference');normal=Module.parse(Path(cref['source_build']['object']).read_bytes())
 exports=external_anchor_bindings(caller['verification']);nominations=[]
 for n in ('IRQ_SetVector_','IRQ_RestoreVector_'):
  need(n in exports and n in m.publics and n not in m.local_publics,'genuine normal caller nomination '+n);obj,addr=exports[n];seg,off=m.publics[n];need(seg==1,'callee CODE identity');nominations.append((obj,addr-off))
 need(len(set(nominations))==1,'consistent normal caller CODE root');obj,base=nominations[0];known={n:tuple(cref['verification']['publics'][n])for n in m.externals};b=infer_bindings(m,image,obj,base,known_symbols=known)
 try:verify_module(m,image,b['placements'],b['symbols'],group_frames={1:(3,0)})
 except ValueError as error:negative=str(error)
 else:raise ValueError('IRQ symbolic original PARA default unexpectedly passed')
 need(negative=='segment _DATA violates SEGDEF alignment','exact default PARA negative')
 ctx=replay_target_data_origin(home=ROOT/'toolchains/watcom-10.0-ga',build=w/'logical-origin');proof=verify_module(m,image,b['placements'],b['symbols'],group_frames={1:(3,0)},logical_origins=(ctx,));assert_contributions(proof,EXPECTED)
 library=ROOT/'reference/duke3d-reconstructions/AUDIO_WF.LIB';need(sha(library)==e['original_library_sha256'],'original library identity');member=e['original_member'];raw=library.read_bytes()[member['offset']:member['offset']+member['bytes']];need(hashlib.sha256(raw).hexdigest()==member['sha256'],'original member identity');original=Module.parse(raw);ob=infer_bindings(original,image,obj,base,known_symbols=known)
 try:verify_module(original,image,ob['placements'],ob['symbols'])
 except ValueError as error:original_negative=str(error)
 else:raise ValueError('IRQ symbolic original default unexpectedly passed')
 need(original_negative==negative,'original/source exact default PARA negative')
 op=verify_module(original,image,ob['placements'],ob['symbols'],logical_origins=(ctx,));need(external_anchor_bindings(proof)==external_anchor_bindings(op),'original public/global/import identities')
 need(original.default_libraries==spec['original_library_requirements']==['math387r','emu387']and not m.default_libraries,'actual inherited library requirements')
 roles=role_closure(m,normal,original,b,cref,ob,w);need(bytes(m._segment(4).data)==bytes(original._segment(4).data)and bytes(m._segment(5).data)==bytes(original._segment(5).data),'all initialized and zero-fill bytes literal original')
 validate_receipt(r,e,spec,pins);unchanged(observer);unchanged(pins)
 out={'kind':'Complete normal IRQ readable NASM contributions; no extra CODE credit','target_sha256':TARGET,'source':r['source'],'source_sha256':r['source_sha256'],'source_reference':PROVENANCE,'source_reference_sha256':sha(project/PROVENANCE),'descriptor':DESCRIPTOR,'descriptor_sha256':sha(project/DESCRIPTOR),'source_build':r,'placements':b['placements'],'constraints':b['constraints'],'verification':proof,'reference_verification':op,'default_absolute_alignment_negative':negative,'original_default_absolute_alignment_negative':original_negative,'all_original_roles':roles,'original_linkage_requirements':original.default_libraries,'native_default_libraries':m.default_libraries,'fresh_caller':{'module':'sndscape','source_build':caller['source_build'],'verification':caller['verification'],'independent_IRQ_anchors':{n:exports[n]for n in ('IRQ_SetVector_','IRQ_RestoreVector_')}},'C_reference':{'source_build':cref['source_build'],'verification':cref['verification']},'source_first_nominations':nominations,'private_external_anchor_names':[],'observer_inputs_sha256':observer,'source_credit':0,'new_CODE_bytes':0,'full_executable_rebuilt':False};dump(w/'whole-proof.json',out);return out

def role_closure(m,normal,original,b,cref,ob,w):
 import re
 cb={'placements':{int(k):tuple(v)for k,v in cref['placements'].items()},'symbols':{k:tuple(v)for k,v in cref['verification']['publics'].items()}}
 model=json.loads((ROOT/MODEL/'source-model.json').read_text());pending=[];labels={};section=None
 for line in (w/'IRQ.LST').read_text().splitlines():
  part=re.search(r'\bsegment (_TEXT|_DATA|_BSS) public',line)
  if part:section=part[1]
  name=re.search(r'\b(D32DosMemAlloc_|_callback_x|_irq_registers|_IRQ_Callback|_IRQ_RealModeCode|_irq_state):\s*$',line)
  if name:pending.append((name[1],section))
  address=re.match(r'\s*\d+\s+([0-9A-F]{8})\s',line)
  if address and pending:
   for n,s in pending:labels[n]=(s,int(address[1],16))
   pending=[]
 need(set(labels)==set(model['private_source_owners']),'complete genuine private listing definitions');sn={'_TEXT':1,'_DATA':4,'_BSS':5};private={n:(b['placements'][sn[s]][0],b['placements'][sn[s]][1]+off)for n,(s,off)in labels.items()}
 for n,value in private.items():need(value==tuple(cb['symbols'][n]),'private source/C physical identity '+n)
 originals={(f.segment,f.offset):f for f in original.fixups};native={(f.segment,f.offset):f for f in m.fixups};rows=[]
 def effective(mod,f,bindings):
  add=int.from_bytes(mod._segment(f.segment).data[f.offset:f.offset+f.width],'little')+f.displacement
  if f.target_method==0:o,v=bindings['placements'][f.target]
  elif f.target_method==2:o,v=bindings['symbols'][mod.externals[f.target-1]]
  else:raise ValueError('IRQ symbolic unmeasured native target')
  return o,(v+add)&0xffffffff
 for f in normal.fixups:
  g=originals[(f.segment,f.offset)];need((f.width,f.location,f.relative)==(g.width,g.location,g.relative),'actual original/C field geometry');expected=effective(original,g,ob);need(expected==effective(normal,f,cb),'original/C typed target identity');q=native.get((f.segment,f.offset))
  if q:
   need((q.width,q.location,q.relative)==(g.width,g.location,g.relative),'actual source typed field geometry');actual=effective(m,q,b);kind='native typed field'
  else:
   need(f.segment==1 and f.offset==502 and f.relative and normal.externals[f.target-1]=='D32DosMemAlloc_','single genuine resolved private CALL');disp=int.from_bytes(m._segment(1).data[502:506],'little',signed=True);actual=(b['placements'][1][0],b['placements'][1][1]+506+disp);need(actual==private['D32DosMemAlloc_'],'resolved private CALL identity');kind='assembler-resolved private relative CALL'
  need(actual==expected,'original/source typed target role');rows.append({'original':vars(g),'C_reference':vars(f),'native':vars(q)if q else None,'kind':kind,'target':actual,'original_owner':original.externals[g.target-1]if g.target_method==2 else original._segment(g.target).name,'original_private':g.target_method==2 and g.target in original.local_externals})
 # Original13 private names stay private owners or qualified actual members.
 members=json.loads((ROOT/'modules/irq.json').read_text())['private_member_correspondence'];members['_rmregs']={'owner':'_irq_registers','offset':0,'member':'registers'};identities={}
 for n in original.local_publics:
  if n in private:value=private[n];owner=n;offset=0
  else:need(n in members,'complete original private-name mapping '+n);view=members[n];owner=view['owner'];offset=view['offset'];value=(private[owner][0],private[owner][1]+offset)
  need(value==tuple(ob['symbols'][n])and n not in m.publics,'original private identity/scope '+n);identities[n]={'source_owner':owner,'member_offset':offset,'target':value,'qualified_member':members.get(n,{}).get('member',n.lstrip('_'))if n not in private else None}
 need(len(rows)==103 and len(m.fixups)==102 and len(identities)==13,'all original role/private closure');return {'original_fields':103,'native_fields':102,'resolved_private_relative_calls':1,'roles':rows,'original_private_identities':identities,'genuine_source_private_owners':private}

def probe(home,build):return observe(build_source(home,build))
if __name__=='__main__':
 import argparse
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.5');p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True);p.add_argument('--source-only',action='store_true');a=p.parse_args();r=build_source(a.home,a.build);out=r if a.source_only else observe(r);dump(a.report,out)
