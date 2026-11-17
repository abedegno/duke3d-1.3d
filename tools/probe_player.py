"""Compile and verify the complete native PLAYER contribution without masks.

All public intervals, prefix/tables, DATA/CONST and BSS pass the unchanged
full-module verifier at one placement. The complete executable is not rebuilt.
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
from tools.prove_module import prepare_headers,digest,assert_contributions
from tools.probe_premap import OPTIONS,check_intervals
from tools.infer_bindings import infer_bindings,BindingError
from tools.verify_module import verify_module,ModuleError,external_anchor_bindings
from tools.preserve import TARGET_SHA256

FUNCTIONS={
    'setpal_':(204096,160),
    'incur_damage_':(204256,208),
    'quickkill_':(204464,128),
    'forceplayerangle_':(204592,64),
    'tracers_':(204656,368),
    'hits_':(205024,208),
    'hitasprite_':(205232,272),
    'displayloogie_':(214544,288),
    'animatefist_':(214832,352),
    'displaymasks_':(215840,400),
    'doincrements_':(225776,1280),
    'hitawall_':(205504,128),
    'aim_':(205632,992),
    'shoot_':(206624,7920),
    'animateknee_':(215184,336),
    'animateknuckles_':(215520,320),
    'animatetip_':(216240,304),
    'animateaccess_':(216544,624),
    'displayweapon_':(217168,6512),
    'getinput_':(223680,2096),
    'checkweapons_':(227056,112),
    'processinput_':(227168,13802),
}


def check_weapon_sprites(module,image,bindings):
    """Verify only the measured eleven-entry drop table, not all PLAYER DATA."""
    if module.publics.get('_weapon_sprites')!=(4,12):
        raise ValueError('unexpected weapon_sprites source extent')
    if module.segments[3].size!=34 or '_fdmatrix' in module.publics:
        raise ValueError('unexpected complete PLAYER DATA extent')
    if tuple(bindings.get('_weapon_sprites',()))!=(3,31232):
        raise ValueError('conflicting weapon_sprites anchor')
    if any(f.segment==4 and f.offset<34 and f.offset+f.width>12 for f in module.fixups):
        raise ValueError('unexpected weapon_sprites fixup')
    view=copy.deepcopy(module)
    table=bytes(view.segments[3].data[12:34])
    for segment in view.segments:
        segment.size=0;segment.data=bytearray()
    view.segments[3].size=22;view.segments[3].data=bytearray(table)
    view.fixups=[];view.publics={'_weapon_sprites':(4,0)}
    view.local_publics &= view.publics.keys()
    proof=verify_module(view,image,{4:(3,31232)},{'_weapon_sprites':(3,31232)})
    proof['scope']='Only the eleven-entry weapon_sprites table, source DATA offsets12..34. Other DATA, CODE tables, BSS and complete module placement are not proved.'
    return proof


def check_complete(module,image,known):
    """Check the complete descriptor and unchanged full-module verifier."""
    spec=json.loads((ROOT/'modules/player.json').read_text())
    code=[(i,s) for i,s in enumerate(module.segments,1) if s.size and s.class_name.upper()=='CODE']
    if len(code)!=1 or code[0][0]!=1 or code[0][1].size!=spec['code_bytes']:
        raise ValueError('incomplete PLAYER CODE extent')
    publics={n for n,(segment,_) in module.publics.items() if segment==1}
    if len(publics)!=spec['code_publics'] or publics!=set(FUNCTIONS):
        raise ValueError('incomplete PLAYER CODE inventory')
    bound=infer_bindings(module,image,spec['code_object'],spec['code_offset'],known_symbols=known)
    proof=verify_module(module,image,bound['placements'],bound['symbols'])
    assert_contributions(proof,spec['expected'])
    return bound,proof


def probe(home,build):
    descriptor=ROOT/'modules/player.json';descriptor_bytes=descriptor.read_bytes()
    spec=json.loads(descriptor_bytes)
    if spec['source']!='src/game/player.c' or spec['options']!=OPTIONS:
        raise ValueError('PLAYER descriptor source/options mismatch')
    binary=(ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(binary).hexdigest()!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    image=LEImage.parse(binary);source=ROOT/'src/game/player.c';identity=digest(source)
    build.mkdir(parents=True,exist_ok=False);headers=build/'include'
    prepare_headers([ROOT/'reference/duke3d-reconstructions',
                     ROOT/'reference/duke3d-reconstructions/MACT'],
                    [ROOT/'src/include',ROOT/'src/game/include',ROOT/'src/engine/include'],headers)
    obj=build/'player.obj'
    compile_source(home,source,obj,OPTIONS,30,include_dirs=[headers])
    if digest(source)!=identity:raise ValueError('source changed during compilation')
    warnings=[line.split('Warning! ',1)[1].strip() for line in obj.with_suffix('.log').read_text(errors='replace').splitlines() if 'Warning! ' in line]
    if warnings!=["W107: Missing return value for function 'hitawall'"]:
        raise ValueError('unexpected PLAYER compiler diagnostics: '+repr(warnings))
    module=Module.parse(obj.read_bytes())
    referenced={module.externals[f.target-1] for f in module.fixups if f.target_method==2}
    known={name:(1,target) for name,(target,_) in FUNCTIONS.items()};anchors={}
    for filename,key in [('engine-function-matches.json','module_verification'),
                         ('gamedef-module.json','verification'),('sounds-module.json','verification'),
                         ('mmulti-module.json','verification'),('config-module.json','verification')]:
        path=ROOT/'evidence'/filename;report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256 or report[key].get('verified') is not True:
            raise ValueError('anchor reference identity mismatch')
        for name,value in external_anchor_bindings(report[key]).items():
            if name not in referenced and name not in FUNCTIONS:continue
            value=tuple(value)
            if name in known and known[name]!=value:raise ValueError('conflicting independent binding: '+name)
            known[name]=value
        anchors[str(path.relative_to(ROOT))]=digest(path)
    for filename in ['actors-progress.json','premap-progress.json']:
        path=ROOT/'evidence'/filename;report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256:raise ValueError('partial anchor reference identity mismatch')
        for function in report['functions']:
            if function['comparison']['match'] is not True:raise ValueError('unverified partial function identity')
            name=function['symbol'];value=(1,function['target_offset'])
            if name not in referenced:continue
            if name in known and known[name]!=value:raise ValueError('conflicting partial function identity: '+name)
            known[name]=value
        anchors[str(path.relative_to(ROOT))]=digest(path)
    functions=check_intervals(module,image,FUNCTIONS,known)
    shared={name:tuple(value) for row in functions for name,value in row['bindings'].items()}
    weapon_sprites=check_weapon_sprites(module,image,shared)
    independent={n:tuple(v) for n,v in known.items() if n not in module.publics}
    if independent!={n:tuple(v) for n,v in spec['symbol_anchors'].items()}:
        raise ValueError('PLAYER descriptor differs from independent anchors')
    bound,full=check_complete(module,image,known)
    if descriptor.read_bytes()!=descriptor_bytes:raise ValueError('descriptor changed during compilation')
    return {'kind':'complete PLAYER object contributions, not a full executable',
            'target_sha256':TARGET_SHA256,'source':'src/game/player.c','source_sha256':identity,
            'headers_sha256':{p.name:digest(p) for p in sorted(headers.iterdir())},
            'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe'),'options':OPTIONS,
            'anchor_evidence_sha256':anchors,'functions':functions,
            'matched_function_bytes':sum(f['size'] for f in functions),
            'matched_function_fixups':sum(f['comparison']['verified_fixups'] for f in functions),
            'source_code_bytes':sum(s.size for s in module.segments if s.class_name.upper()=='CODE'),
            'unverified_code_publics':sorted(n for n,(s,_) in module.publics.items() if s==1 and n not in FUNCTIONS),
            'full_module_gate':full,'verification':full,
            'placements':bound['placements'],'constraints':bound['constraints'],
            'descriptor':'modules/player.json','descriptor_sha256':hashlib.sha256(descriptor_bytes).hexdigest(),
            'symbol_anchors':spec['symbol_anchors'],'compiler_warnings':warnings,
            'omitted_code_bodies':[],
            'excluded_later_source_functions':['getspritescore','computergetinput'],
            'omitted_data':[],
            'weapon_sprites_storage':weapon_sprites,
            'source_segment_inventory':[{'segment':i,'name':s.name,'class':s.class_name,'size':s.size}
                                        for i,s in enumerate(module.segments,1)],
            'scope':'Every emitted byte and fixup, all22 public CODE intervals, the208-byte leading CODE prefix, identified CONST strings/alignment residue, DATA and BSS match at one consistent full-module placement. Later bot source/state is excluded from this contribution; its presence elsewhere in the executable is not established. Linking and full-file identity remain unverified.',
            'leading_code_prefix_verified':True,'initialized_data_verified':True,'bss_verified':True,
            'new_complete_contributions':1,'full_executable_rebuilt':False}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    p.add_argument('--build',type=Path,required=True)
    p.add_argument('--report',type=Path,required=True)
    a=p.parse_args();report=probe(a.home.resolve(),a.build.resolve())
    a.report.write_text(json.dumps(report,indent=2)+'\n')
    print(f"PLAYER VERIFIED: {len(report['functions'])} intervals, "
          f"{report['matched_function_bytes']} bytes, {report['matched_function_fixups']} fixups; complete native contribution")


if __name__=='__main__':main()
