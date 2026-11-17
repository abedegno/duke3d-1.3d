"""Export loader-relocated LE objects for Ghidra analysis only.

These files are not compiler inputs, recovered source, or matching evidence.
The canonical comparison tools continue to read the untouched executable.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from profiles.watcom.tools.le import LEImage
from tools.preserve import TARGET_SHA256


def export_image(target: Path, output: Path) -> dict:
    raw=target.read_bytes()
    identity=hashlib.sha256(raw).hexdigest()
    if identity!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    image=LEImage.parse(raw)
    blobs=[bytearray(image.object_bytes(n)) for n in range(1,len(image.objects)+1)]
    patches={}
    occupied={}
    fixups=image.read_fixups()
    for f in fixups:
        if (f.source_type,f.width) not in [(7,4),(8,4)] or f.alias:
            raise ValueError('unsupported analysis relocation')
        source=image.objects[f.source_object-1].base+f.source_offset
        value=f.target_address if f.source_type==7 else f.target_address-source-4
        payload=struct.pack('<I',value&0xffffffff)
        key=(f.source_object,f.source_offset)
        if key in patches:
            if patches[key]!=payload:
                raise ValueError('conflicting duplicate analysis relocation')
            continue
        for off in range(f.source_offset,f.source_offset+f.width):
            bytekey=(f.source_object,off)
            if bytekey in occupied:
                raise ValueError('overlapping analysis relocations')
            occupied[bytekey]=key
        patches[key]=payload
    for (obj,off),payload in patches.items():
        blobs[obj-1][off:off+len(payload)]=payload
    objects=[]
    for n,(obj,blob) in enumerate(zip(image.objects,blobs),1):
        objects.append({'number':n,'file':f'object{n}.bin','base':obj.base,
                        'size':obj.size,'flags':obj.flags,
                        'sha256':hashlib.sha256(blob).hexdigest()})
    report={'kind':'loader-relocated analysis copy; not source recovery evidence',
            'target_sha256':identity,'recovered_source':False,
            'fixup_records':len(fixups),'unique_fixups_applied':len(patches),
            'objects':objects,
            'scope':'Original executable unchanged. Includes zero-filled LE storage. No matching coverage is claimed.'}
    output.mkdir(parents=True,exist_ok=False)
    for obj,blob in zip(objects,blobs):
        (output/obj['file']).write_bytes(blob)
    (output/'objects.tsv').write_text(''.join(
        f"{o['file']}\t{o['base']:x}\t{o['size']}\t{o['flags']}\n" for o in objects))
    (output/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    return report


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--target',type=Path,default=ROOT/'reference/DUKE3D.EXE')
    p.add_argument('--output',type=Path,required=True,help='fresh analysis-only directory')
    args=p.parse_args()
    report=export_image(args.target,args.output)
    print(f"Analysis only: {len(report['objects'])} objects; {report['unique_fixups_applied']} loader operands relocated")


if __name__=='__main__':main()
