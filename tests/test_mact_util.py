"""Whole native MACT utilities: source, storage, scope and semantics."""
import importlib.util
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]

class MactUtilContractTests(unittest.TestCase):
    def test_complete_source_producer_exists(self):
        self.assertIsNotNone(importlib.util.find_spec('tools.probe_mact_util'),
                             'whole source-built MACT utility producer is absent')

import copy
from dataclasses import replace
import importlib
import json
import shutil
import subprocess
import tempfile

class NativeMactUtilTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.probe=importlib.import_module('tools.probe_mact_util')
        cls.temp=tempfile.TemporaryDirectory(prefix='mact-util-test-')
        cls.build=Path(cls.temp.name);cls.home=ROOT/'toolchains/watcom-10.0-ga'
        cls.report=cls.probe.probe(cls.home,cls.build/'positive')
        cls.module=cls.probe.Module.parse((cls.build/'positive/mact_util.obj').read_bytes())
        cls.image=cls.probe.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())

    @classmethod
    def tearDownClass(cls):cls.temp.cleanup()

    def test_whole_native_source_storage_scope_and_independent_anchors(self):
        proof=self.report['verification']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),(1107,28,61))
        self.assertEqual([(s['target_object'],s['target_offset'],s['compared_bytes']) for s in proof['segments']],[(1,555328,961),(3,23016,138),(3,68264,8),(3,1863808,28)])
        self.assertEqual(set(proof['local_symbols']),{'_ShutDown','_Base','_Comp','_Width','_Switch','newsift_down_'})
        self.assertEqual(len(self.module.publics),20)
        self.assertFalse(self.report['full_executable_rebuilt'])
        self.assertFalse(self.report['original_member_used_by_producer'])
        self.assertEqual(set(self.report['independent_anchor_verifications']),{'strtok','cmain386','nmsize','vprintf','nrealloc'})

    def test_prefix_every_public_tail_and_all_message_residue_bytes_reject(self):
        code=self.module.segments[0]
        offsets=sorted(v for s,v in self.module.publics.values() if s==1)
        positions=set(range(4))|{v-1 for v in offsets[1:]}|{code.size-1}
        for seg,positions in [(0,positions),(1,{0,4,24,60,96,137,2,3,23,57,58,59,94,95}),(3,range(8)),(4,range(28))]:
            for position in positions:
                damaged=copy.deepcopy(self.module);damaged.segments[seg].data[position]^=1
                with self.subTest(segment=seg,offset=position),self.assertRaises(ValueError):
                    self.probe.check_module(damaged,self.image)

    def test_scope_geometry_relocation_alignment_and_backing_controls(self):
        for name in self.module.publics:
            damaged=copy.deepcopy(self.module);del damaged.publics[name]
            with self.subTest(missing_public=name),self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)
        for name in self.module.local_publics:
            damaged=copy.deepcopy(self.module);damaged.local_publics.remove(name)
            with self.subTest(exported_private=name),self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)
        for f in range(len(self.module.fixups)):
            damaged=copy.deepcopy(self.module);damaged.fixups[f]=replace(damaged.fixups[f],displacement=1)
            with self.subTest(fixup=f),self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)
        damaged=copy.deepcopy(self.module);damaged.local_externals.clear()
        with self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)
        damaged=copy.deepcopy(self.module);damaged.segments[-1].size-=4
        with self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)
        for seg in (1,2,4,5):
            placements={int(k):tuple(v) for k,v in self.probe.load_spec()['placements'].items()}
            o,p=placements[seg];placements[seg]=(o,p+1)
            with self.subTest(misplaced_segment=seg),self.assertRaises(ValueError):self.probe.check_module(self.module,self.image,placements=placements)
        placements={int(k):tuple(v) for k,v in self.probe.load_spec()['placements'].items()}
        placements[5]=(3,71840)
        with self.assertRaises(ValueError):self.probe.check_module(self.module,self.image,placements=placements)
        for name,value in [('strtok_',589393),('vprintf_',591234),('realloc_',591260)]:
            with self.subTest(wrong_call=name),self.assertRaises(ValueError):
                self.probe.check_module(self.module,self.image,known={name:(1,value)})

    def test_real_native_behavior_storage_and_message_mutants_reject(self):
        text=(ROOT/'src/mact/util_lib.c').read_text()
        mutants=[('guard','if (inerror) return;','if (!inerror) return;'),
            ('argument','stricmp(check,p)','strcmp(check,p)'),
            ('delimiters','char delimiters[]="\\\\-/"','char delimiters[]="\\\\-?"'),
            ('numeric','str++;','str+=2;'),
            ('heap','n=nel*Width;','n=nel+Width;'),
            ('sift','c=L+L;','c=L+1;'),
            ('memory','p=malloc(size);','p=calloc(1,size);'),
            ('realloc','*ptr=realloc(*ptr,size);','*ptr=realloc(*ptr,size+1);'),
            ('storage','static int inerror = 0;','static int inerror = 1;'),
            ('scope','static void (*ShutDown)','void (*ShutDown)'),
            ('string','SafeMalloc failure for %lu bytes','SafeMalloc failure for %ld bytes'),
            ('residue','"\\n\\0\\0"','"\\n\\0X"')]
        for index,(name,a,b) in enumerate(mutants):
            self.assertIn(a,text,name);source=self.build/f'mutant{index}.c';source.write_text(text.replace(a,b,1))
            obj=source.with_suffix('.obj');self.probe.compile_source(self.home,source,obj,self.probe.OPTIONS)
            with self.subTest(mutant=name),self.assertRaises(ValueError):self.probe.check_module(self.probe.Module.parse(obj.read_bytes()),self.image)

    def test_standalone_fresh_checkout_uses_no_sdk_or_ignored_source(self):
        stage=self.build/'standalone';stage.mkdir()
        for folder in ('tools','profiles'):
            shutil.copytree(ROOT/folder,stage/folder,ignore=shutil.ignore_patterns('__pycache__'))
        paths=['src/mact/util_lib.c','modules/mact_util.json','evidence/mact-util-source-reference.json','evidence/mact-util-crt-anchors.json','evidence/engine-function-matches.json','evidence/mmulti-module.json','evidence/gamedef-module.json']
        for name in paths:
            dest=stage/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/name,dest)
        (stage/'reference').mkdir();(stage/'reference/DUKE3D.EXE').symlink_to(ROOT/'reference/DUKE3D.EXE')
        (stage/'toolchains').symlink_to(ROOT/'toolchains')
        subprocess.run(['python3',str(stage/'tools/probe_mact_util.py'),'--build',str(stage/'fresh'),'--report',str(stage/'report.json')],cwd=stage,check=True,capture_output=True)
        report=json.loads((stage/'report.json').read_text())
        self.assertTrue(report['verification']['verified']);self.assertEqual(report['source_sha256'],self.report['source_sha256'])
        self.assertFalse((stage/'reference/duke3d-reconstructions').exists())
        self.assertFalse((stage/'evidence/watcom-runtime-components.json').exists())

    def test_recovered_c_numeric_token_heap_memory_and_shutdown_behavior(self):
        # Host bridge supplies only platform CRT spelling and the old implicit
        # prototype; the recovered implementation itself is included unchanged.
        stage=self.build/'host';stage.mkdir()
        (stage/'malloc.h').write_text('#include <stdlib.h>\n#include <malloc/malloc.h>\n#define _msize malloc_size\n')
        source=stage/'behavior.c'
        source.write_text('''#include <assert.h>
#include <strings.h>
#define stricmp strcasecmp
static int newsift_down(int,int);
int _argc;
char **_argv;
#include "'''+str(ROOT/'src/mact/util_lib.c')+'''"
static int compare(void *a,void *b) { return *(int*)a-*(int*)b; }
static void swap(void *a,void *b) { int t=*(int*)a;*(int*)a=*(int*)b;*(int*)b=t; }
static void shutdown_callback(void) { Error("nested");printf("shutdown:"); }
int main(int argc,char **argv) {
    int a[]={3,-1,3,0,5,2};
    char *args[]={"utility","plain","--Alpha","/Beta","\\\\gamma"};
    char **saved=args;
    char *memory;
    int n;
    if(argc>1) {
        RegisterShutdownFunction(shutdown_callback);
        if(!strcmp(argv[1],"fatal")) Error("fatal %d",7);
        if(!strcmp(argv[1],"free")) SafeFree(0);
        if(!strcmp(argv[1],"malloc")) SafeMalloc((unsigned long)-1);
        if(!strcmp(argv[1],"realloc")) { memory=SafeMalloc(2);SafeRealloc((void**)&memory,-1); }
        return 99;
    }
    _argc=5;_argv=args;
    assert(CheckParm("alpha")==2 && CheckParm("BETA")==3 && CheckParm("gamma")==4);
    assert(CheckParm("plain")==1 && CheckParm("missing")==0 && args==saved);
    assert(!strcmp(args[2],"--Alpha"));
    assert(ParseHex("0aF")==175 && ParseHex("")==0);
    assert(ParseNum("$ff")==255 && ParseNum("0x10")==16 && ParseNum("-17")==-17);
    assert(MotoShort(0x1234)==0x3412 && IntelShort(-2)==-2);
    assert(MotoLong(0x12345678)==0x78563412 && IntelLong(-123)==-123);
    HeapSort((char*)a,6,sizeof(int),compare,swap);
    for(n=1;n<6;n++) assert(a[n-1]<=a[n]);
    HeapSort((char*)a,0,sizeof(int),compare,swap);
    HeapSort((char*)a,1,sizeof(int),compare,swap);
    memory=SafeMalloc(16);assert(SafeMallocSize(memory)>=16);memory[0]='Q';
    SafeRealloc((void**)&memory,64);assert(memory && memory[0]=='Q');SafeFree(memory);
    return 0;
}
''')
        binary=stage/'behavior'
        subprocess.run(['cc','-std=gnu89','-Wno-deprecated-non-prototype','-I',str(stage),str(source),'-o',str(binary)],check=True,capture_output=True)
        subprocess.run([str(binary)],check=True,capture_output=True)
        for mode,message in [('fatal','fatal 7'),('free','SafeFree : Tried to free a freed pointer'),('malloc','SafeMalloc failure'),('realloc','SafeRealloc failure')]:
            result=subprocess.run([str(binary),mode],capture_output=True,text=True)
            self.assertEqual(result.returncode,1,(mode,result.stderr))
            self.assertEqual(result.stdout.count('shutdown:'),1)
            self.assertIn(message,result.stdout)
            self.assertNotIn('nested',result.stdout)
