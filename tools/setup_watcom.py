"""Verify and unpack private compiler media; never run an installer.

Download the archive URL from `--list` yourself, then pass it to this tool.
Checksums are cross-checked against second-impressions/watcom-compilers
scripts/SHA256SUMS; the containing media remain proprietary inputs.
"""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import sys
import tempfile
import zipfile

BASE='https://archive.org/download/watcom-c-cpp-compilers-collection/'
CANDIDATES={
    '10.0-ga': {
        'url':BASE+'watcom-10.0/discmaster/Sybase%20-%20Watcom%20C%2B%2B%2010.0.zip',
        'sha256':'8e5869e78cda5c42b1fd5aa0675abe52ed03217b4f835bfe4a9dc133d26158aa',
    },
    '10.0a': {
        'url':BASE+'watcom-10.0/WATCOM_C10A.ISO',
        'sha256':'f51ed9358e7eaf6a0d292268bbbc15832530489dd8239a98f6938c244f1736fc',
        'user_reference':'https://winworldpc.com/product/watcom-c-c/100',
    },
    '10.0b': {
        'url':BASE+'watcom-10.0/patches/c_b.zip',
        'sha256':'c1e9e1d7f44b8a828fc00fad71b3af8d64880e68bc12efb579c1efd11254ceb3',
        'base_compiler_sha256':'c3666de94f6fa6800f452dae8acf45505ecdb62f0ade2cc27cc86c2d9e8e2b6b',
        'compiler_sha256':'2b6672b7cb109452a31cb7fd6bf6776f518f43466f66dc3efd8365708fd243c6',
    },
    '10.5': {
        'url':BASE+'watcom-10.5/Watcom_C%2B%2B_10.5.iso',
        'sha256':'e7d8275b71f05c782b69918365c770716bde8f56a08fcdc62fe23dc43d808b9b',
    },
}
COMPONENTS={'BIN','BINB','BINW','H','LIB386'}
SUPPORT_COMMIT='973a92211701437d881d513a62c2ca80e7a79db1'


def file_hash(path: Path) -> str:
    with path.open('rb') as stream:
        return hashlib.file_digest(stream,'sha256').hexdigest()


def extract_zip_tree(archive: Path, home: Path) -> None:
    with zipfile.ZipFile(archive) as z:
        entries=[]
        for info in z.infolist():
            path=PurePosixPath(info.filename)
            if path.is_absolute() or '..' in path.parts or '\\' in info.filename:
                raise ValueError('unsafe archive path')
            if not path.parts or path.parts[0].upper() not in COMPONENTS or info.is_dir():
                continue
            # Uppercase directory names and lowercase file names are stable
            # across the differently cased GA and A-level media.
            dest=home.joinpath(*(s.upper() for s in path.parts[:-1]),path.name.lower())
            entries.append((info,dest))
        for info,dest in entries:
            dest.parent.mkdir(parents=True,exist_ok=True)
            with z.open(info) as src, dest.open('xb') as out:
                shutil.copyfileobj(src,out)


