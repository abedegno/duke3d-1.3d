from pathlib import Path
import copy
from dataclasses import replace
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]

@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and compiler required')
class PlayerModuleTests(unittest.TestCase):
    def test_complete_placement_rejects_code_padding_state_and_fixup_damage(self):
        self.assertTrue((ROOT/'modules/player.json').is_file(),'complete PLAYER descriptor missing')
        from tools.probe_player import probe,check_complete,Module,LEImage
        from tools.verify_module import verify_module,ModuleError,external_anchor_bindings
        with tempfile.TemporaryDirectory() as directory:
            build=Path(directory)/'fresh'
            report=probe(ROOT/'toolchains/watcom-10.0-ga',build)
            module=Module.parse((build/'player.obj').read_bytes())
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        proof=report['verification'];placements=report['placements'];symbols=proof['publics']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),
                         (37207,18,1322))
        self.assertEqual((len(report['functions']),report['matched_function_bytes'],
                          report['matched_function_fixups']),(22,36874,1322))
        self.assertTrue(report['full_module_gate']['verified'])
        self.assertEqual(report['new_complete_contributions'],1)
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['omitted_code_bodies'],[])
        self.assertEqual(report['unverified_code_publics'],[])
        self.assertEqual(report['compiler_warnings'],["W107: Missing return value for function 'hitawall'"])
        for flag in ['leading_code_prefix_verified','initialized_data_verified','bss_verified']:
            self.assertTrue(report[flag])
        self.assertEqual({int(k):tuple(v) for k,v in placements.items()},
                         {1:(1,203888),4:(3,31220),5:(3,587520),6:(3,10508)})
        self.assertEqual(module.segments[0].size,37082)
        self.assertEqual(module.segments[0].data[-1],0xc3)
        self.assertEqual(tuple(symbols['_lastvisinc']),(3,587520))
        self.assertEqual(tuple(symbols['_fistsign']),(3,587536))
        self.assertNotIn('_dmval',external_anchor_bindings(proof))
        self.assertNotIn('_player_text',external_anchor_bindings(proof))
        self.assertNotIn('computergetinput_',module.publics)
        self.assertNotIn('getspritescore_',module.publics)
        self.assertNotIn('_fdmatrix',module.publics)
        # Format payloads keep their first NUL; only identified padding owns the residue.
        content=bytes(module.segments[5].data)
        for offset,text in [(0,b'KILLED BY %s\0'),(16,b'KILLED %s\0'),
                            (28,b'KILLED BY PLAYER %ld\0'),(52,b'KILLED PLAYER %ld\0'),
                            (72,b'frag %d killed %d\n\0')]:
            self.assertEqual(content[offset:offset+len(text)],text)
        self.assertEqual([content[i] for i in [13,14,15,26,27,49,50,51,70,71]],
                         [9,0,44,0,252,69,82,83,85,83])
        self.assertFalse(any(f.segment==6 for f in module.fixups))
        # No padding byte is the start or interior of a referenced format operand.
        for f in module.fixups:
            if f.target_method==2 and module.externals[f.target-1]=='_player_text':
                addend=f.displacement+int.from_bytes(module.segments[f.segment-1].data[f.offset:f.offset+4],'little')
                self.assertIn(addend,[0,16,28,52,72])
        for segment,offset in [(1,0),(1,207),(1,37081),(4,33),(6,90)]+[(6,i) for i in [13,14,15,26,27,49,50,51,70,71]]:
            damaged=copy.deepcopy(module);damaged.segments[segment-1].data[offset]^=1
            with self.subTest(segment=segment,offset=offset):
                with self.assertRaises(ModuleError):verify_module(damaged,image,placements,symbols)
        damaged=copy.deepcopy(module);damaged.segments[4].data[0]=1
        with self.assertRaises(ModuleError):verify_module(damaged,image,placements,symbols)
        damaged=copy.deepcopy(module);damaged.publics['_fistsign']=(5,14)
        with self.assertRaises(ModuleError):verify_module(damaged,image,placements,symbols)
        damaged=copy.deepcopy(module);damaged.segments[4].size+=1;damaged.segments[4].data.append(0)
        with self.assertRaises(ValueError):check_complete(damaged,image,report['symbol_anchors'])
        damaged=copy.deepcopy(module);damaged.segments[3].size+=1;damaged.segments[3].data.append(0)
        with self.assertRaises(ValueError):check_complete(damaged,image,report['symbol_anchors'])
        rows={r['symbol']:r for r in report['functions']};row=rows['processinput_']
        for external in ['activatebysector_','_ud','_weapon_tiles']:
            damaged=copy.deepcopy(module)
            index=next(i for i,f in enumerate(module.fixups) if f.segment==1 and
                       row['source_offset']<=f.offset<row['source_offset']+row['size'] and
                       f.target_method==2 and module.externals[f.target-1]==external)
            damaged.fixups[index]=replace(damaged.fixups[index],displacement=damaged.fixups[index].displacement+1)
            with self.subTest(external=external):
                with self.assertRaises(ModuleError):verify_module(damaged,image,placements,symbols)
        needle=(1332).to_bytes(4,'little');start=row['source_offset']
        offset=bytes(module.segments[0].data[start:start+row['size']]).find(needle)
        self.assertGreaterEqual(offset,0)
        damaged=copy.deepcopy(module);damaged.segments[0].data[start+offset]^=1
        with self.assertRaises(ModuleError):verify_module(damaged,image,placements,symbols)
