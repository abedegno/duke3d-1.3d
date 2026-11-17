"""Closed ELF32 LBM fixture schema; neither parser nor global admission."""
import struct, re
PUBLICS = {'Align_', 'LBMRLEDecompress_', 'MungeBitPlanes_', 'LoadLBM_', 'SaveLBM_'}
IMPORTS = {'memset_', 'Error_', 'MotoLong_', 'MotoShort_'}
CONSTANTS = {'FORMID': 1297239878, 'ILBMID': 1296190537, 'PBMID': 541934160, 'BMHDID': 1145589058, 'BODYID': 1497648962, 'CMAPID': 1346456899, 'BPLANESIZE': 128, 'PALETTE_BYTES': 768, 'BMHD_BYTES': 20, 'MAX_BITMAP_WIDTH': 320, 'MAX_BITMAP_HEIGHT': 200}

def raw_elf(raw, e, source):
    need(raw[:16] == b'\x7fELF\x01\x01\x01' + bytes(9), 'closed LBMLIB raw ELF/schema')
    h = struct.unpack_from('<HHIIIIIHHHHHH', raw, 16)
    need((h[0], h[1], h[2], h[3], h[4], h[6], h[7], h[8], h[9], h[10], h[11], h[12]) == (1, 3, 1, 0, 0, 0, 52, 0, 0, 40, 13, 12), 'closed LBMLIB raw ELF/schema')
    need(h[5] + 13 * 40 == len(raw), 'closed LBMLIB raw ELF/schema')
    ss = [struct.unpack_from('<IIIIIIIIII', raw, h[5] + 40 * i) for i in range(13)]
    need(ss[0] == (0,) * 10, 'closed LBMLIB raw ELF/schema')
    strings = raw[ss[12][4]:ss[12][4] + ss[12][5]]
    names = [strings[s[0]:strings.index(b'\x00', s[0])].decode('ascii') for s in ss]
    need(names == ['', '.text', '.data', '.bss', '_TEXT', '.rel_TEXT', 'CONST', 'CONST2', '_DATA', '_BSS', '.symtab', '.strtab', '.shstrtab'] and names == [s['name'] for s in e['sections']], 'closed LBMLIB raw ELF/schema')
    expected = {1: (1, 6, 0, 1, 0), 2: (1, 3, 0, 1, 0), 3: (8, 3, 0, 1, 0), 4: (1, 6, 1797, 16, 0), 5: (9, 64, 264, 4, 8), 6: (1, 3, 126, 4, 0), 7: (1, 3, 0, 4, 0), 8: (1, 3, 0, 4, 0), 9: (8, 3, 1152, 16, 0), 10: (2, 0, 1088, 4, 16), 11: (3, 0, 934, 1, 0), 12: (3, 0, 78, 1, 0)}
    ranges = [(0, 52), (h[5], len(raw))]
    for i, s in enumerate(ss[1:], 1):
        need((s[1], s[2], s[5], s[8], s[9]) == expected[i] and s[3] == 0, 'closed section schema')
        if i == 5:
            need((s[6], s[7]) == (10, 4), 'closed LBMLIB raw ELF/schema')
        elif i == 10:
            need((s[6], s[7]) == (11, 59), 'closed LBMLIB raw ELF/schema')
        else:
            need((s[6], s[7]) == (0, 0), 'closed LBMLIB raw ELF/schema')
        need(52 <= s[4] <= h[5] and (s[1] == 8 or s[4] + s[5] <= h[5]), 'closed LBMLIB raw ELF/schema')
        if s[1] != 8 and s[5]:
            ranges.append((s[4], s[4] + s[5]))
    ranges.sort()
    need(all((a[1] <= b[0] for a, b in zip(ranges, ranges[1:]))), 'closed LBMLIB raw ELF/schema')
    need(all((not any(raw[a[1]:b[0]]) for a, b in zip(ranges, ranges[1:]))), 'closed LBMLIB raw ELF/schema')
    labels = {t[:-1] for line in source.splitlines() if (t := line.partition('#')[0].strip()).endswith(':')}
    need(len(labels) == 49, 'closed LBMLIB raw ELF/schema')
    for line in source.splitlines():
        t = line.partition('#')[0].strip()
        if t.startswith('.'):
            need(t.startswith(('.intel_syntax ', '.code32', '.file ', '.extern ', '.globl ', '.equ ', '.section ', '.p2align ', '.asciz ', '.zero ')), 'unsupported source directive')
            if t.startswith('.globl '):
                need(t[7:] in PUBLICS | IMPORTS, 'private export forbidden')
            if t.startswith('.zero '):
                need(t == '.zero 9*BPLANESIZE', 'closed LBMLIB raw ELF/schema')
    tab = e['symbols'].get(10, e['symbols'].get('10'))
    need(len(tab) == 68, 'closed LBMLIB raw ELF/schema')
    st = raw[ss[11][4]:ss[11][4] + ss[11][5]]
    symbols = []
    for i in range(68):
        n, v, z, info, other, sec = struct.unpack_from('<IIIBBH', raw, ss[10][4] + 16 * i)
        need(n < len(st), 'closed LBMLIB raw ELF/schema')
        name = st[n:st.index(b'\x00', n)].decode('ascii')
        a = tab[i]
        need((name, v, z, info >> 4, info & 15, other, sec) == (a['name'], a['value'], a['size'], a['binding'], a['type'], a['other'], a['section']), 'closed LBMLIB raw ELF/schema')
        need(z == 0 and info >> 4 in (0, 1) and (info & 15 in (0, 3, 4)) and (other == 0) and (sec != 65522), 'closed LBMLIB raw ELF/schema')
        need(info >> 4 == (0 if i < 59 else 1), 'closed LBMLIB raw ELF/schema')
        if info & 15 == 4:
            need((name, v, info >> 4, sec) == ('LBMLIB.S', 0, 0, 65521), 'closed LBMLIB raw ELF/schema')
        elif info & 15 == 3:
            need(name == '' and v == 0 and (sec in (4, 6, 9)) and (info >> 4 == 0), 'closed LBMLIB raw ELF/schema')
        elif sec == 65521:
            need(name in CONSTANTS and v == CONSTANTS[name] and (info >> 4 == 0), 'closed LBMLIB raw ELF/schema')
        elif sec == 0:
            need(i == 0 and (name, v, info) == ('', 0, 0) or (name in IMPORTS and (v, info) == (0, 16)), 'closed LBMLIB raw ELF/schema')
        else:
            need(name in labels and sec in (4, 6, 9) and (v < ss[sec][5]) and (info >> 4 == (1 if name in PUBLICS else 0)), 'closed LBMLIB raw ELF/schema')
        symbols.append(a)
    need({a['name'] for a in symbols if a['binding'] == 1 and a['section'] > 0} == PUBLICS, 'closed LBMLIB raw ELF/schema')
    need({a['name'] for a in symbols if a['binding'] == 1 and a['section'] == 0} == IMPORTS, 'closed LBMLIB raw ELF/schema')
    priv = next((a for a in symbols if a['name'] == '_bitplanes'))
    need((priv['binding'], priv['section'], priv['value']) == (0, 9, 0), 'closed LBMLIB raw ELF/schema')
    seen = set()
    for i in range(33):
        off, info = struct.unpack_from('<II', raw, ss[5][4] + 8 * i)
        idx, kind = (info >> 8, info & 255)
        need(idx < 68 and kind in (1, 2) and (off + 4 <= 1797) and (symbols[idx]['section'] != 65521), 'closed LBMLIB raw ELF/schema')
        need(not seen.intersection(range(off, off + 4)), 'closed LBMLIB raw ELF/schema')
        seen.update(range(off, off + 4))
        r = next((r for r in e['relocations'] if r['offset'] == off))
        need((r['source_section'], r['type'], r['symbol']['index']) == (4, kind, idx), 'closed LBMLIB raw ELF/schema')
    return {'all13_raw_sections': True, 'all68_raw_symbols': True, 'all33_raw_REL_fields': True, 'all49_real_source_label_identities': True, 'all11_named_ABS_identities': True, 'no_COMMON_weak_TLS_hidden_ABS_relocation': True, 'private_bitplanes_no_export': True}
