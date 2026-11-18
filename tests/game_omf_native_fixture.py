"""Fresh actual GA/GNU fixture, using the same private ABI engine as GAME."""
from pathlib import Path
import sys,json,tempfile,subprocess,hashlib
R=Path(__file__).resolve().parents[1];P=R/'tests/fixtures/game_omf'
sys.path[:0]=[str(P),str(R),str(R/'profiles/watcom/tools')]
from tools import game_omf_link as link
from omf32 import Module
from runner import compile_source,run_batch
from le import LEImage
from tools.build_game_compound import tool_home
from profiles.gnu_elf_omf_game.identity import checked_home,profile

def produce():
 (R/'build').mkdir(exist_ok=True)
 w=Path(tempfile.mkdtemp(prefix='native-',dir=R/'build'));home=R/'toolchains/watcom-10.0-ga';gnu=R/'toolchains/gnu-elf-omf-game';hp=tool_home(home);gp=checked_home(gnu)
 link.need(len(hp)==500,'complete pinned GA compiler home')
 sources={str(p):hashlib.sha256(p.read_bytes()).hexdigest()for p in[P/'fixture.c',P/'fixture.S',Path(__file__),R/'tools/game_omf_link.py',R/'profiles/watcom/tools/runner.py']}
 compile_source(home,P/'fixture.c',w/'c.obj',['/4r','/s','/ort'],60)
 for command in [[str(gnu/'bin/as-new'),*profile()['options']['assembler'],'-o',str(w/'asm.elf'),str(P/'fixture.S')],[str(gnu/'bin/objconv'),*profile()['options']['converter'],str(w/'asm.elf'),str(w/'asm.obj')]]:
  subprocess.run(command,check=True,capture_output=True)
 link.need(tool_home(home)==hp and checked_home(gnu)==gp,'fixture tool freshness')
 link.need(all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in sources.items()),'fixture source freshness')
 c_raw=(w/'c.obj').read_bytes();a_raw=(w/'asm.obj').read_bytes();c,a=Module.parse(c_raw),Module.parse(a_raw)
 print('fixture C segments',[(s.name,s.class_name,s.size,s.attributes)for s in c.segments]);print('fixture C publics',c.publics,c.local_publics,'exts',c.externals,c.local_externals)
 link.need(c.local_publics=={'_fixture_shared','_fixture_asm_only'},'real native two private owners')
 link.need([c.externals[i-1]for i in c.local_externals]==['_fixture_shared'],'only C-referenced array has native LEXT')
 link.need(a.externals==['__GAME_UNIT_TEXT_fixture_shared','__GAME_UNIT_TEXT_fixture_asm_only'] and not a.local_externals,'actual global undefined transport')
 bankseg=c.publics['_fixture_shared'][0];link.need(c.publics['_fixture_asm_only']==(bankseg,4),'native bank coordinates')
 bank=dict(authored_messages=2,authored_bytes=8,message_map=[dict(name='fixture_shared',offset=0,data=b'ABC\0'.hex()),dict(name='fixture_asm_only',offset=4,data=b'XYZ\0'.hex())])
 declaration=dict(schema=1,unit='GAME',input_roles=['c','assembly'],reserved_prefix=link.PREFIX,aliases=[dict(alias=link.PREFIX+n,source_name=n,owner='_'+n,owner_input='c',owner_scope='LPUBDEF',owner_segment=bankseg,owner_segment_name='CONST',owner_segment_size=8,offset=off,capacity=4,input_role='assembly',input_scope='GLOBAL undefined transport',final_scope='unit-private LEXTDEF -> LPUBDEF')for n,off in [('fixture_shared',0),('fixture_asm_only',4)]])
 # Closed fixture scaffold preserves every native contribution, including empty CONST.
 link.need([(s.name,s.class_name,s.attributes)for s in c.segments]==[('_TEXT','CODE',105),('CONST','DATA',169),('CONST2','DATA',169),('_DATA','DATA',169),('_BSS','BSS',169),('CONST','DATA',169)],'closed fixture C scaffold')
 link.need([(s.name,s.class_name,s.size,s.attributes)for s in a.segments]==[('FIXTURE_ASM','CODE',11,41)],'closed fixture ASM contribution')
 comments=[link._raw_inventory(c_raw,c,'c'),link._raw_inventory(a_raw,a,'assembly')]
 layout=[[(0,1),(1,1)],[(0,2),(0,6)],[(0,3)],[(0,4)],[(0,5)]]
 m,cc,receipt=link._combine([c_raw,a_raw],[c,a],comments,declaration,bank,layout,link.SCAFFOLD,6,8)
 raw=link.serialize(m,cc);link.verify_roundtrip(m,raw);(w/'FIXTURE.OBJ').write_bytes(raw)
 run_batch(home,w,'@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BINW;D:\\BIN\r\nwlink system dos4g option nodefaultlibs option map=FIXTURE.MAP file FIXTURE.OBJ name FIXTURE.EXE > LINK.LOG\r\n',30)
 image=LEImage.parse((w/'FIXTURE.EXE').read_bytes());native_fields=image.read_fixups()
 link.need(image.object_bytes(2)[:8]==b'ABC\0XYZ\0','native WLINK final bank bytes')
 link.need(sorted((f.source_object,f.source_offset,f.width,f.target_object,f.target_offset)for f in native_fields)==[(1,1,4,2,0),(1,7,4,2,0),(1,12,4,2,5)],'independent native WLINK targets/addends')
 # Independent relocation inspection: flatten symbols at arbitrary source-owned
 # CODE/DATA bases, then evaluate native typed expressions directly.
 expected={'_fixture_shared':0x20000,'_fixture_asm_only':0x20004};values=[]
 for f in m.fixups:
  if f.target_method!=2:continue
  n=m.externals[f.target-1]
  if n not in expected:continue
  value=(expected[n]+f.displacement+int.from_bytes(m._segment(f.segment).data[f.offset:f.offset+4],'little'))&0xffffffff;values.append((f.segment,f.offset,n,value))
 link.need(sorted(v for _,_,_,v in values)==[0x20000,0x20000,0x20005],'independent fixture resolved addresses/addends')
 link.need(tool_home(home)==hp and checked_home(gnu)==gp,'post-link fixture tool freshness')
 link.need(all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in sources.items()),'post-link fixture source freshness')
 receipt.update(native_C_LPUB=sorted(c.local_publics),native_C_LEXT=[c.externals[i-1]for i in sorted(c.local_externals)],native_ASM_EXT=a.externals,native_ASM_fields=[dict(offset=f.offset,displacement=f.displacement,inline_addend=int.from_bytes(a._segment(f.segment).data[f.offset:f.offset+4],'little'))for f in a.fixups],WLINK_LE_fields=[dict(source_object=f.source_object,source_offset=f.source_offset,width=f.width,target_object=f.target_object,target_offset=f.target_offset)for f in native_fields],WLINK_log=(w/'LINK.LOG').read_text(),source_sha256=sources,toolhome_sha256=hp,gnu_toolhome_sha256=gp,native_fixture_values=values,output_sha256=hashlib.sha256(raw).hexdigest());(w/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(w)
 return w
if __name__=='__main__':produce()
