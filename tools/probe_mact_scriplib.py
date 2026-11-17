"""Rebuild complete readable SCRIPLIB C, checking every byte and native role.

Only tracked source/headers, unmodified GA tools and the target EXE are inputs.
The original SDK member and private research artifacts are not producer inputs.
This proves a module contribution, not original source identity or final linking.
"""
import argparse
from dataclasses import asdict
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from le import LEImage
from runner import compile_source,compiler_bin
from tools.infer_bindings import infer_bindings
from tools.verify_module import verify_module
from tools.preserve import TARGET_SHA256

OPTIONS=['/omaxnet','/zp4','/5r']
COMPILER_SHA256='a4f4da1b8b2cd4e38b2b041975fc6b1d131255ae5eb575828b02f927fbf9bf65'
SPEC_SHA256='831c3a73a6bc8e0412c7e18d5b0729baf57f3430aee45deaeb24d32a5325ee56'
LINEAGE_SHA256='652962dc93f7d81bd3614e65bba05aa3709b7ca4fbb84ffa4222a3861fabe913'
PROOF_TOOLS=['profiles/watcom/tools/runner.py','profiles/watcom/tools/omf32.py',
             'profiles/watcom/tools/le.py','tools/infer_bindings.py',
             'tools/verify_module.py','tools/match_function.py','tools/preserve.py']

def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def load_spec():
    path=ROOT/'modules/mact_scriplib.json'
    if digest(path)!=SPEC_SHA256:raise ValueError('changed complete SCRIPLIB descriptor')
    return json.loads(path.read_text())

def inventory(m):
    """Native runtime metadata, retaining unused imports and private scopes."""
    return json.loads(json.dumps({
        'segments':[{'name':s.name,'class':s.class_name,'size':s.size,
                     'attributes':s.attributes,'access':s.access} for s in m.segments],
        'publics':m.publics,'local_publics':sorted(m.local_publics),
        'externals':m.externals,'local_externals':sorted(m.local_externals),
        'groups':m.groups,'fixups':[asdict(f) for f in m.fixups],
        'code_data_ranges':m.code_data_ranges,'default_libraries':m.default_libraries,
        'far_call_optimization_segments':m.far_call_optimization_segments,
        'dosseg_directives':m.dosseg_directives}))

def code_anchor(image,lineage):
    """Replay accepted CONFIG's real relative call, independent of this module."""
    row=lineage['code_anchor'];pos=row['native_relative_field']
    raw=image.object_bytes(row['native_object'])
    target=pos+4+int.from_bytes(raw[pos:pos+4],'little',signed=True)
    if (raw[pos-1]!=0xe8 or row['caller_native_code_base']+row['caller_relative_field_offset']!=pos
            or [row['native_object'],target]!=row['location']):
        raise ValueError('changed independent CONFIG SCRIPT_Load call anchor')
    return {**row,'verified':True}

def check_module(module,image):
    """Require exact full geometry, roles, scopes and all initialized/BSS bytes."""
    spec=load_spec()
    if inventory(module)!=spec['inventory']:
        raise ValueError('changed SCRIPLIB native geometry, scope, import or typed fixup')
    if any(len(s.data)!=s.size for s in module.segments):
        raise ValueError('incomplete SCRIPLIB segment storage')
    anchors={n:tuple(v) for n,v in {**spec['symbol_anchors'],**spec['import_roles']}.items()}
    bound=infer_bindings(module,image,spec['code_object'],spec['code_offset'],known_symbols=anchors)
    expected={int(n):tuple(v) for n,v in spec['placements'].items()}
    if bound['placements']!=expected or bound['unplaced_segments']:
        raise ValueError('changed complete SCRIPLIB placements')
    proof=verify_module(module,image,bound['placements'],bound['symbols'])
    if any(proof[k]!=v for k,v in spec['expected'].items()):
        raise ValueError('incomplete SCRIPLIB native proof')
    # Proof.publics includes imported anchors and private definitions. Ownership
    # comes from actual PUBDEF/local records, never the combined binding dict.
    exports={n:proof['publics'][n] for n in module.publics if n not in module.local_publics}
    private={n:proof['publics'][n] for n in sorted(module.local_publics)}
    pairs=spec['compiler_folded_export_pairs']
    if len(exports)!=36 or len(private)!=2 or any(exports[a]!=exports[b] for a,b in pairs):
        raise ValueError('changed actual SCRIPLIB export/private/folded-pair ownership')
    return {'verification':proof,'placements':bound['placements'],'constraints':bound['constraints'],
            'global_exports':exports,'private_definitions':private,
            'compiler_folded_export_pairs':pairs,'unique_CODE_intervals':34,
            'source_geometry':inventory(module)}

def snapshot(paths):
    return {Path(p):digest(p) for p in paths}

def check_snapshot(before):
    if any(not p.is_file() or digest(p)!=sha for p,sha in before.items()):
        raise ValueError('SCRIPLIB source/header/descriptor/provenance/helper/tool/target changed during production')

