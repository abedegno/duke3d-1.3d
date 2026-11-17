"""Complete source-built MACT file library: native proof and actual behavior."""
import importlib.util
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]

class MactFileContractTests(unittest.TestCase):
    def test_complete_source_producer_exists(self):
        self.assertIsNotNone(importlib.util.find_spec('tools.probe_mact_file'),
                             'whole source-built MACT file producer is absent')

import copy
from dataclasses import replace
import importlib
import json
import shutil
import subprocess
import tempfile

class NativeMactFileTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.probe=importlib.import_module('tools.probe_mact_file')
        cls.temp=tempfile.TemporaryDirectory(prefix='mact-file-test-')
        cls.build=Path(cls.temp.name);cls.home=ROOT/'toolchains/watcom-10.0-ga'
        cls.report=cls.probe.probe(cls.home,cls.build/'positive')
        cls.module=cls.probe.Module.parse((cls.build/'positive/mact_file.obj').read_bytes())
        cls.image=cls.probe.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())

    @classmethod
    def tearDownClass(cls):cls.temp.cleanup()

    def test_whole_native_source_storage_scope_and_stock_witnesses(self):
        proof=self.report['verification']
        self.assertEqual((proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups']),(2217,0,70))
        self.assertEqual([(s['target_object'],s['target_offset'],s['compared_bytes']) for s in proof['segments']],[(1,569136,1731),(3,26220,406),(3,71104,80)])
        self.assertEqual(proof['local_symbols'],{'_FileNames':(3,71104)})
        self.assertEqual(len(self.module.publics),21)
        self.assertEqual(self.module.local_externals,{5})
        self.assertEqual(self.module.segments[3].data,bytearray(80))
        self.assertEqual(self.module.segments[4].size,0)
        self.assertFalse(self.report['full_executable_rebuilt'])
        self.assertFalse(self.report['original_member_used_by_producer'])
        self.assertEqual(set(self.report['independent_anchor_verifications']),{'drive386','set386','filelen','accss','tolower','toupper','strerror'})
        self.assertEqual(len(self.report['independently_anchored_imports']),8)
        self.assertIn('Error_',self.report['selected_member_call_nominations'])

    def test_every_const_and_initialized_pointer_byte_and_code_boundaries_reject(self):
        offsets=sorted(v for s,v in self.module.publics.values() if s==1)
        positions={0,1730}|set(offsets)|{v-1 for v in offsets if v}
        for seg,positions in [(0,positions),(1,range(406)),(3,range(80))]:
            for position in positions:
                damaged=copy.deepcopy(self.module);damaged.segments[seg].data[position]^=1
                with self.subTest(segment=seg,offset=position),self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)

    def test_every_fixup_typed_field_scope_and_segment_placement_reject(self):
        for f in range(70):
            original=self.module.fixups[f]
            fields={'width':2,'location':3,'relative':not original.relative,'frame_method':0,
                    'frame':999,'target_method':3,'target':999,'displacement':1,'offset':original.offset+1}
            for name,value in fields.items():
                damaged=copy.deepcopy(self.module);damaged.fixups[f]=replace(original,**{name:value})
                with self.subTest(fixup=f,field=name),self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)
        for name in self.module.publics:
            damaged=copy.deepcopy(self.module);del damaged.publics[name]
            with self.subTest(missing_public=name),self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)
        damaged=copy.deepcopy(self.module);damaged.local_publics.clear()
        with self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)
        damaged=copy.deepcopy(self.module);damaged.local_externals.clear()
        with self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)
        damaged=copy.deepcopy(self.module);damaged.segments[3].size=0;damaged.segments[4].size=80
        with self.assertRaises(ValueError):self.probe.check_module(damaged,self.image)
        for seg in (1,2,4):
            placements={int(k):tuple(v) for k,v in self.probe.load_spec()['placements'].items()};o,p=placements[seg];placements[seg]=(o,p+1)
            with self.subTest(misplaced_segment=seg),self.assertRaises(ValueError):self.probe.check_module(self.module,self.image,placements=placements)
        for name in self.probe.load_spec()['symbol_anchors']:
            o,p=self.probe.load_spec()['symbol_anchors'][name]
            with self.subTest(wrong_call=name),self.assertRaises(ValueError):self.probe.check_module(self.module,self.image,known={name:(o,p+1)})

    def test_stock_witness_identity_group_frames_and_anchor_claims_reject(self):
        lineage=json.loads((ROOT/'evidence/mact-file-source-reference.json').read_text())
        for field,value in [('size',1),('sha256','0'*64),('offset',1)]:
            damaged=copy.deepcopy(lineage);damaged['stock_crt_witnesses'][0][field]=value
            with self.subTest(witness_field=field),self.assertRaises(ValueError):self.probe.independent_anchors(self.image,damaged)
        damaged=copy.deepcopy(lineage);damaged['independently_anchored_imports']['access_'][1]+=1
        with self.assertRaises(ValueError):self.probe.independent_anchors(self.image,damaged)
        damaged=copy.deepcopy(lineage);next(r for r in damaged['stock_crt_witnesses'] if r['name']=='strerror')['group_frames']={'1':[3,1]}
        with self.assertRaises(ValueError):self.probe.independent_anchors(self.image,damaged)

    def test_real_native_behavior_storage_and_literal_mutants_reject(self):
        text=(ROOT/'src/mact/file_lib.c').read_text()
        mutants=[('tracking','strlen(filename)+1','strlen(filename)'),
            ('chunk','count > 0x7fff ? 0x7fff : count','count > 0x8000 ? 0x8000 : count'),
            ('filetype','if (filetype == 0)','if (filetype == 1)'),
            ('case','tolower(*src++)','toupper(*src++)'),
            ('path','if (cnt > MAXCHARS)','if (cnt >= MAXCHARS)'),
            ('extension',"*(src-1) != '.'","*(src-1) != '\\\\'"),
            ('state','FileNames[20] = {0}','FileNames[20]'),
            ('scope','static char *FileNames','char *FileNames'),
            ('const','Error opening %s: %s\\n\\0\\0','Error opening %s: %s\\n\\0X')]
        for index,(name,a,b) in enumerate(mutants):
            self.assertIn(a,text,name);source=self.build/f'mutant{index}.c';source.write_text(text.replace(a,b,1));obj=source.with_suffix('.obj')
            self.probe.compile_source(self.home,source,obj,self.probe.OPTIONS)
            with self.subTest(mutant=name),self.assertRaises(ValueError):self.probe.check_module(self.probe.Module.parse(obj.read_bytes()),self.image)

    def test_standalone_without_sdk_research_or_mutable_coverage_inventory(self):
        stage=self.build/'standalone';stage.mkdir()
        for folder in ('tools','profiles'):
            shutil.copytree(ROOT/folder,stage/folder,ignore=shutil.ignore_patterns('__pycache__'))
        for name in ['src/mact/file_lib.c','modules/mact_file.json','evidence/mact-file-source-reference.json']:
            dest=stage/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/name,dest)
        (stage/'reference').mkdir();(stage/'reference/DUKE3D.EXE').symlink_to(ROOT/'reference/DUKE3D.EXE')
        (stage/'toolchains').symlink_to(ROOT/'toolchains')
        subprocess.run(['python3',str(stage/'tools/probe_mact_file.py'),'--build',str(stage/'fresh'),'--report',str(stage/'report.json')],cwd=stage,check=True,capture_output=True)
        report=json.loads((stage/'report.json').read_text());self.assertTrue(report['verification']['verified'])
        self.assertEqual(report['source_sha256'],self.report['source_sha256'])
        self.assertFalse((stage/'reference/duke3d-reconstructions').exists())
        self.assertFalse((stage/'evidence/watcom-runtime-components.json').exists())

    def test_real_file_tracking_large_io_paths_extensions_and_errors(self):
        stage=self.build/'host';stage.mkdir()
        (stage/'fcntl.h').write_text('#include_next <fcntl.h>\n#define O_BINARY 0\n#define O_TEXT 0\n')
        (stage/'io.h').write_text('#include <unistd.h>\nlong filelength(int);\n')
        (stage/'direct.h').write_text('int host_chdir(const char *);\n')
        (stage/'dos.h').write_text('void _dos_setdrive(unsigned,unsigned*);\nvoid _dos_getdrive(unsigned*);\n')
        source=stage/'behavior.c'
        source.write_text(r'''#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
static int frees, allocations, readcalls, writecalls, closefail;
static unsigned maxread, maxwrite, currentdrive=3;
static char directories[128];
static ssize_t host_read(int h,void *p,size_t n) { readcalls++;if(n>maxread)maxread=n;return read(h,p,n); }
static ssize_t host_write(int h,const void *p,size_t n) { writecalls++;if(n>maxwrite)maxwrite=n;return write(h,p,n); }
static int host_close(int h) { if(closefail) return -1;return close(h); }
int host_chdir(const char *p) { strcat(directories,"[");strcat(directories,p);strcat(directories,"]");return strcmp(p,"bad")==0 ? -1:0; }
void _dos_setdrive(unsigned d,unsigned *total) { *total=26;if(d<=26)currentdrive=d; }
void _dos_getdrive(unsigned *d) { *d=currentdrive; }
long filelength(int h) { struct stat s;return fstat(h,&s) ? -1:s.st_size; }
void *SafeMalloc(long n) { void *p;allocations++;p=malloc(n);assert(p);return p; }
void SafeFree(void *p) { frees++;free(p); }
void Error(char *format,...) { va_list a;va_start(a,format);vprintf(format,a);va_end(a);exit(42); }
#define read host_read
#define write host_write
#define close host_close
#define chdir host_chdir
#include "'''+str(ROOT/'src/mact/file_lib.c')+r'''"
int main(int argc,char **argv) {
 char path[256], base[16], ext[64],dir[9],*next;
 char *data,*loaded;long length;int h,i,previous_frees;int handles[24],opened;
 if(argc>2) {
  if(!strcmp(argv[1],"open")) SafeOpenRead(argv[2],0);
  if(!strcmp(argv[1],"type")) SafeOpenWrite(argv[2],99);
  if(!strcmp(argv[1],"appendtype")) SafeOpenAppend(argv[2],-1);
  if(!strcmp(argv[1],"readtype")) SafeOpenRead(argv[2],2);
  if(!strcmp(argv[1],"read")) {h=SafeOpenRead(argv[2],0);SafeRead(h,base,16);}
  if(!strcmp(argv[1],"write")) {h=SafeOpenRead(argv[2],0);SafeWrite(h,base,1);}
  if(!strcmp(argv[1],"close")) {h=SafeOpenRead(argv[2],0);closefail=1;SafeClose(h);}
  if(!strcmp(argv[1],"closehigh")) { for(i=0;i<24;i++)h=SafeOpenRead(argv[2],0);assert(h>=20);closefail=1;SafeClose(h); }
  if(!strcmp(argv[1],"base")) ExtractFileBase("TOOLONGNAME.EXT",base);
  if(!strcmp(argv[1],"dir")) GetPath("NINECHARS",dir);
  return 99;
 }
 assert(argc==2);
 for(i=0;i<20;i++) assert(FileNames[i]==NULL);
 assert(!SafeFileExists(argv[1]));
 data=malloc(70000);assert(data);for(i=0;i<70000;i++)data[i]=(char)(i*13);
 SaveFile(argv[1],data,70000);assert(writecalls==3 && maxwrite==0x7fff);
 assert(SafeFileExists(argv[1]));
 length=LoadFile(argv[1],(void**)&loaded);assert(length==70000 && !memcmp(data,loaded,70000));
 assert(readcalls==3 && maxread==0x7fff);SafeFree(loaded);
 h=SafeOpenAppend(argv[1],1);assert(h>=0 && h<20 && !strcmp(FileNames[h],argv[1]));
 SafeWrite(h,"X",1);SafeClose(h);assert(FileNames[h]==NULL);
 h=SafeOpenRead(argv[1],1);assert(SafeFileLength(h)==70001);
 SafeRead(h,base,0);SafeWrite(h,base,0);
 /* A direct CRT close leaves stale tracked state: reopening that handle frees it. */
 assert(host_close(h)==0);previous_frees=frees;
 i=SafeOpenRead(argv[1],0);assert(i==h && frees==previous_frees+1);SafeClose(i);
 assert(allocations>0 && frees>0);
 opened=0;do { h=SafeOpenRead(argv[1],0);handles[opened++]=h; } while(h<20);
 previous_frees=frees;SafeClose(h);assert(frees==previous_frees);
 for(i=0;i<opened-1;i++)SafeClose(handles[i]);
 for(i=0;i<20;i++) assert(FileNames[i]==NULL);
 setenv("MACT_FILE_PATH","C:\\DATA",1);GetPathFromEnvironment(path,"MACT_FILE_PATH","DUKE.DAT");assert(!strcmp(path,"C:\\DATA\\DUKE.DAT"));
 unsetenv("MACT_FILE_PATH");GetPathFromEnvironment(path,"MACT_FILE_PATH","DUKE.DAT");assert(!strcmp(path,"DUKE.DAT"));
 strcpy(path,"C:\\DIR.NAME\\DUKE");DefaultExtension(path,".DAT");assert(!strcmp(path,"C:\\DIR.NAME\\DUKE.DAT"));
 DefaultExtension(path,".MAP");assert(!strcmp(path,"C:\\DIR.NAME\\DUKE.DAT"));
 strcpy(path,"DUKE.DAT");DefaultPath(path,"C:\\");assert(!strcmp(path,"C:\\DUKE.DAT"));
 strcpy(path,"\\DUKE.DAT");DefaultPath(path,"C:\\");assert(!strcmp(path,"\\DUKE.DAT"));
 ExtractFileBase("C:\\Data\\DUKE3D.GRP",base);assert(!memcmp(base,"duke3d\0\0",8));
 strcpy(ext,"unchanged");assert(!GetExtension("DUKE",ext) && !strcmp(ext,"unchanged"));
 assert(GetExtension("C:\\DUKE.GRP",ext) && !strcmp(ext,"GRP"));
 strcpy(path,"DUKE.GRP");SetExtension(path,".DAT");assert(!strcmp(path,"DUKE.DAT"));
 next=GetPath("\\DUKE\\DATA",dir);assert(!strcmp(dir,"DUKE") && !strcmp(next,"\\DATA"));
 assert(ChangeDrive("d:") && currentdrive==4);assert(!ChangeDrive("?:"));
 assert(ChangeDirectory("C:\\DUKE\\DATA"));assert(!strcmp(directories,"[\\][DUKE][DATA]"));
 directories[0]=0;assert(!ChangeDirectory("good\\bad\\next"));assert(!strcmp(directories,"[good][bad]"));
 assert(unlink(argv[1])==0);free(data);return 0;
}
''')
        binary=stage/'behavior'
        built=subprocess.run(['cc','-std=gnu89','-Wno-deprecated-non-prototype','-Wno-pointer-integer-compare','-I',str(stage),str(source),'-o',str(binary)],capture_output=True,text=True)
        self.assertEqual(built.returncode,0,built.stderr)
        result=subprocess.run([str(binary),str(stage/'large.dat')],capture_output=True,text=True)
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        small=stage/'small.dat';small.write_bytes(b'Q')
        cases=[('open',stage/'missing.dat','Error opening'),('type',small,'SafeOpenWrite: Illegal filetype specified'),
               ('appendtype',small,'SafeOpenAppend: Illegal filetype specified'),('readtype',small,'SafeOpenRead: Illegal filetype specified'),
               ('read',small,'reading 16 bytes from file '+str(small)),('write',small,'writing 1 bytes to file '+str(small)),
               ('close',small,'Unable to close file '+str(small)),('closehigh',small,'Unable to close file\n'),('base',small,'Filename base of TOOLONGNAME.EXT > 8 chars'),
               ('dir',small,'Directory name can only be 8 characters long.')]
        for mode,path,message in cases:
            result=subprocess.run([str(binary),mode,str(path)],capture_output=True,text=True)
            self.assertEqual(result.returncode,42,(mode,result.stdout,result.stderr));self.assertIn(message,result.stdout)
