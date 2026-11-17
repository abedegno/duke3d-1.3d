"""Stage the complete pinned public Capstone distribution; no global install."""
from pathlib import Path
import argparse,json,shutil,sys,tempfile
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from profiles.capstone.identity import files,digest,checked_home,FILES_SHA256
def stage(distribution,home):
    distribution=Path(distribution).resolve();home=Path(home).resolve();expected=files()
    if home.exists():raise ValueError('decoder home exists; choose new directory')
    for n,h in expected.items():
        p=distribution/n
        if not p.is_file()or p.is_symlink()or digest(p)!=h:raise ValueError('distribution dependency changed/missing '+n)
    home.parent.mkdir(parents=True,exist_ok=True);tmp=Path(tempfile.mkdtemp(prefix='capstone-setup-',dir=home.parent))
    try:
        for n in expected:
            p=tmp/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(distribution/n,p)
        (tmp/'setup.json').write_text(json.dumps({'manifest_sha256':FILES_SHA256,'files_sha256':expected,'distribution':'capstone5.0.6 py3-none-macosx_11_0_arm64'},indent=2)+'\n');checked_home(tmp)
        for n,h in expected.items():
            if digest(distribution/n)!=h:raise ValueError('distribution changed during staging')
        tmp.rename(home)
    except Exception:shutil.rmtree(tmp);raise
    return checked_home(home)
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--distribution',type=Path,required=True);p.add_argument('--home',type=Path,required=True);a=p.parse_args();print(json.dumps(stage(a.distribution,a.home),indent=2))