def need(ok,why):
 if not ok:raise ValueError("LBMLIB "+str(why))

import ast,dataclasses
SECTIONS={'.text': (0, 1, 6, 1), '.data': (0, 1, 3, 1), '.bss': (0, 8, 3, 1), '_TEXT': (1797, 1, 6, 16), 'CONST': (126, 1, 3, 4), 'CONST2': (0, 1, 3, 4), '_DATA': (0, 1, 3, 4), '_BSS': (1152, 8, 3, 16)}
PRIMARY_HEADERS={'UTIL_LIB.H': 'c6d886338dc5559000ae7dcd244916f39668dbc13c82d6786af984085bb9e9cd', 'TYPES.H': 'd00c4f7e2968f4315613558e1fb3a1b86f19a50cfd02b42a028cde436e298cf1', '_LBMLIB.H': '22562eab64758c823be2c8a17661d05423daf0115c337373640fefc63b8e2f29', 'LBMLIB.H': '4cbc7102a326a9c3fe5552fd3e843926db2477b7aeb58787fd4bf5d944dae00f'}
UNUSED=set()
def coff(raw,e):
 need(len(raw)>=340,'COFF header');machine,count,timestamp,sp,nt,opt,flags=struct.unpack_from('<HHIIIHH',raw);need((machine,count,nt,opt,flags)==(332,8,70,0,0),'closed COFF header');start=sp+18*nt;need(start+4<=len(raw),'COFF symbol bounds');size=struct.unpack_from('<I',raw,start)[0];need(size>=4 and start+size==len(raw),'complete COFF strings');strings=raw[start:];used_strings=set(range(4));ranges=[(0,340),(sp,start),(start,len(raw))]
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
 need(len(symbols)==67 and len({s['name']for s in symbols})==67,'all67 distinct COFF primary identities');by={s['name']:s for s in symbols};emap={s['index']:s['name']for s in e['sections']};cmap={s['name']:s['index']for s in sections};esymbols=[s for tab in e['symbols'].values()for s in tab];expected=set()
 for s in esymbols:
  if s['index']==0:continue
  n='.file'if s['type']==4 else emap[s['section']]if s['type']==3 else s['name'];expected.add(n);c=by[n]
  if s['type']==4:need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(0,-2,0,103,1)and bytes.fromhex(c['aux'])==b'LBMLIB.S'.ljust(18,b'\0'),'COFF FILE auxiliary')
  elif s['type']==3:
   es=en[emap[s['section']]];cs=sections[cmap[es['name']]-1];need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(0,cs['index'],0,3,1)and bytes.fromhex(c['aux'])==struct.pack('<IHHIhB3s',es['size'],cs['relocation_count'],0,0,0,0,bytes(3)),'COFF section auxiliary')
  else:
   section=0 if s['section']==0 else -1 if s['section']==65521 else cmap[emap[s['section']]];need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(s['value'],section,0,2 if s['binding']==1 else 3,0),'qualified COFF symbol/value/scope')
 need(set(by)==expected and used_strings==set(range(len(strings))),'exact COFF identities/all string bytes');idx={s['index']:s for s in symbols};relations=[]
 for sec in sections:
  es=en[sec['name']];data=bytes.fromhex(sec['data']);eb=bytes.fromhex(es['bytes']or'');rs=[r for r in e['relocations']if emap[r['source_section']]==sec['name']];covered={i for r in rs for i in range(r['offset'],r['offset']+4)};need(len(data)==len(eb)and all(a==b for i,(a,b)in enumerate(zip(data,eb))if i not in covered),'all nonfield ELF/COFF bytes')
  for j in range(sec['relocation_count']):
   off,sym,kind=struct.unpack_from('<IIH',raw,sec['relocation_pointer']+j*10);need(sym in idx,'COFF actual symbol index');c=idx[sym];r=next((r for r in rs if r['offset']==off),None);need(r is not None and kind==(20 if r['type']==2 else 6),'COFF field type/offset');s=r['symbol'];target=s['name']if s['name']else emap[s['section']];need(c['name']==target and c['value']==s['value']and c['class']==(2 if s['binding']==1 else 3),'COFF typed target identity');a=int.from_bytes(data[off:off+4],'little');need(a==(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff,'ELF/COFF addend plus4');relations.append({'offset':off,'name':target,'type':kind})
 need(len(relations)==33 and {r['offset']for r in relations}=={r['offset']for r in e['relocations']},'all33 distinct COFF field relations');return {'timestamp':timestamp,'sections':sections,'symbols':symbols,'relations':relations,'private44_ABS11_retained':True}

def headers(directory):
 from pathlib import Path
 import hashlib
 directory=Path(directory);need({p.name for p in directory.iterdir()if p.is_file()}==set(PRIMARY_HEADERS),'exact primary header graph')
 for n,h in PRIMARY_HEADERS.items():need(hashlib.sha256((directory/n).read_bytes()).hexdigest()==h,'primary header '+n)

def native(m,e,c):
 need(len(m.fixups)==33 and not(m.local_publics or m.local_externals),'native fields/scopes');names={s['index']:s['name']for s in e['sections']};mi={s.name:i for i,s in enumerate(m.segments,1)};fields={(f.segment,f.offset):f for f in m.fixups}
 for s in c['sections']:
  ms=m._segment(s['index']);need(ms.name==s['name']and bytes(ms.data)==(bytes(ms.size)if s['name']=='_BSS'else bytes.fromhex(s['data'])),'all COFF/native section bytes')
 for r in e['relocations']:
  f=fields[(mi[names[r['source_section']]],r['offset'])];need((f.width,f.location,f.relative,f.displacement)==(4,9,r['type']==2,0),'native typed field');s=r['symbol'];a=int.from_bytes(m._segment(f.segment).data[f.offset:f.offset+4],'little');need(a==(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff,'native PC32 translation')
  if s['binding']==1:need(f.target_method==2 and m.externals[f.target-1]==s['name']and(f.frame_method,f.frame)==(5,None),'actual global E+A')
  else:need(f.target_method==0 and m._segment(f.target).name==names[s['section']]and f.frame_method==1 and m.groups[f.frame-1]==('FLAT',()),'private section+V+A')
 need(UNUSED<=set(m.externals)and not any(m.externals[f.target-1]in UNUSED for f in m.fixups if f.target_method==2),'three unused import obligations')

def integer(text):
 def go(n):
  if isinstance(n,ast.Constant)and type(n.value)is int:return n.value
  if isinstance(n,ast.Name)and n.id in CONSTANTS:return CONSTANTS[n.id]
  if isinstance(n,ast.BinOp)and isinstance(n.op,ast.Mult):return go(n.left)*go(n.right)
  raise ValueError('LBMLIB unsupported constant expression')
 return go(ast.parse(text,mode='eval').body)
def source(text):
 labels=[];pub=set();imports=set();constants={};sections=[];ops=[];strings=[];zeros=[];current=None
 for line in text.splitlines():
  t=line.partition('#')[0].strip()
  if not t:continue
  need(';'not in t and not re.search(r'\b(?:incbin|org|db|dw|dd|dq)\b',t,re.I),'ordinary symbolic source/no opaque payload')
  if re.match(r'^[A-Za-z_][A-Za-z_0-9]*:',t):
   n,t=t.split(':',1);need(n not in labels,'duplicate source definition');labels.append(n);t=t.strip()
   if not t:continue
  if t.startswith('.'):
   if t.startswith('.section '):current=t.split()[1].split(',')[0];sections.append(t)
   elif t.startswith('.globl '):pub.add(t[7:])
   elif t.startswith('.extern '):imports.add(t[8:])
   elif t.startswith('.equ '):n,v=t[5:].split(',',1);need(n not in constants,'duplicate ABS');constants[n]=integer(v.strip())
   elif t.startswith('.asciz '):need(current=='CONST','actual error strings only');v=ast.literal_eval(t[7:]);need(type(v)is str and '\0'not in v,'ordinary terminated diagnostic literal');strings.append(v)
   elif t.startswith('.zero '):need(current=='_BSS'and t=='.zero 9*BPLANESIZE','real9x128 bitplanes owner');zeros.append(integer(t[6:]))
   else:need(t in['.intel_syntax noprefix','.code32','.file "LBMLIB.S"','.p2align 4','.p2align 2'],'closed source directives')
  else:need(current=='_TEXT','CODE instructions only');ops.append(t)
 need(pub==PUBLICS|IMPORTS and imports==IMPORTS,'all genuine public/provider declarations');need(len(labels)==49 and len(set(labels))==49 and constants==CONSTANTS,'all49 real definitions/11 ABS');need(sections==['.section _TEXT,"ax",@progbits','.section CONST,"aw",@progbits','.section CONST2,"aw",@progbits','.section _DATA,"aw",@progbits','.section _BSS,"aw",@nobits']and zeros==[1152]and len(strings)==3 and len(ops)==604,'full section/string/state/instruction owners');return {'lines':text.splitlines(),'labels':labels,'instructions':len(ops),'strings':strings,'BSS':zeros[0]}
def elf(raw,e,logical,listing):
 out=raw_elf(raw,e,'\n'.join(logical['lines']));symbols=[s for tab in e['symbols'].values()for s in tab];defs={s['name']:s for s in symbols if s['type']==0 and 0<s['section']<65520};need(set(defs)==set(logical['labels'])and len(defs)==49,'all distinct qualified source identities');need({s['name']:s['value']for s in symbols if s['type']==0 and s['section']==65521}==CONSTANTS and sum(s['type']==0 and s['section']==65521 for s in symbols)==11,'all11 real ABS');need(sum(s['type']==4 for s in symbols)==1 and sum(s['type']==3 for s in symbols)==2,'actual FILE/section identities')
 h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);ss=[struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*i)for i in range(13)]
 for idx,offsets in[(11,[struct.unpack_from('<I',raw,ss[10][4]+16*i)[0]for i in range(68)]),(12,[s[0]for s in ss])]:
  pool=raw[ss[idx][4]:ss[idx][4]+ss[idx][5]];used=set()
  for off in offsets:need(off<len(pool)and b'\0'in pool[off:],'string bounds');used.update(range(off,pool.index(b'\0',off)+1))
  need(used==set(range(len(pool))),'all actual string bytes')
 rows={};pages=0
 for line in listing.splitlines():
  if not line.strip():continue
  if line.startswith('GAS LISTING '):
   z=re.fullmatch(r'GAS LISTING (.+?)\s+page ([1-9][0-9]*)\s*',line);need(z and z[1].endswith('/LBMLIB.S')and int(z[2])==pages+1,'listing page');pages+=1;continue
  if '\t'in line:
   lead,text=line.split('\t',1);a=lead.split();need(len(a)in(1,3)and a[0].isdigit(),'listing row');n=int(a[0]);need(n not in rows and 1<=n<=len(logical['lines'])and text.rstrip()==logical['lines'][n-1].rstrip(),'every exact source line');rows[n]={'offset':int(a[1],16)if len(a)==3 else None,'data':bytes.fromhex(a[2])if len(a)==3 else b'','source':text.partition('#')[0].strip()}
  else:
   a=line.split();need(len(a)==2 and int(a[0])in rows,'listing continuation');rows[int(a[0])]['data']+=bytes.fromhex(a[1])
 need(set(rows)==set(range(1,len(logical['lines'])+1)),'all source rows');en={s['name']:s for s in e['sections']};lc={n:0 for n in['_TEXT','CONST','CONST2','_DATA','_BSS']};current=None;definitions=set();instructions=0
 for row in rows.values():
  t=row['source'];data=row['data']
  if t.startswith('.section '):current=t.split()[1].split(',')[0]
  if t.endswith(':'):
   name=t[:-1];need(name in defs and(defs[name]['section'],defs[name]['value'])==(en[current]['index'],lc[current]),'qualified private/public source coordinate');definitions.add(name)
  if data:
   need(current in lc and row['offset']==lc[current],'listing section coordinate')
   if t.startswith('.asciz '):full=ast.literal_eval(t[7:]).encode('ascii')+b'\0';need(data==full[:len(data)]and len(data)==min(20,len(full)),'source diagnostic literal');data=full
   elif t.startswith('.zero '):need(len(data)==20 and not any(data)and current=='_BSS','real BSS listing prefix');data=bytes(logical['BSS'])
   elif t.startswith('.p2align '):need(not any(data)and current=='CONST'and len(data)==(-lc[current])%4,'natural string alignment')
   if current=='_BSS':need(not any(data),'BSS is uninitialized real storage')
   else:need(data==bytes.fromhex(en[current]['bytes'])[lc[current]:lc[current]+len(data)],'all source/listing/native bytes')
   lc[current]+=len(data);instructions+=current=='_TEXT'
 need(lc=={'_TEXT':1797,'CONST':126,'CONST2':0,'_DATA':0,'_BSS':1152}and instructions==604 and definitions==set(defs),'all bytes/604rows/49definitions owned');out.update({'all604_instruction_rows':True,'all49_source_coordinates':True,'all_three_strings_and_natural_alignment':True});return out

