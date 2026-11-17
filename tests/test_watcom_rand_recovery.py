"""Source-built RAND: complete native state, scopes, and DOS configuration."""
import copy
from dataclasses import replace
import json
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest.mock import patch

from tools import prove_module
from tools.prove_module import ROOT, Module, LEImage, assert_contributions
from tools.verify_module import verify_module, ModuleError, external_anchor_bindings
from runner import CompilerError


HOME = ROOT/'toolchains/watcom-10.0-ga'


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (HOME/'BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class WatcomRandRecoveryTests(unittest.TestCase):
    def production_source(self):
        self.assertTrue((ROOT/'src/runtime/rand.c').is_file(),
                        'production RAND source missing')
        return (ROOT/'src/runtime/rand.c').read_text()

    def fixture(self, root, source=None, changes=None, header_change=None):
        (root/'modules').mkdir()
        (root/'reference').symlink_to(ROOT/'reference',target_is_directory=True)
        shutil.copytree(ROOT/'src/runtime',root/'src/runtime')
        if source is not None:
            (root/'src/runtime/rand.c').write_text(source)
        if header_change:
            name,old,new=header_change
            path=root/'src/runtime/include'/name
            body=path.read_text()
            self.assertIn(old,body)
            path.write_text(body.replace(old,new))
        spec=json.loads((ROOT/'modules/watcom_rand.json').read_text())
        spec.update(changes or {})
        (root/'modules/watcom_rand.json').write_text(json.dumps(spec))

    def test_complete_native_module_rejects_tail_state_callee_and_scope_damage(self):
        self.production_source()
        with tempfile.TemporaryDirectory() as temporary:
            build=Path(temporary)
            report=prove_module.prove('watcom_rand',HOME,build)
            module=Module.parse((build/'watcom_rand.obj').read_bytes())
            log=(build/'watcom_rand.log').read_text()
        proof=report['verification'];placements=report['placements'];symbols=proof['publics']
        self.assertTrue(proof['verified'])
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],
                          proof['verified_fixups']),(62,0,3))
        self.assertEqual({int(k):tuple(v) for k,v in placements.items()},
                         {1:(1,583791),4:(3,71832)})
        self.assertEqual([(s.name,s.class_name,s.size) for s in module.segments],
                         [('_TEXT','CODE',58),('CONST','DATA',0),('CONST2','DATA',0),
                          ('_DATA','DATA',4),('_BSS','BSS',0)])
        self.assertEqual(symbols,{'initrandnext_':(1,583791),'rand_':(1,583797),
                                 'srand_':(1,583833),'_next':(3,71832)})
        self.assertEqual(proof['local_symbols'],{'_next':(3,71832),
                                               'initrandnext_':(1,583791)})
        self.assertEqual(external_anchor_bindings(proof),
                         {'rand_':(1,583797),'srand_':(1,583833)})
        self.assertEqual(module.segments[3].data,b'\x01\x00\x00\x00')
        self.assertEqual(report['options'],['/3r','/s','/os'])
        self.assertEqual(report['compiler_sha256'],
                         'a4f4da1b8b2cd4e38b2b041975fc6b1d131255ae5eb575828b02f927fbf9bf65')
        self.assertEqual(report['source_sha256'],
                         'a74aee766c51bb5999c3772e406c752e99421376ed253aefec1db2723accdd0f')
        self.assertEqual(report['headers_sha256'],{
            'variety.h':'8e21561238003300c98822ed85057c82e15945eb695b93f145b93328d7caafbd',
            'randnext.h':'2470cd384271006888b89a28972926fc25840c8bb0aaab06ded7de57656a571c',
            'rtdata.h':'52af1ea57145c97048476d60db8a96ab7e26aa3dcabe5f051ec556c48c0ef230'})
        self.assertEqual(prove_module.digest(HOME/'H/stdio.h'),
                         'de275400f58feb96f19a1cd313f6906d7a3c849b9c2cfcba0fd7d619c341d6d1')
        self.assertIn('0 warnings, 0 errors',log)
        self.assertFalse(report['full_executable_rebuilt'])
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for segment,offset in [(1,0),(1,41),(1,57),(4,0),(4,3)]:
            damaged=copy.deepcopy(module);damaged.segments[segment-1].data[offset]^=1
            with self.subTest(segment=segment,offset=offset),self.assertRaises(ModuleError):
                verify_module(damaged,image,placements,symbols)
        damaged=copy.deepcopy(module)
        call=next(i for i,f in enumerate(damaged.fixups) if f.offset==8)
        damaged.fixups[call]=replace(damaged.fixups[call],
                                    displacement=damaged.fixups[call].displacement+1)
        with self.assertRaises(ModuleError):
            verify_module(damaged,image,placements,symbols)
        for name in ('rand_','srand_','initrandnext_','_next'):
            wrong=dict(symbols);obj,off=wrong[name];wrong[name]=(obj,off+1)
            with self.subTest(public=name),self.assertRaises(ModuleError):
                verify_module(module,image,placements,wrong)
        missing=dict(proof);del missing['local_symbols']
        with self.assertRaises(ValueError):external_anchor_bindings(missing)
        wrong=copy.deepcopy(proof);wrong['local_symbols']['_next']=(3,71833)
        with self.assertRaises(ValueError):external_anchor_bindings(wrong)
        damaged=copy.deepcopy(module)
        damaged.segments[3].size=3;damaged.segments[3].data=damaged.segments[3].data[:3]
        shortened=verify_module(damaged,image,placements,symbols)
        with self.assertRaises(ValueError):
            assert_contributions(shortened,{'initialized_bytes':62,'zero_fill_bytes':0,
                                            'verified_fixups':3})

    def test_source_algorithm_seed_and_configuration_corruption_are_rejected(self):
        source=self.production_source()
        cases=[('multiplier',source.replace('1103515245','1103515247'),None),
               ('seed_assignment',source.replace('*randptr = seed;','*randptr = seed + 1;'),None),
               ('initial_state',source,('randnext.h','next = 1;','next = 2;')),
               ('initializer',source,('randnext.h','#define _INITRANDNEXT(p)',
                                     '#define _INITRANDNEXT(p) next += 1')),
               ('linkage',source,('variety.h','#define _WCRTLINK\n',
                                 '#define _WCRTLINK __cdecl\n')),
               ('state_alias',source,('rtdata.h','#define _RWD_randnext _RANDNEXT',
                                     '#define _RWD_randnext (*((unsigned long *)0))'))]
        for name,body,header in cases:
            with self.subTest(case=name),tempfile.TemporaryDirectory() as temporary:
                root=Path(temporary);self.fixture(root,body,header_change=header)
                with patch.object(prove_module,'ROOT',root),self.assertRaises((ValueError,CompilerError)):
                    prove_module.prove('watcom_rand',HOME,root/'native')

    def test_missing_public_extent_and_contribution_are_rejected(self):
        source=self.production_source()
        cases=[('missing_public',source[:source.index('_WCRTLINK void srand')],
                {'code_bytes':42},'compiled CODE public count'),
               ('wrong_extent',source,{'code_bytes':57},'compiled text'),
               ('incomplete_total',source,{'expected':{'initialized_bytes':61,
                 'zero_fill_bytes':0,'verified_fixups':3}},'incomplete initialized_bytes')]
        for name,body,changes,error in cases:
            with self.subTest(case=name),tempfile.TemporaryDirectory() as temporary:
                root=Path(temporary);self.fixture(root,body,changes)
                with patch.object(prove_module,'ROOT',root),self.assertRaisesRegex(ValueError,error):
                    prove_module.prove('watcom_rand',HOME,root/'native')

    def test_configuration_guards_reject_other_targets_and_thread_models(self):
        source=self.production_source()
        cases=[(option,source,['/3r','/s','/os',option]) for option in
               ('/bt=nt','/bm','/d__SW_BR','/d__OS2__','/d__PENPOINT__')]
        cases.extend((macro,'#undef '+macro+'\n'+source,['/3r','/s','/os'])
                     for macro in ('__DOS__','__386__','__FLAT__'))
        for name,body,options in cases:
            with self.subTest(configuration=name),tempfile.TemporaryDirectory() as temporary:
                root=Path(temporary)
                self.fixture(root,body,changes={'options':options})
                with patch.object(prove_module,'ROOT',root),self.assertRaises(CompilerError):
                    prove_module.prove('watcom_rand',HOME,root/'native')
                self.assertIn('RAND configuration requires DOS 386 flat static runtime',
                              (root/'native/watcom_rand.log').read_text())
