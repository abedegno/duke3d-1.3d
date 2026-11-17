"""Complete source-first LBMLIB ELF capsule, target/archive observer-only."""
from pathlib import Path
import sys,os,json,hashlib,shutil,tempfile,subprocess,importlib.util,dataclasses
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from omf32 import Module
from profiles.gnu_elf_omf_imports.identity import checked_home,digest,profile
from profiles.gnu_elf_omf.elf32 import elf
MODEL='src/mact/lbmlib';PROVENANCE='evidence/mact-lbmlib-source-reference.json';DESCRIPTOR='modules/mact_lbmlib.json'
SOURCES=[MODEL+'/'+p for p in ['LBMLIB.S','lbmlib.c','include/TYPES.H','include/LBMLIB.H','include/_LBMLIB.H','include/UTIL_LIB.H','contract.py']]
NOTICES=[MODEL+'/README.md',MODEL+'/NOTICES.md',MODEL+'/SEMANTICS.md',MODEL+'/GPL.TXT','profiles/gnu_elf_omf_imports/README.md']
PRODUCERS=['tools/probe_mact_lbmlib.py','profiles/gnu_elf_omf_imports/identity.py','profiles/gnu_elf_omf_imports/profile.json','profiles/gnu_elf_omf_imports/apply_fork.py','profiles/gnu_elf_omf_imports/setup.py','profiles/gnu_elf_omf_imports/defined-global.patch','profiles/gnu_elf_omf_imports/unused-imports.patch','profiles/gnu_elf_omf/elf32.py','profiles/watcom/tools/omf32.py']
OBSERVERS=['tools/prove_module.py','tools/infer_bindings.py','tools/map_candidates.py','tools/match_function.py','tools/verify_module.py','profiles/watcom/tools/le.py']
EXPECTED={'initialized_bytes':1923,'zero_fill_bytes':1152,'verified_fixups':33};TARGETSHA='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4';LIBRARY='reference/duke3d-reconstructions/MACT386.LIB';LIBSHA='957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db';MEMBERSHA='4986297e3ae2a4b1e2e13222f6355215b975c3244cedd4393426d3948db60c80'
def module_options():return profile()['options']
def tree(root):return{str(p.resolve()):digest(p)for p in Path(root).rglob('*')if p.is_file()}
def staged_unchanged(root,pins):need(tree(root)==pins,'staged source/file set changed')
def need(condition,message):
 if not condition:raise ValueError('LBMLIB '+message)
def dump(p,j):p.write_text(json.dumps(j,indent=2)+'\n')
def snapshot(paths):return{str(Path(p).resolve()):digest(p)for p in paths}
def unchanged(pins):
 need(all(Path(p).is_file()and digest(p)==h for p,h in pins.items()),'input/output changed')
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m

def inventory(m):
    return {'name': m.name, 'segments': [[s.name, s.class_name, s.size, s.attributes, s.access] for s in m.segments], 'publics': {n: list(v) for n, v in m.publics.items()}, 'local_publics': sorted(m.local_publics), 'externals': m.externals, 'local_externals': sorted(m.local_externals), 'groups': [[n, list(v)] for n, v in m.groups], 'fixups': [dataclasses.asdict(f) for f in m.fixups], 'default_libraries': m.default_libraries, 'far_call_optimization_segments': sorted(m.far_call_optimization_segments), 'format': m.format, 'comments': [[k, v.hex()] for k, v in m.comments], 'code_data_ranges': [list(v) for v in m.code_data_ranges], 'dosseg_directives': m.dosseg_directives, 'format_source': m.format_source, 'line_numbers': m.line_numbers, 'thread_definitions': m.thread_definitions, 'source_records': m.source_records, 'fixup_encodings': json.loads(json.dumps(m.fixup_encodings, default=lambda x: x.hex() if isinstance(x, bytes) else x))}
def read_provenance(project=ROOT):
 project=Path(project).resolve();raw=(project/PROVENANCE).read_bytes();desc=(project/DESCRIPTOR).read_bytes();e=json.loads(raw);spec=json.loads(desc)
 for field,paths in [('tracked_sources_sha256',SOURCES),('notice_files_sha256',NOTICES),('producer_tools_sha256',PRODUCERS)]:
  need(set(e[field])==set(paths),'closed '+field)
  for p,h in e[field].items():need(digest(project/p)==h,'changed source/tool/notice '+p)
 need(hashlib.sha256(desc).hexdigest()==e['descriptor_sha256']and spec['name']=='mact_lbmlib'and spec['expected']==EXPECTED and spec['options']==module_options(),'fixed descriptor/profile');need(spec['extra_converter_observation_options']==['-fcoff32','-wex'],'finite COFF recipe');pins={str((project/p).resolve()):h for field in ['tracked_sources_sha256','notice_files_sha256','producer_tools_sha256']for p,h in e[field].items()};pins.update({str(project/PROVENANCE):hashlib.sha256(raw).hexdigest(),str(project/DESCRIPTOR):hashlib.sha256(desc).hexdigest()});unchanged(pins);return e,spec,pins

