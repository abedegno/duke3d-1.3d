"""Verify GAMEDEF public intervals, initialized data and complete contributions.

The detailed interval diagnostics accompany the standard complete-module proof.
Neither proof establishes a linked or byte-identical complete executable.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from le import LEImage
from runner import compile_source,compiler_bin
from tools.probe_premap import check_intervals
from tools.prove_module import prepare_headers,digest,assert_contributions
from tools.infer_bindings import infer_bindings,BindingError
from tools.match_function import compare_range
from tools.verify_module import verify_module,ModuleError,external_anchor_bindings
from tools.preserve import TARGET_SHA256

FUNCTIONS={
    'getincangle_':(145840,80),'ispecial_':(145920,48),
    'isaltok_':(145968,64),'getglobalz_':(146032,512),
    'makeitfall_':(146544,448),'getlabel_':(146992,144),
    'keyword_':(147136,128),'transword_':(147264,272),
    'transnum_':(147536,960),'parsecommand_':(148496,5616),
    'passone_':(154112,48),'loadefs_':(154160,672),'dodge_':(154832,320),
    'furthestangle_':(155152,272),'furthestcanseepoint_':(155424,416),
    'alterang_':(155840,656),'move_':(156496,2288),
    'parseifelse_':(158784,528),'parse_':(159312,13072),'execute_':(172384,721),
}
OPTIONS=['/4r','/s','/ort','/dAPPVER_EXEDEF=DN3D13G','/dLIBVER_BUILDREV=19960320']
DATA_PLACEMENTS={4:(3,30424),6:(3,4348)}
DATA_BINDINGS={'_keyw':(3,30424),'_gamedef_text':(3,4348)}


def check_data(module,image):
    active={n for n,s in enumerate(module.segments,1)
            if s.size and s.class_name.upper() not in ('CODE','BSS')}
    if active!={4,6}:
        raise ValueError('unexpected initialized data segments')
    if module.publics.get('_keyw')!=(4,0) or module.publics.get('_gamedef_text')!=(6,0):
        raise ValueError('changed owned data public placement')
    rows=[]
    for segment,size in [(4,396),(6,3173)]:
        if module.segments[segment-1].size!=size:
            raise ValueError('changed initialized data extent')
        obj,target=DATA_PLACEMENTS[segment]
        comparison=compare_range(module,segment,0,image,obj,target,size,
                                 DATA_BINDINGS,DATA_PLACEMENTS)
        if comparison['match'] is not True:
            raise ValueError('unmasked initialized data mismatch')
        rows.append({'segment':segment,'target_object':obj,'target_offset':target,
                     'size':size,'comparison':comparison})
    return rows


def probe(home,build):
    binary=(ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(binary).hexdigest()!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    image=LEImage.parse(binary)
    source=ROOT/'src/game/gamedef.c';identity=digest(source)
    build.mkdir(parents=True,exist_ok=False);headers=build/'include'
    prepare_headers([ROOT/'reference/duke3d-reconstructions',
                     ROOT/'reference/duke3d-reconstructions/MACT'],
                    [ROOT/'src/include',ROOT/'src/game/include',ROOT/'src/engine/include'],headers)
    obj=build/'gamedef.obj'
    compile_source(home,source,obj,OPTIONS,30,include_dirs=[headers])
    if digest(source)!=identity:
        raise ValueError('source changed during compilation')
    module=Module.parse(obj.read_bytes())
    initialized=check_data(module,image)
    known=dict(DATA_BINDINGS)
    known.update({name:(1,target) for name,(target,_) in FUNCTIONS.items()})
    anchors={}
    referenced={module.externals[f.target-1] for f in module.fixups if f.target_method==2}
    for filename,key in [('engine-function-matches.json','module_verification'),
                         ('sounds-module.json','verification')]:
        path=ROOT/'evidence'/filename;report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256:
            raise ValueError('anchor reference identity mismatch')
        for name,value in external_anchor_bindings(report[key]).items():
            if name not in referenced:continue
            value=tuple(value)
            if name in known and known[name]!=value:
                raise ValueError('conflicting independent binding: '+name)
            known[name]=value
        anchors[str(path.relative_to(ROOT))]=digest(path)
    functions=check_intervals(module,image,FUNCTIONS,known)
    # The named data-public anchors also constrain CODE-derived segment bases.
    for row in functions:
        for segment,placement in row['placements'].items():
            if segment in DATA_PLACEMENTS and tuple(placement)!=DATA_PLACEMENTS[segment]:
                raise ValueError('CODE/data placement conflict')
    full=infer_bindings(module,image,1,145840,known_symbols=known)
    full_gate=verify_module(module,image,full['placements'],full['symbols'])
    assert_contributions(full_gate,{'initialized_bytes':30834,'zero_fill_bytes':40,'verified_fixups':2339})
    return {'kind':'complete GAMEDEF contributions with public interval diagnostics, not a full executable',
            'target_sha256':TARGET_SHA256,'source':'src/game/gamedef.c','source_sha256':identity,
            'headers_sha256':{p.name:digest(p) for p in sorted(headers.iterdir())},
            'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe'),'options':OPTIONS,
            'anchor_evidence_sha256':anchors,'functions':functions,'initialized_data':initialized,
            'data_placements':DATA_PLACEMENTS,'data_bindings':DATA_BINDINGS,
            'matched_function_bytes':sum(f['size'] for f in functions),
            'matched_function_fixups':sum(f['comparison']['verified_fixups'] for f in functions),
            'matched_initialized_data_bytes':sum(f['size'] for f in initialized),
            'matched_data_fixups':sum(f['comparison']['verified_fixups'] for f in initialized),
            'source_code_bytes':module.segments[0].size,
            'source_bss_bytes':sum(s.size for s in module.segments if s.class_name.upper()=='BSS'),
            'unverified_code_publics':sorted(n for n,(s,_) in module.publics.items() if s==1 and n not in FUNCTIONS),
            'full_module_gate':full_gate,
            'scope':'All public CODE intervals and initialized data are checked, followed by a complete module check with one CODE placement and every native segment, public and relocation. A public interval may contain a following function switch-table prefix. Linking and the complete executable remain unverified.',
            'new_complete_contributions':1,'full_executable_rebuilt':False}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    parser.add_argument('--build',type=Path,required=True,help='fresh staging directory')
    parser.add_argument('--report',type=Path,required=True)
    args=parser.parse_args();report=probe(args.home.resolve(),args.build.resolve())
    args.report.write_text(json.dumps(report,indent=2)+'\n')
    print(f"GAMEDEF VERIFIED: {len(report['functions'])} CODE intervals, "
          f"{report['matched_function_bytes']} CODE bytes, "
          f"{report['matched_initialized_data_bytes']} data bytes; full module verified, executable unfinished")


if __name__=='__main__':main()
