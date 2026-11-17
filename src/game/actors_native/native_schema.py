from pathlib import Path
import struct,json
from profiles.gnu_elf_omf.elf32 import elf
def coff(p):
    b = p.read_bytes()
    machine, nsec, stamp, sp, ns, opt, flags = struct.unpack_from('<HHIIIHH', b)
    if not (machine == 332 and opt == 0):
        raise ValueError('CONTROL closed metadata/role contract')
    strings = b[sp + ns * 18:]
    cs = lambda st, k: st[k:st.index(b'\x00', k)].decode()
    name = lambda x: cs(strings, int.from_bytes(x[4:], 'little')) if x[:4] == b'\x00' * 4 else x.rstrip(b'\x00').decode()
    secs = []
    for k in range(nsec):
        s = struct.unpack_from('<8sIIIIIIHHI', b, 20 + k * 40)
        secs.append({'index': k + 1, 'name': s[0].rstrip(b'\x00').decode(), 'size': s[3], 'raw_offset': s[4], 'reloc_offset': s[5], 'reloc_count': s[7], 'flags': s[9]})
    symbols = []
    k = 0
    while k < ns:
        n, v, sec, typ, cl, aux = struct.unpack_from('<8sIhHBB', b, sp + k * 18)
        symbols.append({'index': k, 'name': name(n), 'value': v, 'section': sec, 'type': typ, 'class': cl, 'aux_count': aux, 'aux_raw': b[sp + (k + 1) * 18:sp + (k + aux + 1) * 18].hex()})
        k += aux + 1
    rels = []
    for s in secs:
        for k in range(s['reloc_count']):
            a, i, typ = struct.unpack_from('<IIH', b, s['reloc_offset'] + k * 10)
            rels.append({'source_section': s['index'], 'offset': a, 'symbol_index': i, 'type': typ})
    closed_coff_bytes(b,nsec,sp,ns)
    return {'machine': machine, 'timestamp': stamp, 'flags': flags, 'sections': secs, 'symbols': symbols, 'relocations': rels}

def closed_coff_bytes(b,nsec,sp,ns):
 """All COFF file backing/attributes are explicit; timestamp is native metadata."""
 if nsec!=8 or sp+ns*18+4>len(b):raise ValueError('CONTROL COFF bounds')
 stringsize=struct.unpack_from('<I',b,sp+ns*18)[0]
 if stringsize<4 or sp+ns*18+stringsize!=len(b):raise ValueError('CONTROL COFF complete string table')
 covered=set(range(20+40*nsec))|set(range(sp,len(b)))
 for i in range(nsec):
  name,pa,va,size,data,rel,lno,nrel,nlno,flags=struct.unpack_from('<8sIIIIIIHHI',b,20+40*i)
  name=name.rstrip(b'\0').decode();align={'.text':1,'.data':1,'.bss':1,'_TEXT':16,'CONST':4,'CONST2':4,'_DATA':4,'_BSS':16}[name];kind=0x20 if name in('.text','_TEXT')else 0x80 if name in('.bss','_BSS')else 0x40;expect=(0x60000000 if kind==0x20 else 0xc0000000)|{1:0x100000,4:0x300000,16:0x500000}[align]|kind
  if (pa,va,lno,nlno,flags)!=(0,0,0,0,expect):raise ValueError('CONTROL COFF section attributes')
  for off,length in [(data,size if kind!=0x80 else 0),(rel,nrel*10)]:
   if not length:
    if off:raise ValueError('CONTROL empty COFF backing')
    continue
   if off<20+40*nsec or off+length>sp:raise ValueError('CONTROL COFF raw range')
   r=set(range(off,off+length))
   if covered&r:raise ValueError('CONTROL overlapping COFF backing')
   covered|=r
 if any(v and i not in covered for i,v in enumerate(b)):raise ValueError('CONTROL substantive unowned COFF bytes')

