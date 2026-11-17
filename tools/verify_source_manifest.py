#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Verify the public snapshot and guard against publishing local vendor files."""
from pathlib import Path
import hashlib,json,subprocess,sys
ROOT=Path(__file__).resolve().parents[1]
def main():
 spec=json.loads((ROOT/'verification/source-manifest.json').read_bytes());bad=[]
 for name,expected in spec['files'].items():
  path=ROOT/name
  if not path.is_file()or path.is_symlink()or hashlib.sha256(path.read_bytes()).hexdigest()!=expected:bad.append(name)
 if bad:raise ValueError('Source snapshot changed: '+', '.join(bad[:8]))
 # Imported overlays may exist locally, but must never enter the Git index.
 private=set(json.loads((ROOT/'verification/local-dependencies.json').read_bytes())['files'])
 tracked=set(subprocess.check_output(['git','ls-files','-z'],cwd=ROOT).decode().split('\0'))
 allowed=set(spec['files'])|{'verification/source-manifest.json'}|{q['path']for q in json.loads((ROOT/'verification/submodules.json').read_bytes())}
 unexpected=sorted(tracked-allowed-{''})
 if unexpected:raise ValueError('Unexpected tracked files: '+', '.join(unexpected[:8]))
 leaked=sorted(private&tracked)
 if leaked:raise ValueError('Local dependencies are tracked: '+', '.join(leaked[:8]))
 forbidden=[n for n in tracked if n.lower().endswith(('.exe','.obj','.lib','.iso','.grp','.sbk','.sf2'))or n.startswith(('build/','toolchains/'))]
 if forbidden:raise ValueError('Binary/private build inputs are tracked: '+', '.join(sorted(forbidden)[:8]))
 print(f'Public source snapshot verified: {len(spec["files"])} files; local dependencies and binaries remain untracked.')
if __name__=='__main__':
 try:main()
 except (ValueError,OSError,subprocess.CalledProcessError)as e:print(str(e),file=sys.stderr);sys.exit(1)
