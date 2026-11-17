"""DEBUG-only ELF/source/listing preflight; no target input or global admission."""
import struct, re, ast
PUBLICS = {'DBG_ScreenPrint_', 'DBG_FileStartup_', 'DBG_FilePrint_', 'DBG_FileShutdown_', 'DBG_CloseDebugOutput_', 'DBG_StartDebugOutput_', 'DBG_SetDebugLevel_', 'DBG_GetDebugLevel_', 'DBG_EnableDebugLevel_', 'DBG_DisableDebugLevel_', 'DBG_DisableAllDebugLevels_', 'DBG_SetDebugMode_', 'DBG_GetDebugMode_', 'DBG_SetDebugOutputMode_', 'DBG_GetDebugOutputMode_', 'DBG_DebugString_', 'DBG_DbgString_', 'DBG_Shutdown_', 'DBG_Startup_', 'DBG_RegisterOutputFunction_'}
IMPORTS = {'printf_', 'SafeOpenWrite_', 'SafeWrite_', 'SafeClose_', 'memset_', 'vsprintf_', 'Error_'}
SECTIONS = {'.text': (0, 1, 6, 1), '.data': (0, 1, 3, 1), '.bss': (0, 8, 3, 1), '_TEXT': (1033, 1, 6, 16), 'CONST': (176, 1, 3, 4), 'CONST2': (0, 1, 3, 4), '_DATA': (152, 1, 3, 4), '_BSS': (4, 8, 3, 16)}

