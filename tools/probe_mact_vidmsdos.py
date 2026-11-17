"""Complete authored VID C with three disclosed symbolic arithmetic/I/O primitives.

Compilation is source-only. The original SDK member and ignored research paths
are never production inputs. Logical DATA coordinates require the existing
closed, freshly replayed target-specific context; no origin override exists.
"""
from dataclasses import asdict
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from runner import compile_source,compiler_bin
from omf32 import Module
from le import LEImage
from tools.infer_bindings import infer_bindings
from tools.verify_module import verify_module
from tools.preserve import TARGET_SHA256
SOURCE='src/mact/vidmsdos.c'
COUNTERPART='src/mact/lineage/vidmsdos-c-only.c.txt'
HEADERS='src/mact/vidmsdos'
DESCRIPTOR='modules/mact_vidmsdos.json'
PROVENANCE='evidence/mact-vidmsdos-source-reference.json'
LINEAGE='src/mact/lineage/vidmsdos.md'
DESCRIPTOR_SHA256='4fd79f946a5ee58c726193e5d71279ab0e2a06837f06198372e238036f42f6bf'
SOURCE_SHA256='f4a1eec6b5a3cf1295bbc1a7536618312ef4be4d1a4ab3cd5eae65e406b8613e'
COUNTERPART_SHA256='98416c5940ce0595c990f55cf42a65fe182d94a0ac82191688376a81d6add7da'
HEADERS_SHA256={'src/mact/vidmsdos/DEVELOP.H': 'c862210f83facbfa543563d746fa561d9f8d94a251e98a4a470c6bd11e17f861', 'src/mact/vidmsdos/KEYBOARD.H': 'ff41010dca80c96429847b6da8dad5f120d9e9ed69bc0b889c6dd791c61a790c', 'src/mact/vidmsdos/MOUSE.H': '71c3d9f3a5a3ec571b65db921621e77eaf1f5a656a7d17e351e2eceeb30b2aaf', 'src/mact/vidmsdos/TYPES.H': 'd00c4f7e2968f4315613558e1fb3a1b86f19a50cfd02b42a028cde436e298cf1', 'src/mact/vidmsdos/VID.H': 'bfbf270ce558882182cb03b0db7094b71568aec1dc65fe5f16b118babc29a4db'}
OPTIONS=['/omaxnet','/zp4','/5r']
TOOLCHAIN={'BINB/wcc386.exe':'a4f4da1b8b2cd4e38b2b041975fc6b1d131255ae5eb575828b02f927fbf9bf65',
 'BIN/w32run.exe':'d9028582ce7d2d7b0990d677e1947c10e0b0deaefb32d78319fbd2cea603cfcf'}
TOOLS=['tools/probe_mact_vidmsdos.py','tools/prove_module.py','tools/verify_module.py',
 'tools/infer_bindings.py','tools/match_function.py','tools/preserve.py',
 'tools/logical_segment_origins.py','tools/prove_logical_data_origin.py',
 'tools/logical_data_origin_inputs.json','profiles/watcom/tools/omf32.py',
 'profiles/watcom/tools/le.py','profiles/watcom/tools/runner.py']


def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def encoded(value):
    if isinstance(value,bytes):return {'hex':value.hex()}
    if isinstance(value,(list,tuple,set)):
        return [encoded(x) for x in (sorted(value) if isinstance(value,set) else value)]
    if isinstance(value,dict):return {k:encoded(v) for k,v in value.items()}
    return value


def inventory(module):
    """Close every Module field, retaining timestamp-bearing dependencies separately."""
    if set(vars(module))!=set(vars(Module())):
        raise ValueError('unexpected VID parser metadata field')
    out={k:encoded(v) for k,v in vars(module).items() if k not in {'segments','comments','fixups'}}
    out['segments']=[{'name':s.name,'class':s.class_name,'size':s.size,
                     'attributes':s.attributes,'access':s.access} for s in module.segments]
    out['fixups']=[asdict(f) for f in module.fixups]
    out['fixed_comments']=encoded([c for c in module.comments if c[0]!=233])
    dependencies=[]
    for cls,payload in module.comments:
        if cls==233 and payload:
            if len(payload)<5 or payload[4]!=len(payload)-5:
                raise ValueError('malformed VID dependency receipt')
            dependencies.append(payload[5:].decode('ascii'))
    if [p for c,p in module.comments if c==233].count(b'')!=1:
        raise ValueError('missing VID dependency terminator')
    out['dependency_paths']=dependencies
    return out


def validate_spec(spec):
    if hashlib.sha256((json.dumps(spec,indent=2)+'\n').encode()).hexdigest()!=DESCRIPTOR_SHA256:
        raise ValueError('changed fixed VID descriptor/recipe')


