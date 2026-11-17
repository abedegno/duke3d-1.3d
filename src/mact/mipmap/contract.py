"""Closed MIPMAP source/ELF/COFF/OMF scopes and complete typed equations.
No target input, assertion-based checks, opaque storage or private promotion.
"""
import ast,re,struct,dataclasses
SECTIONS = {'.text': (0, 1, 6, 1), '.data': (0, 1, 3, 1), '.bss': (0, 8, 3, 1), '_TEXT': (1133, 1, 6, 16), 'CONST': (8, 1, 3, 4), 'CONST2': (0, 1, 3, 4), '_DATA': (0, 1, 3, 4), '_BSS': (0, 8, 3, 16)}
PUBLIC = {'FoldPixel_': 0, 'CreateMipMap_': 208}
IMPORTS = {'SafeMalloc_', 'memset_', 'CMAP_BestColor_', 'SafeFree_', '_fltused_', '__init_387_emulator', '__8087'}
LABELS = {'mip_level_test': 559, 'initialize_row': 395, 'initialize_next_row': 532, 'initialize_pixel': 436, 'output_begin': 728, 'fold_copy': 625, 'fold_row': 580, 'fold_next_row': 616, 'fold_pixel': 586, 'output_done': 1095, 'output_row': 762, 'output_next_row': 1068, 'output_pixel': 800, 'output_advance': 1051}
ABS = {'DOUBLE_ONE_HIGH': 1023 << 20, 'PIXEL_BYTES': 32, 'PIXEL_WEIGHT': 0, 'PIXEL_RED': 8, 'PIXEL_GREEN': 16, 'PIXEL_BLUE': 24, 'FRAME_BYTES': 116, 'ERROR_RED': 8, 'ERROR_GREEN': 0, 'ERROR_BLUE': 16, 'VALUE_RED': 32, 'VALUE_GREEN': 48, 'VALUE_BLUE': 40, 'ORIGINAL_ROW_BYTES': 60, 'OUTPUT_ROW_BYTES': 64, 'ORIGINAL_ROW_STEP': 68, 'SOURCE_BITMAP': 72, 'ACCUMULATOR_ROW': 76, 'OUTPUT_ROW': 80, 'LEVEL': 84, 'HEIGHT': 88, 'BUFFER_BYTES': 92, 'HALF_HEIGHT': 96, 'FOLDED_PIXELS': 100, 'SOURCE_PIXELS': 104, 'WIDTH': 108, 'CHANNEL_INTEGER': 112, 'DEST_BITMAP_ARG': 132, 'PALETTE_ARG': 136, 'DIFFUSION_ARG': 140}
UNUSED={'_fltused_','__init_387_emulator','__8087'}
REL={262:('SafeMalloc_',2),300:('SafeMalloc_',2),317:('memset_',2),330:('memset_',2),416:('CONST',1),608:('FoldPixel_',2),899:('CMAP_BestColor_',2),942:('CONST',1),1100:('SafeFree_',2),1113:('SafeFree_',2)}
def need(ok,why):
 if not ok:raise ValueError('MIPMAP '+why)
def integer(text):
 def f(n):
  if isinstance(n,ast.Constant)and type(n.value)is int:return n.value
  if isinstance(n,ast.BinOp)and isinstance(n.op,ast.LShift):return f(n.left)<<f(n.right)
  raise ValueError('unsupported source constant')
 return f(ast.parse(text,mode='eval').body)
def source(text):
 labels=[];pub=set();imports=set();const={};sections=[];current=None;scale=None;ops=[]
 for line in text.splitlines():
  t=line.partition('#')[0].strip()
  if not t:continue
  need(';'not in t,'chained statements/payload')
  if re.match(r'^[A-Za-z_][A-Za-z_0-9]*:',t):
   n,t=t.split(':',1);need(n not in labels,'duplicate source definition');labels.append(n);t=t.strip()
   if not t:continue
  if t.startswith('.'):
   if t.startswith('.section '):current=t.split()[1].split(',')[0];sections.append(t)
   elif t.startswith('.equ '):n,v=t[5:].split(',',1);need(n not in const,'duplicate ABS');const[n]=integer(v.strip())
   elif t.startswith('.globl '):pub.update(n.strip()for n in t[7:].split(','))
   elif t.startswith('.extern '):imports.update(n.strip()for n in t[8:].split(','))
   elif t.startswith('.double '):need(current=='CONST'and scale is None,'one genuine scale owner');scale=struct.pack('<d',float(t[8:]))
   else:need(t in ('.intel_syntax noprefix','.arch .387','.code32','.file "MIPMAP.S"','.p2align 4','.p2align 2'),'unknown source/payload directive')
  else:need(current=='_TEXT'and not re.search(r'\b(?:db|dw|dd|dq|incbin|org)\b',t,re.I),'ordinary CODE only');ops.append(t)
 need(pub==set(PUBLIC)|UNUSED and imports==IMPORTS,'actual public/import declarations');need(set(labels)==set(PUBLIC)|set(LABELS)|{'channel_scale'}and len(labels)==17 and const==ABS,'all private/ABS identities');need(sections==['.section _TEXT,"ax",@progbits','.section CONST,"aw",@progbits','.section CONST2,"aw",@progbits','.section _DATA,"aw",@progbits','.section _BSS,"aw",@nobits']and scale is not None and len(ops)==369,'full section/storage/instruction ownership');return {'lines':text.splitlines(),'scale':scale.hex(),'instructions':ops,'source_private15':True,'all30_ABS':const}
