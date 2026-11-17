"""Check the engine's BSS symbols and extent without claiming whole-engine identity."""
import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from tools.prove_module import ROOT
from omf32 import Module
from runner import compile_source
from tools.probe_engine import OPTIONS, INCLUDES


REFERENCE = ROOT/'reference/historical/kenbuild-related-archives-20241213/BUILD_MISC_199604/OBJLIBS/ENGINE.OBJ'
COMPILER = ROOT/'toolchains/watcom-10.5'


@unittest.skipUnless(REFERENCE.is_file() and (COMPILER/'BINW/wcc386.exe').is_file(),
                     'private historical object and compiler required')
class EngineStateTests(unittest.TestCase):
    def test_bss_symbols_and_extent(self):
        raw = REFERENCE.read_bytes()
        manifest = json.loads((ROOT/'evidence/historical-engine-object-match.json').read_text())
        self.assertEqual(hashlib.sha256(raw).hexdigest(), manifest['sha256'])
        reference = Module.parse(raw)
        with tempfile.TemporaryDirectory() as directory:
            obj = Path(directory)/'engine.obj'
            compile_source(COMPILER, ROOT/'src/engine/engine.c', obj,
                           OPTIONS, 60, include_dirs=[ROOT/p for p in INCLUDES])
            recovered = Module.parse(obj.read_bytes())

        def inventory(module):
            segments = [n for n,s in enumerate(module.segments,1)
                        if s.class_name.upper() == 'BSS' and s.size]
            self.assertEqual(len(segments), 1)
            number = segments[0]
            segment = module.segments[number-1]
            self.assertFalse(any(segment.data))
            self.assertFalse(any(f.segment == number for f in module.fixups))
            return segment.size, {name:offset for name,(n,offset) in module.publics.items() if n == number}

        # Zero state, symbol offsets and total extent do not prove CODE or linking.
        self.assertEqual(inventory(recovered), inventory(reference))
