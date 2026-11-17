from pathlib import Path
import copy
import json
from dataclasses import replace
import tempfile
import unittest
from unittest.mock import patch
import subprocess

ROOT=Path(__file__).resolve().parents[1]


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and native compiler required')
class GlobalProgressTests(unittest.TestCase):
    def test_complete_identified_data_segment_keeps_global_layout_unproved(self):
        self.assertTrue((ROOT/'src/game/global.c').is_file(),'missing recovered GLOBAL source')
        from tools.probe_global import probe,Module,LEImage,check_initialized_storage
        from tools.verify_module import ModuleError,external_anchor_bindings
        from tools.infer_bindings import BindingError
        with tempfile.TemporaryDirectory() as temporary:
            build=Path(temporary)/'fresh'
            report=probe(ROOT/'toolchains/watcom-10.0-ga',build)
            module=Module.parse((build/'global.obj').read_bytes())
            callers={name:(Module.parse((build/(name+'-references')/(name+'.obj')).read_bytes()),
                           json.loads((build/(name+'-references.json')).read_text()))
                     for name in ['actors','menues']}
            game_caller=Module.parse((build/'game-references/game.obj').read_bytes())
            with self.assertRaises(FileExistsError):probe(ROOT/'toolchains/watcom-10.0-ga',build)
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        proof=report['initialized_storage']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),(288,0,0))
        self.assertTrue(proof['verified'])
        self.assertEqual(report['matched_initialized_data_bytes'],288)
        self.assertEqual(report['source_code_bytes'],0)
        self.assertEqual(len(report['raw_label_references']),7)
        self.assertTrue(all(row['associated_code_body_verified'] is False for row in report['raw_label_references']))
        self.assertNotIn('_dmval',report['observed_external_bindings'])
        self.assertEqual(tuple(report['observed_external_bindings']['_tempbuf']),(3,413968))
        self.assertFalse(report['initialized_data_verified'])
        self.assertTrue(report['bss_verified'],'missing whole produced BSS projection')
        self.assertFalse(report['full_module_gate']['verified'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['new_complete_contributions'],0)
        self.assertEqual(report['unidentified_adjacent_initialized_range'],
                         {'target_object':3,'start':30820,'end':30916,'bytes':96,'allocation_verified':False})
        self.assertEqual(report['unverified_storage'],[])
        self.assertEqual(report['produced_storage_verification']['zero_fill_bytes'],505130)
        self.assertFalse(report['historical_allocation_verified'])
        self.assertEqual({tuple(row['implied_placement']) for row in report['binding_diagnostics']
                          if row['source_segment']==5},{(3,77808)})
        isolated=report['source_declaration_isolation']
        self.assertTrue(isolated)
        self.assertEqual(isolated['volume_names']['alias'],'unused_later_volume_names_declaration')
        self.assertEqual(isolated['skill_names']['alias'],'unused_later_skill_names_declaration')
        for name,contract in isolated.items():
            alias=contract['alias']
            with self.subTest(isolated_declaration=name):
                self.assertFalse(any(alias in symbol for symbol in module.publics))
                self.assertFalse(any(alias in symbol for symbol in module.externals))
        segment=proof['source_segments'][0]
        self.assertEqual((segment,module.segments[segment-1].size),(4,288))
        self.assertEqual(len([n for n,(s,_) in module.publics.items() if s==segment]),17)
        self.assertEqual(tuple(proof['publics']['_volume_names']),(3,30916))
        self.assertEqual(tuple(proof['publics']['_skill_names']),(3,31015))
        self.assertEqual(tuple(proof['publics']['_weapon_tiles']),(3,31116))
        self.assertEqual(module.segments[segment-1].data[222:224],b"T'")
        self.assertEqual(module.segments[segment-1].data[262:264],b'MN')
        for name in ['_weapon_tiles_alignment','_weapons_ammo_alignment']:
            self.assertIn(name,module.local_publics)
            self.assertNotIn(name,external_anchor_bindings(proof))
        for position in [0,33,98,99,198,199,200,221,222,223,224,262,263,287]:
            damaged=copy.deepcopy(module);damaged.segments[segment-1].data[position]^=1
            with self.subTest(data_or_alignment=position),self.assertRaises(ModuleError):
                check_initialized_storage(damaged,image,report['observed_external_bindings'])
        from omf32 import Fixup
        damaged=copy.deepcopy(module)
        damaged.fixups.append(Fixup(segment,0,4,9,False,1,None,0,segment,0))
        with self.assertRaises(BindingError):
            check_initialized_storage(damaged,image,report['observed_external_bindings'])
        damaged=copy.deepcopy(module);damaged.publics['_unexpected_data_public']=(segment,0)
        with self.assertRaises(ValueError):
            check_initialized_storage(damaged,image,report['observed_external_bindings'])
        from tools.probe_global import (check_produced_storage,caller_row_references,
                                        backup_role_operands,chat_role_operands,raw_state_roles)
        from tools.probe_actors import FUNCTIONS as actor_definitions
        produced=report['produced_storage_verification']
        self.assertEqual((produced['initialized_bytes'],produced['zero_fill_bytes'],produced['verified_fixups']),
                         (288,505130,0))
        self.assertEqual({int(k):tuple(v) for k,v in report['produced_storage_placements'].items()},
                         {4:(3,30916),5:(3,77808)})
        self.assertFalse(any(row['source_segment']==5 for row in report['native_data_records']))
        self.assertEqual(report['source_only_order_control']['runtime_allocations_added'],0)
        self.assertEqual(tuple(report['observed_external_bindings']['_oldipos']),(3,90096))
        self.assertEqual(tuple(report['observed_external_bindings']['_current_menu']),(3,574864))
        for name,address in [('_syncval',86000),('_sbar',579556),('_rtsplaying',582929),('_networkmode',31185)]:
            self.assertEqual(tuple(report['observed_external_bindings'][name]),(3,address))
            self.assertNotIn(name,report['unreferenced_source_publics'])
        game_reference=report['reference_evidence']['native:game']
        self.assertEqual(game_reference['verified_function_rows'],45)
        self.assertEqual(game_reference['reviewed_commit'],'88f6fcd83b4d075575653b8ef2a460c971c19337')
        for name in ['_received_quote','_received_quote_time','_rtsplaying']:
            row=next(row for row in report['binding_diagnostics'] if row['symbol']==name)
            self.assertIn('native:game/getpackets_',row['reference_evidence'])
        for name,address in [('_myxbak',107632),('_myybak',108656),('_myangbak',109680),
                             ('_myhorizbak',110192),('_received_quote',579460),('_received_quote_time',581296)]:
            self.assertEqual(tuple(report['observed_external_bindings'][name]),(3,address))
        self.assertNotIn('_everyothertime',module.publics)
        self.assertNotIn('_everyothertime',report['observed_external_bindings'])
        for name in ['_dmval','_weapon_tiles_alignment','_weapons_ammo_alignment']:
            self.assertNotIn(name,external_anchor_bindings(produced))
        for position in [0,28800,505129]:
            damaged=copy.deepcopy(module);damaged.segments[4].data[position]=1
            with self.subTest(bss_initialized_byte=position),self.assertRaises(ModuleError):
                check_produced_storage(damaged,image,report['observed_external_bindings'],report['native_data_records'])
        damaged=copy.deepcopy(module);segment,offset=damaged.publics['_oldipos']
        damaged.publics['_oldipos']=(segment,offset+4)
        with self.assertRaises(BindingError):
            check_produced_storage(damaged,image,report['observed_external_bindings'],report['native_data_records'])
        damaged=copy.deepcopy(module);damaged.segments[4].attributes=169
        with self.assertRaises(ValueError):
            check_produced_storage(damaged,image,report['observed_external_bindings'],report['native_data_records'])
        with self.assertRaisesRegex(ValueError,'initialized OMF payload'):
            check_produced_storage(module,image,report['observed_external_bindings'],
                                   report['native_data_records']+[{'source_segment':5,'source_offset':0,'kind':'0xa1'}])
        code=image.object_bytes(1);fixups=image.read_fixups();references=report['observed_external_bindings']
        for position in [0x120ec,0x120f2,0x12128,0x12136]:
            damaged=bytearray(code);damaged[position]^=1
            with self.subTest(backup_operand=position),self.assertRaises(ValueError):
                backup_role_operands(damaged,fixups,references)
        index=next(i for i,f in enumerate(fixups) if f.source_object==1 and f.source_offset==0x120ff)
        for field,value in [('width',2),('source_offset',0x12100),('target_object',4),('alias',True)]:
            damaged=list(fixups);damaged[index]=replace(damaged[index],**{field:value})
            with self.subTest(raw_fixup=field),self.assertRaises(ValueError):
                backup_role_operands(code,damaged,references)
        changed=dict(references);changed['_myx']=(3,references['_myx'][1]+4)
        with self.assertRaises(ValueError):backup_role_operands(code,fixups,changed)
        callees=report['raw_state_roles']['consumer_callees']
        for position in [0xe76,0xe82,0xe9d]:
            damaged=bytearray(code);damaged[position]^=1
            with self.subTest(chat_producer=position),self.assertRaises(ValueError):
                chat_role_operands(damaged,fixups,references,callees)
        changed=dict(callees);changed['strcpy_']=(1,callees['strcpy_'][1]+1)
        with self.assertRaises(ValueError):chat_role_operands(code,fixups,references,changed)
        damaged=bytearray(image.data);damaged[-1]^=1
        with self.assertRaisesRegex(ValueError,'identity'):
            raw_state_roles(replace(image,data=bytes(damaged)),references)
        caller,caller_report=callers['actors']
        observed,_=caller_row_references(module,caller,image,caller_report,actor_definitions)
        self.assertIn('_oldipos',observed)
        damaged=copy.deepcopy(caller);damaged.local_externals.add(damaged.externals.index('_oldipos')+1)
        filtered,_=caller_row_references(module,damaged,image,caller_report,actor_definitions)
        self.assertNotIn('_oldipos',filtered)
        collision=copy.deepcopy(module);collision.publics['setinterpolation_']=(5,0)
        filtered,_=caller_row_references(collision,caller,image,caller_report,actor_definitions)
        self.assertNotIn('setinterpolation_',filtered)
        damaged=copy.deepcopy(caller);row=caller_report['functions'][0]
        damaged.segments[0].data[row['source_offset']+row['size']-1]^=1
        with self.assertRaises(ValueError):
            caller_row_references(module,damaged,image,caller_report,actor_definitions)
        changed=copy.deepcopy(caller_report)
        row=next(row for row in changed['functions'] if '_oldipos' in row['bindings'])
        row['bindings']['_oldipos']=[3,90092]
        with self.assertRaises(ValueError):
            caller_row_references(module,caller,image,changed,actor_definitions)
        from tools.probe_global import (reviewed_game_inputs,fresh_reviewed_game_references,
                                        GAME_REFERENCE_BLOBS)
        original_git=subprocess.check_output
        for path in GAME_REFERENCE_BLOBS:
            def corrupt_blob(args,**kwargs):
                raw=original_git(args,**kwargs)
                return raw+b'\n' if args[-1].endswith(':'+path) else raw
            with self.subTest(corrupt_reviewed_blob=path),patch(
                    'tools.probe_global.subprocess.check_output',side_effect=corrupt_blob):
                with self.assertRaisesRegex(ValueError,'blob identity'):
                    reviewed_game_inputs()
        with patch('tools.probe_global.subprocess.check_output',side_effect=
                   subprocess.CalledProcessError(128,['git','show'],stderr=b'missing object')):
            with self.assertRaisesRegex(ValueError,'unavailable; no fetch or fallback'):
                reviewed_game_inputs()
        game_source,game_report,game_definitions=reviewed_game_inputs()
        for identity in ['headers_sha256','compiler_sha256']:
            changed=copy.deepcopy(game_report);changed[identity]={} if identity=='headers_sha256' else 'changed'
            with self.subTest(reviewed_input=identity),tempfile.TemporaryDirectory() as stage:
                with patch('tools.probe_global.reviewed_game_inputs',return_value=
                           (game_source,changed,game_definitions)):
                    with self.assertRaisesRegex(ValueError,'header/compiler input identity'):
                        fresh_reviewed_game_references(module,image,ROOT/'toolchains/watcom-10.0-ga',Path(stage))
        observed,_=caller_row_references(module,game_caller,image,game_report,game_definitions)
        for name in ['_syncval','_sbar','_rtsplaying','_received_quote','_received_quote_time']:
            self.assertIn(name,observed)
        self.assertNotIn('_dmval',observed)
        damaged=copy.deepcopy(game_caller)
        damaged.local_externals.add(damaged.externals.index('_received_quote')+1)
        filtered,_=caller_row_references(module,damaged,image,game_report,game_definitions)
        self.assertNotIn('_received_quote',filtered)
        self.assertIn('getpackets_',game_caller.externals)
        self.assertTrue(any(row['symbol']!='getpackets_' and 'getpackets_' in row['bindings']
                            for row in game_report['functions']))
        collision=copy.deepcopy(module);collision.publics['getpackets_']=(5,0)
        filtered,_=caller_row_references(collision,game_caller,image,game_report,game_definitions)
        self.assertNotIn('getpackets_',filtered)
        changed=dict(game_definitions);start,size=changed['getpackets_'];changed['getpackets_']=(start+16,size)
        with self.assertRaisesRegex(ValueError,'interval geometry'):
            caller_row_references(module,game_caller,image,game_report,changed)
        damaged=copy.deepcopy(game_caller);start=damaged.publics['getpackets_'][1]
        damaged.segments[0].data[start+game_definitions['getpackets_'][1]-1]^=1
        with self.assertRaises(ValueError):
            caller_row_references(module,damaged,image,game_report,game_definitions)
        changed=copy.deepcopy(game_report)
        row=next(row for row in changed['functions'] if row['symbol']=='getpackets_')
        row['bindings']['_received_quote_time']=[3,581298]
        with self.assertRaises(ValueError):
            caller_row_references(module,game_caller,image,changed,game_definitions)
        changed=dict(report['observed_external_bindings']);changed['_weapon_tiles']=(3,31118)
        with self.assertRaises(BindingError):check_initialized_storage(module,image,changed)
        damaged=copy.deepcopy(module);damaged.segments[proof['source_segments'][0]-1].size-=1
        with self.assertRaises(ValueError):check_initialized_storage(damaged,image,report['observed_external_bindings'])
