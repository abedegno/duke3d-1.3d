"""Source-only DEBUG ELF producer preserving declared DOS section alignment.

The existing COFF producer remains unchanged. No original object or executable
is opened here. Target comparison belongs to the separate build observer.
"""
from pathlib import Path
from dataclasses import asdict
import argparse
import hashlib
import importlib.util
import json
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT / 'profiles/watcom/tools')]
from omf32 import Module
from profiles.gnu_elf_omf.identity import checked_home, profile
from profiles.gnu_elf_omf.elf32 import elf

MODEL = 'candidates/mact_debug_elf.json'
SOURCE = 'src/mact/debug.asm'
CONTRACT = 'src/mact/debug-elf/contract.py'
CHANGES = {b'.section _TEXT,"xr0"': b'.section _TEXT,"ax",@progbits\n.p2align 4',
 b'.section CONST,"dw0"': b'.section CONST,"aw",@progbits\n.p2align 2',
 b'.section CONST2,"dw0"': b'.section CONST2,"aw",@progbits\n.p2align 2',
 b'.section _DATA,"dw0"': b'.section _DATA,"aw",@progbits\n.p2align 2',
 b'.section _BSS,"b0"': b'.section _BSS,"aw",@nobits\n.p2align 4'}
STAGE = {'authored/DEBUG.S': 'src/mact/debug.asm',
 'authored/debug_counterpart.c': 'src/mact/debug/debug_counterpart.c',
 'authored/GPL-2.0.txt': 'src/mact/debug/GPL-2.0.txt',
 'elf_contract.py': 'src/mact/debug-elf/contract.py',
 'SOURCE_NOTES.md': 'src/mact/debug-elf/README.md'}

def need(value, message):
    if not value:
        raise ValueError(message)

def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def translate(source):
    for old, new in CHANGES.items():
        need(source.splitlines().count(old) == 1 and new not in source,
             'DEBUG section declaration count or dialect changed')
        source = source.replace(old, new)
    return source

def inverse(source):
    for old, new in CHANGES.items():
        need(source.count(new) == 1, 'DEBUG ELF section declaration count changed')
        source = source.replace(new, old)
    return source

def inventory(module):
    return json.loads(json.dumps({
        'segments': [{'name': s.name, 'class': s.class_name, 'size': s.size,
                      'attributes': s.attributes, 'access': s.access} for s in module.segments],
        'publics': module.publics, 'externals': module.externals,
        'groups': module.groups, 'fixups': [asdict(f) for f in module.fixups]}))

