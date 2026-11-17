"""Closed TLIBDOS source/ELF/role contracts. No assert-based admission checks."""
import re,struct
GLOBALS={'I_Time_':('_TEXT',0),'TIMELIB_StartTiming_':('_TEXT',104),'TIMELIB_StopTiming_':('_TEXT',212),'_stoptics':('_BSS',0),'_starttics':('_BSS',4)}
IMPORTS={'_dos_gettime_'}
def need(condition,message):
 if not condition:raise ValueError('TLIBDOS '+message)
def source(text):
 lines=[line.partition('#')[0].strip()for line in text.splitlines()];lines=[line for line in lines if line];macros={};current=None;body=[];pub=set();external=set();labels=[];constants={};sections=[];storage=[]
 directives={'.intel_syntax noprefix','.file "TLIBDOS.S"','.p2align 4','.p2align 2'}
 for line in lines:
  need(';'not in line,'multiple statements/payload forbidden')
  if line.startswith('.macro '):need(current is None,'nested macro');current=line.split()[1];need(current not in macros,'duplicate macro');macros[current]=[];continue
  if line=='.endm':need(current is not None,'unmatched endm');current=None;continue
  if current:macros[current].append(line);continue
  if line.startswith('.section '):sections.append(line);continue
  if line in directives:continue
  if line.startswith('.globl '):pub.update(line[7:].split(','));continue
  if line.startswith('.extern '):external.add(line[8:]);continue
  if '='in line:
   name,value=map(str.strip,line.split('='));need(name in ['HOUR_MS','TIME_BYTES']and name not in constants,'constant name/scope');constants[name]=int(value);continue
  if ':'in line:
   name,tail=map(str.strip,line.split(':',1));labels.append(name)
   if tail:storage.append((name,tail))
   continue
  body.append(line)
 need(current is None and set(macros)=={'CLOCK_VALUE','RETURN_CLOCK'},'clock macro ownership');need(pub==set(GLOBALS)and external==IMPORTS,'global/import scopes');need(set(labels)==set(GLOBALS)and len(labels)==5,'true labels/private scope');need(constants.keys()=={'HOUR_MS','TIME_BYTES'}and constants['TIME_BYTES']==4 and 0<constants['HOUR_MS']<0x80000000,'logical units/stack geometry');need(storage==[('_stoptics','.zero 4'),('_starttics','.zero 4')],'real BSS owners/order');need(sections==['.section _TEXT,"ax",@progbits','.section CONST,"aw",@progbits','.section CONST2,"aw",@progbits','.section _DATA,"aw",@progbits','.section _BSS,"aw",@nobits','.section _TEXT'],'section ownership/alignment context');need(body.count('CLOCK_VALUE')==3 and body.count('RETURN_CLOCK')==3,'inlined algorithms retained')
 expanded=[]
 for line in body:expanded.extend(macros.get(line,[line]))
 allowed={'push','pop','sub','mov','call','xor','imul','shl','add','lea','ret','nop'}
 for line in expanded:
  operation=re.sub(r'^\{disp8\} ','',line).split()[0];need(operation in allowed and not line.startswith('.'),'ordinary instruction source/no payload')
 need(len(expanded)==124,'complete124 source instructions');return {'constants':constants,'expanded_source_instructions':124,'global_definitions':GLOBALS,'imports':sorted(IMPORTS),'runtime_private_definitions':0,'source_folded_ABS':2}

