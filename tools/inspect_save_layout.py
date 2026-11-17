"""Inspect literal save-record arguments; this does not reconstruct save/load routines."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from tools.preserve import TARGET_SHA256

START=176429
END=178294


def decode_packet(code,site,fixups):
    """Recognize two complete MOV argument packets, without skipping bytes."""
    if site<17 or site+5>len(code) or code[site]!=0xe8:
        return None
    start=site-17;p=code[start:site]
    if p[0]==0xbb and p[5]==0xba and p[10]==0xb8 and p[15:17] in (b'\x89\xf1',b'\x89\xf9'):
        count=int.from_bytes(p[1:5],'little')
        size=int.from_bytes(p[6:10],'little')
        operand=start+11
        instructions=['mov ebx,count','mov edx,item_size','mov eax,address','mov ecx,file']
    else:
        start=site-14;p=code[start:site]
        if not (p[0]==0xbb and p[5]==0xb8 and p[10:12] in (b'\x89\xf1',b'\x89\xf9') and p[12:14]==b'\x89\xda'):
            return None
        count=size=int.from_bytes(p[1:5],'little');operand=start+6
        instructions=['mov ebx,count_and_item_size','mov eax,address','mov ecx,file','mov edx,ebx']
    pointer=int.from_bytes(code[operand:operand+4],'little')
    f=fixups.get((1,operand))
    if f is None or f.source_type!=7 or f.alias or f.target_object!=3 or f.target_offset!=pointer:
        raise ValueError('missing or inconsistent absolute data pointer fixup')
    widths={0:1,2:2,3:4,5:2,6:6,7:4,8:4}
    for (object_number,position),other in fixups.items():
        if object_number!=1:continue
        width=widths.get(other.source_type)
        if width is None:
            if start-6<=position<site+5:
                raise ValueError('unsupported relocation overlapping packet')
            continue
        if position<site+5 and position+width>start:
            if position!=operand or width!=4 or other!=f:
                raise ValueError('extra loader fixup overlapping packet')
    if not size or not count:
        raise ValueError('zero record extent')
    return {'call_offset':site,'packet_offset':start,'pointer_operand':operand,
            'object':3,'address':pointer,'item_size':size,'count':count,
            'span_bytes':size*count,'instructions':instructions,
            'packet_sha256':hashlib.sha256(code[start:site+5]).hexdigest()}


def observe(image):
    anchor_path=ROOT/'evidence/cache1d-module.json'
    anchor=json.loads(anchor_path.read_text())
    if anchor.get('target_sha256')!=TARGET_SHA256 or anchor['verification'].get('verified') is not True:
        raise ValueError('unverified CACHE1D call anchor')
    obj,target=anchor['verification']['publics']['dfwrite_']
    if obj!=1 or target!=421552:
        raise ValueError('unexpected dfwrite anchor')
    code=image.object_bytes(1)
    fixups={}
    for f in image.read_fixups():
        key=(f.source_object,f.source_offset)
        if key in fixups and fixups[key]!=f:
            # Boundary-page records may duplicate equivalent fixups.
            old=fixups[key]
            if (old.source_type,old.target_object,old.target_offset,old.alias)!=(f.source_type,f.target_object,f.target_offset,f.alias):
                raise ValueError('conflicting loader fixups')
        fixups[key]=f
    sites=[p for p in range(START,END-4) if code[p]==0xe8 and
           p+5+int.from_bytes(code[p+1:p+5],'little',signed=True)==target]
    records=[];unsupported=[]
    for site in sites:
        record=decode_packet(code,site,fixups)
        if record is None:unsupported.append(site)
        else:
            if record['address']+record['span_bytes']>image._object(3).size:
                raise ValueError('record extent exceeds object')
            records.append(record)
    reader_target=anchor['verification']['publics']['kdfread_']
    if reader_target!=[1,420486]:
        raise ValueError('unexpected kdfread anchor')
    read_sites=[p for p in range(173650,175650-4) if code[p]==0xe8 and
                p+5+int.from_bytes(code[p+1:p+5],'little',signed=True)==420486]
    reads=[];read_unsupported=[]
    for site in read_sites:
        row=decode_packet(code,site,fixups)
        if row is None:read_unsupported.append(site)
        else:
            if row['address']+row['span_bytes']>image._object(3).size:
                raise ValueError('reader extent exceeds object')
            reads.append(row)
    signature=lambda r:(r['object'],r['address'],r['item_size'],r['count'])
    matching=set(map(signature,records)) & set(map(signature,reads))
    return {'kind':'target instruction observations, not recovered source',
            'range':{'object':1,'start':START,'end':END},
            'dfwrite_anchor':{'evidence':str(anchor_path.relative_to(ROOT)),
                              'sha256':hashlib.sha256(anchor_path.read_bytes()).hexdigest(),
                              'object':obj,'offset':target},
            'write_calls':len(sites),'constant_pointer_records':records,
            'reader':{'range':{'object':1,'start':173650,'end':175650},
                      'kdfread_offset':420486,'read_calls':len(read_sites),
                      'constant_pointer_records':reads,
                      'unsupported_argument_packets':read_unsupported},
            'matching_reader_writer_records':len(matching),
            'unsupported_argument_packets':unsupported,
            'scope':'Only the two listed, complete MOV/call packets are interpreted. Each address has an exact LE pointer fixup. Stack/dynamic/other packets remain uninterpreted. These are explicit writer arguments, not proof of original C types, symbol names, maximum live indices, runtime execution, allocation ownership, or the complete save function.',
            'new_recovered_contributions':0,'full_module_verified':False,
            'full_executable_rebuilt':False}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--report',type=Path,required=True)
    a=p.parse_args();binary=(ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(binary).hexdigest()!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    report={'target_sha256':TARGET_SHA256,**observe(LEImage.parse(binary))}
    a.report.write_text(json.dumps(report,indent=2)+'\n')
    print(f"Observed {len(report['constant_pointer_records'])} literal record packets out of {report['write_calls']} dfwrite calls; source ownership remains unverified")


if __name__=='__main__':main()
