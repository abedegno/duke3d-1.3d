"""Source-only whole GAME mnemonic backend and six real public BSS tail objects.

Prepared optional unidentified CONST preservation; user permission unanswered.
Default symbolic/C producers are unchanged. No source credit/adoption claimed.
"""
from pathlib import Path
import argparse,hashlib,importlib.util,json,os,shutil,subprocess,sys,tempfile,types
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from profiles.gnu_elf_omf_game.identity import checked_home,profile
from profiles.capstone.identity import load as decoder_load,checked_home as decoder_check
from profiles.gnu_elf_omf.elf32 import elf
from omf32 import Module
from runner import run_batch
SOURCE='src/game/symbolic';VARIANT='src/game/symbolic_preserved';REFERENCE='evidence/game-symbolic-preserved-reference.json';DESCRIPTOR='modules/game_symbolic_preserved.json'
PRESERVED_CONST={47:16,93:86,94:7,98:3,99:216,134:160,135:86}
SOURCES=[VARIANT+'/GAME.S',SOURCE+'/game-C-counterpart.c.txt',SOURCE+'/groups.plan',VARIANT+'/contract-model.json','src/game/game_tail.asm']
NOTICES=[VARIANT+'/README.md',SOURCE+'/README.md',SOURCE+'/GPL-2.0-or-later.txt','profiles/gnu_elf_omf_game/README.md','profiles/capstone/README.md']
OBSERVERS=['tools/observe_game_symbolic_preserved.py','tools/map_candidates.py','tools/infer_bindings.py','tools/match_function.py','tools/verify_module.py','profiles/watcom/tools/le.py']
TOOLS=['tools/build_game_symbolic_preserved.py',VARIANT+'/contract.py',SOURCE+'/coff_contract.py','profiles/gnu_elf_omf_game/identity.py','profiles/gnu_elf_omf_game/profile.json','profiles/gnu_elf_omf/elf32.py','profiles/capstone/identity.py','profiles/capstone/files.json','profiles/watcom/tools/omf32.py','profiles/watcom/tools/runner.py','profiles/watcom/game-compound-tools.json']
def need(q,s):
 if not q:raise ValueError('GAME symbolic '+s)
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def dump(p,x):Path(p).parent.mkdir(parents=True,exist_ok=True);Path(p).write_text(json.dumps(x,indent=2)+'\n')
def snapshot(paths):return{str(p):digest(p)for p in paths}
def unchanged(p):need(all(Path(n).is_file()and digest(n)==h for n,h in p.items()),'live/staged/output identity changed')
def module(name,path):
 path=Path(path);m=types.ModuleType(name);m.__file__=str(path);exec(compile(path.read_bytes(),str(path),'exec'),m.__dict__);return m
contract=module('game_symbolic_preserved_contract',ROOT/VARIANT/'contract.py');coff=module('game_symbolic_coff',ROOT/SOURCE/'coff_contract.py')
def ga_home(home):
 expected=json.loads((ROOT/'profiles/watcom/game-compound-tools.json').read_text());actual={p.relative_to(home).as_posix():digest(p)for p in home.rglob('*')if p.is_file()and'.git'not in p.parts};need(actual==expected and len(actual)==500,'complete pinned GA assembler home');return actual

def read_contract():
 reference_raw=(ROOT/REFERENCE).read_bytes();e=json.loads(reference_raw)
 need(set(e)=={'scope','source_credit','full_target_match','sources_sha256','notices_sha256','producer_tools_sha256','descriptor_sha256','python_sha256','emulator_sha256','observer_tools_sha256'},'closed provenance keys')
 expected={}
 for key,paths in [('sources_sha256',SOURCES),('notices_sha256',NOTICES),('producer_tools_sha256',TOOLS)]:
  need(set(e[key])==set(paths),'closed '+key+' keyset')
  need(all(digest(ROOT/n)==h for n,h in e[key].items()),'changed '+key)
  expected.update(e[key])
 need(set(e['observer_tools_sha256'])==set(OBSERVERS),'closed observer keyset')
 need(e['source_credit']==0 and e['full_target_match']is False,'prepared preservation has no adoption/credit approval')
 descriptor_raw=(ROOT/DESCRIPTOR).read_bytes()
 need(hashlib.sha256(descriptor_raw).hexdigest()==e['descriptor_sha256'],'descriptor identity')
 d=json.loads(descriptor_raw)
 need(d['name']=='game_symbolic_preserved_candidate'and d['source_credit']==0 and d['whole_target_match']is False,'candidate scope');need(d['adoption_status']=='prepared; permission unanswered'and {int(k):v for k,v in d['preserved_CONST'].items()}==PRESERVED_CONST,'finite unapproved preparation')
 pins={str(ROOT/n):h for n,h in expected.items()}
 pins[str(ROOT/REFERENCE)]=hashlib.sha256(reference_raw).hexdigest()
 pins[str(ROOT/DESCRIPTOR)]=e['descriptor_sha256']
 unchanged(pins)
 return e,d,pins

