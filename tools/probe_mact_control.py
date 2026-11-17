"""Complete CONTROL symbolic source, closed source-only producer then observer."""
from pathlib import Path
import sys,os,json,hashlib,shutil,tempfile,subprocess,importlib.util,dataclasses
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from omf32 import Module
from profiles.gnu_elf_omf.identity import checked_home,digest,profile
from profiles.gnu_elf_omf.elf32 import elf
from profiles.capstone import identity as decoder
MODEL='src/mact/control_complete';DESCRIPTOR='modules/mact_control.json';PROVENANCE='evidence/mact-control-source-reference.json'
SOURCES=[MODEL+'/'+p for p in ['CONTROL.S','CONTROL_LITERALS.INC','models.py','elf_contract.py','coff_contract.py','operand_roles.json','C-counterpart/control-525.c.txt','C-counterpart/control-native.c.txt','lineage/jfmact-control-primary.c.txt','C-counterpart/include/_control.h','C-counterpart/include/control.h','C-counterpart/include/keyboard.h','C-counterpart/include/mouse.h','C-counterpart/include/types.h','C-counterpart/include/util_lib.h','C-counterpart/include/watcom.h']]
NOTICES=[MODEL+'/README.md',MODEL+'/GPL-2.0.txt',MODEL+'/C-counterpart/README.md','profiles/gnu_elf_omf/README.md','profiles/capstone/README.md']
PRODUCERS=['tools/probe_mact_control.py','profiles/gnu_elf_omf/identity.py','profiles/gnu_elf_omf/profile.json','profiles/gnu_elf_omf/elf32.py','profiles/watcom/tools/omf32.py','profiles/capstone/identity.py','profiles/capstone/files.json']
OBSERVERS=['tools/prove_module.py','tools/infer_bindings.py','tools/map_candidates.py','tools/match_function.py','tools/verify_module.py','profiles/watcom/tools/le.py','tools/mact_control_roles.py','tools/mact_control_callees.py','tools/inventory_watcom_runtime.py']
EXPECTED={'initialized_bytes':7452,'zero_fill_bytes':1612,'verified_fixups':470}
TARGETSHA='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4';LIBRARY='reference/duke3d-reconstructions/MACT386.LIB';LIBSHA='957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db';MEMBERSHA='2c046c087b2c6825fa77f5b8a5c0643fea7a2fc2148cf8c231d0f4dc90a5e129'
def need(ok,message):
 if not ok:raise ValueError('CONTROL '+message)
def dump(path,value):path.write_text(json.dumps(value,indent=2,default=lambda x:x.hex()if isinstance(x,bytes)else x)+'\n')
def snapshot(paths):return {str(Path(p).resolve()):digest(p)for p in paths}
def unchanged(pins):need(all(Path(p).is_file()and digest(p)==h for p,h in pins.items()),'changed source/stage/tool/native output')
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def inventory(m):
 return {'name':m.name,'segments':[[s.name,s.class_name,s.size,s.attributes,s.access]for s in m.segments],'publics':{n:list(v)for n,v in m.publics.items()},'local_publics':sorted(m.local_publics),'externals':m.externals,'local_externals':sorted(m.local_externals),'groups':[[n,list(v)]for n,v in m.groups],'fixups':[dataclasses.asdict(f)for f in m.fixups],'default_libraries':m.default_libraries,'far_call_optimization_segments':sorted(m.far_call_optimization_segments),'format':m.format,'comments':[[k,v.hex()]for k,v in m.comments],'code_data_ranges':[list(v)for v in m.code_data_ranges],'dosseg_directives':m.dosseg_directives,'format_source':m.format_source,'line_numbers':m.line_numbers,'thread_definitions':m.thread_definitions,'source_records':m.source_records,'fixup_encodings':json.loads(json.dumps(m.fixup_encodings,default=lambda x:x.hex()if isinstance(x,bytes)else x))}
def read_provenance(project=ROOT):
 project=Path(project).resolve();raw=(project/PROVENANCE).read_bytes();d=(project/DESCRIPTOR).read_bytes();e=json.loads(raw);spec=json.loads(d)
 for key,paths in [('tracked_sources_sha256',SOURCES),('notice_files_sha256',NOTICES),('producer_tools_sha256',PRODUCERS)]:
  need(set(e[key])==set(paths),'closed '+key)
  for p,h in e[key].items():need(digest(project/p)==h,'changed source/tool/notice '+p)
 need(digest(project/DESCRIPTOR)==e['descriptor_sha256']and spec['name']=='mact_control'and spec['expected']==EXPECTED and spec['options']==profile()['options'],'descriptor/profile identity')
 pins={str((project/p).resolve()):h for key in ['tracked_sources_sha256','notice_files_sha256','producer_tools_sha256']for p,h in e[key].items()};pins.update(snapshot([project/PROVENANCE,project/DESCRIPTOR]));unchanged(pins);return e,spec,pins
