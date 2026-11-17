"""Prove the complete MENUES contribution and its native public partition.

Whole CODE/CONST/DATA/BSS identity at one placement is required before the
20-public partition is checked. This does not rebuild the full executable.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import compile_source, compiler_bin
from tools.prove_module import prepare_headers, digest, prove, assert_contributions
from tools.probe_premap import OPTIONS, check_intervals, check_source_interval
from tools.infer_bindings import infer_bindings
from tools.verify_module import verify_module, external_anchor_bindings
from tools.preserve import TARGET_SHA256

FUNCTIONS = {'cmenu_': (173120, 160), 'savetemp_': (173280, 48),
             'getangplayers_': (173328, 272), 'loadpheader_': (173600, 304), 'probe_': (178432, 912),
             'menutext_': (179344, 752), 'menutextc_': (180096, 656),
             'bar_': (180752, 592), 'dispnames_': (181344, 544),
             'getfilenames_': (181888, 208), 'sortfilenames_': (182096, 448), 'menus_': (182544, 16192),
             'palto_': (198736, 288),
             'logoanimsounds_': (203328, 48), 'drawoverheadmap_': (199024, 3952),
             'endanimsounds_': (202976, 352), 'playanm_': (203376, 507)}
LATER_ANCESTOR_BODIES = ['dummyfunc_', 'dummymess_', 'TENtext_',
           'intro4animsounds_', 'first4animsounds_', 'intro42animsounds_',
           'endanimvol41_', 'endanimvol42_', 'endanimvol43_']

PRIOR_FUNCTIONS = dict(FUNCTIONS)
FUNCTIONS.update({'loadplayer_': (173904, 4416),
                  'menues_inferred_save_tail_entry_': (178320, 16),
                  'saveplayer_': (178336, 96)})
CANDIDATES = {}
EXPECTED = {'initialized_bytes': 33762, 'zero_fill_bytes': 4571, 'verified_fixups': 2263}


def check_complete_module(module, image, known):
    """Check every emitted segment before deriving any new public geometry."""
    inventory = {i: (seg.name, seg.class_name, seg.size)
                 for i, seg in enumerate(module.segments, 1) if seg.size}
    if inventory != {1: ('_TEXT', 'CODE', 30763), 2: ('CONST', 'DATA', 2983),
                     4: ('_DATA', 'DATA', 16), 5: ('_BSS', 'BSS', 4571)}:
        raise ValueError('unexpected complete MENUES segment inventory')
    code_publics = {n for n, (segment, _) in module.publics.items() if segment==1}
    if code_publics != set(FUNCTIONS):
        raise ValueError('unexpected complete MENUES CODE publics')
    if 'menues_inferred_save_tail_entry_' not in module.local_publics:
        raise ValueError('inferred tail entry must remain local')
    bound = infer_bindings(module, image, 1, 173120, known_symbols=known)
    verification = verify_module(module, image, bound['placements'], bound['symbols'])
    assert_contributions(verification, EXPECTED)
    return bound, verification


def check_storage(module, image, functions):
    """Prove only the complete current non-CODE projection, never MENUES.

    The three placements are constrained by accepted code intervals. CODE,
    including menu/switch-table prefixes, is omitted explicitly. The complete
    module gate supplies the separate CODE and common-placement obligation.
    """
    inventory = {i: (seg.name, seg.class_name, seg.size)
                 for i, seg in enumerate(module.segments, 1)
                 if seg.size and seg.class_name.upper()!='CODE'}
    if inventory != {2: ('CONST', 'DATA', 2983), 4: ('_DATA', 'DATA', 16),
                     5: ('_BSS', 'BSS', 4571)}:
        raise ValueError('unexpected MENUES non-CODE segment inventory')
    placements = {2: (3, 7524), 4: (3, 31204), 5: (3, 582944)}
    constrained = {}
    for row in functions:
        if row['comparison']['match'] is not True:
            raise ValueError('unverified MENUES storage anchor interval')
        for segment, value in row['placements'].items():
            segment, value = int(segment), tuple(value)
            if segment==1:
                continue
            if segment in constrained and constrained[segment]!=value:
                raise ValueError('conflicting MENUES storage anchor placements')
            constrained[segment] = value
    if constrained != placements:
        raise ValueError('MENUES storage lacks consistent accepted interval anchors')
    known = {name: tuple(value) for row in functions for name, value in row['bindings'].items()}
    storage = copy.deepcopy(module)
    code = {i for i, seg in enumerate(storage.segments, 1) if seg.class_name.upper()=='CODE'}
    for i in code:
        storage.segments[i-1].size = 0
        storage.segments[i-1].data = bytearray()
    storage.fixups = [fix for fix in storage.fixups if fix.segment not in code]
    storage.publics = {name: value for name, value in storage.publics.items() if value[0] not in code}
    storage.local_publics &= storage.publics.keys()
    proof = verify_module(storage, image, placements, known)
    proof['scope'] = 'Complete native non-CODE projection only; CODE is omitted from this auxiliary check and is required by the separate whole-module verification.'
    proof['source_segments'] = [2, 4, 5]
    return proof


def probe(home, build):
    binary = (ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(binary).hexdigest() != TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    image = LEImage.parse(binary)
    source = ROOT/'src/game/menues.c'
    identity = digest(source)
    descriptor = ROOT/'modules/menues.json'
    descriptor_identity = digest(descriptor)
    spec = json.loads(descriptor.read_text())
    if (spec['source']!='src/game/menues.c' or spec['code_object']!=1 or
            spec['code_offset']!=173120 or spec['code_bytes']!=30763 or
            spec['code_publics']!=20 or spec['options']!=OPTIONS or spec['expected']!=EXPECTED):
        raise ValueError('changed complete MENUES descriptor contract')
    build.mkdir(parents=True, exist_ok=False)
    headers = build/'include'
    prepare_headers([ROOT/'reference/duke3d-reconstructions',
                     ROOT/'reference/duke3d-reconstructions/MACT'],
                    [ROOT/'src/include', ROOT/'src/game/include', ROOT/'src/engine/include'], headers)
    obj = build/'menues.obj'
    compile_source(home, source, obj, OPTIONS, 30, include_dirs=[headers])
    if '0 warnings, 0 errors' not in obj.with_suffix('.log').read_text(encoding='cp437'):
        raise ValueError('MENUES compilation must have zero warnings/errors')
    if digest(source) != identity:
        raise ValueError('source changed during compilation')
    module = Module.parse(obj.read_bytes())
    referenced = {module.externals[f.target-1] for f in module.fixups if f.target_method==2}
    known = {name: (1, offset) for name, (offset, _) in FUNCTIONS.items()}
    anchors = {}
    for filename, key in [('engine-function-matches.json', 'module_verification'),
                          ('gamedef-module.json', 'verification'), ('sounds-module.json', 'verification'),
                          ('mmulti-module.json', 'verification'), ('config-module.json', 'verification'),
                          ('fx_man-module.json', 'verification'), ('music-module.json', 'verification')]:
        path = ROOT/'evidence'/filename
        report = json.loads(path.read_text())
        if report.get('target_sha256') != TARGET_SHA256 or report[key].get('verified') is not True:
            raise ValueError('unverified independent anchor report')
        for name, value in external_anchor_bindings(report[key]).items():
            if name not in referenced:
                continue
            value = tuple(value)
            if name in known and known[name] != value:
                raise ValueError('conflicting independent binding: '+name)
            known[name] = value
        anchors[str(path.relative_to(ROOT))] = digest(path)
    for filename in ['actors-progress.json', 'premap-progress.json']:
        path = ROOT/'evidence'/filename
        report = json.loads(path.read_text())
        if report.get('target_sha256') != TARGET_SHA256:
            raise ValueError('partial anchor reference identity mismatch')
        for row in report['functions']:
            if row['comparison']['match'] is not True:
                raise ValueError('unverified partial function identity')
            name, value = row['symbol'], (1, row['target_offset'])
            if name not in referenced:
                continue
            if name in known and known[name] != value:
                raise ValueError('conflicting partial function identity: '+name)
            known[name] = value
        anchors[str(path.relative_to(ROOT))] = digest(path)
    # Older shared ANIMLIB evidence predates symbol-scope metadata. Replay its
    # complete unchanged descriptor privately and filter its fresh exports.
    animlib = prove('animlib', home, build/'animlib-anchor')
    if animlib.get('target_sha256') != TARGET_SHA256 or animlib['verification'].get('verified') is not True:
        raise ValueError('unverified native ANIMLIB anchor replay')
    for name, value in external_anchor_bindings(animlib['verification']).items():
        if name not in referenced:
            continue
        value = tuple(value)
        if name in known and known[name] != value:
            raise ValueError('conflicting native ANIMLIB binding: '+name)
        known[name] = value
    for name, value in spec['symbol_anchors'].items():
        if (name in module.publics or name not in referenced or
                name not in known or tuple(value)!=known[name]):
            raise ValueError('MENUES descriptor anchor is not independently verified: '+name)
    if digest(descriptor)!=descriptor_identity:
        raise ValueError('MENUES descriptor changed during verification')
    # Preserve the approved17 before applying the whole-proof-backed geometry.
    check_intervals(module, image, PRIOR_FUNCTIONS, known)
    full, verification = check_complete_module(module, image, known)
    functions = check_intervals(module, image, FUNCTIONS, known)
    if (sum(row['size'] for row in functions)!=30763 or
            sum(row['comparison']['verified_fixups'] for row in functions)!=2263):
        raise ValueError('native public partition does not cover complete MENUES CODE')
    storage = check_storage(module, image, functions)
    placements = {str(k): list(v) for k, v in full['placements'].items()}
    return {'kind': 'complete MENUES object contributions, not a full executable',
            'target_sha256': TARGET_SHA256, 'source': 'src/game/menues.c', 'source_sha256': identity,
            'headers_sha256': {p.name: digest(p) for p in sorted(headers.iterdir())},
            'descriptor': 'modules/menues.json', 'descriptor_sha256': descriptor_identity,
            'compiler_sha256': digest(home/compiler_bin(home)/'wcc386.exe'), 'options': OPTIONS,
            'compiler_diagnostics': {'warnings': 0, 'errors': 0},
            'anchor_evidence_sha256': anchors, 'native_anchor_replays': {'animlib': animlib},
            'functions': functions,
            'matched_function_bytes': sum(f['size'] for f in functions),
            'matched_function_fixups': sum(f['comparison']['verified_fixups'] for f in functions),
            'source_code_bytes': module.segments[0].size,
            'unverified_code_publics': sorted(n for n, (s, _) in module.publics.items()
                                              if s==1 and n not in FUNCTIONS),
            'omitted_code_bodies': [], 'later_ancestor_bodies_excluded': LATER_ANCESTOR_BODIES,
            'candidate_full_intervals': {},
            'source_storage_inventory': [{'segment': i, 'name': s.name, 'class': s.class_name,
                                           'size': s.size} for i, s in enumerate(module.segments, 1)
                                         if s.class_name.upper()!='CODE'],
            'full_module_gate': {'verified': True, **EXPECTED}, 'verification': verification,
            'placements': placements, 'constraints': full['constraints'],
            'symbol_anchors': {n: list(v) for n,v in sorted(known.items())
                               if n in referenced and n not in module.publics},
            'noncode_storage': storage, 'noncode_storage_verified': True,
            'initialized_data_verified': True, 'bss_verified': True,
            'leading_code_prefix_verified': True,
            'scope': 'Every emitted CODE, CONST, DATA and BSS byte/fixup is verified at one consistent native placement. The complete20-public CODE partition follows the successful whole-module proof; its inferred static tail entry has unknown historical name/role and is excluded from cross-module exports. Later ancestor TEN/episode4 bodies are outside this earlier target profile. The following5 bytes of inter-module CODE alignment are not counted. This adds one complete MENUES contribution, not a rebuilt executable.',
            'new_complete_contributions': 1, 'full_executable_rebuilt': False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home', type=Path, default=ROOT/'toolchains/watcom-10.0-ga')
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--report', type=Path, required=True)
    args = parser.parse_args()
    report = probe(args.home.resolve(), args.build.resolve())
    args.report.write_text(json.dumps(report, indent=2)+'\n')
    print(f"MENUES VERIFIED: {len(report['functions'])} exact intervals, "
          f"{report['matched_function_bytes']} bytes, {report['matched_function_fixups']} fixups; "
          f"non-CODE {report['noncode_storage']['initialized_bytes']} initialized/"
          f"{report['noncode_storage']['zero_fill_bytes']} BSS bytes; complete contribution")


if __name__=='__main__':
    main()
