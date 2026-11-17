"""Pinned unmodified source-built native tools; no arbitrary local binaries."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[2]
PROFILE_SHA256='a0aa96424edcfac954818f79144479a0c92aeb98e3a386330d129f6fb565a341'
SOURCES_SHA256='38d6e25f9256a54d407c2960fbe2e05358b6a60f778aa22e05bdc6e2f5b51e23'
def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def profile():
 p=ROOT/'profiles/gnu_omf/profile.json'
 if digest(p)!=PROFILE_SHA256:raise ValueError('changed GNU/objconv profile identity')
 return json.loads(p.read_text())
def objconv_sources():
 p=ROOT/'profiles/gnu_omf/objconv-source-files.json'
 if digest(p)!=SOURCES_SHA256:raise ValueError('changed objconv source manifest')
 return json.loads(p.read_text())
def checked_home(home):
 home=Path(home).resolve();spec=profile();expected={p:v['sha256']for p,v in spec['tools'].items()}
 expected.update({'assets/AWE32P10.TXT':spec['primary_asset']['sha256'],'notices/GNU-COPYING3':'8ceb4b9ee5adedde47b31e975c1d90c73ad27b6b165a1dcd80c7c545eb65b903','notices/objconv-instructions.pdf':'3ea9ff2feef7b0b0cbeca7a1d4330383a6ddb41b323c5a991922aa24386743d3'})
 if not home.is_dir():raise ValueError('GNU/objconv home missing; use profiles/gnu_omf/setup.py')
 paths=list(home.rglob('*'))
 if any(p.is_symlink()for p in paths):raise ValueError('GNU/objconv home contains symlink')
 if{p.relative_to(home).as_posix()for p in paths if p.is_file()}!=set(expected)|{'setup.json'}:raise ValueError('GNU/objconv home file set changed')
 for p,h in expected.items():
  if digest(home/p)!=h:raise ValueError('GNU/objconv tool/primary identity changed: '+p)
 receipt=json.loads((home/'setup.json').read_text())
 if(receipt['profile_sha256']!=PROFILE_SHA256 or receipt['source_archives']!=spec['source_archives']or receipt['objconv_source_files_sha256']!=objconv_sources()or receipt['files_sha256']!=expected):raise ValueError('GNU/objconv setup provenance changed')
 return {**expected,'setup.json':digest(home/'setup.json')}
