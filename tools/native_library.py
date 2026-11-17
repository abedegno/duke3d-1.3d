"""Package explicit whole native objects with checked, unmodified GA WLIB.

This layer verifies packaging integrity, not source provenance or target bytes.
Callers must retain whole-translation-unit source/header/build receipts. No SDK
object, archive recipe or target is read implicitly; no source credit is awarded.
"""
import hashlib
import os
from pathlib import Path, PureWindowsPath
import re
import shutil
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from runner import run_batch
from tools.inventory_watcom_runtime import read_archive

WLIB_SHA256 = 'e43aee0886677cfb346513cc3d8e0bf8439774d27a45c4ecdd80d44f4b316eb0'


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def module_key(name):
    # Native WLIB replaces SOURCE.C with SOURCE.ASM in incremental archives.
    # It is the actual THEADR's case-insensitive stem that must be unique.
    stem = PureWindowsPath(name).stem
    if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]{0,7}', stem):
        raise ValueError('unsupported native library module identity: '+name)
    return stem.casefold()


def emulator_path():
    executable = os.environ.get('EXHUME_DOSBOX_X') or shutil.which('dosbox-x')
    if not executable:
        raise ValueError('DOSBox-X is required')
    return Path(shutil.which(executable) or executable).resolve()


def build_library(home, objects, build, timeout=60):
    """Build a fresh SOURCE.LIB, rejecting replacement and metadata damage.

    Supports the measured native eight-character module-ID/8.3 filename route.
    Original object bytes, including debugger metadata and unused imports, are
    retained. An existing output directory is never reused or overwritten.
    """
    home, build = Path(home).resolve(), Path(build).resolve()
    paths = [Path(path).resolve() for path in objects]
    if not paths:
        raise ValueError('native library requires at least one whole object')
    expected, exports, rows = {}, {}, []
    for path in paths:
        if not path.is_file():
            raise ValueError('native object is missing: '+str(path))
        raw = path.read_bytes()
        module = Module.parse(raw)
        key = module_key(module.name)
        if key in expected:
            raise ValueError('duplicate native module stem: '+key)
        public = sorted(set(module.publics)-module.local_publics)
        for name in public:
            folded = name.casefold()
            if folded in exports:
                raise ValueError('duplicate native global export: '+name)
            exports[folded] = name
        row = {'object':str(path), 'module_name':module.name, 'module_key':key,
               'sha256':hashlib.sha256(raw).hexdigest(), 'exports':public}
        expected[key] = row
        rows.append(row)
    wlib = home/'BINB/wlib.exe'
    if not wlib.is_file() or digest(wlib) != WLIB_SHA256:
        raise ValueError('unmeasured native WLIB identity')
    emulator = emulator_path()
    inputs = {*paths, wlib, emulator, Path(sys.executable).resolve(),
              Path(__file__).resolve(), ROOT/'profiles/watcom/tools/runner.py',
              ROOT/'profiles/watcom/tools/omf32.py', ROOT/'tools/inventory_watcom_runtime.py'}
    before = {str(path):digest(path) for path in inputs}
    if any(before[row['object']] != row['sha256'] for row in rows):
        raise ValueError('native object changed during inspection')
    build.mkdir(parents=True, exist_ok=False)
    staged = {}
    batch = '@echo off\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
    for index, row in enumerate(rows, 1):
        alias = f'O{index:03}.OBJ'
        shutil.copyfile(row['object'], build/alias)
        staged[alias] = row['sha256']
        batch += ('wlib -q '+('-n' if index==1 else '-b')+' SOURCE.LIB +'+alias+
                  ' >> WLIB.LOG\r\nif errorlevel 1 goto failed\r\n')
    if any(digest(build/name) != value for name,value in staged.items()):
        raise ValueError('native object changed during staging')
    def inputs_unchanged():
        return (emulator_path() == emulator and
                all(digest(path) == value for path,value in before.items()) and
                all(digest(build/name) == value for name,value in staged.items()))
    batch += ('echo OK>STATUS.TXT\r\ngoto end\r\n:failed\r\n'
              'echo FAILED>STATUS.TXT\r\n:end\r\n')
    run_batch(home, build, batch, timeout)
    if not inputs_unchanged():
        raise ValueError('native library input/tool changed during production')
    status, log, output = build/'STATUS.TXT', build/'WLIB.LOG', build/'SOURCE.LIB'
    if (not status.is_file() or status.read_text().strip() != 'OK' or
            not log.is_file() or log.read_bytes() or not output.is_file()):
        raise ValueError('native WLIB failed or reported a diagnostic')
    raw = output.read_bytes()
    archive = read_archive(raw)
    if len(archive['members']) != len(expected):
        raise ValueError('native archive lost or added a member')
    members, seen = [], set()
    for member in archive['members']:
        module = Module.parse(raw[member['offset']:member['end']])
        key = module_key(module.name)
        if key in seen or key not in expected:
            raise ValueError('duplicate or unexpected native archive member')
        seen.add(key)
        original = expected[key]
        if member['sha256'] != original['sha256']:
            raise ValueError('native archive changed whole object bytes')
        members.append({'module_name':module.name, 'module_key':key,
                        'sha256':member['sha256'], 'exports':original['exports']})
    if seen != set(expected):
        raise ValueError('native archive is missing a member')
    if digest(output) != hashlib.sha256(raw).hexdigest() or not inputs_unchanged():
        raise ValueError('native archive or input changed during verification')
    return {'kind':'Native packaging integrity only; no source or target-byte proof',
            'library':str(output), 'library_sha256':hashlib.sha256(raw).hexdigest(),
            'objects':rows, 'members':members, 'exports':sorted(exports.values()),
            'inputs_sha256':before, 'staged_object_sha256':staged,
            'WLIB_sha256':WLIB_SHA256, 'source_credit':0,
            'historical_selection_or_order_proved':False,
            'full_executable_rebuilt':False}
