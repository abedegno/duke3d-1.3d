"""Complete native ACTORS C/ASM producer and source-boundary regressions."""
import copy
from dataclasses import replace
import json
import os
from pathlib import Path
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
NASM=Path(os.environ.get('DUKE13D_NASM',ROOT/'toolchains/support/nasm-2.16.03/nasm'))

@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file() and
                     NASM.is_file(),'private target, GA compiler and NASM2.16.03 required')
class ActorsCompositeTests(unittest.TestCase):
    def test_native_producer_checks_complete_source_objects_and_corruption(self):
        self.assertTrue((ROOT/'src/game/moveeffectors.asm').is_file(),
                        'production symbolic effector missing')
        from tools.probe_actors_composite import probe,verify_native,Module,LEImage
        with tempfile.TemporaryDirectory() as directory:
            build=Path(directory)/'fresh'
            report=probe(ROOT/'toolchains/watcom-10.0-ga',build,NASM)
            modules={name:Module.parse((build/(name+'.obj')).read_bytes())
                     for name in ('actors_c','actors_asm')}
        proof=report['verification']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],
                          proof['verified_fixups']),(61741,6,2812))
        self.assertTrue(proof['complete_emitted_union_verified'])
        self.assertTrue(proof['unique_public_definitions'])
        self.assertEqual(len(report['functions']),37)
        self.assertEqual((report['prior36_bytes'],report['prior36_fixups']),(42864,1889))
        self.assertEqual(report['functions'][-1]['comparison']['verified_fixups'],923)
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertIn('assembly stand-in',report['humanization_backlog'])
        spec=json.loads((ROOT/'modules/actors.json').read_text())
        # CODE PUBDEFs include the private leading data record, separately
        # from the37function entries claimed by interval coverage.
        self.assertEqual(spec['code_publics'],sum(m.segments[s-1].class_name.upper()=='CODE'
                        for m in modules.values() for s,_ in m.publics.values()))
        self.assertEqual(spec['function_publics'],37)
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        anchors=report['external_bindings']
        # Every produced region has a real-byte control, including C tail,
        # ASM-owned preceding alignment, function entry/body/tail and string.
        for producer,segment,offset in [('actors_c',1,0),('actors_c',1,42883),
                ('actors_c',5,0),('actors_asm',1,0),('actors_asm',1,12),
                ('actors_asm',1,9300),('actors_asm',1,18789),('actors_asm',2,65)]:
            damaged=copy.deepcopy(modules);damaged[producer].segments[segment-1].data[offset]^=1
            with self.subTest(producer=producer,segment=segment,offset=offset),self.assertRaises(ValueError):
                verify_native(damaged,image,spec,anchors)
        damaged=copy.deepcopy(modules)
        damaged['actors_asm'].publics['moveexplosions_']=(1,0)
        with self.assertRaises(ValueError):verify_native(damaged,image,spec,anchors)
        damaged=copy.deepcopy(modules);damaged['actors_asm'].segments[0].size-=1
        damaged['actors_asm'].segments[0].data.pop()
        with self.assertRaises(ValueError):verify_native(damaged,image,spec,anchors)
        wrong=copy.deepcopy(spec);wrong['anchor_evidence']=[]
        with self.assertRaises(ValueError):verify_native(modules,image,wrong,anchors)
        wrong=copy.deepcopy(spec);wrong['producers']['actors_asm']['placements']['1']=[1,127048]
        with self.assertRaises(ValueError):verify_native(modules,image,wrong,anchors)
        wrong=dict(anchors);wrong['ms_']=[1,90564]
        with self.assertRaises(ValueError):verify_native(modules,image,spec,wrong)
        damaged=copy.deepcopy(modules);m=damaged['actors_asm']
        index=next(i for i,f in enumerate(m.fixups) if f.target_method==2 and m.externals[f.target-1]=='ssp_')
        m.fixups[index]=replace(m.fixups[index],displacement=m.fixups[index].displacement+1)
        with self.assertRaises(ValueError):verify_native(damaged,image,spec,anchors)
        damaged=copy.deepcopy(modules);m=damaged['actors_asm']
        m.fixups[index]=replace(m.fixups[index],frame_method=0,frame=1)
        with self.assertRaises(ValueError):verify_native(damaged,image,spec,anchors)

    def test_default_C_selector_and_changed_source_call_contract_reject(self):
        self.assertTrue((ROOT/'tools/probe_actors_composite.py').is_file(),
                        'production composite producer missing')
        from tools.probe_actors_composite import compile_source,prepare_headers,OPTIONS,Module,verify_native,LEImage
        from tools.probe_actors import probe as partial_probe
        # Default-off must preserve the existing pure-C partial path and its
        # full negative effector gate; this invokes the real source compiler.
        with tempfile.TemporaryDirectory() as directory:
            base=Path(directory);report=partial_probe(ROOT/'toolchains/watcom-10.0-ga',base/'default')
            self.assertEqual((len(report['functions']),report['matched_function_bytes'],
                              report['matched_function_fixups']),(36,42864,1889))
            self.assertEqual(report['source_code_bytes'],61666)
            self.assertFalse(report['full_module_gate']['verified'])
            # Wrong live function prototype changes an actual native call
            # contract without changing the composite proof's expectations.
            headers=base/'include'
            prepare_headers([ROOT/'reference/duke3d-reconstructions',ROOT/'reference/duke3d-reconstructions/MACT'],
                            [ROOT/'src/include',ROOT/'src/game/include',ROOT/'src/engine/include'],headers)
            path=headers/'funct.h';text=path.read_text()
            # The period source uses an implicit int distance return. A live
            # short-return declaration changes emitted sign extension/tests.
            path.write_text(text+'\nextern short FindDistance2D(long,long);\n')
            obj=base/'wrong.obj';compile_source(ROOT/'toolchains/watcom-10.0-ga',ROOT/'src/game/actors.c',obj,OPTIONS,60,include_dirs=[headers])
            spec=json.loads((ROOT/'modules/actors.json').read_text())
            good=json.loads((ROOT/'evidence/actors-module.json').read_text())
            from tools.probe_actors_composite import assemble
            asm=base/'asm.obj';assemble(NASM,ROOT/'src/game/moveeffectors.asm',asm)
            modules={'actors_c':Module.parse(obj.read_bytes()),'actors_asm':Module.parse(asm.read_bytes())}
            image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
            with self.assertRaises(ValueError):verify_native(modules,image,spec,good['external_bindings'])

    def test_descriptor_changed_during_tool_validation_is_rejected(self):
        # Parse-before-tool-validation must not report a later descriptor hash
        # as though that later file were the configuration actually consumed.
        import shutil
        from unittest.mock import patch
        import tools.probe_actors_composite as producer
        with tempfile.TemporaryDirectory() as directory:
            fixture=Path(directory)/'root';fixture.mkdir()
            for name in ['src','reference','evidence']:
                (fixture/name).symlink_to(ROOT/name,target_is_directory=True)
            (fixture/'modules').mkdir()
            descriptor=fixture/'modules/actors.json'
            shutil.copyfile(ROOT/'modules/actors.json',descriptor)
            original=producer.checked_nasm
            def changed(nasm):
                result=original(nasm)
                descriptor.write_bytes(descriptor.read_bytes()+b'\n')
                return result
            with patch.object(producer,'ROOT',fixture),patch.object(producer,'checked_nasm',side_effect=changed):
                with self.assertRaisesRegex(ValueError,'descriptor.*changed|input.*changed'):
                    producer.probe(ROOT/'toolchains/watcom-10.0-ga',Path(directory)/'build',NASM)

