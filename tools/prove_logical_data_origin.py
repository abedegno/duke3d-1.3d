"""Closed replay of the reviewed target's candidate combined _DATA origin.

There is no caller-supplied offset, target, evidence label or witness source.
This proves a layout coordinate only, never a new source contribution. Input
updates require a reviewed pin refresh; every call recompiles in a new child.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from le import LEImage
from runner import compile_source, compiler_bin
from tools.prove_module import prepare_headers, assert_contributions
from tools.probe_game import check_code_prefix, check_initialized_data
from tools.probe_premap import check_intervals
from tools.infer_bindings import infer_bindings
from tools.inventory_watcom_runtime import (read_archive, select_member,
                                           nominate_matherr_initializer, native_gate)
from tools.logical_segment_origins import _issue_verified_origin, segment_identity

_INPUTS_SHA256 = '4deb39724368c5db3a4c8ce65f32b2549061313fdb368123c6027a8049a3ad05'
_OPTIONS = ('/4r','/s','/ort','/dAPPVER_EXEDEF=DN3D13G','/dLIBVER_BUILDREV=19960320')
_MATHERR = dict(offset=31472, size=859, name='_matherr',
    sha256='0e7fa19a1405c1dfe027549c81c4e165a14748d4fd6f78c8cbb1f6c0c59b75da')


def _sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


_LOADED_POLICY_SHA256 = _sha(Path(__file__))


def _validate_inputs(home):
    """Closed set and content identities, checked before and after replay."""
    if _sha(Path(__file__)) != _LOADED_POLICY_SHA256:
        raise ValueError('logical origin loaded policy identity changed')
    manifest = ROOT/'tools/logical_data_origin_inputs.json'
    if _sha(manifest) != _INPUTS_SHA256:
        raise ValueError('logical origin input manifest identity changed')
    inputs = json.loads(manifest.read_text())
    def path(name):
        return home/name[6:] if name.startswith('@home/') else ROOT/name
    for directory,names in inputs['file_sets'].items():
        folder = path(directory)
        if directory == '@home/H':
            actual = sorted(p.relative_to(folder).as_posix()
                            for p in folder.rglob('*') if p.is_file())
        else:
            actual = sorted(p.name for p in folder.iterdir()
                            if p.is_file() and p.suffix.lower()=='.h')
        if actual != names:
            raise ValueError('logical origin header-set identity changed: '+directory)
    for name,digest in inputs['sha256'].items():
        if not path(name).is_file() or _sha(path(name)) != digest:
            raise ValueError('logical origin input identity changed: '+name)
    if compiler_bin(home) != 'BINB':
        raise ValueError('logical origin compiler selection identity changed')
    return inputs


def _validate_game_scope(module):
    first = module.publics.get('_cameradist')
    timer = module.publics.get('_TimerPtr')
    if (first is None or first[1] != 0 or timer != (first[0],496) or
            any(s==first[0] and offset<0 for s,offset in module.publics.values())):
        raise ValueError('changed GAME first-public/TimerPtr geometry')
    if {'_cameradist','_TimerPtr'} & module.local_publics:
        raise ValueError('changed GAME native anchor scope')
    identity = segment_identity(module,first[0])
    if identity != ('_DATA','DATA','DGROUP','use32','PUBLIC2'):
        raise ValueError('changed GAME logical DATA identity')
    return first[0], identity


def replay_target_data_origin(*, home=None, build=None):
    """Issue a reusable process context after fresh fixed independent witnesses.

    Raw generated object/log hashes are retained per replay. Their timestamps
    are not the stable semantic evidence fingerprint carried by the context.
    """
    home = Path(home) if home is not None else ROOT/'toolchains/watcom-10.0-ga'
    inputs = _validate_inputs(home)
    emulator = os.environ.get('EXHUME_DOSBOX_X') or shutil.which('dosbox-x')
    if not emulator:
        raise ValueError('native logical origin replay requires DOSBox-X')
    emulator_sha256 = _sha(Path(emulator))
    parent = Path(build) if build is not None else ROOT/'build/logical-data-origin'
    parent.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix='target-origin-', dir=parent))
    headers = work/'include'
    prepare_headers([ROOT/'reference/duke3d-reconstructions',
                     ROOT/'reference/duke3d-reconstructions/MACT'],
                    [ROOT/'src/include',ROOT/'src/game/include',ROOT/'src/engine/include'], headers)
    source = ROOT/'src/game/game.c'
    (work/'GAME.C').write_bytes(source.read_bytes())
    compile_source(home, source, work/'GAME.OBJ', list(_OPTIONS),30,include_dirs=[headers])
    module = Module.parse((work/'GAME.OBJ').read_bytes())
    image = LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
    data_number, identity = _validate_game_scope(module)
    prefix = check_code_prefix(module,image)
    intervals = check_intervals(module,image,{'inittimer_':(480,48)}, {})
    interval = intervals[0]
    if (interval['comparison']['verified_fixups'] != 4 or
            tuple(interval['bindings']['_TimerPtr']) != (3,30056)):
        raise ValueError('changed independently measured GAME TimerPtr operand')
    timer = interval['bindings']['_TimerPtr']
    origin = (timer[0], timer[1]-module.publics['_TimerPtr'][1])
    projection = check_initialized_data(module,image,{'_cameradist':origin})
    assert_contributions(projection,dict(initialized_bytes=864,zero_fill_bytes=0,verified_fixups=0))
    raw = (ROOT/'toolchains/watcom-10.5/LIB386/math387r.lib').read_bytes()
    member = select_member(raw,read_archive(raw),_MATHERR)
    math = Module.parse(raw[member['offset']:member['end']])
    inferred = infer_bindings(math,image,1,625264)
    nomination = nominate_matherr_initializer(math,image,inferred)
    inferred['symbols'][nomination['symbol']] = nomination['value']
    proof = native_gate(math,image,inferred,
        dict(initialized_bytes=295,zero_fill_bytes=0,verified_fixups=19),group_frames={1:(3,0)})
    const = [row for row in proof['segments'] if row['symbol']=='CONST2']
    if (len(const)!=1 or const[0]['target_object']!=origin[0] or
            const[0]['target_offset']+const[0]['compared_bytes']!=origin[1]):
        raise ValueError('complete native matherr CONST2 boundary contradicts GAME origin')
    link = (ROOT/'dukenukem3d/source/MAKEFILE.LNK').read_text()
    first = next((line for line in link.splitlines() if line.startswith('file ')), '')
    if not first or first.split()[1].split(',')[0] != 'game':
        raise ValueError('released first GAME file order changed')
    # Freshness is not cached. Do not issue if any dependency changed while DOS
    # ran or while native witnesses were checked, even when target SHA stayed.
    if _validate_inputs(home) != inputs:
        raise ValueError('logical origin inputs changed during replay')
    if _sha(Path(emulator)) != emulator_sha256:
        raise ValueError('logical origin native emulator identity changed during replay')
    evidence = dict(policy=inputs['policy'], policy_sha256=_LOADED_POLICY_SHA256,
        input_manifest_sha256=_INPUTS_SHA256, pinned_inputs=inputs['sha256'],
        options=list(_OPTIONS), emulator_sha256=emulator_sha256, identity=identity, origin=origin,
        GAME_CODE_prefix=prefix, GAME_inittimer=interval,
        GAME_complete_DATA=projection, matherr_member=_MATHERR,
        matherr_complete_verification=proof, matherr_pointer_nomination=nomination,
        released_first_file='game', source_credit=0)
    (work/'witness.json').write_text(json.dumps(evidence,sort_keys=True,indent=2)+'\n')
    receipts = dict(policy='per-run native producer receipts; not context authority',
        generated_sha256={p.relative_to(work).as_posix():_sha(p)
                          for p in sorted(work.rglob('*')) if p.is_file()},
        compiler_sha256=_sha(home/'BINB/wcc386.exe'),options=list(_OPTIONS),
        emulator_path=str(Path(emulator).resolve()),emulator_sha256=emulator_sha256)
    (work/'receipts.json').write_text(json.dumps(receipts,sort_keys=True,indent=2)+'\n')
    return _issue_verified_origin(image,origin,identity,evidence)
