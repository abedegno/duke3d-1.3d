"""Closed ROX462 ELF schema, not general ELF or application authorization."""
import struct

def check(raw,e,guard):
 assert raw[:16]==b'\x7fELF\x01\x01\x01'+b'\0'*9,'ELF identification/ABI'
 h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16)
 assert(h[0],h[1],h[2],h[3],h[4],h[6],h[7],h[8],h[9],h[10],h[11],h[12])==(1,3,1,0,0,0,52,0,0,40,12,11),'ELF header'
 assert h[5]+40*h[11]==len(raw),'section table extent'
 ss=[struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*i)for i in range(12)];assert ss[0]==(0,)*10
 names=[s['name']for s in e['sections']];assert names==['','.text','.data','.bss','_TEXT','.rel_TEXT','CONST','_DATA','_BSS','.symtab','.strtab','.shstrtab']
 expected={1:(1,6,0,1,0),2:(1,3,0,1,0),3:(8,3,0,1,0),4:(1,6,1217,16,0),5:(9,64,712,4,8),6:(1,3,342,4,0),7:(1,3,11,4,0),8:(8,3,256,16,0),9:(2,0,1568,4,16),10:(3,0,1358,1,0),11:(3,0,71,1,0)}
 ranges=[(0,52),(h[5],len(raw))]
 for i,s in enumerate(ss[1:],1):
  assert(s[1],s[2],s[5],s[8],s[9])==expected[i],'section schema'
  assert s[3]==0
  if i==5:assert(s[6],s[7])==(9,4),'REL link/info'
  elif i==9:assert(s[6],s[7])==(10,70),'SYMTAB link/info'
  else:assert(s[6],s[7])==(0,0)
  assert 52<=s[4]<=h[5] and(s[1]==8 or s[4]+s[5]<=h[5]),'section range'
  if s[1]!=8 and s[5]:ranges.append((s[4],s[4]+s[5]))
 ranges.sort();assert all(a[1]<=b[0]for a,b in zip(ranges,ranges[1:])),'file overlap'
 assert all(not any(raw[a[1]:b[0]])for a,b in zip(ranges,ranges[1:])),'noncanonical inter-section file bytes'
 # Independently read the actual raw symbol table rather than trusting an
 # earlier parsed view when checking classes/visibility/common/ABS rules.
 symbols=[]
 for i in range(ss[9][5]//16):
  n,v,z,info,other,section=struct.unpack_from('<IIIBBH',raw,ss[9][4]+i*16);symbols.append((n,v,z,info>>4,info&15,other,section));assert info>>4 in(0,1)and info&15 in(0,3,4)and other==0 and section!=0xfff2,'symbol bind/type/visibility/common'
 assert symbols[0]==(0,)*7;assert all(s[3]==0 for s in symbols[:70])and all(s[3]==1 for s in symbols[70:])
 tab=e['symbols'].get(9,e['symbols'].get('9'));assert len(symbols)==98 and len(tab)==98
 for i,(a,b)in enumerate(zip(symbols,tab)):
  assert(a[1],a[2],a[3],a[4],a[5],a[6])==(b['value'],b['size'],b['binding'],b['type'],b['other'],b['section']),'parsed/raw symbol mismatch'
  strtab=raw[ss[10][4]:ss[10][4]+ss[10][5]];assert a[0]<len(strtab) and b'\0' in strtab[a[0]:]
  actual_name=strtab[a[0]:strtab.index(b'\0',a[0])].decode('ascii');assert actual_name==b['name'],'symbol name mismatch'
  assert a[2]==0
  if b['type']==4:assert b['name']=='ROX.S'and(a[1],a[3],a[6])==(0,0,0xfff1),'FILE schema'
  elif b['type']==3:assert b['name']==''and(a[1],a[3])==(0,0)and a[6]in(4,6,7,8),'SECTION schema'
  elif b['section']==0xfff1:assert b['name']in guard.FIELDS and b['binding']==0 and b['value']==guard.FIELDS[b['name']]
  elif b['section']==0:assert i==0 or b['name']in guard.IMPORTS and b['binding']==1 and b['value']==0
  else:assert b['section']in(4,6,7,8)and b['value']<=ss[b['section']][5]
 seen=[]
 for i in range(ss[5][5]//8):
  off,info=struct.unpack_from('<II',raw,ss[5][4]+i*8);target,kind=info>>8,info&255;assert kind in(1,2)and target<len(symbols)and off+4<=1217,'REL kind/index/range';sym=symbols[target];assert sym[6]!=0xfff1,'ABS relocation unsupported';assert not any(off<end and off+4>start for start,end in seen),'REL overlap';seen.append((off,off+4));assert any(r['offset']==off and r['type']==kind and r['symbol']['index']==target for r in e['relocations']),'parsed/raw REL mismatch'
 assert len(seen)==89
 return {'ELF32_i386_ET_REL':True,'closed12_section_schemas':True,'all98_raw_symbol_entries':True,'all89_typed_REL_fields':True,'no_common_weak_TLS_hidden_or_ABS_relocations':True,'unbacked_BSS':256}
