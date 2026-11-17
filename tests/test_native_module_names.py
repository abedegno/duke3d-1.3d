"""Native naming must preserve runtime behavior and real library members."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from le import LEImage
from runner import compile_source, assemble_source, run_batch
from tools.infer_bindings import infer_bindings
from tools.verify_module import verify_module
from tools.inventory_watcom_runtime import read_archive

HOME = ROOT/'toolchains/watcom-10.0-ga'


@unittest.skipUnless((HOME/'BINB/wcc386.exe').is_file() and shutil.which('dosbox-x'),
                     'private native compiler required')
class NativeModuleNamesTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        parent = ROOT/'build/native-module-names'
        parent.mkdir(parents=True, exist_ok=True)
        cls.work = Path(tempfile.mkdtemp(prefix='native-', dir=parent))
        cls.sources = {}
        for name, text in {
            'A': 'char module_file[] = __FILE__;\nstatic int internal_count=3;\n'
                 'int package_a(int n) { return n+16+internal_count; }\n',
            'B': 'static int internal_count=3;\n'
                 'int package_b(int n) { return n*2+internal_count; }\n',
            'MAIN': 'int package_a(int); int package_b(int);\n'
                    'int main(void) { return package_a(6)+package_b(7)!=42; }\n',
        }.items():
            source = cls.work/(name+'.C')
            source.write_text(text)
            cls.sources[name] = source
            compile_source(HOME, source, cls.work/(name+'BASE.OBJ'), ['/4r','/s','/or'])

    def named(self, source, output, name, options=None):
        try:
            return compile_source(HOME, source, output, options or ['/4r','/s','/or'],
                                  module_name=name)
        except TypeError as error:
            self.fail('C runner lacks the optional native module-name interface: '+str(error))

    def api(self):
        try:
            from tools.native_library import build_library
        except ImportError as error:
            self.fail('checked native library builder is missing: '+str(error))
        return build_library

    def pair(self, directory):
        objects = []
        for source, name in [('A','PACKA'), ('B','PACKB')]:
            obj = directory/(source+'.OBJ')
            self.named(self.sources[source], obj, name)
            objects.append(obj)
        return objects

    def test_opt_in_name_keeps_source_macro_runtime_and_private_scope(self):
        named = self.work/'PACKA.OBJ'
        self.named(self.sources['A'], named, 'PACKA')
        before = Module.parse((self.work/'ABASE.OBJ').read_bytes())
        after = Module.parse(named.read_bytes())
        self.assertTrue(before.name.endswith('SOURCE.C'))
        self.assertEqual(after.name, 'PACKA')
        self.assertTrue(any(b'SOURCE.C\0' in s.data for s in after.segments))
        self.assertTrue(after.local_publics)
        for field in ('segments','publics','local_publics','externals','groups','fixups',
                      'local_externals','default_libraries'):
            self.assertEqual(getattr(before,field), getattr(after,field), field)

    def test_invalid_ids_and_conflicting_option_preserve_existing_output(self):
        output = self.work/'UNCHANGED.OBJ'
        output.write_bytes(b'previous output')
        for name in ('', 'NINECHARS', 'A.B', '../BAD', 'A B', 'A\nB', 'A>OUT'):
            with self.subTest(name=name), self.assertRaises(ValueError):
                self.named(self.sources['A'], output, name)
            self.assertEqual(output.read_bytes(), b'previous output')
        with self.assertRaises(ValueError):
            self.named(self.sources['A'], output, 'PACKA', ['/4r','/nm=OTHER'])
        self.assertEqual(output.read_bytes(), b'previous output')

    def test_actual_debug_profile_keeps_macro_bytes_and_raw_fixups(self):
        options = ['/zq','/dNOSEM','/d2','/mf','/ot','/s','/of+','/or']
        before_path, after_path = self.work/'DBGBASE.OBJ', self.work/'DBGNAMED.OBJ'
        compile_source(HOME, self.sources['A'], before_path, options)
        self.named(self.sources['A'], after_path, 'PACKA', options)
        before, after = [Module.parse(p.read_bytes()) for p in (before_path,after_path)]
        self.assertEqual(before.fixups, after.fixups)
        self.assertEqual(before.publics, after.publics)
        self.assertEqual(before.local_publics, after.local_publics)
        self.assertEqual(before.externals, after.externals)
        self.assertEqual(before.groups, after.groups)
        changed_empty = []
        for index,(old,new) in enumerate(zip(before.segments,after.segments),1):
            if old.class_name in ('DEBTYP','DEBSYM'):
                continue
            self.assertEqual((old.size,old.attributes,old.access,old.data,old.class_name),
                             (new.size,new.attributes,new.access,new.data,new.class_name))
            if old.name != new.name:
                self.assertEqual((old.size,old.class_name),(0,'FAR_DATA'))
                self.assertTrue(old.name.startswith('SOURCE'))
                self.assertEqual(new.name,'PACKA'+old.name[6:])
                self.assertFalse(any(segment==index for segment,_ in after.publics.values()))
                self.assertFalse(any(f.segment==index or f.target_method==0 and f.target==index
                                     for f in after.fixups))
                changed_empty.append(index)
        self.assertTrue(any(b'SOURCE.C\0' in s.data for s in after.segments
                            if s.class_name not in ('DEBTYP','DEBSYM')))
        old_types = next(s for s in before.segments if s.name=='$$TYPES')
        new_types = next(s for s in after.segments if s.name=='$$TYPES')
        # This no-include fixture has no debug filename table. The full GF1
        # source below separately measures that context-dependent metadata.
        self.assertEqual(old_types.data,new_types.data)

    @unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file(), 'private target required')
    def test_recovered_debug_source_measures_empty_far_name_and_full_native_proof(self):
        from tools.object_contributions import without_watcom_debug
        folder = Path(tempfile.mkdtemp(prefix='gf1-',dir=self.work))
        source = ROOT/'src/gf1/gf1addr.c'
        spec = json.loads((ROOT/'modules/gf1_addr.json').read_text())
        headers = ROOT/'src/gf1/include'
        inputs = [source,*headers.glob('*.h')]
        before_hashes = {str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs}
        baseline, named = folder/'BASE.OBJ', folder/'NAMED.OBJ'
        compile_source(HOME,source,baseline,spec['options'],include_dirs=[headers])
        try:
            compile_source(HOME,source,named,spec['options'],include_dirs=[headers],
                           module_name='GF1ADDR')
        except TypeError as error:
            self.fail('C runner lacks optional native module identity: '+str(error))
        old,new = [Module.parse(p.read_bytes()) for p in (baseline,named)]
        self.assertEqual(old.fixups,new.fixups)
        self.assertEqual(old.publics,new.publics)
        self.assertEqual(old.local_publics,new.local_publics)
        self.assertEqual(old.externals,new.externals)
        renamed = []
        for index,(a,b) in enumerate(zip(old.segments,new.segments),1):
            if a.class_name in ('DEBTYP','DEBSYM'):
                continue
            self.assertEqual((a.class_name,a.size,a.attributes,a.access,a.data),
                             (b.class_name,b.size,b.attributes,b.access,b.data))
            if a.name != b.name:
                self.assertEqual((a.size,a.class_name),(0,'FAR_DATA'))
                self.assertEqual((a.name,b.name),('SOURCE11_DATA','GF1ADDR11_DATA'))
                self.assertFalse(any(segment==index for segment,_ in new.publics.values()))
                self.assertFalse(any(f.segment==index or f.target_method==0 and f.target==index
                                     for f in new.fixups))
                renamed.append(index)
        self.assertEqual(len(renamed),1)
        image = LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        expected = json.loads((ROOT/'evidence/gf1_addr-module.json').read_text())['verification']
        proofs = []
        for module in (old,new):
            runtime,excluded = without_watcom_debug(module)
            inferred = infer_bindings(runtime,image,spec['code_object'],spec['code_offset'],
                                      known_symbols=spec.get('symbol_anchors',{}))
            proof = verify_module(runtime,image,inferred['placements'],inferred['symbols'])
            self.assertEqual(json.loads(json.dumps(proof)),expected)
            proofs.append({'excluded_actual_debug_metadata':excluded,'verification':proof})
        self.assertNotEqual(proofs[0]['excluded_actual_debug_metadata'],
                            proofs[1]['excluded_actual_debug_metadata'])
        self.assertEqual({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs},
                         before_hashes)
        (folder/'proofs.json').write_text(json.dumps(proofs,indent=2)+'\n')

    def test_named_library_preserves_raw_members_and_runs_direct_and_lazy(self):
        build = self.api()
        folder = Path(tempfile.mkdtemp(prefix='link-',dir=self.work))
        objects = self.pair(folder)
        report = build(HOME,objects,folder/'archive')
        library = Path(report['library'])
        raw = library.read_bytes()
        archive = read_archive(raw)
        self.assertEqual(len(archive['members']),2)
        self.assertEqual({m['sha256'] for m in archive['members']},
                         {hashlib.sha256(p.read_bytes()).hexdigest() for p in objects})
        self.assertEqual(set(report['exports']),{'package_a_','package_b_','_module_file'})
        self.assertEqual(report['source_credit'],0)
        shutil.copyfile(library,folder/'OWN.LIB')
        shutil.copyfile(self.work/'MAINBASE.OBJ',folder/'MAIN.OBJ')
        for mode in ('DIRECT','LAZY'):
            (folder/(mode+'.LNK')).write_text('system dos4g\noption quiet,map='+mode+
                '.MAP,stack=4096\nname '+mode+'.EXE\nfile MAIN.OBJ\n'+
                ('file A.OBJ,B.OBJ\n' if mode=='DIRECT' else 'library OWN.LIB\n'))
        batch = ('@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
                 'set LIB=D:\\LIB386;D:\\LIB386\\DOS\r\n')
        for mode in ('DIRECT','LAZY'):
            batch += ('wlink @'+mode+'.LNK > '+mode+'.LOG\r\n'
                      'if errorlevel 1 goto failed\r\n'+mode+'.EXE > '+mode+'.RUN\r\n'
                      'if errorlevel 1 goto failed\r\n')
        batch += ('echo OK>STATUS.TXT\r\ngoto end\r\n:failed\r\necho FAILED>STATUS.TXT\r\n:end\r\n')
        run_batch(HOME,folder,batch,30)
        self.assertEqual((folder/'STATUS.TXT').read_text().strip(),'OK')
        proofs = {}
        for mode in ('DIRECT','LAZY'):
            mapping = (folder/(mode+'.MAP')).read_text()
            symbols = {n:(int(o,16),int(p,16)) for o,p,n in re.findall(
                r'^\s*([0-9a-fA-F]{4}):([0-9a-fA-F]{8})[ *+]+(\w+)\s*$',mapping,re.M)}
            image = LEImage.parse((folder/(mode+'.EXE')).read_bytes())
            proofs[mode] = {}
            for name,pub,obj in [('MAIN','main_',folder/'MAIN.OBJ'),
                                 ('A','package_a_',objects[0]),('B','package_b_',objects[1])]:
                module = Module.parse(obj.read_bytes())
                target,start = symbols[pub]
                inferred = infer_bindings(module,image,target,start-module.publics[pub][1],
                                          known_symbols=symbols)
                proofs[mode][name] = verify_module(module,image,inferred['placements'],inferred['symbols'])
            if mode=='LAZY':
                self.assertIn('OWN.LIB(PACKA)',mapping)
                self.assertIn('OWN.LIB(PACKB)',mapping)
            self.assertTrue(all(p['verified'] for p in proofs[mode].values()))
        (folder/'proofs.json').write_text(json.dumps(proofs,indent=2)+'\n')

    def test_archive_rejects_stem_case_collisions_before_native_output(self):
        build = self.api()
        # The native default SOURCE.C objects already collide, though exported
        # functions differ. This catches the actual original packaging failure.
        stage = self.work/'bad-default-archive'
        with self.assertRaises(ValueError):
            build(HOME,[self.work/'ABASE.OBJ',self.work/'BBASE.OBJ'],stage)
        self.assertFalse(stage.exists())
        folder = Path(tempfile.mkdtemp(prefix='collision-',dir=self.work))
        self.named(self.sources['A'],folder/'A.OBJ','PACKA')
        self.named(self.sources['B'],folder/'B.OBJ','packa')
        with self.assertRaises(ValueError):
            build(HOME,[folder/'A.OBJ',folder/'B.OBJ'],folder/'archive')
        self.assertFalse((folder/'archive').exists())

    def test_archive_rejects_duplicate_global_definitions_not_private_locals(self):
        build = self.api()
        folder = Path(tempfile.mkdtemp(prefix='duplicate-',dir=self.work))
        self.named(self.sources['A'],folder/'A.OBJ','PACKA')
        source = folder/'DUP.C'
        source.write_text('int PACKAGE_A(int n) { return n; }\n')
        self.named(source,folder/'DUP.OBJ','OTHER')
        with self.assertRaises(ValueError):
            build(HOME,[folder/'A.OBJ',folder/'DUP.OBJ'],folder/'archive')
        self.assertFalse((folder/'archive').exists())

    def test_archive_rejects_post_native_object_race(self):
        build = self.api()
        import tools.native_library as library
        original = library.run_batch
        for location in ('original','staged'):
            folder = Path(tempfile.mkdtemp(prefix='race-',dir=self.work))
            objects = self.pair(folder)
            def raced(*args):
                original(*args)
                changed = objects[0] if location=='original' else Path(args[1])/'O001.OBJ'
                raw = bytearray(changed.read_bytes())
                raw[-1] ^= 1
                changed.write_bytes(raw)
            with self.subTest(location=location),patch.object(library,'run_batch',raced),self.assertRaises(ValueError):
                build(HOME,objects,folder/'archive')

    def test_archive_rejects_changed_native_member_even_when_runtime_is_same(self):
        build = self.api()
        import tools.native_library as library
        folder = Path(tempfile.mkdtemp(prefix='member-',dir=self.work))
        objects = self.pair(folder)
        original = library.run_batch
        def corrupt(*args):
            original(*args)
            path = Path(args[1])/'SOURCE.LIB'
            raw = bytearray(path.read_bytes())
            member = read_archive(raw)['members'][0]
            pos = member['offset']
            while pos < member['end']:
                end = pos+3+int.from_bytes(raw[pos+1:pos+3],'little')
                if raw[pos]==0x88 and raw[pos+4]==0xe9:
                    raw[pos+5] ^= 1  # dependency time only, no runtime byte
                    raw[end-1] = (-sum(raw[pos:end-1]))&255
                    path.write_bytes(raw)
                    return
                pos = end
            self.fail('native dependency comment missing from own fixture')
        with patch.object(library,'run_batch',corrupt),self.assertRaises(ValueError):
            build(HOME,objects,folder/'archive')

    def test_archive_rechecks_output_after_member_verification(self):
        build = self.api()
        import tools.native_library as library
        folder = Path(tempfile.mkdtemp(prefix='late-output-',dir=self.work))
        objects = self.pair(folder)
        original = library.read_archive
        def raced(raw):
            result = original(raw)
            path = folder/'archive/SOURCE.LIB'
            changed = bytearray(path.read_bytes())
            changed[-1] ^= 1
            path.write_bytes(changed)
            return result
        with patch.object(library,'read_archive',raced),self.assertRaises(ValueError):
            build(HOME,objects,folder/'archive')

    def test_archive_rejects_emulator_selection_change_after_native_run(self):
        build = self.api()
        import tools.native_library as library
        folder = Path(tempfile.mkdtemp(prefix='tool-selection-',dir=self.work))
        objects = self.pair(folder)
        original = library.run_batch
        def raced(*args):
            original(*args)
            os.environ['EXHUME_DOSBOX_X'] = str(folder/'different-dosbox')
        with patch.dict(os.environ,{}),patch.object(library,'run_batch',raced),self.assertRaises(ValueError):
            build(HOME,objects,folder/'archive')

    def test_archive_requires_new_directory_and_nonempty_inputs(self):
        build = self.api()
        folder = Path(tempfile.mkdtemp(prefix='fresh-',dir=self.work))
        objects = self.pair(folder)
        with self.assertRaises(ValueError):
            build(HOME,[],folder/'empty')
        with self.assertRaises(FileExistsError):
            build(HOME,objects,folder)


class AssemblerSourceNameTests(unittest.TestCase):
    def test_dos_device_basename_is_rejected_before_native_file_access(self):
        from runner import assembly_source_name
        for name in ('NUL.ASM','con.asm','PRN.ASM','AUX.ASM','COM1.ASM','LPT9.ASM'):
            with self.subTest(name=name),self.assertRaises(ValueError):
                assembly_source_name(name)

    @unittest.skipUnless(all(p.is_file() for p in (
        ROOT/'toolchains/tasm-3.1/TASM.EXE', ROOT/'toolchains/masm-5.10/MASM.EXE',
        HOME/'BINB/wasm.exe')) and shutil.which('dosbox-x'), 'private native assemblers required')
    def test_actual_native_assemblers_keep_source_runtime_with_real_names(self):
        cases = [('tasm','tasm-3.1',['/t','/mx']),('masm','masm-5.10',['/MX']),
                 ('wasm','watcom-10.0-ga',[])]
        for producer,version,options in cases:
            with self.subTest(producer=producer),tempfile.TemporaryDirectory() as directory:
                folder = Path(directory)
                source = folder/'leaf.asm'
                source.write_text('.386P\nCODE SEGMENT PUBLIC USE32 \'CODE\'\nASSUME CS:CODE\n'
                                  'PUBLIC sample_\nsample_: mov eax,42\nret\nCODE ENDS\nEND\n')
                home = ROOT/('toolchains/'+version)
                if producer=='wasm':
                    from tools.probe_mact_asm import assemble_native
                    assemble_native(home,source,folder/'BASE.OBJ')
                    fn = lambda name:assemble_native(home,source,folder/'NAMED.OBJ',source_name=name)
                else:
                    assemble_source(home,source,folder/'BASE.OBJ',options,producer=producer)
                    fn = lambda name:assemble_source(home,source,folder/'NAMED.OBJ',options,
                                                     producer=producer,source_name=name)
                try:
                    fn('LEAF.ASM')
                except TypeError as error:
                    self.fail('assembler lacks optional native filename interface: '+str(error))
                before,after = [Module.parse((folder/n).read_bytes()) for n in ('BASE.OBJ','NAMED.OBJ')]
                self.assertEqual(before.name,'SOURCE.ASM')
                self.assertEqual(after.name,'LEAF.ASM')
                for field in ('segments','fixups','publics','local_publics','externals','groups'):
                    self.assertEqual(getattr(before,field),getattr(after,field),field)
                for bad in ('../X.ASM','LONGER123.ASM','A.C','A B.ASM','X.ASM\n'):
                    with self.assertRaises(ValueError):
                        fn(bad)
