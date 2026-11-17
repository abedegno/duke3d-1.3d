#!/usr/bin/env python3
"""Build the opt-in Native-layout converter from exact public source; local install only."""
from pathlib import Path
import sys,hashlib,json,io,zipfile,tarfile,shutil,tempfile,subprocess,argparse
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from profiles.gnu_elf_omf_layouts.identity import profile,digest,checked_home,PROFILE_SHA256,expected_files,imports_profile
from profiles.gnu_elf_omf_layouts.apply_fork import apply

def stage(home,binutils_archive,objconv_archive,assembler,compiler):
    spec=profile();paths=[Path(p).resolve()for p in[binutils_archive,objconv_archive,assembler,compiler]];raw=[p.read_bytes()for p in paths[:3]]
    if[hashlib.sha256(x).hexdigest()for x in raw]!=[spec['source_archives']['binutils']['sha256'],spec['source_archives']['objconv']['sha256'],spec['tools']['bin/as-new']['sha256']]:raise ValueError('Native-layout archive/assembler identity')
    inputs=[*paths,Path(__file__),ROOT/'profiles/gnu_elf_omf_layouts/identity.py',ROOT/'profiles/gnu_elf_omf_layouts/apply_fork.py',ROOT/'profiles/gnu_elf_omf_layouts/profile.json',*[ROOT/'profiles/gnu_elf_omf_layouts'/n for n in spec['metadata_patches']],*[ROOT/'profiles/gnu_elf_omf_imports'/n for n in['identity.py','profile.json','apply_fork.py','defined-global.patch','unused-imports.patch']]];before={str(p):digest(p)for p in inputs}
    if any(hashlib.sha256(x).hexdigest()!=before[str(p)]for p,x in zip(paths[:3],raw)):raise ValueError('Native-layout archive changed after parse')
    home=Path(home).resolve()
    if home.exists():raise ValueError('Native-layout use a fresh local toolhome')
    home.parent.mkdir(parents=True,exist_ok=True);tmp=Path(tempfile.mkdtemp(prefix='native-layout-tools-',dir=home.parent))
    try:
        with tarfile.open(fileobj=io.BytesIO(raw[0]))as t:license_bytes=t.extractfile('binutils-2.44/COPYING3').read()
        with zipfile.ZipFile(io.BytesIO(raw[1]))as z:source=z.read('source.zip');manual=z.read('objconv-instructions.pdf')
        if hashlib.sha256(source).hexdigest()!=spec['source_archives']['objconv']['source_zip_sha256']:raise ValueError('Native-layout nested source archive')
        base=imports_profile(spec);folder=tmp/'sources/objconv';folder.mkdir(parents=True)
        with zipfile.ZipFile(io.BytesIO(source))as z:
            names=z.namelist();expected=base['converter_fork']['original_source_files']
            if len(names)!=42 or set(names)!=set(expected):raise ValueError('Native-layout exact42 released sources')
            for n in names:
                data=z.read(n)
                if Path(n).name!=n or hashlib.sha256(data).hexdigest()!=expected[n]:raise ValueError('Native-layout vendor source path/hash')
                (folder/n).write_bytes(data)
        apply(folder);(tmp/'bin').mkdir();command=[str(paths[3]),'-o',str(tmp/'bin/objconv'),'-O2',*[str(p)for p in sorted(folder.glob('*.cpp'))]];result=subprocess.run(command,capture_output=True,text=True)
        if result.returncode:raise ValueError('Native-layout source compiler failure: '+result.stderr)
        if digest(tmp/'bin/objconv')!=spec['tools']['bin/objconv']['sha256']:raise ValueError('Native-layout source-built converter differs from reviewed host artifact')
        files={'bin/as-new':raw[2],'notices/GNU-COPYING3':license_bytes,'notices/objconv-instructions.pdf':manual}
        files.update({'sources/'+n:(ROOT/'profiles/gnu_elf_omf_layouts'/n).read_bytes()for n in spec['metadata_patches']})
        files.update({'sources/'+n:(ROOT/'profiles/gnu_elf_omf_imports'/n).read_bytes()for n in['defined-global.patch','unused-imports.patch']})
        for n,data in files.items():p=tmp/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
        for n in['bin/as-new','bin/objconv']:(tmp/n).chmod(0o755)
        if any(digest(p)!=h for p,h in before.items()):raise ValueError('Native-layout setup input race')
        expected=expected_files();actual={p.relative_to(tmp).as_posix():digest(p)for p in tmp.rglob('*')if p.is_file()}
        if actual!=expected:raise ValueError('Native-layout exact installed source/tool graph')
        receipt={'profile_sha256':PROFILE_SHA256,'files_sha256':actual,'source_archives':spec['source_archives'],'method':'Reviewed GNU assembler; exact42 released sources plus tracked metadata patches; converter freshly source-compiled, never copied from research/artifact inputs','source_compile':{'compiler':str(paths[3]),'compiler_sha256':before[str(paths[3])],'command':command,'stdout':result.stdout,'stderr':result.stderr},'input_sha256':before};(tmp/'setup.json').write_text(json.dumps(receipt,indent=2)+'\n');checked_home(tmp);tmp.rename(home)
    except Exception:shutil.rmtree(tmp);raise
    return checked_home(home)
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in['home','binutils-archive','objconv-archive','assembler','compiler']:p.add_argument('--'+n,type=Path,required=True)
    a=p.parse_args();print(json.dumps(stage(a.home,a.binutils_archive,a.objconv_archive,a.assembler,a.compiler),indent=2))
