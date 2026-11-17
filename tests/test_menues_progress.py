from pathlib import Path
import copy
from dataclasses import replace
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and compiler required')
class MenuesProgressTests(unittest.TestCase):
    def test_complete_module_and_native_publics_reject_corruption(self):
        self.assertTrue((ROOT/'src/game/menues.c').is_file(),
                        'source-backed MENUES recovery is missing')
        from tools.probe_menues import probe, Module, LEImage, check_intervals, FUNCTIONS
        from tools.match_function import compare_range, MatchError
        with tempfile.TemporaryDirectory() as directory:
            report = probe(ROOT/'toolchains/watcom-10.0-ga', Path(directory)/'fresh')
            module = Module.parse((Path(directory)/'fresh/menues.obj').read_bytes())
        self.assertEqual(len(report['functions']), 20)
        self.assertEqual(report['matched_function_bytes'], 30763)
        self.assertEqual(report['matched_function_fixups'], 2263)
        self.assertEqual(report['new_complete_contributions'], 1)
        self.assertEqual(report['compiler_diagnostics'], {'warnings': 0, 'errors': 0})
        self.assertEqual(report['descriptor'], 'modules/menues.json')
        self.assertTrue(report['full_module_gate']['verified'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['omitted_code_bodies'], [])
        self.assertEqual(report['later_ancestor_bodies_excluded'], ['dummyfunc_', 'dummymess_', 'TENtext_',
                                                           'intro4animsounds_', 'first4animsounds_', 'intro42animsounds_',
                                                       'endanimvol41_', 'endanimvol42_', 'endanimvol43_'])
        image = LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for row in report['functions']:
            args = (1, row['source_offset'], image, 1, row['target_offset'], row['size'],
                    row['bindings'], row['placements'])
            self.assertTrue(compare_range(module, *args)['match'])
            damaged = copy.deepcopy(module)
            damaged.segments[0].data[row['source_offset']+row['size']-1] ^= 1
            with self.subTest(tail=row['symbol']):
                if row['symbol']=='sortfilenames_':
                    # Its final byte belongs to a four-byte CODE fixup.
                    with self.assertRaisesRegex(MatchError, 'outside LE object'):
                        compare_range(damaged, *args)
                else:
                    self.assertFalse(compare_range(damaged, *args)['match'])
        # Literal slider upper bound, player-member displacement and callee
        # identity must all participate in the unmasked production check.
        for name in ['bar_', 'getangplayers_', 'loadpheader_', 'menutext_']:
            row = next(r for r in report['functions'] if r['symbol']==name)
            damaged = copy.deepcopy(module)
            lo, hi = row['source_offset'], row['source_offset']+row['size']
            occupied = {i for f in module.fixups if f.segment==1
                        for i in range(f.offset, f.offset+f.width)}
            if name=='bar_':
                offset = next(i for i in range(lo, hi) if i not in occupied and
                              module.segments[0].data[i] == 63)
            elif name=='loadpheader_':
                offset = module.segments[0].data.index(b'\x83\x3c\x24\x67', lo, hi)+3
            elif name=='menutext_':
                offset = module.segments[0].data.index(b'\x05\x55\x0b\x00\x00', lo, hi)+1
            else:
                offset = module.segments[0].data.index(b'\x66\x8b\x91\x80\x02\x00\x00', lo, hi)+3
            damaged.segments[0].data[offset] ^= 1
            if name=='getangplayers_':
                with self.assertRaisesRegex(MatchError, 'fixup target mismatch'):
                    compare_range(damaged, 1, lo, image, 1, row['target_offset'],
                                  row['size'], row['bindings'], row['placements'])
            else:
                self.assertFalse(compare_range(damaged, 1, lo, image, 1, row['target_offset'],
                                 row['size'], row['bindings'], row['placements'])['match'])
        row = next(r for r in report['functions'] if r['symbol']=='bar_')
        damaged = copy.deepcopy(module)
        i = next(i for i,f in enumerate(module.fixups) if f.segment==1 and
                 row['source_offset'] <= f.offset < row['source_offset']+row['size'] and
                 f.target_method==2 and module.externals[f.target-1]=='rotatesprite_')
        damaged.fixups[i] = replace(damaged.fixups[i], displacement=damaged.fixups[i].displacement+1)
        self.assertFalse(compare_range(damaged, 1, row['source_offset'], image, 1,
                         row['target_offset'], row['size'], row['bindings'], row['placements'])['match'])
        # Owned BSS aliases cannot be given independent placements per helper.
        damaged = copy.deepcopy(module)
        segment, offset = damaged.publics['_mi']
        damaged.publics['_mi'] = (segment, offset+4)
        with self.assertRaises(ValueError):
            check_intervals(damaged, image, FUNCTIONS, {})

        # The shared user prefix names remain provisional. This body must
        # access physical byte7; accepting the ancestor byte6 is incorrect.
        row = next(r for r in report['functions'] if r['symbol']=='drawoverheadmap_')
        lo, hi = row['source_offset'], row['source_offset']+row['size']
        fix = next(f for f in module.fixups if f.segment==1 and lo<=f.offset<hi
                   and f.target_method==2 and module.externals[f.target-1]=='_ud'
                   and int.from_bytes(module.segments[0].data[f.offset:f.offset+4], 'little')==7)
        damaged = copy.deepcopy(module)
        damaged.segments[0].data[fix.offset] = 6
        with self.assertRaisesRegex(MatchError, 'fixup target mismatch'):
            compare_range(damaged, 1, lo, image, 1, row['target_offset'], row['size'],
                          row['bindings'], row['placements'])
        self.assertEqual(report['unverified_code_publics'], [])
        self.assertEqual(report['candidate_full_intervals'], {})
        self.assertTrue(report['native_anchor_replays']['animlib']['verification']['verified'])
        row = next(r for r in report['functions'] if r['symbol']=='playanm_')
        self.assertEqual(row['bindings']['ANIM_DrawFrame_'], [1, 426176])
        self.assertEqual(row['bindings']['_anim'], [3, 32356])
        damaged = copy.deepcopy(module)
        lo, hi = row['source_offset'], row['source_offset']+row['size']
        offset = module.segments[0].data.index(b'\xba\xfc\x0f\x00\x00', lo, hi)+1
        damaged.segments[0].data[offset] = 0xfd
        self.assertFalse(compare_range(damaged, 1, lo, image, 1, row['target_offset'], row['size'],
                         row['bindings'], row['placements'])['match'])

        # Both transfers are inside the complete load-to-inferred-tail public:
        # the native save body is placed before its own called entry.
        player_transfer = bytes.fromhex('bb 10 00 00 00 ba 52 05 00 00')
        self.assertEqual(image.object_bytes(1)[0x2aa00:0x2aa0a], player_transfer)
        self.assertEqual(image.object_bytes(1)[0x2b2dd:0x2b2e7], player_transfer)
        load_row = next(r for r in report['functions'] if r['symbol']=='loadplayer_')
        lo, hi = load_row['source_offset'], load_row['source_offset']+load_row['size']
        self.assertEqual(load_row['size'], 4416)
        self.assertEqual(load_row['comparison']['verified_fixups'], 372)
        self.assertEqual(bytes(module.segments[0].data[lo:hi]).count(player_transfer), 2)

        # Watcom's nonnegative enums can select unsigned branches. The
        # reconstructed format bounds must retain the target signed JL.
        load_start = load_row['source_offset']
        for offset in [0x403, 0x4da]:
            self.assertEqual(image.object_bytes(1)[173904+offset], 0x7c)
            self.assertEqual(module.segments[0].data[load_start+offset], 0x7c)

        self.assertTrue(report['noncode_storage_verified'])
        self.assertEqual(report['noncode_storage']['initialized_bytes'], 2999)
        self.assertEqual(report['noncode_storage']['zero_fill_bytes'], 4571)
        self.assertEqual(report['noncode_storage']['verified_fixups'], 0)
        self.assertTrue(report['initialized_data_verified'])
        from tools.probe_menues import check_storage
        from tools.verify_module import ModuleError
        for segment, offset in [(2, 2982), (4, 8), (5, 4570)]:
            damaged = copy.deepcopy(module)
            damaged.segments[segment-1].data[offset] ^= 1
            with self.subTest(storage_segment=segment), self.assertRaises(ModuleError):
                check_storage(damaged, image, report['functions'])

        damaged = copy.deepcopy(module)
        segment, offset = damaged.publics['_menunamecnt']
        damaged.publics['_menunamecnt'] = (segment, offset+1)
        with self.assertRaises(ModuleError):
            check_storage(damaged, image, report['functions'])
        self.assertNotIn('gametext_later_reference_declaration_', module.externals)

        # The full menu public includes the unsigned slot calls.
        # Target passes an unsigned8-bit slot, with no later negative-slot
        # multiplayer save/restore protocol. Whole native layout is checked below.
        menu_row = next(r for r in report['functions'] if r['symbol']=='menus_')
        menu_start = menu_row['source_offset']
        menu_end = menu_start + menu_row['size']
        self.assertEqual(menu_row['size'], 16192)
        self.assertEqual(menu_row['comparison']['verified_fixups'], 1412)
        slot_calls = [(module.externals[f.target-1], f.offset-1) for f in module.fixups
                      if f.segment==1 and menu_start <= f.offset < menu_end
                      and f.target_method==2
                      and module.externals[f.target-1] in ['loadplayer_', 'saveplayer_']]
        self.assertEqual([name for name, _ in slot_calls],
                         ['loadplayer_', 'loadplayer_', 'saveplayer_'])
        code = bytes(module.segments[0].data)
        call = slot_calls[0][1]
        self.assertEqual(code[call-7:call-4], bytes.fromhex('31 c0 a0'))
        for _, call in slot_calls[1:]:
            self.assertEqual(code[call-5:call], bytes.fromhex('25 ff 00 00 00'))
        target_code = image.object_bytes(1)
        for call, callee in [(0x2cfb5, 0x2a750), (0x2d50c, 0x2a750), (0x2f359, 0x2b8a0)]:
            self.assertEqual(target_code[call], 0xe8)
            self.assertEqual(call+5+int.from_bytes(target_code[call+1:call+5], 'little', signed=True), callee)
        self.assertEqual(target_code[0x2cfb5-7:0x2cfb5-4], bytes.fromhex('31 c0 a0'))
        for call in [0x2d50c, 0x2f359]:
            self.assertEqual(target_code[call-5:call], bytes.fromhex('25 ff 00 00 00'))
        for name in ['loadplayer_later_reference_declaration_', 'saveplayer_later_reference_declaration_']:
            self.assertNotIn(name, module.externals)

        # Earlier skill rows use20 (0x14) bytes, while the shared later
        # declaration still says33 (0x21). This checks literal pointer
        # addends in the complete menu, without claiming label ownership.
        skill_rows = [int.from_bytes(code[f.offset:f.offset+4], 'little') + f.displacement
                      for f in module.fixups if f.segment==1 and menu_start <= f.offset < menu_end
                      and f.target_method==2 and module.externals[f.target-1]=='_skill_names']
        self.assertEqual(skill_rows, [0, 20, 40, 60, 0])
        target_fixups = {f.source_offset: (f.target_object, f.target_offset)
                         for f in image.read_fixups() if f.source_object==1}
        for operand, row in [(0x2e6ab, 0), (0x2e6c3, 1), (0x2e6d8, 2), (0x2e6ed, 3)]:
            self.assertEqual(target_fixups[operand], (3, 31015+row*20))

        # Accept all448 (0x1c0) bytes including the248-byte switch prefix,
        # never the200-byte sort body alone. Every table target is relocated
        # and checked; a changed first table entry must be rejected.
        row = next(r for r in report['functions'] if r['symbol']=='sortfilenames_')
        self.assertEqual(row['size'], 448)
        self.assertEqual(row['comparison']['verified_fixups'], 73)
        self.assertEqual(module.publics['menus_'][1]-row['source_offset'], 448)
        damaged = copy.deepcopy(module)
        damaged.segments[0].data[row['source_offset']+200] ^= 1
        with self.assertRaisesRegex(MatchError, 'fixup target mismatch'):
            compare_range(damaged, 1, row['source_offset'], image, 1,
                          row['target_offset'], row['size'], row['bindings'], row['placements'])
        from tools.probe_premap import check_source_interval
        with self.assertRaisesRegex(ValueError, 'changed source interval extent'):
            check_source_interval(module, image, 'sortfilenames_', 182096, 200, row['bindings'])

        # Native target default skips the skill sound and reaches the clock
        # wait. The complete menu interval, including this flow, is proved.
        wait_add = code.index(bytes.fromhex('05 f0 00 00 00'), menu_start, menu_end)
        wait_start = wait_add-5
        branch = code.rindex(bytes.fromhex('66 3d 03 00 77'), wait_start-80, wait_start)+4
        self.assertEqual(branch+2+int.from_bytes(code[branch+1:branch+2], 'little', signed=True), wait_start)
        self.assertEqual(target_code[0x2e5f9:0x2e5fb], bytes.fromhex('77 2c'))
        self.assertEqual(0x2e5f9+2+0x2c, 0x2e627)

        # Stack homes and the word-width cancel test are part of the whole
        # native public. Neither a frame near-match nor a trimmed body passes.
        self.assertIn(bytes.fromhex('89 45 f4'), code[menu_start:menu_start+80])
        cancel = menu_start+0x1d8a
        self.assertEqual(code[cancel:cancel+4], bytes.fromhex('66 3d ff ff'))
        for offset in [code.index(bytes.fromhex('89 45 f4'), menu_start, menu_start+80)+2, cancel]:
            damaged = copy.deepcopy(module)
            damaged.segments[0].data[offset] ^= 1
            self.assertFalse(compare_range(damaged, 1, menu_start, image, 1,
                             menu_row['target_offset'], menu_row['size'],
                             menu_row['bindings'], menu_row['placements'])['match'])
        damaged = copy.deepcopy(module)
        call_fixup = next(i for i,f in enumerate(module.fixups) if f.segment==1
                          and menu_start <= f.offset < menu_end and f.target_method==2
                          and module.externals[f.target-1]=='saveplayer_')
        damaged.fixups[call_fixup] = replace(damaged.fixups[call_fixup],
                                            displacement=damaged.fixups[call_fixup].displacement+1)
        self.assertFalse(compare_range(damaged, 1, menu_start, image, 1,
                         menu_row['target_offset'], menu_row['size'],
                         menu_row['bindings'], menu_row['placements'])['match'])
        with self.assertRaisesRegex(ValueError, 'changed source interval extent'):
            check_source_interval(module, image, 'menus_', 182544, 16191, menu_row['bindings'])

        # The inferred unused entry is ordinary static C. Its historical name
        # is unknown, and it must never become a cross-module export.
        from tools.probe_menues import check_complete_module
        from tools.verify_module import external_anchor_bindings
        proof = report['verification']
        self.assertEqual(proof['initialized_bytes'], 33762)
        self.assertEqual(proof['zero_fill_bytes'], 4571)
        self.assertEqual(proof['verified_fixups'], 2263)
        self.assertEqual(report['source_code_bytes'], 30763)
        self.assertEqual(sum(seg==1 for seg,_ in module.publics.values()), 20)
        inferred = 'menues_inferred_save_tail_entry_'
        self.assertIn(inferred, proof['local_symbols'])
        self.assertNotIn(inferred, external_anchor_bindings(proof))
        self.assertEqual(tuple(proof['local_symbols'][inferred]), (1, 178320))
        self.assertEqual(report['placements']['1'], [1, 173120])
        entry = module.publics[inferred][1]
        self.assertEqual(module.publics['saveplayer_'][1], entry+16)
        save_row = next(r for r in report['functions'] if r['symbol']=='saveplayer_')
        self.assertEqual(save_row['size'], 96)
        self.assertEqual(save_row['comparison']['verified_fixups'], 4)
        self.assertEqual(module.publics['probe_'][1], module.publics['saveplayer_'][1]+96)
        self.assertEqual(module.publics['loadplayer_'][1]+4416, entry)

        # Whole-segment gates protect the inferred prefix, every segment tail,
        # public starts and visibility; no old boundary/body-only substitute.
        known = {n:tuple(v) for n,v in proof['publics'].items()}
        for segment in [1, 2, 4, 5]:
            damaged = copy.deepcopy(module)
            damaged.segments[segment-1].data[-1] ^= 1
            with self.subTest(full_segment_tail=segment), self.assertRaises(ValueError):
                check_complete_module(damaged, image, known)
        for offset in [entry+1, entry+15]:
            damaged = copy.deepcopy(module)
            damaged.segments[0].data[offset] ^= 1
            with self.subTest(inferred_prefix=offset), self.assertRaises(ValueError):
                check_complete_module(damaged, image, known)
        damaged = copy.deepcopy(module)
        segment, offset = damaged.publics['saveplayer_']
        damaged.publics['saveplayer_'] = (segment, offset-16)
        with self.assertRaises(ValueError):
            check_complete_module(damaged, image, known)
        damaged = copy.deepcopy(module)
        damaged.local_publics.remove(inferred)
        with self.assertRaisesRegex(ValueError, 'inferred tail entry must remain local'):
            check_complete_module(damaged, image, known)
        damaged = copy.deepcopy(module)
        damaged.segments[0].size -= 1
        with self.assertRaisesRegex(ValueError, 'complete MENUES segment inventory'):
            check_complete_module(damaged, image, known)
        for extent in [4432, 2525]:
            with self.subTest(obsolete_or_trimmed_load=extent), self.assertRaisesRegex(ValueError, 'changed source interval extent'):
                check_source_interval(module, image, 'loadplayer_', 173904, extent, known)
