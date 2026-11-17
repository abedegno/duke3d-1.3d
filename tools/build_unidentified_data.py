"""Build the explicitly approved unidentified DATA fragment from tracked source."""
from pathlib import Path
from dataclasses import asdict,is_dataclass
import argparse,hashlib,json,re,shutil,subprocess,sys,tempfile
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from profiles.gnu_elf_omf.identity import checked_home,profile
from profiles.gnu_elf_omf.elf32 import elf
SOURCE='src/game/unidentified13d_data.S'
NOTICE='src/game/unidentified13d_data.md'
SPEC='candidates/unidentified_data.json'
HELPERS=['tools/build_unidentified_data.py','profiles/gnu_elf_omf/identity.py',
         'profiles/gnu_elf_omf/profile.json','profiles/gnu_elf_omf/elf32.py',
         'profiles/watcom/tools/omf32.py','profiles/watcom/tools/le.py',
         'tools/verify_module.py','tools/match_function.py']
TARGET='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'
OUTPUTS={'UNIDENT.ELF','UNIDENT.OBJ','UNIDENT.LST','AS.LOG','OBJ.LOG'}
def need(condition,message):
    if not condition:raise ValueError('unidentified DATA '+message)
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def dump(path,value):Path(path).write_text(json.dumps(value,indent=2)+'\n')
def unchanged(pins,message):
    need(all(Path(p).is_file()and sha(p)==h for p,h in pins.items()),message)
def encode(value):
    if is_dataclass(value):return encode(asdict(value))
    if isinstance(value,(bytes,bytearray)):return {'hex':bytes(value).hex()}
    if isinstance(value,dict):return {str(k):encode(v)for k,v in value.items()}
    if isinstance(value,set):return sorted(encode(v)for v in value)
    if isinstance(value,(tuple,list)):return [encode(v)for v in value]
    return value
def inventory(module):
    result=encode(vars(module))
    result['segments']=[{k:v for k,v in s.items()if k!='data'}for s in result['segments']]
    return result
_LOADED={name:sha(ROOT/name)for name in HELPERS}
def read_spec():
    raw=(ROOT/SPEC).read_bytes();spec=json.loads(raw)
    need(spec['name']=='unidentified_data96'and spec['historical_source_credit']==0
         and spec['complete_module_credit']==0,'bounded preservation scope')
    need(set(spec['helpers_sha256'])==set(HELPERS)and spec['helpers_sha256']==_LOADED,'loaded helper set/identity')
    pins={str(ROOT/name):h for name,h in spec['helpers_sha256'].items()}
    pins.update({str(ROOT/SOURCE):spec['source_sha256'],str(ROOT/NOTICE):spec['notice_sha256'],
                 str(ROOT/SPEC):hashlib.sha256(raw).hexdigest(),
                 str(Path(sys.executable).resolve()):spec['python_sha256']})
    unchanged(pins,'source/notice/helper identity changed')
    return spec,pins
def parse_source(text):
    text=re.sub(r'/\*.*?\*/','',text,flags=re.S)
    rows=[s.strip()for s in text.splitlines()if s.strip()]
    need(rows[:3]==['.section _DATA,"aw",@progbits','.p2align 2','.Lunidentified_region:'],'source directive/header')
    data=[];literal=zero=0
    for row in rows[3:]:
        if row.startswith('.byte '):
            values=row[6:].split(',')
            need(len(data)+len(values)<=96 and all(re.fullmatch(r'0x[0-9a-fA-F]{2}|[0-9]{1,3}',v.strip())for v in values),'source directive byte operands')
            numbers=[int(v.strip(),16 if v.strip().startswith('0x')else 10)for v in values]
            need(all(0<=v<=255 for v in numbers),'source directive byte range')
            data.extend(numbers);literal+=len(numbers)
        elif re.fullmatch(r'.zero [0-9]{1,2}',row):
            size=int(row.split()[1]);need(len(data)+size<=96,'source directive zero extent');data.extend([0]*size);zero+=size
        else:raise ValueError('unidentified DATA source directive not allowed: '+row)
    need(len(data)==96 and literal==28 and zero==68,'source directive complete96-byte shape')
    return bytes(data)
def check_native(module,el,source,spec):
    need(inventory(module)==spec['native_inventory'],'native metadata/scope/extent contract')
    nonempty=[s for s in module.segments if s.size]
    need(len(nonempty)==1 and(nonempty[0].name,nonempty[0].class_name,nonempty[0].size)==('_DATA','DATA',96),'native DATA-only contribution')
    need(not(module.publics or module.externals or module.fixups),'native symbol/field obligations')
    sections=[s for s in el['sections']if s['size']and s['flags']&2]
    need(len(sections)==1 and(sections[0]['name'],sections[0]['type'],sections[0]['flags'],sections[0]['size'],sections[0]['align'])==('_DATA',1,3,96,4),'ELF nonexecutable DATA-only section')
    need(bytes(nonempty[0].data)==bytes.fromhex(sections[0]['bytes'])==source,'complete source/ELF/OMF DATA bytes')
