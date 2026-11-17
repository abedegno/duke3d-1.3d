"""Exact unmodified compiler-tree identity; includes every mounted file."""
from pathlib import Path
import hashlib
import json
ROOT=Path(__file__).resolve().parents[2]
MANIFEST_SHA256='17d1297e675cbffa8ae79f8397ec94c5cd193330410bda11180fce6471cee426'

def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def manifest():
    path=ROOT/'profiles/highc/compiler.json'
    if digest(path)!=MANIFEST_SHA256:raise ValueError('changed High C compiler profile manifest')
    value=json.loads(path.read_text())
    if len(value['files'])!=384:raise ValueError('incomplete High C profile')
    return value

def checked_home(home):
    home=Path(home).resolve();profile=manifest();expected={x['path']:x for x in profile['files']}
    if not home.is_dir():raise ValueError('High C compiler home missing')
    paths=list(home.rglob('*'))
    if any(p.is_symlink()for p in paths):raise ValueError('High C compiler tree contains symlink')
    actual={p.relative_to(home).as_posix()for p in paths if p.is_file()}
    if actual!=set(expected):raise ValueError('High C compiler file set changed (missing/extra; RCPP is excluded)')
    hashes={}
    for name,entry in expected.items():
        path=home/name
        if path.stat().st_size!=entry['size'] or digest(path)!=entry['sha256']:
            raise ValueError('High C compiler file identity changed: '+name)
        hashes[name]=entry['sha256']
    return hashes
