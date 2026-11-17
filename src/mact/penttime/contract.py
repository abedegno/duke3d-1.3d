"""Closed PENTTIME semantic source, ELF32 and full native-role contracts.

No target input, opaque payload, fake private export or optimized-away guard.
"""
import ast,struct,re,collections,dataclasses
PUBLIC={'PENT_Init_':0,'PENT_GetTime_':324,'PENT_StartTimer_':344,'PENT_StopTimer_':352,'PENT_Cycles_':380,'PENT_Time_':452}
IMPORTS={'PENT_Start_','PENT_Stop_','TIME_AddTimer_','ServiceEvents_','printf_','TIME_RemoveTimer_','_PENT_timeh','_PENT_timel','_fltused_','__init_387_emulator','__8087'}
UNUSED={'_fltused_','__init_387_emulator','__8087'}
PRIVATE={'calibration_message':(6,0),'calibration_average':(6,34),'calibration_ticks_per_second':(6,42),'cycles_to_megahertz':(6,50),'calibration_word_scale':(6,58),'cycle_word_scale':(6,66),'time_word_scale':(6,74),'_PENT_megahertz':(9,0),'_PENT_timer':(9,8),'_PENT_overhead':(9,16),'calibration_sample':(4,64),'calibration_sample_done':(4,92),'calibration_wait':(4,81),'calibration_sum':(4,130)}
ABS={'CALIBRATION_FRAME':108,'SAMPLE_BYTES':80,'CALIBRATION_TOTAL':96,'CALIBRATION_TICKS':104,'CONVERSION_INTEGER':80,'CONVERSION_DOUBLE':88}
SECTIONS=[('.text',0,1,6,1),('.data',0,1,3,1),('.bss',0,8,3,1),('_TEXT',527,1,6,16),('CONST',82,1,3,4),('CONST2',0,1,3,4),('_DATA',0,1,3,4),('_BSS',24,8,3,16)]
def need(ok,why):
 if not ok:raise ValueError('PENTTIME '+why)
def source(text):
 section=None;labels=set();globals=set();imports=set();locals=set();constants={};const=bytearray();bss=[];macro=None;macros={};calls=[]
 for line in text.splitlines():
  t=line.partition('#')[0].strip()
  if not t:continue
  need(';'not in t,'chained source directive/statement')
  if macro:
   if t=='.endm':macro=None
   else:need(not t.startswith('.')and not ':'in t and not '='in t,'macro body must contain ordinary symbolic instructions');macros[macro].append(t)
   continue
  if t.startswith('.macro '):
   sig=t[7:];need(sig in ('CYCLE_VALUE scale','CYCLE_RETURN')and sig not in macros,'exact two meaningful macros');macro=sig;macros[sig]=[];continue
  if re.match(r'^[A-Za-z_][A-Za-z_0-9]*:',t):
   n,t=t.split(':',1);need(re.fullmatch('[A-Za-z_][A-Za-z_0-9]*',n)and n not in labels,'real unique label');labels.add(n);t=t.strip()
   if not t:continue
  if re.match(r'[A-Z_]+\s*=',t):
   n,v=t.split('=',1);constants[n.strip()]=int(v);continue
  if t.startswith('.'):
   if t.startswith('.section '):section=t.split()[1].split(',')[0];need(section in {s[0]for s in SECTIONS},'exact section names')
   elif t.startswith('.globl '):globals.update(t[7:].split(','))
   elif t.startswith('.extern '):imports.update(t[8:].split(','))
   elif t.startswith('.local '):locals.update(t[7:].split(','))
   elif t.startswith('.asciz '):need(section=='CONST','string section');const+=ast.literal_eval(t[7:]).encode('ascii')+b'\0'
   elif t.startswith('.double '):need(section=='CONST','double section');const+=struct.pack('<d',float(t[8:]))
   elif t.startswith('.zero '):need(section=='_BSS'and t=='.zero 8','three genuine private doubles/counter storage');bss.append(8)
   else:need(t in ('.intel_syntax noprefix','.arch .387','.file "PENTTIME.S"','.p2align 4','.p2align 2'),'unsupported source directive')
  else:
   need(section=='_TEXT','instruction section');need(not re.search(r'\b(?:db|dw|dd|dq|incbin|org)\b',t,re.I),'instruction payload')
   if t.startswith(('CYCLE_VALUE','CYCLE_RETURN')):calls.append(t)
 need(macro is None and set(macros)=={'CYCLE_VALUE scale','CYCLE_RETURN'},'complete two macros');need(calls==['CYCLE_VALUE cycle_word_scale','CYCLE_RETURN','CYCLE_VALUE time_word_scale','CYCLE_RETURN'],'typed per-function macro roles');need(globals==set(PUBLIC)|UNUSED and imports==IMPORTS and locals=={'_PENT_megahertz','_PENT_timer','_PENT_overhead'},'exact genuine public/import/private declarations');need(labels==set(PUBLIC)|set(PRIVATE)and constants==ABS and bss==[8]*3 and len(const)==82,'complete semantic owners/constants/storage');return {'CONST':const.hex(),'BSS':24,'macros':macros,'macro_invocations':calls,'private_names':sorted(PRIVATE),'all_definitions':sorted(labels)}
