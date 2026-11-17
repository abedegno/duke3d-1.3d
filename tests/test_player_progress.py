from pathlib import Path
import copy
from dataclasses import replace
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]

@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and compiler required')
class PlayerProgressTests(unittest.TestCase):
    def test_native_intervals_reject_corruption_without_claiming_executable(self):
        self.assertTrue((ROOT/'src/game/player.c').is_file(),'recovered PLAYER source missing')
        from tools.probe_player import probe,Module,LEImage,FUNCTIONS
        from tools.probe_premap import check_intervals
        from tools.match_function import compare_range,MatchError
        with tempfile.TemporaryDirectory() as directory:
            build=Path(directory)/'fresh'
            report=probe(ROOT/'toolchains/watcom-10.0-ga',build)
            module=Module.parse((build/'player.obj').read_bytes())
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        self.assertEqual((len(report['functions']),report['matched_function_bytes'],
                          report['matched_function_fixups']),(22,36874,1322))
        self.assertTrue(report['full_module_gate']['verified'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['new_complete_contributions'],1)
        for flag in ['leading_code_prefix_verified','initialized_data_verified','bss_verified']:
            self.assertTrue(report[flag])
        self.assertEqual(report['omitted_code_bodies'],[])
        for name in report['omitted_code_bodies']:
            self.assertNotIn(name+'_',module.publics)
        rows={r['symbol']:r for r in report['functions']}
        self.assertEqual(rows['hitasprite_']['bindings']['hitscan_'],[1,354777])
        self.assertEqual(rows['getinput_']['size'],2096)
        self.assertEqual(rows['shoot_']['comparison']['verified_fixups'],392)
        self.assertEqual(rows['displayweapon_']['size'],6512)
        self.assertEqual(rows['checkweapons_']['bindings']['_weapon_tiles'],[3,31116])
        self.assertEqual(rows['getinput_']['bindings']['_ud'],[3,579668])
        self.assertTrue(report['weapon_sprites_storage']['verified'])
        self.assertEqual(report['weapon_sprites_storage']['initialized_bytes'],22)
        self.assertEqual(report['weapon_sprites_storage']['zero_fill_bytes'],0)
        from tools.probe_player import check_weapon_sprites
        bindings={n:tuple(v) for row in report['functions'] for n,v in row['bindings'].items()}
        damaged=copy.deepcopy(module);segment,offset=module.publics['_weapon_sprites']
        damaged.segments[segment-1].data[offset+20]^=1
        with self.assertRaises(ValueError):check_weapon_sprites(damaged,image,bindings)
        damaged=copy.deepcopy(module);damaged.publics['_weapon_sprites']=(segment,offset+2)
        with self.assertRaises(ValueError):check_weapon_sprites(damaged,image,bindings)
        with self.assertRaises(ValueError):
            check_weapon_sprites(module,image,{**bindings,'_weapon_sprites':(3,31234)})
        # The getinput map-following flag is target byte7; changing it to byte6 fails.
        row=rows['getinput_'];damaged=copy.deepcopy(module)
        index=next(i for i,f in enumerate(module.fixups) if f.segment==1 and
                   row['source_offset']<=f.offset<row['source_offset']+row['size'] and
                   f.target_method==2 and module.externals[f.target-1]=='_ud' and
                   int.from_bytes(module.segments[0].data[f.offset:f.offset+4],'little')==7)
        damaged.segments[0].data[module.fixups[index].offset]=6
        with self.assertRaises(MatchError):
            compare_range(damaged,1,row['source_offset'],image,1,
                          row['target_offset'],row['size'],row['bindings'],row['placements'])
        for row in report['functions']:
            damaged=copy.deepcopy(module)
            damaged.segments[0].data[row['source_offset']+row['size']-1]^=1
            with self.subTest(tail=row['symbol']):
                try:
                    result=compare_range(damaged,1,row['source_offset'],image,1,
                                         row['target_offset'],row['size'],row['bindings'],row['placements'])
                except MatchError:pass
                else:self.assertFalse(result['match'])
        for name,external in [('displayloogie_','_ps'),('hitasprite_','hitscan_'),
                              ('doincrements_','spritesound_'),('setpal_','_sector'),
                              ('aim_','badguy_'),('shoot_','aim_'),
                              ('displayweapon_','animateknee_'),('getinput_','CONTROL_GetInput_'),
                              ('checkweapons_','_weapon_sprites')]:
            row=rows[name];damaged=copy.deepcopy(module)
            index=next(i for i,f in enumerate(module.fixups) if f.segment==1 and
                       row['source_offset']<=f.offset<row['source_offset']+row['size'] and
                       f.target_method==2 and module.externals[f.target-1]==external)
            damaged.fixups[index]=replace(damaged.fixups[index],displacement=damaged.fixups[index].displacement+1)
            with self.subTest(fixup=external):
                try:
                    result=compare_range(damaged,1,row['source_offset'],image,1,
                                         row['target_offset'],row['size'],row['bindings'],row['placements'])
                except MatchError:pass
                else:self.assertFalse(result['match'])
        # Reject a changed player record member and an arithmetic literal.
        for name,needle in [('setpal_', (1329).to_bytes(4,'little')),
                            ('incur_damage_',b'\xc1\xf9\x08')]:
            row=rows[name];start=row['source_offset']
            position=bytes(module.segments[0].data[start:start+row['size']]).find(needle)
            self.assertGreaterEqual(position,0)
            damaged=copy.deepcopy(module)
            damaged.segments[0].data[start+position+len(needle)-1]^=1
            self.assertFalse(compare_range(damaged,1,start,image,1,
                             row['target_offset'],row['size'],row['bindings'],row['placements'])['match'])
        with self.assertRaises(ValueError):
            check_intervals(module,image,FUNCTIONS,{'_ps':(3,1)})
