"""Closed normal Native-layout source-built toolhome; no other profile/default changes."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[2]
PROFILE_SHA256='113e0be4d509f4bd755663d0181947e88726048f5958a62f5a2a984ac574c7c3'
def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def manifest(path,expected,label):
    raw=Path(path).read_bytes()
    if hashlib.sha256(raw).hexdigest()!=expected:raise ValueError(label)
    return json.loads(raw)
def profile():
    path=ROOT/'profiles/gnu_elf_omf_layouts/profile.json'
    return manifest(path,PROFILE_SHA256,'Native-layout tool profile identity')
def imports_profile(spec):
    return manifest(ROOT/'profiles/gnu_elf_omf_imports/profile.json',spec['base_imports_profile_sha256'],'Native-layout base imports profile')
def expected_files():
    spec=profile();files={n:v['sha256']for n,v in spec['tools'].items()};files.update({'sources/objconv/'+n:h for n,h in spec['derived_source_files'].items()})
    files.update({'notices/GNU-COPYING3':'8ceb4b9ee5adedde47b31e975c1d90c73ad27b6b165a1dcd80c7c545eb65b903','notices/objconv-instructions.pdf':'3ea9ff2feef7b0b0cbeca7a1d4330383a6ddb41b323c5a991922aa24386743d3'})
    base=imports_profile(spec)
    files.update({'sources/defined-global.patch':base['converter_fork']['patch_sha256'],'sources/unused-imports.patch':base['converter_fork']['unused_imports_patch_sha256']});files.update({'sources/'+n:h for n,h in spec['metadata_patches'].items()});return files

def checked_home(home):
    home=Path(home).resolve();expected=expected_files()
    if not home.is_dir():raise ValueError('missing Native-layout toolhome; use profiles/gnu_elf_omf_layouts/setup.py')
    paths=list(home.rglob('*'))
    if any(p.is_symlink()for p in paths):raise ValueError('Native-layout toolhome symlink')
    if{p.relative_to(home).as_posix()for p in paths if p.is_file()}!=set(expected)|{'setup.json'}:raise ValueError('Native-layout complete toolhome file set')
    if any(digest(home/p)!=h for p,h in expected.items()):raise ValueError('Native-layout changed tool/source/notice')
    receipt_path=home/'setup.json';receipt_raw=receipt_path.read_bytes();receipt_sha=hashlib.sha256(receipt_raw).hexdigest();receipt=json.loads(receipt_raw)
    if receipt.get('profile_sha256')!=PROFILE_SHA256 or receipt.get('files_sha256')!=expected or receipt.get('source_archives')!=profile()['source_archives']:raise ValueError('Native-layout toolhome setup receipt')
    if digest(receipt_path)!=receipt_sha:raise ValueError('Native-layout setup receipt changed after validation')
    return{**expected,'setup.json':receipt_sha}
