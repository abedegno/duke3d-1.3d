#!/usr/bin/env python3
"""Stage the exact approved source-built tools and primary asset locally.

No global install, binary download, source patch or tool execution. Public source
build commands are in README.md. Already-built binaries must match the independently
reviewed195/196 identities. Only setup reads the public distribution archives.
"""
from pathlib import Path
import argparse,hashlib,io,json,os,shutil,sys,tarfile,tempfile,urllib.request,zipfile
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from profiles.gnu_omf.identity import profile,objconv_sources,checked_home,digest,PROFILE_SHA256

def stage(home,binutils_archive,objconv_archive,primary_archive,assembler,converter):
 spec=profile();paths=[Path(p).resolve()for p in[binutils_archive,objconv_archive,primary_archive,assembler,converter]]
 expected=[spec['source_archives']['binutils']['sha256'],spec['source_archives']['objconv']['sha256'],spec['primary_asset']['archive_sha256'],spec['tools']['bin/as-new']['sha256'],spec['tools']['bin/objconv']['sha256']]
 before={str(p):digest(p)for p in paths}
 if list(before.values())!=expected:raise ValueError('changed source archive, primary asset or approved built tool')
 with tarfile.open(paths[0])as archive:license_bytes=archive.extractfile('binutils-2.44/COPYING3').read()
 with zipfile.ZipFile(paths[1])as outer:
  source=outer.read('source.zip');manual=outer.read('objconv-instructions.pdf')
 if hashlib.sha256(source).hexdigest()!=spec['source_archives']['objconv']['source_zip_sha256']:raise ValueError('changed nested objconv source')
 with zipfile.ZipFile(io.BytesIO(source))as inner:
  actual={n:hashlib.sha256(inner.read(n)).hexdigest()for n in inner.namelist()}
 if actual!=objconv_sources():raise ValueError('unmodified42-file objconv source graph differs')
 with zipfile.ZipFile(paths[2])as archive:
  members=[n for n in archive.namelist()if Path(n).name.upper()=='AWE32P10.TXT']
  if len(members)!=1:raise ValueError('ambiguous primary text member')
  primary=archive.read(members[0])
 if hashlib.sha256(primary).hexdigest()!=spec['primary_asset']['sha256']:raise ValueError('changed primary text bytes')
 home=Path(home).resolve()
 if home.exists():raise ValueError('tool home exists; use a new local directory')
 home.parent.mkdir(parents=True,exist_ok=True);tmp=Path(tempfile.mkdtemp(prefix='gnu-omf-setup-',dir=home.parent))
 try:
  files={'bin/as-new':paths[3].read_bytes(),'bin/objconv':paths[4].read_bytes(),'assets/AWE32P10.TXT':primary,'notices/GNU-COPYING3':license_bytes,'notices/objconv-instructions.pdf':manual}
  for name,data in files.items():p=tmp/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
  for name in ['bin/as-new','bin/objconv']:(tmp/name).chmod(0o755)
  receipt={'profile_sha256':PROFILE_SHA256,'source_archives':spec['source_archives'],'objconv_source_files_sha256':actual,'files_sha256':{n:digest(tmp/n)for n in files},'method':'Exact independently reviewed source-built binaries, source archive identities verified; no rebuild/patch/global install'}
  (tmp/'setup.json').write_text(json.dumps(receipt,indent=2)+'\n');checked_home(tmp)
  if any(digest(p)!=h for p,h in before.items()):raise ValueError('setup input changed during staging')
  tmp.rename(home)
 except Exception:
  shutil.rmtree(tmp);raise
 return checked_home(home)

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path,required=True);p.add_argument('--binutils-archive',type=Path,required=True);p.add_argument('--objconv-archive',type=Path,required=True);p.add_argument('--primary-archive',type=Path,required=True);p.add_argument('--assembler',type=Path,required=True);p.add_argument('--converter',type=Path,required=True);a=p.parse_args();print(json.dumps(stage(a.home,a.binutils_archive,a.objconv_archive,a.primary_archive,a.assembler,a.converter),indent=2))
if __name__=='__main__':main()