def check_native(m,spec):need(inventory(m)==spec['native_inventory'],'complete native metadata/scope/typed roles')

def build_source(home=None,build=None,*,project=ROOT):
 project=Path(project).resolve();home=Path(home or os.environ.get('GNU_ELF_IMPORTS_HOME',ROOT/'toolchains/gnu-elf-omf-imports')).resolve();e,spec,pins=read_provenance(project);tools=checked_home(home);pins.update({str(home/p):h for p,h in tools.items()});pins.update(snapshot([Path(sys.executable).resolve()]));parent=Path(build or project/'build/lbmlib').resolve();parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='lbmlib-',dir=parent));stage=w/'source-only';stage.mkdir()
 for p in SOURCES+NOTICES:
  q=stage/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(project/p,q)
 unchanged(pins);staged=snapshot(stage/p for p in SOURCES+NOTICES)
 need(all(digest(stage/p)==pins[str((project/p).resolve())]for p in SOURCES+NOTICES),'source copy differs');model=stage/MODEL;contract=load('closed_lbmlib_contract',model/'contract.py');contract.headers(model/'include');staged_unchanged(stage,staged);unchanged(pins);logical=contract.source((model/'LBMLIB.S').read_text());staged_unchanged(stage,staged);unchanged(pins)
 # Initial live/copy pins remain immutable through preflight and all native tools.
 commands=[[str(home/'bin/as-new'),*module_options()['assembler'],'-I',str(model),'-al='+str(w/'LBMLIB.LST'),'-o',str(w/'LBMLIB.ELF'),str(model/'LBMLIB.S')]];p=subprocess.run(commands[-1],capture_output=True,text=True);(w/'GAS.LOG').write_text(p.stdout+p.stderr);need(p.returncode==0 and not(p.stdout or p.stderr),'assembler error/warning');unchanged(pins);staged_unchanged(stage,staged);checked_home(home);native=snapshot([w/'LBMLIB.ELF',w/'LBMLIB.LST']);eview=elf(w/'LBMLIB.ELF');schema=contract.elf((w/'LBMLIB.ELF').read_bytes(),eview,logical,(w/'LBMLIB.LST').read_text());unchanged(native);dump(w/'preflight.json',{'logical_source':logical,'ELF_schema':schema,'elf':eview});native.update(snapshot([w/'preflight.json']));commands.append([str(home/'bin/objconv'),'-fcoff32','-wex',str(w/'LBMLIB.ELF'),str(w/'LBMLIB.COFF')]);p=subprocess.run(commands[-1],capture_output=True,text=True);(w/'COFF.LOG').write_text(p.stdout+p.stderr);need(p.returncode==0 and not p.stderr and'warning'not in p.stdout.lower(),'COFF converter diagnostic');unchanged(pins);staged_unchanged(stage,staged);unchanged(native);checked_home(home);native.update(snapshot([w/'LBMLIB.COFF']));coff=contract.coff((w/'LBMLIB.COFF').read_bytes(),eview);unchanged(native);dump(w/'coff-audit.json',coff);native.update(snapshot([w/'coff-audit.json']));commands.append([str(home/'bin/objconv'),*profile()['options']['converter'],str(w/'LBMLIB.ELF'),str(w/'LBMLIB.OBJ')]);p=subprocess.run(commands[-1],capture_output=True,text=True);(w/'CONVERT.LOG').write_text(p.stdout+p.stderr);need(p.returncode==0 and not p.stderr and'warning'not in p.stdout.lower(),'converter error/warning');unchanged(pins);staged_unchanged(stage,staged);unchanged(native);checked_home(home);native.update(snapshot([w/'LBMLIB.OBJ']));m=Module.parse((w/'LBMLIB.OBJ').read_bytes());check_native(m,spec);contract.native(m,eview,coff);unchanged(native);unchanged(pins);staged_unchanged(stage,staged);checked_home(home);receipt={'source_only':True,'original_or_target_read':False,'project':str(project),'home':str(home),'inputs_sha256':pins,'staged_sha256':staged,'native_outputs_sha256':native,'object':str(w/'LBMLIB.OBJ'),'object_sha256':digest(w/'LBMLIB.OBJ'),'commands':commands,'native_inventory':inventory(m),'source_credit':0};dump(w/'source-build.json',receipt);return w


