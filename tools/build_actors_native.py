"""Source-only whole ACTORS backend; no target/archive/decoder inputs."""
from pathlib import Path
import argparse,hashlib,json,shutil,subprocess,sys,tempfile,time,types
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
sys.dont_write_bytecode=True
from omf32 import Module
from profiles.gnu_elf_omf_layouts.identity import checked_home,profile
SOURCE='src/game/actors_native'
PROVENANCE='evidence/actors-native-source-reference.json'
DESCRIPTOR='candidates/actors_native.json'
AUTHORED=['ACTORS.S','source-model.json','actors-C-counterpart.c.txt','moveeffectors-NASM-counterpart.asm.txt']
SUPPORT=['source_policy.py','source-policy.json','native_schema.py','native-output-policy.json','ACTORS-whole-C-owned.plan','groups.plan']
NOTICES=['README.md','GPL-2.0.txt','actors-fixed-complete-C-counterpart.c.txt']
SOURCES=[SOURCE+'/'+n for n in AUTHORED+SUPPORT]
NOTICE_PATHS=[SOURCE+'/'+n for n in NOTICES]
PRODUCERS=['tools/build_actors_native.py','profiles/gnu_elf_omf_layouts/identity.py','profiles/gnu_elf_omf_layouts/profile.json','profiles/gnu_elf_omf_imports/profile.json','profiles/gnu_elf_omf/elf32.py','profiles/watcom/tools/omf32.py']
def need(q,s):
 if not q:raise ValueError('ACTORS native '+s)
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def unchanged(pins):
 need(all(Path(p).is_file()and digest(p)==h for p,h in pins.items()),'input/stage/output identity changed')
def dump(path,data):Path(path).write_text(json.dumps(data,indent=2)+'\n')
def load_module(path,expected=None):
 raw=Path(path).read_bytes()
 if expected is not None:need(hashlib.sha256(raw).hexdigest()==expected,'loaded helper identity')
 m=types.ModuleType('actors_native_'+Path(path).stem);m.__file__=str(path);exec(compile(raw,str(path),'exec'),m.__dict__);return m

def read_contract():
 raw=(ROOT/PROVENANCE).read_bytes();h=hashlib.sha256(raw).hexdigest();e=json.loads(raw)
 need(set(e)=={'schema','scope','source_credit','source_files_sha256','notice_files_sha256','producer_tools_sha256','descriptor_sha256','lineage'},'closed provenance schema')
 need(e['schema']==1 and e['source_credit']==0,'provenance source-only scope')
 pins={str(ROOT/PROVENANCE):h}
 for key,names in [('source_files_sha256',SOURCES),('notice_files_sha256',NOTICE_PATHS),('producer_tools_sha256',PRODUCERS)]:
  need(set(e[key])==set(names),'closed '+key+' keyset');pins.update({str(ROOT/n):v for n,v in e[key].items()})
 draw=(ROOT/DESCRIPTOR).read_bytes();need(hashlib.sha256(draw).hexdigest()==e['descriptor_sha256'],'descriptor identity');d=json.loads(draw)
 need(d['name']=='actors_native_source'and d['expected']=={'initialized_bytes':61741,'zero_fill_bytes':6,'verified_fixups':2812}and d['source_credit']==0,'source-only descriptor scope');pins[str(ROOT/DESCRIPTOR)]=e['descriptor_sha256'];unchanged(pins)
 return e,d,pins