def check_native(m,spec):need(inventory(m)==spec['native_inventory'],'complete native metadata/scope/all470 typed roles')
def check_stage(stage,expected,names):
 unchanged(expected);need({str(p.relative_to(stage))for p in stage.rglob('*')if p.is_file()}==set(names),'exact source stage file set');need(not any(p.is_symlink()for p in stage.rglob('*')),'source stage symlink')
def build_source(home=None,build=None,*,project=ROOT,decoder_home=None):
 project=Path(project).resolve();home=Path(home or os.environ.get('GNU_ELF_OMF_HOME',ROOT/'toolchains/gnu-elf-omf')).resolve();decoder_home=Path(decoder_home or os.environ.get('CAPSTONE_HOME',ROOT/'toolchains/capstone')).resolve();e,spec,pins=read_provenance(project);tools=checked_home(home);dec=decoder.checked_home(decoder_home);decoder.load(decoder_home);pins.update({str(home/p):h for p,h in tools.items()});pins.update({str(decoder_home/p):h for p,h in dec.items()});pins.update(snapshot([Path(sys.executable).resolve()]));parent=Path(build or project/'build/mact-control-proof').resolve();parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='control-elf-',dir=parent));stage=w/'source-only';stage.mkdir()
 for path in SOURCES+NOTICES:
  q=stage/path;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(project/path,q)
 unchanged(pins);expected={str((stage/p).resolve()):pins[str((project/p).resolve())]for p in SOURCES+NOTICES};names=set(SOURCES+NOTICES);check_stage(stage,expected,names)
 model=load('control_literal_models',stage/MODEL/'models.py');literal,_=model.generate();need((stage/MODEL/'CONTROL_LITERALS.INC').read_text()==literal,'generated real literal capacities');text=(stage/MODEL/'CONTROL.S').read_text().replace('.include "CONTROL_LITERALS.INC"',literal);generated=stage/MODEL/'CONTROL_GENERATED.S';expected[str(generated.resolve())]=hashlib.sha256(text.encode()).hexdigest();names.add(str(generated.relative_to(stage)));generated.write_text(text);guard=load('control_source_guard',stage/MODEL/'elf_contract.py');guard.source_preflight(text,model);unchanged(pins);check_stage(stage,expected,names);checked_home(home);decoder.checked_home(decoder_home)
 commands=[[str(home/'bin/as-new'),*spec['options']['assembler'],'--listing-rhs-width=4096','--listing-cont-lines=256','-al='+str(w/'CONTROL.LST'),'-o',str(w/'CONTROL.ELF'),str(generated)]]
 p=subprocess.run(commands[-1],capture_output=True,text=True);(w/'AS.LOG').write_text(p.stdout+p.stderr);need(p.returncode==0 and not(p.stdout or p.stderr),'assembler warning/error');unchanged(pins);check_stage(stage,expected,names);checked_home(home);decoder.checked_home(decoder_home)
 ev=elf(w/'CONTROL.ELF');pre=guard.preflight(w/'CONTROL.ELF',text,(w/'CONTROL.LST').read_text(),ev,model);dump(w/'preflight.json',pre);outputs=snapshot([w/'CONTROL.ELF',w/'CONTROL.LST',w/'preflight.json',w/'AS.LOG'])
 for form,suffix in [('-fomf32','OBJ'),('-fcoff32','COFF')]:
  commands.append([str(home/'bin/objconv'),form,'-wex',str(w/'CONTROL.ELF'),str(w/('CONTROL.'+suffix))]);p=subprocess.run(commands[-1],capture_output=True,text=True);(w/('CONVERT-'+suffix+'.LOG')).write_text(p.stdout+p.stderr);need(p.returncode==0 and not p.stderr and'warning'not in p.stdout.lower(),'converter warning/error');unchanged(pins);check_stage(stage,expected,names);unchanged(outputs);checked_home(home);decoder.checked_home(decoder_home);outputs.update(snapshot([w/('CONTROL.'+suffix),w/('CONVERT-'+suffix+'.LOG')]))
 m=Module.parse((w/'CONTROL.OBJ').read_bytes());check_native(m,spec);post=guard.postflight(ev,m,pre);coff=load('control_coff_guard',stage/MODEL/'coff_contract.py').check(w,ev,m);dump(w/'postflight.json',post);dump(w/'coff-identity.json',coff);dump(w/'commands.json',commands);outputs.update(snapshot([w/'postflight.json',w/'coff-identity.json',w/'commands.json']));unchanged(pins);check_stage(stage,expected,names);unchanged(outputs);checked_home(home);decoder.checked_home(decoder_home)
 result={'source_only':True,'original_target_or_own_object_read':False,'project':str(project),'home':str(home),'decoder_home':str(decoder_home),'inputs_sha256':pins,'staged_sha256':expected,'staged_file_names':sorted(names),'native_outputs_sha256':outputs,'object':str(w/'CONTROL.OBJ'),'object_sha256':digest(w/'CONTROL.OBJ'),'native_inventory':inventory(m),'commands':commands,'original_C_default_LIB_requirements':['math387r','emu387'],'native_default_LIBs':m.default_libraries,'source_credit':0};dump(w/'source-build.json',result);return w

