"""Observer-only existing whole-source and supplied-stock callee role receipts."""
from pathlib import Path
import sys, json, hashlib
R = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(R), str(R / 'profiles/watcom/tools')]
from omf32 import Module
from tools.verify_module import verify_module, external_anchor_bindings
h = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()

def need(c, m):
    if not c:
        raise ValueError('WAD callee ' + m)

def verify_callees(image, expected):
    result = {}
    pins = {}
    all_ = {}
    for n, needed in [('mact_util', ['Error_', 'IntelLong_', 'SafeFree_', 'SafeMallocSize_', 'SafeMalloc_', 'SafeRealloc_']), ('mact_file', ['DefaultExtension_', 'ExtractFileBase_', 'SafeClose_', 'SafeFileLength_', 'SafeOpenRead_', 'SafeOpenWrite_', 'SafeRead_', 'SafeWrite_']), ('mact_zone', ['Z_Malloc_', 'Z_Touch_', 'Z_ChangeTag_'])]:
        p = R / 'evidence' / (n + '-module.json')
        r = json.loads(p.read_text())
        d = R / 'modules' / (n + '.json')
        spec = json.loads(d.read_text())
        source = R / r['source']
        if not (h(source) == r['source_sha256'] and h(d) == r['descriptor_sha256']):
            raise ValueError('WAD current callee/source/stock contract')
        if not r['target_sha256'] == 'a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4':
            raise ValueError('WAD current callee/source/stock contract')
        lineage = R / spec.get('source_reference_evidence', r.get('source_reference_evidence', ''))
        if not (lineage.is_file() and h(lineage) == r['source_reference_sha256']):
            raise ValueError('WAD current callee/source/stock contract')
        pins[str(lineage)] = h(lineage)
        if n in ('mact_util', 'mact_file'):
            producer = R / 'tools' / ('probe_' + n + '.py')
            if not (h(producer) == r['source_producer_sha256'] and r['options'] == spec['options']):
                raise ValueError('WAD current callee/source/stock contract')
            pins[str(producer)] = h(producer)
            home = R / 'toolchains/watcom-10.0-ga'
            compiler = home / 'BINB/wcc386.exe'
            if not h(compiler) == r['compiler_sha256']:
                raise ValueError('WAD current callee/source/stock contract')
            pins[str(compiler)] = h(compiler)
            for header, value in r['compiler_headers_sha256'].items():
                q = home / 'H' / header
                if not h(q) == value:
                    raise ValueError('WAD current callee/source/stock contract')
                pins[str(q)] = h(q)
        else:
            from tools.probe_mact_zone import read_provenance
            ze, zs, zpins = read_provenance()
            if not zs == spec:
                raise ValueError('WAD current callee/source/stock contract')
            pins.update(zpins)
            for q, value in {**ze['tracked_sources_sha256'], **ze['producer_tools_sha256'], **ze['notice_files_sha256']}.items():
                if not h(R / q) == value:
                    raise ValueError('WAD current callee/source/stock contract')
                pins[str(R / q)] = value
        proof = r['verification']
        if not (proof['verified'] and all((proof[k] == v for k, v in spec['expected'].items()))):
            raise ValueError('WAD current callee/source/stock contract')
        a = external_anchor_bindings(proof)
        selected = {k: a[k] for k in needed}
        if not all((tuple(selected[k]) == tuple(expected[k]) for k in selected)):
            raise ValueError('WAD current callee/source/stock contract')
        all_.update(selected)
        result[n] = {'receipt_sha256': h(p), 'actual_source_sha256': h(source), 'descriptor_sha256': h(d), 'whole_counts': spec['expected'], 'named_callees': selected}
        pins.update({str(q): h(q) for q in [p, d, source]})
    p = R / 'evidence/mact-crc-module.json'
    r = json.loads(p.read_text())
    d = R / 'modules/mact_crc.json'
    spec = json.loads(d.read_text())
    source = R / r['source']
    generator = R / r['generator']
    need(h(source) == r['source_sha256'] and h(d) == r['descriptor_sha256'] and (h(generator) == r['generator_sha256']) and (r['options'] == spec['options']), 'CRC live source/recipe')
    compiler = R / 'toolchains/watcom-10.0-ga/BINB/wcc386.exe'
    need(h(compiler) == r['compiler_sha256'], 'CRC compiler')
    lineage=R/'evidence/mact-crc-source-reference.json';cr=json.loads(lineage.read_text());table=R/'src/mact/crctable.h';need(h(table)==r['headers_sha256']['crctable.h']and h(table)==cr['table_source_sha256']and cr['source_sha256']==r['source_sha256']and cr['generator_sha256']==r['generator_sha256'],'CRC actual table/source provenance');pins.update({str(lineage):h(lineage),str(table):h(table)})
    proof = r['verification']
    need(proof['verified'] and all((proof[k] == v for k, v in spec['expected'].items())), 'CRC whole proof')
    name = 'CalculateCRC_'
    need(tuple(proof['publics'][name]) == tuple(expected[name]), 'CRC actual named target')
    all_[name] = proof['publics'][name]
    result['mact_crc'] = {'verification': proof, 'named_callee': {name: all_[name]}}
    pins.update({str(q): h(q) for q in [p, d, source, generator, compiler]})
    p = R / 'evidence/watcom-runtime-components.json'
    runtime = json.loads(p.read_text())
    pins[str(p)] = h(p)
    for stem, name in [('set386', 'memset_'), ('strncpy', 'strncpy_'), ('strncmp', 'strncmp_'), ('stricmp', 'strcmpi_'), ('lseek', 'lseek_'), ('printf', 'printf_'), ('sprintf', 'sprintf_'), ('toupper', 'toupper_'), ('nmalloc', 'malloc_')]:
        c = next((c for c in runtime['components'] if c['name'] == stem))
        lib = R / c['library']
        raw = lib.read_bytes()[c['offset']:c['end']]
        if not (len(raw) == c['size'] and hashlib.sha256(raw).hexdigest() == c['sha256']):
            raise ValueError('WAD current callee/source/stock contract')
        m = Module.parse(raw)
        proof = verify_module(m, image, {int(k): v for k, v in c['placements'].items()}, c['verification']['publics'], group_frames={int(k): v for k, v in c['verification']['group_frames'].items()} if 'group_frames' in c['verification'] else None)
        actual = json.loads(json.dumps(proof))
        if not actual == c['verification']:
            raise ValueError((stem, {k: (actual.get(k), c['verification'].get(k)) for k in set(actual) | set(c['verification']) if actual.get(k) != c['verification'].get(k)}))
        if not (name in m.publics and name not in m.local_publics):
            raise ValueError('WAD current callee/source/stock contract')
        if not tuple(proof['publics'][name]) == tuple(expected[name]):
            raise ValueError('WAD current callee/source/stock contract')
        all_[name] = proof['publics'][name]
        result[stem] = {'supplied_original_stock_only': True, 'source_credit': 0, 'verification': proof, 'named_callee': {name: all_[name]}}
        pins[str(lib)] = h(lib)
    if not set(all_) == set(expected):
        raise ValueError('WAD current callee/source/stock contract')
    return (result, pins)
