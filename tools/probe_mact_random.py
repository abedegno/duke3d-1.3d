"""Compile the complete ordinary-C MACT RNG contribution, without linking."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import compile_source, compiler_bin
from tools.infer_bindings import infer_bindings
from tools.verify_module import verify_module
from tools.preserve import TARGET_SHA256


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def geometry(module):
    return {'publics':module.publics,'local_publics':sorted(module.local_publics),
            'externals':module.externals,'local_externals':sorted(module.local_externals),
            'segments':[{'name':s.name,'class':s.class_name,'size':s.size,
                         'attributes':s.attributes} for s in module.segments]}


def check_module(module,spec):
    """Require complete native definitions and actual local linker scopes."""
    publics=spec.get('expected_publics')
    if (not isinstance(publics,dict) or not publics or any(
        not isinstance(name,str) or not isinstance(value,list) or len(value)!=2
        or any(type(n) is not int for n in value) for name,value in publics.items())):
        raise ValueError('incomplete native public contract')
    for key in ('expected_local_publics','expected_externals','expected_local_externals'):
        value=spec.get(key)
        if (not isinstance(value,list) or any(not isinstance(n,str) for n in value)
                or len(value)!=len(set(value))):
            raise ValueError('incomplete native scope/external contract')
    segments=spec.get('expected_segments')
    if (not isinstance(segments,list) or not segments or any(
        not isinstance(s,dict) or set(s)!={'name','class','size','attributes'}
        or not isinstance(s['name'],str) or not isinstance(s['class'],str)
        or type(s['size']) is not int or type(s['attributes']) is not int for s in segments)):
        raise ValueError('incomplete native segment contract')
    actual=geometry(module)
    if module.publics!={name:tuple(value) for name,value in publics.items()}:
        raise ValueError('native public definitions differ from contract')
    if (module.local_publics!=set(spec['expected_local_publics'])
        or module.externals!=spec['expected_externals']
        or {module.externals[n-1] for n in module.local_externals}
           !=set(spec['expected_local_externals'])):
        raise ValueError('native local/public external scopes differ from contract')
    if actual['segments']!=segments:
        raise ValueError('native segment geometry differs from contract')
    if len(module.fixups)!=spec['expected']['verified_fixups']:
        raise ValueError('native fixup extent differs from contract')


def probe(home:Path,build:Path)->dict:
    descriptor=ROOT/'modules/mact_random.json'
    spec=json.loads(descriptor.read_text())
    integers={'code_bytes':227,'code_publics':6,'code_object':1,'code_offset':564800}
    expected={'initialized_bytes':2279,'zero_fill_bytes':4,'verified_fixups':13}
    if (any(type(spec.get(key)) is not int or spec[key]!=value
            for key,value in integers.items())
        or not isinstance(spec.get('expected'),dict) or set(spec['expected'])!=set(expected)
        or any(type(spec['expected'][key]) is not int or spec['expected'][key]!=value
               for key,value in expected.items())
        or spec['source']!='src/mact/random.c'
        or spec['source_reference_evidence']!='evidence/mact-random-source-reference.json'
        or spec['options']!=['/omaxnet','/zp4','/5r']
        or spec['reference_headers']!=[]
        or spec['overlay_headers']!='src/mact/random/include'):
        raise ValueError('invalid fixed MACT RNG producer contract')
    lineage_path=ROOT/spec['source_reference_evidence']
    lineage=json.loads(lineage_path.read_text())
    anchor=lineage['independent_anchor']
    anchors=spec['symbol_anchors']
    if (not isinstance(anchors,dict) or set(anchors)!={'_dos_gettime_'}
        or not isinstance(anchors['_dos_gettime_'],list)
        or len(anchors['_dos_gettime_'])!=2
        or any(type(value) is not int for value in anchors['_dos_gettime_'])
        or anchor['symbol']!='_dos_gettime_' or anchor['value']!=[1,591195]
        or anchor['verification'].get('verified') is not True
        or anchor['verification']['publics'].get('_dos_gettime_')!=anchor['value']
        or spec['symbol_anchors']!={'_dos_gettime_':anchor['value']}):
        raise ValueError('invalid independent DOS-time anchor')
    binary=ROOT/'reference/DUKE3D.EXE'
    if digest(binary)!=TARGET_SHA256:raise ValueError('reference identity mismatch')
    image=LEImage.parse(binary.read_bytes())
    source=ROOT/spec['source']; source_hash=digest(source)
    headers=ROOT/spec['overlay_headers']
    hashes={p.name:digest(p) for p in headers.iterdir() if p.is_file()}
    if set(hashes)!={'_rt_rand.h'}:raise ValueError('unexpected RNG header stage')
    build.mkdir(parents=True,exist_ok=True)
    obj=build/'mact_random.obj'
    compile_source(home,source,obj,spec['options'],30,include_dirs=[headers])
    if '0 warnings, 0 errors' not in obj.with_suffix('.log').read_text():
        raise ValueError('RNG compilation contains diagnostics')
    module=Module.parse(obj.read_bytes());check_module(module,spec)
    inferred=infer_bindings(module,image,spec['code_object'],spec['code_offset'],
                            known_symbols=spec['symbol_anchors'])
    verification=verify_module(module,image,inferred['placements'],inferred['symbols'])
    if any(verification.get(key)!=value for key,value in spec['expected'].items()):
        raise ValueError('incomplete whole RNG contribution')
    if (digest(source)!=source_hash or source_hash!=lineage['source']['sha256']
        or any(digest(ROOT/path)!=expected for path,expected in lineage['headers'].items())):
        raise ValueError('source/header lineage identity changed')
    return {'kind':'complete source-built MACT RNG contributions, not original OMF identity or a full executable',
            'target_sha256':TARGET_SHA256,'source':spec['source'],'source_sha256':source_hash,
            'headers_sha256':hashes,'descriptor':str(descriptor.relative_to(ROOT)),
            'descriptor_sha256':digest(descriptor),'source_reference_evidence':spec['source_reference_evidence'],
            'source_reference_sha256':digest(lineage_path),'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe'),
            'source_producer_sha256':digest(Path(__file__)),
            'proof_tools_sha256':{label:digest(Path(sys.modules[name].__file__))
                for label,name in [('profiles/watcom/tools/omf32.py','omf32'),
                    ('profiles/watcom/tools/le.py','le'),('profiles/watcom/tools/runner.py','runner'),
                    ('tools/infer_bindings.py','tools.infer_bindings'),
                    ('tools/verify_module.py','tools.verify_module'),
                    ('tools/match_function.py','tools.match_function')]},
            'compiler_headers_sha256':{name:digest(home/'H'/name) for name in ('dos.h','i86.h')},
            'options':spec['options'],'source_geometry':geometry(module),
            'reference_geometry':lineage['reference_geometry'],
            'symbol_anchors':spec['symbol_anchors'],'anchor_evidence':spec['anchor_evidence'],
            'placements':inferred['placements'],'symbols':inferred['symbols'],
            'constraints':inferred['constraints'],'verification':verification,
            'full_executable_rebuilt':False}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    parser.add_argument('--build',type=Path,default=ROOT/'build/mact-random-proof')
    parser.add_argument('--report',type=Path,default=ROOT/'evidence/mact_random-module.json')
    args=parser.parse_args();report=probe(args.home,args.build)
    args.report.parent.mkdir(parents=True,exist_ok=True)
    args.report.write_text(json.dumps(report,indent=2)+'\n')
    v=report['verification']
    print(f"MACT RNG VERIFIED: {v['initialized_bytes']} initialized bytes, "
          f"{v['zero_fill_bytes']} BSS bytes, {v['verified_fixups']} fixups")


if __name__=='__main__':main()
