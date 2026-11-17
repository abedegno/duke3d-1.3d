"""Build the released v1.5 C modules as a named mapping reference.

These objects are reference evidence, not recovered v1.3D source or an
exact v1.5 executable. Engine/library linking is deliberately not claimed.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'profiles/watcom/tools'))
from runner import compile_source
from omf32 import Module

MODULES=['GAME','ACTORS','GAMEDEF','GLOBAL','MENUES','PLAYER','PREMAP','SECTOR',
         'SOUNDS','RTS','CONFIG','ANIMLIB']


def build(home: Path, output: Path) -> dict:
    sources=ROOT/'dukenukem3d/source'
    reference_commit=subprocess.check_output(['git','-C',str(sources),
        'rev-parse','HEAD'],text=True).strip()
    report={'kind':'released-source compiler objects for mapping only',
            'reference_commit':reference_commit,'compiler_sha256':hashlib.sha256(
                (home/'BINB/wcc386.exe').read_bytes()).hexdigest(),'modules':[]}
    for name in MODULES:
        src=sources/(name+'.C')
        obj=output/(name.lower()+'.obj')
        opts=['/4r','/s','/otexan']+(['/zu'] if name=='SOUNDS' else [])
        compile_source(home,src,obj,opts,60,include_dirs=[sources])
        mod=Module.parse(obj.read_bytes())
        report['modules'].append({
            'source':str(src.relative_to(ROOT)),'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),
            'object_sha256':hashlib.sha256(obj.read_bytes()).hexdigest(),
            'options':opts,'publics':mod.publics,'external_count':len(mod.externals),
            'fixup_count':len(mod.fixups),'code_data_ranges':mod.code_data_ranges,
            'default_libraries':mod.default_libraries,
            'segments':[{'name':s.name,'class':s.class_name,'size':s.size} for s in mod.segments],
        })
        print(f'{name}: {len(mod.publics)} public symbols, {len(mod.fixups)} fixups',flush=True)
    return report


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    p.add_argument('--build',type=Path,default=ROOT/'build/sibling')
    p.add_argument('--report',type=Path,default=ROOT/'evidence/sibling.json')
    a=p.parse_args()
    report=build(a.home.resolve(),a.build.resolve())
    a.report.parent.mkdir(parents=True,exist_ok=True)
    a.report.write_text(json.dumps(report,indent=2)+'\n')
