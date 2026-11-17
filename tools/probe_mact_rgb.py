"""Verify complete RGB native C/ASM contributions, without rewriting outputs.

Requires only tracked project inputs, the target EXE, GA compiler/DOSBox-X and
pinned NASM. SDK originals and ignored research files are not runtime inputs.
"""
import argparse
import dataclasses
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from runner import compile_source,compiler_bin
from omf32 import Module
from le import LEImage
from tools.verify_composite import verify_composite
from tools.match_function import compare_range
from tools.probe_actors_composite import checked_nasm,COMPILER_SHA256
from tools.preserve import TARGET_SHA256

OPTIONS=['/omaxnet','/zp4','/5r','/dDUKE13D_RGB_TABLE_ASM=1']
DESCRIPTOR_SHA256='e89ba977616d5369e94191e4f045581fc786a5160e0818cb528b9c597fa03eef'
PLACEMENTS={1:(1,564048),4:(3,68304),5:(3,1864256)}
SYMBOLS={'RGB_FindEGAColors_':(1,564048),'RGB_MakeWeightTable_':(1,564124),
 'RGB_FindBestColor_':(1,564228),'RGB_GetBestColor_':(1,564428),
 'RGB_MakeColorTable_':(1,564468),'_WeightTable':(3,68304),'_egargb':(3,68308),
 '_RGB_Lookup':(3,1864256),'_RGB_EGATable':(3,2126400),
 '_WeightBlue':(3,2126416),'_WeightGreen':(3,2127440),'_WeightRed':(3,2128464),
 'VID_GetPalette_':(1,553740)}
BACKLOG='assembly stand-in: recover C register allocation for final323; inferred names/roles; full executable identity and humanization remain unfinished'

def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def inventory(m):
    return json.loads(json.dumps({'segments':[{'name':s.name,'class':s.class_name,'size':s.size,
            'attributes':s.attributes,'access':s.access} for s in m.segments],
        'publics':m.publics,'local_publics':sorted(m.local_publics),'externals':m.externals,
        'local_externals':sorted(m.local_externals),'groups':m.groups,
        'fixups':[dataclasses.asdict(f) for f in m.fixups],
        'code_data_ranges':m.code_data_ranges,'default_libraries':m.default_libraries,
        'far_call_optimization_segments':m.far_call_optimization_segments,'dosseg_directives':m.dosseg_directives}))

def validate_spec(spec):
    # Compare semantic JSON to the frozen descriptor identity, rejecting edits
    # even when callers bypass probe(). Formatting is intentionally canonical.
    if hashlib.sha256((json.dumps(spec,indent=2)+'\n').encode()).hexdigest()!=DESCRIPTOR_SHA256:
        raise ValueError('changed RGB complete producer contract')

def validate_assembly(text):
    for line in text.splitlines():
        line=line.split(';',1)[0].strip()
        if not line:continue
        if line=='segment _TEXT public align=4 class=CODE use32':continue
        if re.search(r'\b(?:d[bwdqtoyz]|res[bwdqtoyz]|incbin|org|times|align|istruc|struc)\b|%',line,re.I):
            raise ValueError('RGB assembly instruction payload/directive rejected')

def verify_native(modules,image,spec):
    validate_spec(spec)
    if set(modules)!={'rgb_c','rgb_asm'}:raise ValueError('wrong RGB native producer set')
    placements={}
    for name,m in modules.items():
        contract=spec['producers'][name]
        if inventory(m)!=contract['inventory']:
            raise ValueError('changed RGB native graph, typed fixup, extent or scope: '+name)
        if any(len(s.data)!=s.size for s in m.segments):raise ValueError('RGB native storage extent mismatch')
        placements[name]={int(k):tuple(v) for k,v in contract['placements'].items()}
    # The sole outside callee is a measured target-fixup nomination, not an
    # independently rebuilt VID implementation or historical-link claim.
    proof=verify_composite(modules,image,placements,{'VID_GetPalette_':SYMBOLS['VID_GetPalette_']},spec['expected_ranges'])
    if any(proof[k]!=v for k,v in spec['expected'].items()):raise ValueError('RGB contribution totals changed')
    exports={n:v for n,v in proof['publics'].items() if n!='VID_GetPalette_'}
    private=proof['components']['rgb_c']['local_symbols']
    if len(exports)!=6 or len(private)!=6:raise ValueError('RGB export/private inventory mismatch')
    code_publics=sum(m.segments[s-1].class_name=='CODE' for m in modules.values() for s,o in m.publics.values())
    if code_publics!=5:raise ValueError('RGB complete CODE public inventory mismatch')
    return {'verification':proof,'placements':placements,'global_exports':exports,
            'private_c_symbols':private,'codeScopepublics':code_publics,
            'callee_nomination':{'VID_GetPalette_':{'location':SYMBOLS['VID_GetPalette_'],
                'basis':'target typed call fixups; name from original SDK metadata',
                'independent_source_verified':False}}}

