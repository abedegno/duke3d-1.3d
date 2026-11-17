"""Fresh complete SECTOR contribution and interval diagnostics; no executable link."""
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
from tools.infer_bindings import infer_bindings
from tools.verify_module import verify_module,ModuleError,external_anchor_bindings
from tools.probe_premap import check_intervals,check_source_interval,OPTIONS
from tools.preserve import TARGET_SHA256

FUNCTIONS={
    'checkcursectnums_':(254688,80),'checkhitceiling_':(268608,720),
    'checkplayerhurt_':(268048,560),'dist_':(254816,48),
    'doanimations_':(255360,704),'findotherplayer_':(255152,208),
    'findplayer_':(254864,288),'getanimationgoal_':(256064,48),
    'isanearoperator_':(254640,48),'operatemasterswitches_':(262112,80),
    'setanimation_':(256112,144),'ldist_':(254768,48),
    'isadoorwall_':(254448,160),'isanunderoperator_':(254608,32),
    'callsound_':(253632,480),'check_activator_motion_':(254112,336),
    'operateforcefields_':(262192,224),
    'animatecamsprite_':(256256,240),'animatewalls_':(256496,544),
    'activatewarpelevators_':(257040,464),'operatesectors_':(257504,3824),
    'operaterespawns_':(261328,144),'operateactivators_':(261472,640),
    'checkhitswitch_':(262416,3440),'activatebysector_':(265856,80),
    'checkhitwall_':(265936,2112),'checkhitsprite_':(269328,5616),
    'allignwarpelevators_':(274944,336),'cheatkeys_':(275280,2720),
    'checksectors_':(278000,3585),
}
OMITTED=[]
EXCLUDED=[]


def independent_anchors(module):
    """Use complete exported/reference bindings, and verified function identities."""
    referenced={module.externals[f.target-1] for f in module.fixups if f.target_method==2}
    known={name:(1,target) for name,(target,_) in FUNCTIONS.items()}
    hashes={}
    def retain(name,value):
        if name not in referenced and name not in FUNCTIONS:return
        value=tuple(value)
        if name in known and known[name]!=value:
            raise ValueError('conflicting independent binding: '+name)
        known[name]=value
    for filename,key in [('engine-function-matches.json','module_verification'),
                         ('gamedef-module.json','verification'),
                         ('sounds-module.json','verification'),
                         ('mmulti-module.json','verification'),
                         ('config-module.json','verification'),
                         ('fx_man-module.json','verification'),
                         ('music-module.json','verification')]:
        path=ROOT/'evidence'/filename
        report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256:
            raise ValueError('anchor reference identity mismatch')
        for name,value in external_anchor_bindings(report[key]).items():retain(name,value)
        hashes[str(path.relative_to(ROOT))]=digest(path)
    for filename in ['actors-progress.json','premap-progress.json']:
        path=ROOT/'evidence'/filename
        report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256:
            raise ValueError('partial anchor reference identity mismatch')
        for function in report['functions']:
            if function['comparison']['match'] is not True:
                raise ValueError('unverified function anchor')
            retain(function['symbol'],(1,function['target_offset']))
        hashes[str(path.relative_to(ROOT))]=digest(path)
    return known,hashes


def check_storage(module,image,bindings):
    """Verify all non-CODE storage using the exact sound-halt reference."""
    storage=copy.deepcopy(module)
    placements={}
    for number,segment in enumerate(storage.segments,1):
        if segment.class_name.upper()=='CODE':
            segment.size=0
            segment.data=bytearray()
        elif segment.size:
            names=[(n,off) for n,(seg,off) in module.publics.items()
                   if seg==number and n in bindings]
            if not names:raise ValueError('unanchored non-CODE storage segment')
            bases={(bindings[n][0],bindings[n][1]-off) for n,off in names}
            if len(bases)!=1:raise ValueError('conflicting storage segment anchors')
            placements[number]=bases.pop()
    storage.fixups=[f for f in storage.fixups
                    if module.segments[f.segment-1].class_name.upper()!='CODE']
    storage.publics={n:(seg,off) for n,(seg,off) in storage.publics.items()
                     if module.segments[seg-1].class_name.upper()!='CODE'}
    owned={n:bindings[n] for n in storage.publics if n in bindings}
    proof=verify_module(storage,image,placements,owned)
    proof['scope']='All native non-CODE storage only; this projection alone does not prove CODE or executable identity.'
    return proof


