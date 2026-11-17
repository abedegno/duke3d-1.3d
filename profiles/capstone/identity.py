"""Closed Capstone5.0.6 distribution identity, local staging only."""
from pathlib import Path
import hashlib,importlib,json,sys,os
ROOT=Path(__file__).resolve().parents[2]
FILES_SHA256='bd7af521e61bfca5e482552a2e5353ca9355ff4a23992593d9eafd3486d64a1d'
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def files():
    p=ROOT/'profiles/capstone/files.json'
    if digest(p)!=FILES_SHA256:raise ValueError('changed decoder manifest')
    return json.loads(p.read_text())
def checked_home(home):
    home=Path(home).resolve();expected=files()
    if not home.is_dir():raise ValueError('decoder home missing; use profiles/capstone/setup.py')
    paths=list(home.rglob('*'))
    if any(p.is_symlink()for p in paths):raise ValueError('decoder home symlink')
    if {p.relative_to(home).as_posix()for p in paths if p.is_file()}!=set(expected)|{'setup.json'}:raise ValueError('decoder home file set')
    for n,h in expected.items():
        if digest(home/n)!=h:raise ValueError('changed decoder dependency '+n)
    r=json.loads((home/'setup.json').read_text())
    if r!={'manifest_sha256':FILES_SHA256,'files_sha256':expected,'distribution':'capstone5.0.6 py3-none-macosx_11_0_arm64'}:raise ValueError('decoder setup provenance')
    return {**expected,'setup.json':digest(home/'setup.json')}
def load(home):
    home=Path(home).resolve();checked_home(home);sys.dont_write_bytecode=True
    if 'LIBCAPSTONE_PATH'in os.environ:raise ValueError('decoder environment override unsupported')
    existing=sys.modules.get('capstone')
    if existing is not None and Path(existing.__file__).resolve()!=home/'capstone/__init__.py':raise ValueError('foreign decoder already imported')
    sys.path.insert(0,str(home));m=importlib.import_module('capstone')
    if Path(m.__file__).resolve()!=home/'capstone/__init__.py' or m.__version__!='5.0.6':raise ValueError('decoder import identity')
    if Path(m._cs._name).resolve()!=home/'capstone/lib/libcapstone.dylib':raise ValueError('foreign native decoder library')
    expected=files()
    for name,loaded in tuple(sys.modules.items()):
        if name=='capstone'or name.startswith('capstone.'):
            path=Path(loaded.__file__).resolve()
            if not path.is_relative_to(home)or path.relative_to(home).as_posix()not in expected:raise ValueError('foreign decoder submodule')
    checked_home(home);return m
