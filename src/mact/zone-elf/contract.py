"""Closed source-specific ELF SOUND admission, no generic changes."""
import struct, ast, re
PUBLICS = {'Z_FreeZone_', 'Z_Init_', 'Z_ShutDownZone_', 'Z_ShutDown_', 'Z_GetSize_', 'Z_AddFreeBlock_', 'Z_FreeBlock_', 'Z_Free_', 'Z_FreeTags_', 'Z_PurgeZone_', 'Z_FindBlockInFreeList_', 'Z_FindFreeBlock_', 'Z_Malloc_', 'Z_Touch_', 'Z_Realloc_', 'Z_ZoneUsed_', 'Z_ZoneMaxFree_', 'Z_ZoneSize_', 'Z_ChangeTag_', 'Z_AvailHeap_', 'Z_DumpHeap_', 'Z_CheckHeap_'}
IMPORTS = {'Error_', 'SafeMalloc_', 'malloc_', 'SafeFree_', 'free_', 'memset_', 'int386x_', 'DBG_DbgString_'}

def integer(text, values):

    def f(n):
        if isinstance(n, ast.Constant) and type(n.value) is int:
            return n.value
        if isinstance(n, ast.Name):
            if not n.id in values:
                raise ValueError('Closed ELF schema violation at legacy line 8')
            return values[n.id]
        if isinstance(n, ast.UnaryOp) and isinstance(n.op, ast.USub):
            return -f(n.operand)
        if isinstance(n, ast.BinOp):
            a, b = (f(n.left), f(n.right))
            if isinstance(n.op, ast.Add):
                return a + b
            if isinstance(n.op, ast.Sub):
                return a - b
            if isinstance(n.op, ast.Mult):
                return a * b
            if isinstance(n.op, ast.Div):
                if not (a >= 0 and b > 0):
                    raise ValueError('Closed ELF schema violation at legacy line 15')
                return a // b
        raise AssertionError('unknown source arithmetic')
    return f(ast.parse(text, mode='eval').body)

def listing_layout(listing, source, e):
    lines = source.splitlines()
    rows = {}
    pages = []
    for line in listing.splitlines():
        if not line.strip():
            continue
        if line.startswith('GAS LISTING '):
            m = re.fullmatch('GAS LISTING (.+?)\\s+page ([1-9][0-9]*)\\s*', line)
            if not (m and m[1].endswith('/ZONE.S') and (int(m[2]) == len(pages) + 1)):
                raise ValueError('Closed ELF schema violation at legacy line 23')
            pages.append(m[1])
            continue
        if '\t' in line:
            prefix, text = line.split('\t', 1)
            a = prefix.split()
            if not (len(a) in (1, 3) and a[0].isdigit()):
                raise ValueError('Closed ELF schema violation at legacy line 25')
            n = int(a[0])
            if not (1 <= n <= len(lines) and text.rstrip() == lines[n - 1].rstrip() and (n not in rows)):
                raise ValueError('Closed ELF schema violation at legacy line 25')
            rows[n] = {'source': text.strip(), 'offset': int(a[1], 16) if len(a) == 3 else None, 'bytes': bytes.fromhex(a[2]) if len(a) == 3 else b''}
        else:
            a = line.split()
            if not (len(a) == 2 and a[0].isdigit() and (int(a[0]) in rows)):
                raise ValueError('Closed ELF schema violation at legacy line 27')
            rows[int(a[0])]['bytes'] += bytes.fromhex(a[1])
    if not set(rows) == set(range(1, len(lines) + 1)):
        raise ValueError('Closed ELF schema violation at legacy line 28')
    sec = None
    lc = {4: 0, 6: 0, 7: 0, 8: 0, 9: 0}
    defs = {}
    constants = {}
    code_rows = []
    for n in range(1, len(lines) + 1):
        row = rows[n]
        t = row['source'].partition('#')[0].strip()
        if t.startswith('.section '):
            sec = {'_TEXT': 4, 'CONST': 6, 'CONST2': 7, '_DATA': 8, '_BSS': 9}[t.split()[1].split(',')[0]]
        if t.startswith('.equ '):
            name, x = t[5:].split(',', 1)
            constants[name] = integer(x, constants)
        if t.endswith(':'):
            if not sec is not None:
                raise ValueError('Closed ELF schema violation at legacy line 33')
            defs[t[:-1]] = (sec, lc[sec])
        if t.startswith('.space '):
            if not (sec == 9 and row['offset'] == lc[sec] and (not any(row['bytes']))):
                raise ValueError('Closed ELF schema violation at legacy line 34')
            lc[sec] += integer(t[7:], constants)
        elif sec in (6, 8) and t.startswith(('.ascii ', '.long ')):
            data = ast.literal_eval(row['source'][7:]).encode('ascii') if t.startswith('.ascii ') else struct.pack('<' + 'I' * len(t[6:].split(',')), *[integer(x, constants) for x in t[6:].split(',')])
            if not (row['offset'] == lc[sec] and row['bytes'] == data and (len(data) <= 20)):
                raise ValueError('Closed ELF schema violation at legacy line 36')
            actual = bytes.fromhex(e['sections'][sec]['bytes'])
            if not data == actual[lc[sec]:lc[sec] + len(data)]:
                raise ValueError('Closed ELF schema violation at legacy line 36')
            lc[sec] += len(data)
        elif row['bytes']:
            if not (sec in (4, 6, 8) and row['offset'] == lc[sec]):
                raise ValueError('Closed ELF schema violation at legacy line 38')
            actual = bytes.fromhex(e['sections'][sec]['bytes'])
            if not row['bytes'] == actual[lc[sec]:lc[sec] + len(row['bytes'])]:
                raise ValueError('Closed ELF schema violation at legacy line 38')
            lc[sec] += len(row['bytes'])
            if sec == 4:
                code_rows.append({'line': n, 'offset': row['offset'], 'bytes': row['bytes'].hex(), 'source': row['source']})
    if not (lc == {4: 2367, 6: 1427, 7: 0, 8: 32, 9: 48} and len(defs) == 149 and (len(code_rows) == 907)):
        raise ValueError('Closed ELF schema violation at legacy line 40')
    return (defs, code_rows)

