#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Build GAME from 79 C functions and two named assembly fallbacks.

Compile the complete live inputs, then combine their relocatable source outputs.
Target executables and previously compiled objects are never inputs.
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
from omf32 import Module
from runner import compile_source, run_batch
from tools import game_omf_link as linker
from tools.build_actors_c import publish_checked
from tools.build_game_compound import (prepare_live_headers, header_sources,
                                       OPTIONS, check_diagnostics, inventory)
from tools.verified_snapshot import (capture, capture_tree, check, check_tree,
                                     copy_verified)
from profiles.gnu_elf_omf_game.identity import checked_home, profile


def need(value, message):
    if not value:
        raise ValueError('GAME C: ' + message)


def build_source(home, build, *, assembler_home=None):
    home = Path(home).resolve()
    assembler_home = Path(assembler_home or ROOT / 'toolchains/gnu-elf-omf-game').resolve()
    compiler_profile = capture(ROOT / 'profiles/watcom/game-compound-tools.json')
    compiler_tree = capture_tree(home)
    need({n: p.sha256 for n, p in compiler_tree.items()} == compiler_profile.json(),
         'complete pinned GA compiler installation')
    assembler_tree = checked_home(assembler_home)
    emulator = os.environ.get('EXHUME_DOSBOX_X') or shutil.which('dosbox-x')
    need(emulator, 'DOSBox-X required')
    pins = [compiler_profile, capture(Path(emulator).resolve()),
            capture(Path(sys.executable).resolve()), capture(__file__)]
    pins.extend(compiler_tree.values())
    pins.extend(capture(assembler_home / n, h) for n, h in assembler_tree.items())
    for name in ['tools/game_omf_link.py', 'tools/actors_omf_link.py',
                 'tools/build_actors_c.py', 'tools/build_game_compound.py',
                 'tools/verified_snapshot.py', 'profiles/watcom/tools/runner.py',
                 'profiles/watcom/tools/omf32.py', 'profiles/gnu_elf_omf_game/identity.py',
                 'profiles/gnu_elf_omf_game/profile.json']:
        pins.append(capture(ROOT / name))
    names = ['game.c', 'gametext.h', 'game_fallback.S', 'game_private_imports.json',
             'game_text_model.json', 'game_tail.asm']
    sources = {n: capture(ROOT / 'src/game' / n) for n in names}
    pins.extend(sources.values())
    tail_descriptor = capture(ROOT / 'modules/game_compound.json')
    pins.append(tail_descriptor)
    headers = {}
    for path in header_sources():
        headers[Path(path).name.lower()] = capture(ROOT / path)
    pins.extend(headers.values())
    header_inventory = {n: p.sha256 for n, p in headers.items()}
    parent = Path(build).resolve()
    parent.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix='game-c-', dir=parent))
    stage = work / 'source-only'
    stage.mkdir()
    staged = [copy_verified(p, stage / n) for n, p in sources.items()]
    prepare_live_headers(stage / 'include')
    staged_headers = capture_tree(stage / 'include')
    need({n: p.sha256 for n, p in staged_headers.items()} == header_inventory,
         'live prepared header identities')
    staged.extend(staged_headers.values())
    # The native compiler copies the translation unit to SOURCE.C and searches INC0.
    staged.append(copy_verified(sources['gametext.h'], stage / 'include/gametext.h'))

    def fresh():
        check(pins + staged)
        check_tree(home, compiler_tree)
        need(checked_home(assembler_home) == assembler_tree, 'assembler installation changed')
        need({Path(p).name.lower(): h for p, h in header_sources().items()} ==
             header_inventory, 'header namespace changed')
        need({p.relative_to(stage).as_posix() for p in stage.rglob('*') if p.is_file()} ==
             {p.path.relative_to(stage).as_posix() for p in staged}, 'staged namespace changed')

    fresh()
    options = OPTIONS + ['/dGAME_ASM_FALLBACKS']
    compile_source(home, stage / 'game.c', work / 'C.OBJ', options, 60,
                   include_dirs=[stage / 'include'])
    diagnostics = check_diagnostics(work / 'C.log')
    logs = [capture(work / 'C.log')]
    fresh()
    commands = [
        [str(assembler_home / 'bin/as-new'), *profile()['options']['assembler'],
         '-o', str(work / 'ASM.ELF'), str(stage / 'game_fallback.S')],
        [str(assembler_home / 'bin/objconv'), *profile()['options']['converter'],
         str(work / 'ASM.ELF'), str(work / 'ASM.OBJ')],
    ]
    for number, command in enumerate(commands):
        fresh()
        run = subprocess.run(command, capture_output=True, timeout=60)
        log = work / ('ASM-' + str(number) + '.log')
        log.write_bytes(run.stdout + run.stderr)
        need(run.returncode == 0 and not run.stderr and b'warning' not in run.stdout.lower(),
             'assembler/converter diagnostics')
        logs.append(capture(log))
        fresh()
    compiled = [capture(work / name) for name in ['C.OBJ', 'ASM.OBJ', 'ASM.ELF']]
    c_module, asm_module = (Module.parse(p.raw) for p in compiled[:2])
    c_functions = sorted(n for n, (s, _) in c_module.publics.items()
                         if n not in c_module.local_publics and c_module._segment(s).class_name == 'CODE')
    need(len(c_functions) == 79 and set(asm_module.publics) == {'spawn_', 'checkcommandline_'},
         'finite C/assembly function ownership')
    declaration = linker.load_json(sources['game_private_imports.json'].raw)
    model = linker.load_json(sources['game_text_model.json'].raw)
    merged, comments, contributions = linker.coalesce(compiled[0].raw, compiled[1].raw,
                                                      declaration, model)
    raw = linker.serialize(merged, comments)
    proof = linker.verify_roundtrip(merged, raw)
    output = work / 'GAME.OBJ'
    output.write_bytes(raw)
    # The six genuine tail owners remain a separate native object.
    tail = copy_verified(sources['game_tail.asm'], work / 'GMTAIL.ASM')
    fresh()
    run_batch(home, work, '@echo off\r\nset PATH=D:\\BINB;D:\\BIN\r\nwasm /zq GMTAIL.ASM > TAIL.LOG\r\nif errorlevel 1 goto failed\r\necho OK>TAILSTAT.TXT\r\ngoto done\r\n:failed\r\necho FAILED>TAILSTAT.TXT\r\n:done\r\n', 45)
    need((work / 'TAILSTAT.TXT').read_text().strip() == 'OK' and
         not (work / 'TAIL.LOG').read_bytes(), 'tail diagnostics')
    tail_object = capture(work / 'GMTAIL.OBJ')
    tm = Module.parse(tail_object.raw)
    need(inventory(tm) == tail_descriptor.json()['tail_native_inventory'],
         'complete genuine tail inventory')
    outputs = compiled + logs + [capture(output), tail, tail_object,
                                 capture(work / 'TAIL.LOG'), capture(work / 'TAILSTAT.TXT')]
    fresh()
    check(outputs)
    result = dict(source_only=True, source_native_omf_link=True,
                  object=str(output), object_sha256=hashlib.sha256(raw).hexdigest(),
                  tail_object=str(tail_object.path), tail_object_sha256=tail_object.sha256,
                  emitting_c_functions=79, emitting_assembly_functions=['spawn', 'checkcommandline'],
                  c_function_symbols=c_functions, source_translation_units=3, owned_link_objects=2,
                  target_or_cached_object_input=False, options=options, commands=commands,
                  diagnostics=diagnostics, contributions=contributions, semantic_source_link=proof,
                  inputs_sha256={str(p.path): p.sha256 for p in pins},
                  staged_sha256={str(p.path): p.sha256 for p in staged},
                  outputs_sha256={str(p.path): p.sha256 for p in outputs},
                  directory=str(work), compiler_home=str(home), assembler_home=str(assembler_home),
                  staging_root=str(stage), header_inventory=header_inventory)
    publish_checked(work / 'source-build.json', result, pins + staged + outputs, fresh)
    return result


