"""Pinned nonhistorical High C DATA producer, using the unchanged DOS runner.
No claim of hc2.5k identity or operational final-link compatibility.
"""
from pathlib import Path
import json
import os
import shutil
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'profiles/watcom/tools'))
from runner import run_batch
from profiles.highc.identity import checked_home,digest,manifest
OPTIONS=('-c','-O6','-386')
DOS_NAMES={'NRPNVAR.C','MIDIVAR.C'}

def host_inputs():
    binary=os.environ.get('EXHUME_DOSBOX_X') or shutil.which('dosbox-x')
    if not binary:raise ValueError('DOSBox-X is required')
    return [Path(binary).resolve(),Path(sys.executable).resolve()]

def compile_source(home,source,header,work,dos_name,timeout=30):
    if dos_name not in DOS_NAMES:raise ValueError('unsupported High C DOS source filename')
    home=Path(home).resolve();source=Path(source).resolve();header=Path(header).resolve();work=Path(work).resolve()
    tools=checked_home(home);hosts=host_inputs();paths=[source,header,*hosts]
    before={str(p):digest(p)for p in paths}
    work.mkdir(parents=True,exist_ok=False)
    shutil.copyfile(source,work/dos_name);shutil.copyfile(header,work/'CTAWEAPI.H')
    staged={work/dos_name:before[str(source)],work/'CTAWEAPI.H':before[str(header)]}
    if any(digest(p)!=h for p,h in staged.items()):
        raise ValueError('High C source/header changed while staging')
    # Fresh directory and explicit filenames prevent stale objects and generic
    # SOURCE.THEADR collisions. Only supported fixed options reach the driver.
    batch=('@echo off\r\nset PATH=D:\\BIN\r\nset HCDIR=D:\\\r\n'
           'hc386 '+' '.join(OPTIONS)+' '+dos_name+' > COMPILE.LOG\r\n'
           'if errorlevel 1 goto failed\r\necho OK>STATUS.TXT\r\ngoto end\r\n'
           ':failed\r\necho FAILED>STATUS.TXT\r\n:end\r\n')
    run_batch(home,work,batch,timeout)
    if (checked_home(home)!=tools or host_inputs()!=hosts or
        any(digest(p)!=h for p,h in before.items()) or
        any(digest(p)!=h for p,h in staged.items())):
        raise ValueError('High C source/header/host tool changed during compilation')
    stem=Path(dos_name).stem;obj=work/(stem+'.OBJ')
    if not(work/'STATUS.TXT').exists() or (work/'STATUS.TXT').read_text().strip()!='OK' or not obj.is_file() or not obj.stat().st_size:
        raise ValueError('High C native compilation failed')
    log=work/'COMPILE.LOG'
    if not log.is_file() or log.read_bytes():raise ValueError('unexpected redirected High C diagnostic output')
    # Some driver console messages bypass DOS redirection. Do not describe an
    # empty redirected log as generic warning capture; flags/source are fixed
    # and complete object metadata/bytes are independently checked by callers.
    return {'object':obj,'object_sha256':digest(obj),'log_sha256':digest(log),
            'compiler_files_sha256':tools,'source_header_host_sha256':before,
            'options':list(OPTIONS),'dos_source_filename':dos_name,
            'historical_producer_identity_matched':False,'final_link_compatible':False}
