"""Compile partial ACTORS and verify explicit native public intervals.

Common names and non-CODE placements agree; non-CODE storage is checked
separately. The complete leading CODE data/alignment prefix is also checked.
The remaining effector body and full placement remain unverified. A masked mapping search never counts as proof or complete coverage.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import compile_source,compiler_bin
from tools.prove_module import prepare_headers,digest
from tools.probe_premap import OPTIONS,check_intervals
from tools.match_function import compare_range,is_alignment_padding
from tools.infer_bindings import infer_bindings,BindingError
from tools.verify_module import verify_module,ModuleError,external_anchor_bindings
from tools.preserve import TARGET_SHA256

FUNCTIONS={'addammo_': (84752, 112),
 'hitradius_': (86128, 2160),
 'ifhitbyweapon_': (91728, 864),
 'moveactors_': (111376, 11536),
 'addweapon_': (84864, 176),
 'bounce_': (104064, 512),
 'ceilingspace_': (84592, 80),
 'checkavailinven_': (85040, 256),
 'checkavailweapon_': (85296, 544),
 'clearsectinterpolate_': (90416, 144),
 'dointerpolations_': (84432, 112),
 'floorspace_': (84672, 80),
 'gutsdir_': (90016, 240),
 'ifhitsectors_': (91664, 64),
 'lotsofmoney_': (89648, 128),
 'movecyclers_': (92592, 272),
 'movefx_': (94320, 1168),
 'ms_': (90560, 256),
 'restoreinterpolations_': (84544, 48),
 'setinterpolation_': (84240, 80),
 'setsectinterpolate_': (90256, 160),
 'ssp_': (89472, 96),
 'stopinterpolation_': (84320, 112),
 'updateinterpolations_': (84192, 48),
 'ifsquished_': (85840, 288),
 'insertspriteq_': (89568, 80),
 'guts_': (89776, 240),
 'movefta_': (90816, 848),
 'movesprite_': (88288, 1184),
 'movedummyplayers_': (92864, 496),
 'moveplayers_': (93360, 960),
 'movefallers_': (95488, 816),
 'movestandables_': (96304, 7760),
 'moveweapons_': (104576, 3424),
 'moveexplosions_': (122912, 4144),
 'movetransports_': (108000, 3376)}


def check_storage(module,image,bindings):
    """Verify the complete non-CODE projection, never the complete module.

    CONST has one measured 67-byte string. BSS placement agrees with the
    _otherp reference in the exact player loop. CODE-resident tables are
    intentionally outside this projection and keep the umbrella data gate open.
    """
    noncode={i:(seg.name,seg.class_name,seg.size)
             for i,seg in enumerate(module.segments,1)
             if seg.size and seg.class_name.upper()!='CODE'}
    if noncode!={2:('CONST','DATA',67),5:('_BSS','BSS',6)}:
        raise ValueError('unexpected ACTORS non-CODE segment inventory')
    if module.publics.get('_dmval')!=(5,0) or module.publics.get('_otherp')!=(5,4):
        raise ValueError('unexpected ACTORS owned BSS publics')
    if tuple(bindings.get('_otherp',()))!=(3,77748):
        raise ValueError('conflicting ACTORS storage anchor')
    storage=copy.deepcopy(module)
    omitted={i for i,seg in enumerate(storage.segments,1)
             if seg.class_name.upper()=='CODE'}
    for i in omitted:
        storage.segments[i-1].size=0
        storage.segments[i-1].data=bytearray()
    storage.fixups=[f for f in storage.fixups if f.segment not in omitted]
    storage.publics={n:v for n,v in storage.publics.items() if v[0] not in omitted}
    storage.local_publics &= storage.publics.keys()
    proof=verify_module(storage,image,{2:(3,4280),5:(3,77744)},
                        {'_otherp':(3,77748)})
    proof['scope']='Complete non-CODE storage only; not a complete ACTORS contribution. CODE and its embedded tables are omitted.'
    proof['source_segments']=[2,5]
    return proof


def check_code_prefix(module,image):
    """Check the complete leading data/alignment extent at its measured base.

    Seven status values, one residue byte and eight short slime frames occupy
    compiler-recognized CODE data. Eight native no-op bytes align the first
    function. The residue's origin and original source names remain inferred.
    """
    if module.publics.get('_radius_status_record')!=(1,0) or \
            '_radius_status_record' not in module.local_publics:
        raise ValueError('unexpected ACTORS prefix record ownership')
    if module.publics.get('updateinterpolations_')!=(1,32):
        raise ValueError('unexpected ACTORS leading prefix extent')
    if module.code_data_ranges!=[(1,0,24)]:
        raise ValueError('unexpected ACTORS recognized CODE data extent')
    if not is_alignment_padding(bytes(module.segments[0].data[24:32])):
        raise ValueError('unexpected ACTORS prefix alignment')
    proof=compare_range(module,1,0,image,1,84160,32,{},
                        {1:(1,84160)},label='ACTORS leading CODE data/alignment')
    if proof['match'] is not True:
        raise ValueError('unmasked ACTORS leading prefix mismatch')
    proof.update({'source_segment':1,'source_offset':0,
                  'recognized_data_bytes':24,'native_alignment_bytes':8,
                  'status_values_bytes':7,'residue_offset':7,
                  'slime_frames_offset':8,'slime_frames_bytes':16,
                  'complete_prefix_verified':True})
    return proof


def probe(home,build):
    binary=(ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(binary).hexdigest()!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    image=LEImage.parse(binary);source=ROOT/'src/game/actors.c';identity=digest(source)
    build.mkdir(parents=True,exist_ok=False);headers=build/'include'
    prepare_headers([ROOT/'reference/duke3d-reconstructions',
                     ROOT/'reference/duke3d-reconstructions/MACT'],
                    [ROOT/'src/include',ROOT/'src/game/include',ROOT/'src/engine/include'],headers)
    obj=build/'actors.obj'
    compile_source(home,source,obj,OPTIONS,30,include_dirs=[headers])
    if digest(source)!=identity:raise ValueError('source changed during compilation')
    module=Module.parse(obj.read_bytes())
    referenced={module.externals[f.target-1] for f in module.fixups if f.target_method==2}
    known={name:(1,target) for name,(target,_) in FUNCTIONS.items()};anchors={}
    for filename,key in [('engine-function-matches.json','module_verification'),
                         ('gamedef-module.json','verification'),('sounds-module.json','verification'),
                         ('mmulti-module.json','verification')]:
        path=ROOT/'evidence'/filename;report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256:
            raise ValueError('anchor reference identity mismatch')
        for name,value in external_anchor_bindings(report[key]).items():
            if name not in referenced and name not in FUNCTIONS:continue
            value=tuple(value)
            if name in known and known[name]!=value:raise ValueError('conflicting independent binding: '+name)
            known[name]=value
        anchors[str(path.relative_to(ROOT))]=digest(path)
    path=ROOT/'evidence/premap-progress.json';report=json.loads(path.read_text())
    if report.get('target_sha256')!=TARGET_SHA256:raise ValueError('PREMAP reference identity mismatch')
    for function in report['functions']:
        if function['comparison']['match'] is not True:raise ValueError('unverified PREMAP identity')
        name=function['symbol'];value=(1,function['target_offset'])
        if name not in referenced:continue
        if name in known and known[name]!=value:raise ValueError('conflicting PREMAP identity: '+name)
        known[name]=value
    anchors[str(path.relative_to(ROOT))]=digest(path)
    functions=check_intervals(module,image,FUNCTIONS,known)
    shared={name:tuple(value) for row in functions for name,value in row['bindings'].items()}
    storage=check_storage(module,image,shared)
    prefix=check_code_prefix(module,image)
    if any(tuple(row['placements'][1])!=(1,84160) for row in functions):
        raise ValueError('ACTORS public interval conflicts with leading prefix base')
    try:
        full=infer_bindings(module,image,1,84160,known_symbols=known)
        verify_module(module,image,full['placements'],full['symbols'])
    except (BindingError,ModuleError) as error:
        full_gate={'verified':False,'error':str(error)}
    else:raise ValueError('whole module unexpectedly passes; promote via a complete descriptor')
    return {'kind':'partial ACTORS public interval checks, not a complete contribution',
            'target_sha256':TARGET_SHA256,'source':'src/game/actors.c','source_sha256':identity,
            'headers_sha256':{p.name:digest(p) for p in sorted(headers.iterdir())},
            'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe'),'options':OPTIONS,
            'anchor_evidence_sha256':anchors,'functions':functions,
            'matched_function_bytes':sum(f['size'] for f in functions),
            'matched_function_fixups':sum(f['comparison']['verified_fixups'] for f in functions),
            'source_code_bytes':sum(s.size for s in module.segments if s.class_name.upper()=='CODE'),
            'unverified_code_publics':sorted(n for n,(s,_) in module.publics.items() if s==1 and n not in FUNCTIONS and n!='_radius_status_record'),
            'full_module_gate':full_gate,'leading_code_prefix':prefix,'noncode_storage':storage,'noncode_storage_verified':True,
            'scope':'All bytes and fixups in the listed public intervals are checked. All listed public intervals agree on CODE base84160, logical names and non-CODE placements; their union omits the unverified effector body. A public interval can contain a following function switch-table prefix. All non-CODE initialized storage and BSS are checked separately. The complete32-byte leading CODE data/alignment prefix is checked at the same CODE base as every listed public. The remaining effector body, complete initialized-data gate, full module placement, linking and the executable remain unverified.',
            'leading_code_prefix_verified':True,'initialized_data_verified':False,'bss_verified':True,
            'new_complete_contributions':0,'full_executable_rebuilt':False}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    p.add_argument('--build',type=Path,required=True)
    p.add_argument('--report',type=Path,required=True)
    a=p.parse_args();report=probe(a.home.resolve(),a.build.resolve())
    a.report.write_text(json.dumps(report,indent=2)+'\n')
    print(f"ACTORS IN PROGRESS: {len(report['functions'])} intervals, "
          f"{report['matched_function_bytes']} bytes, {report['matched_function_fixups']} fixups; module unverified")


if __name__=='__main__':main()