def observe(work,*,project=ROOT):
 from le import LEImage
 from tools.infer_bindings import infer_bindings
 from tools.map_candidates import locate
 from tools.verify_module import verify_module,external_anchor_bindings
 project=Path(project).resolve();w=Path(work).resolve();r=json.loads((w/'source-build.json').read_text());need(r['source_only']and not r['original_or_target_read']and r['project']==str(project),'source boundary/project');unchanged(r['inputs_sha256']);unchanged(r['staged_sha256']);unchanged(r['native_outputs_sha256']);checked_home(r['home']);e,spec,pins=read_provenance(project);need(set(e['observer_tools_sha256'])==set(OBSERVERS),'observer key set');need(all(digest(ROOT/p)==h for p,h in e['observer_tools_sha256'].items()),'observer identities');observer=snapshot([ROOT/p for p in OBSERVERS]+[ROOT/LIBRARY,ROOT/'reference/DUKE3D.EXE']);need(digest(ROOT/LIBRARY)==LIBSHA and digest(ROOT/'reference/DUKE3D.EXE')==TARGETSHA,'reference identities');raw=(ROOT/LIBRARY).read_bytes()[79360:83364];need(hashlib.sha256(raw).hexdigest()==MEMBERSHA,'original member');original=Module.parse(raw);need(original.default_libraries==spec['original_default_library_requirements'],'original default-library resolution obligations');native=Module.parse(Path(r['object']).read_bytes());check_native(native,spec);contract=load('observed_lbmlib_contract',project/MODEL/'contract.py');roles=contract.roles(original,native,json.loads((w/'preflight.json').read_text())['elf']);image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());locations=locate(native,{n:image.object_bytes(n)for n,o in enumerate(image.objects,1)if o.flags&4});candidates=[];passed=[]
 for row in locations:
  for loc in row.get('locations',[]):
   key=(loc['object'],loc['offset']-row['source_offset'])
   if any(tuple(v['placement'])==key for v in candidates):continue
   try:
    b=infer_bindings(native,image,*key);ob=infer_bindings(original,image,*key);p=verify_module(native,image,b['placements'],b['symbols']);op=verify_module(original,image,ob['placements'],ob['symbols']);need(not(b['unplaced_segments']or ob['unplaced_segments']),'unplaced storage');need(all(p[k]==v for k,v in EXPECTED.items())and all(p[k]==op[k]for k in p if k not in ('publics','local_symbols')),'whole original/source proof');need(external_anchor_bindings(p)==external_anchor_bindings(op),'source/original anchors');passed.append((b,ob,p,op));candidates.append({'placement':key,'match':True})
   except ValueError as err:candidates.append({'placement':key,'match':False,'error':str(err)})
 need(len(passed)==1,'unique full-source nomination winner');b,ob,p,op=passed[0];need(original.local_publics=={'_bitplanes'}and not(native.local_publics or native.local_externals),'one actual original private/qualified source scope');need('_bitplanes'not in external_anchor_bindings(p),'private anchor leak');data_index=next(i for i,s in enumerate(native.segments,1)if s.name=='_BSS');obj,base=b['placements'][data_index];need(tuple(op['local_symbols']['_bitplanes'])==(obj,base),'private BSS target correspondence');unchanged(r['inputs_sha256']);unchanged(r['staged_sha256']);unchanged(r['native_outputs_sha256']);unchanged(observer);checked_home(r['home']);out={'kind':'complete LBMLIB source contributions, not full executable','source':MODEL+'/LBMLIB.S','source_sha256':digest(project/MODEL/'LBMLIB.S'),'source_reference_sha256':digest(project/PROVENANCE),'descriptor':DESCRIPTOR,'descriptor_sha256':digest(project/DESCRIPTOR),'target_sha256':TARGETSHA,'source_only':True,'original_or_target_read_during_production':False,'native_build_directory':str(w),'source_build':r,'verification':p,'reference_verification':op,'placements':b['placements'],'constraints':b['constraints'],'all_original_roles':roles,'original_default_libraries':original.default_libraries,'native_default_libraries':native.default_libraries,'runtime_private_definitions':1,'source_private_definitions':44,'instructions':604,'private_anchor_names':[],'genuine_unused_imports':[],'native_inventory':inventory(native),'nominations':locations,'all_candidates':candidates,'callee_roles':{n:p['publics'][n]for n in ['memset_','Error_','MotoLong_','MotoShort_']},'observer_inputs_sha256':observer,'source_credit':0,'full_executable_rebuilt':False};dump(w/'whole-proof.json',out);return out

def probe(home,build):return observe(build_source(home,build))
if __name__=='__main__':
 import argparse
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True);p.add_argument('--elf-home',type=Path);p.add_argument('--source-only',action='store_true');a=p.parse_args();w=build_source(a.elf_home,a.build);r=json.loads((w/'source-build.json').read_text())if a.source_only else observe(w);a.report.parent.mkdir(parents=True,exist_ok=True);dump(a.report,r);print(w)
