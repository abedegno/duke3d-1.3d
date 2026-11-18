"""Closed normal source-only partial GAME C/private-prefix + public BSS tail.

Released/source headers are real inputs. Original SDK objects, target, caller
reports and ignored prepared-header snapshots are never production inputs.
"""
from pathlib import Path
from dataclasses import is_dataclass
import argparse,hashlib,json,os,re,shutil,sys,tempfile
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from runner import compile_source,run_batch,compiler_bin
from omf32 import Module
SOURCE='src/game/symbolic/game-fixed-C-counterpart.c.txt';TAIL='src/game/game_tail.asm';DESCRIPTOR='modules/game_compound.json';PROVENANCE='evidence/game-compound-source-reference.json';PROFILE='profiles/watcom/game-compound-tools.json'
SOURCES=[SOURCE,TAIL];NOTICES=['src/game/gpl.txt','src/game/compound-README.md','evidence/game-source-reference.json'];TOOLS=['tools/build_game_compound.py','profiles/watcom/tools/runner.py','profiles/watcom/tools/omf32.py',PROFILE]
OBSERVERS=['tools/probe_game.py','tools/probe_premap.py','tools/prove_module.py','tools/infer_bindings.py','tools/match_function.py','tools/verify_module.py','tools/preserve.py','profiles/watcom/tools/le.py']
REFERENCES=['reference/duke3d-reconstructions','reference/duke3d-reconstructions/MACT'];OVERLAYS=['src/include','src/game/include','src/engine/include','src/game/compound/include'];OPTIONS=['/4r','/s','/ort','/dAPPVER_EXEDEF=DN3D13G','/dLIBVER_BUILDREV=19960320'];ASM_OPTIONS=['/zq']
SHARED_GAME_HEADER='src/game/include/duke3d.h';GAME_ONLY_HEADER='src/game/compound/include/duke3d.h'
PALETTE_DECLARATION=b'extern char boardfilename[128],waterpal[768],slimepal[768],titlepal[768],drealms[768],endingpal[768];'
PREFIX={'_frameval':0,'_recbuf':256,'_endingpal':296,'_titlepal':1064,'_waterpal':1832,'_drealms':2600,'_slimepal':3368,'_nonsharedtimer':4136,'_recfilep':4140,'_rtsptr':4144,'_totalreccnt':4148,'_tempwallptr':4152,'_dmval':4156}
TAIL_OFFSETS={'_cheatbuf':0,'_everyothertime':10,'_cheatbuflen':11,'_playerswhenstarted':12,'_restorepalette':13,'_screencapt':14}
def need(q,s):
 if not q:raise ValueError(s)
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,x):Path(p).parent.mkdir(parents=True,exist_ok=True);Path(p).write_text(json.dumps(x,indent=2)+'\n')
def snapshot(paths):return {str(p):digest(p)for p in paths}
def unchanged(pins):need(all(Path(p).is_file()and digest(p)==h for p,h in pins.items()),'GAME compound input/output changed during production')
def encode(x):
 if isinstance(x,(bytes,bytearray)):return {'hex':bytes(x).hex()}
 if is_dataclass(x):return encode(vars(x))
 if isinstance(x,dict):return {str(k):encode(v)for k,v in x.items()}
 if isinstance(x,set):return sorted(encode(v)for v in x)
 if isinstance(x,(list,tuple)):return [encode(v)for v in x]
 return x
def inventory(m,stable=False):
 need(set(vars(m))==set(vars(Module())),'unknown GAME native metadata');d=encode(vars(m));d['segments']=[{'name':s.name,'class':s.class_name,'size':s.size,'attributes':s.attributes,'access':s.access,'data_sha256':hashlib.sha256(bytes(s.data)).hexdigest()}for s in m.segments]
 if stable:
  seen=0;source=0
  for i,(kind,payload)in enumerate(m.comments):
   if kind==233 and payload:
    need(len(payload)>=6 and payload[4]==len(payload)-5,'unmeasured GAME source provenance length');path=payload[5:].decode('ascii')
    need(re.fullmatch(r'C:\\SOURCE\.C|C:\\INC0\\[A-Za-z_0-9]+\.h|D:\\H\\(?:sys\\)?[A-Za-z_0-9]+\.[hH]',path)is not None,'unmeasured GAME source provenance path')
    d['comments'][i]=[kind,{'native_timestamp_bytes':4,'source_path':path}];seen+=1;source+=path=='C:\\SOURCE.C'
  need(source==1 and seen>1,'missing or duplicate GAME source/header provenance record')
 return d
