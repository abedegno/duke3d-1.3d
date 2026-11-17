"""Read-only ELF32 receipts for closed source-specific schemas, no rewriting."""
import struct
def elf(p):
    b = p.read_bytes()
    assert b[:7] == b'\x7fELF\x01\x01\x01'
    h = struct.unpack_from('<HHIIIIIHHHHHH', b, 16)
    assert h[:2] == (1, 3)
    ss = [struct.unpack_from('<IIIIIIIIII', b, h[5] + i * h[10]) for i in range(h[11])]
    names = ss[h[12]]
    st = b[names[4]:names[4] + names[5]]
    cs = lambda s, i: s[i:s.index(b'\x00', i)].decode()
    rows = []
    symbols = {}
    rels = []
    for i, s in enumerate(ss):
        rows.append({'index': i, 'name': cs(st, s[0]), 'type': s[1], 'flags': s[2], 'size': s[5], 'align': s[8], 'backed': s[1] != 8, 'bytes': None if s[1] == 8 else b[s[4]:s[4] + s[5]].hex()})
        if s[1] == 2:
            t = ss[s[6]]
            strings = b[t[4]:t[4] + t[5]]
            tab = []
            for k in range(0, s[5], s[9]):
                n, v, z, info, other, sec = struct.unpack_from('<IIIBBH', b, s[4] + k)
                tab.append({'index': len(tab), 'name': cs(strings, n), 'value': v, 'size': z, 'binding': info >> 4, 'type': info & 15, 'other': other, 'section': sec})
            symbols[i] = tab
    for i, s in enumerate(ss):
        if s[1] == 9:
            for k in range(0, s[5], s[9]):
                off, info = struct.unpack_from('<II', b, s[4] + k)
                a = struct.unpack_from('<i', b, ss[s[7]][4] + off)[0]
                rels.append({'source_section': s[7], 'offset': off, 'type': info & 255, 'symbol': symbols[s[6]][info >> 8], 'inline_signed': a})
    return {'sections': rows, 'symbols': symbols, 'relocations': rels}
