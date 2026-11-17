"""Reproduce the pinned, unmodified384-file DATA compiler subset.
Requires supplied pinned media,7z,mcopy and DOSBox-X. No download, license/serial
interaction or global install. Known damaged RCPP(option3) is never selected.
"""
from pathlib import Path
import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
ROOT=Path(__file__).resolve().parents[2]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from runner import run_batch
from profiles.highc.identity import manifest,checked_home,digest

def extraction_script(text,profile):
    parts=[];paths=set()
    for lib,body in re.findall(r'@BeginLib\s+(\S+)(.*?)@EndLib',text,re.S|re.I):
        selected=[]
        for line in body.splitlines():
            if re.search(r'@Option\s+1\b',line) and not re.search(r'NSER\.EXE',line,re.I):
                line=re.sub(r'\s+@Option\s+1\b','',line).strip()
                match=re.fullmatch(r'@F [0-9A-Z]+ @S \d+ @[OA] ([A-Z0-9_\\.\-]+)',line,re.I)
                if not match:raise ValueError('unsupported original selected install record')
                name=match.group(1).replace('\\','/')
                if name.startswith('/') or '..'in Path(name).parts or 'RCPP'in name.upper():
                    raise ValueError('invalid compiler selection path')
                paths.add(name.upper());selected.append(line)
        if selected:parts.append('@BeginLib '+lib+'\n'+'\n'.join(selected)+'\n@EndLib\n')
    if paths!={x['path'].upper()for x in profile['files']}:
        raise ValueError('compiler selection does not match384-file manifest')
    return ('@DefineProject\n@Name = "MetaWare High C/C++ for Extended DOS and Windows"\n'
            '@Version = "3.31"\n@Subdir = "\\\\OUT"\n@OutDrive = D\n@EndProject\n'
            '@DefineDisk\n@Label = "Disk #1"\n'+''.join(parts)+
            '@EndDisk\n@Finish\n@EndFinish\n')

def command(args):
    result=subprocess.run([str(x)for x in args],capture_output=True,text=True,timeout=60)
    if result.returncode:raise ValueError('media extraction failed: '+result.stderr[-1000:])
    return result.stdout+result.stderr

def prepare(archive,destination,work):
    archive=Path(archive).resolve();destination=Path(destination).resolve();work=Path(work).resolve();profile=manifest()
    if not archive.is_file() or archive.stat().st_size!=profile['archive']['size'] or digest(archive)!=profile['archive']['sha256']:
        raise ValueError('High C archive identity mismatch')
    if destination.exists():raise ValueError('compiler destination already exists; never overwrite')
    programs=[shutil.which('7z'),shutil.which('mcopy')]
    if not all(programs):raise ValueError('7z and mcopy required for pinned media extraction')
    tools={p:digest(p)for p in programs};work.mkdir(parents=True,exist_ok=True)
    actual=Path(tempfile.mkdtemp(prefix='highc-setup-',dir=work));media=actual/'media';media.mkdir()
    (actual/'outer-extraction.log').write_text(command([programs[0],'x','-y','-o'+str(media),archive]))
    product=media/profile['archive']['product_directory']
    for item in profile['media']:
        path=product/item['path']
        if not path.is_file() or path.stat().st_size!=item['size'] or digest(path)!=item['sha256']:
            raise ValueError('High C disk identity changed: '+item['path'])
    floppies=actual/'floppies';floppies.mkdir()
    for i in range(1,8):
        disk=floppies/('disk'+str(i));disk.mkdir()
        (actual/('disk'+str(i)+'.log')).write_text(command([programs[1],'-s','-i',product/('disk'+str(i)+'.img'),'::*',disk]))
    for item in profile['extraction_inputs']:
        path=floppies/item['path']
        if not path.is_file() or path.stat().st_size!=item['size'] or digest(path)!=item['sha256']:
            raise ValueError('High C extraction input identity changed: '+item['path'])
    stage=actual/'stage';stage.mkdir();disk1=floppies/'disk1'
    for name in ['INSTALL.EXE','DISK.ID']:shutil.copyfile(disk1/name,stage/name)
    script=extraction_script((disk1/'INSTALL.DAT').read_text(),profile)
    for lib in re.findall(r'@BeginLib (\S+)',script):
        matches=list(floppies.rglob(lib))
        if len(matches)!=1:raise ValueError('missing/duplicate selected compressed library')
        shutil.copyfile(matches[0],stage/lib)
    (stage/'INSTALL.DAT').write_bytes(script.replace('\n','\r\n').encode('ascii'))
    # The generated script contains only project/disk/selected-file records and
    # an empty Finish. Original dialogs, Spawn/serializer and EULA branches are
    # absent; the shipped unmodified executable performs decompression only.
    run_batch(stage,stage,'@echo off\r\nINSTALL > EXTRACT.LOG\r\nif errorlevel 1 goto failed\r\necho OK>C:\\STATUS.TXT\r\ngoto end\r\n:failed\r\necho FAILED>C:\\STATUS.TXT\r\n:end\r\n',50)
    if not(stage/'STATUS.TXT').is_file() or (stage/'STATUS.TXT').read_text().strip()!='OK':
        raise ValueError('compiler decompressor did not finish successfully')
    checked_home(stage/'OUT')
    if digest(archive)!=profile['archive']['sha256'] or any(digest(p)!=h for p,h in tools.items()):
        raise ValueError('media or extraction tool changed during setup')
    destination.parent.mkdir(parents=True,exist_ok=True);shutil.copytree(stage/'OUT',destination)
    checked_home(destination)
    receipt={'archive_sha256':digest(archive),'tool_sha256':tools,'selected_files':384,
             'actual_setup_directory':str(actual),'destination':str(destination),
             'RCPP_selected':False,'serialization_or_license_dialog_run':False,
             'historical_producer_identity_matched':False,'final_link_compatible':False}
    (actual/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    return receipt

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--archive',type=Path,required=True)
    p.add_argument('--home',type=Path,required=True);p.add_argument('--work',type=Path,required=True)
    a=p.parse_args();print(json.dumps(prepare(a.archive,a.home,a.work),indent=2))
if __name__=='__main__':main()
