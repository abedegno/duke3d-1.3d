"""Task69 own native fixture builders; NOT High C/tool output.
Fixture builders use no SDK bytes. Optional reference replay keeps original
member bytes in memory and emits ownership metadata only.
"""
from pathlib import Path
import hashlib,json,struct,sys
ROOT=Path(__file__).resolve().parents[1]


def rec(k,p):
    b=bytes([k])+struct.pack('<H',len(p)+1)+p
    return b+bytes([-sum(b)&255])
def name(s):
    b=s.encode('ascii');return bytes([len(b)])+b
def u32(n):return struct.pack('<I',n)

def records(easy=True,threads=True):
    # Completely populated CODE and DATA; all-zero artificial payload except
    # independently chosen sentinel words. They are parser/gate witnesses.
    kinds=(0x98,0x90,0xa0,0x9c) if easy else (0x99,0x91,0xa1,0x9d)
    seg,pub,data,fix=kinds
    size=0x10020
    chunks=[(0x80,name('task68-own-fixture'))]
    if easy:chunks.append((0x88,b'\x80\xaa80386'))
    chunks += [(0x88,b'\x80\0Task68 handcrafted; not High C output'),
               (0x96,b''.join(name(s) for s in ('','CODE','CODE','DATA','DATA','DGROUP'))),
               (seg,bytes([0xa8 if easy else 0xa9])+u32(size)+b'\x02\x03\x01'),
               (seg,bytes([0xa8 if easy else 0xa9])+u32(size)+b'\x04\x05\x01'),
               (0x9a,b'\x06\xff\x02'),(0x8c,name('own_external')+b'\0'),
               (pub,b'\x00\x01'+name('own_code_high')+u32(0x10000)+b'\0'),
               (pub,b'\x01\x02'+name('own_data_high')+u32(0x10010)+b'\0')]
    if threads:chunks.append((fix,b'\x44\x01\x00\x02'))
    payloads=[bytearray(size),bytearray(size)]
    payloads[0][-4:]=b'OWNC';payloads[1][-4:]=b'OWND'
    for number,payload in enumerate(payloads,1):
        for off in range(0,size,512):
            chunks.append((data,bytes([number])+u32(off)+payload[off:off+512]))
            if number==1 and off==0x10000:
                loc=0xd4 if easy else 0xe4
                if threads:
                    chunks += [(fix,bytes([loc,0,0x8c])),
                               (fix,bytes([loc,4,0x88])+u32(0x10001)),
                               (fix,b'\x08\x01'+bytes([loc,8,0x8c]))]
                else:
                    chunks += [(fix,bytes([loc,0,0x14,1,2])),
                               (fix,bytes([loc,4,0x10,1,2])+u32(0x10001)),
                               (fix,bytes([loc,8,0x16,1,1]))]
    chunks.append((0x8a,b'\0'))
    return chunks

def object_bytes(easy=True,threads=True):
    return b''.join(rec(*r) for r in records(easy,threads))


def linked_image():
    """Own independent LE fixture; no parser AST or historical output used.

    Two 17-page objects. CODE high references resolve to DATA0, DATA0x10001,
    and DATA0x10010; three loader relocations occupy logical page16.
    """
    page_size=4096
    count=34
    obj=0xc4; pages=obj+48; fp=pages+count*4; fr=fp+(count+1)*4
    fix=b''.join(b'\x07\x10'+struct.pack('<hBI',off,2,target)
                 for off,target in ((0,0),(4,0x10001),(8,0x10010)))
    raw=bytearray(4096+count*page_size)
    raw[:4]=b'LE\0\0'
    for offset,value in {20:count,24:1,28:0,32:2,36:0x10020,
                         40:page_size,44:page_size,48:(count+1)*4+len(fix),
                         64:obj,68:2,72:pages,104:fp,108:fr,128:4096}.items():
        struct.pack_into('<I',raw,offset,value)
    struct.pack_into('<6I',raw,obj,0x10020,0x10000,0x2005,1,17,0)
    struct.pack_into('<6I',raw,obj+24,0x10020,0x30000,0x2003,18,17,0)
    for n in range(count):
        raw[pages+4*n:pages+4*n+4]=(n+1).to_bytes(3,'big')+b'\0'
    for n in range(count+1):
        struct.pack_into('<I',raw,fp+4*n,0 if n<=16 else len(fix))
    raw[fr:fr+len(fix)]=fix
    for offset,target in ((0,0),(4,0x10001),(8,0x10010)):
        struct.pack_into('<I',raw,4096+0x10000+offset,target)
    raw[4096+0x1001c:4096+0x10020]=b'OWNC'
    raw[4096+17*page_size+0x1001c:4096+17*page_size+0x10020]=b'OWND'
    return bytes(raw)