def check(W,m,clock_bounds):
 W=Path(W)
 c=coff(W/'ACTORS.COFF');e=elf(W/'ACTORS.ELF');es={s['index']:s for s in e['sections']};cs={s['name']:s for s in c['sections']};symbols=[s for table in e['symbols'].values()for s in table];cn={s['name']:s for s in c['symbols']};ci={s['index']:s for s in c['symbols']};need=lambda q,s:None if q else(_ for _ in()).throw(ValueError(s));seen=[]
 for s in symbols:
  if not s['name']and not s['type']:continue
  if s['type']==4:
   z=cn['.file'];need((z['class'],z['section'],z['value'],z['type'])==(103,-2,0,0)and bytes.fromhex(z['aux_raw']).rstrip(b'\0')==s['name'].encode(),'true FILE aux')
  elif s['type']==3:
   sec=es[s['section']]['name'];z=cn[sec];need((z['class'],z['section'],z['value'],z['aux_count'])==(3,cs[sec]['index'],0,1),'true section identity');need(bytes.fromhex(z['aux_raw'])==struct.pack('<IHHIhB3s',cs[sec]['size'],cs[sec]['reloc_count'],0,0,0,0,bytes(3)),'complete section aux')
  else:
   z=cn[s['name']];section=0 if s['section']==0 else -1 if s['section']==65521 else cs[es[s['section']]['name']]['index'];need((z['class'],z['value'],z['section'],z['type'],z['aux_count'])==(2 if s['binding']==1 else 3,s['value'],section,0,0),'true complete symbol binding')
  seen.append(z['index'])
 need(len(seen)==len(set(seen))==len(c['symbols']),'complete symbol identity bijection');ef={(es[f['source_section']]['name'],f['offset']):f for f in e['relocations']};cf={(c['sections'][f['source_section']-1]['name'],f['offset']):f for f in c['relocations']};need(len(ef)==len(cf)==len(c['relocations'])==2812 and set(ef)==set(cf),'complete unique2812 COFF field coordinate bijection');raw=(W/'ACTORS.COFF').read_bytes();native={s.name:s for s in m.segments}
 for name,s in cs.items():
  se=next(t for t in e['sections']if t['name']==name);need(s['size']==se['size']and(s['flags']>>20&15)=={1:1,4:3,16:5}[se['align']],'section real size/alignment')
  if name not in native:need(s['size']==0,'only genuine unused empty default sections');continue
  if name=='_BSS':need(s['raw_offset']==0 and not any(native[name].data),'BSS uninitialized bytes');continue
  data=raw[s['raw_offset']:s['raw_offset']+s['size']]if s['raw_offset']else b'';need(data==bytes(native[name].data),'complete COFF/native section bytes');eb=bytes.fromhex(se['bytes']);covered={i for k in ef if k[0]==name for i in range(k[1],k[1]+4)};need(all(x==y for i,(x,y)in enumerate(zip(data,eb))if i not in covered),'complete COFF/ELF nonfield bytes')
  for key,f in cf.items():
   if key[0]!=name:continue
   g=ef[key];z=ci[f['symbol_index']];sym=g['symbol'];required=sym['name']if sym['binding']==1 else es[sym['section']]['name'];need(z['name']==required and(z['class'],z['value'],f['type'])==(2 if sym['binding']==1 else 3,sym['value'],20 if g['type']==2 else 6),'actual complete COFF owner/type/section+V');need(int.from_bytes(data[key[1]:key[1]+4],'little')==(g['inline_signed']+(4 if g['type']==2 else 0))&0xffffffff,'inline relative bias only')
 if not clock_bounds[0]<=c['timestamp']<=clock_bounds[1]:raise ValueError('native COFF creation timestamp outside observed tool call')
 return {'all_ELF_COFF_primary_identities':len(seen),'all_unique_fields':2812,'complete_backing':True,'actual_native_COFF_timestamp':c['timestamp'],'clock_bounds':clock_bounds}
