#!/usr/bin/env python3
"""Root-relative source-built ELF/fork setup; no global install or binary download.
Archive validation and the exact source-level patch precede atomic publication.
The reviewed already-built tools can be reused; full rebuild recipe is README.md.
"""
from pathlib import Path
import sys,hashlib,io,json,shutil,tempfile,tarfile,zipfile,argparse
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from profiles.gnu_elf_omf_imports.identity import profile,digest,checked_home,PROFILE_SHA256
from profiles.gnu_elf_omf_imports.apply_fork import apply

def stage(home,binutils_archive,objconv_archive,assembler,converter):
 spec=profile();paths=[Path(p).resolve()for p in[binutils_archive,objconv_archive,assembler,converter]]
 before={str(p):digest(p)for p in [*paths,Path(__file__),ROOT/'profiles/gnu_elf_omf_imports/identity.py',ROOT/'profiles/gnu_elf_omf_imports/apply_fork.py',ROOT/'profiles/gnu_elf_omf_imports/profile.json',ROOT/'profiles/gnu_elf_omf_imports/defined-global.patch',ROOT/'profiles/gnu_elf_omf_imports/unused-imports.patch']};expected=[spec['source_archives']['binutils']['sha256'],spec['source_archives']['objconv']['sha256'],spec['tools']['bin/as-new']['sha256'],spec['tools']['bin/objconv']['sha256']]
 if[digest(p)for p in paths]!=expected:raise ValueError('changed source archive or approved source-built ELF/fork tool')
 home=Path(home).resolve()
 if home.exists():raise ValueError('toolhome exists; use a fresh local home')
 home.parent.mkdir(parents=True,exist_ok=True);tmp=Path(tempfile.mkdtemp(prefix='elf-omf-setup-',dir=home.parent))
 try:
  with tarfile.open(paths[0])as tar:license_bytes=tar.extractfile('binutils-2.44/COPYING3').read()
  with zipfile.ZipFile(paths[1])as outer:source=outer.read('source.zip');manual=outer.read('objconv-instructions.pdf')
  if hashlib.sha256(source).hexdigest()!=spec['source_archives']['objconv']['source_zip_sha256']:raise ValueError('nested source.zip identity')
  with zipfile.ZipFile(io.BytesIO(source))as inner:
   names=inner.namelist();original=spec['converter_fork']['original_source_files']
   if set(names)!=set(original)or len(names)!=len(original):raise ValueError('exact42-file original source set')
   for n in names:
    data=inner.read(n)
    if Path(n).name!=n or hashlib.sha256(data).hexdigest()!=original[n]:raise ValueError('original source file identity/path')
    p=tmp/'sources/objconv'/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
  apply(tmp/'sources/objconv')
  if{p.name:digest(p)for p in(tmp/'sources/objconv').iterdir()}!=spec['converter_fork']['derived_source_files']:raise ValueError('derived source-level fork graph')
  files={'bin/as-new':paths[2].read_bytes(),'bin/objconv':paths[3].read_bytes(),'notices/GNU-COPYING3':license_bytes,'notices/objconv-instructions.pdf':manual,'sources/defined-global.patch':(ROOT/'profiles/gnu_elf_omf_imports/defined-global.patch').read_bytes(),'sources/unused-imports.patch':(ROOT/'profiles/gnu_elf_omf_imports/unused-imports.patch').read_bytes()}
  for n,data in files.items():p=tmp/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
  for n in ['bin/as-new','bin/objconv']:(tmp/n).chmod(0o755)
  all_={p.relative_to(tmp).as_posix():digest(p)for p in tmp.rglob('*')if p.is_file()};receipt={'profile_sha256':PROFILE_SHA256,'source_archives':spec['source_archives'],'files_sha256':all_,'method':'Reviewed source-built binaries; exact original42source archive + separately applied and retained three-file cumulative source fork455+482; no binary/object patch/global install'};(tmp/'setup.json').write_text(json.dumps(receipt,indent=2)+'\n');checked_home(tmp)
  if any(digest(p)!=h for p,h in before.items()):raise ValueError('setup input changed during stage')
  tmp.rename(home)
 except Exception:shutil.rmtree(tmp);raise
 return checked_home(home)
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for n in['home','binutils-archive','objconv-archive','assembler','converter']:p.add_argument('--'+n,type=Path,required=True)
 a=p.parse_args();print(json.dumps(stage(a.home,a.binutils_archive,a.objconv_archive,a.assembler,a.converter),indent=2))
