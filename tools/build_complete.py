"""Portable complete present-source native link and pinned vendor binding.

Builds real complete translation units/capsules, never probe-carved intervals.
Stock compiler members are unmodified supplied dependencies and earn no source
credit. Target/SDK objects and development receipts are not producer inputs.
"""
from pathlib import Path
import argparse,hashlib,importlib,json,os,re,shutil,subprocess,sys,tempfile,time
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from runner import compile_source,assemble_source,run_batch
from omf32 import Module
from tools.prove_module import prepare_headers
from tools.prepare_stock_runtime import prepare as prepare_runtime
from tools.bind_dos4gw import bind_prefix
RECIPE='candidates/complete_source.json'
def need(q,s):
 if not q:raise ValueError('Complete source build: '+s)
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,v):Path(p).parent.mkdir(parents=True,exist_ok=True);Path(p).write_text(json.dumps(v,indent=2,default=str)+'\n')
def snapshot(paths):return{str(p):sha(p)for p in paths}
def unchanged(pins):need(all(Path(p).is_file()and sha(p)==h for p,h in pins.items()),'input/stage/output changed')
def publish_checked(path,value,pins,validate=None):
 unchanged(pins)
 if validate:validate()
 dump(path,value)
 try:
  unchanged(pins)
  if validate:validate()
 except Exception:
  Path(path).unlink(missing_ok=True);raise

def safe_source(p):
 need(type(p)is str and'..'not in Path(p).parts and not Path(p).is_absolute()and p.startswith(('src/','profiles/','modules/','candidates/','tools/','dukenukem3d/','reference/')),'research/absolute source path rejected')
 need(Path(p).suffix.lower()not in('.obj','.lib','.exe'),'compiled object is not authored source')
def validate_recipe(r):
 need(r['schema']==1 and r['source_credit_added']==0 and r['whole_target_match']is False,'candidate scope')
 need(len(r['owned'])==122 and{q['alias']for q in r['owned']}=={f'O{i:03}.OBJ'for i in range(1,123)},'all122 unique owned source nodes')
 for q in r['owned']:
  need(q['kind']in('generic','api','game-main','game-tail'),'finite producer type')
  if'source'in q:safe_source(q['source'])
  if q['kind']=='generic':
   need(q['producer']in('watcom','tasm','masm','nasm','native-wasm')and q['home'].startswith('toolchains/')and'..'not in Path(q['home']).parts,'fixed normal native producer');need(type(q['options'])is list and all(type(x)is str for x in q['options']),'actual option vector')
   for p in q['reference_headers']+q['overlay_headers']:safe_source(p+'/header.h')
  elif q['kind']=='api':
   need(re.fullmatch(r'tools\.[a-z_0-9]+',q['module'])is not None and q['function']in('build_source','assemble','compile_only','compile_preserved','compile_candidate'),'named normal source-only API')
   for a in[*q['args'],*q['kwargs'].values()]:
    need(type(a)is dict and len(a)==1 and next(iter(a))in('literal','tool_home','source_path','asset_home'),'typed normal argument')
    if'source_path'in a:safe_source(a['source_path'])
    if'tool_home'in a:need(not Path(a['tool_home']).is_absolute()and'..'not in Path(a['tool_home']).parts,'declared tool home')
 files=r['link']['files'];runtime=json.loads((ROOT/r['runtime_manifest']).read_text());expected={q['alias']for q in r['owned']}|{'UNIDENT.OBJ'}|{q['filename']for q in runtime['objects']};need(len(files)==len(set(files))==300 and set(files)==expected,'complete unique300-file source/runtime graph');need(r['link']['libraries']==[q['filename']for q in runtime['libraries']],'exact five stock library order');need(files[:2]==['O071.OBJ','O113.OBJ'],'actual GAME main then tail attachment');need(next(q for q in r['owned']if q['alias']=='O071.OBJ')['kind']=='game-main'and next(q for q in r['owned']if q['alias']=='O113.OBJ')['kind']=='game-tail','actual GAME source backend required');return r
