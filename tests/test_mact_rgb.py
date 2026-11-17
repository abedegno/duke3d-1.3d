"""Native RGB union, readable counterpart and corruption controls."""
import copy
from dataclasses import replace
import json
import os
from pathlib import Path
import subprocess
import shutil
from unittest.mock import patch
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1]

class RGBSourceTests(unittest.TestCase):
    def test_owned_source_and_no_payload(self):
        self.assertTrue((ROOT/'src/mact/rgb.c').is_file(), 'readable RGB source missing')
        from tools.probe_mact_rgb import validate_assembly
        asm=(ROOT/'src/mact/rgb_make_table.asm').read_text()
        validate_assembly(asm)
        for payload in ['db 144','incbin "target"','times 3 nop','org 10','%include "x"']:
            with self.subTest(payload=payload),self.assertRaises(ValueError):
                validate_assembly(asm+'\n'+payload)

    def test_assembler_version_and_default_identity_reject(self):
        from tools.probe_mact_rgb import checked_nasm
        import tools.probe_actors_composite as assembler
        with tempfile.TemporaryDirectory() as d:
            fake=Path(d)/'nasm';fake.write_text('#!/bin/sh\necho NASM version 2.16.04\n');fake.chmod(0o755)
            with self.assertRaisesRegex(ValueError,'NASM2.16.03'):checked_nasm(fake)
            default=Path(d)/'toolchains/support/nasm-2.16.03/nasm';default.parent.mkdir(parents=True)
            shutil.copy2(fake,default)
            with patch.object(assembler,'ROOT',Path(d)),self.assertRaisesRegex(ValueError,'binary identity'):
                checked_nasm()

