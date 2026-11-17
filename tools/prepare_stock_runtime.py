"""Prepare unmodified supplied Watcom members for the recovered source link.

Only original compiler libraries are inputs. No game/SDK object or target EXE
is read, no object is rewritten, and no recovered-source credit is claimed.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import sys
import tempfile
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from tools.inventory_watcom_runtime import read_archive
MANIFEST='candidates/stock_runtime_inputs.json'
LIBRARIES={
 'C105.LIB':'toolchains/watcom-10.5/LIB386/DOS/clib3r.lib',
 'M105.LIB':'toolchains/watcom-10.5/LIB386/math387r.lib',
 'CGA.LIB':'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib',
 'MGA.LIB':'toolchains/watcom-10.0-ga/LIB386/math387r.lib',
 'EGA.LIB':'toolchains/watcom-10.0-ga/LIB386/DOS/emu387.lib',
}
def need(value,message):
 if not value:raise ValueError(message)
def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def prepare(build,*,manifest=None):
 manifest=Path(manifest or ROOT/MANIFEST).resolve();raw_model=manifest.read_bytes();model=json.loads(raw_model);pins={str(manifest):hashlib.sha256(raw_model).hexdigest()}
 need(model['kind']=='unmodified supplied Watcom runtime link dependencies'and model['source_credit']==0,'Wrong runtime dependency scope')
 need(len(model['libraries'])==5 and{q['filename']:q['source_library']for q in model['libraries']}==LIBRARIES,'Wrong stock library set')
 need(len(model['objects'])==177,'Incomplete stock object set')
 inputs={};members={};payloads={};expected={}
 for row in model['libraries']:
  name=row['source_library'];path=ROOT/name;raw=path.read_bytes();h=hashlib.sha256(raw).hexdigest();need(h==row['sha256'],'Stock library identity changed: '+name);archive=read_archive(raw)
  need(len(archive['members'])==row['member_count'],'Stock library member count changed')
  inputs[name]=raw;members[name]={q['offset']:q for q in archive['members']};pins[str(path)]=h;payloads[row['filename']]=raw;expected[row['filename']]=h
 for row in model['objects']:
  name=row['filename'];need(re.fullmatch(r'[RIDFS][0-9]{3}\.OBJ',name)is not None and name not in payloads,'Invalid or duplicate stock filename')
  library=row['library'];need(library in inputs,'Unknown stock library')
  member=members[library].get(row['offset']);need(member is not None,'Stock member offset is not a complete member boundary')
  need(all(member[key]==row[key]for key in['name','size','sha256']),'Stock member identity changed: '+name)
  raw=inputs[library][member['offset']:member['end']];need(hashlib.sha256(raw).hexdigest()==row['sha256'],'Stock member bytes differ')
  payloads[name]=raw;expected[name]=row['sha256']
 pins[str(Path(__file__).resolve())]=digest(__file__);pins[str(ROOT/'tools/inventory_watcom_runtime.py')]=digest(ROOT/'tools/inventory_watcom_runtime.py')
 def unchanged():
  need(all(Path(p).is_file()and digest(p)==h for p,h in pins.items()),'Runtime input/model changed during preparation')
 unchanged();parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);work=Path(tempfile.mkdtemp(prefix='stock-runtime-',dir=parent))
 for name,raw in payloads.items():(work/name).write_bytes(raw)
 def outputs_unchanged():
  need({p.name for p in work.iterdir()if p.is_file()}<=set(expected)|{'runtime-inputs.json'},'Unexpected runtime output file')
  need(all((work/name).is_file()and digest(work/name)==h for name,h in expected.items()),'Stock runtime output changed')
 unchanged();outputs_unchanged()
 result={'kind':'Unmodified supplied compiler runtime link inputs','directory':str(work),'stock_objects':177,'stock_libraries':5,'inputs_sha256':pins,'outputs_sha256':expected,'target_or_game_archive_read':False,'vendor_supplied':True,'recovered_source_credit':0,'whole_executable_verified':False}
 receipt=work/'runtime-inputs.json';receipt.write_text(json.dumps(result,indent=2)+'\n')
 try:unchanged();outputs_unchanged()
 except Exception:receipt.unlink();raise
 return result
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--build',type=Path,required=True);parser.add_argument('--manifest',type=Path);parser.add_argument('--report',type=Path,required=True);args=parser.parse_args();r=prepare(args.build,manifest=args.manifest);args.report.parent.mkdir(parents=True,exist_ok=True);args.report.write_text(json.dumps(r,indent=2)+'\n');print('Prepared177 unmodified stock objects and5 libraries:',r['directory'])
