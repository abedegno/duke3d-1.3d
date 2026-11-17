#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Import an exact local vendor-source overlay without downloading or licensing it."""
from pathlib import Path
import argparse,hashlib,json,sys
ROOT=Path(__file__).resolve().parents[1]
def digest(raw):return hashlib.sha256(raw).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--from',dest='source',type=Path,required=True);a=p.parse_args()
 spec=json.loads((ROOT/'verification/local-dependencies.json').read_bytes());pending=[]
 for name,expected in spec['files'].items():
  rel=Path(name)
  if rel.is_absolute()or'..'in rel.parts or not rel.parts:raise ValueError('unsafe dependency path')
  source=a.source/rel
  if not source.is_file():raise ValueError('missing local dependency: '+name)
  raw=source.read_bytes()
  if digest(raw)!=expected:raise ValueError('wrong local dependency hash: '+name)
  target=ROOT/rel
  if any(x.is_symlink()for x in[target,*target.parents]):raise ValueError('symlink destination: '+name)
  if target.exists()and(not target.is_file()or digest(target.read_bytes())!=expected):raise ValueError('conflicting existing file: '+name)
  pending.append((target,raw,expected))
 # Everything is validated before the first write; copies use those same bytes.
 for target,raw,expected in pending:
  target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(raw)
  if digest(target.read_bytes())!=expected:raise ValueError('copied dependency changed: '+str(target))
 print(f'Imported and verified {len(pending)} local dependency files. No redistribution rights or licence acceptance are implied.')
if __name__=='__main__':
 try:main()
 except (ValueError,OSError)as e:print(str(e),file=sys.stderr);sys.exit(1)