def inventory_sha(m):return hashlib.sha256(json.dumps(inventory(m,True),sort_keys=True,separators=(',',':')).encode()).hexdigest()
def check_diagnostics(log):
 text=Path(log).read_text();pat=re.compile(r"SOURCE\.C\(\d+\): Warning! W107: Missing return value for function '(moveloop|domovethings)'");warnings=[]
 for line in text.splitlines():
  if re.search(r'(?:Warning|Error)!|\b[WE]\d{3}\b',line):
   match=pat.fullmatch(line);need(match is not None,'unexpected GAME compiler diagnostic: '+line);warnings.append(match[1])
 need(warnings==['moveloop','domovethings']and re.findall(r'^SOURCE\.C: \d+ lines, included \d+, (\d+) warnings, (\d+) errors$',text,re.M)==[('2','0')],'unexpected GAME compiler diagnostic inventory')
 return {'accepted_warning_functions':warnings,'warning_count':2,'error_count':0,'log_sha256':digest(log),'historical_return_types_proved':False}
def header_sources():
 out={}
 for folder in REFERENCES+OVERLAYS:
  d=ROOT/folder;need(d.is_dir(),'missing live GAME source-header directory '+folder);names=set()
  for p in sorted(d.iterdir()):
   if p.is_file()and p.suffix.lower()=='.h':
    n=p.name.lower();need(n not in names,'case-colliding GAME headers');names.add(n);out[str(p.relative_to(ROOT))]=digest(p)
 return out
def check_palette_header_context():
 need((ROOT/SHARED_GAME_HEADER).is_file()and(ROOT/GAME_ONLY_HEADER).is_file(),'missing GAME palette header input')
 original=(ROOT/SHARED_GAME_HEADER).read_bytes()
 variant=(ROOT/GAME_ONLY_HEADER).read_bytes()
 need(original.count(PALETTE_DECLARATION)==1,'changed shared GAME palette declaration')
 expected=original.replace(PALETTE_DECLARATION,PALETTE_DECLARATION.replace(b',endingpal[768]',b''))
 need(variant==expected,'changed GAME-only palette header context')
 return {'shared_header':SHARED_GAME_HEADER,'shared_sha256':digest(ROOT/SHARED_GAME_HEADER),
         'GAME_only_header':GAME_ONLY_HEADER,'variant_sha256':digest(ROOT/GAME_ONLY_HEADER),
         'removed_only':'redundant endingpal extern; real public definition unchanged',
         'other_translation_units_use_shared_header':True}

def prepare_live_headers(output):
 output.mkdir(parents=True,exist_ok=False);refs={}
 for folder in REFERENCES+OVERLAYS:
  for p in sorted((ROOT/folder).iterdir()):
   if p.is_file()and p.suffix.lower()=='.h':
    n=p.name.lower()
    if folder in REFERENCES:
     need(n not in refs or refs[n]==digest(p),'conflicting GAME reference source headers');refs[n]=digest(p)
    shutil.copyfile(p,output/n)
 return {p.name:digest(p)for p in sorted(output.iterdir())}
def tool_home(home):
 home=Path(home).resolve();actual={str(p.relative_to(home)):digest(p)for p in sorted(home.rglob('*'))if p.is_file()and'.git'not in p.relative_to(home).parts};expected=json.loads((ROOT/PROFILE).read_text());need(len(expected)==500 and actual==expected,'changed complete GAME GA tool home');return actual
def runtime_inputs(e):
 emulator=Path(os.environ.get('EXHUME_DOSBOX_X')or shutil.which('dosbox-x')or'').resolve();python=Path(sys.executable).resolve();need(emulator.is_file()and digest(emulator)==e['emulator_sha256']and digest(python)==e['python_sha256'],'changed GAME emulator/Python');return snapshot([emulator,python])
