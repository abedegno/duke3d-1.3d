"""Rebuild the engine and report strict function/module comparisons.

The prebuilt object supplies independently rechecked anchors and extents only.
It is never linked into, or copied into, the reconstructed source object.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import compile_source, compiler_bin
from tools.match_function import match_function, MatchError
from tools.preserve import TARGET_SHA256
from tools.verify_module import verify_module, ModuleError

REFERENCE = ROOT/'reference/historical/kenbuild-related-archives-20241213/BUILD_MISC_199604/OBJLIBS/ENGINE.OBJ'
ANCHORS = ROOT/'evidence/historical-engine-object-match.json'
OPTIONS = ['/4r', '/s', '/or', '/dLIBVER_BUILDREV=19960320']
INCLUDES = ['src/engine/include']
INPUTS = ['src/engine/engine.c', 'src/engine/include/build.h',
          'src/engine/include/ves2.h', 'src/engine/include/pragmas.h']


def sha(data):
    return hashlib.sha256(data).hexdigest()


def compare_functions(module, image, reference, anchors):
    """Check complete reference public intervals; never normalize branch bytes."""
    placements = {int(k):tuple(v) for k,v in anchors['placements'].items()}
    symbols = anchors['verification']['publics']
    code = [n for n,s in enumerate(reference.segments,1)
            if s.size and s.class_name.upper() == 'CODE']
    if len(code) != 1:
        raise ValueError('reference requires one CODE segment')
    number = code[0]
    # Each function comparison binds its own CODE base. Whole-module placement
    # is checked separately and remains mandatory for a complete module proof.
    placements.pop(number)
    rows = []
    for name,(segment,start) in sorted(reference.publics.items()):
        if segment != number:
            continue
        end = min((o for n,o in reference.publics.values() if n == number and o > start),
                  default=reference.segments[number-1].size)
        obj,offset = symbols[name]
        if name not in module.publics:
            row = {'symbol':name, 'match':False, 'error':'missing source public'}
        else:
            try:
                row = match_function(module, name, image, obj, offset, end-start,
                                     symbols, placements)
            except MatchError as error:
                row = {'symbol':name, 'match':False, 'error':str(error)}
        rows.append(row)
    return rows


def bss_layout(module, reference):
    """Compare zero state, named offsets and extent to the reverified reference."""
    def inventory(m):
        segments = [n for n,s in enumerate(m.segments,1)
                    if s.size and s.class_name.upper() == 'BSS']
        if len(segments) != 1:
            raise ValueError('engine requires one BSS segment')
        n = segments[0]
        s = m.segments[n-1]
        publics = {name:off for name,(seg,off) in m.publics.items() if seg == n}
        return (s.size, s.attributes, publics,
                not any(s.data) and not any(f.segment == n for f in m.fixups))
    actual,expected = inventory(module),inventory(reference)
    return {'match':actual == expected, 'bytes':actual[0], 'publics':len(actual[2]),
            'scope':'zero state, segment attributes, named offsets and extent; no CODE or linking claim'}


def probe(home: Path, output: Path):
    raw = (ROOT/'reference/DUKE3D.EXE').read_bytes()
    if sha(raw) != TARGET_SHA256:
        raise ValueError('reference executable identity mismatch')
    image = LEImage.parse(raw)
    anchor_bytes = ANCHORS.read_bytes()
    anchors = json.loads(anchor_bytes)
    original = REFERENCE.read_bytes()
    if sha(original) != anchors['sha256']:
        raise ValueError('historical object identity mismatch')
    compiler = home/compiler_bin(home)/'wcc386.exe'
    compiler_identity = json.loads((ROOT/'evidence/watcom-10.5.json').read_text())
    compiler_sha = sha(compiler.read_bytes())
    if compiler_sha != compiler_identity['tools']['BINW/wcc386.exe']['sha256']:
        raise ValueError('Watcom 10.5 compiler identity mismatch')
    reference = Module.parse(original)
    placements = {int(k):tuple(v) for k,v in anchors['placements'].items()}
    symbols = anchors['verification']['publics']
    # Replay the reference-only proof against this executable before using any
    # of its names, extents or data/BSS placements as source comparison anchors.
    verify_module(reference, image, placements, symbols)
    output.mkdir(parents=True, exist_ok=True)
    obj = output/'engine.obj'
    input_hashes = {p:sha((ROOT/p).read_bytes()) for p in INPUTS}
    compile_source(home, ROOT/'src/engine/engine.c', obj, OPTIONS, 60,
                   include_dirs=[ROOT/p for p in INCLUDES])
    if input_hashes != {p:sha((ROOT/p).read_bytes()) for p in INPUTS}:
        raise ValueError('source input changed during engine compilation')
    module = Module.parse(obj.read_bytes())
    rows = compare_functions(module, image, reference, anchors)
    try:
        verification = verify_module(module, image, placements, symbols)
    except ModuleError as error:
        verification = {'verified':False, 'error':str(error)}
    return {'status':'strict engine comparisons; full executable remains unfinished',
            'target_sha256':TARGET_SHA256, 'reference_object_sha256':sha(original),
            'anchor_report_sha256':sha(anchor_bytes),
            'compiler_sha256':compiler_sha, 'compiler_options':OPTIONS,
            'source_inputs_sha256':input_hashes,
            'object_sha256':sha(obj.read_bytes()),
            'object_identity_note':'Dependency metadata can vary between compiler runs.',
            'segments':[{'name':s.name, 'class':s.class_name, 'bytes':s.size}
                        for s in module.segments],
            'functions':rows, 'total_functions':len(rows),
            'matched_functions':sum(r['match'] for r in rows),
            'matched_function_bytes':sum(r['compared_bytes'] for r in rows if r['match']),
            'matched_function_fixups':sum(r['verified_fixups'] for r in rows if r['match']),
            'bss_layout':bss_layout(module,reference),
            'module_verification':verification, 'full_executable_rebuilt':False}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home', type=Path, default=ROOT/'toolchains/watcom-10.5')
    parser.add_argument('--build', type=Path, default=ROOT/'build/engine-reconciliation')
    parser.add_argument('--report', type=Path, default=ROOT/'evidence/engine-function-matches.json')
    args = parser.parse_args()
    report = probe(args.home.resolve(),args.build.resolve())
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report,indent=2)+'\n')
    print(f"Strict engine function matches: {report['matched_functions']}/{report['total_functions']}")
    print(f"Whole-engine module verified: {report['module_verification']['verified']}")
    print('Full executable rebuild remains outstanding')
