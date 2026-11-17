from pathlib import Path
import copy
from dataclasses import replace
import tempfile
import unittest

from tools.probe_gamedef import ROOT, probe, check_data, Module, LEImage
from tools.probe_premap import check_intervals
from tools.match_function import compare_range,MatchError


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and compiler required')
class GamedefProgressTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.directory=tempfile.TemporaryDirectory()
        build=Path(cls.directory.name)/'fresh'
        cls.report=probe(ROOT/'toolchains/watcom-10.0-ga',build)
        cls.module=Module.parse((build/'gamedef.obj').read_bytes())
        cls.image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())

    @classmethod
    def tearDownClass(cls):
        cls.directory.cleanup()

    def test_complete_intervals_and_data_still_do_not_complete_executable(self):
        report=self.report
        self.assertEqual(len(report['functions']),20)
        self.assertEqual(report['matched_function_bytes'],27265)
        self.assertEqual(report['matched_function_fixups'],2240)
        self.assertEqual(report['matched_initialized_data_bytes'],3569)
        self.assertEqual(report['matched_data_fixups'],99)
        self.assertTrue(report['full_module_gate']['verified'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['new_complete_contributions'],1)
        self.assertEqual(report['unverified_code_publics'],
                         [])
        prefix_end=0
        for function in sorted(report['functions'],key=lambda f:f['source_offset']):
            if function['symbol']=='execute_':continue
            self.assertEqual(function['source_offset'],prefix_end)
            self.assertEqual(function['target_offset'],145840+prefix_end)
            prefix_end+=function['size']
        self.assertEqual(prefix_end,26544)
        execute=next(f for f in report['functions'] if f['symbol']=='execute_')
        self.assertEqual(execute['source_offset']+execute['size'],self.module.segments[0].size)
        self.assertEqual(execute['target_offset']+execute['size'],173105)
        self.assertEqual(self.module.segments[0].data[-1],0xc3)
        self.assertEqual(execute['bindings']['_ps'],[3,376112])
        self.assertEqual(execute['bindings']['_g_i'],[3,77788])
        self.assertEqual(execute['bindings']['_g_t'],[3,77764])
        loading=next(f for f in report['functions'] if f['symbol']=='loadefs_')
        self.assertEqual(loading['bindings']['_last_used_end'],[3,77776])
        self.assertEqual(loading['bindings']['_total_script_lines'],[3,77796])

    def test_code_and_initialized_data_tails_are_unmasked(self):
        for row in self.report['functions']:
            damaged=copy.deepcopy(self.module)
            damaged.segments[0].data[row['source_offset']+row['size']-1]^=1
            with self.subTest(code=row['symbol']):
                try:
                    result=compare_range(damaged,1,row['source_offset'],self.image,1,
                                         row['target_offset'],row['size'],row['bindings'],row['placements'])
                except MatchError:
                    pass  # A switch-table tail may itself be a relocation.
                else:
                    self.assertFalse(result['match'])
        for row in self.report['initialized_data']:
            damaged=copy.deepcopy(self.module)
            damaged.segments[row['segment']-1].data[-1]^=1
            with self.subTest(data=row['segment']):
                with self.assertRaises(ValueError):
                    check_data(damaged,self.image)

    def test_literal_bound_and_player_member_addend_reject(self):
        keyword=next(f for f in self.report['functions'] if f['symbol']=='keyword_')
        self.assertEqual(self.module.segments[0].data[keyword['source_offset']+0x47],99)
        damaged=copy.deepcopy(self.module)
        damaged.segments[0].data[keyword['source_offset']+0x47]=100
        self.assertFalse(compare_range(damaged,1,keyword['source_offset'],self.image,1,
                         keyword['target_offset'],keyword['size'],keyword['bindings'],
                         keyword['placements'])['match'])
        parser=next(f for f in self.report['functions'] if f['symbol']=='parsecommand_')
        self.assertEqual(self.module.segments[0].data[parser['source_offset']+0x14c8],26)
        damaged=copy.deepcopy(self.module)
        damaged.segments[0].data[parser['source_offset']+0x14c8]=27
        self.assertFalse(compare_range(damaged,1,parser['source_offset'],self.image,1,
                         parser['target_offset'],parser['size'],parser['bindings'],
                         parser['placements'])['match'])
        execute=next(f for f in self.report['functions'] if f['symbol']=='execute_')
        damaged=copy.deepcopy(self.module)
        index=next(i for i,f in enumerate(damaged.fixups) if f.segment==1 and
                   execute['source_offset']<=f.offset<execute['source_offset']+execute['size'] and
                   f.target_method==2 and damaged.externals[f.target-1]=='_ps')
        damaged.fixups[index]=replace(damaged.fixups[index],displacement=damaged.fixups[index].displacement+1)
        with self.assertRaises(MatchError):
            compare_range(damaged,1,execute['source_offset'],self.image,1,
                          execute['target_offset'],execute['size'],execute['bindings'],
                          execute['placements'])

    def test_pointer_relocation_extra_data_and_owned_bss_reject(self):
        damaged=copy.deepcopy(self.module)
        index=next(i for i,f in enumerate(damaged.fixups) if f.segment==4)
        damaged.fixups[index]=replace(damaged.fixups[index],displacement=damaged.fixups[index].displacement+1)
        with self.assertRaises(ValueError):
            check_data(damaged,self.image)
        damaged=copy.deepcopy(self.module)
        damaged.segments[1].size=1
        damaged.segments[1].data.append(0)
        with self.assertRaises(ValueError):
            check_data(damaged,self.image)
        damaged=copy.deepcopy(self.module)
        segment,offset=damaged.publics['_g_i']
        damaged.publics['_g_i']=(segment,offset+2)
        definitions={f['symbol']:(f['target_offset'],f['size']) for f in self.report['functions']}
        with self.assertRaises(ValueError):
            check_intervals(damaged,self.image,definitions,{})

    def test_complete_descriptor_covers_every_segment_and_fixup(self):
        from tools.prove_module import prove
        from tools.verify_module import verify_module,ModuleError
        with tempfile.TemporaryDirectory() as directory:
            report=prove('gamedef',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
            module=Module.parse((Path(directory)/'gamedef.obj').read_bytes())
        v=report['verification']
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (30834,40,2339))
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(v['publics']['parse_'],(1,159312))
        self.assertEqual(v['publics']['execute_'],(1,172384))
        self.assertEqual(v['local_symbols']['_g_i'],(3,77788))
        for i,segment in enumerate(module.segments):
            if not segment.size:continue
            damaged=copy.deepcopy(module);damaged.segments[i].data[-1]^=1
            with self.subTest(segment=segment.name),self.assertRaises(ModuleError):
                verify_module(damaged,self.image,report['placements'],v['publics'])
        # Both interpreter jump-table entries and member relocations are checked.
        for label,predicate in [
            ('table_entry',lambda f:f.segment==1 and f.target_method==0 and
             12992<=f.offset<13472),
            ('interpreter_member',lambda f:f.segment==1 and f.target_method==2 and
             13472<=f.offset<26544 and module.externals[f.target-1]=='_ps')]:
            index=next(i for i,f in enumerate(module.fixups) if predicate(f))
            damaged=copy.deepcopy(module)
            damaged.fixups[index]=replace(damaged.fixups[index],displacement=damaged.fixups[index].displacement+1)
            with self.subTest(fixup=label),self.assertRaises(ModuleError):
                verify_module(damaged,self.image,report['placements'],v['publics'])
        # The descriptor must place the entire measured CODE and BSS ranges.
        by_name={s['symbol']:s for s in v['segments']}
        self.assertEqual(by_name['_TEXT']['target_offset']+by_name['_TEXT']['compared_bytes'],173105)
        self.assertEqual(by_name['_BSS']['target_offset']+by_name['_BSS']['compared_bytes'],77800)