def check(raw, e, source, listing):
    if not raw[:16] == b'\x7fELF\x01\x01\x01' + bytes(9):
        raise ValueError('Closed ELF schema violation at legacy line 44')
    h = struct.unpack_from('<HHIIIIIHHHHHH', raw, 16)
    if not (h[0], h[1], h[2], h[3], h[4], h[6], h[7], h[8], h[9], h[10], h[11], h[12]) == (1, 3, 1, 0, 0, 0, 52, 0, 0, 40, 13, 12):
        raise ValueError('Closed ELF schema violation at legacy line 44')
    if not h[5] + 13 * 40 == len(raw):
        raise ValueError('Closed ELF schema violation at legacy line 44')
    ss = [struct.unpack_from('<IIIIIIIIII', raw, h[5] + 40 * i) for i in range(13)]
    if not ss[0] == (0,) * 10:
        raise ValueError('Closed ELF schema violation at legacy line 44')
    strings = raw[ss[12][4]:ss[12][4] + ss[12][5]]
    names = [strings[s[0]:strings.index(b'\x00', s[0])].decode('ascii') for s in ss]
    if not (names == ['', '.text', '.data', '.bss', '_TEXT', '.rel_TEXT', 'CONST', 'CONST2', '_DATA', '_BSS', '.symtab', '.strtab', '.shstrtab'] and names == [s['name'] for s in e['sections']]):
        raise ValueError('Closed ELF schema violation at legacy line 45')
    expected = {1: (1, 6, 0, 1, 0), 2: (1, 3, 0, 1, 0), 3: (8, 3, 0, 1, 0), 4: (1, 6, 2367, 16, 0), 5: (9, 64, 728, 4, 8), 6: (1, 3, 1427, 4, 0), 7: (1, 3, 0, 4, 0), 8: (1, 3, 32, 4, 0), 9: (8, 3, 48, 16, 0), 10: (2, 0, 2864, 4, 16), 11: (3, 0, 2648, 1, 0), 12: (3, 0, 78, 1, 0)}
    ranges = [(0, 52), (h[5], len(raw))]
    for i, s in enumerate(ss[1:], 1):
        if not ((s[1], s[2], s[5], s[8], s[9]) == expected[i] and s[3] == 0):
            raise ValueError('closed section schema')
        if i == 5:
            if not (s[6], s[7]) == (10, 4):
                raise ValueError('Closed ELF schema violation at legacy line 49')
        elif i == 10:
            if not (s[6], s[7]) == (11, 149):
                raise ValueError('Closed ELF schema violation at legacy line 50')
        elif not (s[6], s[7]) == (0, 0):
            raise ValueError('Closed ELF schema violation at legacy line 51')
        if not (52 <= s[4] <= h[5] and (s[1] == 8 or s[4] + s[5] <= h[5])):
            raise ValueError('Closed ELF schema violation at legacy line 52')
        if s[1] != 8 and s[5]:
            ranges.append((s[4], s[4] + s[5]))
    ranges.sort()
    if not all((a[1] <= b[0] for a, b in zip(ranges, ranges[1:]))):
        raise ValueError('Closed ELF schema violation at legacy line 54')
    if not all((not any(raw[a[1]:b[0]]) for a, b in zip(ranges, ranges[1:]))):
        raise ValueError('Closed ELF schema violation at legacy line 54')
    definitions, instructions = listing_layout(listing, source, e)
    constants = {}
    labels = set()
    for line in source.splitlines():
        t = line.partition('#')[0].strip()
        if t.endswith(':'):
            labels.add(t[:-1])
        if t.startswith('.equ '):
            n, x = t[5:].split(',', 1)
            if not n not in constants:
                raise ValueError('Closed ELF schema violation at legacy line 59')
            constants[n] = integer(x, constants)
        if t.startswith('.globl '):
            if not set(t[7:].split(',')) <= PUBLICS:
                raise ValueError('private export')
        if t.startswith('.'):
            if not t.startswith(('.intel_syntax ', '.att_syntax ', '.code32', '.file ', '.section ', '.p2align ', '.globl ', '.extern ', '.equ ', '.ascii ', '.byte ', '.long ', '.space ')):
                raise ValueError('unsupported data/source directive')
    if not (len(constants) == 17 and len(labels) == 149):
        raise ValueError('Closed ELF schema violation at legacy line 63')
    tab = e['symbols'].get(10, e['symbols'].get('10'))
    if not len(tab) == 179:
        raise ValueError('Closed ELF schema violation at legacy line 64')
    st = raw[ss[11][4]:ss[11][4] + ss[11][5]]
    symbols = []
    for i in range(179):
        n, v, z, info, other, sec = struct.unpack_from('<IIIBBH', raw, ss[10][4] + 16 * i)
        if not n < len(st):
            raise ValueError('Closed ELF schema violation at legacy line 66')
        name = st[n:st.index(b'\x00', n)].decode('ascii')
        a = tab[i]
        if not (name, v, z, info >> 4, info & 15, other, sec) == (a['name'], a['value'], a['size'], a['binding'], a['type'], a['other'], a['section']):
            raise ValueError('Closed ELF schema violation at legacy line 66')
        if not (z == 0 and info >> 4 in (0, 1) and (info & 15 in (0, 3, 4)) and (other == 0) and (sec != 65522)):
            raise ValueError('Closed ELF schema violation at legacy line 66')
        if not info >> 4 == (0 if i < 149 else 1):
            raise ValueError('Closed ELF schema violation at legacy line 66')
        if info & 15 == 4:
            if not (name, v, info >> 4, sec) == ('zone.S', 0, 0, 65521):
                raise ValueError('Closed ELF schema violation at legacy line 67')
        elif info & 15 == 3:
            if not (name == '' and v == 0 and (sec in (6, 8, 9)) and (info >> 4 == 0)):
                raise ValueError('Closed ELF schema violation at legacy line 68')
        elif sec == 65521:
            if not (name in constants and v == constants[name] & 4294967295 and (info >> 4 == 0)):
                raise ValueError('Closed ELF schema violation at legacy line 69')
        elif sec == 0:
            if not (i == 0 and (name, v, info) == ('', 0, 0) or (name in IMPORTS and (v, info) == (0, 16))):
                raise ValueError('Closed ELF schema violation at legacy line 70')
        elif not (name in labels and (sec, v) == definitions[name] and (info >> 4 == (1 if name in PUBLICS else 0))):
            raise ValueError('Closed ELF schema violation at legacy line 71')
        symbols.append(a)
    if not {a['name'] for a in symbols if a['binding'] == 1 and a['section'] > 0} == PUBLICS:
        raise ValueError('Closed ELF schema violation at legacy line 73')
    if not {a['name'] for a in symbols if a['binding'] == 1 and a['section'] == 0} == IMPORTS:
        raise ValueError('Closed ELF schema violation at legacy line 73')
    seen = set()
    for i in range(91):
        off, info = struct.unpack_from('<II', raw, ss[5][4] + 8 * i)
        idx, kind = (info >> 8, info & 255)
        if not (idx < 179 and kind in (1, 2) and (off + 4 <= 2367) and (symbols[idx]['section'] != 65521)):
            raise ValueError('Closed ELF schema violation at legacy line 76')
        if not not seen.intersection(range(off, off + 4)):
            raise ValueError('Closed ELF schema violation at legacy line 76')
        seen.update(range(off, off + 4))
        r = next((r for r in e['relocations'] if r['offset'] == off))
        if not (r['source_section'], r['type'], r['symbol']['index']) == (4, kind, idx):
            raise ValueError('Closed ELF schema violation at legacy line 76')
    return {'all13_raw_section_schemas': True, 'all179_raw_symbols': True, 'all91_raw_REL_fields': True, 'all127_real_private_and17_ABS_identities': True, 'no_COMMON_weak_TLS_hidden_or_ABS_relocation': True, 'private_exports_forbidden': True, 'complete_source_listing_907_instruction_rows': instructions, 'source149_definition_coordinates': definitions}
