"""Fresh ordinary-C whole MACT utilities proof; never reads SDK objects for output."""
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
from tools.infer_bindings import infer_bindings
from tools.verify_module import verify_module,external_anchor_bindings
from tools.inventory_watcom_runtime import read_archive,select_member
from tools.preserve import TARGET_SHA256

SPEC_SHA256='c015af00e98341a826d35c5a04b5e06ece4ea5de7a7cf3bc7a3ab33f0cdb4dd1'
OPTIONS=['/omaxnet','/zp4','/5r']
COMPILER_SHA256='a4f4da1b8b2cd4e38b2b041975fc6b1d131255ae5eb575828b02f927fbf9bf65'


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load_spec():
    path=ROOT/'modules/mact_util.json'
    if digest(path)!=SPEC_SHA256: raise ValueError('changed measured utility descriptor')
    return json.loads(path.read_text())


def geometry(module):
    return {'publics':{n:list(v) for n,v in module.publics.items()},
            'local_publics':sorted(module.local_publics),'externals':module.externals,
            'local_externals':sorted(module.local_externals),
            'code_data_ranges':[list(v) for v in module.code_data_ranges],
            'segments':[{'name':s.name,'class':s.class_name,'size':s.size,
                         'attributes':s.attributes} for s in module.segments]}


def check_module(module,image,*,known=None,placements=None):
    spec=load_spec()
    if geometry(module)!=spec['geometry'] or len(module.fixups)!=61:
        raise ValueError('changed native utility geometry or scope')
    anchors={k:tuple(v) for k,v in spec['symbol_anchors'].items()}
    for name,value in (known or {}).items():
        if name in anchors and anchors[name]!=tuple(value):
            raise ValueError('conflicting independent anchor')
        anchors[name]=tuple(value)
    bound=infer_bindings(module,image,1,555328,known_symbols=anchors)
    expected={int(k):tuple(v) for k,v in spec['placements'].items()}
    if bound['placements']!=expected: raise ValueError('changed native utility placement')
    proof=verify_module(module,image,placements or bound['placements'],bound['symbols'])
    if any(proof[k]!=v for k,v in spec['expected'].items()):
        raise ValueError('incomplete utility proof')
    return bound,proof


def independent_anchors(image,lineage):
    """Revalidate three separate whole stock CRT modules, reference-only."""
    anchor=lineage['independent_anchors'];path=ROOT/anchor['evidence']
    if digest(path)!=anchor['sha256']: raise ValueError('changed CRT anchor evidence')
    records=json.loads(path.read_text())['components'];proofs={};symbols={}
    for name in anchor['members']:
        row=next(c for c in records if c['name']==name)
        raw=(ROOT/row['library']).read_bytes();archive=read_archive(raw)
        member=select_member(raw,archive,row)
        m=Module.parse(raw[member['offset']:member['end']])
        p=verify_module(m,image,row['placements'],row['verification']['publics'])
        proofs[name]={'library':row['library'],'library_sha256':archive['sha256'],
                      'member_sha256':member['sha256'],'verification':p}
        for n,v in external_anchor_bindings(p).items():
            if n in symbols and symbols[n]!=v: raise ValueError('conflicting CRT anchors')
            symbols[n]=v
    for peer in lineage['verified_peer_anchors']:
        peer_path=ROOT/peer['path']
        if digest(peer_path)!=peer['sha256']: raise ValueError('changed accepted peer anchors')
        proof=json.loads(peer_path.read_text())[peer['field']]
        for n,v in external_anchor_bindings(proof).items():
            if n not in anchor['symbols']: continue
            v=tuple(v)
            if n in symbols and symbols[n]!=v: raise ValueError('conflicting peer anchor')
            symbols[n]=v
    for n,v in anchor['symbols'].items():
        if symbols.get(n)!=tuple(v): raise ValueError('independent CRT anchor mismatch')
    return proofs


def probe(home,build):
    spec=load_spec();lineage_path=ROOT/spec['source_reference_evidence']
    lineage_hash=digest(lineage_path)
    lineage=json.loads(lineage_path.read_text());source=ROOT/spec['source']
    source_hash=digest(source);compiler=home/compiler_bin(home)/'wcc386.exe'
    if source_hash!=lineage['source']['sha256']: raise ValueError('utility source lineage mismatch')
    if digest(compiler)!=COMPILER_SHA256: raise ValueError('wrong native compiler')
    binary=ROOT/'reference/DUKE3D.EXE'
    if binary.stat().st_size!=1179131 or digest(binary)!=TARGET_SHA256:
        raise ValueError('wrong target identity')
    image=LEImage.parse(binary.read_bytes());anchors=independent_anchors(image,lineage)
    headers={p.name:digest(p) for p in (home/'H').iterdir() if p.is_file()}
    build.mkdir(parents=True,exist_ok=True);obj=build/'mact_util.obj'
    compile_source(home,source,obj,OPTIONS)
    if '0 warnings, 0 errors' not in obj.with_suffix('.log').read_text():
        raise ValueError('native compilation has diagnostics')
    if (digest(lineage_path)!=lineage_hash or digest(source)!=source_hash or digest(compiler)!=COMPILER_SHA256 or
            headers!={p.name:digest(p) for p in (home/'H').iterdir() if p.is_file()}):
        raise ValueError('utility input changed during compilation')
    module=Module.parse(obj.read_bytes());bound,proof=check_module(module,image)
    return {'kind':'complete source-built MACT utilities contribution; no full executable identity claim',
            'target_sha256':TARGET_SHA256,'source':spec['source'],'source_sha256':source_hash,
            'source_reference_sha256':lineage_hash,'descriptor_sha256':digest(ROOT/'modules/mact_util.json'),
            'source_producer_sha256':digest(Path(__file__)),'compiler_sha256':COMPILER_SHA256,
            'compiler_headers_sha256':headers,'options':OPTIONS,
            'proof_tools_sha256':{n:digest(ROOT/n) for n in [
                'profiles/watcom/tools/omf32.py','profiles/watcom/tools/le.py',
                'profiles/watcom/tools/runner.py','tools/infer_bindings.py',
                'tools/verify_module.py','tools/match_function.py','tools/inventory_watcom_runtime.py']},
            'native_object_sha256':digest(obj),'native_log_sha256':digest(obj.with_suffix('.log')),
            'independent_anchor_verifications':anchors,
            'independently_anchored_imports':lineage['independent_anchors']['symbols'],
            'selected_member_call_nominations':lineage['selected_member_call_nominations'],
            'callee_identity_limit':lineage['anchor_limit'],'source_geometry':geometry(module),
            'placements':bound['placements'],'constraints':bound['constraints'],'verification':proof,
            'original_member_used_by_producer':False,'source_instruction_payload':False,
            'full_executable_rebuilt':False}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    parser.add_argument('--build',type=Path,default=ROOT/'build/mact-util-proof')
    parser.add_argument('--report',type=Path,default=ROOT/'evidence/mact_util-module.json')
    args=parser.parse_args();report=probe(args.home,args.build)
    args.report.write_text(json.dumps(report,indent=2)+'\n')
    print('MACT utilities VERIFIED: 1107 initialized + 28 BSS bytes; 61 fixups')


if __name__=='__main__':main()
