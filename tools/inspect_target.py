"""Write a reproducible structural report without exporting game bytes."""
import argparse
from collections import Counter
from dataclasses import asdict
import hashlib
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'exhume/profiles/watcom/tools'))
from le import LEImage


def inspect(path: Path) -> dict:
    data = path.read_bytes()
    image = LEImage.parse(data)
    fixups = image.read_fixups()
    unique = {(f.source_object, f.source_offset, f.source_type,
               f.target_object, f.target_offset) for f in fixups}
    return {
        'sha256': hashlib.sha256(data).hexdigest(), 'file_size': len(data),
        'embedded_mz_offset': image.origin, 'le_header_offset': image.header_offset,
        'page_size': image.page_size, 'logical_pages': len(image.pages),
        'entry': {'object': image.entry_object, 'offset': image.entry_offset,
                  'file_offset': image.file_offset(image.entry_object,image.entry_offset)},
        'stack': {'object': image.stack_object, 'offset': image.stack_offset},
        'objects': [dict(asdict(o), initialized_sha256=hashlib.sha256(
            image.object_bytes(n)[:o.page_count*image.page_size]).hexdigest(),
            virtual_sha256=hashlib.sha256(image.object_bytes(n)).hexdigest())
            for n,o in enumerate(image.objects,1)],
        'fixups': {'records': len(fixups), 'unique_sources_and_targets': len(unique),
                   'source_types': dict(sorted(Counter(f.source_type for f in fixups).items()))},
        'file_regions': [
            {'start': 0, 'end': image.origin, 'status': 'unmapped outer DOS/4GW binding'},
            {'start': image.origin, 'end': image.header_offset, 'status': 'embedded MZ stub'},
            {'start': image.header_offset, 'end': min(p.file_offset for p in image.pages
                if p.file_offset is not None), 'status': 'LE loader, tables, fixups, alignment'},
            {'start': min(p.file_offset for p in image.pages if p.file_offset is not None),
             'end': max(p.file_offset+p.stored_size for p in image.pages if p.file_offset is not None),
             'status': 'mapped LE object pages'},
        ],
        'recovery_status': 'structural mapping only; no recovered source coverage claimed',
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', type=Path)
    parser.add_argument('--output', type=Path, default=Path('evidence/target.json'))
    args = parser.parse_args()
    report = inspect(args.target)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({key:report[key] for key in ['embedded_mz_offset','le_header_offset','fixups']},indent=2))
