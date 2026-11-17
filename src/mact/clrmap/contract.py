"""Finite CLRMAP ELF/raw symbol/REL scope; no general ELF admission."""
import struct, re, math, dataclasses
PUBLICS = {'HSV_TO_RGB_', 'RGB_TO_HSV_', 'GetDarkenedColor_', 'RGB_TO_YIQ_', 'YIQ_TO_RGB_', 'RGB_TO_XYZ_', 'XYZ_TO_RGB_', 'XYZ_TO_LUV_', 'LUV_TO_XYZ_', 'CMAP_BuildYIQPalette_', 'CMAP_GetBestColor_', 'CMAP_GetBestColorFast_', 'CMAP_GetBestYIQColor_', 'CMAP_BestColor_', 'CMAP_CreateFloatPalette_', 'CMAP_CalculateTranslucentMap_', 'CMAP_CalculateColorMap_', 'CMAP_CalculateLightMap_', 'CMAP_BuildColorMap_', 'CMAP_BuildMonochromeMap_', 'CMAP_GetIntensity_', 'CMAP_FindEGAColors_', '_egacolor'}
IMPORTS = {'__CHP', 'IF@DPOW', 'SafeMalloc_', 'SafeFree_', '_fltused_', '__init_387_emulator', '__8087'}
FEATURES = {'_fltused_', '__init_387_emulator', '__8087'}