def build_source(home,build):
 e,d,pins=read_contract();home=Path(home).resolve();hp=checked_home(home);pins.update({str(home/n):h for n,h in hp.items()});pins[str(Path(sys.executable).resolve())]=digest(Path(sys.executable).resolve())
 parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='actors-native-',dir=parent));stage=w/'source-only';authored=stage/'authored';support=stage/'support';authored.mkdir(parents=True);support.mkdir();expected={}
 # Bind expected staged bytes to closed live pins BEFORE any copy.
 for n in AUTHORED+SUPPORT+NOTICES:
  src=ROOT/SOURCE/n;dest=(authored if n in AUTHORED else support)/n;expected[str(dest)]=pins[str(src)];shutil.copyfile(src,dest)
 unchanged(pins);unchanged(expected)
 guard=load_module(support/'source_policy.py',expected[str(support/'source_policy.py')]);schema=load_module(support/'native_schema.py',expected[str(support/'native_schema.py')]);source_guard=guard.check(authored,support/'source-policy.json')
 policy_raw=(support/'native-output-policy.json').read_bytes();policy=json.loads(policy_raw);need(hashlib.sha256(policy_raw).hexdigest()==pins[str(ROOT/SOURCE/'native-output-policy.json')],'output policy parsed same raw');need(set(policy['outputs_sha256'])=={'ACTORS.ELF','ACTORS.OBJ'},'closed deterministic output set');outputs={};commands=[];clock_start=int(time.time())
 def fresh():
  unchanged(pins);unchanged(expected);unchanged(outputs);need({str(p)for p in stage.rglob('*')if p.is_file()}==set(expected),'complete staged file set');need(checked_home(home)==hp,'whole tool-home identity changed')
 def run(args,log):
  fresh();commands.append(list(map(str,args)));p=subprocess.run(commands[-1],capture_output=True,text=True,timeout=60);(w/log).write_text(p.stdout+p.stderr);fresh();need(p.returncode==0 and not p.stderr and'warning'not in p.stdout.lower(),'native diagnostic '+str(w/log));outputs[str(w/log)]=digest(w/log)
 opts=profile()['options'];run([home/'bin/as-new',*opts['assembler'],'--listing-rhs-width=4096','--listing-cont-lines=256','-al='+str(w/'ACTORS.LST'),'-o',w/'ACTORS.ELF',authored/'ACTORS.S'],'AS.LOG');outputs.update({str(w/n):digest(w/n)for n in ['ACTORS.ELF','ACTORS.LST']});need(outputs[str(w/'ACTORS.ELF')]==policy['outputs_sha256']['ACTORS.ELF'],'complete source ELF contract')
 run([home/'bin/objconv',*opts['converter'],'-omit-unused-gnu-defaults','-group-plan='+str(support/'groups.plan'),'-packet-plan='+str(support/'ACTORS-whole-C-owned.plan'),w/'ACTORS.ELF',w/'ACTORS.OBJ'],'OMF.LOG');outputs[str(w/'ACTORS.OBJ')]=digest(w/'ACTORS.OBJ');need(outputs[str(w/'ACTORS.OBJ')]==policy['outputs_sha256']['ACTORS.OBJ'],'complete native OMF contract')
 run([home/'bin/objconv','-fcoff32','-wex',w/'ACTORS.ELF',w/'ACTORS.COFF'],'COFF.LOG');outputs[str(w/'ACTORS.COFF')]=digest(w/'ACTORS.COFF');m=Module.parse((w/'ACTORS.OBJ').read_bytes());need([(s.name,s.class_name,s.size,s.attributes)for s in m.segments]==[tuple(x)for x in d['segments']],'descriptor segment inventory');need({n:[m._segment(s).name,o]for n,(s,o)in m.publics.items()}==d['global_definitions'],'descriptor global coordinates');need(set(m.externals)-set(m.publics)==set(d['genuine_imports']),'descriptor genuine imports');native=schema.check(w,m,[clock_start,int(time.time())]);dump(w/'source-guard.json',source_guard);dump(w/'native-schema.json',native);outputs.update({str(w/n):digest(w/n)for n in ['source-guard.json','native-schema.json']});fresh()
 r={'source_only':True,'target_SDK_development_object_decoder_read':False,'source_credit':0,'object':str(w/'ACTORS.OBJ'),'object_sha256':outputs[str(w/'ACTORS.OBJ')],'native_build_directory':str(w),'inputs_sha256':pins,'staged_sha256':expected,'outputs_sha256':outputs,'commands':commands,'source_guard':source_guard,'native_schema':native,'native_segments':[(s.name,s.class_name,s.size,s.attributes)for s in m.segments],'required_original_default_libraries':['math387r','emu387'],'opt_in_link_handoff':{'replace':'O001.OBJ','remove_FILE':'O002.OBJ'}}
 fresh();receipt=w/'source-build.json';dump(receipt,r)
 try:fresh()
 except Exception:
  receipt.unlink();raise
 return r

def check_freshness(receipt,home):
 read_contract();unchanged(receipt['inputs_sha256']);unchanged(receipt['staged_sha256']);unchanged(receipt['outputs_sha256']);checked_home(home)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path,default=ROOT/'toolchains/gnu-elf-omf-layouts');p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True);a=p.parse_args();r=build_source(a.home,a.build);a.report.parent.mkdir(parents=True,exist_ok=True);dump(a.report,r);print('ACTORS SOURCE BUILT',r['object_sha256'],'61674 CODE/67 CONST/6 BSS/2812 fields')
if __name__=='__main__':main()