def build(parent,home=None):
    spec,pins=read_spec();home=Path(home or ROOT/'toolchains/gnu-elf-omf').resolve()
    pins.update({str(home/name):h for name,h in checked_home(home).items()})
    source=parse_source((ROOT/SOURCE).read_text());unchanged(pins,'live input changed')
    parent=Path(parent).resolve();parent.mkdir(parents=True,exist_ok=True)
    work=Path(tempfile.mkdtemp(prefix='unidentified-data-',dir=parent));stage=work/'source-only';stage.mkdir()
    expected={str(stage/'UNIDENT.S'):spec['source_sha256'],str(stage/'NOTICE.md'):spec['notice_sha256']}
    shutil.copyfile(ROOT/SOURCE,stage/'UNIDENT.S');shutil.copyfile(ROOT/NOTICE,stage/'NOTICE.md')
    outputs={};commands=[]
    def stable():
        unchanged(pins,'live input changed');unchanged(expected,'stage identity changed')
        need({str(p)for p in stage.iterdir()}==set(expected),'stage file set changed')
        need(parse_source((stage/'UNIDENT.S').read_text())==source,'staged source directives changed')
        unchanged(outputs,'native output changed');checked_home(home)
    def run(command,log):
        stable();commands.append(command);p=subprocess.run(command,capture_output=True,text=True)
        (work/log).write_text(p.stdout+p.stderr)
        need(p.returncode==0 and not p.stderr and 'warning'not in p.stdout.lower(),'native diagnostics: '+p.stdout+p.stderr)
        stable()
    run([str(home/'bin/as-new'),*profile()['options']['assembler'],'-al='+str(work/'UNIDENT.LST'),'-o',str(work/'UNIDENT.ELF'),str(stage/'UNIDENT.S')],'AS.LOG')
    outputs.update({str(work/name):sha(work/name)for name in ['UNIDENT.ELF','UNIDENT.LST','AS.LOG']})
    run([str(home/'bin/objconv'),*profile()['options']['converter'],str(work/'UNIDENT.ELF'),str(work/'UNIDENT.OBJ')],'OBJ.LOG')
    outputs.update({str(work/name):sha(work/name)for name in ['UNIDENT.OBJ','OBJ.LOG']})
    obj=work/'UNIDENT.OBJ';check_native(Module.parse(obj.read_bytes()),elf(work/'UNIDENT.ELF'),source,spec);stable()
    result={'name':'unidentified_data96','source_only':True,'reference_or_archive_read_during_production':False,
            'native_build_directory':str(work),'compiler_home':str(home),'object':str(obj),'object_sha256':sha(obj),
            'inputs_sha256':pins,'staged_sha256':expected,'outputs_sha256':outputs,'commands':commands,
            'historical_source_credit':0,'complete_module_credit':0,'full_executable_rebuilt':False}
    dump(work/'source-build.json',result);return result
def validate(result):
    spec,pins=read_spec();home=Path(result['compiler_home'])
    pins.update({str(home/name):h for name,h in checked_home(home).items()})
    need(result['inputs_sha256']==pins,'complete input receipt');unchanged(pins,'live input changed')
    work=Path(result['native_build_directory']);stage=work/'source-only'
    expected={str(stage/'UNIDENT.S'):spec['source_sha256'],str(stage/'NOTICE.md'):spec['notice_sha256']}
    need(result['staged_sha256']==expected,'complete stage receipt');unchanged(expected,'stage identity changed')
    need({str(p)for p in stage.iterdir()}==set(expected),'stage file set changed')
    need(set(result['outputs_sha256'])=={str(work/n)for n in OUTPUTS},'complete output receipt')
    unchanged(result['outputs_sha256'],'native output changed');obj=work/'UNIDENT.OBJ'
    need(result['object']==str(obj)and result['object_sha256']==sha(obj),'actual object receipt')
    source=parse_source((stage/'UNIDENT.S').read_text());module=Module.parse(obj.read_bytes())
    check_native(module,elf(work/'UNIDENT.ELF'),source,spec);return module

def observe(result,reference=None):
    module=validate(result)
    from le import LEImage
    from tools.verify_module import verify_module
    path=Path(reference or ROOT/'reference/DUKE3D.EXE');need(sha(path)==TARGET,'immutable target identity')
    image=LEImage.parse(path.read_bytes());segment=next(i for i,s in enumerate(module.segments,1)if s.size)
    proof=verify_module(module,image,{segment:(3,30820)},{})
    need([proof[k]for k in ['initialized_bytes','zero_fill_bytes','verified_fixups']]==[96,0,0],'complete source fragment proof')
    incoming=[encode(f)for f in image.read_fixups()if f.target_object==3 and 30820<=f.target_offset<30916]
    need(not incoming,'known incoming loader reference');need(sha(path)==TARGET,'target changed');validate(result)
    out={'name':'unidentified_data96','scope':'Explicitly authorized unidentified literal DATA preservation',
         'source_build':result,'verification':proof,'known_incoming_loader_fields':incoming,
         'historical_meaning':'unidentified','historical_source_credit':0,'complete_module_credit':0,
         'full_executable_rebuilt':False};dump(Path(result['native_build_directory'])/'whole-proof.json',out);return out

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path);p.add_argument('--build',type=Path,required=True)
    p.add_argument('--report',type=Path,required=True);p.add_argument('--source-only',action='store_true');p.add_argument('--reference',type=Path)
    a=p.parse_args();result=build(a.build,a.home);out=result if a.source_only else observe(result,a.reference)
    a.report.parent.mkdir(parents=True,exist_ok=True);dump(a.report,out)
    print('UNIDENTIFIED DATA96 source-only'if a.source_only else'UNIDENTIFIED DATA96 verified; historical/module credit0')
if __name__=='__main__':main()
