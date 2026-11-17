"""Native PUBLIC combination alignment, trust boundary and unchanged defaults."""
from copy import copy, deepcopy
from dataclasses import replace
from pathlib import Path
import sys
import unittest
from unittest.mock import patch
import os
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from le import LEImage
from tools.verify_module import verify_module, ModuleError
from tests.logical_origin_fixture import build_fixture, issue_fixture_context


class StandaloneDefaultOriginTests(unittest.TestCase):
    def test_default_stage_has_no_optional_origin_dependency(self):
        from tests.test_verify_module import ModuleProofTests
        _,image,_=ModuleProofTests().fixture()
        with tempfile.TemporaryDirectory(prefix='default-origin-stage-',dir=ROOT/'build') as temporary:
            stage=Path(temporary)
            files=['tools/verify_module.py','tools/match_function.py',
                   'profiles/watcom/tools/omf32.py','profiles/watcom/tools/le.py']
            for name in files:
                destination=stage/name;destination.parent.mkdir(parents=True,exist_ok=True)
                shutil.copyfile(ROOT/name,destination)
            (stage/'IMAGE.LE').write_bytes(image.data)
            (stage/'check.py').write_text('''from pathlib import Path
import sys
sys.path.insert(0,str(Path.cwd()/'profiles/watcom/tools'))
from omf32 import Module,Segment
from le import LEImage
from tools.verify_module import verify_module
image=LEImage.parse(Path('IMAGE.LE').read_bytes())
module=Module(name='own',segments=[Segment('_DATA','DATA',4,0xa9,bytearray(b'ABCD'))])
baseline=verify_module(module,image,{1:(1,8)},{})
assert baseline['initialized_bytes']==4
assert 'logical_segment_origins' not in baseline
for contexts in (None,(),[]):
 assert verify_module(module,image,{1:(1,8)},{},logical_origins=contexts)==baseline
assert 'tools.logical_segment_origins' not in sys.modules
''')
            self.assertFalse((stage/'tools/logical_segment_origins.py').exists())
            result=subprocess.run([sys.executable,str(stage/'check.py')],cwd=stage,
                                  env={**os.environ,'PYTHONPATH':''},capture_output=True,text=True)
            self.assertEqual(result.returncode,0,result.stdout+result.stderr)


class NativeLogicalOriginTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rows = build_fixture(ROOT)

    def inputs(self, case='A'):
        row = self.rows[case]
        module = Module.parse((row['directory']/'SECOND.OBJ').read_bytes())
        image = LEImage.parse((row['directory']/'OUT.EXE').read_bytes())
        number = next(n for n,s in enumerate(module.segments,1) if s.size)
        return module, image, {number:row['marker']}, number

    def test_four_actual_executions_and_unchanged_default_alignment(self):
        for case,row in self.rows.items():
            module,image,places,number = self.inputs(case)
            self.assertEqual(module._segment(number).attributes, 0x69)
            self.assertEqual(row['actual'][3], 0 if case=='D' else 4)
            if case=='D':
                before = verify_module(module,image,places,{})
                self.assertEqual(before, verify_module(module,image,places,{},logical_origins=()))
                self.assertNotIn('logical_segment_origins',before)
            else:
                with self.assertRaisesRegex(ModuleError,'alignment'):
                    verify_module(module,image,places,{})

    def test_native_witness_context_proves_all_cases_and_is_reusable(self):
        for case,row in self.rows.items():
            module,image,places,number = self.inputs(case)
            context = issue_fixture_context(row)
            for _ in range(2):
                proof = verify_module(module,image,places,{},logical_origins=(context,))
                self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']), (1,0))
                self.assertEqual(proof['logical_segment_origins'][0]['origin'],list(row['leader']))
                self.assertFalse(proof['full_executable_rebuilt'])

    def test_native_same_phase_wrong_origin_is_not_evidence(self):
        for origin in [(2,0),(2,5),(2,20),(1,4),(2,-12),(2,True)]:
            with self.subTest(origin=origin), self.assertRaises(ValueError):
                issue_fixture_context(self.rows['A'],claimed_origin=origin)

    def test_context_cannot_be_constructed_copied_or_deserialized(self):
        from tools.logical_segment_origins import LogicalSegmentOrigin
        module,image,places,_ = self.inputs()
        context = issue_fixture_context(self.rows['A'])
        with self.assertRaises(TypeError):LogicalSegmentOrigin()
        for operation in (copy,deepcopy,replace):
            with self.subTest(operation=operation), self.assertRaises(TypeError):operation(context)
        forged = object.__new__(LogicalSegmentOrigin)
        for candidate in (forged, {}, {'origin':[2,4]}, 'validated', 4):
            with self.subTest(candidate=type(candidate)), self.assertRaises(ModuleError):
                verify_module(module,image,places,{},logical_origins=(candidate,))
        with self.assertRaises((AttributeError,TypeError)):
            context.origin=(2,20)

    def test_target_mutation_and_duplicate_or_extraneous_contexts_reject(self):
        module,image,places,_ = self.inputs()
        context = issue_fixture_context(self.rows['A'])
        changed = bytearray(image.data);changed[-1]^=1
        with self.assertRaisesRegex(ModuleError,'target'):
            verify_module(module,LEImage.parse(bytes(changed)),places,{},logical_origins=(context,))
        for contexts in ((context,context), (issue_fixture_context(self.rows['D']),), {'x':context}):
            with self.subTest(contexts=type(contexts)), self.assertRaises(ModuleError):
                verify_module(module,image,places,{},logical_origins=contexts)
        for contexts in (False,0,{},'',set()):
            with self.subTest(malformed_falsy=type(contexts)), self.assertRaises(ModuleError):
                verify_module(module,image,places,{},logical_origins=contexts)

    def test_exact_identity_and_measured_subset_only(self):
        module,image,places,number = self.inputs()
        context = issue_fixture_context(self.rows['A'])
        mutations = [('name','_data'),('class_name','data'),('class_name','BSS'),
                     ('attributes',0x68),('attributes',0x61),('attributes',0x71),('attributes',0x7d)]
        for field,value in mutations:
            changed = deepcopy(module);setattr(changed._segment(number),field,value)
            with self.subTest(field=field,value=value), self.assertRaises(ModuleError):
                verify_module(changed,image,places,{},logical_origins=(context,))
        for groups in ([], [('dgroup',(number,))], [('DGROUP',())],
                       [('DGROUP',(number,)),('OTHER',(number,))], [('DGROUP',(number,number))]):
            changed=deepcopy(module);changed.groups=groups
            with self.subTest(groups=groups), self.assertRaises(ModuleError):
                verify_module(changed,image,places,{},logical_origins=(context,))
        changed=deepcopy(module);changed.format='easy-omf386'
        with self.assertRaises(ModuleError):verify_module(changed,image,places,{},logical_origins=(context,))

    def test_context_does_not_hide_bytes_public_conflicts_or_bad_placement(self):
        module,image,places,number = self.inputs()
        context = issue_fixture_context(self.rows['A'])
        changed=deepcopy(module);changed._segment(number).data[0]=20
        with self.assertRaisesRegex(ModuleError,'differing bytes'):
            verify_module(changed,image,places,{},logical_origins=(context,))
        with self.assertRaisesRegex(ModuleError,'conflicting binding'):
            verify_module(module,image,places,{'_aligned_marker':(2,21)},logical_origins=(context,))
        for position in [(1,20),(2,0),(2,True),(True,20),(2,21),(2,-12),(2,2**32)]:
            with self.subTest(position=position), self.assertRaises(ModuleError):
                verify_module(module,image,{number:position},{},logical_origins=(context,))
        for key in (True,1.0,str(number)):
            with self.subTest(key=key), self.assertRaises(ModuleError):
                verify_module(module,image,{key:places[number]},{},logical_origins=(context,))

    def test_fresh_native_byte_mutation_is_still_rejected(self):
        from runner import assemble_source
        from tests.logical_origin_fixture import SECOND
        import tempfile
        work=Path(tempfile.mkdtemp(prefix='logical-byte-negative-',dir=ROOT/'build'))
        (work/'SECOND.ASM').write_text(SECOND.replace('db 19','db 20'))
        assemble_source(ROOT/'toolchains/tasm-3.1',work/'SECOND.ASM',work/'SECOND.OBJ',
                        ['/q','/t','/ml','/j.386p'],producer='tasm')
        module,image,places,number=self.inputs('D')
        changed=Module.parse((work/'SECOND.OBJ').read_bytes())
        self.assertEqual((changed._segment(number).size,changed._segment(number).attributes),(1,0x69))
        with self.assertRaisesRegex(ModuleError,'differing bytes'):
            verify_module(changed,image,places,{},
                          logical_origins=(issue_fixture_context(self.rows['D']),))

    def test_dword_contribution_and_group_frame_remain_separate(self):
        row=self.rows['A'];context=issue_fixture_context(row)
        module=Module.parse((row['directory']/'FIRST.OBJ').read_bytes())
        image=LEImage.parse((row['directory']/'OUT.EXE').read_bytes())
        number=next(n for n,s in enumerate(module.segments,1) if s.size)
        proof=verify_module(module,image,{number:row['prefix']},{},
                            group_frames={1:(2,0)},logical_origins=(context,))
        self.assertEqual(proof['initialized_bytes'],8)
        self.assertEqual(proof['group_frames'],{1:(2,0)})
        self.assertEqual(proof['logical_segment_origins'][0]['origin'],[2,4])

    def test_unmatched_segments_keep_absolute_alignment(self):
        from omf32 import Segment
        module,image,places,number=self.inputs()
        module.segments.append(Segment('_TEXT','CODE',1,0x69,bytearray([0])))
        places[len(module.segments)]=(1,1)
        with self.assertRaisesRegex(ModuleError,'alignment'):
            verify_module(module,image,places,{},logical_origins=(issue_fixture_context(self.rows['A']),))

    def test_ambiguous_nonempty_segments_reject(self):
        module,image,places,number=self.inputs()
        context=issue_fixture_context(self.rows['A'])
        module.segments.append(deepcopy(module._segment(number)))
        module.groups=[('DGROUP',(number,len(module.segments)))]
        places[len(module.segments)]=(2,36)
        with self.assertRaisesRegex(ModuleError,'ambiguous'):
            verify_module(module,image,places,{},logical_origins=(context,))

    def test_changed_native_receipt_rejects_before_issuance(self):
        row = self.rows['A'];path=row['directory']/'OUT.MAP';old=path.read_bytes()
        try:
            path.write_bytes(old+b'\nchanged\n')
            with self.assertRaisesRegex(ValueError,'evidence'):issue_fixture_context(row)
        finally:path.write_bytes(old)