def probe(home,build):
    home=Path(home).resolve();build=Path(build).resolve();spec=load_spec()
    descriptor=ROOT/'modules/mact_scriplib.json';lineage_path=ROOT/spec['source_reference_evidence']
    if digest(lineage_path)!=LINEAGE_SHA256:raise ValueError('changed SCRIPLIB lineage')
    lineage=json.loads(lineage_path.read_text());source=ROOT/spec['source']
    include=ROOT/spec['include_directory'];headers={p.name:p for p in include.iterdir() if p.is_file() and p.suffix.lower()=='.h'}
    if {str(p.relative_to(ROOT)):digest(p) for p in headers.values()}!=lineage['tracked_headers_sha256']:
        raise ValueError('changed released SCRIPLIB header identity')
    if digest(source)!=lineage['source']['sha256']:raise ValueError('changed SCRIPLIB source lineage')
    compiler=home/compiler_bin(home)/'wcc386.exe'
    emulator=Path(os.environ.get('EXHUME_DOSBOX_X') or shutil.which('dosbox-x') or 'missing-dosbox-x').resolve()
    compiler_headers={str(p.relative_to(home)):p for p in (home/'H').rglob('*') if p.is_file()}
    # Hash every staged compiler/project header and real tool/implementation
    # input before and after native compilation. Preserve the full log/object.
    paths={source,descriptor,lineage_path,ROOT/'reference/DUKE3D.EXE',compiler,
           home/'BIN/w32run.exe',emulator,Path(sys.executable).resolve(),Path(__file__).resolve(),
           *headers.values(),*compiler_headers.values(),*(ROOT/p for p in PROOF_TOOLS)}
    before=snapshot(paths)
    if before[compiler]!=COMPILER_SHA256 or before[ROOT/'reference/DUKE3D.EXE']!=TARGET_SHA256:
        raise ValueError('wrong original GA compiler or target EXE')
    # Close the validation-to-snapshot window as well as the compilation window.
    if (before[descriptor]!=SPEC_SHA256 or before[lineage_path]!=LINEAGE_SHA256
            or before[source]!=lineage['source']['sha256']
            or any(before[ROOT/p]!=sha for p,sha in lineage['tracked_headers_sha256'].items())):
        raise ValueError('SCRIPLIB validated input changed before compilation')
    image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());anchor=code_anchor(image,lineage)
    build.mkdir(parents=True,exist_ok=True);actual=Path(tempfile.mkdtemp(prefix='scriplib-',dir=build))
    obj=actual/'scriplib.obj'
    compile_source(home,source,obj,OPTIONS,30,include_dirs=[include])
    log=obj.with_suffix('.log').read_text(errors='replace')
    if re.search(r'Warning!|Error!',log) or '0 warnings, 0 errors' not in log:
        raise ValueError('unexpected SCRIPLIB compiler diagnostics')
    module=Module.parse(obj.read_bytes());proof=check_module(module,image)
    check_snapshot(before)
    if {p.name for p in include.iterdir() if p.is_file() and p.suffix.lower()=='.h'}!=set(headers):
        raise ValueError('SCRIPLIB header set changed during production')
    if {str(p.relative_to(home)) for p in (home/'H').rglob('*') if p.is_file()}!=set(compiler_headers):
        raise ValueError('SCRIPLIB compiler header set changed during production')
    return {'kind':'complete source-built MACT SCRIPLIB candidate; not complete executable',
            'source':spec['source'],'source_sha256':before[source],
            'descriptor_sha256':before[descriptor],'source_reference_sha256':before[lineage_path],
            'source_producer_sha256':before[Path(__file__).resolve()],
            'target_sha256':TARGET_SHA256,'compiler_sha256':before[compiler],'options':OPTIONS,
            'actual_build_directory':str(actual),'native_object_sha256':digest(obj),
            'native_log_sha256':digest(obj.with_suffix('.log')),
            'compiler_headers_sha256':{n:before[p] for n,p in sorted(compiler_headers.items())},
            'inputs_sha256':{str(p):sha for p,sha in sorted(before.items())},
            'independent_CODE_anchor':anchor,'import_roles':spec['import_roles'],
            'callee_identity_limit':lineage['import_role_limit'],**proof,
            'original_member_used_by_producer':False,'source_instruction_payload':False,
            'historical_source_identity':False,'source_credit':0,'full_executable_rebuilt':False,
            'remaining_obligations':lineage['remaining_obligations']}

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    p.add_argument('--build',type=Path,default=ROOT/'build/mact-scriplib-proof')
    p.add_argument('--report',type=Path,default=ROOT/'evidence/mact_scriplib-module.json')
    a=p.parse_args();report=probe(a.home,a.build)
    a.report.parent.mkdir(parents=True,exist_ok=True);a.report.write_text(json.dumps(report,indent=2)+'\n')
    print('SCRIPLIB VERIFIED: 5616 initialized,80 BSS,225 typed fixups; final EXE unfinished')

if __name__=='__main__':main()