def read_contract():
 e=json.loads((ROOT/PROVENANCE).read_text());s=json.loads((ROOT/DESCRIPTOR).read_text())
 need(type(e)is dict and type(s)is dict,'GAME compound object contract');required={'sources_sha256','notices_sha256','producer_tools_sha256','header_sources_sha256','prepared_headers_sha256','descriptor_sha256','observer_tools_sha256','emulator_sha256','python_sha256','palette_header_context','scope','source_credit','full_executable_rebuilt'};need(required<=set(e),'missing GAME compound provenance field')
 for field,paths in [('sources_sha256',SOURCES),('notices_sha256',NOTICES),('producer_tools_sha256',TOOLS)]:
  need(type(e[field])is dict and set(e[field])==set(paths),'changed closed GAME '+field)
  for p,h in e[field].items():need((ROOT/p).is_file()and digest(ROOT/p)==h,'changed GAME source/tool/notice '+p)
 need(type(e['observer_tools_sha256'])is dict and set(e['observer_tools_sha256'])==set(OBSERVERS),'changed GAME observer tool keyset')
 need(e['palette_header_context']==check_palette_header_context(),'changed palette header context receipt');need(e['header_sources_sha256']==header_sources(),'changed live GAME source-header set/identity');need(digest(ROOT/DESCRIPTOR)==e['descriptor_sha256']and s['name']=='game_partial_compound'and s['options']==OPTIONS and s['asm_options']==ASM_OPTIONS and s['header_recipe']=={'references':REFERENCES,'overlays':OVERLAYS},'changed fixed GAME compound recipe');need(e['source_credit']==0 and e['full_executable_rebuilt']is False,'GAME partial scope cannot become whole credit')
 pins=snapshot(ROOT/p for p in[*SOURCES,*NOTICES,*TOOLS,DESCRIPTOR,PROVENANCE,*e['header_sources_sha256']]);return e,s,pins

def observer_snapshot():
 e,s,pins=read_contract()
 for path,value in e['observer_tools_sha256'].items():
  need((ROOT/path).is_file()and digest(ROOT/path)==value,'changed GAME observer helper '+path);pins[str(ROOT/path)]=value
 return pins

def check_tail_source(source):
 lines=[x.partition(';')[0].strip()for x in source.decode('ascii').splitlines()if x.partition(';')[0].strip()];expected=['.386p','.model flat',"_BSS segment byte public use32 'BSS'",'public _cheatbuf,_everyothertime,_cheatbuflen','public _playerswhenstarted,_restorepalette,_screencapt','_cheatbuf db 10 dup (?)','_everyothertime db ?','_cheatbuflen db ?','_playerswhenstarted db ?','_restorepalette db ?','_screencapt db ?','_BSS ends','DGROUP group _BSS','end'];need(lines==expected,'changed genuine GAME six-public-tail source/scope')
def validate_native(m,tail,s):
 need(inventory_sha(m)==s['C_stable_native_inventory_sha256'],'changed full GAME native runtime/scope contract');need(inventory(tail)==s['tail_native_inventory'],'changed whole GAME tail native contract');need(m.segments[4].size==4160 and {n:o for n,(seg,o)in m.publics.items()if seg==5}==PREFIX,'changed GAME C physical prefix');need({n for n in m.local_publics if m.publics[n][0]==5}=={'_frameval','_dmval'},'private GAME prefix owner promotion/removal');need(all(n not in m.publics and n in m.externals and m.externals.index(n)+1 not in m.local_externals for n in TAIL_OFFSETS),'changed GAME real external tail consumers');need(tail.publics=={n:(3,o)for n,o in TAIL_OFFSETS.items()}and not(tail.local_publics or tail.local_externals or tail.externals or tail.fixups),'changed GAME real tail public identity/scope')