def read_recipe(path=None):return validate_recipe(json.loads(Path(path or ROOT/RECIPE).read_text()))
def link_text(r):return'\n'.join([*r['link']['directives'],*('file '+n for n in r['link']['files']),*('library '+n for n in r['link']['libraries'])])+'\n'
def tracked_inputs():
 # Fixed normal input namespaces. Never enumerate ignored builds, SDK object
 # archives or a target image; imported reference repositories contribute H only.
 paths=[]
 for folder in['src','profiles','tools','modules','candidates','evidence']:
  paths.extend(p for p in(ROOT/folder).rglob('*')if p.is_file()and'__pycache__'not in p.parts and'.git'not in p.parts and p.suffix not in('.pyc','.pyo')and p.name!='.DS_Store')
 for folder in['dukenukem3d','reference/duke3d-reconstructions','reference/audiolib-reconstructions','reference/build-reconstructions']:
  paths.extend(p for p in(ROOT/folder).rglob('*')if p.is_file()and p.suffix.lower()=='.h'and'.git'not in p.parts)
 return snapshot(paths)
def normal_homes(r):
 names={q['home'].split('/',1)[1]for q in r['owned']if q['kind']=='generic'}|{'gnu-elf-omf-game','capstone','watcom-10.0-ga','watcom-10.5','gnu-elf-omf'}
 names|={a['tool_home']for q in r['owned']if q['kind']=='api'for a in[*q['args'],*q['kwargs'].values()]if'tool_home'in a};result={}
 for name in sorted(names):
  home=(ROOT/'toolchains'/name).resolve();need(home.is_dir(),'missing declared normal toolhome '+name);local={p.relative_to(home).as_posix():sha(p)for p in sorted(home.rglob('*'))if p.is_file()and'.git'not in p.parts};identity=r['generic_toolchain_identities'].get(name)
  if identity:
   if identity['kind']=='complete-home':need(len(local)==identity['files']and hashlib.sha256(json.dumps(local,sort_keys=True,separators=(',',':')).encode()).hexdigest()==identity['manifest_sha256'],'actual pinned complete native home '+name)
   else:need(all(local.get(n)==h for n,h in identity['files_sha256'].items()),'actual pinned native assembler '+name)
  result.update({str(home/n):h for n,h in local.items()})
 return result
def resolve(value):
 if isinstance(value,dict)and'object'in value:return Path(value['object']),value
 p=Path(value)
 if p.is_file():return p,{'object':str(p),'source_only':True}
 for name in['source-build.json','candidate-result.json']:
  if(p/name).is_file():
   r=json.loads((p/name).read_text())
   if'object'in r:return Path(r['object']),r
 objects=[q for q in p.rglob('*')if q.is_file()and q.suffix.lower()=='.obj'];need(len(objects)==1,'normal source API must publish one unambiguous object');return objects[0],{'native_directory':str(p),'source_only':True}
def generic(q,w,pins):
 w.mkdir(parents=True,exist_ok=False);source=ROOT/q['source'];home=ROOT/q['home'];obj=w/'SOURCE.OBJ';unchanged(pins)
 if q['producer']=='watcom':
  expected={}
  for folder in q['reference_headers']+q['overlay_headers']:
   for p in sorted((ROOT/folder).iterdir()):
    if p.is_file()and p.suffix.lower()=='.h':expected[p.name.lower()]=pins[str(p)]
  include=w/'include';prepare_headers([ROOT/p for p in q['reference_headers']],[ROOT/p for p in q['overlay_headers']],include);need({p.name:sha(p)for p in include.iterdir()if p.is_file()}==expected,'prepared header differs from expected pre-copy inputs');compile_source(home,source,obj,q['options'],60,include_dirs=[include])
 elif q['producer']in('tasm','masm'):assemble_source(home,source,obj,q['options'],60,producer=q['producer'])
 elif q['producer']=='native-wasm':
  from tools.probe_mact_asm import assemble_native
  assemble_native(home,source,obj)
 else:
  p=subprocess.run([str(home/'nasm'),*q['options'],'-o',str(obj),str(source)],capture_output=True,text=True,timeout=60);obj.with_suffix('.log').write_text(p.stdout+p.stderr);need(p.returncode==0 and not p.stderr,'NASM diagnostic/failure')
 unchanged(pins);return obj,{'source_only':True,'source':q['source'],'home':q['home'],'options':q['options'],'object':str(obj)}
def argument(a,assets):
 if'literal'in a:return a['literal']
 if'tool_home'in a:return ROOT/'toolchains'/a['tool_home']
 if'source_path'in a:return ROOT/a['source_path']
 return assets
