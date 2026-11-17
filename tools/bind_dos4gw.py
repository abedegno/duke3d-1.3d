"""Bind a supplied program behind the measured private DOS/4GW vendor component.

Only the pinned v1.3D container is supported. This copies no reference game
payload and verifies no source build; whole-file identity is reported separately.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from tools.preserve import TARGET_SHA256

VENDOR_SIZE=217764
VENDOR_SHA256='21d1cda74c1f4e379b5796c8f33a6619dfced9e5b8eef2df642a21b91fc882ff'
STUB_SIZE=10648
STUB_SHA256='3d1278454dbb867e17b383b65571031b232bb924393a49d116d7220080b54091'
FRAMES=((62580,123076,'VMM.EXP'),(123076,217764,'4GWPRO.EXP'))


def digest(data):
    return hashlib.sha256(data).hexdigest()


def _inspect_prefix(prefix):
    """Validate this exact component, not arbitrary DOS/16M files.

    Field layout is corroborated by Open Watcom exe16m.h. The old MAKEPM2072
    page convention is measured here: whole pages*512+tail, unlike the modern
    Open Watcom writer's ceil-page convention. The pinned hash bounds reuse.
    """
    if len(prefix)!=VENDOR_SIZE:
        raise ValueError('vendor component extent mismatch')
    word=lambda off:struct.unpack_from('<H',prefix,off)[0]
    dword=lambda off:struct.unpack_from('<I',prefix,off)[0]
    if prefix[:2]!=b'MZ':raise ValueError('vendor MZ signature mismatch')
    tail,pages=word(2),word(4)
    if not pages or tail>=512:raise ValueError('invalid vendor MZ page dimensions')
    mz_size=(pages-1)*512+(tail or 512)
    header_size=word(8)*16
    if mz_size!=62580 or header_size!=512:
        raise ValueError('vendor MZ load/header extent mismatch')
    if header_size+16*word(0x16)+word(0x14)>=mz_size:
        raise ValueError('vendor MZ entry outside load image')
    cursor=mz_size;frames=[]
    for expected,next_expected,name in FRAMES:
        if cursor!=expected or cursor+176>len(prefix) or prefix[cursor:cursor+2]!=b'BW':
            raise ValueError('vendor BW header boundary/signature mismatch')
        version=word(cursor+26)
        if version!=2072:raise ValueError('unsupported vendor MAKEPM version')
        tail,pages=word(cursor+2),word(cursor+4)
        if not pages or tail>=512:raise ValueError('invalid vendor BW page dimensions')
        size=pages*512+tail
        following=dword(cursor+28)
        if following<=cursor or following>len(prefix):
            raise ValueError('vendor BW next header outside forward chain')
        if following!=next_expected or cursor+size!=following:
            raise ValueError('vendor BW page extent/next header disagreement')
        path=prefix[cursor+112:cursor+176]
        if b'\0' not in path or path.split(b'\0',1)[0]!=name.encode('ascii'):
            raise ValueError('vendor BW EXP identity mismatch')
        frames.append({'offset':cursor,'size':size,'next_header':following,'name':name,
                       'makepm_version':version,'sha256':digest(prefix[cursor:following])})
        cursor=following
    if cursor!=len(prefix):raise ValueError('unassigned bytes after vendor BW chain')
    if digest(prefix)!=VENDOR_SHA256:
        raise ValueError('vendor component identity mismatch')
    return {'vendor_bytes':VENDOR_SIZE,'vendor_sha256':VENDOR_SHA256,
            'outer_mz_load_bytes':mz_size,'outer_mz_header_bytes':header_size,
            'frames':frames,'page_convention':'measured MAKEPM2072 whole pages plus remainder',
            'scope':'Pinned vendor component only; no game payload or source recovery credit.'}


def inspect_reference(reference):
    if digest(reference)!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    report=_inspect_prefix(reference[:VENDOR_SIZE])
    image=LEImage.parse(reference)
    if (image.origin,image.header_offset)!=(VENDOR_SIZE,VENDOR_SIZE+STUB_SIZE):
        raise ValueError('reference inner MZ/LE boundary mismatch')
    if digest(reference[VENDOR_SIZE:image.header_offset])!=STUB_SHA256:
        raise ValueError('reference inner MZ stub identity mismatch')
    report.update({'reference_sha256':TARGET_SHA256,'reference_bytes':len(reference),
                   'inner_mz_origin':image.origin,'le_header_offset':image.header_offset,
                   'inner_mz_stub_bytes':STUB_SIZE,'inner_mz_stub_sha256':STUB_SHA256})
    return report


def bind(reference,program):
    runtime=inspect_reference(reference)
    if len(program)<64 or program[:2]!=b'MZ':
        raise ValueError('program must be a complete unbound native MZ/LE image')
    native=LEImage.parse(program)
    if native.origin!=0:
        raise ValueError('program is already bound behind another container')
    if native.header_offset!=STUB_SIZE or digest(program[:native.header_offset])!=STUB_SHA256:
        raise ValueError('native MZ stub differs from the independently reproduced target stub')
    bound=reference[:VENDOR_SIZE]+program
    image=LEImage.parse(bound)
    if (image.origin,image.header_offset)!=(VENDOR_SIZE,VENDOR_SIZE+native.header_offset):
        raise ValueError('bound program container origin mismatch')
    if (image.objects,image.entry_object,image.entry_offset,image.stack_object,image.stack_offset)!=(
        native.objects,native.entry_object,native.entry_offset,native.stack_object,native.stack_offset):
        raise ValueError('bound program object/entry/stack metadata changed')
    if image.read_fixups()!=native.read_fixups():
        raise ValueError('bound program fixups changed')
    for number in range(1,len(native.objects)+1):
        if image.object_bytes(number)!=native.object_bytes(number):
            raise ValueError('bound program object bytes changed')
    differing=sum(a!=b for a,b in zip(bound,reference))+abs(len(bound)-len(reference))
    report={'kind':'measured vendor binding; supplied program source provenance unverified',
            'runtime':runtime,'native_program_bytes':len(program),'native_program_sha256':digest(program),
            'bound_bytes':len(bound),'bound_sha256':digest(bound),'native_program_preserved':True,
            'le_objects_and_fixups_preserved':True,'reused_target_game_bytes':0,
            'source_rebuild_verified':False,'full_executable_rebuilt':False,'executed':False,
            'whole_file_identity':{'match':bound==reference,'differing_bytes':differing,
                'actual_bytes':len(bound),'expected_bytes':len(reference),
                'actual_sha256':digest(bound),'expected_sha256':TARGET_SHA256}}
    return bound,report


def bind_prefix(prefix,program):
    """Bind from the separately supplied pinned vendor component only.

    No reference game payload is read or compared by this production API.
    The existing reference-aware API and CLI remain unchanged.
    """
    runtime=_inspect_prefix(prefix)
    if len(program)<64 or program[:2]!=b'MZ':
        raise ValueError('program must be a complete unbound native MZ/LE image')
    native=LEImage.parse(program)
    if native.origin!=0:
        raise ValueError('program is already bound behind another container')
    if native.header_offset!=STUB_SIZE or digest(program[:native.header_offset])!=STUB_SHA256:
        raise ValueError('native MZ stub differs from the independently reproduced target stub')
    bound=prefix+program;image=LEImage.parse(bound)
    if (image.origin,image.header_offset)!=(VENDOR_SIZE,VENDOR_SIZE+native.header_offset):
        raise ValueError('bound program container origin mismatch')
    if (image.objects,image.entry_object,image.entry_offset,image.stack_object,image.stack_offset)!=(native.objects,native.entry_object,native.entry_offset,native.stack_object,native.stack_offset):
        raise ValueError('bound program object/entry/stack metadata changed')
    if image.read_fixups()!=native.read_fixups():
        raise ValueError('bound program fixups changed')
    for number in range(1,len(native.objects)+1):
        if image.object_bytes(number)!=native.object_bytes(number):
            raise ValueError('bound program object bytes changed')
    return bound,{'kind':'Pinned supplied vendor prefix binding; no reference game payload input',
        'runtime':runtime,'native_program_bytes':len(program),'native_program_sha256':digest(program),
        'bound_bytes':len(bound),'bound_sha256':digest(bound),'native_program_preserved':True,
        'le_objects_and_fixups_preserved':True,'reused_target_game_bytes':0,
        'target_game_payload_read':False,'source_credit_added':0,'whole_target_match':False}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('reference','program','output','report'):
        parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args()
    paths={name:getattr(args,name).resolve() for name in ('reference','program','output','report')}
    try:
        values=list(paths.values())
        for i,path in enumerate(values):
            for other in values[i+1:]:
                if path==other or (path.exists() and other.exists() and path.samefile(other)):
                    raise ValueError('reference, program, output and report must be distinct files')
        bound,report=bind(paths['reference'].read_bytes(),paths['program'].read_bytes())
        for name in ('output','report'):paths[name].parent.mkdir(parents=True,exist_ok=True)
        paths['output'].write_bytes(bound)
        paths['report'].write_text(json.dumps(report,indent=2)+'\n')
    except (ValueError,OSError) as error:
        parser.error(str(error))
    print(f"BOUND: {len(bound)} bytes; whole reference identity: "
          f"{report['whole_file_identity']['match']}; source rebuild remains unverified")


if __name__=='__main__':main()
