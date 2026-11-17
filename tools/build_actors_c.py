#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Fresh ACTORS C plus its named effector, linked without decoding instructions.

The source-only producer emits a complete relocatable OMF module. Native layout
is a separate metadata-only step. Neither step reads a target or cached object.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT / 'profiles/watcom/tools')]
from runner import compile_source
from omf32 import Module
from tools.prove_module import prepare_headers
from tools.verified_snapshot import capture, capture_tree, check, check_tree, copy_verified, publish_json
from tools import actors_omf_link as linker

OPTIONS = ['/4r', '/s', '/ort', '/dAPPVER_EXEDEF=DN3D13G',
           '/dLIBVER_BUILDREV=19960320', '/dDUKE13D_EFFECTOR_ASM=1']
NASM_SHA256 = 'c6d2ce2396140d994438a98ef45a8f0e8c9c90b0edb7ad418352bca051e0c295'
REFERENCES = ['reference/duke3d-reconstructions', 'reference/duke3d-reconstructions/MACT']
OVERLAYS = ['src/include', 'src/game/include', 'src/engine/include']


def need(value, message):
    if not value:
        raise ValueError('ACTORS C: ' + message)


def publish_checked(path, value, snapshots, validate):
    need(not Path(path).exists(), 'new source receipt path required')
    validate()
    receipt = publish_json(path, value, snapshots)
    try:
        validate()
        receipt.check()
    except Exception:
        Path(path).unlink(missing_ok=True)
        raise
    return receipt


def build_source(home, build, *, assembler_home=None):
    """Compile both live inputs now; no object/receipt reuse interface."""
    need(not os.environ.get('NASMENV'), 'ambient NASMENV is unsupported')
    home = Path(home).resolve()
    assembler_home = Path(assembler_home or ROOT / 'toolchains/support/nasm-2.16.03').resolve()
    profile = capture(ROOT / 'profiles/watcom/game-compound-tools.json')
    tool_tree = capture_tree(home)
    need({n: p.sha256 for n, p in tool_tree.items()} == profile.json(), 'complete pinned GA tool installation')
    assembler = capture(assembler_home / 'nasm', NASM_SHA256)
    emulator_name = os.environ.get('EXHUME_DOSBOX_X') or shutil.which('dosbox-x')
    need(emulator_name, 'DOSBox-X is required')
    pins = [profile, assembler, capture(Path(emulator_name).resolve()),
            capture(Path(sys.executable).resolve()), capture(__file__),
            capture(ROOT / 'tools/actors_omf_link.py'), capture(ROOT / 'tools/verified_snapshot.py'),
            capture(ROOT / 'tools/prove_module.py'), capture(ROOT / 'profiles/watcom/tools/runner.py'),
            capture(ROOT / 'profiles/watcom/tools/omf32.py')]
    pins.extend(tool_tree.values())
    sources = [capture(ROOT / 'src/game/actors.c'), capture(ROOT / 'src/game/moveeffectors.asm')]
    pins.extend(sources)
    headers = {}
    header_namespaces = {}
    for folder in REFERENCES + OVERLAYS:
        directory = ROOT / folder
        members = tuple(sorted(p for p in directory.iterdir() if p.is_file() and p.suffix.lower() == '.h'))
        header_namespaces[directory] = members
        for p in members:
            snap = capture(p)
            pins.append(snap)
            headers[p.name.lower()] = snap.sha256

    parent = Path(build).resolve()
    parent.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix='actors-c-', dir=parent))
    stage = work / 'source-only'
    stage.mkdir()
    staged = [copy_verified(sources[0], stage / 'ACTORS.C'),
              copy_verified(sources[1], stage / 'MOVEFFECTORS.ASM')]
    prepare_headers([ROOT / p for p in REFERENCES], [ROOT / p for p in OVERLAYS], stage / 'include')
    staged_headers = capture_tree(stage / 'include')
    need({n: p.sha256 for n, p in staged_headers.items()} == headers, 'header copy differs from retained input identities')
    staged.extend(staged_headers.values())

    def fresh():
        check(pins + staged)
        check_tree(home, tool_tree)
        for directory, expected in header_namespaces.items():
            actual = tuple(sorted(p for p in directory.iterdir() if p.is_file() and p.suffix.lower() == '.h'))
            need(actual == expected, 'header input namespace changed')
        need(set(p.relative_to(stage).as_posix() for p in stage.rglob('*') if p.is_file()) ==
             set(p.path.relative_to(stage).as_posix() for p in staged), 'staged source namespace changed')

    fresh()
    compile_source(home, stage / 'ACTORS.C', work / 'C.OBJ', OPTIONS, 60, include_dirs=[stage / 'include'])
    c_log = capture(work / 'C.log')
    need(not any(word in c_log.raw for word in (b'Warning!', b'Error!')), 'native C diagnostics')
    fresh()
    command = [str(assembler.path), '-f', 'obj', '-o', str(work / 'ASM.OBJ'), str(stage / 'MOVEFFECTORS.ASM')]
    run = subprocess.run(command, capture_output=True, timeout=30)
    log_raw = run.stdout + run.stderr
    (work / 'ASM.log').write_bytes(log_raw)
    need(run.returncode == 0 and not log_raw, 'native assembler diagnostics')
    fresh()
    compiled = [capture(work / 'C.OBJ'), capture(work / 'ASM.OBJ')]
    c_module, asm_module = (Module.parse(p.raw) for p in compiled)
    def code_publics(module):
        return sorted(n for n, (seg, _) in module.publics.items()
                      if n not in module.local_publics and module._segment(seg).class_name == 'CODE')
    c_functions = code_publics(c_module)
    asm_functions = code_publics(asm_module)
    need(len(c_functions) == 36 and asm_functions == ['moveeffectors_'], 'finite source function ownership changed')
    merged, comments, contributions = linker.coalesce([p.raw for p in compiled])
    spans = linker.source_packets([p.raw for p in compiled])
    raw = linker.serialize(merged, comments, spans)
    proof = linker.verify_roundtrip(merged, raw)
    expected = hashlib.sha256(raw).hexdigest()
    output_path = work / 'ACTORS.OBJ'
    output_path.write_bytes(raw)
    output = capture(output_path, expected)
    fresh()
    check(compiled + [c_log, output])
    result = {
        'source_only': True, 'source_native_omf_link': True,
        'object': str(output.path), 'object_sha256': expected,
        'source_files': ['src/game/actors.c', 'src/game/moveeffectors.asm'],
        'emitting_c_functions': len(c_functions), 'emitting_assembly_functions': ['moveeffectors'],
        'c_function_symbols': c_functions,
        'source_translation_units': 2, 'owned_link_objects': 1,
        'target_or_cached_object_input': False, 'options': OPTIONS,
        'assembler_command': command, 'contributions': contributions,
        'semantic_source_link': proof, 'normal_source_packets': spans,
        'inputs_sha256': {str(p.path): p.sha256 for p in pins},
        'staged_sha256': {str(p.path): p.sha256 for p in staged},
        'outputs_sha256': {str(p.path): p.sha256 for p in compiled + [c_log, output]},
        'directory': str(work),
        'compiler_home': str(home),
        'staging_root': str(stage),
        'header_namespaces': {str(folder): [str(p) for p in members] for folder, members in header_namespaces.items()},
    }
    fresh()
    publish_checked(work / 'source-build.json', result, pins + staged + compiled + [c_log, output], fresh)
    return result