def api(q,w,assets):
 m=importlib.import_module(q['module']);fn=getattr(m,q['function']);args=[argument(a,assets)for a in q['args']];kw={k:argument(a,assets)for k,a in q['kwargs'].items()}
 if q['function']=='compile_preserved':v=fn(w,**kw)
 elif q['function']=='compile_candidate':v=fn(*args,w,**kw)
 else:v=fn(*args,build=w,**kw)
 return resolve(v)
def copy_expected(source,dest,pins):
 expected=sha(source);pins[str(source)]=expected;shutil.copyfile(source,dest);need(sha(dest)==expected,'copied object/library differs from expected pre-copy digest');return expected

def validate_native_and_bind(work,prefix,expected_native_sha256,validated_files):
 """Bind the SAME native snapshot whose digest passed validation.

 Digests describe the validated/derived bytes, never a later recapture of disk.
 Caller-validated LOG/MAP/status pins remain unchanged through publication.
 """
 w=Path(work);program=w/'link/GAME.EXE';raw=program.read_bytes();native_sha=hashlib.sha256(raw).hexdigest();need(native_sha==expected_native_sha256,'native result differs from the declared reproducible source baseline');output_pins={**validated_files,str(program):native_sha};unchanged(output_pins)
 bound,proof=bind_prefix(prefix,raw);need(bound==prefix+raw and proof['native_program_sha256']==native_sha,'binding changed validated native snapshot');output=w/'DUKE3D.EXE';binding=w/'binding.json';binding_raw=(json.dumps(proof,indent=2,default=str)+'\n').encode();bound_sha=hashlib.sha256(bound).hexdigest();output_pins.update({str(output):bound_sha,str(binding):hashlib.sha256(binding_raw).hexdigest()});output.write_bytes(bound);binding.write_bytes(binding_raw);unchanged(output_pins)
 return{'native_sha256':native_sha,'bound_sha256':bound_sha,'bound_bytes':len(bound),'binding':proof,'outputs_sha256':output_pins}

PREPARED_GAME_NATIVE_SHA256='a5fd6a00453c9f923b6c453a91be2401bfafad3ce55ee6ff741727f2346be88a'
def select_recipe(normal,*,native_layout=False,prepare_game_residue=False):
 """Unselected defaults stay literal; optional residue is preparation only."""
 need(not prepare_game_residue or native_layout,'--prepare-game-residue requires --native-layout')
 if native_layout:
  from tools.build_native_layout import prepare_recipe
  r=prepare_recipe(normal)
 else:r=normal
 if prepare_game_residue:
  main=next(q for q in r['owned']if q['alias']=='O071.OBJ');main.update({'name':'Prepared GAME CONST residue source (not adopted)','source':'src/game/symbolic_preserved/GAME.S','producer_module':'tools.build_game_symbolic_preserved'})
  tail=next(q for q in r['owned']if q['alias']=='O113.OBJ');tail['producer_module']='tools.build_game_symbolic_preserved'
  r.update({'preparation_only':True,'adoption_approved':False,'expected_native_sha256':PREPARED_GAME_NATIVE_SHA256})
 return r

def build_game(native,*,prepare_game_residue=False):
 module='tools.build_game_symbolic_preserved'if prepare_game_residue else'tools.build_game_symbolic'
 return importlib.import_module(module).build_source(ROOT/'toolchains/gnu-elf-omf-game',native/'GAME',decoder_home=ROOT/'toolchains/capstone',watcom_home=ROOT/'toolchains/watcom-10.0-ga')