def install(version: str, archive: Path, destination: Path, support: Path | None=None,
            *, base: Path | None=None) -> dict:
    candidate=CANDIDATES[version]
    actual=file_hash(archive)
    if actual!=candidate['sha256']:
        raise ValueError(f'Archive SHA-256 mismatch: {actual}')
    if destination.exists():
        raise FileExistsError(f'Compiler home already exists: {destination}')
    if version=='10.0b':
        if base is None or not (base/'BINB/wcc386.exe').is_file():
            raise ValueError('10.0b requires a verified 10.0a base compiler')
        if file_hash(base/'BINB/wcc386.exe')!=candidate['base_compiler_sha256']:
            raise ValueError('10.0a base compiler SHA-256 mismatch')
        if destination.resolve().is_relative_to(base.resolve()):
            raise ValueError('10.0b destination must be outside the base compiler home')
    destination.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='watcom-',dir=destination.parent) as temporary:
        stage=Path(temporary)
        home=stage/'home'
        if version=='10.0b':
            # Patch only private copies. The original base is never mounted
            # into the emulator, and no destination is published on failure.
            shutil.copytree(base,home)
            patch_work=stage/'patch'
            patch_work.mkdir()
            subprocess.run(['7z','e','-y','-o'+str(patch_work),str(archive.resolve()),
                            'PTCH23.B'],check=True,capture_output=True)
            shutil.copyfile(home/'BINB/wcc386.exe',patch_work/'wcc386.exe')
            sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'profiles/watcom/tools'))
            from runner import run_batch
            run_batch(home,patch_work,
                      '@echo off\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
                      'bpatch -b -p PTCH23.B > PATCH.LOG\r\n',30)
            patched=patch_work/'wcc386.exe'
            if file_hash(patched)!=candidate['compiler_sha256']:
                raise ValueError('10.0b patched compiler SHA-256 mismatch')
            shutil.copyfile(patched,home/'BINB/wcc386.exe')
        elif version=='10.0-ga':
            extract_zip_tree(archive,home)
        else:
            if version=='10.5':
                if support is None:
                    support=Path(__file__).resolve().parents[1]/'toolchains/support/watcom-compilers'
                commit=subprocess.check_output(['git','-C',str(support),'rev-parse','HEAD'],text=True).strip()
                if commit!=SUPPORT_COMMIT:
                    raise ValueError('unexpected preservation unpacker commit')
                subprocess.run(['bsdtar','-xf',str(archive.resolve()),'-C',str(stage),'DISKIMGS'],check=True)
                subprocess.run([sys.executable,str(support/'scripts/lib/setup_inf_manifest.py'),
                    'unpack',str(stage/'DISKIMGS/DISK01/SETUP.INF'),str(stage/'DISKIMGS'),
                    str(stage/'WATCOM')],check=True)
            else:
                subprocess.run(['bsdtar','-xf',str(archive.resolve()),'-C',str(stage),
                                *('WATCOM/'+s for s in sorted(COMPONENTS) if s!='BINW')],check=True)
            home=stage/'WATCOM'
            # Normalize case in a separate tree; avoid case-only renames on
            # filesystems that regard upper/lowercase paths as identical.
            normalized=stage/'home'
            for path in home.rglob('*'):
                if path.is_file():
                    relative=path.relative_to(home)
                    if relative.parts[0].upper() not in COMPONENTS:
                        continue
                    dest=normalized.joinpath(*(s.upper() for s in relative.parts[:-1]),relative.name.lower())
                    dest.parent.mkdir(parents=True,exist_ok=True)
                    shutil.copyfile(path,dest)
            home=normalized
        required=(['BINW/wcc386.exe','BINW/wasm.exe','BINW/wlink.exe','BINW/dos4gw.exe']
                  if version=='10.5' else ['BINB/wcc386.exe','BINB/wasm.exe','BIN/wlink.exe','BIN/dos4gw.exe'])
        files={p:{'size':(home/p).stat().st_size,'sha256':file_hash(home/p)} for p in required}
        home.rename(destination)
    result=dict(version=version,archive_sha256=actual,home=str(destination),
                source=candidate,tools=files)
    if version=='10.0b':
        result.update(base_compiler_sha256=candidate['base_compiler_sha256'],
                      patch_scope='wcc386 compiler only; other tools and headers inherited from 10.0a')
    return result


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--list',action='store_true')
    p.add_argument('--version',choices=CANDIDATES)
    p.add_argument('--archive',type=Path)
    p.add_argument('--destination',type=Path)
    p.add_argument('--manifest',type=Path)
    p.add_argument('--support',type=Path)
    p.add_argument('--base',type=Path,help='verified 10.0a home for the 10.0b compiler patch')
    a=p.parse_args()
    if a.list:
        print(json.dumps(CANDIDATES,indent=2))
    else:
        if not all((a.version,a.archive,a.destination)):
            p.error('--version, --archive and --destination are required')
        result=install(a.version,a.archive,a.destination,a.support,base=a.base)
        if a.manifest:
            a.manifest.parent.mkdir(parents=True,exist_ok=True)
            a.manifest.write_text(json.dumps(result,indent=2)+'\n')
        print(json.dumps(result,indent=2))