def build_source(home,build):
 e,s,pins=read_contract();home=Path(home).resolve();tools=tool_home(home);pins.update(runtime_inputs(e));pins.update({str(home/p):h for p,h in tools.items()});parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);build=Path(tempfile.mkdtemp(prefix='game-compound-',dir=parent));stage=build/'source-only'
 for p in[*SOURCES,*NOTICES]:q=stage/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,q)
 headers=build/'include';prepared=prepare_live_headers(headers);need(prepared==e['prepared_headers_sha256'],'changed fresh prepared GAME header graph');staged=snapshot([*[p for p in stage.rglob('*')if p.is_file()],*[p for p in headers.iterdir()if p.is_file()]]);check_tail_source((stage/TAIL).read_bytes());compile_source(home,stage/SOURCE,build/'game.obj',OPTIONS,45,include_dirs=[headers]);diagnostics=check_diagnostics(build/'game.log');shutil.copyfile(stage/TAIL,build/'GMTAIL.ASM')
 run_batch(home,build,'@echo off\r\nset PATH=D:\\BINB;D:\\BIN\r\nwasm /zq GMTAIL.ASM > TAIL.LOG\r\nif errorlevel 1 goto failed\r\necho OK>TAILSTAT.TXT\r\ngoto done\r\n:failed\r\necho FAILED>TAILSTAT.TXT\r\n:done\r\n',45);need((build/'TAILSTAT.TXT').read_text().strip()=='OK'and not(build/'TAIL.LOG').read_bytes(),'actual GAME tail native failure/diagnostics');m=Module.parse((build/'game.obj').read_bytes());tail=Module.parse((build/'GMTAIL.OBJ').read_bytes());validate_native(m,tail,s);dump(build/'C-raw-native-inventory.json',inventory(m));dump(build/'tail-raw-native-inventory.json',inventory(tail));outputs=snapshot(build/p for p in['game.obj','game.log','GMTAIL.ASM','GMTAIL.OBJ','TAIL.LOG','C-raw-native-inventory.json','tail-raw-native-inventory.json']);unchanged(pins);unchanged(staged);unchanged(outputs);need(header_sources()==e['header_sources_sha256'],'GAME source headers changed during native production');tool_home(home)
 r={'source_only':True,'original_binary_SDK_object_or_caller_read':False,'source_credit':0,'full_executable_rebuilt':False,'native_build_directory':str(build),'C_object':str(build/'game.obj'),'tail_object':str(build/'GMTAIL.OBJ'),'objects':[{'source':SOURCE,'object':str(build/'game.obj'),'kind':'C/all real code+CONST+DATA+private BSS prefix'},{'source':TAIL,'object':str(build/'GMTAIL.OBJ'),'kind':'six real public BSS objects only','must_follow_C_in_link':True}],'source_sha256':digest(ROOT/SOURCE),'tail_source_sha256':digest(ROOT/TAIL),'options':OPTIONS,'asm_options':ASM_OPTIONS,'headers_sha256':prepared,'palette_header_context':e['palette_header_context'],'compiler_diagnostics':diagnostics,'inputs_sha256':pins,'staged_inputs_sha256':staged,'outputs_sha256':outputs,'tool_home_sha256':tools,'C_stable_native_inventory_sha256':inventory_sha(m),'C_object_sha256':digest(build/'game.obj'),'tail_object_sha256':digest(build/'GMTAIL.OBJ'),'raw_inventory_files':[str(build/'C-raw-native-inventory.json'),str(build/'tail-raw-native-inventory.json')],'source_timestamp_scope':'Only actual4-byte timestamps of the fixed ordered source/header E9 vector are variable in stable metadata identity; all paths/classes/order/empty sentinel and raw object/comments are retained. No byte/runtime/scope/fixup normalization.'};dump(build/'source-build.json',r);return r

def check_freshness(result,home):
 e,s,pins=read_contract();unchanged(result['inputs_sha256']);unchanged(result['staged_inputs_sha256']);unchanged(result['outputs_sha256']);need(header_sources()==e['header_sources_sha256'],'GAME live header set changed');runtime_inputs(e);tool_home(home)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga');p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True);a=p.parse_args();r=build_source(a.home,a.build);dump(a.report,r);print('GAME COMPOUND SOURCE BUILT: C prefix4160 + six public BSS objects15; partial/no target observation')
if __name__=='__main__':main()