def elf(raw,e,logical):
 need(raw[:16]==b'\x7fELF\x01\x01\x01'+b'\0'*9,'ELF identification');h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);need((h[0],h[1],h[2],h[3],h[4],h[6],h[7],h[8],h[9],h[10],h[11],h[12])==(1,3,1,0,0,0,52,0,0,40,13,12),'ELF header');need(h[5]+40*13==len(raw),'section header extent');ss=[struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*i)for i in range(13)];need(ss[0]==(0,)*10,'null section');names=['','.text','.data','.bss','_TEXT','.rel_TEXT','CONST','CONST2','_DATA','_BSS','.symtab','.strtab','.shstrtab'];need([s['name']for s in e['sections']]==names,'exact section names');expected={1:(1,6,0,1,0),2:(1,3,0,1,0),3:(8,3,0,1,0),4:(1,6,329,16,0),5:(9,64,48,4,8),6:(1,3,0,4,0),7:(1,3,0,4,0),8:(1,3,0,4,0),9:(8,3,8,16,0),10:(2,0,160,4,16),11:(3,0,114,1,0),12:(3,0,78,1,0)};ranges=[(0,52),(h[5],len(raw))]
 for i,s in enumerate(ss[1:],1):
  need((s[1],s[2],s[5],s[8],s[9])==expected[i]and s[3]==0,'section schema')
  need((s[6],s[7])==({5:(10,4),10:(11,4)}.get(i,(0,0))),'section link/info');need(52<=s[4]<=h[5]and(s[1]==8 or s[4]+s[5]<=h[5]),'section backing/range')
  if s[1]!=8 and s[5]:ranges.append((s[4],s[4]+s[5]))
 ranges.sort();need(all(a[1]<=b[0]for a,b in zip(ranges,ranges[1:])),'section overlap');need(all(not any(raw[a[1]:b[0]])for a,b in zip(ranges,ranges[1:])),'noncanonical file gap');tab=e['symbols'].get(10,e['symbols'].get('10'));need(len(tab)==10,'symbol extent');strings=raw[ss[11][4]:ss[11][4]+ss[11][5]]
 for i,s in enumerate(tab):
  n,v,z,info,other,section=struct.unpack_from('<IIIBBH',raw,ss[10][4]+16*i);need(n<len(strings)and b'\0'in strings[n:],'symbol string');name=strings[n:strings.index(b'\0',n)].decode('ascii');need((name,v,z,info>>4,info&15,other,section)==(s['name'],s['value'],s['size'],s['binding'],s['type'],s['other'],s['section']),'raw/parsed symbol');need(z==other==0,'symbol size/visibility')
  if i==0:need((n,v,z,info,other,section)==(0,)*6,'null symbol')
  elif name=='TLIBDOS.S':need((v,info,section)==(0,4,65521),'FILE identity')
  elif name in logical['constants']:need((v,info,section)==(logical['constants'][name],0,65521),'real ABS constant')
  elif name in GLOBALS:need((info,section,v)==(16,names.index(GLOBALS[name][0]),GLOBALS[name][1]),'real GLOBAL definition')
  else:need(name=='_dos_gettime_'and(v,info,section)==(0,16,0),'true undefined import')
 need({s['name']for s in tab}=={'','TLIBDOS.S','HOUR_MS','TIME_BYTES'}|set(GLOBALS)|IMPORTS,'complete symbol identity set');expected_roles={8:('_dos_gettime_',2,-4),112:('_dos_gettime_',2,-4),201:('_starttics',1,0),220:('_dos_gettime_',2,-4),309:('_starttics',1,0),317:('_stoptics',1,0)};need(len(e['relocations'])==6,'REL count');need({r['offset']for r in e['relocations']}==set(expected_roles),'complete REL offsets')
 for i in range(6):
  off,info=struct.unpack_from('<II',raw,ss[5][4]+8*i);kind=info&255;index=info>>8;need(index<10 and off in expected_roles,'REL index/range');r=e['relocations'][i];need((r['source_section'],r['offset'],r['type'],r['symbol']['index'])==(4,off,kind,index),'raw/parsed REL');need((tab[index]['name'],kind,r['inline_signed'])==expected_roles[off],'six typed source roles')
 return {'closed_ELF32_i386':True,'all13sections':True,'all10symbols':True,'all6typed_roles':True,'runtime_private_definitions':0}

def roles(original,native):
 need(not(original.local_publics or original.local_externals or native.local_publics or native.local_externals),'private scope');need(len(original.fixups)==len(native.fixups)==6,'six roles');need({n:(original._segment(s).name,o)for n,(s,o)in original.publics.items()}=={n:(native._segment(s).name,o)for n,(s,o)in native.publics.items()},'five global definitions');out=[]
 for a,b in zip(original.fixups,native.fixups):
  need((a.offset,a.width,a.location,a.relative,a.displacement)==(b.offset,b.width,b.location,b.relative,b.displacement)and a.width==4 and a.location==9 and a.displacement==0,'typed field geometry');need(a.target_method==b.target_method==2,'target form');name=original.externals[a.target-1];need(name==native.externals[b.target-1],'actual target name');need(a.frame_method==1 and original.groups[a.frame-1]==('FLAT',())and b.frame_method==5,'measured C/GNU frame roles');out.append({'offset':a.offset,'name':name,'relative':a.relative,'width':4,'original_frame':'FLAT','source_frame':'target'})
 return out
