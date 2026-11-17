"""Read-only GAME COFF identities/aux and ELF/OMF equations; no rewriting."""
from pathlib import Path
import struct
def coff(p):
    b = p.read_bytes()
    machine, nsec, stamp, sp, ns, opt, flags = struct.unpack_from('<HHIIIHH', b)
    if not (machine == 332 and opt == 0):
        raise ValueError('GAME closed metadata/role contract')
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

def check(work,e,m):
 w=Path(work);c=coff(w/'GAME.COFF');syms=[s for tab in e['symbols'].values()for s in tab];names={s['name']:s for s in c['symbols']};byindex={s['index']:s for s in c['symbols']};cs={s['name']:s for s in c['sections']};correspondences=[];raw=(w/'GAME.COFF').read_bytes()
 for s in syms:
     if s['type'] == 4:
         z = names['.file']
         if not (z['class'], z['section'], z['value'], z['type']) == (103, -2, 0, 0):
             raise ValueError('GAME closed metadata/role contract')
         if not bytes.fromhex(z['aux_raw']).rstrip(b'\x00') == s['name'].encode():
             raise ValueError('GAME closed metadata/role contract')
     elif s['type'] == 3:
         sec = e['sections'][s['section']]['name']
         z = names[sec]
         if not (z['class'], z['section'], z['value'], z['aux_count']) == (3, cs[sec]['index'], 0, 1):
             raise ValueError('GAME closed metadata/role contract')
         if not bytes.fromhex(z['aux_raw']) == struct.pack('<IHHIhB3s', cs[sec]['size'], cs[sec]['reloc_count'], 0, 0, 0, 0, bytes(3)):
             raise ValueError('GAME closed metadata/role contract')
     elif not s['name']:
         continue
     else:
         z = names[s['name']]
         if not (z['class'] == (2 if s['binding'] == 1 else 3) and z['type']==0 and z['aux_count']==0 and z['value'] == s['value']):
             raise ValueError('GAME closed metadata/role contract')
         section = 0 if s['section'] == 0 else -1 if s['section'] == 65521 else cs[e['sections'][s['section']]['name']]['index']
         if not z['section'] == section:
             raise ValueError('GAME closed metadata/role contract')
     correspondences.append({'ELF': s, 'COFF': z})
 if not (len(correspondences) == len([s for s in syms if s['name']or s['type']==3]) and len(c['relocations']) == 5018):
     raise ValueError('GAME closed metadata/role contract')
 if len(c['symbols'])!=len(correspondences)or len({v['name']for v in c['symbols']})!=len(c['symbols']):raise ValueError('GAME extra/lost COFF identity')
 relrows = []
 for s in c['sections']:
     es = next((z for z in e['sections'] if z['name'] == s['name']))
     if not s['size'] == es['size']:
         raise ValueError('GAME closed metadata/role contract')
     if not s['flags'] >> 20 & 15 == {1: 1, 4: 3, 16: 5}[es['align']]:
         raise ValueError('GAME closed metadata/role contract')
     target = next((z for z in m.segments if z.name == s['name']),None)
     if target is None:
         if s['name']not in('.text','.data','.bss')or s['size']or s['reloc_count']or s['raw_offset']:raise ValueError('GAME meaningful omitted section')
         continue
     if s['name'] in ['_BSS', '.bss']:
         if not (s['raw_offset'] == 0 and (not any(target.data))):
             raise ValueError('GAME closed metadata/role contract')
         continue
     data = raw[s['raw_offset']:s['raw_offset'] + s['size']] if s['raw_offset'] else b''
     if not data == bytes(target.data):
         raise ValueError('GAME closed metadata/role contract')
     eb = bytes.fromhex(es['bytes'])
     fields = {r['offset']: r for r in e['relocations'] if r['source_section'] == es['index']}
     covered = {k for off in fields for k in range(off, off + 4)}
     if not all((eb[k] == data[k] for k in range(len(data)) if k not in covered)):
         raise ValueError('GAME closed metadata/role contract')
     for off, r in fields.items():
         a = int.from_bytes(data[off:off + 4], 'little')
         if not a == r['inline_signed'] + (4 if r['type'] == 2 else 0) & 4294967295:
             raise ValueError('GAME closed metadata/role contract')
 # Per-row validity is insufficient: a duplicate can hide a missing field.
 actual_fields=[(c['sections'][r['source_section']-1]['name'],r['offset'])for r in c['relocations']]
 expected_fields=[(e['sections'][r['source_section']]['name'],r['offset'])for r in e['relocations']]
 if not(len(actual_fields)==len(set(actual_fields))==len(expected_fields)==len(set(expected_fields))==5018 and set(actual_fields)==set(expected_fields)):
     raise ValueError('GAME complete unique COFF/ELF field bijection')
 for r in c['relocations']:
     sn = c['sections'][r['source_section'] - 1]['name']
     es = next((s for s in e['sections'] if s['name'] == sn))
     er = next((z for z in e['relocations'] if (z['source_section'], z['offset']) == (es['index'], r['offset'])))
     z = byindex[r['symbol_index']]
     required=er['symbol']['name']if er['symbol']['binding']==1 else e['sections'][er['symbol']['section']]['name']
     if z['name']!=required:raise ValueError('GAME COFF field changed genuine named owner')
     if not (r['type'] == (20 if er['type'] == 2 else 6) and z['value'] == er['symbol']['value'] and (z['class'] == (2 if er['symbol']['binding'] == 1 else 3))):
         raise ValueError('GAME closed metadata/role contract')
     relrows.append({'ELF': er, 'COFF': r, 'COFF_symbol': z})
 return {'all_primary_identities':correspondences,'complete_raw_COFF':c,'all5018_REL_correspondences':relrows,'all_COFF_OMF_section_bytes_literal':True,'ELF_COFF_only_PC32_plus4_changes':True,'all_genuine_private_source_identities_preserved':True}


def closed_coff_bytes(b,nsec,sp,ns):
 """All COFF file backing/attributes are explicit; timestamp is native metadata."""
 if nsec!=8 or sp+ns*18+4>len(b):raise ValueError('GAME COFF bounds')
 stringsize=struct.unpack_from('<I',b,sp+ns*18)[0]
 if stringsize<4 or sp+ns*18+stringsize!=len(b):raise ValueError('GAME COFF complete string table')
 covered=set(range(20+40*nsec))|set(range(sp,len(b)))
 for i in range(nsec):
  name,pa,va,size,data,rel,lno,nrel,nlno,flags=struct.unpack_from('<8sIIIIIIHHI',b,20+40*i)
  name=name.rstrip(b'\0').decode();align={'.text':1,'.data':1,'.bss':1,'_TEXT':16,'CONST':4,'CONST2':4,'_DATA':4,'_BSS':16}[name];kind=0x20 if name in('.text','_TEXT')else 0x80 if name in('.bss','_BSS')else 0x40;expect=(0x60000000 if kind==0x20 else 0xc0000000)|{1:0x100000,4:0x300000,16:0x500000}[align]|kind
  if (pa,va,lno,nlno,flags)!=(0,0,0,0,expect):raise ValueError('GAME COFF section attributes')
  for off,length in [(data,size if kind!=0x80 else 0),(rel,nrel*10)]:
   if not length:
    if off:raise ValueError('GAME empty COFF backing')
    continue
   if off<20+40*nsec or off+length>sp:raise ValueError('GAME COFF raw range')
   r=set(range(off,off+length))
   if covered&r:raise ValueError('GAME overlapping COFF backing')
   covered|=r
 if any(v and i not in covered for i,v in enumerate(b)):raise ValueError('GAME substantive unowned COFF bytes')