def build(parent,*,assets,vendor_prefix,native_layout=False,prepare_game_residue=False):
 need(not prepare_game_residue or native_layout,'--prepare-game-residue requires --native-layout')
 started=time.monotonic();recipe_raw=(ROOT/RECIPE).read_bytes();recipe_sha=hashlib.sha256(recipe_raw).hexdigest();r=validate_recipe(json.loads(recipe_raw))
 r=select_recipe(r,native_layout=native_layout,prepare_game_residue=prepare_game_residue)
 assets=Path(assets).resolve();vendor_prefix=Path(vendor_prefix).resolve();prefix=vendor_prefix.read_bytes();need(len(prefix)==r['vendor_prefix']['bytes']and hashlib.sha256(prefix).hexdigest()==r['vendor_prefix']['sha256'],'pinned vendor prefix only; no game payload input');from src.pawe32.embed.assets import check_assets
 check_assets(assets);pins=tracked_inputs();need(pins[str(ROOT/RECIPE)]==recipe_sha,'recipe changed after raw parse');home_pins=normal_homes(r);pins.update(home_pins);pins.update(snapshot([Path(sys.executable).resolve(),vendor_prefix,assets/'SYNTHGM.SBK',assets/'SYNTHGM.SF2']));need(pins[str(vendor_prefix)]==r['vendor_prefix']['sha256'],'vendor prefix changed after raw validation');emulator=Path(os.environ.get('EXHUME_DOSBOX_X')or shutil.which('dosbox-x')or'').resolve();need(emulator.is_file(),'normal DOSBox-X required');pins.update(snapshot([emulator]));parent=Path(parent).resolve();parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='complete-source-',dir=parent));native=w/'source';native.mkdir();link=w/'link';link.mkdir();objects=[];objectpins={};game=None
 dump(w/'input-manifest.json',pins);dump(w/'declared-recipe.json',r)
 for i,q in enumerate(r['owned'],1):
  target=native/q['alias'][:-4];print(f'[{i}/{len(r["owned"])}] {q["alias"]} {q["name"]}',flush=True)
  if q['kind']=='generic':obj,receipt=generic(q,target,pins)
  elif q['kind']=='api':obj,receipt=api(q,target,assets)
  else:
   if game is None:
    game=build_game(native,prepare_game_residue=prepare_game_residue)
   receipt=game;obj=Path(game['object'if q['kind']=='game-main'else'tail_object'])
  if native_layout:
   from tools.build_native_layout import catalog,emit,irq_source
   if q['alias']in catalog()['modules']:
    if q['alias']=='O035.OBJ':receipt=irq_source(receipt,target/'elf-port')
    receipt=emit(q['alias'],receipt,target/'record-layout');obj=Path(receipt['object'])
  need(obj.is_file(),'source producer did not publish an object');h=copy_expected(obj,link/q['alias'],objectpins);objects.append({'alias':q['alias'],'source_recipe':q,'object':str(obj),'sha256':h});dump(w/'objects.json',objects);dump(native/(q['alias'][:-4]+'-source.json'),receipt)
 from tools.build_unidentified_data import build as data_build
 data=data_build(native/'unidentified',home=ROOT/'toolchains/gnu-elf-omf');copy_expected(Path(data['object']),link/'UNIDENT.OBJ',objectpins);dump(w/'unidentified-source.json',data)
 stock=prepare_runtime(w/'stock');dump(w/'stock-runtime.json',stock)
 for n,h in stock['outputs_sha256'].items():need(copy_expected(Path(stock['directory'])/n,link/n,objectpins)==h,'unmodified supplied stock input')
 # Physical duplicate owners are explicit and must remain the real ones.
 seen={};duplicates={}
 for n in r['link']['files']:
  if not n.startswith('O'):continue
  m=Module.parse((link/n).read_bytes())
  for name in m.publics:
   if name in m.local_publics:continue
   if name in seen:duplicates.setdefault(n,[]).append(name)
   else:seen[name]=n
 need({n:sorted(v)for n,v in duplicates.items()}=={n:sorted(v)for n,v in r['expected_duplicate_publics'].items()},'changed physical duplicate PUBLIC ownership; no generic duplicate waiver');need({n:seen[n]for v in duplicates.values()for n in v}==r['expected_selected_duplicate_owners'],'actual selected early PUBLIC owner changed');dump(w/'physical-duplicate-owners.json',{'first_owners':{n:seen[n]for v in duplicates.values()for n in v},'later_physical_definitions':duplicates,'native_first_wins_required':True})
 (link/'LINK.LNK').write_text(link_text(r));stage=snapshot(link/p for p in[*r['link']['files'],*r['link']['libraries'],'LINK.LNK']);unchanged(pins);unchanged(objectpins);run_batch(ROOT/'toolchains'/r['link']['tool_home'],link,'@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\nset LIB=D:\\LIB386;D:\\LIB386\\DOS\r\nwlink @LINK.LNK > LINK.LOG\r\nif errorlevel 1 goto failed\r\necho OK>LINKSTAT.TXT\r\ngoto done\r\n:failed\r\necho FAILED>LINKSTAT.TXT\r\n:done\r\n',90);unchanged(pins);unchanged(objectpins);unchanged(stage)
 validated_files={}
 for n in['LINK.LOG','OUT.MAP','LINKSTAT.TXT']:
  path=link/n;raw=path.read_bytes();validated_files[str(path)]=hashlib.sha256(raw).hexdigest()
  if n=='LINK.LOG':log=raw.decode().replace('\r\n','\n')
  elif n=='LINKSTAT.TXT':need(raw.decode().strip()=='OK','actual native WLINK failure; retained LINK.LOG/MAP')
 warnings=re.findall(r'^Warning\(1027\): file (O[0-9]+\.OBJ)\([^\n]*?\): redefinition of (\S+) ignored$',log,re.M);need(len([line for line in log.splitlines()if re.search(r'\b(?:warning|error)',line,re.I)])==17 and len(warnings)==17 and sorted(warnings)==sorted((n,s)for n,v in duplicates.items()for s in v),'only exact17 independently declared physical duplicate warnings');need(not re.search(r'Error|undefined',log,re.I),'native unresolved/link errors');program=link/'GAME.EXE';validated=validate_native_and_bind(w,prefix,r['expected_native_sha256'],validated_files);output=w/'DUKE3D.EXE';bindproof=validated['binding'];output_pins=validated['outputs_sha256'];unchanged(pins);unchanged(objectpins);unchanged(stage);unchanged(output_pins);need(tracked_inputs()=={p:h for p,h in pins.items()if str(ROOT)in p and any(Path(p).is_relative_to(ROOT/x)for x in['src','profiles','tools','modules','candidates','evidence','dukenukem3d','reference'])},'normal source input namespace changed')
 def final_freshness():
  unchanged(pins);unchanged(objectpins);unchanged(stage);unchanged(output_pins);need(normal_homes(r)==home_pins,'complete declared toolhome namespace changed');need(tracked_inputs()==source_namespace,'normal source namespace changed')
 source_namespace={p:h for p,h in pins.items()if str(ROOT)in p and any(Path(p).is_relative_to(ROOT/x)for x in['src','profiles','tools','modules','candidates','evidence','dukenukem3d','reference'])};final_freshness()
 result={'kind':'Complete normal present-owned source build, supplied stock runtime and pinned vendor binding','owned_source_objects':len(r['owned']),'native_layout':native_layout,'preserved_unidentified_DATA_bytes':96,'stock_objects':177,'stock_libraries':5,'source_only_before_vendor_binding':True,'target_game_payload_or_ignored_research_input':False,'source_credit_added':0,'whole_target_match':False,'known_negative':(None if prepare_game_residue else'seven GAME CONST source zeros; raw serialization separately observed'if native_layout else'seven GAME CONST source zeros and raw fixup serialization; packet policy not applied'),'native_program':str(program),'native_sha256':validated['native_sha256'],'bound_program':str(output),'bound_sha256':validated['bound_sha256'],'bound_bytes':validated['bound_bytes'],'directory':str(w),'objects':objects,'input_manifest':str(w/'input-manifest.json'),'inputs_sha256':pins,'source_object_inputs_sha256':objectpins,'link_inputs_sha256':stage,'elapsed_seconds':time.monotonic()-started,'binding':bindproof,'outputs_sha256':output_pins,'tool_home_files_sha256':home_pins,'source_namespace_sha256':source_namespace};
 if prepare_game_residue:result.update({'preparation_only':True,'adoption_approved':False,'prepared_unidentified_GAME_CONST_bytes':7})
 publish_checked(w/'result.json',result,{**pins,**objectpins,**stage,**output_pins},final_freshness);print('COMPLETE NORMAL SOURCE NATIVE',result['native_sha256'],'BOUND',result['bound_sha256'],flush=True);return result

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--prepare-game-residue',action='store_true',help='preparation only, not adopted; requires --native-layout');p.add_argument('--native-layout',action='store_true',help='opt in to reviewed source-native record plans and whole ACTORS compiland');p.add_argument('--build',type=Path,default=ROOT/'build/complete-source');p.add_argument('--assets',type=Path,default=ROOT/'build/assets/pawe');p.add_argument('--vendor-prefix',type=Path,required=True);p.add_argument('--report',type=Path,required=True);a=p.parse_args();
 if a.prepare_game_residue and not a.native_layout:p.error('--prepare-game-residue requires --native-layout')
 r=build(a.build,assets=a.assets,vendor_prefix=a.vendor_prefix,native_layout=a.native_layout,prepare_game_residue=a.prepare_game_residue);publish_checked(a.report,r,{**r['inputs_sha256'],**r['source_object_inputs_sha256'],**r['link_inputs_sha256'],**r['outputs_sha256']})
if __name__=='__main__':main()
