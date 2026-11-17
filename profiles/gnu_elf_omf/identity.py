"""Closed separate ELF toolhome; existing GNU COFF profile is untouched."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[2]
PROFILE_SHA256='36c67429e16ae92c1ff84a22699bc65edb5c5f441187261c54e6ceb523b23594'
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def profile():
 p=ROOT/'profiles/gnu_elf_omf/profile.json'
 if digest(p)!=PROFILE_SHA256:raise ValueError('changed ELF tool profile')
 return json.loads(p.read_text())
def expected_files():
 s=profile();r={n:v['sha256']for n,v in s['tools'].items()};r.update({'sources/objconv/'+n:h for n,h in s['converter_fork']['derived_source_files'].items()});r.update({'notices/GNU-COPYING3':'8ceb4b9ee5adedde47b31e975c1d90c73ad27b6b165a1dcd80c7c545eb65b903','notices/objconv-instructions.pdf':'3ea9ff2feef7b0b0cbeca7a1d4330383a6ddb41b323c5a991922aa24386743d3','sources/defined-global.patch':s['converter_fork']['patch_sha256']});return r
def checked_home(home):
 home=Path(home).resolve();expected=expected_files()
 if not home.is_dir():raise ValueError('missing ELF home; use profiles/gnu_elf_omf/setup.py')
 paths=list(home.rglob('*'))
 if any(p.is_symlink()for p in paths):raise ValueError('ELF home symlink')
 if{p.relative_to(home).as_posix()for p in paths if p.is_file()}!=set(expected)|{'setup.json'}:raise ValueError('ELF home file set changed')
 for n,h in expected.items():
  if digest(home/n)!=h:raise ValueError('changed ELF tool/source/notice: '+n)
 j=json.loads((home/'setup.json').read_text())
 if j.get('profile_sha256')!=PROFILE_SHA256 or j.get('files_sha256')!=expected or j.get('source_archives')!=profile()['source_archives']:raise ValueError('ELF setup receipt changed')
 return {**expected,'setup.json':digest(home/'setup.json')}