@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                    (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(), 'private target/compiler required')
class RGBNativeTests(unittest.TestCase):
    def test_native_complete_union_and_negative_controls(self):
        from tools.probe_mact_rgb import probe,verify_native,Module,LEImage
        with tempfile.TemporaryDirectory() as d:
            build=Path(d)/'native';report=probe(ROOT/'toolchains/watcom-10.0-ga',build)
            modules={n:Module.parse((Path(report['actual_build_directory'])/(n+'.obj')).read_bytes()) for n in ('rgb_c','rgb_asm')}
        self.assertIn('objects_sha256',report)
        self.assertIn('sources_sha256',report)
        proof=report['verification']
        self.assertEqual([proof[k] for k in ('initialized_bytes','zero_fill_bytes','verified_fixups')],[795,265232,23])
        self.assertEqual(len(report['global_exports']),6)
        self.assertEqual(len(report['private_c_symbols']),6)
        self.assertEqual(report['codeScopepublics'],5)
        self.assertFalse(report['full_executable_rebuilt'])
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        spec=json.loads((ROOT/'modules/mact_rgb.json').read_text())
        for producer,segment,offset in [('rgb_c',1,0),('rgb_c',1,378),('rgb_c',1,419),('rgb_c',4,0),('rgb_c',4,51),('rgb_c',5,0),('rgb_c',5,265231),('rgb_asm',1,0),('rgb_asm',1,322)]:
            bad=copy.deepcopy(modules);bad[producer].segments[segment-1].data[offset]^=1
            with self.subTest(region=(producer,segment,offset)),self.assertRaises(ValueError):verify_native(bad,image,spec)
        for producer in modules:
            for field,value in [('width',2),('location',1),('relative',False),('frame_method',0),('displacement',1),('target',99)]:
                bad=copy.deepcopy(modules);m=bad[producer];i=next(i for i,f in enumerate(m.fixups) if f.relative)
                m.fixups[i]=replace(m.fixups[i],**{field:value})
                with self.subTest(producer=producer,field=field),self.assertRaises(ValueError):verify_native(bad,image,spec)
        for alteration in ('scope','local_external','groups','libraries','private_external','global','extent','extra_segment'):
            bad=copy.deepcopy(modules);m=bad['rgb_c']
            if alteration=='scope':m.local_publics.clear()
            elif alteration=='local_external':m.local_externals.clear()
            elif alteration=='groups':m.groups.clear()
            elif alteration=='libraries':m.default_libraries.append('unexpected')
            elif alteration=='private_external':bad['rgb_asm'].externals.append('_WeightRed')
            elif alteration=='global':m.publics['_extra']=(1,0)
            elif alteration=='extent':m.segments[0].size-=1;m.segments[0].data.pop()
            else:m.segments.append(copy.deepcopy(m.segments[0]))
            with self.subTest(alteration=alteration),self.assertRaises(ValueError):verify_native(bad,image,spec)
        for key in ('expected_ranges','producers'):
            bad=copy.deepcopy(spec);bad[key]={}
            with self.assertRaises(ValueError):verify_native(modules,image,bad)
        backed=copy.deepcopy(image);original=backed.file_offset
        backed.file_offset=lambda obj,off: 1 if obj==3 and off==1864256 else original(obj,off)
        with self.assertRaises(ValueError):verify_native(modules,backed,spec)

    def test_default_C_retains_full_negative_builder(self):
        from tools.probe_mact_rgb import compile_source,Module,OPTIONS,LEImage,compare_range,PLACEMENTS,SYMBOLS
        with tempfile.TemporaryDirectory() as d:
            obj=Path(d)/'default.obj';compile_source(ROOT/'toolchains/watcom-10.0-ga',ROOT/'src/mact/rgb.c',obj,OPTIONS[:-1],30)
            m=Module.parse(obj.read_bytes())
        self.assertEqual(m.segments[0].size,743)
        self.assertEqual(m.publics['RGB_MakeColorTable_'],(1,420))
        im=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        prefix=compare_range(m,1,0,im,1,564048,420,SYMBOLS,PLACEMENTS)
        self.assertTrue(prefix['match'])
        tail=compare_range(m,1,420,im,1,564468,323,SYMBOLS,PLACEMENTS)
        self.assertEqual(len(tail['differing_offsets']),19)
        with tempfile.TemporaryDirectory() as d:
            obj=Path(d)/'zero.obj'
            compile_source(ROOT/'toolchains/watcom-10.0-ga',ROOT/'src/mact/rgb.c',obj,OPTIONS[:-1]+['/dDUKE13D_RGB_TABLE_ASM=0'],30)
            self.assertEqual(Module.parse(obj.read_bytes()).segments[0].data,m.segments[0].data)

    def test_semantic_C_and_ASM_mutations_reject(self):
        from tools.probe_mact_rgb import probe,verify_native,compile_source,OPTIONS,Module,LEImage,checked_nasm
        with tempfile.TemporaryDirectory() as d:
            parent=Path(d);r=probe(ROOT/'toolchains/watcom-10.0-ga',parent/'native')
            actual=Path(r['actual_build_directory'])
            modules={n:Module.parse((actual/(n+'.obj')).read_bytes()) for n in ('rgb_c','rgb_asm')}
            spec=json.loads((ROOT/'modules/mact_rgb.json').read_text())
            image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
            source=(ROOT/'src/mact/rgb.c').read_text()
            for label,text,options in [('weight',source.replace('213*square','214*square'),OPTIONS),
                    ('table',source.replace('0,0,171','0,0,170',1),OPTIONS),
                    ('selector',source,OPTIONS[:-1]),
                    ('storage',source.replace('WeightBlue[256]','WeightBlue[257]'),OPTIONS)]:
                path=parent/(label+'.c');path.write_text(text);out=parent/(label+'.obj')
                compile_source(ROOT/'toolchains/watcom-10.0-ga',path,out,options,30)
                bad=dict(modules);bad['rgb_c']=Module.parse(out.read_bytes())
                with self.subTest(change=label),self.assertRaises(ValueError):verify_native(bad,image,spec)
            asm=parent/'semantic.asm';asm.write_text((ROOT/'src/mact/rgb_make_table.asm').read_text().replace('cmp esi, 64','cmp esi, 63',1))
            binary,_=checked_nasm();out=parent/'semantic.obj'
            subprocess.run([str(binary),'-f','obj','-o',str(out),str(asm)],check=True,capture_output=True)
            bad=dict(modules);bad['rgb_asm']=Module.parse(out.read_bytes())
            with self.assertRaises(ValueError):verify_native(bad,image,spec)

    def test_standalone_and_actual_source_tool_races(self):
        import tools.probe_mact_rgb as producer
        with tempfile.TemporaryDirectory() as d:
            isolated=Path(d)/'project';isolated.mkdir()
            for folder in ('src','tools','profiles','modules','evidence'):
                shutil.copytree(ROOT/folder,isolated/folder,ignore=shutil.ignore_patterns('__pycache__'))
            (isolated/'reference').mkdir();(isolated/'reference/DUKE3D.EXE').symlink_to(ROOT/'reference/DUKE3D.EXE')
            binary=Path(d)/'nasm';shutil.copy2(ROOT/'toolchains/support/nasm-2.16.03/nasm',binary)
            command=['python3',str(isolated/'tools/probe_mact_rgb.py'),'--home',str(ROOT/'toolchains/watcom-10.0-ga'),
                '--nasm',str(binary),'--build',str(Path(d)/'standalone'),'--report',str(Path(d)/'standalone.json')]
            subprocess.run(command,check=True,capture_output=True)
            report=json.loads((Path(d)/'standalone.json').read_text())
            self.assertTrue(report['verification']['verified'])
            self.assertFalse((isolated/'build').exists())
            # Exercise the actual before/after guard with safe private input
            # copies changed after a real successful compile. No project input
            # or original compiler is mutated by a negative control.
            compile_real=producer.compile_source
            for target in (isolated/'src/mact/rgb.c',binary):
                original=target.read_bytes()
                def race(*args,**kwargs):
                    result=compile_real(*args,**kwargs)
                    target.write_bytes(original+b'\n')
                    return result
                with patch.object(producer,'ROOT',isolated),patch.object(producer,'compile_source',race):
                    with self.subTest(race=target.name),self.assertRaisesRegex(ValueError,'changed during production'):
                        producer.probe(ROOT/'toolchains/watcom-10.0-ga',Path(d)/'races',binary)
                target.write_bytes(original)
            origin=isolated/'evidence/mact-rgb-source-reference.json'
            value=json.loads(origin.read_text());value['tracked_sources_sha256']['src/mact/rgb.c']='0'*64
            origin.write_text(json.dumps(value))
            with patch.object(producer,'ROOT',isolated),self.assertRaisesRegex(ValueError,'lineage'):
                producer.probe(ROOT/'toolchains/watcom-10.0-ga',Path(d)/'bad-lineage',binary)