def build_source(home,build,*,decoder_home,watcom_home):
 e,d,pins=read_contract();home=Path(home).resolve();decoder_home=Path(decoder_home).resolve();watcom_home=Path(watcom_home).resolve();hp=checked_home(home);dp=decoder_check(decoder_home);gp=ga_home(watcom_home)
 python=Path(sys.executable).resolve();emulator=Path(os.environ.get('EXHUME_DOSBOX_X')or shutil.which('dosbox-x')or'').resolve();need(python.is_file()and digest(python)==e['python_sha256']and emulator.is_file()and digest(emulator)==e['emulator_sha256'],'Python/emulator identity');pins.update(snapshot([python,emulator]));pins.update({str(home/n):h for n,h in hp.items()});pins.update({str(decoder_home/n):h for n,h in dp.items()});pins.update({str(watcom_home/n):h for n,h in gp.items()});decoder_load(decoder_home)
 parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='game-symbolic-',dir=parent));stage=w/'source-only';expected={}
 # Live pins precede copy; models are parsed only from the verified staged bytes.
 for n in[*SOURCES,*NOTICES]:
  staged_name=SOURCE+n[len(VARIANT):]if n.startswith(VARIANT+'/')and n.endswith(('GAME.S','contract-model.json'))else n;dest=stage/staged_name;dest.parent.mkdir(parents=True,exist_ok=True);expected[str(dest)]=pins[str(ROOT/n)];shutil.copyfile(ROOT/n,dest)
 unchanged(pins);unchanged(expected);text=(stage/SOURCE/'GAME.S').read_text();model_raw=(stage/SOURCE/'contract-model.json').read_bytes();need(hashlib.sha256(model_raw).hexdigest()==contract.MODEL_SHA256,'staged model identity');contract.source_preflight(text,json.loads(model_raw));outputs={};commands=[]
 def fresh():
  unchanged(pins);unchanged(expected);unchanged(outputs);need({str(p)for p in stage.rglob('*')if p.is_file()}==set(expected),'staged complete file set');need(checked_home(home)==hp and decoder_check(decoder_home)==dp and ga_home(watcom_home)==gp,'complete toolhome freshness')
 def run(args,log):
  fresh();commands.append(args);p=subprocess.run(args,capture_output=True,text=True);(w/log).write_text(p.stdout+p.stderr);fresh();need(p.returncode==0 and not p.stderr and'warning'not in p.stdout.lower(),'native diagnostics '+str(w/log));outputs.update(snapshot([w/log]))
 opts=profile()['options'];run([str(home/'bin/as-new'),*opts['assembler'],'--listing-rhs-width=4096','--listing-cont-lines=256','-al='+str(w/'GAME.LST'),'-o',str(w/'GAME.ELF'),str(stage/SOURCE/'GAME.S')],'AS.LOG');outputs.update(snapshot(w/n for n in['GAME.ELF','GAME.LST']));contract.raw_elf(w/'GAME.ELF');el=elf(w/'GAME.ELF');pre=contract.preflight(w/'GAME.ELF',text,(w/'GAME.LST').read_text(),el);dump(w/'source-ELF-proof.json',pre);outputs.update(snapshot([w/'source-ELF-proof.json']))
 run([str(home/'bin/objconv'),*opts['converter'],'-group-plan='+str(stage/SOURCE/'groups.plan'),str(w/'GAME.ELF'),str(w/'GAME.OBJ')],'OMF.LOG');outputs.update(snapshot([w/'GAME.OBJ']));run([str(home/'bin/objconv'),'-fcoff32','-wex',str(w/'GAME.ELF'),str(w/'GAME.COFF')],'COFF.LOG');outputs.update(snapshot([w/'GAME.COFF']));m=Module.parse((w/'GAME.OBJ').read_bytes());post=contract.postflight(el,m,pre);cf=coff.check(w,el,m);dump(w/'source-native-proof.json',post);dump(w/'COFF-proof.json',cf);outputs.update(snapshot(w/n for n in['source-native-proof.json','COFF-proof.json']))
 tail=(stage/'src/game/game_tail.asm').read_bytes();need(digest(stage/'src/game/game_tail.asm')==d['tail_source_sha256'],'real six-owner tail');shutil.copyfile(stage/'src/game/game_tail.asm',w/'GMTAIL.ASM');outputs.update(snapshot([w/'GMTAIL.ASM']));fresh();run_batch(watcom_home,w,'@echo off\r\nset PATH=D:\\BINB;D:\\BIN\r\nwasm /zq GMTAIL.ASM > TAIL.LOG\r\nif errorlevel 1 goto failed\r\necho OK>TAILSTAT.TXT\r\ngoto done\r\n:failed\r\necho FAILED>TAILSTAT.TXT\r\n:done\r\n',45);fresh();need((w/'TAILSTAT.TXT').read_text().strip()=='OK'and not(w/'TAIL.LOG').read_bytes(),'tail diagnostics');tail_raw=(w/'GMTAIL.OBJ').read_bytes();outputs[str(w/'GMTAIL.OBJ')]=hashlib.sha256(tail_raw).hexdigest();tm=Module.parse(tail_raw);need(contract.inventory(tm)==d['tail_native_inventory'],'full tail runtime/scope/coordinate contract');outputs.update(snapshot(w/n for n in['TAIL.LOG','TAILSTAT.TXT']));fresh()
 r={'source_only':True,'target_SDK_Cobject_decoder_emitter_read':False,'source_credit':0,'full_target_match':False,'known_negative':'adoption permission unanswered; target observation separate','prepared_unidentified_CONST_residue':PRESERVED_CONST,'adoption_approved':False,'object':str(w/'GAME.OBJ'),'object_sha256':outputs[str(w/'GAME.OBJ')],'tail_object':str(w/'GMTAIL.OBJ'),'tail_object_sha256':outputs[str(w/'GMTAIL.OBJ')],'objects':[{'source':VARIANT+'/GAME.S','object':str(w/'GAME.OBJ')},{'source':'src/game/game_tail.asm','object':str(w/'GMTAIL.OBJ'),'must_follow_main_in_link':True}],'native_build_directory':str(w),'inputs_sha256':pins,'staged_inputs_sha256':expected,'outputs_sha256':outputs,'commands':commands,'native_inventory':contract.inventory(m),'all5018_complete_source_roles':True,'all109_actual_PUBLIC_coordinates':True,'runtime_sections':[(s.name,s.class_name,s.size,s.attributes,s.access)for s in m.segments]}
 fresh();receipt_path=w/'source-build.json';receipt_raw=(json.dumps(r,indent=2)+'\n').encode();dump(receipt_path,r)
 try:need(receipt_path.read_bytes()==receipt_raw,'same prepared receipt RAW');fresh()
 except Exception:
  receipt_path.unlink()
  raise
 return r

def check_freshness(r,home,decoder_home,watcom_home):
 read_contract();unchanged(r['inputs_sha256']);unchanged(r['staged_inputs_sha256']);unchanged(r['outputs_sha256']);checked_home(Path(home));decoder_check(Path(decoder_home));ga_home(Path(watcom_home))
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path,default=ROOT/'toolchains/gnu-elf-omf-game');p.add_argument('--decoder-home',type=Path,default=ROOT/'toolchains/capstone');p.add_argument('--watcom-home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga');p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True);a=p.parse_args();r=build_source(a.home,a.build,decoder_home=a.decoder_home,watcom_home=a.watcom_home);dump(a.report,r);print('GAME PREPARED PRESERVED SOURCE BUILT',r['object_sha256'],'84142 CODE/4274 CONST/864 DATA/4160+15 BSS/5018 fields; seven post-NUL residue bytes prepared; permission unanswered')
if __name__=='__main__':main()