def raw_elf(raw, e, source, model):
    need(raw[:16] == b'\x7fELF\x01\x01\x01' + bytes(9), 'closed CLRMAP raw ELF/schema')
    h = struct.unpack_from('<HHIIIIIHHHHHH', raw, 16)
    need((h[0], h[1], h[2], h[3], h[4], h[6], h[7], h[8], h[9], h[10], h[11], h[12]) == (1, 3, 1, 0, 0, 0, 52, 0, 0, 40, 13, 12), 'closed CLRMAP raw ELF/schema')
    need(h[5] + 13 * 40 == len(raw), 'closed CLRMAP raw ELF/schema')
    ss = [struct.unpack_from('<IIIIIIIIII', raw, h[5] + 40 * i) for i in range(13)]
    need(ss[0] == (0,) * 10, 'closed CLRMAP raw ELF/schema')
    strings = raw[ss[12][4]:ss[12][4] + ss[12][5]]
    names = [strings[s[0]:strings.index(b'\x00', s[0])].decode('ascii') for s in ss]
    need(names == ['', '.text', '.data', '.bss', '_TEXT', '.rel_TEXT', 'CONST', 'CONST2', '_DATA', '_BSS', '.symtab', '.strtab', '.shstrtab'], 'closed CLRMAP raw ELF/schema')
    need(names == [s['name'] for s in e['sections']], 'closed CLRMAP raw ELF/schema')
    expected = {1: (1, 6, 0, 1, 0), 2: (1, 3, 0, 1, 0), 3: (8, 3, 0, 1, 0), 4: (1, 6, 4711, 16, 0), 5: (9, 64, 960, 4, 8), 6: (1, 3, 624, 4, 0), 7: (1, 3, 0, 4, 0), 8: (1, 3, 48, 4, 0), 9: (8, 3, 16, 16, 0), 10: (2, 0, 3264, 4, 16), 11: (3, 0, 4076, 1, 0), 12: (3, 0, 78, 1, 0)}
    ranges = [(0, 52), (h[5], len(raw))]
    for i, s in enumerate(ss[1:], 1):
        need((s[1], s[2], s[5], s[8], s[9]) == expected[i], 'closed section schema')
        need(s[3] == 0, 'closed CLRMAP raw ELF/schema')
        if i == 5:
            need((s[6], s[7]) == (10, 4), 'closed CLRMAP raw ELF/schema')
        elif i == 10:
            need((s[6], s[7]) == (11, 174), 'closed CLRMAP raw ELF/schema')
        else:
            need((s[6], s[7]) == (0, 0), 'closed CLRMAP raw ELF/schema')
        need(52 <= s[4] <= h[5] and (s[1] == 8 or s[4] + s[5] <= h[5]), 'closed CLRMAP raw ELF/schema')
        if s[1] != 8 and s[5]:
            ranges.append((s[4], s[4] + s[5]))
    ranges.sort()
    need(all((a[1] <= b[0] for a, b in zip(ranges, ranges[1:]))), 'closed CLRMAP raw ELF/schema')
    need(all((not any(raw[a[1]:b[0]]) for a, b in zip(ranges, ranges[1:]))), 'closed CLRMAP raw ELF/schema')
    constants = {}
    for n, v in model.BIT_CONSTANTS.items():
        bits = struct.unpack('<Q', struct.pack('<d', v))[0]
        constants[n + '_LO'] = bits & 4294967295
        constants[n + '_HI'] = bits >> 32
    constants.update({'EGA_DARK': 87, 'EGA_MID': 171, 'EGA_FULL': 255})
    labels = {t[:-1] for line in source.splitlines() if (t := line.partition('#')[0].strip()).endswith(':')}
    labels.update((n for n, v in model.CONSTANTS))
    need(len(labels) == 177, 'closed CLRMAP raw ELF/schema')
    tab = e['symbols'].get(10, e['symbols'].get('10'))
    need(len(tab) == 204, 'closed CLRMAP raw ELF/schema')
    st = raw[ss[11][4]:ss[11][4] + ss[11][5]]
    symbols = []
    for i in range(204):
        n, v, z, info, other, sec = struct.unpack_from('<IIIBBH', raw, ss[10][4] + 16 * i)
        need(n < len(st), 'closed CLRMAP raw ELF/schema')
        name = st[n:st.index(b'\x00', n)].decode('ascii')
        a = tab[i]
        need((name, v, z, info >> 4, info & 15, other, sec) == (a['name'], a['value'], a['size'], a['binding'], a['type'], a['other'], a['section']), 'closed CLRMAP raw ELF/schema')
        need(z == 0 and info >> 4 in (0, 1) and (info & 15 in (0, 3, 4)) and (other == 0) and (sec != 65522), 'closed CLRMAP raw ELF/schema')
        need(info >> 4 == (0 if i < 174 else 1), 'closed CLRMAP raw ELF/schema')
        if info & 15 == 4:
            need((name, v, info >> 4, sec) == ('CLRMAP.S', 0, 0, 65521), 'closed CLRMAP raw ELF/schema')
        elif info & 15 == 3:
            need(name == '' and v == 0 and (sec in (4, 6, 8)) and (info >> 4 == 0), 'closed CLRMAP raw ELF/schema')
        elif sec == 65521:
            need(name in constants and v == constants[name] and (info >> 4 == 0), 'closed CLRMAP raw ELF/schema')
        elif sec == 0:
            need(i == 0 and (name, v, info) == ('', 0, 0) or (name in IMPORTS and (v, info) == (0, 16)), 'closed CLRMAP raw ELF/schema')
        else:
            need(name in labels and sec in (4, 6, 8, 9) and (v <= ss[sec][5]) and (info >> 4 == (1 if name in PUBLICS else 0)), 'closed CLRMAP raw ELF/schema')
        symbols.append(a)
    need({a['name'] for a in symbols if a['binding'] == 1 and a['section'] > 0} == PUBLICS, 'closed CLRMAP raw ELF/schema')
    need({a['name'] for a in symbols if a['binding'] == 1 and a['section'] == 0} == IMPORTS, 'closed CLRMAP raw ELF/schema')
    need(len([a for a in symbols if a['binding'] == 0 and a['type'] == 0 and (0 < a['section'] < 65520)]) == 154, 'closed CLRMAP raw ELF/schema')
    byname = {a['name']: a for a in symbols if a['name']}
    need((byname['_egargb']['section'], byname['_egargb']['value'], byname['_egargb']['binding']) == (8, 0, 0), 'closed CLRMAP raw ELF/schema')
    need((byname['_egacolor']['section'], byname['_egacolor']['value'], byname['_egacolor']['binding']) == (9, 0, 1), 'closed CLRMAP raw ELF/schema')
    for j, (name, value) in enumerate(model.CONSTANTS):
        need((byname[name]['section'], byname[name]['value'], byname[name]['binding']) == (6, j * 8, 0), 'closed CLRMAP raw ELF/schema')
    seen = set()
    count = 0
    for i in range(120):
        off, info = struct.unpack_from('<II', raw, ss[5][4] + 8 * i)
        idx, kind = (info >> 8, info & 255)
        need(idx < 204 and kind in (1, 2) and (off + 4 <= 4711), 'closed CLRMAP raw ELF/schema')
        need(symbols[idx]['section'] != 65521, 'closed CLRMAP raw ELF/schema')
        need(not seen.intersection(range(off, off + 4)), 'closed CLRMAP raw ELF/schema')
        seen.update(range(off, off + 4))
        r = next((r for r in e['relocations'] if r['offset'] == off))
        need((r['source_section'], r['type'], r['symbol']['index']) == (4, kind, idx), 'closed CLRMAP raw ELF/schema')
        count += 1
    need(count == 120, 'closed CLRMAP raw ELF/schema')
    return {'all13_raw_section_schemas': True, 'all204_raw_symbol_entries': True, 'all120_raw_REL_fields': True, 'genuine_FPU3_undefined_declarations': True, 'all154_runtime_private_and15_word_ABS_identities': True, 'no_COMMON_weak_TLS_hidden_or_ABS_relocation': True}