def observe(work,*,project=ROOT):
 from le import LEImage
 from tools.map_candidates import locate
 from tools.infer_bindings import infer_bindings
 from tools.verify_module import verify_module,external_anchor_bindings
 from tools.mact_control_roles import audit_roles
 from tools.mact_control_callees import verify_callees
 project=Path(project).resolve();w=Path(work).resolve();r=json.loads((w/'source-build.json').read_text());need(r['source_only']and not r['original_target_or_own_object_read']and r['project']==str(project),'source-first boundary')
 for group in ['inputs_sha256','staged_sha256','native_outputs_sha256']:unchanged(r[group])
 check_stage(w/'source-only',r['staged_sha256'],r['staged_file_names']);checked_home(r['home']);decoder.checked_home(r['decoder_home']);e,spec,current=read_provenance(project);need(set(e['observer_tools_sha256'])==set(OBSERVERS),'observer keyset');need(all(digest(ROOT/p)==h for p,h in e['observer_tools_sha256'].items()),'observer identity');observer=snapshot([ROOT/p for p in OBSERVERS]+[ROOT/LIBRARY,ROOT/'reference/DUKE3D.EXE']);need(digest(ROOT/LIBRARY)==LIBSHA and digest(ROOT/'reference/DUKE3D.EXE')==TARGETSHA,'original immutable observers');raw=(ROOT/LIBRARY).read_bytes()[95744:115441];need(hashlib.sha256(raw).hexdigest()==MEMBERSHA,'whole original member identity');orig=Module.parse(raw);m=Module.parse((w/'CONTROL.OBJ').read_bytes());check_native(m,spec);image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());loc=locate(m,{i:image.object_bytes(i)for i,o in enumerate(image.objects,1)if o.flags&4});candidates=sorted({(v['object'],v['offset']-row['source_offset'])for row in loc for v in row.get('locations',[])});attempts=[];wins=[]
 for obj,base in candidates:
  try:
   ob=infer_bindings(orig,image,obj,base);op=verify_module(orig,image,ob['placements'],ob['symbols']);names={s.name:i+1 for i,s in enumerate(m.segments)};places={names[orig._segment(i).name]:tuple(v)for i,v in ob['placements'].items()};p=verify_module(m,image,places,external_anchor_bindings(op));need(all(p[k]==v and op[k]==v for k,v in EXPECTED.items()),'complete native/original whole totals');wins.append((ob,op,places,p));attempts.append({'placement':[obj,base],'match':True})
  except(ValueError,AssertionError)as err:attempts.append({'placement':[obj,base],'match':False,'error':str(err)})
 need(len(wins)==1,'unique full whole source candidate '+repr(attempts));ob,op,places,p=wins[0];pre=json.loads((w/'preflight.json').read_text());roles=audit_roles(orig,m,pre,places,p,op);dump(w/'role-closure.json',roles);needed={n:external_anchor_bindings(p)[n]for n in spec['original_imports']};callees,callee_pins=verify_callees(image,needed)
 for group in ['inputs_sha256','staged_sha256','native_outputs_sha256']:unchanged(r[group])
 check_stage(w/'source-only',r['staged_sha256'],r['staged_file_names']);unchanged(observer);unchanged(callee_pins);checked_home(r['home']);decoder.checked_home(r['decoder_home'])
 out={'kind':'Complete normal CONTROL symbolic source; no whole executable claim','source':MODEL+'/CONTROL.S','source_sha256':digest(project/MODEL/'CONTROL.S'),'source_reference_sha256':digest(project/PROVENANCE),'descriptor':DESCRIPTOR,'descriptor_sha256':digest(project/DESCRIPTOR),'target_sha256':TARGETSHA,'source_build':r,'verification':p,'reference_verification':op,'placements':places,'native_inventory':inventory(m),'role_closure':roles,'nominations':loc,'complete_candidate_gates':attempts,'callee_verifications':callees,'callee_inputs_sha256':callee_pins,'observer_inputs_sha256':observer,'source_credit':0,'full_executable_rebuilt':False};dump(w/'whole-proof.json',out);return out

def probe(home,build):return observe(build_source(home,build))
if __name__=='__main__':
 import argparse
 a=argparse.ArgumentParser(description=__doc__);a.add_argument('--build',type=Path,required=True);a.add_argument('--report',type=Path,required=True);a.add_argument('--elf-home',type=Path);a.add_argument('--decoder-home',type=Path);a.add_argument('--source-only',action='store_true');v=a.parse_args();w=build_source(v.elf_home,v.build,decoder_home=v.decoder_home);r=json.loads((w/'source-build.json').read_text())if v.source_only else observe(w);v.report.parent.mkdir(parents=True,exist_ok=True);dump(v.report,r);print(w)