def check(raw, e, source, listing):
    if not raw[:16] == b'\x7fELF\x01\x01\x01' + bytes(9):
        raise ValueError('Closed ELF schema violation at legacy line 7')
    h = struct.unpack_from('<HHIIIIIHHHHHH', raw, 16)
    if not (h[:5] == (1, 3, 1, 0, 0) and h[6:] == (0, 52, 0, 0, 40, 14, 13) and (h[5] + 14 * 40 == len(raw))):
        raise ValueError('Closed ELF schema violation at legacy line 7')
    secs = e['sections']
    if not [s['name'] for s in secs] == ['', '.text', '.data', '.bss', '_TEXT', '.rel_TEXT', 'CONST', 'CONST2', '_DATA', '.rel_DATA', '_BSS', '.symtab', '.strtab', '.shstrtab']:
        raise ValueError('Closed ELF schema violation at legacy line 8')
    sn = {s['index']: s['name'] for s in secs}
    by = {s['name']: s for s in secs}
    if not {s['name']: (s['size'], s['type'], s['flags'], s['align']) for s in secs if s['name'] in SECTIONS} == SECTIONS:
        raise ValueError('Closed ELF schema violation at legacy line 8')
    rawsecs = [struct.unpack_from('<IIIIIIIIII', raw, h[5] + i * 40) for i in range(14)]
    if not rawsecs[0] == (0,) * 10:
        raise ValueError('Closed ELF schema violation at legacy line 9')
    ranges = [(0, 52), (h[5], len(raw))]
    for i, s in enumerate(rawsecs[1:], 1):
        if (s[1], s[2], s[5], s[8]) != tuple(secs[i][key] for key in ('type', 'flags', 'size', 'align')):
            raise ValueError('Raw DEBUG section differs from parsed geometry')
        if not (s[3] == 0 and 52 <= s[4] <= h[5] and (s[1] == 8 or s[4] + s[5] <= h[5])):
            raise ValueError('Closed ELF schema violation at legacy line 11')
        if not s[1] != 4294967193:
            raise ValueError('Closed ELF schema violation at legacy line 11')
        if s[1] != 8 and s[5]:
            ranges.append((s[4], s[4] + s[5]))
        if i in (5, 9):
            if not (s[1], s[2], s[6], s[7], s[8], s[9]) == (9, 64, 11, 4 if i == 5 else 8, 4, 8):
                raise ValueError('Closed ELF schema violation at legacy line 13')
        elif i == 11:
            if not (s[1], s[2], s[6], s[8], s[9]) == (2, 0, 12, 4, 16):
                raise ValueError('Closed ELF schema violation at legacy line 14')
        elif i in (12, 13):
            if not (s[1], s[2], s[6], s[7], s[8], s[9]) == (3, 0, 0, 0, 1, 0):
                raise ValueError('Closed ELF schema violation at legacy line 15')
        elif not (s[6], s[7], s[9]) == (0, 0, 0):
            raise ValueError('Closed ELF schema violation at legacy line 16')
    ranges.sort()
    if not all((a[1] <= b[0] and (not any(raw[a[1]:b[0]])) for a, b in zip(ranges, ranges[1:]))):
        raise ValueError('Closed ELF schema violation at legacy line 17')
    lines = source.splitlines()
    rows = {}
    pages = []
    for line in listing.splitlines():
        if not line.strip():
            continue
        if line.startswith('GAS LISTING '):
            m = re.fullmatch('GAS LISTING (.+?)\\s+page ([1-9][0-9]*)\\s*', line)
            if not (m and m[1].endswith('/DEBUG.S') and (int(m[2]) == len(pages) + 1)):
                raise ValueError('Closed ELF schema violation at legacy line 23')
            pages.append(m[1])
            continue
        if '\t' in line:
            lead, text = line.split('\t', 1)
            a = lead.split()
            if not (len(a) in (1, 3) and a[0].isdigit()):
                raise ValueError('Closed ELF schema violation at legacy line 25')
            n = int(a[0])
            if not (1 <= n <= len(lines) and n not in rows and (text.rstrip() == lines[n - 1].rstrip())):
                raise ValueError('Closed ELF schema violation at legacy line 25')
            rows[n] = {'line': n, 'source': text.strip(), 'offset': int(a[1], 16) if len(a) == 3 else None, 'data': bytes.fromhex(a[2]) if len(a) == 3 else b''}
        else:
            a = line.split()
            if not (len(a) == 2 and a[0].isdigit() and (int(a[0]) in rows)):
                raise ValueError('Closed ELF schema violation at legacy line 27')
            rows[int(a[0])]['data'] += bytes.fromhex(a[1])
    if not set(rows) == set(range(1, len(lines) + 1)):
        raise ValueError('Closed ELF schema violation at legacy line 28')
    section = None
    lc = {n: 0 for n in SECTIONS}
    defs = {}
    const = {}
    code = []
    for row in rows.values():
        t = row['source'].partition('#')[0].strip()
        if t.startswith('.section '):
            section = t.split()[1].split(',')[0]
            if not section in SECTIONS:
                raise ValueError('Closed ELF schema violation at legacy line 31')
        if t.endswith(':'):
            if not (section and t[:-1] not in defs):
                raise ValueError('Closed ELF schema violation at legacy line 32')
            defs[t[:-1]] = (section, lc[section])
        if t.startswith('.equ '):
            n, v = t[5:].split(',', 1)
            if not n not in const:
                raise ValueError('Closed ELF schema violation at legacy line 33')
            const[n] = int(v)
        if t.startswith('.'):
            if not t.startswith(('.file ', '.intel_syntax ', '.equ ', '.extern ', '.globl ', '.section ', '.p2align ', '.balign ', '.ascii ', '.asciz ', '.long ', '.space ')):
                raise ValueError('Closed ELF schema violation at legacy line 35')
            if t.startswith('.globl '):
                if not t[7:] in PUBLICS:
                    raise ValueError('Closed ELF schema violation at legacy line 36')
            if t.startswith('.extern '):
                if not t[8:] in IMPORTS:
                    raise ValueError('Closed ELF schema violation at legacy line 37')
            if t.startswith(('.ascii ', '.asciz ')):
                if not section == 'CONST':
                    raise ValueError('Closed ELF schema violation at legacy line 38')
                v = ast.literal_eval(t.split(' ', 1)[1]).encode('ascii') + (b'\x00' if t.startswith('.asciz ') else b'')
                if not row['data'] == v:
                    raise ValueError('Closed ELF schema violation at legacy line 38')
            if t.startswith('.long '):
                if not section == '_DATA':
                    raise ValueError('Closed ELF schema violation at legacy line 39')
            if t.startswith('.space '):
                if not (section == '_BSS' and t == '.space 4' and (row['offset'] == lc[section]) and (not any(row['data']))):
                    raise ValueError('Closed ELF schema violation at legacy line 40')
                lc[section] += 4
                continue
        if row['data']:
            if not (section and section != '_BSS' and (row['offset'] == lc[section])):
                raise ValueError('Closed ELF schema violation at legacy line 42')
            data = bytes.fromhex(by[section]['bytes'])
            if not row['data'] == data[lc[section]:lc[section] + len(row['data'])]:
                raise ValueError('Closed ELF schema violation at legacy line 42')
            lc[section] += len(row['data'])
            if section == '_TEXT':
                if not not t.startswith('.'):
                    raise ValueError('Closed ELF schema violation at legacy line 43')
                code.append(dict(row, data=row['data'].hex()))
    if not lc == {n: s[0] for n, s in SECTIONS.items()}:
        raise ValueError('Closed ELF schema violation at legacy line 44')
    if not const == {'MAXDEBUGSTRING': 400, 'debug_normal': 5, 'debug_max': 20, 'filetype_text': 1}:
        raise ValueError('Closed ELF schema violation at legacy line 44')
    symbols = [s for tab in e['symbols'].values() for s in tab]
    if not (len(symbols) == 70 and (rawsecs[11][5], rawsecs[11][7]) == (1120, 43)):
        raise ValueError('Closed ELF schema violation at legacy line 46')
    st = raw[rawsecs[12][4]:rawsecs[12][4] + rawsecs[12][5]]
    for i, s in enumerate(symbols):
        n, v, size, info, other, sec = struct.unpack_from('<IIIBBH', raw, rawsecs[11][4] + 16 * i)
        if not n < len(st):
            raise ValueError('Closed ELF schema violation at legacy line 49')
        name = st[n:st.index(b'\x00', n)].decode('ascii')
        if not (name, v, size, info >> 4, info & 15, other, sec) == (s['name'], s['value'], s['size'], s['binding'], s['type'], s['other'], s['section']):
            raise ValueError('Closed ELF schema violation at legacy line 49')
        if not (size == 0 and info >> 4 == (0 if i < 43 else 1)):
            raise ValueError('Closed ELF schema violation at legacy line 49')
        if s['type'] == 4:
            if not (name, v, info, sec) == ('debug.S', 0, 4, 65521):
                raise ValueError('Closed ELF schema violation at legacy line 50')
        elif s['type'] == 3:
            if not (name == '' and v == 0 and (info == 3) and (sn[sec] in ('CONST', '_DATA', '_BSS'))):
                raise ValueError('Closed ELF schema violation at legacy line 51')
        elif i == 0:
            if not (n, v, size, info, other, sec) == (0, 0, 0, 0, 0, 0):
                raise ValueError('Closed ELF schema violation at legacy line 52')
    if not len([s for s in symbols if s['type'] == 4]) == 1:
        raise ValueError('Closed ELF schema violation at legacy line 53')
    if not ({(s['binding'], s['value'], s['section']) for s in symbols if s['type'] == 3} == {(0, 0, 6), (0, 0, 8), (0, 0, 10)} and len([s for s in symbols if s['type'] == 3]) == 3):
        raise ValueError('Closed ELF schema violation at legacy line 54')
    if not all((s['index'] == 0 or s['type'] == 3 or s['name'] for s in symbols)):
        raise ValueError('Closed ELF schema violation at legacy line 55')
    names = {s['name']: s for s in symbols if s['name']}
    if not all((s['binding'] in (0, 1) and s['type'] in (0, 3, 4) and (s['other'] == 0) and (s['section'] != 65522) for s in symbols)):
        raise ValueError('Closed ELF schema violation at legacy line 56')
    if not {s['name'] for s in symbols if s['binding'] == 1 and s['section'] > 0} == PUBLICS:
        raise ValueError('Closed ELF schema violation at legacy line 57')
    if not {s['name'] for s in symbols if s['binding'] == 1 and s['section'] == 0} == IMPORTS:
        raise ValueError('Closed ELF schema violation at legacy line 57')
    if not {s['name']: s['value'] for s in symbols if s['type'] != 4 and s['section'] == 65521} == const:
        raise ValueError('Closed ELF schema violation at legacy line 58')
    if not {s['name'] for s in symbols if s['type'] == 0 and 0 < s['section'] < 65520} == set(defs):
        raise ValueError('Closed ELF schema violation at legacy line 59')
    for n, (sec, v) in defs.items():
        s = names[n]
        if not (s['type'], s['binding'], sn[s['section']], s['value']) == (0, 1 if n in PUBLICS else 0, sec, v):
            raise ValueError('Closed ELF schema violation at legacy line 60')
    rel = e['relocations']
    if not len(rel) == 79:
        raise ValueError('Closed ELF schema violation at legacy line 61')
    seen = set()
    for r in rel:
        if not (sn[r['source_section']] in ('_TEXT', '_DATA') and r['type'] in (1, 2) and (r['symbol']['section'] != 65521)):
            raise ValueError('Closed ELF schema violation at legacy line 63')
        if not r['offset'] + 4 <= by[sn[r['source_section']]]['size']:
            raise ValueError('Closed ELF schema violation at legacy line 63')
        field = {(r['source_section'], n) for n in range(r['offset'], r['offset'] + 4)}
        if not not seen & field:
            raise ValueError('Closed ELF schema violation at legacy line 63')
        seen |= field
        if not any((row['offset'] <= r['offset'] and r['offset'] + 4 <= row['offset'] + len(row['data']) for row in rows.values() if row['offset'] is not None and (r['symbol']['name'] in row['source'] or r['symbol']['type'] == 3))):
            raise ValueError('Closed ELF schema violation at legacy line 64')
    return {'all_sections': True, 'all_source_listing_bytes': True, 'all_source_definition_coordinates': defs, 'all4_ABS': const, 'CODE_instruction_rows': code, 'ELF_primary_symbols': len(symbols), 'source_private_definitions': len(defs) - len(PUBLICS), 'all79_REL_fields': True, 'no_unknown_or_weak_COMMON_TLS_hidden_ABS_relocations': True}