def need(ok,why):
 if not ok:raise ValueError("CLRMAP "+str(why))


def coff(raw,e):
 need(len(raw)>=340,'COFF header');machine,count,timestamp,sp,nt,opt,flags=struct.unpack_from('<HHIIIHH',raw);need((machine,count,nt,opt,flags)==(332,8,207,0,0),'closed COFF header');start=sp+18*nt;need(start+4<=len(raw),'COFF symbol bounds');size=struct.unpack_from('<I',raw,start)[0];need(size>=4 and start+size==len(raw),'complete COFF strings');strings=raw[start:];used_strings=set(range(4));ranges=[(0,340),(sp,start),(start,len(raw))]
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
 need(len(symbols)==203 and len({s['name']for s in symbols})==203,'all203 distinct COFF primary identities');by={s['name']:s for s in symbols};emap={s['index']:s['name']for s in e['sections']};cmap={s['name']:s['index']for s in sections};esymbols=[s for tab in e['symbols'].values()for s in tab];expected=set()
 for s in esymbols:
  if s['index']==0:continue
  n='.file'if s['type']==4 else emap[s['section']]if s['type']==3 else s['name'];expected.add(n);c=by[n]
  if s['type']==4:need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(0,-2,0,103,1)and bytes.fromhex(c['aux'])==b'CLRMAP.S'.ljust(18,b'\0'),'COFF FILE auxiliary')
  elif s['type']==3:
   es=en[emap[s['section']]];cs=sections[cmap[es['name']]-1];need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(0,cs['index'],0,3,1)and bytes.fromhex(c['aux'])==struct.pack('<IHHIhB3s',es['size'],cs['relocation_count'],0,0,0,0,bytes(3)),'COFF section auxiliary')
  else:
   section=0 if s['section']==0 else -1 if s['section']==65521 else cmap[emap[s['section']]];need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(s['value'],section,0,2 if s['binding']==1 else 3,0),'qualified COFF symbol/value/scope')
 need(set(by)==expected and used_strings==set(range(len(strings))),'exact COFF identities/all string bytes');idx={s['index']:s for s in symbols};relations=[]
 for sec in sections:
  es=en[sec['name']];data=bytes.fromhex(sec['data']);eb=bytes.fromhex(es['bytes']or'');rs=[r for r in e['relocations']if emap[r['source_section']]==sec['name']];covered={i for r in rs for i in range(r['offset'],r['offset']+4)};need(len(data)==len(eb)and all(a==b for i,(a,b)in enumerate(zip(data,eb))if i not in covered),'all nonfield ELF/COFF bytes')
  for j in range(sec['relocation_count']):
   off,sym,kind=struct.unpack_from('<IIH',raw,sec['relocation_pointer']+j*10);need(sym in idx,'COFF actual symbol index');c=idx[sym];r=next((r for r in rs if r['offset']==off),None);need(r is not None and kind==(20 if r['type']==2 else 6),'COFF field type/offset');s=r['symbol'];target=s['name']if s['name']else emap[s['section']];need(c['name']==target and c['value']==s['value']and c['class']==(2 if s['binding']==1 else 3),'COFF typed target identity');a=int.from_bytes(data[off:off+4],'little');need(a==(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff,'ELF/COFF addend plus4');relations.append({'offset':off,'name':target,'type':kind})
 need(len(relations)==120 and {r['offset']for r in relations}=={r['offset']for r in e['relocations']},'all120 distinct COFF field relations');return {'timestamp':timestamp,'sections':sections,'symbols':symbols,'relations':relations,'private154_ABS15_retained':True}

PRIMARY_HEADERS={'_clrmap.h': '722ee2385bc712fc40f6d50c0eb70163a67f9b34cc8cfa671105310c605d7395', 'util_lib.h': 'c6d886338dc5559000ae7dcd244916f39668dbc13c82d6786af984085bb9e9cd', 'types.h': 'd00c4f7e2968f4315613558e1fb3a1b86f19a50cfd02b42a028cde436e298cf1', 'clrmap.h': '20ff38f9a3e31d0657a75e064ad447900d7e5425bca19f7d297e82cd1600530d', 'develop.h': 'c862210f83facbfa543563d746fa561d9f8d94a251e98a4a470c6bd11e17f861'}
SECTIONS={'.text': (0, 1, 6, 1), '.data': (0, 1, 3, 1), '.bss': (0, 8, 3, 1), '_TEXT': (4711, 1, 6, 16), 'CONST': (624, 1, 3, 4), 'CONST2': (0, 1, 3, 4), '_DATA': (48, 1, 3, 4), '_BSS': (16, 8, 3, 16)}
UNUSED=FEATURES
TABLE=['hsv_sector_red_yellow','hsv_sector_yellow_green','hsv_sector_green_cyan','hsv_sector_cyan_blue','hsv_sector_blue_magenta','hsv_sector_magenta_red']
def headers(directory):
 from pathlib import Path
 import hashlib
 directory=Path(directory);need({p.name for p in directory.iterdir()if p.is_file()}==set(PRIMARY_HEADERS),'exact primary header graph')
 for n,h in PRIMARY_HEADERS.items():need(hashlib.sha256((directory/n).read_bytes()).hexdigest()==h,'primary header '+n)
def model(m):
 need(type(m.CONSTANTS)is list and len(m.CONSTANTS)==78 and len({n for n,v in m.CONSTANTS})==78,'78 distinct real scalar owners')
 need(all(re.fullmatch('[a-z][a-z0-9_]*',n)and type(v)in(int,float)and math.isfinite(v)for n,v in m.CONSTANTS),'named finite binary64 scalars')
 need(set(m.BIT_CONSTANTS)=={'HUE_CIRCLE_BITS','FP_ONE_BITS','UNDEFINED_HUE_BITS','LUV_WHITE_U_BITS','DISTORTION_BOUND_BITS','LIGHTNESS_MAX_BITS'}and all(type(v)in(int,float)and math.isfinite(v)for v in m.BIT_CONSTANTS.values()),'six real floating immediate views')
 need(m.generate()=='\n'.join(['# Genuine named binary64 literals; each role follows the readable color aid.']+[x for n,v in m.CONSTANTS for x in(n+':','.double '+repr(v))])+'\n','generated named scalar source')
 want=[]
 for n,v in m.BIT_CONSTANTS.items():
  bits=struct.unpack('<Q',struct.pack('<d',v))[0];want+=['.equ '+n+'_LO, '+hex(bits&0xffffffff),'.equ '+n+'_HI, '+hex(bits>>32)]
 need(m.bit_constants()=='\n'.join(want)+'\n','typed low/high floating views')
def source(text,m):
 labels=[];public=set();imports=set();sections=[];ops=[];palette=[];current=None;absval={};table=[]
 for line in text.splitlines():
  t=line.partition('#')[0].strip()
  if not t:continue
  need(';'not in t and not re.search(r'\b(?:incbin|org|db|dw|dd|dq)\b',t,re.I),'ordinary source/no opaque payload')
  if re.match(r'^[A-Za-z_][A-Za-z_0-9]*:',t):
   n,t=t.split(':',1);need(n not in labels,'duplicate definition');labels.append(n);t=t.strip()
   if not t:continue
  if t.startswith('.'):
   if t.startswith('.section '):current=t.split()[1].split(',')[0];sections.append(t)
   elif t.startswith('.globl '):public.add(t[7:].strip('"'))
   elif t.startswith('.extern '):imports.add(t[8:].strip('"'))
   elif t.startswith('.long '):need(current=='_TEXT'and not table,'single genuine CS table');table=t[6:].split(',')
   elif t.startswith('.byte '):need(current=='_DATA','palette only');palette.append(t[6:])
   elif t.startswith('.equ '):n,v=t[5:].split(',',1);need(n not in absval,'duplicate ABS');absval[n]=int(v,0)
   else:need(t in ['.intel_syntax noprefix','.code32','.file "CLRMAP.S"','.include "COLOR_BITS.INC"','.include "COLOR_CONSTANTS.INC"','.p2align 4','.p2align 2','.zero 16'],'closed source directives')
  else:need(current=='_TEXT','CODE instructions only');ops.append(t)
 need(public==PUBLICS|IMPORTS and imports==IMPORTS,'public/import source scope');need(len(labels)==99 and len(set(labels)|{n for n,v in m.CONSTANTS})==177,'all177 actual definitions');need(sections==['.section _TEXT,"ax",@progbits','.section CONST,"aw",@progbits','.section CONST2,"aw",@progbits','.section _DATA,"aw",@progbits','.section _BSS,"aw",@nobits'],'closed source sections');need(sum(t.partition('#')[0].strip()=='.zero 16'for t in text.splitlines())==1,'one real BSS declaration');need(table==TABLE and len(ops)==1568 and len(palette)==16 and absval=={'EGA_DARK':87,'EGA_MID':171,'EGA_FULL':255},'full typed table/instructions/palette')
 flat=[]
 for i,line in enumerate(text.splitlines(),1):
  flat.append((i,line))
  if line.strip()=='.include "COLOR_BITS.INC"':flat.extend(enumerate(m.bit_constants().splitlines(),1))
  if line.strip()=='.include "COLOR_CONSTANTS.INC"':flat.extend(enumerate(m.generate().splitlines(),1))
 return {'lines':text.splitlines(),'flat_lines':flat,'labels':labels+[n for n,v in m.CONSTANTS],'instructions':len(ops),'table':table}
def elf(raw,e,logical,text,m,listing):
 out=raw_elf(raw,e,text,m);symbols=[s for t in e['symbols'].values()for s in t]
 h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);ss=[struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*i)for i in range(13)]
 for idx,offsets in [(11,[struct.unpack_from('<I',raw,ss[10][4]+16*i)[0]for i in range(204)]),(12,[row[0]for row in ss])]:
  pool=raw[ss[idx][4]:ss[idx][4]+ss[idx][5]];used=set()
  for off in offsets:need(off<len(pool)and b'\0'in pool[off:],'string bounds');used.update(range(off,pool.index(b'\0',off)+1))
  need(used==set(range(len(pool))),'all actual string bytes accounted')
 absolute={'EGA_DARK':87,'EGA_MID':171,'EGA_FULL':255}
 for n,v in m.BIT_CONSTANTS.items():
  bits=struct.unpack('<Q',struct.pack('<d',v))[0];absolute[n+'_LO']=bits&0xffffffff;absolute[n+'_HI']=bits>>32
 need({s['name']:s['value']for s in symbols if s['type']==0 and s['section']==65521}==absolute and sum(s['type']==0 and s['section']==65521 for s in symbols)==15,'all15 distinct meaningful ABS')
 defs={s['name']:s for s in symbols if s['type']==0 and 0<s['section']<65520};need(set(defs)==set(logical['labels'])and len(defs)==177,'all distinct source definitions');need(sum(s['type']==4 for s in symbols)==1 and sum(s['type']==3 for s in symbols)==3,'structural symbols exact')
 rows=[];pages=0
 for line in listing.splitlines():
  if not line.strip():continue
  if line.startswith('GAS LISTING '):
   z=re.fullmatch(r'GAS LISTING (.+?)\s+page ([1-9][0-9]*)\s*',line);need(z and z[1].endswith('/CLRMAP.S')and int(z[2])==pages+1,'listing page');pages+=1;continue
  if '\t'in line:
   lead,src=line.split('\t',1);a=lead.split();need(len(a)in(1,3)and a[0].isdigit(),'listing row');rows.append({'line':int(a[0]),'offset':int(a[1],16)if len(a)==3 else None,'data':bytes.fromhex(a[2])if len(a)==3 else b'','source':src})
  else:
   a=line.split();need(len(a)==2 and rows and int(a[0])==rows[-1]['line'],'listing continuation');rows[-1]['data']+=bytes.fromhex(a[1])
 need(len(rows)==len(logical['flat_lines']),'every main/include source line');current=None;lc={n:0 for n in ['_TEXT','CONST','CONST2','_DATA','_BSS']};opcount=0;definitions=set();en={s['name']:s for s in e['sections']};section_ids={s['name']:s['index']for s in e['sections']}
 for row,(n,line)in zip(rows,logical['flat_lines']):
  need(row['line']==n and(row['source'].rstrip()==line.rstrip()or(line.startswith('.long ')and row['source']==line[:99])),'exact source/listing association');t=line.partition('#')[0].strip()
  if t.startswith('.section '):current=t.split()[1].split(',')[0]
  if t.endswith(':'):
   name=t[:-1];need(name in defs and(defs[name]['section'],defs[name]['value'])==(section_ids[current],lc[current]),'qualified source label coordinate');definitions.add(name)
  data=row['data']
  if data:
   need(current in lc and row['offset']==lc[current],'listing logical coordinate');count=len(data)
   if t.startswith('.long '):
    full=b''.join(struct.pack('<I',defs[name]['value'])for name in TABLE);need(data==full[:len(data)]and len(data)==20,'visible six-word table listing prefix');data=full;count=24
   if current=='_BSS':need(t.startswith('.zero 16')and count==16 and not any(data),'real zero BSS')
   else:need(data==bytes.fromhex(en[current]['bytes'])[lc[current]:lc[current]+count],'all listing/native bytes')
   lc[current]+=count;opcount+=current=='_TEXT'and not t.startswith('.long ')
 need(lc=={'_TEXT':4711,'CONST':624,'CONST2':0,'_DATA':48,'_BSS':16}and opcount==1568 and definitions==set(defs),'complete source/listing ownership');need(bytes.fromhex(en['CONST']['bytes'])==b''.join(struct.pack('<d',v)for n,v in m.CONSTANTS),'all named model doubles');out.update({'all1568_instruction_rows':True,'all177_qualified_source_definitions':True,'all_include_source_lines':True});return out

