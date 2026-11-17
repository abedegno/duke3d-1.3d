from pathlib import Path
import copy
from dataclasses import replace
import tempfile
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]

@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and compiler required')
class ActorsProgressTests(unittest.TestCase):
    def test_native_intervals_reject_corruption_without_claiming_module(self):
        self.assertTrue((ROOT/'src/game/actors.c').is_file(),'recovered ACTORS source missing')
        from tools.probe_actors import probe,Module,LEImage
        from tools.probe_premap import check_intervals
        from tools.match_function import compare_range,MatchError
        with tempfile.TemporaryDirectory() as directory:
            build=Path(directory)/'fresh'
            report=probe(ROOT/'toolchains/watcom-10.0-ga',build)
            module=Module.parse((build/'actors.obj').read_bytes())
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        self.assertEqual((len(report['functions']),report['matched_function_bytes'],
                          report['matched_function_fixups']),(36,42864,1889))
        self.assertEqual(len(report['unverified_code_publics']),1)
        self.assertNotIn('lotsofmail_',module.publics)
        self.assertNotIn('lotsofpaper_',module.publics)
        self.assertFalse(report['full_module_gate']['verified'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['new_complete_contributions'],0)
        self.assertTrue(report['leading_code_prefix_verified'])
        self.assertFalse(report['initialized_data_verified'])
        self.assertTrue(report['noncode_storage_verified'])
        self.assertTrue(report['bss_verified'])
        storage=report['noncode_storage']
        self.assertEqual((storage['initialized_bytes'],storage['zero_fill_bytes']),(67,6))
        self.assertEqual([r['symbol'] for r in storage['segments']],['CONST','_BSS'])
        self.assertEqual(tuple(storage['publics']['_otherp']),(3,77748))
        from tools.probe_actors import check_storage
        bindings={k:tuple(v) for row in report['functions'] for k,v in row['bindings'].items()}
        # Text corruption, incorrect storage ownership and file-backed BSS fail.
        damaged=copy.deepcopy(module);damaged.segments[1].data[-2]^=1
        with self.assertRaises(ValueError):check_storage(damaged,image,bindings)
        damaged=copy.deepcopy(module);damaged.publics['_otherp']=(5,2)
        with self.assertRaises(ValueError):check_storage(damaged,image,bindings)
        damaged=copy.deepcopy(module);damaged.segments[4].data[0]=1
        with self.assertRaises(ValueError):check_storage(damaged,image,bindings)
        damaged=copy.deepcopy(module);damaged.segments[4].size+=1;damaged.segments[4].data.append(0)
        with self.assertRaises(ValueError):check_storage(damaged,image,bindings)
        with self.assertRaises(ValueError):check_storage(module,image,{**bindings,'_otherp':(3,77752)})
        with patch.object(image,'file_offset',return_value=0):
            with self.assertRaisesRegex(ValueError,'BSS target range has file backing'):
                check_storage(module,image,bindings)
        rows={r['symbol']:r for r in report['functions']}
        # Target's complete money interval directly abuts the guts body.
        self.assertEqual(rows['lotsofmoney_']['target_offset']+128,
                         rows['guts_']['target_offset'])
        self.assertEqual(rows['lotsofmoney_']['source_offset']+128,
                         rows['guts_']['source_offset'])
        # The entire separate leading prefix, including residue and NOP tail,
        # is verified at the common CODE base rather than by a normalized scan.
        from tools.probe_actors import check_code_prefix
        prefix=report['leading_code_prefix']
        self.assertEqual((prefix['compared_bytes'],prefix['verified_fixups']),(32,0))
        self.assertTrue(prefix['complete_prefix_verified'])
        self.assertEqual(module.code_data_ranges,[(1,0,24)])
        self.assertEqual((prefix['recognized_data_bytes'],prefix['native_alignment_bytes']),(24,8))
        for offset in [0,7,8,23,31]:
            damaged=copy.deepcopy(module);damaged.segments[0].data[offset]^=1
            with self.subTest(prefix_offset=offset):
                with self.assertRaises(ValueError):check_code_prefix(damaged,image)
        damaged=copy.deepcopy(module);damaged.publics['updateinterpolations_']=(1,31)
        with self.assertRaisesRegex(ValueError,'prefix extent'):check_code_prefix(damaged,image)
        damaged=copy.deepcopy(module);damaged.code_data_ranges=[(1,0,23)]
        with self.assertRaisesRegex(ValueError,'CODE data extent'):check_code_prefix(damaged,image)
        damaged=copy.deepcopy(module);damaged.local_publics.remove('_radius_status_record')
        with self.assertRaisesRegex(ValueError,'record ownership'):check_code_prefix(damaged,image)
        damaged=copy.deepcopy(module);damaged.publics['_radius_status_record']=(1,1)
        with self.assertRaisesRegex(ValueError,'record ownership'):check_code_prefix(damaged,image)
        # Public-interval claims still begin after the complete leading prefix.
        self.assertEqual(rows['updateinterpolations_']['source_offset'],32)
        self.assertEqual(rows['updateinterpolations_']['target_offset'],84192)
        self.assertEqual(rows['ceilingspace_']['bindings']['_sector'],[3,1597120])
        self.assertEqual(rows['floorspace_']['bindings']['_sector'],[3,1597120])
        self.assertEqual(rows['checkavailweapon_']['size'],544)
        self.assertEqual(rows['moveplayers_']['bindings']['execute_'],[1,172384])
        self.assertEqual(rows['movestandables_']['size'],7760)
        self.assertEqual(rows['movestandables_']['bindings']['_global_random'],[3,581298])
        self.assertEqual(rows['moveactors_']['size'],11536)
        self.assertEqual(rows['moveactors_']['comparison']['verified_fixups'],472)
        self.assertEqual(rows['ifhitbyweapon_']['size'],864)
        self.assertEqual(rows['ifhitbyweapon_']['comparison']['verified_fixups'],42)
        self.assertEqual(rows['hitradius_']['size'],2160)
        self.assertEqual(rows['hitradius_']['comparison']['verified_fixups'],76)
        self.assertEqual(rows['moveweapons_']['size'],3424)
        self.assertEqual(rows['moveweapons_']['bindings']['bounce_'],[1,104064])
        self.assertEqual(rows['moveexplosions_']['size'],4144)
        self.assertEqual(rows['movetransports_']['size'],3376)
        row=rows['movetransports_']
        table_indices=[i for i,f in enumerate(module.fixups) if f.segment==1 and
                       row['source_offset']+3320<=f.offset<row['source_offset']+3376]
        self.assertEqual(len(table_indices),13)
        damaged=copy.deepcopy(module);index=table_indices[0]
        damaged.fixups[index]=replace(damaged.fixups[index],displacement=damaged.fixups[index].displacement+1)
        try:
            result=compare_range(damaged,1,row['source_offset'],image,1,
                                 row['target_offset'],row['size'],row['bindings'],row['placements'])
        except MatchError:pass
        else:self.assertFalse(result['match'])
        # Watcom shares bounce's epilogue with this later loop; the raw branch must match too.
        row=rows['moveexplosions_'];offset=row['source_offset']+0x1c
        displacement=int.from_bytes(module.segments[0].data[offset:offset+4],'little',signed=True)
        self.assertEqual(offset+4+displacement,rows['bounce_']['source_offset']+0x1ec)
        damaged=copy.deepcopy(module);damaged.segments[0].data[offset]^=1
        self.assertFalse(compare_range(damaged,1,row['source_offset'],image,1,
                         row['target_offset'],row['size'],row['bindings'],row['placements'])['match'])
        for row in report['functions']:
            damaged=copy.deepcopy(module)
            damaged.segments[0].data[row['source_offset']+row['size']-1]^=1
            with self.subTest(tail=row['symbol']):
                try:
                    result=compare_range(damaged,1,row['source_offset'],image,1,
                                         row['target_offset'],row['size'],row['bindings'],row['placements'])
                except MatchError:pass # A switch-table tail may be a relocated word.
                else:self.assertFalse(result['match'])
        row=rows['setinterpolation_'];offset=row['source_offset']+0xc
        self.assertEqual(int.from_bytes(module.segments[0].data[offset:offset+4],'little'),2048)
        damaged=copy.deepcopy(module);damaged.segments[0].data[offset]^=1
        self.assertFalse(compare_range(damaged,1,row['source_offset'],image,1,
                         row['target_offset'],row['size'],row['bindings'],row['placements'])['match'])
        for name,delta,value,width in [('ifsquished_',0x70,1536,4),
                                       ('ifhitbyweapon_',0x94,42,1),
                                       ('ifhitbyweapon_',0xb9,1641,2),
                                       ('moveactors_',0x25b6,32,1),
                                       ('moveactors_',0x2606,32,1),
                                       ('insertspriteq_',0x40,63,1),
                                       ('movesprite_',0x3da,128,4),
                                       ('guts_',0xb3,48,4),
                                       ('movefallers_',0x1bb,64,4),
                                       ('movefallers_',0x1c2,127,1),
                                       ('movefallers_',0x1ee,2,1),
                                       ('movefallers_',0x223,29,4),
                                       ('movefallers_',0x22c,176,4),
                                       ('movefallers_',0x2f6,3072,4),
                                       ('movestandables_',0x7d7,32,1),
                                       ('movestandables_',0x892,2271,4),
                                       ('movestandables_',0x8a1,2311,4),
                                       ('movestandables_',0x1a45,4096,4),
                                       ('moveweapons_',0x393,1,1),
                                       ('moveweapons_',0x6f1,64,4),
                                       ('moveweapons_',0xd1c,71,1),
                                       ('moveexplosions_',0xde,3999,2),
                                       ('moveexplosions_',0x7e7,4,4),
                                       ('moveexplosions_',0x9f7,128,4),
                                       ('moveexplosions_',0xd5a,8,1),
                                       ('moveexplosions_',0xdb5,52,1)]:
            row=rows[name];offset=row['source_offset']+delta
            self.assertEqual(int.from_bytes(module.segments[0].data[offset:offset+width],'little'),value)
            damaged=copy.deepcopy(module);damaged.segments[0].data[offset]^=1
            with self.subTest(literal=name):
                self.assertFalse(compare_range(damaged,1,row['source_offset'],image,1,
                                 row['target_offset'],row['size'],row['bindings'],row['placements'])['match'])
        # Knockback reads the recipient's extra through its indexed sprite base.
        row=rows['hitradius_'];offset=row['source_offset']+0x667
        self.assertEqual(bytes(module.segments[0].data[offset:offset+3]),b'\x66\x8b\x90')
        damaged=copy.deepcopy(module);damaged.segments[0].data[offset+2]^=1
        self.assertFalse(compare_range(damaged,1,row['source_offset'],image,1,
                         row['target_offset'],row['size'],row['bindings'],row['placements'])['match'])
        index=next(i for i,f in enumerate(module.fixups) if f.segment==1 and f.offset==offset+3)
        fixup=module.fixups[index]
        self.assertEqual(module.externals[fixup.target-1],'_sprite')
        self.assertEqual(fixup.displacement+int.from_bytes(module.segments[0].data[offset+3:offset+7],'little'),42)
        damaged=copy.deepcopy(module);damaged.fixups[index]=replace(fixup,displacement=fixup.displacement+1)
        with self.assertRaises(MatchError):
            compare_range(damaged,1,row['source_offset'],image,1,
                          row['target_offset'],row['size'],row['bindings'],row['placements'])
        for name,external in [('setinterpolation_','_curipos'),('ceilingspace_','_sector'),
                              ('ifsquished_','_ud'),('ifhitbyweapon_','_ud'),('movedummyplayers_','_ps'),
                              ('movestandables_','_global_random'),('moveactors_','_ps'),
                              ('moveweapons_','bounce_')]:
            row=rows[name];damaged=copy.deepcopy(module)
            index=next(i for i,f in enumerate(module.fixups) if f.segment==1 and
                       row['source_offset']<=f.offset<row['source_offset']+row['size'] and
                       f.target_method==2 and module.externals[f.target-1]==external)
            damaged.fixups[index]=replace(damaged.fixups[index],displacement=damaged.fixups[index].displacement+1)
            with self.subTest(relocation=external):
                # Absolute conflicts raise; a changed relative callee can return a byte mismatch.
                try:
                    result=compare_range(damaged,1,row['source_offset'],image,1,
                                         row['target_offset'],row['size'],row['bindings'],row['placements'])
                except MatchError:pass
                else:self.assertFalse(result['match'])
        definitions={r['symbol']:(r['target_offset'],r['size']) for r in report['functions']}
        with self.assertRaises(ValueError):
            check_intervals(module,image,definitions,{'_sector':(3,1597160)})
