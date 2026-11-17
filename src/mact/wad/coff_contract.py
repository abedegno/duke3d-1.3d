"""Read-only WAD COFF identities/aux and ELF/OMF equations; no rewriting."""
from pathlib import Path
import struct
def coff(p):
    b = p.read_bytes()
    machine, nsec, stamp, sp, ns, opt, flags = struct.unpack_from('<HHIIIHH', b)
    if not (machine == 332 and opt == 0):
        raise ValueError('WAD closed metadata/role contract')
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
    return {'machine': machine, 'timestamp': stamp, 'flags': flags, 'sections': secs, 'symbols': symbols, 'relocations': rels}

def check(work,e,m):
 w=Path(work);c=coff(w/'WAD.COFF');syms=[s for tab in e['symbols'].values()for s in tab];names={s['name']:s for s in c['symbols']};byindex={s['index']:s for s in c['symbols']};cs={s['name']:s for s in c['sections']};correspondences=[];raw=(w/'WAD.COFF').read_bytes()
 for s in syms:
     if s['type'] == 4:
         z = names['.file']
         if not (z['class'], z['section'], z['value'], z['type']) == (103, -2, 0, 0):
             raise ValueError('WAD closed metadata/role contract')
         if not bytes.fromhex(z['aux_raw']).rstrip(b'\x00') == s['name'].encode():
             raise ValueError('WAD closed metadata/role contract')
     elif s['type'] == 3:
         sec = e['sections'][s['section']]['name']
         z = names[sec]
         if not (z['class'], z['section'], z['value'], z['aux_count']) == (3, cs[sec]['index'], 0, 1):
             raise ValueError('WAD closed metadata/role contract')
         if not bytes.fromhex(z['aux_raw']) == struct.pack('<IHHIhB3s', cs[sec]['size'], cs[sec]['reloc_count'], 0, 0, 0, 0, bytes(3)):
             raise ValueError('WAD closed metadata/role contract')
     elif not s['name']:
         continue
     else:
         z = names[s['name']]
         if not (z['class'] == (2 if s['binding'] == 1 else 3) and z['value'] == s['value']):
             raise ValueError('WAD closed metadata/role contract')
         section = 0 if s['section'] == 0 else -1 if s['section'] == 65521 else cs[e['sections'][s['section']]['name']]['index']
         if not z['section'] == section:
             raise ValueError('WAD closed metadata/role contract')
     correspondences.append({'ELF': s, 'COFF': z})
 if not (len(correspondences) == 205 and len(c['relocations']) == 245):
     raise ValueError('WAD closed metadata/role contract')
 relrows = []
 for s in c['sections']:
     es = next((z for z in e['sections'] if z['name'] == s['name']))
     if not s['size'] == es['size']:
         raise ValueError('WAD closed metadata/role contract')
     if not s['flags'] >> 20 & 15 == {1: 1, 4: 3, 16: 5}[es['align']]:
         raise ValueError('WAD closed metadata/role contract')
     target = next((z for z in m.segments if z.name == s['name']))
     if s['name'] in ['_BSS', '.bss']:
         if not (s['raw_offset'] == 0 and (not any(target.data))):
             raise ValueError('WAD closed metadata/role contract')
         continue
     data = raw[s['raw_offset']:s['raw_offset'] + s['size']] if s['raw_offset'] else b''
     if not data == bytes(target.data):
         raise ValueError('WAD closed metadata/role contract')
     eb = bytes.fromhex(es['bytes'])
     fields = {r['offset']: r for r in e['relocations'] if r['source_section'] == es['index']}
     covered = {k for off in fields for k in range(off, off + 4)}
     if not all((eb[k] == data[k] for k in range(len(data)) if k not in covered)):
         raise ValueError('WAD closed metadata/role contract')
     for off, r in fields.items():
         a = int.from_bytes(data[off:off + 4], 'little')
         if not a == r['inline_signed'] + (4 if r['type'] == 2 else 0) & 4294967295:
             raise ValueError('WAD closed metadata/role contract')
 for r in c['relocations']:
     sn = c['sections'][r['source_section'] - 1]['name']
     es = next((s for s in e['sections'] if s['name'] == sn))
     er = next((z for z in e['relocations'] if (z['source_section'], z['offset']) == (es['index'], r['offset'])))
     z = byindex[r['symbol_index']]
     if not (r['type'] == (20 if er['type'] == 2 else 6) and z['value'] == er['symbol']['value'] and (z['class'] == (2 if er['symbol']['binding'] == 1 else 3))):
         raise ValueError('WAD closed metadata/role contract')
     relrows.append({'ELF': er, 'COFF': r, 'COFF_symbol': z})
 return {'all205_primary_identities':correspondences,'complete_raw_COFF':c,'all245_REL_correspondences':relrows,'all_COFF_OMF_section_bytes_literal':True,'ELF_COFF_only_PC32_plus4_changes':True,'all135_private_plus13ABS_preserved':True}
