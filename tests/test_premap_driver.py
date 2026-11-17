"""Require native abort ownership and reject obsolete BSS placement overrides."""
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools import prove_module
from tools.verify_module import external_anchor_bindings
from tools.probe_premap import Module

ROOT=Path(__file__).resolve().parents[1]


class BoundaryRoutingTests(unittest.TestCase):
    def test_other_module_cannot_request_premap_boundary(self):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary);(root/'modules').mkdir()
            (root/'modules/rts.json').write_text(json.dumps({'bss_boundary':{'kind':'ordered-public-paragraph-boundaries'}}))
            with patch.object(prove_module,'ROOT',root):
                with self.assertRaisesRegex(ValueError,'BSS boundary'):
                    prove_module.prove('rts',root/'unused-home',root/'unused-build')

    def test_premap_cannot_request_arbitrary_boundary(self):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary);(root/'modules').mkdir()
            (root/'modules/premap.json').write_text(json.dumps({'bss_boundary':{'kind':'arbitrary-placement'}}))
            with patch.object(prove_module,'ROOT',root):
                with self.assertRaisesRegex(ValueError,'BSS boundary'):
                    prove_module.prove('premap',root/'unused-home',root/'unused-build')

    @unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                         (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file() ,
                         'private target/compiler required')
    def test_complete_native_premap_through_standard_driver(self):
        with tempfile.TemporaryDirectory() as temporary:
            report=prove_module.prove('premap',ROOT/'toolchains/watcom-10.0-ga',Path(temporary)/'native')
            module=Module.parse((Path(temporary)/'native/premap.obj').read_bytes())
        self.assertEqual(module.publics.get('_wait_abort'),(5,4))
        self.assertNotIn('_wait_abort',module.local_publics)
        proof=report['verification']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),
                         (12932,5,815))
        self.assertTrue(proof['verified'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertNotIn('bss_boundary',report)
        self.assertNotIn('boundary_evidence',report)
        self.assertEqual(tuple(external_anchor_bindings(proof)['_wait_abort']),(3,587556))
        self.assertEqual(tuple(proof['local_symbols']['_dmval']),(3,587552))
        self.assertNotIn('_dmval',external_anchor_bindings(proof))

    @unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                         (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                         'private target/compiler required')
    def test_abort_export_resolves_an_independent_native_byte_consumer(self):
        # Full PREMAP still needs other game/SDK owners. No dummy definitions
        # or undefined-symbol waiver is used: both diagnostic links must fail,
        # and only the real owned byte may leave their undefined sets.
        import re
        from runner import compile_source,run_batch
        from tools.prove_module import prepare_headers
        home=ROOT/'toolchains/watcom-10.0-ga'
        with tempfile.TemporaryDirectory() as temporary:
            base=Path(temporary);report=prove_module.prove('premap',home,base/'fixed')
            spec=json.loads((ROOT/'modules/premap.json').read_text())
            headers=base/'include';prepare_headers([ROOT/p for p in spec['reference_headers']],
                                                 [ROOT/p for p in spec['overlay_headers']],headers)
            text=(ROOT/'src/game/premap.c').read_text();self.assertEqual(text.count('char wait_abort;'),1)
            wrong=base/'EXTERN.C';wrong.write_text(text.replace('char wait_abort;','extern char wait_abort;'))
            compile_source(home,wrong,base/'EXTERN.OBJ',spec['options'],30,include_dirs=[headers])
            consumer=base/'MAIN.C';consumer.write_text('extern char wait_abort;\nint main(void) { return wait_abort; }\n')
            compile_source(home,consumer,base/'MAIN.OBJ',['/4r','/s','/ort'],30)
            missing={}
            for label,obj in [('EXTERN','EXTERN.OBJ'),('OWNED','fixed/premap.obj')]:
                (base/(label+'.LNK')).write_text('system dos4g\noption quiet,map='+label+'.MAP\nname '+label+'.EXE\nfile MAIN.OBJ,'+obj.replace('/','\\')+'\n')
                batch=('@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
                       'set LIB=D:\\LIB386;D:\\LIB386\\DOS\r\nwlink @'+label+'.LNK > '+label+'.LOG\r\n'
                       'if errorlevel 1 goto failed\r\necho OK>'+label+'.STA\r\ngoto end\r\n'
                       ':failed\r\necho FAILED>'+label+'.STA\r\n:end\r\n')
                run_batch(home,base,batch,30);log=(base/(label+'.LOG')).read_text()
                self.assertEqual((base/(label+'.STA')).read_text().strip(),'FAILED',log)
                self.assertFalse((base/(label+'.EXE')).exists())
                missing[label]=set(re.findall(r'Warning\(1028\): (\S+) is an undefined reference',log))
            self.assertIn('_wait_abort',missing['EXTERN'])
            self.assertEqual(missing['EXTERN']-missing['OWNED'],{'_wait_abort'})
            self.assertEqual(missing['OWNED']-missing['EXTERN'],set())
            self.assertEqual(tuple(external_anchor_bindings(report['verification'])['_wait_abort']),(3,587556))