def check_snapshot(before):
    if any(digest(p)!=v for p,v in before.items()):
        raise ValueError('RGB source/descriptor/provenance/helper/tool/target changed during production')

def probe(home,build,nasm=None):
    home=Path(home).resolve();build=Path(build).resolve()
    descriptor=ROOT/'modules/mact_rgb.json';raw=descriptor.read_bytes();spec=json.loads(raw);validate_spec(spec)
    provenance=ROOT/spec['source_reference_evidence'];origin_raw=provenance.read_bytes();origin=json.loads(origin_raw)
    sources={n:ROOT/p['source'] for n,p in spec['producers'].items()}
    binary,assembler=checked_nasm(nasm)
    emulator=Path(os.environ.get('EXHUME_DOSBOX_X') or shutil.which('dosbox-x') or 'missing-dosbox-x').resolve()
    compiler=home/compiler_bin(home)/'wcc386.exe'
    paths={descriptor,provenance,ROOT/'reference/DUKE3D.EXE',Path(__file__).resolve(),compiler,
           home/'BIN/w32run.exe',binary,emulator,Path(sys.executable).resolve(),*sources.values()}
    # Hash actual implementation inputs as well as source/tool executables.
    paths.update(ROOT/p for p in ['profiles/watcom/tools/runner.py','profiles/watcom/tools/omf32.py',
        'profiles/watcom/tools/le.py','tools/verify_composite.py','tools/verify_module.py',
        'tools/match_function.py','tools/probe_actors_composite.py','tools/prove_module.py',
        'tools/infer_bindings.py','tools/probe_actors.py','tools/preserve.py',
        'tools/object_contributions.py','tools/probe_bss_order.py','tools/probe_premap.py'])
    before={p:digest(p) for p in paths}
    if (before[descriptor]!=hashlib.sha256(raw).hexdigest() or before[provenance]!=hashlib.sha256(origin_raw).hexdigest()
            or before[binary]!=assembler['binary_sha256']):raise ValueError('RGB input changed during validation')
    if before[compiler]!=COMPILER_SHA256 or before[ROOT/'reference/DUKE3D.EXE']!=TARGET_SHA256:
        raise ValueError('RGB original compiler/target identity mismatch')
    if origin['tracked_sources_sha256']!={str(p.relative_to(ROOT)):before[p] for p in sources.values()}:
        raise ValueError('RGB source lineage identity mismatch')
    validate_assembly(sources['rgb_asm'].read_text())
    # Reusable build parent; retain each new invocation separately, never read
    # stale output as input. Callers receive the actual output directory.
    build.mkdir(parents=True,exist_ok=True)
    import tempfile
    actual=Path(tempfile.mkdtemp(prefix='rgb-',dir=build))
    compile_source(home,sources['rgb_c'],actual/'rgb_c.obj',OPTIONS,30)
    if re.search('Warning!|Error!',(actual/'rgb_c.log').read_text(errors='replace')):
        raise ValueError('unexpected RGB C compiler diagnostics')
    result=subprocess.run([str(binary),'-f','obj','-o',str(actual/'rgb_asm.obj'),str(sources['rgb_asm'])],capture_output=True,text=True,timeout=30)
    (actual/'rgb_asm.log').write_text(result.stdout+result.stderr)
    if result.returncode or result.stderr:raise ValueError('RGB NASM assembly failed: '+result.stderr)
    modules={n:Module.parse((actual/(n+'.obj')).read_bytes()) for n in sources}
    proof=verify_native(modules,LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes()),spec)
    check_snapshot(before)
    return {'kind':'complete RGB C/ASM contributions; not complete executable',
        'target_sha256':TARGET_SHA256,'descriptor':'modules/mact_rgb.json','descriptor_sha256':before[descriptor],
        'actual_build_directory':str(actual),
        'objects_sha256':{n:digest(actual/(n+'.obj')) for n in sources},
        'sources_sha256':{str(p.relative_to(ROOT)):before[p] for p in sources.values()},
        'inputs_sha256':{str(p):v for p,v in sorted(before.items())},
        'compiler_sha256':before[compiler],'options':OPTIONS,'assembler':assembler,
        'source_reference_evidence':spec['source_reference_evidence'],**proof,
        'humanization_backlog':BACKLOG,'full_executable_rebuilt':False,
        'BSS_alignment':origin['BSS_alignment']}

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True)
    p.add_argument('--nasm',type=Path)
    a=p.parse_args();report=probe(a.home,a.build,a.nasm)
    a.report.parent.mkdir(parents=True,exist_ok=True);a.report.write_text(json.dumps(report,indent=2)+'\n')
    print('RGB VERIFIED: 795 initialized, 265232 BSS, 23 typed fixups; full EXE unfinished')
if __name__=='__main__':main()
