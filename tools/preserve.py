"""Extract the user's reference executable without overwriting other inputs."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

TARGET_SHA256 = 'a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'
TARGET_SIZE = 1179131
ISO_ENTRY = 'DN3DINST/DUKE3D.EXE'


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def write_verified(data: bytes, output: Path, expected_sha256: str) -> None:
    actual = hashlib.sha256(data).hexdigest()
    if actual != expected_sha256:
        raise ValueError(f'Input SHA-256 {actual} differs from {expected_sha256}')
    output.parent.mkdir(parents=True, exist_ok=True)
    try:
        with output.open('xb') as stream:
            stream.write(data)
    except FileExistsError:
        if output.read_bytes() != data:
            raise FileExistsError(f'Refusing to replace different file: {output}')


def preserve(iso: Path, output: Path) -> dict:
    data = subprocess.check_output(['bsdtar', '-xOf', str(iso), ISO_ENTRY])
    if len(data) != TARGET_SIZE:
        raise ValueError(f'Unexpected executable size: {len(data)}')
    write_verified(data, output, TARGET_SHA256)
    return {
        'media': {'path': iso.name, 'size': iso.stat().st_size, 'sha256': sha256_file(iso)},
        'target': {'iso_entry': ISO_ENTRY, 'path': str(output), 'size': len(data),
                   'sha256': TARGET_SHA256},
        'dependencies': {
            name: {'commit': subprocess.check_output(
                ['git', '-C', name, 'rev-parse', 'HEAD'], text=True).strip(),
                   'upstream': url}
            for name, url in (
                ('dukenukem3d', 'https://github.com/videogamepreservation/dukenukem3d.git'),
                ('exhume', 'https://github.com/abedegno/Exhume.git'))
        },
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('iso', type=Path)
    parser.add_argument('--output', type=Path, default=Path('reference/DUKE3D.EXE'))
    parser.add_argument('--manifest', type=Path, default=Path('evidence/inputs.json'))
    args = parser.parse_args()
    result = preserve(args.iso, args.output)
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result['target'], indent=2))
