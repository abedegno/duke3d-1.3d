"""Complete native DEBUGIO ownership, including private helpers and state."""
import copy
from dataclasses import replace
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools import prove_module
from tools.prove_module import ROOT, Module, LEImage, assert_contributions
from tools.verify_module import verify_module, ModuleError, external_anchor_bindings


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0b/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class DebugIORecoveryTests(unittest.TestCase):
    def test_complete_native_source_rejects_tail_state_and_callee_damage(self):
        self.assertTrue((ROOT/'src/audio/debugio.c').is_file(),
                        'production DEBUGIO source missing')
        self.assertTrue((ROOT/'modules/debugio.json').is_file(),
                        'complete DEBUGIO descriptor missing')
        with tempfile.TemporaryDirectory() as directory:
            build=Path(directory)
            report=prove_module.prove('debugio',ROOT/'toolchains/watcom-10.0b',build)
            module=Module.parse((build/'debugio.obj').read_bytes())
            log=(build/'debugio.log').read_text()
        proof=report['verification'];placements=report['placements'];symbols=proof['publics']
        self.assertTrue(proof['verified'])
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],
                          proof['verified_fixups']),(763,0,14))
        self.assertEqual({int(k):tuple(v) for k,v in placements.items()},
                         {1:(1,528192),4:(3,62304)})
        self.assertEqual(symbols,{
            'DB_SetXY_':(1,528192),'DB_PutChar_':(1,528212),
            'DB_PrintString_':(1,528428),'myitoa_':(1,528516),
            'myutoa_':(1,528528),'DB_PrintNum_':(1,528560),
            'DB_PrintUnsigned_':(1,528636),'DB_printf_':(1,528688),
            '_disp_offset':(3,62304)})
        self.assertEqual(proof['local_symbols'],{
            '_disp_offset':(3,62304),'myitoa_':(1,528516),'myutoa_':(1,528528)})
        self.assertEqual(set(external_anchor_bindings(proof)),{
            'DB_SetXY_','DB_PutChar_','DB_PrintString_',
            'DB_PrintNum_','DB_PrintUnsigned_','DB_printf_'})
        self.assertEqual(module.segments[0].size,761)
        self.assertEqual(module.segments[3].size,2)
        self.assertEqual(sum(seg in {1} for seg,_ in module.publics.values()),8)
        self.assertEqual(module.segments[3].data,b'\x00\x0f')
        self.assertIn('0 warnings, 0 errors',log)
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['compiler_sha256'],
                         '2b6672b7cb109452a31cb7fd6bf6776f518f43466f66dc3efd8365708fd243c6')
        self.assertEqual(report['options'],
                         ['/omaxnet','/zp4','/5r','/dLIBVER_ASSREV=19960116'])
        spec=json.loads((ROOT/'modules/debugio.json').read_text())
        self.assertEqual(spec['reference_headers'],'reference/audiolib-reconstructions/SOURCE')
        self.assertEqual(spec['overlay_headers'],[])
        self.assertEqual(report['headers_sha256']['memcheck.h'],
                         '03f280d0e41dee69f05fd9de996297d2f25fe2587edd0143e2f7adb9c74864a3')

        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for segment,offset in [(1,0),(1,760),(4,0),(4,1)]:
            damaged=copy.deepcopy(module);damaged.segments[segment-1].data[offset]^=1
            with self.subTest(segment=segment,offset=offset),self.assertRaises(ModuleError):
                verify_module(damaged,image,placements,symbols)
        damaged=copy.deepcopy(module)
        index=next(i for i,f in enumerate(damaged.fixups) if f.target_method==2 and
                   damaged.externals[f.target-1]=='DB_PutChar_')
        damaged.fixups[index]=replace(damaged.fixups[index],
                                      displacement=damaged.fixups[index].displacement+1)
        with self.assertRaises(ModuleError):
            verify_module(damaged,image,placements,symbols)
        wrong=dict(symbols);wrong['DB_PutChar_']=(1,528216)
        with self.assertRaises(ModuleError):verify_module(module,image,placements,wrong)
        missing_scope=dict(proof);del missing_scope['local_symbols']
        with self.assertRaises(ValueError):external_anchor_bindings(missing_scope)
        wrong_scope=copy.deepcopy(proof);wrong_scope['local_symbols']['myitoa_']=(1,528517)
        with self.assertRaises(ValueError):external_anchor_bindings(wrong_scope)
        # A shortened DATA segment can match bytes but cannot meet the whole
        # contribution contract used by the standard descriptor driver.
        damaged=copy.deepcopy(module)
        damaged.segments[3].size=1;damaged.segments[3].data=damaged.segments[3].data[:1]
        shortened=verify_module(damaged,image,placements,symbols)
        with self.assertRaises(ValueError):assert_contributions(shortened,spec['expected'])

    def test_standard_driver_rejects_missing_public_and_incomplete_extent(self):
        self.assertTrue((ROOT/'src/audio/debugio.c').is_file(),
                        'production DEBUGIO source missing')
        original=json.loads((ROOT/'modules/debugio.json').read_text())
        source=(ROOT/'src/audio/debugio.c').read_text()
        start=source.index('void DB_SetXY\n');end=source.index('void DB_PutChar\n',start)
        # Remove a complete public body from real source. Adjust only the CODE
        # extent to reach the independent eight-public completeness guard.
        cases=[('missing_public',source[:start]+source[end:],{'code_bytes':741},
                'compiled CODE public count'),
               ('wrong_extent',source,{'code_bytes':760},'compiled text'),
               ('incomplete_total',source,
                {'expected':{'initialized_bytes':762,'zero_fill_bytes':0,'verified_fixups':14}},
                'incomplete initialized_bytes')]
        for name,body,change,error in cases:
            with self.subTest(case=name),tempfile.TemporaryDirectory() as temporary:
                root=Path(temporary);(root/'modules').mkdir();(root/'src').mkdir()
                (root/'reference').symlink_to(ROOT/'reference',target_is_directory=True)
                (root/'src/debugio.c').write_text(body)
                spec={**original,**change,'source':'src/debugio.c'}
                (root/'modules/debugio.json').write_text(json.dumps(spec))
                with patch.object(prove_module,'ROOT',root),self.assertRaisesRegex(ValueError,error):
                    prove_module.prove('debugio',ROOT/'toolchains/watcom-10.0b',root/'native')

    @unittest.skipUnless((ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                         'historical GA compiler required')
    def test_ga_compiler_cannot_replace_the_native_audio_profile(self):
        self.assertTrue((ROOT/'src/audio/debugio.c').is_file(),
                        'production DEBUGIO source missing')
        with tempfile.TemporaryDirectory() as temporary:
            build=Path(temporary)
            with self.assertRaisesRegex(ValueError,'compiled text'):
                prove_module.prove('debugio',ROOT/'toolchains/watcom-10.0-ga',build)
            module=Module.parse((build/'debugio.obj').read_bytes())
        self.assertEqual(module.segments[0].size,745)
