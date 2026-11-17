"""Backward-compatible entry point for the complete RTS module proof."""
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from tools.prove_module import main,prepare_headers,digest
from tools.prove_module import prove as _prove


def prove(home: Path,build: Path) -> dict:
    return _prove('rts',home,build)


if __name__=='__main__':
    main('rts')