def elf(raw,e,logical):
 need(raw[:16]==b'\x7fELF\x01\x01\x01'+bytes(9),'ELF ident');h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);need(h[:5]==(1,3,1,0,0)and h[6:]==(0,52,0,0,40,13,12)and h[5]+13*40==len(raw),'raw ELF header/bounds');ss=[struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*i)for i in range(13)];need(ss[0]==(0,)*10,'null section');sec=e['sections'];names={s['index']:s['name']for s in sec};need([s['name']for s in sec]==['','.text','.data','.bss','_TEXT','.rel_TEXT','CONST','CONST2','_DATA','_BSS','.symtab','.strtab','.shstrtab'],'closed section set/order');need([(s['name'],s['size'],s['type'],s['flags'],s['align'])for s in sec if s['name']in{v[0]for v in SECTIONS}]==SECTIONS,'complete section storage/alignment');ranges=[(0,52),(h[5],len(raw))]
 for i,s in enumerate(ss[1:],1):
  need(s[3]==0 and 52<=s[4]<=h[5]and(s[1]==8 or s[4]+s[5]<=h[5]),'section bounds')
  if s[1]!=8 and s[5]:ranges.append((s[4],s[4]+s[5]))
  if i==5:need((s[1],s[2],s[5],s[6],s[7],s[8],s[9])==(9,64,368,10,4,4,8),'REL schema')
  elif i==10:need((s[1],s[2],s[5],s[6],s[7],s[8],s[9])==(2,0,656,11,24,4,16),'symbol schema')
  elif i in (11,12):need((s[1],s[2],s[6],s[7],s[8],s[9])==(3,0,0,0,1,0),'strings schema')
  else:need((s[6],s[7],s[9])==(0,0,0),'section metadata')
 ranges.sort();need(all(a[1]<=b[0]and not any(raw[a[1]:b[0]])for a,b in zip(ranges,ranges[1:])),'overlap/unknown padding');symbols=[s for t in e['symbols'].values()for s in t];need(len(symbols)==41,'all41 symbols');strings=raw[ss[11][4]:ss[11][4]+ss[11][5]]
 for i,s in enumerate(symbols):
  n,v,z,info,other,sn=struct.unpack_from('<IIIBBH',raw,ss[10][4]+i*16);need(n<len(strings),'symbol name bounds');name=strings[n:strings.index(b'\0',n)].decode('ascii');need((name,v,z,info>>4,info&15,other,sn)==(s['name'],s['value'],s['size'],s['binding'],s['type'],s['other'],s['section']),'raw complete symbol');need(z==0 and info>>4==(0 if i<24 else 1)and other==0,'symbol scope/visibility')
  if i==0:need((name,v,z,info,other,sn)==('',0,0,0,0,0),'null symbol')
  elif info&15==4:need((name,v,info,sn)==('PENTTIME.S',0,4,65521),'FILE identity')
  elif info&15==3:need(name==''and v==0 and info==3 and sn in(6,9),'section identity')
  elif sn==65521:need(name in ABS and info==0 and v==ABS[name],'meaningful ABS identity')
  elif sn==0:need(name in IMPORTS and info==16 and v==0,'true undefined global')
  elif name in PUBLIC:need((sn,v,info)==(4,PUBLIC[name],16),'actual public coordinate')
  else:need(name in PRIVATE and(sn,v)==PRIVATE[name]and info==0,'actual private coordinate')
 need({s['name']for s in symbols if s['binding']==1 and s['section']==0}==IMPORTS,'unused FPU declarations must remain');need({s['name']for s in symbols if s['binding']==1 and 0<s['section']<65520}==set(PUBLIC),'public set');need({s['name']for s in symbols if s['type']==0 and 0<s['section']<65520}==set(PUBLIC)|set(PRIVATE),'all source identities');need({s['name']:s['value']for s in symbols if s['type']!=4 and s['section']==65521}==ABS and sum(s['type']!=4 and s['section']==65521 for s in symbols)==6,'all six qualified ABS identities');need(sum(s['type']==4 for s in symbols)==1 and sum(s['type']==3 for s in symbols)==2 and{(s['section'],s['value'])for s in symbols if s['type']==3}=={(6,0),(9,0)},'structural identities');need(sec[6]['bytes']==logical['CONST'],'all source-derived scalar/string bytes');rels=e['relocations'];need(len(rels)==46,'all46 REL records');seen=set()
 for r in rels:
  need(r['source_section']==4 and r['type']in(1,2)and r['offset']+4<=527 and r['symbol']['section']!=65521,'typed runtime field');q=set(range(r['offset'],r['offset']+4));need(not q&seen,'overlapping/duplicate fields');seen|=q
 need(not any(r['symbol']['name']in UNUSED for r in rels),'unused imports must have no fabricated references');return {'all13sections':True,'all41symbols':True,'all46fields':True,'source_private14_ABS6':True,'unused_FPU3_real':True}
