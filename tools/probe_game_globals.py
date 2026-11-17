"""Reproduce GLOBAL layout diagnostics; this is not a module recovery proof."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import compile_source,compiler_bin
from tools.preserve import TARGET_SHA256
from tools.prove_module import prepare_headers,digest


def probe(home,build):
    target=ROOT/'reference/DUKE3D.EXE'
    if digest(target)!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    ref=ROOT/'reference/duke3d-reconstructions'
    upstream=ref/'GLOBAL.C'
    if digest(upstream)!='1c30c003edfab958293c9e6876f4e3455041aa7682522baad8b3262e620f04f9':
        raise ValueError('GLOBAL source identity mismatch')
    build.mkdir(parents=True,exist_ok=False)
    headers=build/'include'
    prepare_headers([ref,ref/'MACT'],[ROOT/'src/include',ROOT/'src/game/include'],headers)
    # Save/load records distinguish 4096 engine sprites from 2048 hit records.
    # Allocation ownership remains tentative; do not shrink the engine limit.
    header=headers/'build.h'
    raw=header.read_bytes().replace(b'#define MAXTILES 6144',b'#define MAXTILES 4096')
    header.write_bytes(raw)
    header=headers/'duke3d.h'
    header.write_text(header.read_text().replace('hittype[MAXSPRITES]','hittype[2048]'))
    source=build/'global.c'
    source.write_text(upstream.read_text().replace('hittype[MAXSPRITES]','hittype[2048]').replace('spriteqamount=64','spriteqamount')
                      .replace('playonten = 0,','')
                      .replace('cloudtotalclock = 0,totalmemory = 0','cloudtotalclock,totalmemory'))
    options=['/4r','/s','/ort','/dAPPVER_EXEDEF=DN3D13G']
    obj=build/'global.obj'
    compile_source(home,source,obj,options,30,include_dirs=[headers])
    module=Module.parse(obj.read_bytes())
    image=LEImage.parse(target.read_bytes())
    data=[s for s in module.segments if s.name=='_DATA']
    if len(data)!=1 or data[0].size!=64:
        raise ValueError('unexpected diagnostic DATA extent')
    original=bytes(data[0].data);observed=image.object_bytes(3)[31140:31204]
    differences=[{'offset':i,'source':a,'target':b}
                 for i,(a,b) in enumerate(zip(original,observed)) if a!=b]
    bindings={};evidence={}
    for path in sorted((ROOT/'evidence').glob('*-module.json')):
        report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256:continue
        for name,value in report.get('verification',{}).get('publics',{}).items():
            if name not in module.publics or name=='_dmval':continue
            bindings.setdefault(name,set()).add(tuple(value))
            evidence[path.name]=digest(path)
    rows=[]
    for name,values in sorted(bindings.items()):
        segment,offset=module.publics[name]
        rows.append({'symbol':name,'source_segment':segment,'source_offset':offset,
                     'existing_logical_bindings':[list(v) for v in sorted(values)],
                     'implied_segment_bases':[[o,a-offset] for o,a in sorted(values)]})
    observations=ROOT/'evidence/save-layout-observations.json'
    return {'status':'diagnostic only; complete GLOBAL contribution is unverified',
            'target_sha256':TARGET_SHA256,'upstream':'reference/duke3d-reconstructions/GLOBAL.C',
            'upstream_sha256':digest(upstream),'generated_source_sha256':digest(source),
            'headers_sha256':{p.name:digest(p) for p in sorted(headers.iterdir())},
            'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe'),'options':options,
            'source_transformations':['Use an explicit 2048-element hit-record declaration while retaining the 4096-sprite engine limit.',
                                      'Remove spriteqamount initializer, retaining BSS declaration.',
                                      'Remove playonten definition.',
                                      'Move cloudtotalclock and totalmemory from initialized DATA to BSS.'],
            'configured_limits':{'MAXSPRITES':4096,'hit_records':2048,'MAXTILES':4096},
            'inferred_game_limits':{'MAX_WEAPONS':11},
            'record_observations':{'evidence':'evidence/save-layout-observations.json',
                                   'sha256':digest(observations),
                                   'note':'Explicit saved/read counts do not by themselves prove original allocation sizes or macro names.'},
            'limits_note':'Unproved hypotheses; no complete BSS placement is inferred. Restored external declarations allocate state only where GLOBAL defines them. Remaining ancestral fields and inferred extents have not all been verified; these candidate allocations are not counted as recovered ownership.',
            'data_observation':{'object':3,'offset':31140,'size':64,
                                'source_sha256':hashlib.sha256(original).hexdigest(),
                                'target_sha256':hashlib.sha256(observed).hexdigest(),
                                'differing_bytes':differences,'byte_identical':not differences},
            'segments':[{'name':s.name,'size':s.size} for s in module.segments],
            'binding_scope':'Existing complete proofs establish physical references and consistent logical bindings, not original ownership or full external type sizes. Different implied BSS bases reject this tentative layout.',
            'existing_evidence_sha256':evidence,'binding_diagnostics':rows,
            'new_recovered_contributions':0,'full_module_verified':False,
            'full_executable_rebuilt':False}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    p.add_argument('--build',type=Path,required=True,help='fresh diagnostic directory')
    p.add_argument('--report',type=Path,required=True)
    a=p.parse_args();report=probe(a.home.resolve(),a.build.resolve())
    a.report.write_text(json.dumps(report,indent=2)+'\n')
    print('GLOBAL diagnostic: 64 DATA bytes; '+str(len(report['data_observation']['differing_bytes']))+
          ' differing bytes; full contribution remains unverified')


if __name__=='__main__':main()