def replay_pawe32():
    """Reference ownership only. Never emits SDK object/body bytes.

    CODE bases are independently anchored by accepted AWE32 caller constraints
    (Task67); DATA placements inferred from exact LE relocation targets must
    survive the unchanged whole-module verifier. Group1 is explicitly bound to
    LE object3, frame0, and checked against every member/target placement.
    """
    sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
    from omf32 import Module
    from le import LEImage
    from tools.inventory_watcom_runtime import read_archive
    from tools.infer_bindings import infer_bindings,infer_data_bindings
    from tools.verify_module import verify_module,ModuleError
    from copy import deepcopy
    witnesses=[
        ('nrpnvar.c',16,1785,'1e683d49e6ce453178ded31c25e78f5c89dff6ae83e54eae66a1319fc9a22daa',None,32364,1544,0),
        ('nrpn.c',1808,4360,'7fad1adc93ed224b1bcdda796c10610127297e09f2e01cbfd32b388291a6a49c',426312,33908,3388,149),
        ('sbkload.c',6176,6725,'c883af1d64f143c6386bdc8ffc65e212a29a74351ddd03ed7a3d5078f7e319ca',429120,34488,5404,149),
        ('hardware.c',12912,4275,'5a807da55db64ceaf8b1d3956c0b264a226ef0d18fde599f057f041f68ea422f',434004,35008,3180,154),
        ('midivar.c',17200,2778,'9a56d0b90a5bb6658ef235bc7c5c28d3094816f59dea768ae25e26bd45377f5c',None,35528,2396,0),
        ('midieng.c',19984,10327,'8ba6052d38f40af10bb2af6268946080d257c290fd79fb597075eab51437b412',436664,37924,8708,229),
        ('embed.c',30320,17938,'0e07fd4722e142702f40a6cc941fdc02c7373e6b4f7764be77eb15d23a88b7c5',None,39348,17444,0)]
    raw=(ROOT/'reference/audiolib-reconstructions/LIB/PAWE32.LIB').read_bytes()
    digest=hashlib.sha256(raw).hexdigest()
    assert digest=='ebeb7dfb5a38ad206569804445cff5fb8e5265ac1cdd6039beebedd1e889e14c'
    archive=read_archive(raw);assert len(archive['members'])==7
    image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
    caller_proof=json.loads((ROOT/'evidence/awe32-module.json').read_text())
    anchors={c['symbol']:c['value'] for c in caller_proof['constraints'] if 'symbol' in c}
    rows=[]
    for member,witness in zip(archive['members'],witnesses):
        name_,offset,size,sha,code_base,data_base,nbytes,nfix=witness
        assert (member['name'],member['offset'],member['end']-member['offset'],member['sha256'])==(name_,offset,size,sha)
        source=raw[offset:offset+size];module=Module.parse(source)
        assert b''.join(r[2] for r in module.source_records)==source
        known={n:v for n,v in anchors.items() if n in module.publics or n in module.externals}
        if code_base is None:
            bindings=infer_data_bindings(module,{n:v for n,v in known.items() if n in module.publics})
            expected={1:(3,data_base)};frames={}
        else:
            bindings=infer_bindings(module,image,1,code_base,known_symbols=known)
            expected={1:(1,code_base),2:(3,data_base)};frames={1:(3,0)}
            assert module.groups==[('DGROUP',(2,))]
        assert bindings['placements']==expected
        proof=verify_module(module,image,bindings['placements'],bindings['symbols'],group_frames=frames)
        assert (proof['initialized_bytes'],proof['verified_fixups'])==(nbytes,nfix)
        negatives=[]
        for seg in range(len(module.segments)):
            damaged=deepcopy(module);damaged.segments[seg].data[-1]^=1
            try:verify_module(damaged,image,expected,bindings['symbols'],group_frames=frames)
            except ModuleError:negatives.append('changed segment '+str(seg+1)+' last byte rejected')
            else:raise AssertionError('whole-member mutation unexpectedly accepted')
        if frames:
            for invalid in ({},{1:(1,0)},{1:(3,4)}):
                try:verify_module(module,image,expected,bindings['symbols'],group_frames=invalid)
                except ModuleError:negatives.append('absent/wrong group frame rejected')
                else:raise AssertionError('wrong group frame unexpectedly accepted')
        rows.append({'member':name_,'member_sha256':sha,'placements':expected,
                     'group_frames':frames,'thread_definitions':len(module.thread_definitions),
                     'proof':proof,'negative_checks':negatives})
    return {'scope':'complete original member reference ownership only',
            'archive_sha256':digest,'source_credit':0,'full_executable_rebuilt':False,
            'initialized_bytes':sum(r['proof']['initialized_bytes'] for r in rows),
            'verified_fixups':sum(r['proof']['verified_fixups'] for r in rows),'members':rows}


if __name__=='__main__':
    import argparse
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--replay-pawe32',action='store_true')
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    if a.replay_pawe32:
        a.out.parent.mkdir(parents=True,exist_ok=True)
        a.out.write_text(json.dumps(replay_pawe32(),indent=2)+'\n')
    else:
        a.out.mkdir(parents=True,exist_ok=True)
        for label,easy,threads in (('easy-threaded',True,True),('easy-inline',True,False),
                                   ('standard-threaded',False,True),('standard-inline',False,False)):
            (a.out/(label+'.obj')).write_bytes(object_bytes(easy,threads))
        (a.out/'own-linked.le').write_bytes(linked_image())