def probe(home,build):
    binary=(ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(binary).hexdigest()!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    image=LEImage.parse(binary)
    source=ROOT/'src/game/sector.c';identity=digest(source)
    build.mkdir(parents=True,exist_ok=False)
    headers=build/'include'
    prepare_headers([ROOT/'reference/duke3d-reconstructions',
                     ROOT/'reference/duke3d-reconstructions/MACT'],
                    [ROOT/'src/include',ROOT/'src/game/include',ROOT/'src/engine/include'],headers)
    obj=build/'sector.obj'
    compile_source(home,source,obj,OPTIONS,30,include_dirs=[headers])
    if digest(source)!=identity:raise ValueError('source changed during compilation')
    module=Module.parse(obj.read_bytes())
    known,anchors=independent_anchors(module)
    functions=check_intervals(module,image,FUNCTIONS,known)
    bindings={n:tuple(v) for row in functions for n,v in row['bindings'].items()}
    storage_proof=check_storage(module,image,bindings)
    descriptor=ROOT/'modules/sector.json'
    spec=json.loads(descriptor.read_text())
    if (spec['source']!='src/game/sector.c' or spec['options']!=OPTIONS or
            spec['code_object']!=1 or spec['code_offset']!=253632 or
            module.segments[0].size!=spec['code_bytes'] or
            sum(seg==1 for seg,_ in module.publics.values())!=spec['code_publics']):
        raise ValueError('complete descriptor/source geometry mismatch')
    for name,value in spec['symbol_anchors'].items():
        if name in module.publics or name not in known or tuple(value)!=known[name]:
            raise ValueError('descriptor independent anchor mismatch: '+name)
    full=infer_bindings(module,image,spec['code_object'],spec['code_offset'],known_symbols=known)
    full_gate=verify_module(module,image,full['placements'],full['symbols'])
    assert_contributions(full_gate,spec['expected'])
    code_end=spec['code_offset']+spec['code_bytes']
    sound=json.loads((ROOT/'evidence/sounds-module.json').read_text())
    sound_code=next(row for row in sound['verification']['segments'] if row['symbol']=='_TEXT')
    sound_start=sound_code['target_offset']
    if sound_code['target_object']!=1 or sound_start<code_end:
        raise ValueError('following SOUNDS contribution overlaps SECTOR')
    if image.object_bytes(1)[code_end:sound_start]!=bytes(sound_start-code_end):
        raise ValueError('following alignment gap is not zero filled')
    return {
        'kind':'complete SECTOR contributions with public interval diagnostics, not a full executable',
        'target_sha256':TARGET_SHA256,'source':'src/game/sector.c','source_sha256':identity,
        'headers_sha256':{p.name:digest(p) for p in sorted(headers.iterdir())},
        'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe'),'options':OPTIONS,
        'anchor_evidence_sha256':anchors,'functions':functions,
        'descriptor':'modules/sector.json','descriptor_sha256':digest(descriptor),
        'source_reference_evidence':'evidence/sector-source-reference.json',
        'source_reference_sha256':digest(ROOT/'evidence/sector-source-reference.json'),
        'placements':full['placements'],'constraints':full['constraints'],
        'verification':full_gate,'symbol_anchors':spec['symbol_anchors'],
        'anchor_evidence':spec['anchor_evidence'],
        'matched_function_bytes':sum(f['size'] for f in functions),
        'matched_function_fixups':sum(f['comparison']['verified_fixups'] for f in functions),
        'source_code_bytes':sum(s.size for s in module.segments if s.class_name.upper()=='CODE'),
        'omitted_code_publics':OMITTED,'removed_later_code_publics':['breakwall_'],
        'unverified_code_publics':sorted(n for n,(s,_) in module.publics.items()
                                        if s==1 and n not in FUNCTIONS),
        'excluded_location_candidates':EXCLUDED,
        'unverified_storage':[],'noncode_storage':storage_proof,
        'noncode_storage_verified':True,'full_module_gate':full_gate,
        'scope':'All thirty complete public intervals and all native CODE/BSS bytes and fixups verify with one CODE placement and common external bindings. Following-function switch-table prefixes are included. Five-byte BSS includes module-local dmval. The following fifteen zero bytes before independent SOUNDS are outside the native source contribution. Linker alignment reproduction and whole-executable identity remain unverified.',
        'following_alignment_gap':{'target_object':1,'start':code_end,'end':sound_start,
                                   'bytes':sound_start-code_end,'all_zero':True,
                                   'source_contribution':False},
        'leading_code_prefix_verified':True,'initialized_data_verified':True,'bss_verified':True,
        'new_complete_contributions':1,'full_executable_rebuilt':False,
    }


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    parser.add_argument('--build',type=Path,required=True,help='fresh staging directory')
    parser.add_argument('--report',type=Path,required=True)
    parser.add_argument('--module-report',type=Path,help='also write the complete contribution report')
    args=parser.parse_args()
    report=probe(args.home.resolve(),args.build.resolve())
    args.report.write_text(json.dumps(report,indent=2)+'\n')
    if args.module_report:
        keys=['target_sha256','source','source_sha256','headers_sha256','compiler_sha256',
              'options','descriptor','descriptor_sha256','source_reference_evidence',
              'source_reference_sha256','anchor_evidence_sha256','placements','constraints',
              'verification','symbol_anchors','anchor_evidence','following_alignment_gap',
              'full_executable_rebuilt']
        contribution={key:report[key] for key in keys}
        contribution['kind']='complete SECTOR object contributions, not a full executable'
        args.module_report.write_text(json.dumps(contribution,indent=2)+'\n')
    print(f"SECTOR VERIFIED: {len(report['functions'])} exact intervals, "
          f"{report['matched_function_bytes']} bytes, {report['matched_function_fixups']} fixups; "
          'full native module and five BSS bytes verified; executable unlinked')


if __name__=='__main__':main()
