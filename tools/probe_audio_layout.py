"""Five fixed ordinary-C audio layouts; source-only compilation precedes observation."""
from pathlib import Path
from dataclasses import is_dataclass,asdict
import argparse,hashlib,json,os,shutil,sys,tempfile
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from runner import compile_source,compiler_bin
from omf32 import Module
NAMES=('sndscape','sndsrc','pas16','irq','blaster');HOMES={'sndscape':'watcom-10.0a','sndsrc':'watcom-10.0-ga','pas16':'watcom-10.0a','irq':'watcom-10.5','blaster':'watcom-10.0a'}
PROFILE='profiles/watcom/audio-layout-tools.json';PROVENANCE='evidence/audio-layout-source-reference.json';NOTICE='src/audio/layout-README.md';NOTICES=[NOTICE,'src/audio/gpl.txt'];OPTIONS=['/omaxnet','/zp4','/5r'];REFERENCES=['dukenukem3d/audiolib/SOURCE'];OVERLAYS=['src/include']
TOOLS=['tools/probe_audio_layout.py','tools/prove_module.py','profiles/watcom/tools/runner.py','profiles/watcom/tools/omf32.py',PROFILE];OBSERVERS=['tools/infer_bindings.py','tools/verify_module.py','tools/match_function.py','profiles/watcom/tools/le.py'];TARGET_SHA='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'
def need(q,m):
 if not q:raise ValueError('audio layout '+m)
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,d):Path(p).parent.mkdir(parents=True,exist_ok=True);Path(p).write_text(json.dumps(d,indent=2)+'\n')
def snapshot(paths):return {str(p):digest(p)for p in paths}
def unchanged(pins):need(all(Path(p).is_file()and digest(p)==v for p,v in pins.items()),'live/stage/tool/output identity changed')
def encode(v):
 if isinstance(v,(bytes,bytearray)):return {'hex':bytes(v).hex()}
 if is_dataclass(v):return encode(vars(v))
 if isinstance(v,dict):return {str(k):encode(x)for k,x in v.items()}
 if isinstance(v,set):return sorted(encode(x)for x in v)
 if isinstance(v,(list,tuple)):return [encode(x)for x in v]
 return v
def metadata(m):
 result={k:encode(v)for k,v in vars(m).items()if k not in ['segments','publics','externals','local_publics','local_externals','groups','fixups','default_libraries','comments']};comments=[]
 for kind,payload in m.comments:
  if kind==0xe9 and payload:
   need(len(payload)>=5 and payload[4]==len(payload)-5,'malformed native E9 provenance');comments.append([kind,{'E9_path':payload[5:].decode('latin1'),'variable_timestamp_bytes':4}])
  else:comments.append([kind,{'hex':payload.hex()}])
 result['comments']=comments;return result

def check_native(m,spec):
 from tools.prove_module import assert_native_inventory
 assert_native_inventory(m,spec)
 required={'native_segments','expected_default_libraries','expected_publics','expected_local_publics','expected_externals','expected_local_externals','expected_fixups','expected_groups','audio_native_metadata'};need(required<=set(spec),'incomplete module native contract')
 need(m.publics=={n:tuple(v)for n,v in spec['expected_publics'].items()}and m.local_publics==set(spec['expected_local_publics']),'complete public/private definitions differ')
 need(m.externals==spec['expected_externals']and sorted(m.local_externals)==spec['expected_local_externals'],'complete external scopes differ')
 need([asdict(f)for f in m.fixups]==spec['expected_fixups'],'typed native fields differ')
 need([[n,list(v)]for n,v in m.groups]==spec['expected_groups'],'group membership differs')
 need(metadata(m)==spec['audio_native_metadata'],'complete native metadata differs')

def header_sources():
 out={}
 for folder in REFERENCES+OVERLAYS:
  p=ROOT/folder;need(p.is_dir(),'missing source header folder')
  for h in p.iterdir():
   if h.is_file()and h.suffix.lower()=='.h':out[str(h.relative_to(ROOT))]=digest(h)
 return out

_LOADED={n:digest(ROOT/n)for n in ['tools/probe_audio_layout.py','profiles/watcom/tools/runner.py','profiles/watcom/tools/omf32.py']}

