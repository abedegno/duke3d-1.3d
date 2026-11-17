"""Closed finite WAD477 ELF/raw symbol/REL schema; no generic ELF authority."""
import struct

def check(raw, e, source):
    if not raw[:16] == b'\x7fELF\x01\x01\x01' + bytes(9):
        raise ValueError('ELF identity/ABI')
    h = struct.unpack_from('<HHIIIIIHHHHHH', raw, 16)
    if not (h[0], h[1], h[2], h[3], h[4], h[6], h[7], h[8], h[9], h[10], h[11], h[12]) == (1, 3, 1, 0, 0, 0, 52, 0, 0, 40, 14, 13):
        raise ValueError('ELF header')
    if not h[5] + 14 * 40 == len(raw):
        raise ValueError('WAD closed source/metadata contract')
    ss = [struct.unpack_from('<IIIIIIIIII', raw, h[5] + 40 * i) for i in range(14)]
    if not ss[0] == (0,) * 10:
        raise ValueError('WAD closed source/metadata contract')
    shstr = raw[ss[13][4]:ss[13][4] + ss[13][5]]
    names = []
    for s in ss:
        if not s[0] < len(shstr):
            raise ValueError('WAD closed source/metadata contract')
        names.append(shstr[s[0]:shstr.index(b'\x00', s[0])].decode('ascii'))
    if not names == ['', '.text', '.data', '.bss', '_TEXT', '.rel_TEXT', 'CONST', 'CONST2', '_DATA', '.rel_DATA', '_BSS', '.symtab', '.strtab', '.shstrtab']:
        raise ValueError('WAD closed source/metadata contract')
    if not names == [s['name'] for s in e['sections']]:
        raise ValueError('WAD closed source/metadata contract')
    expected = {1: (1, 6, 0, 1, 0), 2: (1, 3, 0, 1, 0), 3: (8, 3, 0, 1, 0), 4: (1, 6, 3326, 16, 0), 5: (9, 64, 1784, 4, 8), 6: (1, 3, 954, 4, 0), 7: (1, 3, 0, 4, 0), 8: (1, 3, 104, 4, 0), 9: (9, 64, 176, 4, 8), 10: (8, 3, 140, 16, 0), 11: (2, 0, 3296, 4, 16), 12: (3, 0, 2742, 1, 0), 13: (3, 0, 82, 1, 0)}
    ranges = [(0, 52), (h[5], len(raw))]
    for i, s in enumerate(ss[1:], 1):
        if not (s[1], s[2], s[5], s[8], s[9]) == expected[i]:
            raise ValueError('section schema')
        if not s[3] == 0:
            raise ValueError('WAD closed source/metadata contract')
        if i in (5, 9):
            if not (s[6], s[7]) == (11, 4 if i == 5 else 8):
                raise ValueError('WAD closed source/metadata contract')
        elif i == 11:
            if not (s[6], s[7]) == (12, 153):
                raise ValueError('WAD closed source/metadata contract')
        elif not (s[6], s[7]) == (0, 0):
            raise ValueError('WAD closed source/metadata contract')
        if not (52 <= s[4] <= h[5] and (s[1] == 8 or s[4] + s[5] <= h[5])):
            raise ValueError('WAD closed source/metadata contract')
        if s[1] != 8 and s[5]:
            ranges.append((s[4], s[4] + s[5]))
    ranges.sort()
    if not all((a[1] <= b[0] for a, b in zip(ranges, ranges[1:]))):
        raise ValueError('WAD closed source/metadata contract')
    if not all((not any(raw[a[1]:b[0]]) for a, b in zip(ranges, ranges[1:]))):
        raise ValueError('WAD closed source/metadata contract')
    pubs = set()
    imports = set()
    labels = set()
    constants = {}
    for line in source.splitlines():
        t = line.partition('#')[0].strip()
        if t.startswith('.globl '):
            pubs.update(t[7:].split(','))
        elif t.startswith('.extern '):
            imports.update(t[8:].split(','))
        elif t.startswith('.equ '):
            n, v = t[5:].split(',')
            constants[n] = int(v)
        elif t.endswith(':'):
            labels.add(t[:-1])
    if not (len(pubs), len(imports), len(labels), len(constants)) == (26, 27, 161, 13):
        raise ValueError('WAD closed source/metadata contract')
    tab = e['symbols'].get(11, e['symbols'].get('11'))
    if not len(tab) == 206:
        raise ValueError('WAD closed source/metadata contract')
    strings = raw[ss[12][4]:ss[12][4] + ss[12][5]]
    syms = []
    for i in range(206):
        n, v, z, info, other, sec = struct.unpack_from('<IIIBBH', raw, ss[11][4] + 16 * i)
        if not n < len(strings):
            raise ValueError('WAD closed source/metadata contract')
        name = strings[n:strings.index(b'\x00', n)].decode('ascii')
        b = tab[i]
        if not (name, v, z, info >> 4, info & 15, other, sec) == (b['name'], b['value'], b['size'], b['binding'], b['type'], b['other'], b['section']):
            raise ValueError('raw/parsed identity')
        if not (info >> 4 in (0, 1) and info & 15 in (0, 3, 4) and (other == 0) and (sec != 65522) and (z == 0)):
            raise ValueError('bind/type/visibility/COMMON')
        if not info >> 4 == (0 if i < 153 else 1):
            raise ValueError('LOCAL/GLOBAL partition')
        if info & 15 == 4:
            if not (name, v, info >> 4, sec) == ('wad.S', 0, 0, 65521):
                raise ValueError('WAD closed source/metadata contract')
        elif info & 15 == 3:
            if not (name == '' and v == 0 and (sec in (6, 8, 10)) and (info >> 4 == 0)):
                raise ValueError('WAD closed source/metadata contract')
        elif sec == 65521:
            if not (name in constants and v == constants[name] and (info >> 4 == 0)):
                raise ValueError('WAD closed source/metadata contract')
        elif sec == 0:
            if not (i == 0 and (name, v, info) == ('', 0, 0) or (name in imports and (v, info) == (0, 16))):
                raise ValueError('WAD closed source/metadata contract')
        elif not (name in labels and sec in (4, 6, 8, 10) and (v <= ss[sec][5]) and (info >> 4 == (1 if name in pubs else 0))):
            raise ValueError('WAD closed source/metadata contract')
        syms.append(b)
    if not {b['name'] for b in syms if b['binding'] == 1 and b['section'] > 0} == pubs:
        raise ValueError('WAD closed source/metadata contract')
    if not {b['name'] for b in syms if b['binding'] == 1 and b['section'] == 0} == imports:
        raise ValueError('WAD closed source/metadata contract')
    if not len([b for b in syms if b['binding'] == 0 and b['type'] == 0 and (0 < b['section'] < 65520)]) == 135:
        raise ValueError('WAD closed source/metadata contract')
    seen = set()
    count = 0
    for rs, src in [(5, 4), (9, 8)]:
        for i in range(ss[rs][5] // 8):
            off, info = struct.unpack_from('<II', raw, ss[rs][4] + 8 * i)
            idx, kind = (info >> 8, info & 255)
            if not (idx < 206 and kind in (1, 2) and (off + 4 <= ss[src][5])):
                raise ValueError('WAD closed source/metadata contract')
            if not (src == 4 or kind == 1):
                raise ValueError('WAD closed source/metadata contract')
            if not syms[idx]['section'] != 65521:
                raise ValueError('ABS relocation unsupported')
            if not not seen.intersection(((src, k) for k in range(off, off + 4))):
                raise ValueError('WAD closed source/metadata contract')
            seen.update(((src, k) for k in range(off, off + 4)))
            r = next((r for r in e['relocations'] if (r['source_section'], r['offset']) == (src, off)))
            if not (r['type'], r['symbol']['index']) == (kind, idx):
                raise ValueError('WAD closed source/metadata contract')
            count += 1
    if not count == 245:
        raise ValueError('WAD closed source/metadata contract')
    return {'closed14section_schemas': True, 'all206raw_symbols': True, 'all245raw_REL_fields': True, 'real135_local_labels_objects': True, 'no_COMMON_weak_TLS_visibility_or_ABS_reloc': True}