def native(m,e,c):
 need(len(m.fixups)==120 and not(m.local_publics or m.local_externals),'native fields/scopes');names={s['index']:s['name']for s in e['sections']};mi={s.name:i for i,s in enumerate(m.segments,1)};fields={(f.segment,f.offset):f for f in m.fixups}
 for s in c['sections']:
  ms=m._segment(s['index']);need(ms.name==s['name']and bytes(ms.data)==(bytes(ms.size)if s['name']=='_BSS'else bytes.fromhex(s['data'])),'all COFF/native section bytes')
 for r in e['relocations']:
  f=fields[(mi[names[r['source_section']]],r['offset'])];need((f.width,f.location,f.relative,f.displacement)==(4,9,r['type']==2,0),'native typed field');s=r['symbol'];a=int.from_bytes(m._segment(f.segment).data[f.offset:f.offset+4],'little');need(a==(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff,'native PC32 translation')
  if s['binding']==1:need(f.target_method==2 and m.externals[f.target-1]==s['name']and(f.frame_method,f.frame)==(5,None),'actual global E+A')
  else:need(f.target_method==0 and m._segment(f.target).name==names[s['section']]and f.frame_method==1 and m.groups[f.frame-1]==('FLAT',()),'private section+V+A')
 need(UNUSED<=set(m.externals)and not any(m.externals[f.target-1]in UNUSED for f in m.fixups if f.target_method==2),'three unused import obligations')
def roles(original,m,e):
 need(original.local_publics=={'_egargb'}and len(original.local_externals)==1 and not(m.local_publics or m.local_externals),'genuine original private correspondence');names={s.name:i for i,s in enumerate(m.segments,1)};need({n:(original._segment(s).name,v)for n,(s,v)in original.publics.items()if n not in original.local_publics}=={n:(m._segment(s).name,v)for n,(s,v)in m.publics.items()},'all real public geometry');need(set(original.externals)-original.local_publics==set(m.externals),'complete imports');need(len(original.fixups)==len(m.fixups)==120,'all original fields');fields={(f.segment,f.offset):f for f in m.fixups};out=[];private=0;table=[]
 for os in original.segments:need(bytes(os.data)==bytes(m._segment(names[os.name]).data),'all raw original section bytes')
 for a in original.fixups:
  b=fields[(names[original._segment(a.segment).name],a.offset)];need((a.width,a.location,a.relative,a.displacement)==(b.width,b.location,b.relative,b.displacement)==(4,9,a.relative,0),'all typed original geometry');name=original.externals[a.target-1]if a.target_method==2 else original._segment(a.target).name
  if name=='_egargb':need(b.target_method==0 and m._segment(b.target).name=='_DATA'and b.frame_method==1,'qualified private palette role');private+=1
  elif a.target_method==2:need(b.target_method==2 and m.externals[b.target-1]==name and b.frame_method==5,'actual public/provider role')
  else:need(b.target_method==0 and original._segment(a.target).name==m._segment(b.target).name and b.frame_method==1,'actual section role')
  out.append({'name':name,'original':dataclasses.asdict(a),'native':dataclasses.asdict(b)})
 for off in range(0,24,4):
  f=fields[(4,off)];need(not f.relative and f.target_method==0 and f.target==4,'real CS dispatch word');table.append({'field':off,'native':dataclasses.asdict(f)})
 need(private==3 and fields[(4,202)].target_method==0 and fields[(4,202)].target==4,'private3/CS table reference');return {'roles':out,'private_references':private,'table':table}
