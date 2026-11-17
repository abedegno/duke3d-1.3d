"""Compile complete ACTORS from C plus a visible symbolic assembly stand-in.

Every original object segment is verified. Explicit contribution placements do
not establish historical linker order, an original assembler, or executable identity.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import compile_source,compiler_bin
from tools.prove_module import prepare_headers,digest,assert_contributions
from tools.probe_actors import FUNCTIONS,check_code_prefix
from tools.infer_bindings import infer_bindings
from tools.match_function import compare_range
from tools.verify_module import external_anchor_bindings
from tools.verify_composite import verify_composite
from tools.preserve import TARGET_SHA256

OPTIONS=['/4r','/s','/ort','/dAPPVER_EXEDEF=DN3D13G',
         '/dLIBVER_BUILDREV=19960320','/dDUKE13D_EFFECTOR_ASM=1']
COMPILER_SHA256='a4f4da1b8b2cd4e38b2b041975fc6b1d131255ae5eb575828b02f927fbf9bf65'
DEFAULT_NASM_SHA256='c6d2ce2396140d994438a98ef45a8f0e8c9c90b0edb7ad418352bca051e0c295'
NASM_ARCHIVE_SHA256='1412a1c760bbd05db026b6c0d1657affd6631cd0a63cddb6f73cc6d4aa616148'
NASM_SOURCE_URL='https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/nasm-2.16.03.tar.xz'
RANGES=[[1,84160,61674,'initialized'],[3,4280,67,'initialized'],[3,77744,6,'BSS']]
EXPECTED={'initialized_bytes':61741,'zero_fill_bytes':6,'verified_fixups':2812}
ANCHORS=[{'path':'evidence/engine-function-matches.json','proof':'module_verification'},
         {'path':'evidence/gamedef-module.json','proof':'verification'},
         {'path':'evidence/sounds-module.json','proof':'verification'},
         {'path':'evidence/mmulti-module.json','proof':'verification'},
         {'path':'evidence/config-module.json','proof':'verification'},
         {'path':'evidence/player-module.json','proof':'verification'}]
HUMANIZATION='assembly stand-in: recover readable C equivalence for moveeffectors; provisional scratch/CFG labels and historical identifier names remain open'


def validate_spec(spec):
    if (spec.get('name')!='ACTORS' or spec.get('producer')!='actors-composite' or
            spec.get('expected_ranges')!=RANGES or spec.get('expected')!=EXPECTED or
            spec.get('code_bytes')!=61674 or spec.get('code_publics')!=38 or spec.get('function_publics')!=37 or
            spec.get('anchor_evidence')!=ANCHORS or
            set(spec.get('producers',{}))!={'actors_c','actors_asm'} or
            spec.get('reference_headers')!=['reference/duke3d-reconstructions','reference/duke3d-reconstructions/MACT'] or
            spec.get('overlay_headers')!=['src/include','src/game/include','src/engine/include'] or
            spec.get('source_reference_evidence')!='evidence/actors-effector-source.json'):
        raise ValueError('incomplete ACTORS composite descriptor')
    c=spec['producers']['actors_c'];a=spec['producers']['actors_asm']
    if (c['source']!='src/game/actors.c' or c['producer']!='watcom-10.0-ga' or c['options']!=OPTIONS or
            a['source']!='src/game/moveeffectors.asm' or a['producer']!='nasm-2.16.03' or a['options']!=['-f','obj']):
        raise ValueError('changed ACTORS source producer contract')
    functions={**FUNCTIONS,'moveeffectors_':(127056,18778)}
    if spec.get('functions')!={n:{'target_object':1,'target_offset':t,'size':z} for n,(t,z) in functions.items()}:
        raise ValueError('incomplete ACTORS public interval contract')


def checked_nasm(nasm=None):
    default=nasm is None
    binary=(ROOT/'toolchains/support/nasm-2.16.03/nasm' if default else Path(nasm)).resolve()
    identity=digest(binary)
    if default and identity!=DEFAULT_NASM_SHA256:
        raise ValueError('default workspace NASM binary identity mismatch')
    result=subprocess.run([str(binary),'-v'],capture_output=True,text=True,check=True,timeout=10)
    version=result.stdout.strip()
    if result.stderr or not re.fullmatch(r'NASM version 2\.16\.03(?: compiled on .+)?',version):
        raise ValueError('NASM2.16.03 is required')
    return binary,{'version':version,'binary_sha256':identity,'default_workspace_binary':default,
                   'source_url':NASM_SOURCE_URL,'source_archive_sha256':NASM_ARCHIVE_SHA256,
                   'scope':'alternate assembler; not original Watcom toolchain identity'}


def assemble(nasm,source,output):
    text=source.read_text()
    data=[line.strip() for line in text.splitlines()
          if not line.lstrip().startswith(';') and re.search(r'\b(db|dw|dd|dq|dt|incbin|org)\b',line,re.I)]
    if data!=['L1296: db "Could not find any locators for SE# 6 and 14 with a hitag of %ld.",10,0']:
        raise ValueError('instruction payload or unexpected assembly data directive')
    result=subprocess.run([str(nasm),'-f','obj','-o',str(output),str(source)],
                          capture_output=True,text=True,timeout=30)
    output.with_suffix('.log').write_text(result.stdout+result.stderr)
    if result.returncode or result.stderr or not output.is_file():
        raise ValueError('NASM assembly failed: '+result.stderr)


def merge_bindings(known,additional):
    for name,value in additional.items():
        value=tuple(value)
        if name in known and tuple(known[name])!=value:
            raise ValueError('conflicting ACTORS external binding: '+name)
        known[name]=value


def verify_native(modules,image,spec,anchors):
    """Validate complete actual source objects; never strip or merge outputs."""
    validate_spec(spec)
    if set(modules)!={'actors_c','actors_asm'}:
        raise ValueError('wrong ACTORS native producer set')
    places={};shared={n:tuple(v) for n,v in anchors.items()};exports={}
    private=set().union(*(m.local_publics for m in modules.values()))
    if private & shared.keys():raise ValueError('private ACTORS name used as external anchor')
    for name,m in modules.items():
        contract=spec['producers'][name]
        inventory=[{'name':s.name,'class':s.class_name,'attributes':s.attributes,'bytes':s.size} for s in m.segments]
        if (inventory!=contract['segments'] or m.publics!={n:tuple(v) for n,v in contract['publics'].items()} or
                m.local_publics!=set(contract['local_publics']) or m.local_externals!=set(contract['local_externals']) or
                m.code_data_ranges!=[tuple(v) for v in contract['code_data_ranges']] or len(m.fixups)!=contract['fixups']):
            raise ValueError('changed ACTORS native extent/public/scope/segment geometry: '+name)
        places[name]={int(k):tuple(v) for k,v in contract['placements'].items()}
        for symbol,(segment,offset) in m.publics.items():
            if symbol in m.local_publics:continue
            if symbol in exports:raise ValueError('duplicate ACTORS export: '+symbol)
            obj,start=places[name][segment];exports[symbol]=(obj,start+offset)
    if sum(m.segments[s-1].class_name.upper()=='CODE' for m in modules.values()
           for s,_ in m.publics.values())!=spec['code_publics']:
        raise ValueError('changed ACTORS complete CODE public inventory')
    merge_bindings(shared,exports)
    constraints={}
    # Both real producers must agree on every inferred shared external. Five
    # cross-object C calls resolve from actual exports, never saved local names.
    for name,m in modules.items():
        code=next(i for i,s in enumerate(m.segments,1) if s.size and s.class_name.upper()=='CODE')
        obj,base=places[name][code]
        known={n:v for n,v in shared.items() if n not in m.local_publics}
        inferred=infer_bindings(m,image,obj,base,known_symbols=known)
        if inferred['placements']!=places[name] or inferred['unplaced_segments']:
            raise ValueError('inferred ACTORS segment placement conflicts with descriptor: '+name)
        merge_bindings(shared,{n:v for n,v in inferred['symbols'].items() if n not in private})
        constraints[name]=inferred['constraints']
    proof=verify_composite(modules,image,places,shared,RANGES)
    assert_contributions(proof,EXPECTED)
    prefix=check_code_prefix(modules['actors_c'],image)
    functions=[]
    for symbol,contract in sorted(spec['functions'].items(),key=lambda row:row[1]['target_offset']):
        begin=contract['target_offset'];end=begin+contract['size'];pieces=[]
        for name,m in modules.items():
            for number,s in enumerate(m.segments,1):
                if not s.size or s.class_name.upper()!='CODE':continue
                obj,base=places[name][number];left=max(begin,base);right=min(end,base+s.size)
                if left>=right:continue
                private_bindings=dict(shared)
                for local in m.local_publics:
                    segment,offset=m.publics[local];target_obj,target_start=places[name][segment]
                    private_bindings[local]=(target_obj,target_start+offset)
                report=compare_range(m,number,left-base,image,obj,left,right-left,private_bindings,places[name],label=symbol)
                if not report['match']:raise ValueError('ACTORS public interval mismatch: '+symbol)
                pieces.append({'producer':name,'source_segment':number,'source_offset':left-base,'comparison':report})
        if sum(p['comparison']['compared_bytes'] for p in pieces)!=contract['size']:
            raise ValueError('incomplete ACTORS public interval: '+symbol)
        functions.append({'symbol':symbol,**contract,'source_spans':pieces,
                          'comparison':{'match':True,'compared_bytes':contract['size'],
                                        'verified_fixups':sum(p['comparison']['verified_fixups'] for p in pieces),
                                        'differing_offsets':[]}})
    return {'verification':proof,'placements':places,'external_bindings':shared,
            'constraints':constraints,'functions':functions,'leading_code_prefix':prefix,
            'prior36_bytes':sum(f['size'] for f in functions[:-1]),
            'prior36_fixups':sum(f['comparison']['verified_fixups'] for f in functions[:-1])}


def independent_anchors(spec,referenced):
    known={};identities={}
    for row in spec['anchor_evidence']:
        path=ROOT/row['path'];report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256:raise ValueError('anchor target identity mismatch')
        exported=external_anchor_bindings(report[row['proof']])
        merge_bindings(known,{n:v for n,v in exported.items() if n in referenced})
        identities[row['path']]=digest(path)
    return known,identities


def probe(home,build,nasm=None):
    home=Path(home).resolve();build=Path(build).resolve()
    descriptor=ROOT/'modules/actors.json';config_bytes=descriptor.read_bytes()
    spec=json.loads(config_bytes);validate_spec(spec)
    provenance=ROOT/spec['source_reference_evidence'];origin_bytes=provenance.read_bytes()
    origin=json.loads(origin_bytes)
    sources={n:ROOT/c['source'] for n,c in spec['producers'].items()}
    # Snapshot all source/descriptor/header/anchor/tool inputs and recheck after
    # execution. Production has no ignored-object or research-certificate inputs.
    paths={descriptor,provenance,Path(__file__).resolve(),ROOT/'reference/DUKE3D.EXE'}|set(sources.values())
    for directory in spec['reference_headers']+spec['overlay_headers']:
        paths.update(p for p in (ROOT/directory).iterdir() if p.is_file() and p.suffix.lower()=='.h')
    paths.update(ROOT/r['path'] for r in spec['anchor_evidence'])
    compiler=home/compiler_bin(home)/'wcc386.exe';binary,assembler=checked_nasm(nasm);paths.update([compiler,binary])
    before={p:digest(p) for p in paths}
    if before[descriptor]!=hashlib.sha256(config_bytes).hexdigest():
        raise ValueError('ACTORS descriptor input changed during validation')
    if before[provenance]!=hashlib.sha256(origin_bytes).hexdigest() or before[binary]!=assembler['binary_sha256']:
        raise ValueError('ACTORS provenance/tool input changed during validation')
    if before[compiler]!=COMPILER_SHA256 or before[ROOT/'reference/DUKE3D.EXE']!=TARGET_SHA256:
        raise ValueError('original compiler/reference identity mismatch')
    if (origin['tracked_sources_sha256']!={str(p.relative_to(ROOT)):before[p] for p in sources.values()} or
            origin['assembler']['archive_sha256']!=NASM_ARCHIVE_SHA256 or
            origin['assembler']['source_url']!=NASM_SOURCE_URL):
        raise ValueError('ACTORS tracked source/provenance identity mismatch')
    build.mkdir(parents=True,exist_ok=False);headers=build/'include'
    prepare_headers([ROOT/p for p in spec['reference_headers']],
                    [ROOT/p for p in spec['overlay_headers']],headers)
    hashes={p.name:digest(p) for p in sorted(headers.iterdir())}
    if hashes!=origin['canonical_headers_sha256']:raise ValueError('ACTORS canonical header/prototype identity mismatch')
    compile_source(home,sources['actors_c'],build/'actors_c.obj',OPTIONS,60,include_dirs=[headers])
    log=(build/'actors_c.log').read_text(errors='replace')
    if re.search(r'Warning!|Error!',log):raise ValueError('unexpected ACTORS C compiler diagnostics')
    assemble(binary,sources['actors_asm'],build/'actors_asm.obj')
    modules={n:Module.parse((build/(n+'.obj')).read_bytes()) for n in sources}
    referenced={m.externals[f.target-1] for m in modules.values() for f in m.fixups if f.target_method==2}
    known,anchor_hashes=independent_anchors(spec,referenced)
    result=verify_native(modules,LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes()),spec,known)
    if any(digest(p)!=identity for p,identity in before.items()) or hashes!={p.name:digest(p) for p in sorted(headers.iterdir())}:
        raise ValueError('ACTORS source/assembly/header/descriptor/anchor/tool changed during production')
    return {'kind':'complete ACTORS C/ASM object contributions; not a complete executable',
            'target_sha256':TARGET_SHA256,'descriptor':'modules/actors.json','descriptor_sha256':before[descriptor],
            'sources_sha256':{str(p.relative_to(ROOT)):before[p] for p in sources.values()},
            'source_reference_evidence':spec['source_reference_evidence'],'source_reference_sha256':before[provenance],
            'headers_sha256':hashes,'compiler_sha256':before[compiler],'options':OPTIONS,
            'assembler':assembler,'assembler_options':['-f','obj'],'anchor_evidence_sha256':anchor_hashes,
            'producer_sha256':before[Path(__file__).resolve()],**result,
            'code_publics':spec['code_publics'],'function_publics':spec['function_publics'],
            'humanization_backlog':HUMANIZATION,'full_executable_rebuilt':False,
            'unresolved_project_work':['historical linker selection/order','full executable identity',
                                       'remaining modules',HUMANIZATION]}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    parser.add_argument('--build',type=Path,required=True)
    parser.add_argument('--report',type=Path,required=True)
    parser.add_argument('--nasm',type=Path)
    args=parser.parse_args();report=probe(args.home,args.build,args.nasm)
    args.report.parent.mkdir(parents=True,exist_ok=True)
    args.report.write_text(json.dumps(report,indent=2)+'\n')
    print('ACTORS VERIFIED: 61741 initialized bytes, 6 BSS bytes, 2812 fixups; symbolic stand-in backlog remains')


if __name__=='__main__':main()
