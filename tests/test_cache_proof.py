from pathlib import Path
import tempfile
import unittest
from tools.prove_module import ROOT, prove


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class CacheProofTests(unittest.TestCase):
    def test_complete_cache_uses_shared_engine_size(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('cache1d',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (5415,49453,332))
        self.assertEqual(v['publics']['_cachesize'],(3,31681))
        self.assertEqual(v['publics']['initcache_'],(1,418275))
        self.assertEqual(v['publics']['_reserved_cache_size'],(3,32073))
        self.assertFalse(report['full_executable_rebuilt'])

    def test_cache_arrays_link_to_an_independent_consumer(self):
        # A linker-only fixture: no generated executable is run or credited
        # as recovered game output. Other cache internals must remain local.
        from runner import compile_source, run_batch
        from tools.verify_module import external_anchor_bindings
        with tempfile.TemporaryDirectory() as directory:
            work=Path(directory)
            report=prove('cache1d',ROOT/'toolchains/watcom-10.0-ga',work)
            source=work/'MAIN.C'
            source.write_text('#include <stdlib.h>\n'
                              'extern long cacleng[], cacnum;\n'
                              'extern char *lockptr[];\n'
                              'long cachesize;\n'
                              'char *kmalloc(long n) { return malloc(n); }\n'
                              'void kfree(void *p) { free(p); }\n'
                              'int main(void) { return cacnum + cacleng[0] + (lockptr[0] != 0); }\n')
            home=ROOT/'toolchains/watcom-10.0-ga'
            compile_source(home,source,work/'MAIN.OBJ',['/4r','/s','/ort'],30)
            (work/'LINK.LNK').write_text('system dos4g\noption quiet,map=LINK.MAP,stack=4096\n'
                                       'name LINK.EXE\nfile MAIN.OBJ,cache1d.obj\n')
            batch=('@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
                   'set LIB=D:\\LIB386;D:\\LIB386\\DOS\r\nwlink @LINK.LNK > LINK.LOG\r\n'
                   'if errorlevel 1 goto failed\r\necho OK>LINK.STA\r\ngoto end\r\n'
                   ':failed\r\necho FAILED>LINK.STA\r\n:end\r\n')
            run_batch(home,work,batch,30)
            log=(work/'LINK.LOG').read_text(errors='replace')
            self.assertEqual((work/'LINK.STA').read_text().strip(),'OK',log)
            self.assertTrue((work/'LINK.EXE').is_file(),log)
            anchors=external_anchor_bindings(report['verification'])
            self.assertEqual(anchors['_lockptr'],(3,1665920))
            self.assertEqual(anchors['_cacleng'],(3,1682304))
            self.assertEqual(anchors['_cacnum'],(3,32077))
            for name in ('_lockptr','_cacleng','_cacnum'):
                self.assertNotIn(name,report['verification']['local_symbols'])
                self.assertIn(name,(work/'LINK.MAP').read_text())
            for name in ('_handptr','_dmval','_cachestart','_reserved_cache_size','_agecount'):
                self.assertIn(name,report['verification']['local_symbols'])
                self.assertNotIn(name,anchors)