class TargetLogicalOriginTests(unittest.TestCase):
    def test_closed_factory_replays_native_witness_and_retains_receipts(self):
        from tools.prove_logical_data_origin import replay_target_data_origin
        contexts = []
        for _ in range(2):
            contexts.append(replay_target_data_origin(
                home=ROOT/'toolchains/watcom-10.0-ga', build=ROOT/'build/task179-origins'))
        from tools.logical_segment_origins import _ISSUED
        self.assertEqual(_ISSUED[contexts[0]], _ISSUED[contexts[1]])
        self.assertEqual((_ISSUED[contexts[0]].object_number,_ISSUED[contexts[0]].origin),(3,29560))
        # Consumption has no disk freshness claim. Source freshness belongs to
        # the next factory replay, while the target is checked here in memory.
        from omf32 import Segment
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        module=Module(name='diagnostic', segments=[Segment('_DATA','DATA',1,0x69,
            bytearray(image.data[image.file_offset(3,29560):image.file_offset(3,29560)+1]))],
            groups=[('DGROUP',(1,))])
        with patch.object(Path,'open',side_effect=AssertionError('consumer filesystem I/O')):
            proof=verify_module(module,image,{1:(3,29560)},{},logical_origins=(contexts[0],))
        self.assertEqual(proof['initialized_bytes'],1)
        self.assertIn('Candidate',proof['logical_segment_origins'][0]['scope'])

    def test_changed_source_and_header_reject_before_replay(self):
        from tools.prove_logical_data_origin import replay_target_data_origin
        # Mutate only worktree-owned source/header, never the shared target or
        # toolchain. Other content pins are checked through the validator below.
        for relative in ('src/game/game.c','src/include/compat.h'):
            path=ROOT/relative
            if not path.exists():
                path=next((ROOT/'src/include').glob('*.h'))
            original=path.read_bytes()
            try:
                path.write_bytes(original+b'\n/* freshness control */\n')
                with self.assertRaisesRegex(ValueError,'identity'):
                    replay_target_data_origin(home=ROOT/'toolchains/watcom-10.0-ga',
                                              build=ROOT/'build/task179-origins')
            finally:path.write_bytes(original)
        with self.assertRaises(TypeError):
            replay_target_data_origin(origin=(3,29576))

    def test_target_manifest_compiler_and_helper_content_identities_are_closed(self):
        from tools.prove_logical_data_origin import _validate_inputs
        original=Path.read_bytes
        paths=['reference/DUKE3D.EXE','tools/logical_data_origin_inputs.json',
               'dukenukem3d/source/MAKEFILE.LNK','tools/probe_game.py',
               'evidence/gamedef-module.json','toolchains/watcom-10.0-ga/BINB/wcc386.exe']
        for relative in paths:
            selected=ROOT/relative
            def altered(path):
                data=original(path)
                return data+b'changed' if path==selected else data
            with self.subTest(relative=relative), patch.object(Path,'read_bytes',altered), \
                    self.assertRaisesRegex(ValueError,'identity'):
                _validate_inputs(ROOT/'toolchains/watcom-10.0-ga')

    def test_added_header_is_not_an_approved_input(self):
        from tools.prove_logical_data_origin import _validate_inputs
        path=ROOT/'src/include/task179_freshness.h'
        self.assertFalse(path.exists())
        try:
            path.write_text('/* own unexpected header */\n')
            with self.assertRaisesRegex(ValueError,'header-set identity'):
                _validate_inputs(ROOT/'toolchains/watcom-10.0-ga')
        finally:path.unlink()

    def test_source_change_during_native_replay_prevents_issuance(self):
        import tools.prove_logical_data_origin as producer
        source=ROOT/'src/game/game.c';original=source.read_bytes()
        compile_real=producer.compile_source
        def compile_then_change(*args,**kwargs):
            output=compile_real(*args,**kwargs)
            source.write_bytes(original+b'\n/* after compile freshness control */\n')
            return output
        try:
            with patch.object(producer,'compile_source',compile_then_change), \
                    self.assertRaisesRegex(ValueError,'identity'):
                producer.replay_target_data_origin(home=ROOT/'toolchains/watcom-10.0-ga',
                                                   build=ROOT/'build/task179-origins')
        finally:source.write_bytes(original)

    def test_changed_first_public_or_scope_rejects(self):
        from tools.prove_logical_data_origin import _validate_game_scope
        from omf32 import Segment
        module=Module(name='own',segments=[Segment('_DATA','DATA',864,0xa9,bytearray(864))],
            publics={'_cameradist':(1,0),'_TimerPtr':(1,496)}, groups=[('DGROUP',(1,))])
        _validate_game_scope(module)
        for name in ('_cameradist','_TimerPtr'):
            changed=deepcopy(module);changed.local_publics.add(name)
            with self.assertRaisesRegex(ValueError,'scope'):_validate_game_scope(changed)
        module.publics['_cameradist']=(1,4)
        with self.assertRaisesRegex(ValueError,'first'):_validate_game_scope(module)
