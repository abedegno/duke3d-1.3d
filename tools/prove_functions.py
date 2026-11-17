"""Compile recorded candidates and compare complete relocated function bytes."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'exhume/profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import compile_source
from tools.match_function import match_function, MatchError
from tools.preserve import TARGET_SHA256


def prove(home: Path, output: Path) -> dict:
    target=(ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(target).hexdigest()!=TARGET_SHA256:
        raise ValueError('Reference target identity mismatch')
    image=LEImage.parse(target)
    config=json.loads((ROOT/'evidence/functions.json').read_text())
    bindings=json.loads((ROOT/'evidence/bindings.json').read_text())['symbols']
    modules,results={},[]
    for function in config['functions']:
        source=function['source']
        if source not in modules:
            obj=output/Path(source).with_suffix('.obj')
            compile_source(home,ROOT/source,obj,config['options'],30)
            modules[source]=Module.parse(obj.read_bytes())
        mod=modules[source]
        try:
            r=match_function(mod,function['symbol'],image,function['object'],
                             function['offset'],function['size'],bindings)
        except MatchError as error:
            r=dict(symbol=function['symbol'],match=False,error=str(error))
        r.update(source=source,source_sha256=hashlib.sha256((ROOT/source).read_bytes()).hexdigest())
        results.append(r)
    return {'compiler_home':str(home),'compiler_sha256':hashlib.sha256(
                (home/'BINB/wcc386.exe').read_bytes()).hexdigest(),
            'target_sha256':TARGET_SHA256,'options':config['options'],
            'results':results,'matched':sum(r['match'] for r in results),'total':len(results),
            'full_executable_rebuilt':False}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    p.add_argument('--build',type=Path,default=ROOT/'build/proof')
    p.add_argument('--report',type=Path,default=ROOT/'evidence/matches.json')
    a=p.parse_args()
    report=prove(a.home.resolve(),a.build.resolve())
    a.report.parent.mkdir(parents=True,exist_ok=True)
    a.report.write_text(json.dumps(report,indent=2)+'\n')
    print(f"Matched {report['matched']}/{report['total']} functions; full executable rebuild remains outstanding")
    for r in report['results']:
        print(('MATCH ' if r['match'] else 'DIFF  ')+r['symbol']+
              (': '+r['error'] if 'error' in r else ''))
    raise SystemExit(0 if report['matched']==report['total'] else 1)