class ActorsAssemblerIdentityTests(unittest.TestCase):
    def test_custom_version_and_default_host_binary_identity_are_enforced(self):
        from unittest.mock import patch
        import tools.probe_actors_composite as producer
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);binary=root/'toolchains/support/nasm-2.16.03/nasm'
            binary.parent.mkdir(parents=True)
            binary.write_text('#!/bin/sh\necho "NASM version 2.16.02"\n');binary.chmod(0o755)
            with self.assertRaisesRegex(ValueError,'2.16.03'):
                producer.checked_nasm(binary)
            binary.write_text('#!/bin/sh\necho "NASM version 2.16.03"\n')
            with patch.object(producer,'ROOT',root):
                with self.assertRaisesRegex(ValueError,'binary identity mismatch'):
                    producer.checked_nasm()

    @unittest.skipUnless(NASM.is_file(),'NASM2.16.03 required')
    def test_changed_assembly_input_is_rejected_before_emission(self):
        from unittest.mock import patch
        import tools.probe_actors_composite as producer
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)/'root';(root/'src/game').mkdir(parents=True)
            for name in ['modules','reference','evidence']:
                (root/name).symlink_to(ROOT/name,target_is_directory=True)
            (root/'src/include').symlink_to(ROOT/'src/include',target_is_directory=True)
            (root/'src/engine').symlink_to(ROOT/'src/engine',target_is_directory=True)
            (root/'src/game/include').symlink_to(ROOT/'src/game/include',target_is_directory=True)
            (root/'src/game/actors.c').symlink_to(ROOT/'src/game/actors.c')
            (root/'src/game/moveeffectors.asm').write_text(
                (ROOT/'src/game/moveeffectors.asm').read_text()+'\n; changed source input\n')
            build=Path(directory)/'build'
            with patch.object(producer,'ROOT',root):
                with self.assertRaisesRegex(ValueError,'source/provenance identity mismatch'):
                    producer.probe(ROOT/'toolchains/watcom-10.0-ga',build,NASM)
            self.assertFalse(build.exists())

    def test_instruction_data_payload_is_rejected_before_assembler_execution(self):
        from tools.probe_actors_composite import assemble
        with tempfile.TemporaryDirectory() as directory:
            source=Path(directory)/'payload.asm';output=Path(directory)/'payload.obj'
            source.write_text('bits 32\nsegment _TEXT public use32 class=CODE\ndb 0x90\n')
            with self.assertRaisesRegex(ValueError,'instruction payload'):
                assemble(Path('/assembler-must-not-run'),source,output)
            self.assertFalse(output.exists())