def read_contract(name):
 need(name in NAMES,'unknown module');p=ROOT/PROVENANCE;e=json.loads(p.read_text());required={'sources_sha256','descriptors_sha256','headers_sha256','prepared_headers_sha256','producer_tools_sha256','observer_tools_sha256','notice_files_sha256','python_sha256','emulator_sha256','scope'};need(required<=set(e),'missing provenance field')
 sets={'sources_sha256':{f'src/audio/{n}.c'for n in NAMES},'descriptors_sha256':{f'modules/{n}.json'for n in NAMES},'producer_tools_sha256':set(TOOLS),'observer_tools_sha256':set(OBSERVERS),'notice_files_sha256':set(NOTICES)}
 for key,expected in sets.items():
  need(set(e[key])==expected,'closed '+key)
  for n,h in e[key].items():need((ROOT/n).is_file()and digest(ROOT/n)==h,'changed '+n)
 need(all(e['producer_tools_sha256'][n]==v for n,v in _LOADED.items()),'loaded producer identity differs');need(header_sources()==e['headers_sha256'],'closed live header graph differs');need(digest(Path(sys.executable).resolve())==e['python_sha256'],'Python identity')
 emulator=Path(os.environ.get('EXHUME_DOSBOX_X')or shutil.which('dosbox-x')).resolve();need(digest(emulator)==e['emulator_sha256'],'emulator identity')
 spec=json.loads((ROOT/f'modules/{name}.json').read_text());need(spec['source']==f'src/audio/{name}.c'and spec['options']==OPTIONS,'fixed source/options');pins=snapshot([p,*[ROOT/n for k in sets for n in e[k]],*[ROOT/n for n in e['headers_sha256']],Path(sys.executable).resolve(),emulator]);return e,spec,pins

def checked_home(name,home):
 expected=json.loads((ROOT/PROFILE).read_text())[HOMES[name]];actual={str(p.relative_to(home)):digest(p)for p in sorted(home.rglob('*'))if p.is_file()};need(actual==expected,'complete compiler home differs');return actual

def check_stage(work,name,expected_headers):
 stage=Path(work)/'source-only';headers=Path(work)/'include'
 need({p.name for p in stage.iterdir()}=={name+'.c','layout-README.md','gpl.txt'} and {p.name for p in headers.iterdir()}==set(expected_headers),'staged file set differs')
 need(all(p.is_file()and not p.is_symlink()for p in [*stage.iterdir(),*headers.iterdir()]),'staged file set contains nonregular input')

def expected_stage(work,name,e,live_pins):
 work=Path(work);stage=work/'source-only';headers=work/'include'
 for n,value in [(f'src/audio/{name}.c',e['sources_sha256'][f'src/audio/{name}.c']),*[(n,e['notice_files_sha256'][n])for n in NOTICES]]:need(live_pins.get(str(ROOT/n))==value,'pre-copy expected stage/live pin differs')
 return {str(stage/(name+'.c')):e['sources_sha256'][f'src/audio/{name}.c'],**{str(stage/Path(n).name):e['notice_files_sha256'][n]for n in NOTICES},**{str(headers/n):h for n,h in e['prepared_headers_sha256'].items()}}

def check_expected_stage(work,name,e,live_pins,claimed=None):
 check_stage(work,name,e['prepared_headers_sha256']);expected=expected_stage(work,name,e,live_pins)
 need(claimed is None or claimed==expected,'pre-copy expected stage receipt differs')
 need(snapshot(Path(p)for p in expected)==expected,'pre-copy expected stage bytes differ')
 return expected

def build_source(name,home,build):
 from tools.prove_module import prepare_headers
 home=Path(home).resolve();e,spec,pins=read_contract(name);tools=checked_home(name,home);parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);work=Path(tempfile.mkdtemp(prefix=name+'-audio-',dir=parent));stage=work/'source-only';stage.mkdir();expected=expected_stage(work,name,e,pins);source=stage/f'{name}.c';shutil.copyfile(ROOT/spec['source'],source)
 for notice in NOTICES:shutil.copyfile(ROOT/notice,stage/Path(notice).name)
 headers=work/'include';prepare_headers([ROOT/n for n in REFERENCES],[ROOT/n for n in OVERLAYS],headers);actual={p.name:digest(p)for p in headers.iterdir()};need(actual==e['prepared_headers_sha256'],'prepared source header graph differs');staged=check_expected_stage(work,name,e,pins);need(staged==expected,'pre-copy expected stage changed');unchanged(pins);compile_source(home,source,work/f'{name}.obj',OPTIONS,45,include_dirs=[headers]);text=(work/f'{name}.log').read_text();need('0 warnings, 0 errors'in text and'Warning!'not in text and'Error!'not in text,'native diagnostic');m=Module.parse((work/f'{name}.obj').read_bytes());check_native(m,spec);outputs=snapshot([work/f'{name}.obj',work/f'{name}.log']);unchanged(pins);unchanged(staged);unchanged(outputs);check_expected_stage(work,name,e,pins,staged);need(header_sources()==e['headers_sha256'],'live source header set changed');checked_home(name,home)
 receipt={'source_only':True,'original_or_target_read_during_production':False,'module':name,'source':spec['source'],'source_sha256':digest(ROOT/spec['source']),'home':str(home),'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe'),'options':OPTIONS,'native_build_directory':str(work),'object':str(work/f'{name}.obj'),'object_sha256':digest(work/f'{name}.obj'),'headers_sha256':actual,'tool_home_sha256':tools,'inputs_sha256':pins,'staged_sha256':staged,'outputs_sha256':outputs,'source_credit':0};dump(work/'source-build.json',receipt);return receipt

