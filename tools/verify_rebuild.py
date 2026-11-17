#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Check the complete known v1.3D executable identity, without comparison masks."""
from pathlib import Path
import argparse,hashlib,json,sys
ROOT=Path(__file__).resolve().parents[1]
def main():
 p=argparse.ArgumentParser(description=__doc__);g=p.add_mutually_exclusive_group(required=True);g.add_argument('--file',type=Path);g.add_argument('--result',type=Path);a=p.parse_args();path=a.file
 if a.result:path=Path(json.loads(a.result.read_bytes())['bound_program'])
 raw=path.read_bytes();expected=json.loads((ROOT/'verification/rebuild.json').read_bytes())['expected_executable'];actual=hashlib.sha256(raw).hexdigest()
 if len(raw)!=expected['bytes']or actual!=expected['sha256']:raise ValueError(f'Executable mismatch: {len(raw)} bytes, SHA256 {actual}')
 print(json.dumps({'verified':True,'bytes':len(raw),'sha256':actual,'comparison_masks':False},indent=2))
if __name__=='__main__':
 try:main()
 except (ValueError,OSError,KeyError)as e:print(str(e),file=sys.stderr);sys.exit(1)
