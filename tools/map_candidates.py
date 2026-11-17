"""Diagnostic reference-function locations. No relocation-masked result is proof."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from le import LEImage
from tools.preserve import TARGET_SHA256


def locate(module: Module, images: dict[int,bytes], min_anchor: int=8) -> list[dict]:
    if min_anchor<1:
        raise ValueError('min_anchor must be positive')
    rows=[]
    for symbol,(segment,start) in sorted(module.publics.items()):
        seg=module.segments[segment-1]
        if seg.class_name.upper()!='CODE' or start>=seg.size:
            continue
        end=min((o for s,o in module.publics.values() if s==segment and o>start),default=seg.size)
        original=bytes(seg.data[start:end]); mask=bytearray(len(original))
        for f in module.fixups:
            if f.segment==segment and f.offset<end and f.offset+f.width>start:
                if f.offset<start or f.offset+f.width>end:
                    raise ValueError(f'fixup crosses public range: {symbol}')
                a=f.offset-start
                if any(mask[a:a+f.width]):
                    raise ValueError('overlapping object fixups')
                mask[a:a+f.width]=b'\1'*f.width
        runs=[]; a=0
        while a<len(mask):
            if mask[a]:a+=1;continue
            b=a+1
            while b<len(mask) and not mask[b]:b+=1
            runs.append((a,b));a=b
        anchor_start,anchor_end=max(runs,key=lambda pair:pair[1]-pair[0],default=(0,0))
        row={'symbol':symbol,'segment':segment,'source_offset':start,'size':end-start,
             'unmasked_bytes':mask.count(0),'anchor_size':anchor_end-anchor_start,
             'locations':[],'status':'insufficient_anchor'}
        if anchor_end-anchor_start>=min_anchor:
            anchor=original[anchor_start:anchor_end]
            for number,image in sorted(images.items()):
                hit=image.find(anchor)
                while hit>=0:
                    off=hit-anchor_start
                    if off>=0 and off+len(original)<=len(image) and all(
                        image[off+a:off+b]==original[a:b] for a,b in runs):
                        row['locations'].append({'object':number,'offset':off})
                    hit=image.find(anchor,hit+1)
            count=len(row['locations'])
            row['status']='candidate' if count==1 else 'ambiguous' if count>1 else 'not_found'
        rows.append(row)
    return rows


def scan(directory: Path) -> dict:
    raw=(ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(raw).hexdigest()!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    image=LEImage.parse(raw)
    images={n:image.object_bytes(n) for n,o in enumerate(image.objects,1) if o.flags&4}
    modules=[]
    for path in sorted(directory.glob('*.obj')):
        rows=locate(Module.parse(path.read_bytes()),images)
        modules.append({'module':path.stem,'object_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
                        'functions':rows})
        print(path.stem,dict(Counter(r['status'] for r in rows)),flush=True)
    return {'status':'diagnostic candidates only; no relocated byte proof',
            'target_sha256':TARGET_SHA256,'modules':modules}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--objects',type=Path,default=ROOT/'build/sibling')
    p.add_argument('--output',type=Path,default=ROOT/'evidence/candidates.json')
    a=p.parse_args();report=scan(a.objects)
    a.output.parent.mkdir(parents=True,exist_ok=True)
    a.output.write_text(json.dumps(report,indent=2)+'\n')