class RGBHostTests(unittest.TestCase):
    def test_bounded_defined_domain_and_real_tables(self):
        self.assertTrue((ROOT/'src/mact/rgb.c').is_file(),'readable RGB source missing')
        with tempfile.TemporaryDirectory() as d:
            harness=Path(d)/'host.c'
            harness.write_text('#include <assert.h>\n#include "'+str(ROOT/'src/mact/rgb.c')+'"\n'
                'void VID_GetPalette(unsigned char *p) { int i; for(i=0;i<768;i++) p[i]=0; }\n'
                'int main(void) { unsigned char p[768]={0}; int i; RGB_MakeWeightTable();'
                'for(i=0;i<256;i++){assert(WeightRed[i]==213*i*i/1000);assert(WeightGreen[i]==715*i*i/1000);assert(WeightBlue[i]==72*i*i/1000);}'
                'assert(RGB_FindBestColor(0,0,0,p)==0); p[3]=10;p[4]=20;p[5]=30;'
                'assert(RGB_FindBestColor(10,20,30,p)==1);'
                'assert(RGB_GetBestColor(252,252,252)==0);'
                'for(i=0;i<16;i++)RGB_Lookup[egargb[i*3]>>2][egargb[i*3+1]>>2][egargb[i*3+2]>>2]=(unsigned char)i;'
                'RGB_FindEGAColors();for(i=0;i<16;i++)assert(RGB_EGATable[i]==i);'
                'RGB_MakeColorTable();for(i=0;i<262144;i++)assert(((unsigned char*)RGB_Lookup)[i]==0);'
                'for(i=0;i<16;i++)assert(RGB_EGATable[i]==0);return 0;}')
            out=Path(d)/'host';subprocess.run(['cc','-std=c99','-fsanitize=address,undefined',str(harness),'-o',str(out)],check=True,capture_output=True)
            subprocess.run([str(out)],check=True,capture_output=True)
