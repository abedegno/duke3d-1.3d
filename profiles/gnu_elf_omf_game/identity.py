"""Closed normal GAME source-built toolhome; no other profile/default changes."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[2]
PROFILE_SHA256='239d10c6a10169ceddb368a2885442f223f7b47bb9000a476cade3d16d3d3532'
def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def profile():
    path=ROOT/'profiles/gnu_elf_omf_game/profile.json'
    if digest(path)!=PROFILE_SHA256:raise ValueError('GAME tool profile identity')
    return json.loads(path.read_text())
def expected_files():
    spec=profile();files={n:v['sha256']for n,v in spec['tools'].items()};files.update({'sources/objconv/'+n:h for n,h in spec['derived_source_files'].items()})
    files.update({'notices/GNU-COPYING3':'8ceb4b9ee5adedde47b31e975c1d90c73ad27b6b165a1dcd80c7c545eb65b903','notices/objconv-instructions.pdf':'3ea9ff2feef7b0b0cbeca7a1d4330383a6ddb41b323c5a991922aa24386743d3'})
    base=json.loads((ROOT/'profiles/gnu_elf_omf_imports/profile.json').read_text())
    if digest(ROOT/'profiles/gnu_elf_omf_imports/profile.json')!=spec['base_imports_profile_sha256']:raise ValueError('GAME base imports profile')
    files.update({'sources/defined-global.patch':base['converter_fork']['patch_sha256'],'sources/unused-imports.patch':base['converter_fork']['unused_imports_patch_sha256']});files.update({'sources/'+n:h for n,h in spec['metadata_patches'].items()});return files

def checked_home(home):
    home=Path(home).resolve();expected=expected_files()
    if not home.is_dir():raise ValueError('missing GAME toolhome; use profiles/gnu_elf_omf_game/setup.py')
    paths=list(home.rglob('*'))
    if any(p.is_symlink()for p in paths):raise ValueError('GAME toolhome symlink')
    if{p.relative_to(home).as_posix()for p in paths if p.is_file()}!=set(expected)|{'setup.json'}:raise ValueError('GAME complete toolhome file set')
    if any(digest(home/p)!=h for p,h in expected.items()):raise ValueError('GAME changed tool/source/notice')
    receipt=json.loads((home/'setup.json').read_text())
    if receipt.get('profile_sha256')!=PROFILE_SHA256 or receipt.get('files_sha256')!=expected or receipt.get('source_archives')!=profile()['source_archives']:raise ValueError('GAME toolhome setup receipt')
    return{**expected,'setup.json':digest(home/'setup.json')}