def elf(raw,e,logical,listing):
 need(raw[:16]==b'\x7fELF\x01\x01\x01'+bytes(9),'ELF ident');h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);need(h[:5]==(1,3,1,0,0)and h[6:]==(0,52,0,0,40,13,12)and h[5]+13*40==len(raw),'header/extent');ss=[struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*i)for i in range(13)];need(ss[0]==(0,)*10,'null section');sec=e['sections'];names={s['index']:s['name']for s in sec};need([s['name']for s in sec]==['','.text','.data','.bss','_TEXT','.rel_TEXT','CONST','CONST2','_DATA','_BSS','.symtab','.strtab','.shstrtab'],'all13 sections');need({s['name']:(s['size'],s['type'],s['flags'],s['align'])for s in sec if s['name']in SECTIONS}==SECTIONS,'genuine geometry/flags/alignment');ranges=[(0,52),(h[5],len(raw))]
 for i,s in enumerate(ss[1:],1):
  need(s[3]==0 and 52<=s[4]<=h[5]and(s[1]==8 or s[4]+s[5]<=h[5]),'section bounds')
  if s[1]!=8 and s[5]:ranges.append((s[4],s[4]+s[5]))
  if i==5:need((s[1],s[2],s[5],s[6],s[7],s[8],s[9])==(9,64,80,10,4,4,8),'raw REL schema')
  elif i==10:need((s[1],s[2],s[5],s[6],s[7],s[8],s[9])==(2,0,912,11,48,4,16),'symbol schema')
  elif i in(11,12):need((s[1],s[2],s[6],s[7],s[8],s[9])==(3,0,0,0,1,0),'string schema')
  else:need((s[6],s[7],s[9])==(0,0,0),'section metadata')
 ranges.sort();need(all(a[1]<=b[0]and not any(raw[a[1]:b[0]])for a,b in zip(ranges,ranges[1:])),'raw overlap/extra nonzero bytes');symbols=[s for t in e['symbols'].values()for s in t];need(len(symbols)==57,'all57 symbols');strings=raw[ss[11][4]:ss[11][4]+ss[11][5]];need(ss[11][5]==693 and ss[12][5]==78,'exact complete string extents');used_strings=set()
 for i,s in enumerate(symbols):
  n,v,z,info,other,sn=struct.unpack_from('<IIIBBH',raw,ss[10][4]+16*i);need(n<len(strings),'symbol string bounds');end=strings.index(b'\0',n);used_strings.update(range(n,end+1));name=strings[n:end].decode('ascii');need((name,v,z,info>>4,info&15,other,sn)==(s['name'],s['value'],s['size'],s['binding'],s['type'],s['other'],s['section']),'complete raw symbol');need(z==0 and info>>4==(0 if i<48 else 1)and other==0,'scope/visibility')
  if i==0:need((name,v,info,sn)==('',0,0,0),'null symbol')
  elif info&15==4:need((name,v,info,sn)==('MIPMAP.S',0,4,65521),'FILE identity')
  elif info&15==3:need((name,v,info,sn)==('',0,3,6),'CONST section identity')
  elif sn==65521:need(name in ABS and(v,info)==(ABS[name],0),'meaningful ABS')
  elif sn==0:need(name in IMPORTS and(v,info)==(0,16),'genuine undefined global')
  elif name in PUBLIC:need((sn,v,info)==(4,PUBLIC[name],16),'real public coordinate')
  elif name in LABELS:need((sn,v,info)==(4,LABELS[name],0),'real private branch coordinate')
  else:need((name,sn,v,info)==('channel_scale',6,0,0),'private scalar coordinate')
 need(used_strings==set(range(len(strings))),'all actual symbol-string bytes');section_strings=raw[ss[12][4]:ss[12][4]+ss[12][5]];used_sections=set()
 for row in ss:need(row[0]<len(section_strings),'section name bounds');end=section_strings.index(b'\0',row[0]);used_sections.update(range(row[0],end+1))
 need(used_sections==set(range(len(section_strings))),'all section-string bytes')
 need({s['name']:s['value']for s in symbols if s['type']!=4 and s['section']==65521}==ABS and sum(s['type']!=4 and s['section']==65521 for s in symbols)==30,'all30 actual ABS');need(sum(s['type']==3 for s in symbols)==1 and sum(s['type']==4 for s in symbols)==1,'complete structural symbols');need({s['name']for s in symbols if s['section']==0 and s['binding']==1}==IMPORTS and {s['name']for s in symbols if s['binding']==1 and 0<s['section']<65520}==set(PUBLIC),'complete public/import sets');need({s['name']for s in symbols if s['type']==0 and 0<s['section']<65520}==set(PUBLIC)|set(LABELS)|{'channel_scale'},'all17 qualified definitions');need(sec[6]['bytes']==logical['scale'],'source mathematical scalar bytes');rels=e['relocations'];need(len(rels)==10 and {r['offset']for r in rels}==set(REL),'all10 distinct fields')
 for i,r in enumerate(rels):
  off,info=struct.unpack_from('<II',raw,ss[5][4]+8*i);need((r['source_section'],r['offset'],r['type'],r['symbol']['index'])==(4,off,info&255,info>>8),'raw field');s=r['symbol'];name=s['name']if s['name']else names[s['section']];need((name,r['type'])==REL[off]and r['inline_signed']==(-4 if r['type']==2 else 0),'typed source target/addend');need(s['binding']==1 or(s['type'],s['section'])==(3,6),'field scope');need(name not in UNUSED,'unused imports need no fake references')
 rows={};pages=[]
 for line in listing.splitlines():
  if not line.strip():continue
  if line.startswith('GAS LISTING '):
   m=re.fullmatch(r'GAS LISTING (.+?)\s+page ([1-9][0-9]*)\s*',line);need(m and m[1].endswith('/MIPMAP.S')and int(m[2])==len(pages)+1,'listing header');pages.append(m[1]);continue
  if '\t'in line:
   lead,text=line.split('\t',1);a=lead.split();need(len(a)in(1,3)and a[0].isdigit(),'listing row');n=int(a[0]);need(1<=n<=len(logical['lines'])and n not in rows and text.rstrip()==logical['lines'][n-1].rstrip(),'exact listing source');rows[n]={'offset':int(a[1],16)if len(a)==3 else None,'data':bytes.fromhex(a[2])if len(a)==3 else b'','source':text.strip()}
  else:
   a=line.split();need(len(a)==2 and a[0].isdigit()and int(a[0])in rows,'listing continuation');rows[int(a[0])]['data']+=bytes.fromhex(a[1])
 need(set(rows)==set(range(1,len(logical['lines'])+1)),'every source line');current=None;lc={'_TEXT':0,'CONST':0};ops=0
 for row in rows.values():
  t=row['source'].partition('#')[0].strip()
  if t.startswith('.section '):current=t.split()[1].split(',')[0]
  if row['data']:
   need(current in lc and row['offset']==lc[current],'listing section/coordinate');data=bytes.fromhex(next(s['bytes']for s in sec if s['name']==current));need(row['data']==data[lc[current]:lc[current]+len(row['data'])],'all compiled bytes in listing');lc[current]+=len(row['data']);ops+=current=='_TEXT'
 need(lc=={'_TEXT':1133,'CONST':8}and ops==369,'all CODE/CONST bytes and369 instructions');return {'all13sections':True,'all57symbols':True,'all10fields':True,'all369_source_instruction_rows':True,'all15_private30ABS':True}