def apply_layout(normal, build, plan_path, expected_plan_sha256, *, extra_pins=None):
    """Internal second step for a trusted current-invocation source result.

    This is not an external receipt/object adoption interface or an attestation
    against arbitrary caller-controlled Python. Every runtime property stays literal.
    """
    from tools.build_native_layout import check_native, receipt_pins, parse_plan
    need(normal.get('source_native_omf_link') is True, 'fresh source-native OMF link required')
    retained = receipt_pins(normal)
    pins = [capture(n, h) for n, h in {**retained, **(extra_pins or {})}.items()]
    pins.append(capture(ROOT / 'tools/build_native_layout.py'))
    original = capture(normal['object'], normal['object_sha256'])
    plan_snapshot = capture(plan_path, expected_plan_sha256)
    compiler_home = Path(normal['compiler_home'])
    expected_tools = {str(p.path): p.sha256 for p in pins if p.path.is_relative_to(compiler_home)}
    actual_tools = capture_tree(compiler_home)
    need({str(p.path): p.sha256 for p in actual_tools.values()} == expected_tools, 'compiler namespace changed')
    for folder, expected in normal['header_namespaces'].items():
        actual = sorted(str(p) for p in Path(folder).iterdir() if p.is_file() and p.suffix.lower() == '.h')
        need(actual == expected, 'header namespace changed before layout')
    staging_root = Path(normal['staging_root'])
    staged_tree = capture_tree(staging_root)
    need({str(p.path): p.sha256 for p in staged_tree.values()} == normal['staged_sha256'],
         'staged source namespace changed before layout')
    before = Module.parse(original.raw)
    plan = parse_plan(plan_snapshot.raw.decode('ascii'), before._segment(1).size)
    raw = linker.repacketize(original.raw, plan['packets'])
    after = Module.parse(raw)
    proof = check_native(before, after, plan)
    parent = Path(build).resolve()
    parent.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix='actors-c-layout-', dir=parent))
    path = work / 'ACTORS.OBJ'
    expected = hashlib.sha256(raw).hexdigest()
    def fresh():
        check(pins + [original, plan_snapshot])
        check_tree(compiler_home, actual_tools)
        check_tree(staging_root, staged_tree)
        for folder, expected in normal['header_namespaces'].items():
            actual = sorted(str(p) for p in Path(folder).iterdir() if p.is_file() and p.suffix.lower() == '.h')
            need(actual == expected, 'header namespace changed through layout publication')

    fresh()
    path.write_bytes(raw)
    output = capture(path, expected)
    result = {
        'source_only': True, 'source_native_omf_link': True,
        'normal_source': normal, 'object': str(path), 'object_sha256': expected,
        'emitting_c_functions': 36, 'emitting_assembly_functions': ['moveeffectors'],
        'source_translation_units': 2, 'owned_link_objects': 1,
        'proof': proof, 'packet_count': len(plan['packets']),
        'inputs_sha256': {str(p.path): p.sha256 for p in pins + [original, plan_snapshot]},
        'outputs_sha256': {str(output.path): output.sha256},
        'target_or_cached_object_input': False,
    }
    publish_checked(work / 'source-build.json', result, pins + [original, plan_snapshot, output], fresh)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home', type=Path, default=ROOT / 'toolchains/watcom-10.0-ga')
    parser.add_argument('--assembler-home', type=Path, default=ROOT / 'toolchains/support/nasm-2.16.03')
    parser.add_argument('--build', type=Path, required=True)
    args = parser.parse_args()
    result = build_source(args.home, args.build, assembler_home=args.assembler_home)
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
