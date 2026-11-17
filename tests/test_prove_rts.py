from pathlib import Path
import tempfile
import unittest
from tools.prove_rts import prepare_headers


class RTSHeaderTests(unittest.TestCase):
    def test_ordered_overlays_preserve_shared_compatibility_headers(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            ref,shared,game=(root/name for name in ['ref','shared','game'])
            for p in [ref,shared,game]:p.mkdir()
            (ref/'PRAGMAS.H').write_text('later')
            (shared/'pragmas.h').write_text('period')
            (shared/'duke3d.h').write_text('shared')
            (game/'DUKE3D.H').write_text('measured game')
            prepare_headers(ref,[shared,game],root/'staged')
            self.assertEqual((root/'staged/pragmas.h').read_text(),'period')
            self.assertEqual((root/'staged/duke3d.h').read_text(),'measured game')

    def test_stages_multiple_reference_header_roots_then_overlay(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            first,second,overlay=(root/name for name in ['game','mact','overlay'])
            for path in [first,second,overlay]:path.mkdir()
            (first/'GAME.H').write_text('original game')
            (second/'TYPES.H').write_text('mact types')
            (overlay/'game.h').write_text('recovered game')
            prepare_headers([first,second],overlay,root/'staged')
            self.assertEqual((root/'staged/game.h').read_text(),'recovered game')
            self.assertEqual((root/'staged/types.h').read_text(),'mact types')
            self.assertEqual((first/'GAME.H').read_text(),'original game')
            (second/'GAME.H').write_text('conflicting reference')
            with self.assertRaisesRegex(ValueError,'reference header'):
                prepare_headers([first,second],overlay,root/'rejected')

    def test_stages_recovered_header_without_changing_reference(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);reference=root/'reference';overlay=root/'overlay'
            reference.mkdir();overlay.mkdir()
            (reference/'TEST.H').write_text('original')
            (reference/'other.c').write_text('omit')
            (overlay/'test.h').write_text('recovered')
            prepare_headers(reference,overlay,root/'staged')
            self.assertEqual((root/'staged/test.h').read_text(),'recovered')
            self.assertEqual((reference/'TEST.H').read_text(),'original')
            self.assertFalse((root/'staged/other.c').exists())
