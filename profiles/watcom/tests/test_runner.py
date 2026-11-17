from pathlib import Path
import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from runner import compile_source, run_batch, CompilerError, compiler_bin
import runner
from omf32 import Module


class CompilerLayoutTests(unittest.TestCase):
    def test_selects_binw_layout_for_later_compilers(self):
        with tempfile.TemporaryDirectory() as directory:
            home=Path(directory)
            (home/'BINW').mkdir()
            (home/'BINW/wcc386.exe').write_bytes(b'fixture')
            self.assertEqual(compiler_bin(home),'BINW')


@unittest.skipUnless((Path(__file__).resolve().parents[3]/'toolchains/tasm-3.1/TASM.EXE').is_file()
                     and shutil.which('dosbox-x'),'private TASM 3.1 required')
class AssemblerRunnerTests(unittest.TestCase):
    def test_real_assembly_and_failed_output_preservation(self):
        home=Path(__file__).resolve().parents[3]/'toolchains/tasm-3.1'
        with tempfile.TemporaryDirectory() as directory:
            work=Path(directory);source=work/'leaf.asm';output=work/'leaf.obj'
            source.write_text('IDEAL\nP386\nMODEL FLAT\nCODESEG\nMASM\n'
                              'PUBLIC sample_\nEXTRN other_:PROC\n'
                              'sample_ PROC NEAR\n call other_\n ret\n'
                              'sample_ ENDP\nEND\n')
            runner.assemble_source(home,source,output,['/t','/p','/mx','/w2'])
            module=Module.parse(output.read_bytes())
            self.assertIn('sample_',module.publics)
            self.assertEqual(len(module.fixups),1)
            self.assertEqual(module.externals,['other_'])
            original=output.read_bytes()
            source.write_text('THIS IS INVALID ASSEMBLY\nEND\n')
            with self.assertRaises(CompilerError):
                runner.assemble_source(home,source,output,['/t'])
            self.assertEqual(output.read_bytes(),original)
            source.write_text('END\n')
            with self.assertRaises(CompilerError):
                runner.assemble_source(home,source,output,['/?'])
            self.assertEqual(output.read_bytes(),original)


@unittest.skipUnless((Path(__file__).resolve().parents[3]/'toolchains/masm-5.10/MASM.EXE').is_file()
                     and shutil.which('dosbox-x'),'private MASM 5.10 required')
class MasmRunnerTests(unittest.TestCase):
    def test_real_native_masm_and_error_output_preservation(self):
        home=Path(__file__).resolve().parents[3]/'toolchains/masm-5.10'
        with tempfile.TemporaryDirectory() as directory:
            work=Path(directory);source=work/'leaf.asm';output=work/'leaf.obj'
            source.write_text('.386P\nCODE SEGMENT PUBLIC USE32 \'CODE\'\nASSUME CS:CODE\n'
                              'PUBLIC sample_\nEXTRN other_:NEAR\n'
                              'sample_: call other_\n ret\nCODE ENDS\nEND\n')
            runner.assemble_source(home,source,output,['/MX'],producer='masm')
            module=Module.parse(output.read_bytes())
            self.assertIn('sample_',module.publics)
            self.assertEqual(module.externals,['other_'])
            self.assertEqual(len(module.fixups),1)
            original=output.read_bytes()
            source.write_text('THIS IS INVALID ASSEMBLY\nEND\n')
            with self.assertRaises(CompilerError):
                runner.assemble_source(home,source,output,['/MX'],producer='masm')
            self.assertEqual(output.read_bytes(),original)


@unittest.skipUnless(os.environ.get('WATCOM_HOME') and shutil.which('dosbox-x'),
                     'set WATCOM_HOME to run historical compiler integration tests')
class RunnerTests(unittest.TestCase):
    def setUp(self):
        self.home = Path(os.environ['WATCOM_HOME']).resolve()
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)

    def test_compiles_real_register_abi_leaf(self):
        src = self.work / 'leaf.c'
        src.write_text('int twice(int x) { return x * 2; }\n')
        out = self.work / 'leaf.obj'
        compile_source(self.home, src, out, ['/5r','/s','/otexan'], 20)
        self.assertGreater(out.stat().st_size, 50)
        self.assertEqual(out.read_bytes()[0], 0x80)  # real OMF THEADR

    def test_invalid_c_is_reported_without_replacing_existing_output(self):
        src = self.work / 'bad.c'
        src.write_text('int broken( {\n')
        out = self.work / 'bad.obj'
        out.write_bytes(b'keep')
        with self.assertRaises(CompilerError):
            compile_source(self.home, src, out, ['/5r'], 20)
        self.assertEqual(out.read_bytes(), b'keep')

    def test_dos_batch_timeout(self):
        with self.assertRaises(TimeoutError):
            run_batch(self.home, self.work, '@echo off\r\n:loop\r\ngoto loop\r\n', 0.5)

    def test_missing_object_is_failure(self):
        src = self.work / 'nothing.c'
        src.write_text('int x;\n')
        with self.assertRaises(CompilerError):
            compile_source(self.home, src, self.work/'nothing.obj', ['/?'], 20)

    def test_stages_project_headers(self):
        includes=self.work/'headers'
        includes.mkdir()
        (includes/'answer.h').write_text('#define ANSWER 42\n')
        src=self.work/'with_header.c'
        src.write_text('#include "answer.h"\nint answer(void) {return ANSWER;}\n')
        out=self.work/'with_header.obj'
        compile_source(self.home,src,out,['/4r','/s','/otexan'],20,include_dirs=[includes])
        self.assertGreater(out.stat().st_size,50)