def observe(receipt):
 from le import LEImage
 from tools.infer_bindings import infer_bindings
 from tools.verify_module import verify_module
 from tools.prove_module import assert_contributions
 name=receipt['module'];e,spec,pins=read_contract(name);home=Path(receipt['home']);checked_home(name,home)
 for field in ['inputs_sha256','staged_sha256','outputs_sha256']:unchanged(receipt[field])
 need(receipt['source']==spec['source']and receipt['source_sha256']==e['sources_sha256'][spec['source']]and receipt['inputs_sha256']==pins,'pre-copy expected stage/live source receipt differs')
 check_expected_stage(receipt['native_build_directory'],name,e,pins,receipt['staged_sha256'])
 target=ROOT/'reference/DUKE3D.EXE';need(digest(target)==TARGET_SHA,'target identity');observed=snapshot([target,*[ROOT/n for n in OBSERVERS]]);image=LEImage.parse(target.read_bytes());m=Module.parse(Path(receipt['object']).read_bytes());check_native(m,spec)
 library=ROOT/'reference/duke3d-reconstructions/AUDIO_WF.LIB';need(digest(library)==e['original_library_sha256'],'original archive identity');member=e['original_members'][name];raw=library.read_bytes()[member['offset']:member['offset']+member['bytes']];need(hashlib.sha256(raw).hexdigest()==member['sha256'],'original member identity');original=Module.parse(raw);need({n:v for n,v in m.publics.items()if n not in m.local_publics}=={n:v for n,v in original.publics.items()if n not in original.local_publics},'original global-definition/scope contract differs');observed[str(library)]=digest(library)
 bound=infer_bindings(m,image,spec['code_object'],spec['code_offset'],known_symbols=spec['symbol_anchors']);proof=verify_module(m,image,bound['placements'],bound['symbols']);assert_contributions(proof,spec['expected'])
 original_bound=infer_bindings(original,image,spec['code_object'],spec['code_offset'],known_symbols=spec['symbol_anchors']);members={};removed={n for n,(seg,_)in original.publics.items()if original._segment(seg).class_name=='BSS'and n not in m.publics};need(set(spec['private_member_correspondence'])==removed,'complete original private member keyset')
 for old,view in spec['private_member_correspondence'].items():
  owner=view['owner'];offset=view['offset'];need(old in original.local_publics and owner in m.local_publics,'private member must remain private');need(original.publics[old]==(5,offset),'original private member coordinate');base=bound['symbols'][owner];physical=(base[0],base[1]+offset);need(physical==tuple(original_bound['symbols'][old]),'private member physical role');members[old]={'source_owner':owner,'member_offset':offset,'target':list(physical)}
 unchanged(observed);unchanged(pins)
 for field in ['inputs_sha256','staged_sha256','outputs_sha256']:unchanged(receipt[field])
 check_expected_stage(receipt['native_build_directory'],name,e,pins,receipt['staged_sha256'])
 checked_home(name,home);result={'kind':f'complete {spec["name"]} object contributions, not a full executable','target_sha256':TARGET_SHA,'source':spec['source'],'source_sha256':receipt['source_sha256'],'headers_sha256':receipt['headers_sha256'],'descriptor':f'modules/{name}.json','descriptor_sha256':digest(ROOT/f'modules/{name}.json'),'compiler_sha256':receipt['compiler_sha256'],'options':OPTIONS,'placements':bound['placements'],'constraints':bound['constraints'],'verification':proof,'symbol_anchors':spec['symbol_anchors'],'anchor_evidence':spec['anchor_evidence'],'source_build':receipt,'native_inventory':{'segments':spec['native_segments'],'publics':spec['expected_publics'],'local_publics':spec['expected_local_publics'],'externals':spec['expected_externals'],'local_externals':spec['expected_local_externals']},'observer_inputs_sha256':observed,'private_members':members,'original_global_definitions_and_scopes_exact':True,'unresolved_project_work':['final native layout','whole EXE identity','humanization'],'source_credit':0,'full_executable_rebuilt':False};dump(Path(receipt['native_build_directory'])/'whole-proof.json',result);return result

def probe(name,home,build):return observe(build_source(name,home,build))
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('module',choices=NAMES);p.add_argument('--home',type=Path,required=True);p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True);p.add_argument('--source-only',action='store_true');a=p.parse_args();r=build_source(a.module,a.home,a.build);r=r if a.source_only else observe(r);dump(a.report,r)
if __name__=='__main__':main()
