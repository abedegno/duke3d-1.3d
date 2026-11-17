from pathlib import Path
import copy
import json
from dataclasses import replace
import tempfile
import unittest
from tools.probe_premap import ROOT,probe,Module,LEImage,check_source_interval
from tools.match_function import compare_range


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and compiler required')
class PremapProgressTests(unittest.TestCase):
    def test_complete_native_module_owns_abort_byte(self):
        with tempfile.TemporaryDirectory() as directory:
            report=probe(ROOT/'toolchains/watcom-10.0-ga',Path(directory)/'fresh')
            module=Module.parse((Path(directory)/'fresh/premap.obj').read_bytes())
        self.assertEqual(len(report['functions']),22)
        self.assertEqual(report['matched_function_bytes'],12654)
        self.assertEqual(report['matched_function_fixups'],815)
        self.assertTrue('initialized_storage' in report,'missing initialized string-pool proof')
        self.assertTrue(report['initialized_storage']['verified'])
        self.assertEqual(report['matched_initialized_data_bytes'],278)
        self.assertEqual(report['initialized_storage']['verified_fixups'],0)
        self.assertTrue(report['initialized_data_verified'])
        self.assertTrue(report['bss_verified'], 'missing directly inferred owned BSS proof')
        self.assertEqual({row['class']:row['size'] for row in report['unverified_storage']},
                         {})
        self.assertTrue(report['full_module_gate']['verified'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['new_complete_contributions'],1)
        self.assertEqual(report['unverified_code_publics'],[])
        self.assertEqual(report['source_code_bytes'],report['matched_function_bytes'])
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        from tools.probe_premap import check_initialized_storage,ModuleError,check_intervals,FUNCTIONS
        from tools.infer_bindings import BindingError
        bindings={n:tuple(v) for row in report['functions'] for n,v in row['bindings'].items()}
        from tools.probe_premap import check_owned_state,check_complete
        bss=report['bss_storage']
        self.assertTrue(bss['verified'])
        self.assertEqual((bss['initialized_bytes'],bss['zero_fill_bytes'],bss['verified_fixups']),(0,5,0))
        self.assertEqual(report['matched_bss_bytes'],5)
        self.assertEqual(bss['local_symbols'],{'_dmval':(3,587552)})
        self.assertEqual(bss['publics'],{'_wait_abort':(3,587556)})
        self.assertNotIn('placement_basis',bss)
        self.assertNotIn('dependencies',bss)
        from tools.verify_module import verify_module,external_anchor_bindings
        self.assertTrue((ROOT/'modules/premap.json').is_file())
        spec=json.loads((ROOT/'modules/premap.json').read_text())
        proof=report['verification'];placements=report['placements'];symbols=proof['publics']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),
                         (12932,5,815))
        self.assertEqual({int(k):tuple(v) for k,v in placements.items()},
                         {1:(1,240976),5:(3,587552),6:(3,10600)})
        self.assertEqual(set(module.publics),set(FUNCTIONS)|{'_dmval','_premap_text','_wait_abort'})
        self.assertTrue(report['leading_code_prefix_verified'])
        self.assertEqual(report['following_alignment_gap'],{'target_object':1,'start':253630,
                         'end':253632,'bytes':2,'all_zero':True,'source_contribution':False})
        self.assertEqual(module.segments[3].size,0)  # Removed unsupported global palette index.
        for name in ['_dmval','_premap_text']:
            self.assertNotIn(name,external_anchor_bindings(proof))
        self.assertEqual(tuple(external_anchor_bindings(proof)['_wait_abort']),(3,587556))
        self.assertEqual(module.publics['_wait_abort'],(5,4))
        self.assertNotIn('_wait_abort',module.local_publics)
        fullknown={**{name:tuple(value) for name,value in spec['symbol_anchors'].items()},
                   **{name:(1,offset) for name,(offset,_) in FUNCTIONS.items()}}
        for segment,offset in [(1,0),(1,7456),(1,12653),(6,0),(6,277)]:
            damaged=copy.deepcopy(module);damaged.segments[segment-1].data[offset]^=1
            with self.subTest(full_module_byte=(segment,offset)),self.assertRaises(ModuleError):
                verify_module(damaged,image,placements,symbols)
        changed=copy.deepcopy(placements);changed[6]=(3,10604)
        with self.assertRaises(ModuleError):verify_module(module,image,changed,symbols)
        self.assertNotIn('bss_boundary',spec)
        self.assertNotIn('boundary_evidence',spec)
        wrong=copy.deepcopy(placements);wrong[5]=(3,587568)
        with self.assertRaises(ModuleError):verify_module(module,image,wrong,symbols)
        with self.assertRaises(ValueError):
            check_complete(module,image,{**fullknown,'_wait_abort':(3,587555)},spec)
        # Redirect a real PS relocation toward owned BSS: inference cannot
        # replace the abort-derived native base to accommodate a false role.
        damaged=copy.deepcopy(module)
        index=next(i for i,f in enumerate(damaged.fixups) if f.segment==1 and
                   not f.relative and f.target_method==2 and damaged.externals[f.target-1]=='_ps')
        damaged.fixups[index]=replace(damaged.fixups[index],target_method=0,target=5)
        with self.assertRaises(ValueError):check_complete(damaged,image,fullknown,spec)
        ps=next(row for row in report['functions'] if row['symbol']=='resetpspritevars_')
        self.assertEqual((ps['source_offset'],ps['size'],ps['comparison']['verified_fixups']),(7456,1328,87))
        # Both saved aiming-byte member displacements are native operands, and
        # both weapon-copy loops plus the palette wrap remain unmasked CODE.
        member=(1332).to_bytes(4,'little')
        body=bytes(module.segments[0].data[7456:7456+1328])
        member_offsets=[position for position in range(len(body)-3) if body[position:position+4]==member]
        self.assertEqual(len(member_offsets),2)
        for position in member_offsets:
            damaged=copy.deepcopy(module);damaged.segments[0].data[7456+position]^=1
            with self.subTest(saved_aim_member=position),self.assertRaises(ModuleError):
                verify_module(damaged,image,placements,symbols)
        # A fixed palette limit immediate is independent of relocation bindings.
        self.assertEqual(body[0x422],17)
        damaged=copy.deepcopy(module);damaged.segments[0].data[7456+0x422]=16
        with self.assertRaises(ModuleError):verify_module(damaged,image,placements,symbols)
        bss_segment=module.publics['_dmval'][0]
        for description,damage in [('alignment',lambda m:setattr(m.segments[bss_segment-1],'attributes',169)),
                                   ('size',lambda m:setattr(m.segments[bss_segment-1],'size',6)),
                                   ('name',lambda m:setattr(m.segments[bss_segment-1],'name','OTHER_BSS')),
                                   ('local offset',lambda m:m.publics.update({'_dmval':(bss_segment,1)})),
                                   ('local scope',lambda m:m.local_publics.remove('_dmval')),
                                   ('abort offset',lambda m:m.publics.update({'_wait_abort':(bss_segment,3)})),
                                   ('abort scope',lambda m:m.local_publics.add('_wait_abort')),
                                   ('scratch byte',lambda m:m.segments[bss_segment-1].data.__setitem__(0,1)),
                                   ('abort byte',lambda m:m.segments[bss_segment-1].data.__setitem__(4,1))]:
            damaged=copy.deepcopy(module);damage(damaged)
            with self.subTest(owned_state_corruption=description),self.assertRaises(ValueError):
                check_owned_state(damaged)
        for offset in (0,4):
            damaged=copy.deepcopy(module);damaged.segments[bss_segment-1].data[offset]=1
            with self.subTest(whole_BSS_byte=offset),self.assertRaises(ModuleError):
                verify_module(damaged,image,placements,symbols)
        # Real source counterfactuals distinguish ownership, exported scope,
        # byte width and reset behavior; none changes the accepted declaration.
        from runner import compile_source
        from tools.prove_module import prepare_headers
        source=(ROOT/'src/game/premap.c').read_text()
        with tempfile.TemporaryDirectory() as temporary:
            for label,before,after in [('external','char wait_abort;','extern char wait_abort;'),
                                       ('private','char wait_abort;','static char wait_abort;'),
                                       ('wrong-width','char wait_abort;','short wait_abort;'),
                                       ('wrong-reset','    wait_abort = 0;','    wait_abort = 1;')]:
                stage=Path(temporary)/label;stage.mkdir();candidate=stage/'premap.c'
                self.assertEqual(source.count(before),1);candidate.write_text(source.replace(before,after))
                headers=stage/'include';prepare_headers([ROOT/p for p in spec['reference_headers']],
                                                       [ROOT/p for p in spec['overlay_headers']],headers)
                obj=stage/'premap.obj';compile_source(ROOT/'toolchains/watcom-10.0-ga',candidate,obj,spec['options'],30,include_dirs=[headers])
                mutated=Module.parse(obj.read_bytes())
                with self.subTest(source_owner=label),self.assertRaises(ValueError):
                    check_complete(mutated,image,fullknown,spec)
        segment,offset=module.publics['_premap_text']
        self.assertEqual(offset,0)
        self.assertEqual(module.segments[segment-1].size,278)
        self.assertEqual(bindings['_premap_text'],(3,10600))
        self.assertEqual(report['initialized_storage']['local_symbols']['_premap_text'],(3,10600))
        for position in [0,27,57,230,277]:
            damaged=copy.deepcopy(module)
            damaged.segments[segment-1].data[position]^=1
            with self.subTest(string_or_alignment_byte=position),self.assertRaises(ModuleError):
                check_initialized_storage(damaged,image,bindings)
        with self.assertRaises((ValueError,BindingError)):
            check_intervals(module,image,FUNCTIONS,{**bindings,'_premap_text':(3,10604)})
        for function in report['functions']:
            args=(1,function['source_offset'],image,1,function['target_offset'],function['size'])
            original=compare_range(module,*args,function['bindings'],function['placements'])
            self.assertTrue(original['match'])
            damaged=copy.deepcopy(module)
            damaged.segments[0].data[function['source_offset']+function['size']-1]^=1
            with self.subTest(tail=function['symbol']):
                result=compare_range(damaged,*args,function['bindings'],function['placements'])
                self.assertFalse(result['match'])
        prestat=next(f for f in report['functions'] if f['symbol']=='resetprestat_')
        self.assertEqual(module.segments[0].data[prestat['source_offset']+0x3b],64)
        damaged=copy.deepcopy(module)
        damaged.segments[0].data[prestat['source_offset']+0x3b]=63
        self.assertFalse(compare_range(damaged,1,prestat['source_offset'],image,1,
                         prestat['target_offset'],prestat['size'],prestat['bindings'],
                         prestat['placements'])['match'])
        stats=next(f for f in report['functions'] if f['symbol']=='resetplayerstats_')
        self.assertEqual(stats['bindings']['_weapon_tiles'],[3,31116])
        self.assertEqual(stats['bindings']['setpal_'],[1,204096])
        remaps=next(f for f in report['functions'] if f['symbol']=='genspriteremaps_')
        self.assertEqual(remaps['bindings']['_tempbuf'],[3,413968])
        self.assertEqual(remaps['bindings']['_loadfromgrouponly'],[3,582928])
        entry=next(f for f in report['functions'] if f['symbol']=='enterlevel_')
        self.assertEqual(entry['source_offset']+entry['size'],module.segments[0].size)
        self.assertEqual(entry['size'],1390)
        self.assertEqual(entry['target_offset']+entry['size'],253630)
        self.assertEqual(module.segments[0].data[-1],0xc3)
        timing=next(f for f in report['functions'] if f['symbol']=='resettimevars_')
        self.assertEqual(timing['bindings']['_totalclock'],[3,1644968])
        self.assertEqual(timing['bindings']['_ps'],[3,376112])
        for name in ['_mymaxlag','_otherminlag','_myminlag']:
            self.assertEqual(entry['bindings'][name],timing['bindings'][name])
        wait=next(f for f in report['functions'] if f['symbol']=='waitforeverybody_')
        packet=next(f for f in report['functions'] if f['symbol']=='compare_network_value_')
        self.assertEqual(wait['bindings']['sendpacket_'],[1,423523])
        self.assertEqual(packet['bindings']['sendpacket_'],[1,423523])
        self.assertEqual(wait['bindings']['getpackets_'],packet['bindings']['getpackets_'])
        self.assertEqual(wait['bindings']['_wait_abort'],[3,587556])
        self.assertEqual(packet['bindings']['_received_sync_value'],[3,574840])
        self.assertEqual(packet['bindings']['_tempbuf'],remaps['bindings']['_tempbuf'])
        # Both handshake phases and the packet's high-byte mask are literal
        # instructions; neither may disappear behind relocation handling.
        for function,offset,expected in [(wait,0x3d,2),(packet,0x45,0x7f)]:
            self.assertEqual(module.segments[0].data[function['source_offset']+offset],expected)
            damaged=copy.deepcopy(module)
            damaged.segments[0].data[function['source_offset']+offset]^=1
            result=compare_range(damaged,1,function['source_offset'],image,1,function['target_offset'],
                                 function['size'],function['bindings'],function['placements'])
            self.assertFalse(result['match'])
        self.assertTrue(all(f['bindings'].get('loadtile_', [1,328028])==[1,328028]
                            for f in report['functions']))
        function=next(f for f in report['functions'] if 'loadtile_' in f['bindings'])
        i=next(i for i,f in enumerate(module.fixups) if f.segment==1 and
               function['source_offset']<=f.offset<function['source_offset']+function['size'] and
               f.target_method==2 and module.externals[f.target-1]=='loadtile_')
        damaged=copy.deepcopy(module)
        damaged.fixups[i]=replace(damaged.fixups[i],displacement=damaged.fixups[i].displacement+1)
        result=compare_range(damaged,1,function['source_offset'],image,1,function['target_offset'],
                             function['size'],function['bindings'],function['placements'])
        self.assertFalse(result['match'])
        # The eight-entry game-side sky clear is an instruction immediate,
        # independent of the engine's larger sky-offset storage declaration.
        backdrop=next(f for f in report['functions'] if f['symbol']=='setupbackdrop_')
        damaged=copy.deepcopy(module)
        damaged.segments[0].data[backdrop['source_offset']+0x1e]^=1
        result=compare_range(damaged,1,backdrop['source_offset'],image,1,backdrop['target_offset'],
                             backdrop['size'],backdrop['bindings'],backdrop['placements'])
        self.assertFalse(result['match'])
        # A player-member displacement has no relocation to mask or rebind.
        reset=next(f for f in report['functions'] if f['symbol']=='resetweapons_')
        damaged=copy.deepcopy(module)
        damaged.segments[0].data[reset['source_offset']+0x5c]^=1
        result=compare_range(damaged,1,reset['source_offset'],image,1,reset['target_offset'],
                             reset['size'],reset['bindings'],reset['placements'])
        self.assertFalse(result['match'])
        function=next(f for f in report['functions'] if f['symbol']=='cachegoodsprites_')
        damaged=copy.deepcopy(module)
        inherited=next(f for f in damaged.fixups if f.segment==1 and f.width==4)
        damaged.fixups.append(replace(inherited,offset=function['source_offset']-1))
        with self.assertRaisesRegex(ValueError,'crosses'):
            check_source_interval(damaged,image,function['symbol'],function['target_offset'],
                                  function['size'],function['bindings'])