def roles(original,m,e):
 need(original.local_publics=={'_bitplanes'}and len(original.local_externals)==1 and not(m.local_publics or m.local_externals),'one real original private correspondence');names={s.name:i for i,s in enumerate(m.segments,1)};need({n:(original._segment(s).name,v)for n,(s,v)in original.publics.items()if n not in original.local_publics}=={n:(m._segment(s).name,v)for n,(s,v)in m.publics.items()},'all public coordinates');need(set(original.externals)-original.local_publics==set(m.externals),'all provider/self imports');need(len(original.fixups)==len(m.fixups)==33,'all fields');fields={(f.segment,f.offset):f for f in m.fixups};rows=[];private=0;selfrefs=0
 for os in original.segments:need(bytes(os.data)==bytes(m._segment(names[os.name]).data)and os.size==m._segment(names[os.name]).size and os.attributes==m._segment(names[os.name]).attributes,'all raw original source bytes/alignment')
 for a in original.fixups:
  b=fields[(names[original._segment(a.segment).name],a.offset)];need((a.width,a.location,a.relative,a.displacement)==(b.width,b.location,b.relative,b.displacement)==(4,9,a.relative,0),'typed original field');name=original.externals[a.target-1]if a.target_method==2 else original._segment(a.target).name
  if name=='_bitplanes':need(b.target_method==0 and m._segment(b.target).name=='_BSS'and b.frame_method==1,'private section+V+A');private+=1
  elif a.target_method==2:need(b.target_method==2 and m.externals[b.target-1]==name and b.frame_method==5,'actual public/provider E+A');selfrefs+=name in m.publics
  else:need(b.target_method==0 and original._segment(a.target).name==m._segment(b.target).name and b.frame_method==1,'actual section role')
  rows.append({'name':name,'original':dataclasses.asdict(a),'native':dataclasses.asdict(b)})
 need(private==2 and selfrefs==3,'two private/three public-self equations');return {'roles':rows,'private_references':private,'public_self_references':selfrefs}
