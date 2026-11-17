"""Reproduce native PUBLIC BSS concatenation, without claiming target ownership.

Small data-only fixtures carry the same SEGDEF attributes and byte counts as
three game contributions. Their linker maps distinguish paragraph alignment
from DWORD alignment and object order from reversed order. No game instruction
or initialized payload is used, and the generated fixtures are never executed.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from runner import assemble_source,run_batch

SIZES={'player':18,'premap':4,'sector':5}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def experiment(home,assembler,build,alignment,order):
    build.mkdir(parents=True,exist_ok=False)
    sources={};objects={};attributes={};sizes={}
    for name,size in SIZES.items():
        source=build/(name.upper()+'.ASM')
        source.write_text(f".386p\n_BSS SEGMENT {alignment} PUBLIC USE32 'BSS'\n"
                          f"PUBLIC {name}_state\n{name}_state DB {size} DUP (?)\n"
                          "_BSS ENDS\nEND\n")
        obj=source.with_suffix('.OBJ')
        assemble_source(assembler,source,obj,['/MX'],producer='masm')
        module=Module.parse(obj.read_bytes())
        if (len(module.segments)!=1 or module.fixups or
                module.segments[0].name!='_BSS' or
                module.segments[0].class_name!='BSS' or
                module.publics!={name+'_state':(1,0)}):
            raise ValueError('unexpected native BSS fixture')
        segment=module.segments[0]
        if segment.size!=size or any(segment.data):
            raise ValueError('fixture includes initialized payload or wrong extent')
        sources[name]=digest(source);objects[name]=digest(obj)
        attributes[name]=segment.attributes;sizes[name]=segment.size
    response=build/'ORDER.LNK'
    response.write_text('format os2 le\noption map=OUT.MAP\n'
                        'option nodefaultlibs\nname OUT.EXE\nfile '+
                        ','.join(n.upper()+'.OBJ' for n in order)+'\n')
    batch=('@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
           'wlink @ORDER.LNK > LINK.LOG\r\nif errorlevel 1 goto failed\r\n'
           'echo OK>STATUS.TXT\r\ngoto end\r\n:failed\r\n'
           'echo FAILED>STATUS.TXT\r\n:end\r\n')
    run_batch(home,build,batch,30)
    status=(build/'STATUS.TXT').read_text().strip()
    log=(build/'LINK.LOG').read_text()
    if status!='OK' or 'Error(' in log:
        raise ValueError('native layout link failed: '+log)
    warnings=[int(n) for n in re.findall(r'Warning\((\d+)\)',log)]
    # These fixtures intentionally have no stack or entry point. The linker
    # warnings are expected; arbitrary additional diagnostics must reject.
    if warnings!=[1014,1023]:
        raise ValueError('unexpected layout-fixture linker diagnostics: '+log)
    map_text=(build/'OUT.MAP').read_text()
    rows=re.findall(r'^([0-9a-fA-F]{4}):([0-9a-fA-F]{8})[*+s ]*\s+'
                    r'(player_state|premap_state|sector_state)\s*$',map_text,re.M)
    if len(rows)!=3 or len({n for _,_,n in rows})!=3 or len({o for o,_,_ in rows})!=1:
        raise ValueError('incomplete or ambiguous native linker map')
    return {'order':order,'segment_attributes':attributes,'segment_bytes':sizes,
            'public_offsets':{name:int(offset,16) for _,offset,name in rows},
            'source_sha256':sources,'object_sha256':objects,
            'response_sha256':digest(response),'map_sha256':digest(build/'OUT.MAP'),
            'link_log_sha256':digest(build/'LINK.LOG'),'warning_codes':warnings,
            'warning_scope':'Data-only layout fixture has no stack or entry point; it is not executable game code.'}


def probe(home,assembler,build):
    home=home.resolve();assembler=assembler.resolve();build=build.resolve()
    build.mkdir(parents=True,exist_ok=False)
    response=ROOT/'reference/duke3d-reconstructions/MAKEFILE.LNK'
    source_order=[]
    for line in response.read_text().splitlines():
        if line.strip().lower().startswith('file '):
            source_order.extend(n.strip().lower() for n in line.strip()[5:].split(','))
    start=source_order.index('menues');end=source_order.index('sounds')+1
    source_order=source_order[start:end]
    if source_order!=['menues','player','premap','sector','sounds']:
        raise ValueError('pinned link response no longer has the expected adjacent modules')
    results={}
    for name,alignment,order in [
            ('paragraph','PARA',['player','premap','sector']),
            ('dword','DWORD',['player','premap','sector']),
            ('reverse','PARA',['sector','premap','player'])]:
        results[name]=experiment(home,assembler,build/name,alignment,order)
    return {'kind':'native linker segment-order and alignment experiment, not target BSS ownership',
            'linker_sha256':digest(home/'BIN/wlink.exe'),
            'assembler_sha256':digest(assembler/'MASM.EXE'),
            'link_response':str(response.relative_to(ROOT)),
            'link_response_sha256':digest(response),'link_response_order':source_order,
            'experiments':results,'target_bss_ownership_verified':False,
            'scope':'These fixtures establish behavior of the tested linker and native SEGDEF attributes. Absolute target placement additionally requires independently verified neighboring contributions, native inventory, and matching target module order. No linker-version identity, target allocation ownership or full executable identity is established here.',
            'new_complete_contributions':0,'full_executable_rebuilt':False}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    parser.add_argument('--assembler',type=Path,default=ROOT/'toolchains/masm-5.10')
    parser.add_argument('--build',type=Path,required=True)
    parser.add_argument('--report',type=Path,required=True)
    args=parser.parse_args()
    result=probe(args.home,args.assembler,args.build)
    args.report.write_text(json.dumps(result,indent=2)+'\n')
    print('Native BSS order/alignment experiments complete; target ownership remains unproved.')


if __name__=='__main__':main()