def native(m,e):
 fields={f.offset:f for f in m.fixups};need(len(fields)==len(m.fixups)==46,'complete native typed fields');sn={s['index']:s['name']for s in e['sections']};mn={s.name:n for n,s in enumerate(m.segments,1)}
 for r in e['relocations']:
  f=fields.get(r['offset']);need(f is not None and(f.segment,f.width,f.location,f.relative,f.displacement)==(4,4,9,r['type']==2,0),'ELF/native field geometry');a=int.from_bytes(m._segment(4).data[f.offset:f.offset+4],'little');need(a==(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff,'PC32 plus4/addend math');s=r['symbol']
  if s['binding']==1:need(f.target_method==2 and m.externals[f.target-1]==s['name']and f.frame_method==5,'genuine global linker-selected identity')
  else:need(f.target_method==0 and f.target==mn[sn[s['section']]]and f.frame_method==1 and m.groups[f.frame-1]==('FLAT',()),'genuine private/section target')
 need(UNUSED<=set(m.externals)and not(m.local_publics or m.local_externals),'all unused/private native scopes')
def roles(original,m,e):
 need(len(original.fixups)==len(m.fixups)==46,'original whole fields');symbols={s['name']:s for tab in e['symbols'].values()for s in tab if s['name']};mn={s.name:n for n,s in enumerate(m.segments,1)};names={s['index']:s['name']for s in e['sections']};fields={f.offset:f for f in m.fixups};er={r['offset']:r for r in e['relocations']};private=original.local_publics;need(private=={'_PENT_timer','_PENT_megahertz','_PENT_overhead'},'original actual private owners');need({original.externals[i-1]for i in original.local_externals}==private and set(original.externals)-private==set(m.externals),'original full import/private declaration correspondence');need({n:v for n,v in original.publics.items()if n not in private}=={n:(1,v)for n,v in PUBLIC.items()},'original full nonlocal public geometry');counts=collections.Counter();out=[]
 for name in private:
  seg,value=original.publics[name];s=symbols[name];need((s['binding'],names[s['section']],s['value'])==(0,original._segment(seg).name,value),'original/source private identity');need(name not in m.publics and name not in m.externals,'private promotion')
 for f in original.fixups:
  g=fields[f.offset];r=er[f.offset];need((g.width,g.location,g.relative)==(f.width,f.location,f.relative)==(4,9,f.relative),'whole typed original geometry');name=original.externals[f.target-1]if f.target_method==2 else original._segment(f.target).name
  if name in private:
   s=symbols[name];need(g.target_method==0 and m._segment(g.target).name==names[s['section']],'private target section');old=int.from_bytes(original._segment(f.segment).data[f.offset:f.offset+4],'little')+f.displacement;new=int.from_bytes(m._segment(g.segment).data[g.offset:g.offset+4],'little')+g.displacement;need(r['symbol']['value']+new==s['value']+old,'private section+V+A equation');counts[name]+=1
  elif f.target_method==2:need(g.target_method==2 and m.externals[g.target-1]==name,'original named external role')
  else:need(g.target_method==0 and m._segment(g.target).name==name,'original constant role')
  out.append({'name':name,'original':dataclasses.asdict(f),'native':dataclasses.asdict(g),'ELF':r})
 need(dict(counts)=={'_PENT_timer':11,'_PENT_overhead':5,'_PENT_megahertz':3},'all19 private references');return {'roles':out,'private_reference_counts':dict(counts),'private_scope':'3 original named locals -> qualified source-local identities, not exports','source_credit':0}