def build_source(home, build):
    home = Path(home).resolve()
    tools = checked_home(home)
    model_bytes = (ROOT / MODEL).read_bytes()
    model_sha256 = hashlib.sha256(model_bytes).hexdigest()
    spec = json.loads(model_bytes)
    need(set(spec['inputs_sha256']) == set(STAGE.values()), 'DEBUG source file set changed')
    need(spec['name'] == 'mact_debug_elf_source' and spec['source'] == SOURCE, 'DEBUG source model changed')
    for name, expected in spec['inputs_sha256'].items():
        need(digest(ROOT / name) == expected, 'DEBUG source/contract changed: ' + name)
    helper_names = [MODEL, *STAGE.values(), 'profiles/gnu_elf_omf/identity.py',
                    'profiles/gnu_elf_omf/profile.json', 'profiles/gnu_elf_omf/elf32.py',
                    'profiles/watcom/tools/omf32.py']
    # Retain the model's validated source/contract hashes across staging.
    pins = {str(ROOT / name): model_sha256 if name == MODEL else
            spec['inputs_sha256'][name] if name in spec['inputs_sha256'] else digest(ROOT / name)
            for name in helper_names}
    need(digest(ROOT / MODEL) == model_sha256, 'Source model changed after parse')
    pins.update({str(Path(__file__).resolve()): digest(__file__),
                 str(Path(sys.executable).resolve()): digest(Path(sys.executable).resolve())})
    pins.update({str(home / name): value for name, value in tools.items()})
    parent = Path(build).resolve()
    parent.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix='mact-debug-elf-', dir=parent))
    stage = work / 'source-only'
    stage.mkdir()
    for target, name in STAGE.items():
        destination = stage / target
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / name, destination)
        need(digest(destination) == pins[str(ROOT / name)], 'Source stage changed')
    source = (stage / 'authored/DEBUG.S').read_bytes()
    translated = translate(source)
    need(inverse(translated) == source, 'DEBUG instructions/data changed by section translation')
    (stage / 'DEBUG.S').write_bytes(translated)
    staged = {str(p): digest(p) for p in stage.rglob('*') if p.is_file()}
    generated = {}
    def unchanged():
        need({str(p) for p in stage.rglob('*') if p.is_file()} == set(staged), 'DEBUG stage file set changed')
        for path, expected in {**pins, **staged, **generated}.items():
            need(Path(path).is_file() and digest(path) == expected, 'DEBUG input/stage changed: ' + path)
        checked_home(home)
    commands = []
    def run(args, log):
        unchanged()
        commands.append(args)
        proc = subprocess.run(args, capture_output=True, text=True, timeout=60)
        (work / log).write_text(proc.stdout + proc.stderr)
        need(proc.returncode == 0 and not proc.stderr and 'warning' not in proc.stdout.lower(),
             'DEBUG native tool failed: ' + log)
        unchanged()
    options = profile()['options']
    run([str(home / 'bin/as-new'), *options['assembler'], '-al=' + str(work / 'DEBUG.LST'),
         '-o', str(work / 'DEBUG.ELF'), str(stage / 'DEBUG.S')], 'GAS.LOG')
    need(not (work / 'GAS.LOG').read_text(), 'DEBUG assembler emitted a diagnostic')
    generated.update({str(work / name): digest(work / name)
                      for name in ['DEBUG.ELF', 'DEBUG.LST', 'GAS.LOG']})
    schema = importlib.util.spec_from_file_location('_debug_elf_contract', stage / 'elf_contract.py')
    guard = importlib.util.module_from_spec(schema)
    # Avoid runtime cache files in the closed stage.
    exec(compile((stage / 'elf_contract.py').read_bytes(), str(stage / 'elf_contract.py'), 'exec'), guard.__dict__)
    parsed = elf(work / 'DEBUG.ELF')
    proof = guard.check((work / 'DEBUG.ELF').read_bytes(), parsed,
                        translated.decode(), (work / 'DEBUG.LST').read_text())
    (work / 'preflight.json').write_text(json.dumps(proof, indent=2) + '\n')
    generated[str(work / 'preflight.json')] = digest(work / 'preflight.json')
    run([str(home / 'bin/objconv'), *options['converter'],
         str(work / 'DEBUG.ELF'), str(work / 'DEBUG.OBJ')], 'CONVERT.LOG')
    native_path = work / 'DEBUG.OBJ'
    native_bytes = native_path.read_bytes()
    native_sha256 = hashlib.sha256(native_bytes).hexdigest()
    generated[str(native_path)] = native_sha256
    module = Module.parse(native_bytes)
    need(inventory(module) == spec['native_inventory'], 'DEBUG complete native inventory changed')
    need(not (module.comments or module.default_libraries or module.line_numbers or
              module.local_publics or module.local_externals or module.source_records or
              module.thread_definitions or module.code_data_ranges or module.dosseg_directives or
              module.far_call_optimization_segments or module.format_source is not None),
         'DEBUG unsupported native metadata')
    unchanged()
    outputs = {str(p): digest(p) for p in work.iterdir() if p.is_file()}
    result = {'source_only': True, 'original_or_target_read_during_production': False,
              'object': str(work / 'DEBUG.OBJ'), 'object_sha256': native_sha256,
              'source_sha256': digest(ROOT / SOURCE), 'translated_sha256': digest(stage / 'DEBUG.S'),
              'native_fields': len(module.fixups),
              'segments': [[s.name, s.size, s.attributes] for s in module.segments],
              'inputs_sha256': pins, 'staged_sha256': staged, 'outputs_sha256': outputs,
              'commands': commands, 'source_credit': 0, 'full_executable_identical': False}
    # Bind publication to the native snapshot actually parsed above.
    unchanged()
    need(all(digest(path) == expected for path, expected in outputs.items()),
         'Generated output changed before publication')
    receipt_path = work / 'source-build.json'
    receipt_path.write_text(json.dumps(result, indent=2) + '\n')
    try:
        unchanged()
        need(all(digest(path) == expected for path, expected in outputs.items()),
             'Generated output changed during publication')
    except Exception:
        receipt_path.unlink()
        raise
    return result

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home', type=Path, default=ROOT / 'toolchains/gnu-elf-omf')
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--report', type=Path, required=True)
    args = parser.parse_args()
    result = build_source(args.home, args.build)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(result, indent=2) + '\n')
    print('Built source-only DEBUG ELF:', result['object_sha256'])
