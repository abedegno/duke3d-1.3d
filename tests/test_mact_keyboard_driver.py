"""Fresh ordinary-C keyboard proof and strict whole-module damage controls."""
from copy import deepcopy
import hashlib
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from tools.prove_module import prove
from tools.verify_module import verify_module,ModuleError,external_anchor_bindings


class KeyboardDriverTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        parent=ROOT/'build/mact-keyboard-tests';parent.mkdir(parents=True,exist_ok=True)
        cls.work=Path(tempfile.mkdtemp(prefix='native-',dir=parent))
        cls.inputs=[ROOT/'src/mact/keyboard.c',ROOT/'modules/mact_keyboard.json',
                    ROOT/'src/mact/keyboard/keyboard.h',ROOT/'src/mact/keyboard/types.h',
                    ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe',ROOT/'reference/DUKE3D.EXE']
        cls.before={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in cls.inputs}
        cls.report=prove('mact_keyboard',ROOT/'toolchains/watcom-10.0-ga',cls.work/'positive')
        cls.module=Module.parse((cls.work/'positive/mact_keyboard.obj').read_bytes())
        cls.image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        (cls.work/'snapshot.json').write_text(json.dumps(cls.before,indent=2)+'\n')

    @classmethod
    def tearDownClass(cls):
        if cls.before!={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in cls.inputs}:
            raise AssertionError('keyboard source/tool/target changed during tests')

    def verify(self,module=None,symbols=None):
        return verify_module(module or self.module,self.image,self.report['placements'],
                             symbols if symbols is not None else self.report['verification']['publics'])

    def test_standard_route_builds_complete_module_and_scopes(self):
        proof=self.report['verification']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),
                         (1906,397,171))
        self.assertEqual(self.report['placements'],{1:(1,568512),2:(3,25624),4:(3,70408),5:(3,2130656)})
        self.assertEqual(len(proof['local_symbols']),8)
        exports=external_anchor_bindings(proof)
        for name in proof['local_symbols']:self.assertNotIn(name,exports)
        self.assertIn('_KB_KeyDown',exports);self.assertIn('_KB_LastScan',exports)
        self.assertFalse(self.report['full_executable_rebuilt'])
        self.assertEqual(sorted(self.module.local_externals),[3,4,5,6,7,8,11,13])
        self.assertEqual((self.module.publics['_ScanStrings'],self.module.segments[3].size),((4,260),696))
        #109 actual pointers, not an invented110th entry for the historical bound.
        self.assertEqual((696-260)//4,109)

    def test_ascii_and_real_table_pointer_changes_fail(self):
        for offset in (4,4+83,132+103,260,692):
            m=deepcopy(self.module);m.segments[3].data[offset]^=1
            with self.subTest(offset=offset),self.assertRaises(ModuleError):self.verify(m)

    def test_whole_last_bytes_are_required_for_all_segments(self):
        for segment,offset in ((1,615),(2,593),(4,695),(5,396)):
            m=deepcopy(self.module);m.segments[segment-1].data[offset]^=1
            with self.subTest(segment=segment),self.assertRaises(ModuleError):self.verify(m)

    def test_missing_pointer_fixup_and_wrong_external_binding_fail(self):
        m=deepcopy(self.module)
        m.fixups=[f for f in m.fixups if not (f.segment==4 and f.offset==692)]
        with self.assertRaisesRegex(ModuleError,'unaccounted'):self.verify(m)
        symbols=dict(self.report['verification']['publics']);symbols['memset_']=(1,588145)
        with self.assertRaises(ModuleError):self.verify(symbols=symbols)

    def source_stage(self,label):
        stage=self.work/label;stage.mkdir()
        (stage/'src/mact').mkdir(parents=True)
        shutil.copyfile(ROOT/'src/mact/keyboard.c',stage/'src/mact/keyboard.c')
        shutil.copytree(ROOT/'src/mact/keyboard',stage/'src/mact/keyboard')
        (stage/'modules').mkdir();shutil.copyfile(ROOT/'modules/mact_keyboard.json',stage/'modules/mact_keyboard.json')
        (stage/'reference').mkdir();(stage/'reference/DUKE3D.EXE').symlink_to(ROOT/'reference/DUKE3D.EXE')
        return stage

    def test_producer_does_not_need_original_sdk_or_primary_archive(self):
        stage=self.source_stage('source-only')
        with patch('tools.prove_module.ROOT',stage):
            result=prove('mact_keyboard',ROOT/'toolchains/watcom-10.0-ga',stage/'native')
        self.assertEqual(result['verification']['initialized_bytes'],1906)
        self.assertFalse((stage/'reference/duke3d-reconstructions/MACT386.LIB').exists())
        self.assertFalse((stage/'build/mact-source-research/rottsource.zip').exists())

    def source_negative(self,label,old,new):
        # Real native recompile of a source mutation; no mocked compiler result.
        stage=self.source_stage(label)
        source=stage/'src/mact/keyboard.c';text=source.read_text();self.assertEqual(text.count(old),1)
        source.write_text(text.replace(old,new))
        with patch('tools.prove_module.ROOT',stage),self.assertRaises(ValueError):
            prove('mact_keyboard',ROOT/'toolchains/watcom-10.0-ga',stage/'native')

    def test_exported_private_ascii_table_is_rejected(self):
        self.source_negative('scope','static char ASCIINames','char ASCIINames')

    def test_changed_key_event_condition_is_rejected(self):
        self.source_negative('event','scancode == sc_Kpad_Star','scancode != sc_Kpad_Star')


if __name__=='__main__':unittest.main()