def coff(raw,e):
 need(len(raw)>=340,'COFF header');machine,count,timestamp,sp,nt,opt,flags=struct.unpack_from('<HHIIIHH',raw);need((machine,count,nt,opt,flags)==(332,8,58,0,0),'closed COFF header');start=sp+18*nt;need(start+4<=len(raw),'COFF symbol bounds');size=struct.unpack_from('<I',raw,start)[0];need(size>=4 and start+size==len(raw),'complete COFF strings');strings=raw[start:];used_strings=set(range(4));ranges=[(0,340),(sp,start),(start,len(raw))]
 def name(b):
  if b[:4]==bytes(4):
   i=struct.unpack_from('<I',b,4)[0];need(4<=i<len(strings)and b'\0'in strings[i:],'COFF name bounds');end=strings.index(b'\0',i);used_strings.update(range(i,end+1));return strings[i:end].decode('ascii')
  n=b.split(b'\0',1)[0];need(b==n.ljust(8,b'\0'),'short name padding');return n.decode('ascii')
 sections=[];en={s['name']:s for s in e['sections']};expected_names=list(SECTIONS)
 for i,n in enumerate(expected_names):
  hdr=raw[20+40*i:60+40*i];p,v,z,pos,rp,lp,nr,nl,attr=struct.unpack_from('<IIIIIIHHI',hdr,8);es=en[n];wanted=((0x60000020 if es['flags']&4 else 0xc0000080 if es['type']==8 else 0xc0000040)|({1:1,4:3,16:5}[es['align']]<<20));need((name(hdr[:8]),p,v,z,lp,nl,attr)==(n,0,0,es['size'],0,0,wanted),'all COFF section geometry/flags');rels=[r for r in e['relocations']if e['sections'][r['source_section']]['name']==n];need(nr==len(rels),'all COFF section relocations')
  if z and es['type']!=8:need(340<=pos and pos+z<=sp,'COFF backing');ranges.append((pos,pos+z));data=raw[pos:pos+z]
  else:need(pos==0,'no backed empty/BSS');data=b''
  if nr:need(340<=rp and rp+nr*10<=sp,'COFF relocation bounds');ranges.append((rp,rp+nr*10))
  else:need(rp==0,'empty COFF relocation pointer')
  sections.append({'index':i+1,'name':n,'size':z,'data':data.hex(),'flags':attr,'relocation_pointer':rp,'relocation_count':nr})
 ranges.sort();need(all(a[1]<=b[0]and not any(raw[a[1]:b[0]])for a,b in zip(ranges,ranges[1:])),'COFF overlap/unassigned bytes');symbols=[];i=0
 while i<nt:
  b=raw[sp+18*i:sp+18*(i+1)];value,section,type,cls,aux=struct.unpack_from('<IhHBB',b,8);need(i+aux<nt,'COFF auxiliary bounds');symbols.append({'index':i,'name':name(b[:8]),'value':value,'section':section,'type':type,'class':cls,'aux_count':aux,'aux':raw[sp+18*(i+1):sp+18*(i+1+aux)].hex()});i+=1+aux
 need(len(symbols)==56 and len({s['name']for s in symbols})==56,'all56 distinct COFF primary identities');by={s['name']:s for s in symbols};emap={s['index']:s['name']for s in e['sections']};cmap={s['name']:s['index']for s in sections};esymbols=[s for tab in e['symbols'].values()for s in tab];expected=set()
 for s in esymbols:
  if s['index']==0:continue
  n='.file'if s['type']==4 else emap[s['section']]if s['type']==3 else s['name'];expected.add(n);c=by[n]
  if s['type']==4:need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(0,-2,0,103,1)and bytes.fromhex(c['aux'])==b'MIPMAP.S'.ljust(18,b'\0'),'COFF FILE auxiliary')
  elif s['type']==3:
   es=en[emap[s['section']]];cs=sections[cmap[es['name']]-1];need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(0,cs['index'],0,3,1)and bytes.fromhex(c['aux'])==struct.pack('<IHHIhB3s',es['size'],cs['relocation_count'],0,0,0,0,bytes(3)),'COFF section auxiliary')
  else:
   section=0 if s['section']==0 else -1 if s['section']==65521 else cmap[emap[s['section']]];need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(s['value'],section,0,2 if s['binding']==1 else 3,0),'qualified COFF symbol/value/scope')
 need(set(by)==expected and used_strings==set(range(len(strings))),'exact COFF identities/all string bytes');idx={s['index']:s for s in symbols};relations=[]
 for sec in sections:
  es=en[sec['name']];data=bytes.fromhex(sec['data']);eb=bytes.fromhex(es['bytes']or'');rs=[r for r in e['relocations']if emap[r['source_section']]==sec['name']];covered={i for r in rs for i in range(r['offset'],r['offset']+4)};need(len(data)==len(eb)and all(a==b for i,(a,b)in enumerate(zip(data,eb))if i not in covered),'all nonfield ELF/COFF bytes')
  for j in range(sec['relocation_count']):
   off,sym,kind=struct.unpack_from('<IIH',raw,sec['relocation_pointer']+j*10);need(sym in idx,'COFF actual symbol index');c=idx[sym];r=next((r for r in rs if r['offset']==off),None);need(r is not None and kind==(20 if r['type']==2 else 6),'COFF field type/offset');s=r['symbol'];target=s['name']if s['name']else emap[s['section']];need(c['name']==target and c['value']==s['value']and c['class']==(2 if s['binding']==1 else 3),'COFF typed target identity');a=int.from_bytes(data[off:off+4],'little');need(a==(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff,'ELF/COFF addend plus4');relations.append({'offset':off,'name':target,'type':kind})
 need(len(relations)==10 and {r['offset']for r in relations}==set(REL),'all10 distinct COFF field relations');return {'timestamp':timestamp,'sections':sections,'symbols':symbols,'relations':relations,'private15_ABS30_retained':True}
def native(m,e,c):
 need(len(m.fixups)==10 and not(m.local_publics or m.local_externals),'complete native fields/scopes');names={s['index']:s['name']for s in e['sections']};fields={f.offset:f for f in m.fixups}
 for s in c['sections']:need(bytes(m._segment(s['index']).data)==bytes.fromhex(s['data']),'all COFF/native section bytes')
 for r in e['relocations']:
  f=fields[r['offset']];need((f.segment,f.width,f.location,f.relative,f.displacement)==(4,4,9,r['type']==2,0),'native typed source field');s=r['symbol'];a=int.from_bytes(m._segment(4).data[f.offset:f.offset+4],'little');need(a==(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff,'native PC32 convention')
  if s['binding']==1:need(f.target_method==2 and m.externals[f.target-1]==s['name']and(f.frame_method,f.frame)==(5,None),'genuine external/global field')
  else:need(f.target_method==0 and m._segment(f.target).name=='CONST'and f.frame_method==1 and m.groups[f.frame-1]==('FLAT',()),'private scalar section field')
 need(UNUSED<=set(m.externals),'genuine unused imports retained')
def roles(original,m,e):
 need(not(original.local_publics or original.local_externals or m.local_publics or m.local_externals),'zero original/runtime named private definitions');need(set(original.externals)==set(m.externals)==IMPORTS|{'FoldPixel_'},'all original import declarations');need({n:(original._segment(s).name,v)for n,(s,v)in original.publics.items()}=={n:(m._segment(s).name,v)for n,(s,v)in m.publics.items()},'actual public geometry');need(len(original.fixups)==len(m.fixups)==10,'whole original fields');fields={f.offset:f for f in m.fixups};out=[]
 for a in original.fixups:
  b=fields[a.offset];need((a.width,a.location,a.relative,a.displacement)==(b.width,b.location,b.relative,b.displacement)==(4,9,a.relative,0),'original typed geometry');name=original.externals[a.target-1]if a.target_method==2 else original._segment(a.target).name
  if a.target_method==2:need(b.target_method==2 and m.externals[b.target-1]==name and b.frame_method==5,'actual public/provider role')
  else:need(b.target_method==0 and original._segment(a.target).name==m._segment(b.target).name and b.frame_method==1 and m.groups[b.frame-1]==('FLAT',()),'actual constant role')
  need(int.from_bytes(original._segment(a.segment).data[a.offset:a.offset+4],'little')==int.from_bytes(m._segment(b.segment).data[b.offset:b.offset+4],'little'),'all source/original inline addends');out.append({'name':name,'original':dataclasses.asdict(a),'native':dataclasses.asdict(b),'source_equation':'same named E+A or same CONST section+A; PC32+4 translated exactly'})
 need(bytes(original._segment(1).data)==bytes(m._segment(4).data)and bytes(original._segment(2).data)==bytes(m._segment(5).data),'all raw source/original loadable bytes literal');return out

PRIMARY_HEADERS={'types.h': 'd00c4f7e2968f4315613558e1fb3a1b86f19a50cfd02b42a028cde436e298cf1', 'mipmap.h': 'f5ce65da6b66753700ced1f9a680760e536704a03e1b1f6cd1ccdb2ffb6a217d', 'clrmap.h': '20ff38f9a3e31d0657a75e064ad447900d7e5425bca19f7d297e82cd1600530d', 'develop.h': 'c862210f83facbfa543563d746fa561d9f8d94a251e98a4a470c6bd11e17f861', 'util_lib.h': 'c6d886338dc5559000ae7dcd244916f39668dbc13c82d6786af984085bb9e9cd'}
def headers(directory):
 from pathlib import Path
 import hashlib
 directory=Path(directory);need({p.name for p in directory.iterdir()if p.is_file()}==set(PRIMARY_HEADERS),'exact retained primary header graph')
 for n,h in PRIMARY_HEADERS.items():need(hashlib.sha256((directory/n).read_bytes()).hexdigest()==h,'unchanged primary API/type header '+n)
