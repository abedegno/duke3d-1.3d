"""Compile complete PREMAP with ordinary inferred ownership of its abort byte.

Every native byte/fixup and actual public/local scope is checked. No neighbor
projection or injected BSS placement is used. Whole executable remains unproved.
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
from tools.infer_bindings import infer_bindings,BindingError
from tools.match_function import compare_range
from tools.verify_module import verify_module,ModuleError,external_anchor_bindings
from tools.preserve import TARGET_SHA256

FUNCTIONS={'xyzmirror_':(240976,176),'vscrn_':(241152,304),'pickrandomspot_':(241456,176),
           'resetplayerstats_':(241632,816),'resetweapons_':(242448,176),'resetinventory_':(242624,144),'resetprestat_':(242768,448),
           'setupbackdrop_':(243216,304),'cachespritenum_':(243520,1456),'cachegoodsprites_':(244976,528),'prelevel_':(245504,2592),'newgame_':(248096,336),
           'resetpspritevars_':(248432,1328),'resettimevars_':(249760,464),'genspriteremaps_':(250224,288),'waitforeverybody_':(250512,416),
           'compare_network_value_':(250928,192),'getsound_':(251120,240),
           'precachenecessarysounds_':(251360,64),'cacheit_':(251424,352),'dofrontscreens_':(251776,464),'enterlevel_':(252240,1390)}
OPTIONS=['/4r','/s','/ort','/dAPPVER_EXEDEF=DN3D13G','/dLIBVER_BUILDREV=19960320']


def check_source_interval(module,image,name,target,size,known):
    segment,start=module.publics[name]
    end=min((offset for seg,offset in module.publics.values() if seg==segment and offset>start),
            default=module.segments[segment-1].size)
    if segment!=1 or end-start!=size:
        raise ValueError('changed source interval extent: '+name)
    view=copy.deepcopy(module)
    view.publics={n:(seg,offset) for n,(seg,offset) in module.publics.items()
                  if n==name or module.segments[seg-1].class_name.upper()!='CODE'}
    view.fixups=[f for f in view.fixups if f.segment==segment and
                 f.offset<end and f.offset+f.width>start]
    if any(f.offset<start or f.offset+f.width>end for f in view.fixups):
        raise ValueError('source fixup crosses interval boundary: '+name)
    # Other CODE publics are intentionally not placed by this partial check.
    # Retain DATA/BSS publics: even external fixups to owned names must imply
    # a common segment base. Target callees retain independent bindings.
    bound=infer_bindings(view,image,1,target-start,known_symbols=known)
    result=compare_range(view,segment,start,image,1,target,size,
                         bound['symbols'],bound['placements'],label=name)
    if result['match'] is not True:raise ValueError('unmasked interval mismatch: '+name)
    used={view.externals[f.target-1] for f in view.fixups if f.target_method==2}|{name}
    return {'symbol':name,'source_offset':start,'target_offset':target,'size':size,
                          'comparison':result,
                          'bindings':{n:list(bound['symbols'][n]) for n in sorted(used)},
                          'placements':bound['placements']}


def check_intervals(module,image,definitions,known):
    # Each CODE placement is still independent, but a source-level external
    # cannot silently acquire a different physical address in another body.
    shared={n:tuple(v) for n,v in known.items()}
    rows=[]
    data_placements={}
    for name,(target,size) in definitions.items():
        row=check_source_interval(module,image,name,target,size,shared)
        for segment,placement in row['placements'].items():
            if segment==1:continue  # CODE placement remains interval-local.
            placement=tuple(placement)
            if segment in data_placements and data_placements[segment]!=placement:
                raise BindingError(f'conflicting shared segment placement: {segment}')
            data_placements[segment]=placement
        shared.update({n:tuple(v) for n,v in row['bindings'].items()})
        rows.append(row)
    return rows


def check_initialized_storage(module,image,bindings):
    """Check the complete recovered string pool, including alignment residue.

    Its common placement comes from CODE references. Other native DATA/BSS
    segments are not included in this initialized-pool projection.
    """
    segment,offset=module.publics['_premap_text']
    if offset!=0 or module.segments[segment-1].size!=278:
        raise ValueError('changed initialized string-pool extent')
    anchor=tuple(bindings['_premap_text'])
    if anchor!=(3,10600):raise ValueError('changed string-pool binding')
    storage=copy.deepcopy(module)
    for number,value in enumerate(storage.segments,1):
        if number!=segment:
            value.size=0
            value.data=bytearray()
    storage.fixups=[f for f in storage.fixups if f.segment==segment]
    storage.publics={n:(seg,off) for n,(seg,off) in storage.publics.items() if seg==segment}
    proof=verify_module(storage,image,{segment:anchor},{'_premap_text':anchor})
    assert_contributions(proof,{'initialized_bytes':278,'zero_fill_bytes':0,'verified_fixups':0})
    proof['source_segments']=[segment]
    proof['scope']='Complete string-pool segment only; this projection does not verify other native storage or the whole module.'
    return proof


def check_owned_state(module):
    """Validate the actual private scratch and public one-byte abort owner."""
    rows=[(n,s) for n,s in enumerate(module.segments,1)
          if s.size and s.class_name.upper()=='BSS']
    if len(rows)!=1:raise ValueError('changed native PREMAP BSS contribution')
    segment,state=rows[0]
    if ((segment,state.name,state.attributes,state.size)!=(5,'_BSS',105,5) or
            {n:v for n,v in module.publics.items() if v[0]==segment}!=
                {'_dmval':(5,0),'_wait_abort':(5,4)} or
            '_dmval' not in module.local_publics or '_wait_abort' in module.local_publics or
            any(state.data) or any(f.segment==segment for f in module.fixups)):
        raise ValueError('changed native PREMAP byte-owner extent or scope')
    return segment


def check_complete(module,image,known,spec):
    """Infer all native segments from real references, then verify every byte.

    No boundary placement, source-only projection or caller-supplied BSS base is
    injected. Active references to owned wait_abort naturally place its segment.
    """
    if (spec['source']!='src/game/premap.c' or spec['options']!=OPTIONS or
            spec['code_object']!=1 or spec['code_offset']!=240976 or
            spec['code_bytes']!=12654 or spec['code_publics']!=22 or
            'bss_boundary' in spec or 'boundary_evidence' in spec or
            spec['expected']!={'initialized_bytes':12932,'zero_fill_bytes':5,'verified_fixups':815} or
            module.segments[0].size!=spec['code_bytes'] or
            {n for n,(segment,_) in module.publics.items() if segment==1}!=set(FUNCTIONS) or
            module.publics!={n:tuple(v) for n,v in spec['expected_publics'].items()} or
            module.local_publics!=set(spec['expected_local_publics'])):
        raise ValueError('complete PREMAP descriptor/native geometry or scope mismatch')
    check_owned_state(module)
    for name,value in spec['symbol_anchors'].items():
        if name in module.publics or name not in known or tuple(value)!=tuple(known[name]):
            raise ValueError('descriptor independent anchor mismatch: '+name)
    full=infer_bindings(module,image,spec['code_object'],spec['code_offset'],known_symbols=known)
    proof=verify_module(module,image,full['placements'],full['symbols'])
    assert_contributions(proof,spec['expected'])
    return full,proof


def probe(home,build):
    binary=(ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(binary).hexdigest()!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    image=LEImage.parse(binary)
    source=ROOT/'src/game/premap.c';identity=digest(source)
    build.mkdir(parents=True,exist_ok=False);headers=build/'include'
    prepare_headers([ROOT/'reference/duke3d-reconstructions',
                     ROOT/'reference/duke3d-reconstructions/MACT'],
                    [ROOT/'src/include',ROOT/'src/game/include',ROOT/'src/engine/include'],headers)
    obj=build/'premap.obj'
    compile_source(home,source,obj,OPTIONS,30,include_dirs=[headers])
    if digest(source)!=identity:raise ValueError('source changed during compilation')
    module=Module.parse(obj.read_bytes())
    engine_path=ROOT/'evidence/engine-function-matches.json'
    sound_path=ROOT/'evidence/sounds-module.json'
    network_path=ROOT/'evidence/mmulti-module.json'
    fx_path=ROOT/'evidence/fx_man-module.json'
    music_path=ROOT/'evidence/music-module.json'
    gamedef_path=ROOT/'evidence/gamedef-module.json'
    engine=json.loads(engine_path.read_text());sound=json.loads(sound_path.read_text())
    network=json.loads(network_path.read_text())
    fx=json.loads(fx_path.read_text());music=json.loads(music_path.read_text())
    gamedef=json.loads(gamedef_path.read_text())
    for evidence,verification in [(engine,engine['module_verification']),
                                  (sound,sound['verification']),(network,network['verification']),
                                  (fx,fx['verification']),(music,music['verification']),(gamedef,gamedef['verification'])]:
        if evidence.get('target_sha256')!=TARGET_SHA256 or verification.get('verified') is not True:
            raise ValueError('unverified independent anchor report')
    referenced={module.externals[f.target-1] for f in module.fixups if f.target_method==2}
    known={}
    for publics in [external_anchor_bindings(engine['module_verification']),
                    external_anchor_bindings(sound['verification']),external_anchor_bindings(network['verification']),
                    external_anchor_bindings(fx['verification']),external_anchor_bindings(music['verification']),
                    external_anchor_bindings(gamedef['verification']),
                    {name:[1,offset] for name,(offset,_) in FUNCTIONS.items()}]:
        for name,value in publics.items():
            if name not in referenced and name not in FUNCTIONS:continue
            value=tuple(value)
            if name in known and known[name]!=value:
                raise ValueError('conflicting independent binding: '+name)
            known[name]=value
    functions=check_intervals(module,image,FUNCTIONS,known)
    bindings={n:tuple(v) for row in functions for n,v in row['bindings'].items()}
    initialized=check_initialized_storage(module,image,bindings)
    descriptor=ROOT/'modules/premap.json';spec=json.loads(descriptor.read_text())
    full,full_gate=check_complete(module,image,known,spec)
    segment=check_owned_state(module)
    bss={'verified':True,'initialized_bytes':0,'zero_fill_bytes':5,'verified_fixups':0,
         'source_segments':[segment],'source_symbols':{'_dmval':0,'_wait_abort':4},
         'local_symbols':{'_dmval':full_gate['local_symbols']['_dmval']},
         'publics':{'_wait_abort':full_gate['publics']['_wait_abort']},
         'segments':[s for s in full_gate['segments'] if s['symbol']=='_BSS'],
         'scope':'Whole-module ordinary native inference/verification proves the private scratch and real public abort byte together; no conditional neighbor placement or standalone BSS projection.'}
    unverified_storage=[]
    sector=json.loads((ROOT/'evidence/sector-module.json').read_text())
    if sector['target_sha256']!=TARGET_SHA256 or not sector['verification']['verified']:
        raise ValueError('unverified next-SECTOR CODE boundary')
    sector_code=next(row for row in sector['verification']['segments'] if row['symbol']=='_TEXT')
    code_end=spec['code_offset']+spec['code_bytes'];following=sector_code['target_offset']
    if (sector_code['target_object']!=1 or following-code_end!=2 or
            image.object_bytes(1)[code_end:following]!=bytes(2)):
        raise ValueError('changed independent next-SECTOR boundary or following linker gap')
    return {'kind':'complete PREMAP native contributions with an owned abort byte, not a full executable',
            'target_sha256':TARGET_SHA256,'source':'src/game/premap.c','source_sha256':identity,
            'headers_sha256':{p.name:digest(p) for p in sorted(headers.iterdir())},
            'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe'),'options':OPTIONS,
            'anchor_evidence_sha256':{str(p.relative_to(ROOT)):digest(p) for p in [engine_path,sound_path,network_path,fx_path,music_path,gamedef_path]},
            'descriptor':'modules/premap.json','descriptor_sha256':digest(descriptor),
            'source_reference_evidence':'evidence/premap-source-reference.json',
            'source_reference_sha256':digest(ROOT/'evidence/premap-source-reference.json'),
            'placements':full['placements'],'constraints':full['constraints'],
            'verification':full_gate,'symbol_anchors':spec['symbol_anchors'],
            'anchor_evidence':spec['anchor_evidence'],
            'native_inventory':[{'source_segment':n,'name':seg.name,'class':seg.class_name,
                                 'size':seg.size,'attributes':seg.attributes}
                                for n,seg in enumerate(module.segments,1)],
            'functions':functions,'matched_function_bytes':sum(f['size'] for f in functions),
            'matched_function_fixups':sum(f['comparison']['verified_fixups'] for f in functions),
            'source_code_bytes':module.segments[0].size,
            'initialized_storage':initialized,'matched_initialized_data_bytes':278,
            'leading_code_prefix_verified':True,'initialized_data_verified':True,'bss_verified':True,'bss_storage':bss,
            'matched_bss_bytes':5,
            'unverified_storage':unverified_storage,
            'unverified_code_publics':sorted(n for n,(s,_) in module.publics.items() if s==1 and n not in FUNCTIONS),
            'full_module_gate':full_gate,
            'scope':'All twenty-two complete native public intervals and every CODE/CONST byte and fixup verify together at one CODE placement with common external bindings. The five-byte native BSS segment owns private dmval plus the actual public one-byte wait_abort; active CODE references infer its placement without any neighbor projection or injected placement. No neighbor locals are imported. The following two zero bytes before independent SECTOR are outside the native contribution. Original linker identity, linker alignment reproduction and whole-executable identity remain unverified.',
            'following_alignment_gap':{'target_object':1,'start':code_end,'end':following,
                                       'bytes':2,'all_zero':True,'source_contribution':False},
            'new_complete_contributions':1,'full_executable_rebuilt':False}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    p.add_argument('--build',type=Path,required=True,help='fresh staging directory')
    p.add_argument('--report',type=Path,required=True)
    p.add_argument('--module-report',type=Path,help='also write the complete object contribution report')
    a=p.parse_args();report=probe(a.home.resolve(),a.build.resolve())
    a.report.write_text(json.dumps(report,indent=2)+'\n')
    if a.module_report:
        keys=['target_sha256','source','source_sha256','headers_sha256','compiler_sha256',
              'options','descriptor','descriptor_sha256','source_reference_evidence','source_reference_sha256',
              'anchor_evidence_sha256','placements','constraints','verification','symbol_anchors','anchor_evidence',
              'bss_storage','native_inventory','following_alignment_gap','full_executable_rebuilt']
        contribution={key:report[key] for key in keys}
        contribution['kind']='complete PREMAP native contributions with an owned abort byte, not a full executable'
        a.module_report.write_text(json.dumps(contribution,indent=2)+'\n')
    print(f"PREMAP VERIFIED: {len(report['functions'])} exact intervals, "
          f"{report['matched_function_bytes']} bytes, {report['matched_function_fixups']} fixups; "
          '278 initialized string bytes and 5 directly inferred owned BSS bytes verified; executable unlinked')


if __name__=='__main__':main()