def apply_layout(normal, build, plan_path, expected_plan_sha256, *, extra_pins=None):
    from tools.build_native_layout import check_native, receipt_pins, parse_plan
    need(normal.get('source_native_omf_link') is True, 'fresh GAME source link required')
    pins = [capture(n, h) for n, h in {**receipt_pins(normal), **(extra_pins or {})}.items()]
    pins.extend([capture(ROOT / 'tools/build_native_layout.py'),
                 capture(plan_path, expected_plan_sha256)])
    original = capture(normal['object'], normal['object_sha256'])
    before = Module.parse(original.raw)
    plan = parse_plan(pins[-1].raw.decode('ascii'), before._segment(1).size)
    raw = linker.repacketize(original.raw, plan['packets'])
    proof = check_native(before, Module.parse(raw), plan)
    parent = Path(build).resolve()
    parent.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix='game-c-layout-', dir=parent))
    path = work / 'GAME.OBJ'
    def fresh():
        check(pins + [original])
        need({Path(p).name.lower(): h for p, h in header_sources().items()} ==
             normal['header_inventory'], 'header namespace changed before layout publication')
        need({str(p.path): p.sha256 for p in capture_tree(normal['staging_root']).values()} ==
             normal['staged_sha256'], 'staged namespace changed before layout publication')
        for key in ['compiler_home', 'assembler_home']:
            home = Path(normal[key])
            expected = {str(p.path): p.sha256 for p in pins if p.path.is_relative_to(home)}
            need({str(p.path): p.sha256 for p in capture_tree(home).values()} == expected,
                 'complete tool namespace changed')
    fresh()
    path.write_bytes(raw)
    output = capture(path)
    result = dict(source_only=True, source_native_omf_link=True, normal_source=normal,
                  object=str(path), object_sha256=output.sha256, tail_object=normal['tail_object'],
                  tail_object_sha256=normal['tail_object_sha256'], emitting_c_functions=79,
                  emitting_assembly_functions=['spawn', 'checkcommandline'], proof=proof,
                  packet_count=len(plan['packets']), target_or_cached_object_input=False,
                  inputs_sha256={str(p.path): p.sha256 for p in pins + [original]},
                  outputs_sha256={str(path): output.sha256})
    publish_checked(work / 'source-build.json', result, pins + [original, output], fresh)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home', type=Path, default=ROOT / 'toolchains/watcom-10.0-ga')
    parser.add_argument('--assembler-home', type=Path, default=ROOT / 'toolchains/gnu-elf-omf-game')
    parser.add_argument('--build', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(build_source(args.home, args.build, assembler_home=args.assembler_home), indent=2))


if __name__ == '__main__':
    main()
