"""Native complete SECTOR contribution, with every byte and fixup required."""
from pathlib import Path
import copy
from dataclasses import replace
import importlib
import hashlib
import json
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and compiler required')
class SectorProgressTests(unittest.TestCase):
    def test_complete_module_intervals_storage_and_corruptions(self):
        self.assertTrue((ROOT/'tools/probe_sector.py').is_file(),
                        'production SECTOR native probe is missing')
        probe=importlib.import_module('tools.probe_sector')
        from tools.match_function import compare_range,MatchError
        from tools.infer_bindings import BindingError
        with tempfile.TemporaryDirectory() as directory:
            build=Path(directory)/'fresh'
            report=probe.probe(ROOT/'toolchains/watcom-10.0-ga',build)
            module=probe.Module.parse((build/'sector.obj').read_bytes())
        committed=json.loads((ROOT/'evidence/sector-module.json').read_text())
        for key in ['source_reference_evidence','source_reference_sha256',
                    'following_alignment_gap']:
            with self.subTest(committed_metadata=key):
                self.assertIn(key,committed)
                self.assertEqual(committed[key],report[key])
        self.assertEqual(report['source_reference_evidence'],
                         'evidence/sector-source-reference.json')
        self.assertEqual(report['source_reference_sha256'],hashlib.sha256(
            (ROOT/report['source_reference_evidence']).read_bytes()).hexdigest())
        self.assertEqual(report['following_alignment_gap'],
                         {'target_object':1,'start':281585,'end':281600,
                          'bytes':15,'all_zero':True,'source_contribution':False})
        self.assertEqual(len(report['functions']),30)
        self.assertEqual({f['symbol']:(f['target_offset'],f['size'])
                          for f in report['functions']},{
            'checkcursectnums_':(254688,80),'checkhitceiling_':(268608,720),
            'checkplayerhurt_':(268048,560),'dist_':(254816,48),
            'doanimations_':(255360,704),'findotherplayer_':(255152,208),
            'findplayer_':(254864,288),'getanimationgoal_':(256064,48),
            'isanearoperator_':(254640,48),'operatemasterswitches_':(262112,80),
            'setanimation_':(256112,144),'ldist_':(254768,48),
            'isadoorwall_':(254448,160),'isanunderoperator_':(254608,32),
            'callsound_':(253632,480),'check_activator_motion_':(254112,336),
            'operateforcefields_':(262192,224),
            'animatecamsprite_':(256256,240),'animatewalls_':(256496,544),
            'activatewarpelevators_':(257040,464),'operatesectors_':(257504,3824),
            'operaterespawns_':(261328,144),'operateactivators_':(261472,640),
            'checkhitswitch_':(262416,3440),'activatebysector_':(265856,80),
            'checkhitwall_':(265936,2112),'checkhitsprite_':(269328,5616),
            'allignwarpelevators_':(274944,336),'cheatkeys_':(275280,2720),
            'checksectors_':(278000,3585)})
        self.assertEqual(report['matched_function_bytes'],27953)
        self.assertEqual(report['matched_function_fixups'],1382)
        self.assertTrue(report['full_module_gate']['verified'])
        self.assertEqual(report['full_module_gate']['initialized_bytes'],27953)
        self.assertEqual(report['full_module_gate']['zero_fill_bytes'],5)
        self.assertEqual(report['full_module_gate']['verified_fixups'],1382)
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['new_complete_contributions'],1)
        self.assertEqual(report['omitted_code_publics'],[])
        self.assertNotIn('breakwall_',module.publics)
        self.assertEqual(report['removed_later_code_publics'],['breakwall_'])
        self.assertEqual(report['source_code_bytes'],27953)
        self.assertEqual(report['unverified_code_publics'],[])
        self.assertTrue(report['initialized_data_verified'])
        self.assertTrue(report['bss_verified'])
        self.assertTrue(report['noncode_storage_verified'])
        self.assertEqual(report['noncode_storage']['zero_fill_bytes'],5)
        self.assertEqual(report['noncode_storage']['local_symbols']['_dmval'],(3,587568))
        self.assertTrue(report['leading_code_prefix_verified'])
        self.assertEqual(report['unverified_storage'],[])
        self.assertTrue(report['anchor_evidence_sha256'])
        self.assertTrue(report['headers_sha256'])
        self.assertEqual(report['excluded_location_candidates'],
                         [])
        image=probe.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        rows={f['symbol']:f for f in report['functions']}
        def compare(candidate,function):
            try:
                return compare_range(candidate,1,function['source_offset'],image,1,
                                     function['target_offset'],function['size'],
                                     function['bindings'],function['placements'])['match']
            except MatchError:
                return False
        # Every full public interval, including its last byte, is required.
        shared={}
        for function in report['functions']:
            self.assertTrue(compare(module,function))
            for name,value in function['bindings'].items():
                self.assertEqual(shared.setdefault(name,value),value)
            damaged=copy.deepcopy(module)
            damaged.segments[0].data[function['source_offset']+function['size']-1]^=1
            with self.subTest(tail=function['symbol']):
                self.assertFalse(compare(damaged,function))
            with self.subTest(extent=function['symbol']):
                with self.assertRaisesRegex(ValueError,'extent'):
                    probe.check_source_interval(module,image,function['symbol'],
                          function['target_offset'],function['size']-1,function['bindings'])
        # Pointer and call target mutations must retain their independent bindings.
        for name,symbol in [('_animateptr','doanimations_'),
                            ('stopinterpolation_','doanimations_'),
                            ('FindDistance3D_','dist_'),
                            ('FindDistance2D_','ldist_'),
                            ('xyzsound_','checkhitswitch_'),
                            ('EGS_','checkhitwall_'),
                            ('badguy_','checkhitsprite_'),
                            ('MUSIC_Pause_','cheatkeys_'),
                            ('neartag_','checksectors_')]:
            function=rows[symbol]
            index=next(i for i,f in enumerate(module.fixups) if f.segment==1 and
                       function['source_offset']<=f.offset<function['source_offset']+function['size']
                       and f.target_method==2 and module.externals[f.target-1]==name)
            damaged=copy.deepcopy(module)
            damaged.fixups[index]=replace(damaged.fixups[index],
                                         displacement=damaged.fixups[index].displacement+1)
            with self.subTest(fixup=name):
                self.assertFalse(compare(damaged,function))
                with self.assertRaises((ValueError,BindingError)):
                    probe.check_intervals(damaged,image,probe.FUNCTIONS,shared)
        # Public intervals include the following functions' switch-table prefixes.
        for symbol,offset,count in [('isadoorwall_',104,12),('animatecamsprite_',188,13),
                                    ('activatewarpelevators_',368,23),
                                    ('allignwarpelevators_',212,31)]:
            function=rows[symbol]
            table=function['source_offset']+offset
            table_fixups=[(i,f) for i,f in enumerate(module.fixups)
                          if f.segment==1 and table<=f.offset<table+count*4]
            self.assertEqual(len(table_fixups),count)
            self.assertEqual([f.offset-table for _,f in table_fixups],list(range(0,count*4,4)))
            for index,fixup in table_fixups:
                damaged=copy.deepcopy(module)
                damaged.fixups[index]=replace(fixup,displacement=fixup.displacement+1)
                with self.subTest(prefix_table=(symbol,fixup.offset-table)):
                    self.assertFalse(compare(damaged,function))
        door=rows['isadoorwall_']
        for function,operand in [(door,3),(rows['isanunderoperator_'],8)]:
            damaged=copy.deepcopy(module)
            damaged.segments[0].data[function['source_offset']+operand]^=1
            self.assertFalse(compare(damaged,function))
        # Restored early behavior and the whole five-byte BSS stay mandatory.
        for symbol,offset,expected in [('callsound_',0x127,0x89),
                                       ('check_activator_motion_',0xea,36),
                                       ('operateforcefields_',0xc7,85),
                                       ('animatewalls_',0x2e,7),
                                       ('activatewarpelevators_',0xed,73),
                                       ('operatesectors_',0x949,128),
                                       ('operaterespawns_',0x12,22),
                                       ('operateactivators_',0x116,64),
                                       ('checkhitwall_',0x5d0,20),
                                       ('checkhitwall_',0x26d,0xc6),
                                       ('checkhitsprite_',0x15c6,3),
                                       ('cheatkeys_',0x4b,0x34),
                                       ('checksectors_',0x383,0xb2)]:
            function=rows[symbol]
            self.assertEqual(module.segments[0].data[function['source_offset']+offset],expected)
            damaged=copy.deepcopy(module)
            damaged.segments[0].data[function['source_offset']+offset]^=1
            with self.subTest(restored_operand=symbol):
                self.assertFalse(compare(damaged,function))
        bindings={n:tuple(v) for row in report['functions'] for n,v in row['bindings'].items()}
        damaged=copy.deepcopy(module)
        damaged.segments[4].data[0]=1
        with self.assertRaises(probe.ModuleError):
            probe.check_storage(damaged,image,bindings)
        with self.assertRaises((ValueError,BindingError)):
            probe.check_storage(module,image,{**bindings,'_haltsoundhack':(3,587573)})
        # The player i member is the 724-byte addend on the _ps reference.
        # It must be checked even though its absolute address is relocated.
        function=rows['checkcursectnums_']
        member=function['source_offset']+37
        self.assertEqual(module.segments[0].data[member:member+4],b'\xd4\x02\x00\x00')
        damaged=copy.deepcopy(module)
        damaged.segments[0].data[member]^=1
        self.assertFalse(compare(damaged,function))
        # One complete native placement covers all intervals, CODE tables and BSS.
        end=0
        for function in sorted(report['functions'],key=lambda f:f['source_offset']):
            self.assertEqual(function['source_offset'],end)
            self.assertEqual(function['target_offset'],253632+end)
            end+=function['size']
        self.assertEqual(end,module.segments[0].size)
        self.assertEqual(end+253632,281585)
        self.assertEqual(module.segments[0].data[-1],0xc3)
        self.assertEqual(image.object_bytes(1)[281585:281600],bytes(15))
        for segment in [0,4]:
            damaged=copy.deepcopy(module)
            damaged.segments[segment].data[-1]^=1
            with self.subTest(full_segment=segment),self.assertRaises(probe.ModuleError):
                probe.verify_module(damaged,image,report['placements'],report['verification']['publics'])
        damaged=copy.deepcopy(module)
        damaged.segments[0].data[0]^=1
        with self.assertRaises(probe.ModuleError):
            probe.verify_module(damaged,image,report['placements'],report['verification']['publics'])
        self.assertEqual(report['verification']['local_symbols']['_dmval'],(3,587568))
        from tools.verify_module import external_anchor_bindings
        self.assertNotIn('_dmval',external_anchor_bindings(report['verification']))
        descriptor=json.loads((ROOT/'modules/sector.json').read_text())
        self.assertEqual(descriptor['code_bytes'],27953)
        self.assertEqual(descriptor['code_publics'],30)
        self.assertEqual(descriptor['expected'],{'initialized_bytes':27953,'zero_fill_bytes':5,'verified_fixups':1382})
        self.assertEqual(report['descriptor'],'modules/sector.json')
        # A caller cannot bind one player array to a second physical address.
        with self.assertRaises((ValueError,BindingError)):
            probe.check_intervals(module,image,probe.FUNCTIONS,
                                  {**shared,'_ps':(3,376113)})



if __name__=='__main__':unittest.main()
