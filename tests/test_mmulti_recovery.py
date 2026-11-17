from pathlib import Path
import copy
from dataclasses import replace
import hashlib
import json
import tempfile
import unittest

from tools.prove_module import ROOT,prove,Module,LEImage
from tools.verify_module import verify_module,ModuleError


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.5/BINW/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class NetworkRecoveryTests(unittest.TestCase):
    def test_complete_mmulti_with_original_empty_socket_export(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('mmulti',ROOT/'toolchains/watcom-10.5',Path(directory))
            m=Module.parse((Path(directory)/'mmulti.obj').read_bytes())
        v=report['verification']
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],
                          v['verified_fixups']),(2237,34510,165))
        self.assertEqual(v['publics']['setsocket_'],(1,423522))
        self.assertEqual(v['publics']['initmultiplayers_'],(1,423026))
        self.assertEqual(v['publics']['_connectpoint2'],(3,1733104))
        self.assertFalse(report['full_executable_rebuilt'])
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for index,s in enumerate(m.segments):
            if not s.size:
                continue
            damaged=copy.deepcopy(m);damaged.segments[index].data[-1]^=1
            with self.subTest(segment=s.name),self.assertRaises(ModuleError):
                verify_module(damaged,image,report['placements'],v['publics'])
        damaged=copy.deepcopy(m)
        damaged.fixups[0]=replace(damaged.fixups[0],displacement=m.fixups[0].displacement+1)
        with self.assertRaises(ModuleError):
            verify_module(damaged,image,report['placements'],v['publics'])
        # The optional historical object is a rechecked metadata reference,
        # never an input to the source producer or reconstructed output.
        ref=ROOT/'reference/historical/kenbuild-related-archives-20241213/BUILD_MISC_199604/OBJLIBS/MMULTI.OBJ'
        if ref.is_file():
            evidence=json.loads((ROOT/'evidence/historical-mmulti-object-match.json').read_text())
            self.assertEqual(hashlib.sha256(ref.read_bytes()).hexdigest(),evidence['sha256'])
            original=Module.parse(ref.read_bytes())
            self.assertEqual(original.publics,m.publics)
            verify_module(original,image,evidence['placements'],evidence['verification']['publics'])
