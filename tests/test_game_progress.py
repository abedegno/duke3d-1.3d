from pathlib import Path
import copy
from dataclasses import replace
import hashlib
import json
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file() and
                     (ROOT/'toolchains/watcom-10.5').is_dir(),
                     'private target and compiler required')
class GameProgressTests(unittest.TestCase):
    def test_exact_missing_return_diagnostics_only(self):
        from tools.probe_game import check_native_diagnostics
        allowed=["SOURCE.C(1): Warning! W107: Missing return value for function 'moveloop'",
                 "SOURCE.C(2): Warning! W107: Missing return value for function 'domovethings'"]
        footer='SOURCE.C: 1 lines, included 1, 2 warnings, 0 errors'
        with tempfile.TemporaryDirectory() as temporary:
            log=Path(temporary)/'game.log'
            log.write_text('\n'.join(allowed+[footer]))
            self.assertEqual(check_native_diagnostics(log)['accepted_warning_functions'],
                             ['moveloop','domovethings'])
            for altered in [allowed+["SOURCE.C(3): Warning! W107: Missing return value for function 'playback'",footer],
                            [allowed[0].replace('W107','W108'),allowed[1],footer],
                            [allowed[0].replace('Missing return value','Different return value'),allowed[1],footer],
                            allowed+["SOURCE.C(3): Error! E1031: Name missing",footer],
                            allowed+[footer.replace('0 errors','1 errors')],
                            allowed+[footer.replace('2 warnings','3 warnings')],
                            allowed+[allowed[0],footer], [footer],allowed]:
                log.write_text('\n'.join(altered))
                with self.subTest(log=altered):
                    with self.assertRaises(ValueError):check_native_diagnostics(log)

    def test_native_intervals_abi_and_common_storage_remain_partial(self):
        from tools.probe_game import probe,FUNCTIONS,check_source_identity
        from tools.probe_premap import check_source_interval,check_intervals
        from omf32 import Module
        from le import LEImage
        with tempfile.TemporaryDirectory() as temporary:
            build=Path(temporary)/'native'
            report=probe(ROOT/'toolchains/watcom-10.0-ga',build)
            build=Path(report['source_build']['native_build_directory'])
            module=Module.parse((build/'game.obj').read_bytes())
            tail=Module.parse((build/'GMTAIL.OBJ').read_bytes())
            self.assertEqual((len(report['functions']),report['matched_function_bytes'],
                              report['matched_function_fixups']),(78,66094,4314))
            from tools.probe_game import check_native_diagnostics
            diagnostics=check_native_diagnostics(build/'game.log')
            self.assertEqual(diagnostics['accepted_warning_functions'],['moveloop','domovethings'])
            self.assertEqual(diagnostics,report['compiler_diagnostics'])
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        # These complete render intervals must reject the later ancestor's
        # menu/capture/mirror behavior and extra glass randomization.
        for name,target,size in [('displayrooms_',27840,2752),('vglass_',81472,240),
                                 ('cheats_',54624,3664),('animatesprites_',47744,6880),
                                 ('nonsharedkeys_',58288,4096),('comlinehelp_',62384,432),
                                 ('compilecons_',65168,112),('Startup_',65280,304),
                                 ('getnames_',65632,192),('main_',65824,1488),
                                 ('opendemoread_',67312,288),('opendemowrite_',67600,336),
                                 ('gameexit_',22896,224),
                                 ('record_',67936,272),('closedemowrite_',68208,160),
                                 ('playback_',68368,1088),('moveloop_',69456,160),
                                 ('fakedomovethingscorrect_',69616,448),
                                 ('fakedomovethings_',70064,4032),
                                 ('domovethings_',74096,1008),('doorders_',75104,640),
                                 ('Logo_',63968,1072),('dobonus_',75744,5216)]:
            with self.subTest(new_render_interval=name):
                try:
                    check_source_interval(module,image,name,target,size,
                                          {n:tuple(v) for row in report['functions']
                                           for n,v in row['bindings'].items()})
                except (ValueError,KeyError) as error:
                    self.fail(str(error))
        self.assertEqual((len(report['functions']),report['matched_function_bytes'],
                          report['matched_function_fixups']),(78,66094,4314))
        self.assertEqual(report['new_complete_contributions'],0)
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertFalse(report['full_module_gate']['verified'])
        self.assertTrue(report['leading_code_prefix_verified'])
        for flag in ['initialized_data_verified','bss_verified']:
            self.assertFalse(report[flag])
        from tools.probe_game import check_code_prefix
        prefix=report['leading_code_prefix']
        self.assertEqual((prefix['compared_bytes'],prefix['verified_fixups']),(448,0))
        self.assertEqual((prefix['target_object'],prefix['target_offset']),(1,16))
        self.assertEqual(module.code_data_ranges,[(1,0,440)])
        self.assertEqual((prefix['recognized_data_bytes'],prefix['native_alignment_bytes']),(440,8))
        self.assertFalse(report['unassigned_preceding_code_range']['ownership_verified'])
        self.assertEqual(report['unassigned_preceding_code_range']['size'],16)
        for offset in [0,79,80,159,160,239,240,319,320,439,440,447]:
            damaged=copy.deepcopy(module);damaged.segments[0].data[offset]^=1
            with self.subTest(prefix_offset=offset):
                with self.assertRaises(ValueError):check_code_prefix(damaged,image)
        damaged=copy.deepcopy(module);damaged.publics['timerhandler_']=(1,447)
        with self.assertRaisesRegex(ValueError,'prefix extent'):check_code_prefix(damaged,image)
        damaged=copy.deepcopy(module);damaged.code_data_ranges=[(1,0,439)]
        with self.assertRaisesRegex(ValueError,'CODE data extent'):check_code_prefix(damaged,image)
        damaged=copy.deepcopy(module);damaged.publics['unexpected_prefix_']=(1,0)
        with self.assertRaisesRegex(ValueError,'unexpected public'):check_code_prefix(damaged,image)
        self.assertEqual(report['omitted_code_bodies'],[])
        self.assertEqual(report['excluded_later_code_bodies'],
                         ['gametextpal','minitextshade','writestring','testcd','copyprotect','adduserquote'])
        for name in report['excluded_later_code_bodies']:
            self.assertNotIn(name,report['omitted_code_bodies'])
            self.assertNotIn(name+'_',module.publics)
            self.assertNotIn(name+'_',module.externals)
        self.assertTrue(report['unverified_code_publics'])
        self.assertNotIn('gametext_later_signature_',module.externals)
        self.assertNotIn('gametext_later_signature_',module.publics)
        rows={row['symbol']:row for row in report['functions']}
        bindings={n:tuple(a) for row in rows.values() for n,a in row['bindings'].items()}
        for row in rows.values():
            damaged=copy.deepcopy(module)
            seg,off=damaged.publics[row['symbol']]
            damaged.segments[seg-1].data[off+row['size']-1]^=1
            with self.assertRaises(ValueError):
                check_source_interval(damaged,image,row['symbol'],row['target_offset'],
                                      row['size'],bindings)
        # Native gametext has four register parameters, a plain RET and the
        # older constant rendering flags; the full 272-byte interval includes
        # its nine alignment bytes. Do not accept a terminal-body trim.
        row=rows['gametext_'];start=row['source_offset']
        self.assertEqual(row['size'],272)
        self.assertEqual(module.segments[0].data[start+262],0xc3)
        flags=module.segments[0].data.find(b'\x6a\x1a',start,start+row['size'])
        self.assertGreaterEqual(flags,start)
        damaged=copy.deepcopy(module);damaged.segments[0].data[flags+1]=24
        with self.assertRaises(ValueError):
            check_source_interval(damaged,image,'gametext_',576,272,bindings)
        with self.assertRaises(ValueError):
            check_source_interval(module,image,'gametext_',576,263,bindings)
        # Representative callee and global/player-member relocations must not
        # be hidden by the diagnostic candidate scan.
        for name in ['gametext_','coolgaugetext_','view_','inittimer_','EGS_',
                     'faketimerhandler_','getpackets_','invennum_','weaponnum_','weaponnum999_',
                     'displayrooms_','vglass_','cheats_','animatesprites_','nonsharedkeys_','comlinehelp_']:
            row=rows[name];start=row['source_offset'];end=start+row['size']
            index=next(i for i,f in enumerate(module.fixups)
                       if f.segment==1 and start<=f.offset<end)
            damaged=copy.deepcopy(module);fix=damaged.fixups[index]
            damaged.fixups[index]=replace(fix,displacement=fix.displacement+1)
            with self.assertRaises(ValueError):
                check_source_interval(damaged,image,name,row['target_offset'],row['size'],bindings)
        # EGS uses the inserted index directly, without the later error path.
        # Include its complete native padding and measured hit-state offsets.
        row=rows['EGS_'];start=row['source_offset'];end=start+row['size']
        fixes=[f for f in module.fixups if f.segment==1 and start<=f.offset<end]
        self.assertEqual((row['size'],row['comparison']['verified_fixups']),(544,36))
        names=[module.externals[f.target-1] for f in fixes if f.target_method==2]
        self.assertIn('insertsprite_',names)
        self.assertNotIn('gameexit_',names)
        fix=next(f for f in fixes if f.target_method==2 and
                 module.externals[f.target-1]=='_hittype' and
                 int.from_bytes(module.segments[0].data[f.offset:f.offset+4],'little')==35)
        damaged=copy.deepcopy(module);damaged.segments[0].data[fix.offset]^=1
        with self.assertRaises(ValueError):
            check_source_interval(damaged,image,'EGS_',30672,544,bindings)
        with self.assertRaisesRegex(ValueError,'changed source interval extent'):
            check_source_interval(module,image,'EGS_',30672,530,bindings)
        # The earlier switches recognize tile1741, not the later1742 case.
        # Check the native case operand, including both relocation-free
        # classifiers, rather than trusting source-level case inventories.
        for name in ['check_fta_sounds_','badguy_','badguypic_']:
            row=rows[name];start=row['source_offset'];end=start+row['size']
            operand=module.segments[0].data.index(bytes.fromhex('66 3d cd 06'),start,end)+2
            damaged=copy.deepcopy(module);damaged.segments[0].data[operand]=0xce
            with self.assertRaises(ValueError):
                check_source_interval(damaged,image,name,row['target_offset'],row['size'],bindings)
        for name in ['badguy_','badguypic_']:
            self.assertEqual(rows[name]['comparison']['verified_fixups'],0)
        row=rows['faketimerhandler_'];start=row['source_offset'];end=start+row['size']
        fixes=[f for f in module.fixups if f.segment==1 and start<=f.offset<end]
        names=[module.externals[f.target-1] for f in fixes if f.target_method==2]
        self.assertEqual((row['size'],row['comparison']['verified_fixups']),(3968,281))
        self.assertIn('getpackets_',names)
        self.assertIn('getinput_',names)
        self.assertNotIn('computergetinput_',names)
        self.assertNotIn('_KB_KeyDown',names)
        fix=next(f for f in fixes if f.target_method==2 and
                 module.externals[f.target-1]=='_loc' and
                 int.from_bytes(module.segments[0].data[f.offset:f.offset+4],'little')==4)
        damaged=copy.deepcopy(module);damaged.segments[0].data[fix.offset]=3
        with self.assertRaises(ValueError):
            check_source_interval(damaged,image,'faketimerhandler_',5616,3968,bindings)
        # The receiver has independently replayed RTS callees, an earlier
        # network version, and four move-counter stores (no sync reset).
        row=rows['getpackets_'];start=row['source_offset'];end=start+row['size']
        fixes=[f for f in module.fixups if f.segment==1 and start<=f.offset<end]
        self.assertEqual((row['size'],row['comparison']['verified_fixups']),(4128,233))
        self.assertTrue(report['native_anchor_replays']['rts']['verification']['verified'])
        from tools.verify_module import external_anchor_bindings
        rts=external_anchor_bindings(report['native_anchor_replays']['rts']['verification'])
        for name in ['RTS_NumSounds_','RTS_GetSound_']:
            self.assertEqual(tuple(row['bindings'][name]),tuple(rts[name]))
        code=module.segments[0].data
        version=next(f for f in fixes if f.target_method==2 and
                     module.externals[f.target-1]=='_packbuf' and
                     code[f.offset-2:f.offset]==bytes.fromhex('80 3d') and
                     code[f.offset+4]==103)
        damaged=copy.deepcopy(module);damaged.segments[0].data[version.offset+4]=104
        with self.assertRaises(ValueError):
            check_source_interval(damaged,image,'getpackets_',1488,4128,bindings)
        counter_names=[module.externals[f.target-1] for f in fixes
                       if f.target_method==2 and start+0xbf7<=f.offset<start+0xc17]
        self.assertEqual(counter_names,['_fakemovefifoplc','_movefifosendplc',
                                        '_movefifoplc','_movefifoend'])
        self.assertEqual(tuple(row['bindings']['_received_quote']),(3,579460))
        self.assertEqual(tuple(row['bindings']['_received_quote_time']),(3,581296))
        self.assertEqual(tuple(row['bindings']['_recbuf']),(3,73824))
        for name in ['_received_quote','_received_quote_time','_playerreadyflag']:
            fix=next(f for f in reversed(fixes) if f.target_method==2 and
                     module.externals[f.target-1]==name)
            damaged=copy.deepcopy(module)
            index=module.fixups.index(fix)
            damaged.fixups[index]=replace(fix,displacement=fix.displacement+1)
            with self.assertRaises(ValueError):
                check_source_interval(damaged,image,'getpackets_',1488,4128,bindings)
        for name in ['_qe','_cp','_quotebot','_quotebotgoal','_received_quote','_received_quote_time']:
            self.assertNotIn(name,module.publics)
        # Independent PREMAP loads place the real ending palette immediately
        # after recbuf; the GAME-only context now reproduces that owner.
        self.assertEqual(module.publics['_endingpal'][1]-module.publics['_recbuf'][1],40)
        for name in ['invennum_','weaponnum_','weaponnum999_']:
            self.assertEqual(tuple(rows[name]['placements'][1]),(1,16))
        # Seven shutdown calls have a measured order; the earlier candidate
        # had the same opcodes but the wrong callees in those positions.
        row=rows['ShutDown_'];start=row['source_offset'];end=start+row['size']
        fixes=[f for f in module.fixups if f.segment==1 and start<=f.offset<end]
        self.assertEqual([module.externals[f.target-1] for f in fixes],
                         ['CONTROL_Shutdown_','KB_Shutdown_','SoundShutdown_',
                          'MusicShutdown_','uninittimer_','uninitengine_','CONFIG_WriteSetup_'])
        damaged=copy.deepcopy(module)
        indices=[i for i,f in enumerate(module.fixups) if f in fixes]
        damaged.fixups[indices[0]]=replace(fixes[0],target=fixes[1].target)
        with self.assertRaises(ValueError):
            check_source_interval(damaged,image,'ShutDown_',65120,48,bindings)
        # The shared native DATA placement agrees with independent anchors
        # around the old archive buffer. Its initialized bytes are not claimed.
        self.assertEqual(bindings['_cameradist'],(3,29560))
        segment,offset=module.publics['_boardfilename']
        placement=next(row['placements'][segment] for row in rows.values()
                       if segment in row['placements'])
        self.assertEqual((placement[0],placement[1]+offset),(3,29836))
        with self.assertRaises(ValueError):
            check_intervals(module,image,FUNCTIONS,{**bindings,'_boardfilename':(3,29708)})
        self.assertTrue(report['native_anchor_replays']['task_man']['verification']['verified'])
        # These source mutations name actual wrong operands, branches and stores.
        # Compile each ordinary C change privately and require the unchanged
        # unmasked native interval checker to reject it.
        from runner import compile_source
        from tools.prove_module import prepare_headers
        from tools.probe_game import OPTIONS
        source=(ROOT/'src/game/game.c').read_text()
        new_rows={'displayrest_':(23584,2192,177),'weapon_amounts_':(13664,1920,63),
                  'displayinventory_':(15824,1008,38),'displayfragbar_':(16832,608,53),
                  'tics_':(21536,144,12),'caches_':(21680,224,14),
                  'coords_':(21904,464,44),'operatefta_':(22368,336,21),
                  'FTA_':(22704,112,3),'showtwoscreens_':(22816,16,0),
                  'binscreen_':(22832,64,5),'displayrooms_':(27840,2752,131),
                  'vglass_':(81472,240,9),'cheats_':(54624,3664,315),
                  'animatesprites_':(47744,6880,239),'nonsharedkeys_':(58288,4096,426),'comlinehelp_':(62384,432,96)}
        for name,expected in new_rows.items():
            row=rows[name]
            self.assertEqual((row['target_offset'],row['size'],
                              row['comparison']['verified_fixups']),expected)
        self.assertIn('gameexit_',FUNCTIONS)
        self.assertNotIn('gameexit_',report['unverified_code_publics'])
        self.assertNotIn('weapon_amounts',report['omitted_code_bodies'])
        self.assertNotIn('caches',report['omitted_code_bodies'])
        for name,target in [('_lockptr',(3,1665920)),('_cacleng',(3,1682304))]:
            self.assertEqual(bindings[name],target)
            self.assertFalse(report['consumer_reference_roles'][name]['scope_link_model_verified'])
            self.assertNotIn(name,module.publics)
            with self.subTest(common_binding=name):
                with self.assertRaises(ValueError):
                    check_intervals(module,image,FUNCTIONS,
                                    {**bindings,name:(target[0],target[1]+4)})
        for name in ['caches_','coords_','operatefta_','binscreen_','cheats_','nonsharedkeys_','comlinehelp_']:
            row=rows[name];start=row['source_offset'];end=start+row['size']
            index=next(i for i,f in enumerate(module.fixups)
                       if f.segment==1 and start<=f.offset<end and
                       f.target_method==2 and module.externals[f.target-1].endswith('_'))
            damaged=copy.deepcopy(module);fix=damaged.fixups[index]
            # Rebind a call to a distinct external, preserving opcode and width.
            other=next(i+1 for i,n in enumerate(module.externals)
                       if n.endswith('_') and i+1!=fix.target)
            damaged.fixups[index]=replace(fix,target=other)
            with self.subTest(callee=name):
                with self.assertRaises(ValueError):
                    check_source_interval(damaged,image,name,row['target_offset'],row['size'],bindings)
        with self.assertRaisesRegex(ValueError,'changed source interval extent'):
            check_source_interval(module,image,'showtwoscreens_',22816,1,bindings)
        from tools.probe_game import check_initialized_data
        data_proof=report['initialized_data_projection']
        self.assertTrue(report['owned_data_verified'])
        self.assertFalse(report['other_initialized_storage_verified'])
        self.assertEqual((data_proof['initialized_bytes'],data_proof['zero_fill_bytes'],
                          data_proof['verified_fixups']),(864,0,0))
        data_segment=data_proof['source_segment']
        self.assertEqual([(r['source_offset'],r['size']) for r in data_proof['alignment_residues']],
                         [(9,3),(493,3),(506,2)])
        exports=external_anchor_bindings(data_proof)
        for row in data_proof['alignment_residues']:
            self.assertNotIn(row['symbol'],exports)
            self.assertEqual(row['runtime_fixup_references'],0)
        for offset in [0,8,9,10,11,148,275,276,403,407,408,411,412,492,493,494,495,
                       496,503,504,505,506,507,508,511,512,582,861,862,863]:
            damaged=copy.deepcopy(module);damaged.segments[data_segment-1].data[offset]^=1
            with self.subTest(data_byte=offset):
                with self.assertRaises(ValueError):check_initialized_data(damaged,image,bindings)
        damaged=copy.deepcopy(module);damaged.segments[data_segment-1].size-=1
        with self.assertRaisesRegex(ValueError,'DATA extent'):
            check_initialized_data(damaged,image,bindings)
        with self.assertRaisesRegex(ValueError,'DATA placement'):
            check_initialized_data(module,image,{**bindings,'_cameradist':(3,29564)})
        damaged=copy.deepcopy(module);damaged.publics['_TimerPtr']=(data_segment,495)
        with self.assertRaisesRegex(ValueError,'object layout'):
            check_initialized_data(damaged,image,bindings)
        damaged=copy.deepcopy(module);damaged.local_publics.remove('_inferred_serial_alignment')
        with self.assertRaisesRegex(ValueError,'alignment gap'):
            check_initialized_data(damaged,image,bindings)
        # A CODE reference into padding must fail even though this projection
        # verifies DATA only. Model a real OMF internal-segment relocation.
        damaged=copy.deepcopy(module)
        index=next(i for i,f in enumerate(damaged.fixups) if f.target_method==2 and
                   damaged.externals[f.target-1]=='_TimerPtr')
        fix=damaged.fixups[index]
        damaged.fixups[index]=replace(fix,target_method=0,target=data_segment,displacement=0)
        damaged.segments[fix.segment-1].data[fix.offset:fix.offset+4]=(9).to_bytes(4,'little')
        with self.assertRaisesRegex(ValueError,'source reference into'):
            check_initialized_data(damaged,image,bindings)
        # displayfragbar's full public also owns the native switch-table tail
        # for the following gauge switch:28 relocations/112 bytes, not a trim.
        row=rows['displayfragbar_'];start=row['source_offset'];end=start+row['size']
        table_indices=[i for i,f in enumerate(module.fixups) if f.segment==1 and
                       start<=f.offset<end and f.target_method==0 and f.target==1]
        self.assertEqual(len(table_indices),28)
        self.assertEqual([module.fixups[i].offset-start for i in table_indices],
                         list(range(484,596,4)))
        for index in [table_indices[0],table_indices[-1]]:
            damaged=copy.deepcopy(module);fix=damaged.fixups[index]
            damaged.fixups[index]=replace(fix,displacement=fix.displacement+1)
            with self.assertRaises(ValueError):
                check_source_interval(damaged,image,'displayfragbar_',16832,608,bindings)
        self.assertEqual(tuple(rows['displayrooms_']['placements'][1]),(1,16))
        row=rows['vglass_'];start=row['source_offset'];end=start+row['size']
        glass_calls=[module.externals[f.target-1] for f in module.fixups
                     if f.segment==1 and start<=f.offset<end and f.target_method==2
                     and module.externals[f.target-1].endswith('_')]
        self.assertEqual(glass_calls,['krand_','krand_','krand_','EGS_'])
        self.assertNotIn('cheats',report['omitted_code_bodies'])
        cheat=rows['cheats_']
        self.assertEqual(tuple(report['compound_storage']['C_prefix_zero_fill_range'][k]for k in ['target_object','target_offset']),(3,73568))
        self.assertNotIn('_cheatbuf',module.publics)
        self.assertNotIn('_cheatbuflen',module.publics)
        self.assertEqual(tail.publics['_cheatbuf'],(3,0))
        self.assertEqual(tail.publics['_cheatbuflen'],(3,11))
        self.assertEqual(tuple(cheat['bindings']['_cheatbuf']),(3,77728))
        self.assertEqual(tuple(cheat['bindings']['_cheatbuflen']),(3,77739))
        self.assertNotIn('_nomorelogohack',module.publics)
        self.assertNotIn('_nomorelogohack',module.externals)
        self.assertFalse(report['cheat_buffer_observations']['nomorelogohack_active_consumer'])
        for name in ['_trees','_sixteen']:
            self.assertNotIn(name,module.externals)
        self.assertFalse(report['bss_verified'])
        role=report['measured_user_byte8_role']
        self.assertEqual((role['logical_role'],role['target_offset'],role['cheat_index']),
                         ('clipping',579676,20))
        self.assertFalse(role['byte5_role_verified'])
        from tools.probe_game import check_compound_storage
        damaged=copy.deepcopy(tail);damaged.publics['_cheatbuflen']=(3,10)
        with self.assertRaises(ValueError):
            check_compound_storage(module,damaged,image,report['functions'])
        # The public includes the following cheats switch's 25 generated
        # four-byte entries and all native alignment. OMF code_data_ranges
        # marks only the leading initializer data, not these switch tails.
        animation=rows['animatesprites_'];start=animation['source_offset']
        self.assertEqual(tuple(animation['placements'][1]),(1,16))
        self.assertNotIn('animatesprites_',report['unverified_code_publics'])
        self.assertIn('spawn_',report['unverified_code_publics'])
        self.assertIn('wallswitchcheck_',report['unverified_code_publics'])
        table=[f for f in module.fixups if f.segment==1 and
               start+6776<=f.offset<start+6876]
        self.assertEqual([f.offset-start for f in table],list(range(6776,6876,4)))
        self.assertTrue(all(f.target_method==0 and f.target==1 for f in table))
        self.assertEqual(module.segments[0].data[start+6772],0xc3)
        for fix in table:
            damaged=copy.deepcopy(module)
            index=damaged.fixups.index(fix)
            damaged.fixups[index]=replace(fix,displacement=fix.displacement+1)
            with self.subTest(animation_table_entry=(fix.offset-start-6776)//4):
                with self.assertRaises(ValueError):
                    check_source_interval(damaged,image,'animatesprites_',47744,6880,bindings)
        for trim in [6773,6776,6876,6879]:
            with self.assertRaisesRegex(ValueError,'changed source interval extent'):
                check_source_interval(module,image,'animatesprites_',47744,trim,bindings)
        # No switch table is trimmed from this public: its native RET and
        # all fourteen alignment bytes finish the complete 4096-byte interval.
        keys=rows['nonsharedkeys_'];start=keys['source_offset']
        self.assertEqual(tuple(keys['placements'][1]),(1,16))
        self.assertEqual(module.segments[0].data[start+4081],0xc3)
        from tools.match_function import is_alignment_padding
        self.assertTrue(is_alignment_padding(bytes(module.segments[0].data[start+4082:start+4096])))
        with self.assertRaisesRegex(ValueError,'changed source interval extent'):
            check_source_interval(module,image,'nonsharedkeys_',58288,4082,bindings)
        self.assertNotIn('nonsharedkeys_',report['unverified_code_publics'])
        self.assertEqual(tuple(keys['bindings']['_nonsharedtimer']),(3,77704))
        for name,target in [('_CONTROL_ButtonState1',2132660),('_CONTROL_ButtonState2',2132664)]:
            self.assertEqual(tuple(keys['bindings'][name]),(3,target))
            with self.assertRaises(ValueError):
                check_intervals(module,image,FUNCTIONS,{**bindings,name:(3,target+4)})
        # Help's complete public owns the next parser's 58 native entries.
        help_row=rows['comlinehelp_'];start=help_row['source_offset']
        self.assertEqual(tuple(help_row['placements'][1]),(1,16))
        self.assertEqual(module.segments[0].data[start+198:start+200],bytes.fromhex('c3 90'))
        table=[f for f in module.fixups if f.segment==1 and start+200<=f.offset<start+432]
        self.assertEqual([f.offset-start for f in table],list(range(200,432,4)))
        self.assertTrue(all(f.target_method==0 and f.target==1 for f in table))
        for fix in table:
            damaged=copy.deepcopy(module);index=damaged.fixups.index(fix)
            damaged.fixups[index]=replace(fix,displacement=fix.displacement+1)
            with self.subTest(help_table_entry=(fix.offset-start-200)//4):
                with self.assertRaises(ValueError):
                    check_source_interval(damaged,image,'comlinehelp_',62384,432,bindings)
        with self.assertRaisesRegex(ValueError,'changed source interval extent'):
            check_source_interval(module,image,'comlinehelp_',62384,200,bindings)
        self.assertNotIn('checkcommandline',report['omitted_code_bodies'])
        for name,target,size in [('checkcommandline_',62816,1072)]:
            self.assertIn(name,report['unverified_code_publics'])
            with self.subTest(unproved_whole_interval=name):
                with self.assertRaises(ValueError):
                    check_source_interval(module,image,name,target,size,bindings)
        for name,target,size,ret in [('compilecons_',65168,112,99),
                                     ('Startup_',65280,304,289),('getnames_',65632,192,178)]:
            row=rows[name];origin=row['source_offset']
            self.assertEqual(module.segments[0].data[origin+ret],0xc3)
            with self.subTest(no_body_only_trim=name):
                with self.assertRaisesRegex(ValueError,'changed source interval extent'):
                    check_source_interval(module,image,name,target,ret+1,bindings)
            for fix in [f for f in module.fixups if f.segment==1 and origin<=f.offset<origin+size]:
                damaged=copy.deepcopy(module);at=damaged.fixups.index(fix)
                damaged.fixups[at]=replace(fix,displacement=fix.displacement+1)
                with self.subTest(new_native_fixup=(name,fix.offset-origin)):
                    with self.assertRaises(ValueError):
                        if fix.target_method==0 and fix.target==2:
                            # A sole string reference can move an isolated
                            # interval's inferred CONST base. The production
                            # graph must retain the common non-CODE placement.
                            check_intervals(damaged,image,FUNCTIONS,bindings)
                        else:
                            check_source_interval(damaged,image,name,target,size,bindings)
        for name,target,size,ret in [('main_',65824,1488,1482),
                                     ('opendemoread_',67312,288,284),
                                     ('opendemowrite_',67600,336,324)]:
            row=rows[name];origin=row['source_offset']
            self.assertEqual(module.segments[0].data[origin+ret],0xc3)
            with self.subTest(no_demo_body_trim=name):
                with self.assertRaisesRegex(ValueError,'changed source interval extent'):
                    check_source_interval(module,image,name,target,ret+1,bindings)
            for offset in range(ret+1,size):
                damaged=copy.deepcopy(module);damaged.segments[0].data[origin+offset]^=1
                with self.subTest(main_demo_alignment=(name,offset)):
                    with self.assertRaises(ValueError):
                        check_source_interval(damaged,image,name,target,size,bindings)
            for fix in [f for f in module.fixups if f.segment==1 and origin<=f.offset<origin+size]:
                damaged=copy.deepcopy(module);at=damaged.fixups.index(fix)
                damaged.fixups[at]=replace(fix,displacement=fix.displacement+1)
                with self.subTest(main_demo_fixup=(name,fix.offset-origin)):
                    with self.assertRaises(ValueError):
                        check_source_interval(damaged,image,name,target,size,bindings)
        prediction_rows=[('gameexit_',22896,224,24,218),
                         ('record_',67936,272,15,257),
                         ('closedemowrite_',68208,160,17,147),
                         ('playback_',68368,1088,91,1086),
                         ('moveloop_',69456,160,17,None),
                         ('fakedomovethingscorrect_',69616,448,36,None),
                         ('fakedomovethings_',70064,4032,289,4016),
                         ('domovethings_',74096,1008,104,1002),
                         ('doorders_',75104,640,56,584)]
        for name,target,size,fixup_count,ret in prediction_rows:
            row=rows[name];origin=row['source_offset']
            self.assertEqual((row['target_offset'],row['size'],
                              row['comparison']['verified_fixups']),(target,size,fixup_count))
            self.assertNotIn(name,report['unverified_code_publics'])
            if ret is not None:
                self.assertEqual(module.segments[0].data[origin+ret],0xc3)
                with self.assertRaisesRegex(ValueError,'changed source interval extent'):
                    check_source_interval(module,image,name,target,ret+1,bindings)
            # moveloop/fakecorrect use a shared playback epilogue: they still
            # own every byte up to the next public, including final alignment.
            for offset in range((ret+1 if ret is not None else {'moveloop_':155,'fakedomovethingscorrect_':442}[name]),size):
                damaged=copy.deepcopy(module);damaged.segments[0].data[origin+offset]^=1
                with self.subTest(prediction_tail=(name,offset)):
                    with self.assertRaises(ValueError):
                        check_source_interval(damaged,image,name,target,size,bindings)
            for fix in [f for f in module.fixups if f.segment==1 and origin<=f.offset<origin+size]:
                damaged=copy.deepcopy(module);at=damaged.fixups.index(fix)
                damaged.fixups[at]=replace(fix,displacement=fix.displacement+1)
                with self.subTest(prediction_fixup=(name,fix.offset-origin)):
                    with self.assertRaises(ValueError):
                        if fix.target_method==0 and fix.target==2:
                            check_intervals(damaged,image,FUNCTIONS,bindings)
                        else:
                            check_source_interval(damaged,image,name,target,size,bindings)
        # GA resolved ShutDown directly: no OMF fixup exists at this E8.
        # Raw displacement bytes must remain checked, independently of the
        # 24 typed relocations and the five native alignment bytes.
        origin=rows['gameexit_']['source_offset'];call=origin+126
        self.assertEqual(module.segments[0].data[call:call+5],bytes.fromhex('e8 6d a4 00 00'))
        self.assertFalse(any(f.segment==1 and call<=f.offset<call+5 for f in module.fixups))
        resolved=call+5+int.from_bytes(module.segments[0].data[call+1:call+5],'little',signed=True)
        self.assertEqual(resolved,module.publics['ShutDown_'][1])
        self.assertEqual(resolved+rows['gameexit_']['placements'][1][1],65120)
        for offset in range(call+1,call+5):
            damaged=copy.deepcopy(module);damaged.segments[0].data[offset]^=1
            with self.assertRaises(ValueError):
                check_source_interval(damaged,image,'gameexit_',22896,224,bindings)
        orders=rows['doorders_'];origin=orders['source_offset']
        table=[f for f in module.fixups if f.segment==1 and origin+588<=f.offset<origin+628]
        self.assertEqual([f.offset-origin for f in table],list(range(588,628,4)))
        self.assertTrue(all(f.target_method==0 and f.target==1 for f in table))
        for trim in [585,588,628,639]:
            with self.assertRaisesRegex(ValueError,'changed source interval extent'):
                check_source_interval(module,image,'doorders_',75104,trim,bindings)
        for name,target,size,fields in [('Logo_',63968,1072,88),('dobonus_',75744,5216,402)]:
            row=rows[name];self.assertNotIn(name,report['unverified_code_publics'])
            self.assertEqual((row['size'],row['comparison']['verified_fixups']),(size,fields))
            self.assertEqual(tuple(row['placements'][5]),(3,73568))
            for fix in [f for f in module.fixups if f.segment==1 and row['source_offset']<=f.offset<row['source_offset']+size]:
                damaged=copy.deepcopy(module);at=damaged.fixups.index(fix)
                damaged.fixups[at]=replace(fix,displacement=fix.displacement+1)
                with self.subTest(palette_body_field=(name,fix.offset-row['source_offset'])):
                    with self.assertRaises(ValueError):
                        check_source_interval(damaged,image,name,target,size,bindings)
        # All registered C intervals now share the real CODEbase16; this
        # is stronger than matching their extents independently.
        self.assertTrue(all(tuple(r['placements'][1])==(1,16) for r in rows.values()))
        self.assertNotIn('_gc',module.externals)
        physics=report['prediction_physics']
        self.assertEqual((physics['gravity_increment'],physics['contact_shift'],
                          physics['source_frame_bytes'],physics['native_frame_bytes']),
                         (256,6,72,72))
        self.assertFalse(physics['GLOBAL_gc_historical_role_proved'])
        self.assertFalse(physics['BSS_ownership_proved'])
        self.assertEqual(tuple(rows['domovethings_']['bindings']['_received_quote']),
                         (3,579460))
        self.assertEqual(tuple(rows['domovethings_']['bindings']['_received_quote_time']),
                         (3,581296))
        abort=report['wait_abort_consumer']
        self.assertEqual((abort['symbol'],abort['target'],abort['read_width']),
                         ('_wait_abort',[3,587556],1))
        self.assertFalse(abort['historical_name_proved'])
        self.assertTrue(abort['storage_owned_by_PREMAP'])
        self.assertFalse(abort['storage_owned_by_GAME'])
        self.assertEqual(abort['PREMAP_owned_BSS_range_exclusive'],[587552,587557])
        self.assertEqual(abort['function'],['waitforeverybody_',250512,416])
        self.assertEqual(abort['source_constraint_offsets'],[9570,9674,9908])
        self.assertEqual(hashlib.sha256((ROOT/abort['evidence']).read_bytes()).hexdigest(),
                         abort['evidence_sha256'])
        self.assertEqual(bindings['_wait_abort'],(3,587556))
        origin=module.publics['main_'][1]
        self.assertEqual(module.segments[0].data[origin+881:origin+883],b'\x80\x3d')
        self.assertEqual(module.segments[0].data[origin+887],0)
        self.assertEqual(bindings['_frecfilep'],(3,29968))
        self.assertEqual(bindings['_recfilep'],(3,77708))
        self.assertEqual(bindings['kclose_'],(1,420443))
        for name in ['main_','opendemoread_','opendemowrite_']:
            self.assertNotIn(name[:-1],report['omitted_code_bodies'])
        # This is an explicit full-interval negative diagnostic, not a masked
        # acceptance: two intra-TU branches still reach spawn's return one byte
        # late. All fixups must resolve against the same canonical globals.
        from tools.infer_bindings import infer_bindings
        from tools.match_function import compare_range
        seg,origin=module.publics['checkcommandline_']
        view=copy.deepcopy(module)
        view.publics={n:(s,o) for n,(s,o) in module.publics.items()
                      if n=='checkcommandline_' or s!=1}
        view.fixups=[f for f in module.fixups if f.segment==1 and origin<=f.offset<origin+1072]
        bound=infer_bindings(view,image,1,62816-origin,known_symbols=bindings)
        negative=compare_range(view,1,origin,image,1,62816,1072,
                               bound['symbols'],bound['placements'])
        self.assertFalse(negative['match'])
        self.assertEqual((negative['compared_bytes'],negative['verified_fixups']),(1072,95))
        self.assertEqual(negative['differing_offsets'],[74,85])
        byte5=next(f for f in view.fixups if f.target_method==2 and
                   module.externals[f.target-1]=='_ud' and
                   int.from_bytes(module.segments[0].data[f.offset:f.offset+4],'little')==5)
        self.assertEqual(module.segments[0].data[byte5.offset-2:byte5.offset],bytes.fromhex('c6 05'))
        self.assertEqual(module.segments[0].data[byte5.offset+4],1)
        self.assertFalse(report['measured_user_byte8_role']['byte5_role_verified'])
        # Inspect identified source literals too, while full CONST remains
        # uncredited. This checks source text, not just the addresses in calls.
        for name in ['comlinehelp_','checkcommandline_','Logo_']:
            origin=module.publics[name][1];size={'comlinehelp_':432,'checkcommandline_':1072,'Logo_':1072}[name]
            literal_fixes=[f for f in module.fixups if f.segment==1 and origin<=f.offset<origin+size
                           and f.target_method==0 and f.target==2]
            self.assertTrue(literal_fixes)
            for fix in literal_fixes:
                offset=int.from_bytes(module.segments[0].data[fix.offset:fix.offset+4],'little')+fix.displacement
                constant=module.segments[1].data
                text=bytes(constant[offset:constant.index(0,offset)+1])
                self.assertEqual(text,image.object_bytes(3)[offset+4:offset+4+len(text)])
        mutations=[
            ('prediction-later-gravity','fakedomovethings_','myzvel += 256;','myzvel += (gc+80);'),
            ('prediction-contact-x','fakedomovethings_','myxvel -= sintable[(j+512)&2047]<<6;','myxvel -= sintable[(j+512)&2047]<<4;'),
            ('prediction-contact-y','fakedomovethings_','myyvel -= sintable[j&2047]<<6;','myyvel -= sintable[j&2047]<<4;'),
            ('prediction-clipping-byte','fakedomovethings_','ud.over_shoulder_on','ud.clipping'),
            ('prediction-aiming-byte','fakedomovethings_','p->level_reset_flag','p->on_ground'),
            ('prediction-clip-mask','fakedomovethings_','CLIPMASK0','CLIPMASK1'),
            ('prediction-backup-index','fakedomovethings_','myhorizbak[fakemovefifoplc&(MOVEFIFOSIZ-1)]','myhorizbak[(fakemovefifoplc+1)&(MOVEFIFOSIZ-1)]'),
            ('prediction-cstat-restore','fakedomovethings_','sprite[p->i].cstat = backcstat;','sprite[p->i].cstat &= ~257;'),
            ('exit-demo-close','gameexit_','fclose(frecfilep);','kclose((long)frecfilep);'),
            ('exit-shutdown-call','gameexit_','    ShutDown();','    SoundShutdown();'),
            ('exit-text-filter','gameexit_',"*(t+1) == 0","*(t+1) != 0"),
            ('record-input-width','record_','sizeof(input));','sizeof(input)-1);'),
            ('record-flush-count','record_','ud.reccnt >= RECSYNCBUFSIZ','ud.reccnt > RECSYNCBUFSIZ'),
            ('close-demo-zero-count','closedemowrite_','ud.reccnt > 0','ud.reccnt >= 0'),
            ('close-demo-header-count','closedemowrite_','&totalreccnt,sizeof(long)','&ud.reccnt,sizeof(long)'),
            ('playback-mode-test','playback_','gm&MODE_EOL) &&','gm&MODE_GAME) &&'),
            ('playback-packet-pump','playback_','            getpackets();',''),
            ('playback-ready-guard','playback_','    foundemo = 0;','    if(ready2send) return 0;\n    foundemo = 0;'),
            ('movement-result-use','moveloop_','        domovethings();','        if(domovethings()) break;'),
            ('movement-fifo-condition','moveloop_','movefifoplc > bufferjitter','movefifoplc >= bufferjitter'),
            ('prediction-correction-value','fakedomovethingscorrect_','myx = p->posx;','myx = p->oposx;'),
            ('prediction-correction-horizon','fakedomovethingscorrect_','myhoriz = p->horiz;','myhoriz = p->ohoriz;'),
            ('movement-quote-time','domovethings_','received_quote_time = 160;','received_quote_time = 180;'),
            ('movement-quote-value','domovethings_','received_quote = buf;','received_quote = buf+1;'),
            ('movement-quote-countdown','domovethings_','received_quote_time > 0','received_quote_time > 1'),
            ('orders-wait-pump','doorders_','while( !KB_KeyWaiting() );','while( !KB_KeyWaiting() ) getpackets();'),
            ('orders-bonus-table','doorders_','case 5:\n','case 6:\n'),
            ('main-heap-threshold','main_','Z_AvailHeap() < 2800000','Z_AvailHeap() < 2812000'),
            ('main-group-buffer','main_','initgroupfile(groupfilename)',
             'initgroupfile(boardfilename)'),
            ('main-group-failure','main_','initgroupfile(groupfilename)) == -1',
             'initgroupfile(groupfilename)) == 0'),
            ('main-uart-pump','main_','while( !KB_KeyWaiting() );',
             'while( !KB_KeyWaiting() ) getpackets();'),
            ('main-abort-byte','main_','if(wait_abort)','if(gamequit)'),
            ('main-movement-return','main_','                moveloop();',
             '                if( moveloop() ) continue;'),
            ('main-demo-draw-order','main_',
             '        if(ps[myconnectindex].gm&MODE_DEMO)\n            goto MAIN_LOOP_RESTART;\n\n        displayrest(i);',
             '        displayrest(i);\n        if(ps[myconnectindex].gm&MODE_DEMO)\n            goto MAIN_LOOP_RESTART;'),
            ('demo-read-selector','opendemoread_','which_demo == 10','which_demo == 9'),
            ('demo-read-count-width','opendemoread_',
             'kread(recfilep,&ud.reccnt,sizeof(long));',
             'kread(recfilep,&ud.reccnt,sizeof(short));'),
            ('demo-read-volume-field','opendemoread_',
             '&ud.volume_number,sizeof(char)','&ud.level_number,sizeof(char)'),
            ('demo-write-close-value','opendemowrite_',
             'kclose((long)frecfilep);','kclose((long)recfilep);'),
            ('demo-write-open-failure','opendemowrite_',
             'fopen(d,"wb")) == -1','fopen(d,"wb")) == (FILE *)NULL'),
            ('demo-write-count-width','opendemowrite_',
             'fwrite(&dummylong,4,1,frecfilep);','fwrite(&dummylong,2,1,frecfilep);'),
            ('demo-write-respawn-field','opendemowrite_',
             '&ud.m_respawn_monsters,sizeof(int32)',
             '&ud.m_respawn_items,sizeof(int32)'),
            ('compilecons-label-buffer','compilecons_','label = (char *)&hittype[0];',
             'label = (char *)&sprite[0];'),
            ('compilecons-archive-argument','compilecons_',
             'confilename,groupfilename);','confilename,boardfilename);'),
            ('startup-network-player-limit','Startup_','numplayers <= 4','numplayers < 4'),
            ('startup-ready-clear','Startup_','   initmultiplayers(0,0,0);',
             '   for(i=0;i<MAXPLAYERS;i++) playerreadyflag[i] = 0;\n   initmultiplayers(0,0,0);'),
            ('getnames-packet-type','getnames_','buf[0] = 6;','buf[0] = 5;'),
            ('getnames-protocol','getnames_','buf[1] = 103;','buf[1] = 104;'),
            ('getnames-message-length','getnames_','l += 3;','l += 2;'),
            ('getnames-wait','getnames_','        waitforeverybody();\n',''),
            ('getnames-name-copy','getnames_','ud.user_name[myconnectindex][l]',
             'ud.user_name[myconnectindex][l+1]'),
            ('help-argv-index','comlinehelp_','argv[0]','argv[1]'),
            ('help-early-return','comlinehelp_','argv[0]);','argv[0]); return;'),
            ('help-parser-group-alias','comlinehelp_',
             "case 'G':\n                        c++;\n                        if(*c) strcpy(groupfilename,c);",
             "case 'H':\n                        c++;\n                        if(*c) strcpy(groupfilename,c);"),
            ('help-parser-byte5-alias','comlinehelp_',"case 'D':\n                        /* Raw /d selector",
             "case 'E':\n                        /* Raw /d selector"),
            ('help-parser-version-alias','comlinehelp_',"case 'j':\n                    case 'J':",
             "case 'j':\n                    case 'K':"),
            ('keys-coop-recording','nonsharedkeys_','ud.coop == 1 || ud.recstat != 0',
             'ud.coop == 1 || ud.recstat == 2'),
            ('keys-music-count','nonsharedkeys_','music_select == 33','music_select == 44'),
            ('keys-quote-duration','nonsharedkeys_','received_quote_time = 180;',
             'received_quote_time = 160;'),
            ('keys-quote-pointer','nonsharedkeys_','received_quote = ud.ridecule[i-1];',
             'received_quote = ud.ridecule[i];'),
            ('keys-capture-tile','nonsharedkeys_','waloff[MAXTILES-3]','waloff[MAXTILES-1]'),
            ('keys-quick-save-menu','nonsharedkeys_','cmenu(360+lastsavedpos);',
             'current_menu = 360+lastsavedpos;'),
            ('keys-quick-save-multiplayer','nonsharedkeys_',
             'if( KB_KeyPressed( sc_F6 ) && ud.multimode < 2 &&',
             'if( KB_KeyPressed( sc_F6 ) &&'),
            ('keys-f2-screenpeek-guard','nonsharedkeys_',
             'totalclock = ototalclock;\n                }\n                screenpeek = myconnectindex;\n            }\n\n            if(KB_KeyPressed( sc_F3 ))',
             'totalclock = ototalclock;\n                    screenpeek = myconnectindex;\n                }\n            }\n\n            if(KB_KeyPressed( sc_F3 ))'),
            ('animation-horse-tile','animatesprites_','t->picnum = 1;','t->picnum = 2;'),
            ('animation-rotation-divisor','animatesprites_','/192)%5','/170)%5'),
            ('animation-rotation-modulus','animatesprites_','/192)%5','/192)%7'),
            ('animation-shade','animatesprites_','t->shade = 16;','t->shade = 15;'),
            ('animation-frame-tile','animatesprites_','INFERRED_FRAMEEFFECT1_13D = 3999',
             'INFERRED_FRAMEEFFECT1_13D = 4095'),
            ('animation-cheat-table','animatesprites_','case 20:\n                        /* Raw clip-cheat',
             'case 25:\n                        /* Raw clip-cheat'),
            ('cheat-eog-mode','cheats_','ud.eog = 5;','ud.eog = 1;'),
            ('cheat-clip-byte','cheats_','ud.over_shoulder_on','ud.clipping'),
            ('cheat-input-limit','cheats_','if(cheatbuflen > 11)','if(cheatbuflen > 10)'),
            # Real ASM tail storage is covered by GameCompoundNative. This
            # counterexample changes actual C accesses to the external byte.
            ('cheat-counter-access-width','cheats_','extern char cheatbuf[10],cheatbuflen;',
             'extern char cheatbuf[10]; extern short cheatbuflen;'),
            ('cheat-message-width','cheats_','sendpacket(i,tempbuf,10);','sendpacket(i,tempbuf,11);'),
            ('cheat-volume-range','cheats_','if(volnume > 2)','if(volnume > 4)'),
            ('cheat-weapon-store','cheats_','ps[myconnectindex].gotweapon[weapon]  = 1;',
             'ps[myconnectindex].gotweapon[weapon]  = 0;'),
            ('cheat-eog-player-mode','cheats_','ps[myconnectindex].gm |= MODE_EOL;',
             'ps[myconnectindex].gm |= MODE_RESTART;'),
            ('render-menu-guard','displayrooms_','(current_menu/100) == 3','(current_menu/100) == 4'),
            ('render-capture-tile','displayrooms_','MAXTILES-3','MAXTILES-1'),
            ('render-mirror-sector','displayrooms_','choriz,mirrorsector[i]);','choriz,mirrorsector[i]+MAXSECTORS);'),
            ('glass-extra-random-z','vglass_','EGS(sect,x,y,z,','EGS(sect,x,y,z-(TRAND&8191),'),
            ('typing-timer','displayrest_','received_quote_time = 160','received_quote_time = 159'),
            ('typing-quote-pointer','displayrest_','received_quote = recbuf','received_quote = recbuf+1'),
            ('typing-screen-position','displayrest_','strget(160,141','strget(160,142'),
            ('monitor-tile','displayrest_','walock[MAXTILES-3]','walock[MAXTILES-1]'),
            ('typing-native-allocation','displayrest_','short ch=0, hitstate;','short ch, hitstate;'),
            ('weapon-shrinker-ammo','weapon_amounts_','p->ammo_amount[SHRINKER_WEAPON]','p->ammo_amount[GROW_WEAPON]'),
            ('weapon-status-position','weapon_amounts_','patchstatusbar(96,178','patchstatusbar(97,178'),
            ('inventory-player-row','displayinventory_','y = 156','y = 154'),
            ('inventory-mini-x','displayinventory_','xoff += 56','xoff += 65'),
            ('frag-player-color','displayfragbar_','9+(i&7)','sprite[ps[i].i].pal'),
            ('frame-count-mask','tics_','#define AVERAGEFRAMES 64','#define AVERAGEFRAMES 16'),
            ('coordinate-x','coords_','274L','250L'),
            ('coordinate-member','coords_','ps[snum].transporter_hold','ps[snum].on_ground'),
            ('quote-timer-branch','operatefta_','received_quote_time > 0','received_quote_time > 1'),
            ('quote-value','operatefta_','received_quote,0','received_quote+1,0'),
            ('quote-screen-branch','operatefta_','ud.screen_size > 0','ud.screen_size == 0'),
            ('fta-priority','FTA_','q != 115','q != 114'),
            ('fta-later-q26','FTA_','p->ftq != q )','p->ftq != q || q == 26 )'),
            ('fta-store-order','FTA_','pub = NUMPAGES;\n            pus = NUMPAGES;\n            p->ftq = q;',
             'p->ftq = q;\n            pub = NUMPAGES;\n            pus = NUMPAGES;'),
            ('cache-length-array','caches_','cacleng[i]','cac[i].leng'),
            ('cache-lock-array','caches_','*lockptr[i]','*cac[i].lock'),
            ('cache-native-tail','caches_','     k += 6;\n','     k += 7;\n'),
            ('empty-public-tail','showtwoscreens_','{\n}','{\n    pub = NUMPAGES;\n}'),
            ('binscreen-group-parameter','binscreen_','loadfromgrouponly','1')]
        with tempfile.TemporaryDirectory() as temporary:
            private=Path(temporary)
            for label,name,before,after in mutations:
                with self.subTest(source_mutation=label):
                    stage=private/label;stage.mkdir()
                    if label in ['frame-count-mask','cheat-counter-access-width','animation-frame-tile','animation-cheat-table',
                                 'help-parser-group-alias','help-parser-byte5-alias','help-parser-version-alias','orders-bonus-table']:
                        if label=='orders-bonus-table':
                            begin=source.index('void dobonus(');body=source[begin:]
                            self.assertIn(before,body)
                            altered=source[:begin]+body.replace(before,after,1)
                        else:
                            self.assertEqual(source.count(before),1)
                            altered=source.replace(before,after)
                    else:
                        prefix={'opendemoread_':'char ','moveloop_':'char ',
                                'domovethings_':'char ','playback_':'long '}.get(name,'void ')
                        begin=source.index(prefix+name[:-1]+'(')
                        # Retained inactive WW2 code in cheats has column-zero
                        # inner braces; stop at its next public declaration.
                        end=(source.index('\nvoid nonsharedkeys(',begin) if name=='cheats_'
                             else source.index('\n}',begin)+2)
                        body=source[begin:end]
                        self.assertIn(before,body)
                        altered=source[:begin]+body.replace(before,after)+source[end:]
                    candidate=stage/'game.c';candidate.write_text(altered)
                    headers=stage/'include'
                    prepare_headers([ROOT/'reference/duke3d-reconstructions',
                                     ROOT/'reference/duke3d-reconstructions/MACT'],
                                    [ROOT/'src/include',ROOT/'src/game/include',ROOT/'src/engine/include'],headers)
                    obj=stage/'game.obj'
                    compile_source(ROOT/'toolchains/watcom-10.0-ga',candidate,obj,OPTIONS,30,
                                   include_dirs=[headers])
                    check_native_diagnostics(obj.with_suffix('.log'))
                    mutated=Module.parse(obj.read_bytes());row=rows[name]
                    control_bindings=bindings
                    if label=='main-abort-byte':
                        # This counterfactual introduces a new reference; use
                        # the same complete PLAYER consumer binding that the
                        # production anchor adapter imports when referenced.
                        player=external_anchor_bindings(json.loads(
                            (ROOT/'evidence/player-module.json').read_text())['verification'])
                        self.assertEqual(player['_gamequit'],[3,31187])
                        control_bindings={**bindings,'_gamequit':tuple(player['_gamequit'])}
                    with self.assertRaises(ValueError):
                        check_source_interval(mutated,image,name,row['target_offset'],row['size'],control_bindings)
            identity_file=private/'identity.c';identity_file.write_text(source)
            identity=hashlib.sha256(identity_file.read_bytes()).hexdigest()
            check_source_identity(identity_file,identity)
            identity_file.write_text(source+'\n/* changed during compilation */\n')
            with self.assertRaisesRegex(ValueError,'source changed during compilation'):
                check_source_identity(identity_file,identity)
            with self.assertRaisesRegex(ValueError,'source changed during compilation'):
                check_source_identity(ROOT/'src/game/game.c','0'*64)
        provenance=json.loads((ROOT/'evidence/game-source-reference.json').read_text())
        self.assertEqual(provenance['source_sha256'],report['source_sha256'])
        for key,path in [('upstream_sha256',ROOT/provenance['upstream_source']),
                         ('released_source_sha256',ROOT/provenance['released_source']),
                         ('license_sha256',ROOT/'src/game/gpl.txt')]:
            self.assertEqual(provenance[key],hashlib.sha256(path.read_bytes()).hexdigest())
