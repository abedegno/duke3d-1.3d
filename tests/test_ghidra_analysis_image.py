"""The decompiler input is a relocated copy, never the byte-proof input."""
from pathlib import Path
import hashlib
import json
import tempfile
import unittest
from tools.export_ghidra_image import export_image, ROOT
from profiles.watcom.tools.le import LEImage
from tools.preserve import TARGET_SHA256


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file(),'private target required')
class GhidraAnalysisImageTests(unittest.TestCase):
    def test_loader_operands_in_separate_objects_and_original_unchanged(self):
        target=ROOT/'reference/DUKE3D.EXE';before=target.read_bytes()
        image=LEImage.parse(before)
        with tempfile.TemporaryDirectory() as directory:
            report=export_image(target,Path(directory)/'analysis')
            self.assertEqual(report['target_sha256'],TARGET_SHA256)
            self.assertEqual(report['unique_fixups_applied'],27363)
            self.assertFalse(report['recovered_source'])
            blobs=[(Path(directory)/'analysis'/o['file']).read_bytes() for o in report['objects']]
            self.assertEqual([len(b) for b in blobs],[o.size for o in image.objects])
            for f in image.read_fixups():
                at=image.objects[f.source_object-1].base+f.source_offset
                expected=f.target_address if f.source_type==7 else f.target_address-at-4
                blob=blobs[f.source_object-1]
                actual=int.from_bytes(blob[f.source_offset:f.source_offset+4],'little')
                self.assertEqual(actual,expected&0xffffffff)
            # Bytes outside loader operands must survive the analysis export too.
            for n,blob in enumerate(blobs,1):
                covered=set()
                for f in image.read_fixups():
                    if f.source_object==n: covered.update(range(f.source_offset,f.source_offset+f.width))
                original=image.object_bytes(n)
                self.assertTrue(all(a==b for i,(a,b) in enumerate(zip(original,blob)) if i not in covered))
        self.assertEqual(target.read_bytes(),before)
        self.assertEqual(hashlib.sha256(before).hexdigest(),TARGET_SHA256)

    def test_wrong_reference_rejected_before_export(self):
        with tempfile.TemporaryDirectory() as directory:
            target=Path(directory)/'wrong.exe';target.write_bytes(b'MZ wrong target')
            out=Path(directory)/'analysis'
            with self.assertRaisesRegex(ValueError,'identity'):
                export_image(target,out)
            self.assertFalse(out.exists())