def verify_native(module,image,spec,context):
    validate_spec(spec)
    if inventory(module)!=spec['native_inventory']:
        raise ValueError('changed complete VID native inventory/scope/fixup contract')
    if any(len(s.data)!=s.size for s in module.segments):
        raise ValueError('changed VID storage extent')
    inferred=infer_bindings(module,image,1,553424,known_symbols=spec['symbol_anchors'])
    expected_places={int(k):tuple(v) for k,v in spec['placements'].items()}
    expected_symbols={n:tuple(v) for n,v in spec['expected_symbols'].items()}
    if (inferred['placements']!=expected_places or inferred['symbols']!=expected_symbols or
            inferred['unplaced_segments']):
        raise ValueError('changed VID complete binding/caller contract')
    proof=verify_module(module,image,inferred['placements'],inferred['symbols'],
                        logical_origins=(context,))
    if any(proof[k]!=v for k,v in spec['expected'].items()):
        raise ValueError('incomplete VID whole-module proof')
    return {'placements':inferred['placements'],'symbol_anchors':inferred['symbols'],
            'constraints':inferred['constraints'],'verification':proof}


def compile_only(home,source,headers,build):
    """Genuine standalone producer; no target, library, descriptor or context reads."""
    build=Path(build);build.mkdir(parents=True,exist_ok=True)
    work=Path(tempfile.mkdtemp(prefix='vid-',dir=build))
    shutil.copyfile(source,work/'VIDMSDOS.C')
    shutil.copytree(headers,work/'include')
    compile_source(Path(home),work/'VIDMSDOS.C',work/'VIDMSDOS.OBJ',OPTIONS,45,
                   include_dirs=[work/'include'],module_name='VIDMSDOS')
    log=(work/'VIDMSDOS.log').read_text(errors='replace')
    if 'Warning!' in log or 'Error!' in log or '0 warnings, 0 errors' not in log:
        raise ValueError('VID compiler emitted diagnostics')
    return work


def _replay_origin(home,build):
    from tools.prove_logical_data_origin import replay_target_data_origin
    return replay_target_data_origin(home=home,build=build)


def validate_inputs(home):
    spec=json.loads((ROOT/DESCRIPTOR).read_text());validate_spec(spec)
    evidence=json.loads((ROOT/PROVENANCE).read_text())
    if (evidence['source_files_sha256']!={SOURCE:SOURCE_SHA256,COUNTERPART:COUNTERPART_SHA256} or
            set(evidence['proof_tools_sha256'])!=set(TOOLS) or
            evidence['toolchain_sha256']!=TOOLCHAIN or evidence['options']!=OPTIONS or
            evidence['descriptor_sha256']!=DESCRIPTOR_SHA256):
        raise ValueError('changed VID provenance/producer contract')
    headers={str(p.relative_to(ROOT)):digest(p) for p in sorted((ROOT/HEADERS).iterdir()) if p.is_file()}
    if headers!=HEADERS_SHA256 or evidence['headers_sha256']!=HEADERS_SHA256:
        raise ValueError('changed released VID header graph')
    home_headers={p.relative_to(home).as_posix():digest(p) for p in sorted((home/'H').rglob('*')) if p.is_file()}
    if compiler_bin(home)!='BINB' or home_headers!=evidence['compiler_headers_sha256']:
        raise ValueError('changed VID compiler/header identity')
    expected={ROOT/p:v for p,v in {**evidence['source_files_sha256'],**evidence['proof_tools_sha256'],
                  **evidence['headers_sha256'],LINEAGE:evidence['lineage_sha256'],
                  DESCRIPTOR:DESCRIPTOR_SHA256,'reference/DUKE3D.EXE':TARGET_SHA256}.items()}
    expected.update({home/p:v for p,v in {**TOOLCHAIN,**home_headers}.items()})
    for path,value in expected.items():
        if digest(path)!=value:raise ValueError('changed VID source/tool/input: '+str(path))
    emulator=os.environ.get('EXHUME_DOSBOX_X') or shutil.which('dosbox-x')
    if not emulator:raise ValueError('missing DOSBox-X')
    paths=[*expected,ROOT/PROVENANCE,Path(emulator).resolve(),Path(sys.executable).resolve()]
    return spec,{str(p):digest(p) for p in paths}


def probe(home,build):
    home,build=Path(home).resolve(),Path(build).resolve()
    spec,before=validate_inputs(home)
    native=compile_only(home,ROOT/SOURCE,ROOT/HEADERS,build)
    obj=native/'VIDMSDOS.OBJ';module=Module.parse(obj.read_bytes())
    # Closed witness replay issues a real in-process capability, never a serialized origin.
    context=_replay_origin(home,native/'logical-origin-replay')
    result=verify_native(module,LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes()),spec,context)
    if any(digest(p)!=v for p,v in before.items()):
        raise ValueError('VID inputs changed during production')
    return {'kind':'complete authored VID source contributions; not whole executable',
       'target_sha256':TARGET_SHA256,'source':SOURCE,'source_sha256':SOURCE_SHA256,
       'source_reference_evidence':PROVENANCE,'descriptor':DESCRIPTOR,
       'descriptor_sha256':DESCRIPTOR_SHA256,'options':OPTIONS,'module_name':'VIDMSDOS',
       'compiler_sha256':TOOLCHAIN['BINB/wcc386.exe'],'native_build_directory':str(native),
       'object_sha256':digest(obj),'headers_sha256':{p.name:digest(p) for p in sorted((ROOT/HEADERS).iterdir())},
       'inputs_sha256':before,'native_comments':encoded(module.comments),
       'dependency_receipt_policy':'raw per-run timestamps retained; exact ordered paths and fixed comments checked',
       'humanization_backlog':spec['humanization_backlog'],'full_executable_rebuilt':False,**result}
