"""Prepare the exact MASM 5.10 published with Microsoft's DOS 4.0 tools."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import tempfile

SHA256='1c6286c69b616160b8475ad17453ee872702a2c98075c2159ec792a1c745275f'
COMMIT='2d04cacc5322951f187bb17e017c12920ac8ebe2'
BLOB_SHA1='eacbb6312af49633d2228d0baacb1e9a0a5efc97'
URL=f'https://raw.githubusercontent.com/microsoft/MS-DOS/{COMMIT}/v4.0/src/TOOLS/MASM.EXE'


def prepare(binary: Path,destination: Path) -> dict:
    binary=binary.resolve();destination=destination.resolve()
    if destination.exists():
        raise FileExistsError(destination)
    data=binary.read_bytes()
    blob=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
    if len(data)!=110703 or hashlib.sha256(data).hexdigest()!=SHA256 or blob!=BLOB_SHA1:
        raise ValueError('MASM 5.10 binary identity mismatch')
    destination.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='masm-setup-',dir=destination.parent) as directory:
        home=Path(directory)/'home';home.mkdir()
        shutil.copyfile(binary,home/'MASM.EXE')
        if hashlib.sha256((home/'MASM.EXE').read_bytes()).hexdigest()!=SHA256:
            raise ValueError('copied MASM binary identity mismatch')
        if destination.exists():
            raise FileExistsError(destination)
        home.rename(destination)
    return {'version':'Microsoft Macro Assembler 5.10','source_url':URL,
            'repository_commit':COMMIT,'github_blob_sha1':BLOB_SHA1,
            'method':'Verify published executable SHA-256, Git blob SHA-1 and length; copy to a fresh private tool home. No installer executed.',
            'tools':{'MASM.EXE':{'sha256':SHA256,'bytes':len(data)}}}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary',type=Path,required=True)
    parser.add_argument('--destination',type=Path,required=True)
    parser.add_argument('--manifest',type=Path,required=True)
    args=parser.parse_args()
    report=prepare(args.binary,args.destination)
    args.manifest.parent.mkdir(parents=True,exist_ok=True)
    args.manifest.write_text(json.dumps(report,indent=2)+'\n')
    print('Verified MASM 5.10 prepared.')
