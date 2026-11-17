"""Source and native-scope contract; all guards survive Python -O."""
from pathlib import Path
import json,hashlib,re
B=Path(__file__).resolve().parent
NAMES=('IRQ.ASM','irq.c','irq.h','i86.h')
def need(c,m):
    if not c:raise ValueError(m)
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def check_pins(pins):
    for p,h in pins.items():need(Path(p).is_file() and not Path(p).is_symlink() and sha(p)==h,'pinned input/output changed: '+p)
def model():return json.loads((B/'source-model.json').read_text())
def source_contract(source):
    source=Path(source);schema=model()
    need(set(p.name for p in source.iterdir())==set(NAMES)|{'contract.py','source-model.json','README.md','gpl.txt'},'closed source files')
    need(all((source/n).is_file() and not (source/n).is_symlink() for n in NAMES),'regular source inputs')
    for n,h in schema['primary_headers_sha256'].items():need(sha(source/n)==h,'primary header pin: '+n)
    aid=(source/'irq.c').read_text();pattern=r'(irq_state\.Regs\.w\.ax\s*=\s*)(0x[0-9a-fA-F]+);';values=list(re.finditer(pattern,aid))
    # Only the first actual Get Protected Mode Vector request can vary.
    need(values and int(values[0][2],16) in (0x0204,0x0205),'first DPMI service source family')
    service=int(values[0][2],16);start,end=values[0].span(2);normalized=aid[:start]+'DPMI_SERVICE'+aid[end:]
    need(hashlib.sha256(normalized.encode()).hexdigest()==schema['C_aid_service_normalized_sha256'],'complete retained C aid semantic family')
    text=(source/'IRQ.ASM').read_text();statements=[x.split(';',1)[0].strip() for x in text.splitlines() if x.split(';',1)[0].strip()]
    expected=[('DPMI_GET_PROTECTED_VECTOR equ '+hex(service)) if x.startswith('DPMI_GET_PROTECTED_VECTOR equ ') else x for x in schema['statements']]
    # Accept cosmetic leading zero in semantic hex spelling only.
    statements=[('DPMI_GET_PROTECTED_VECTOR equ '+hex(int(x.split()[-1],0))) if x.startswith('DPMI_GET_PROTECTED_VECTOR equ ') else x for x in statements]
    need(statements==expected,'finite complete NASM statement/operand-owner grammar')
    return {'get_protected_vector_service':service}
def native_contract(m):
    schema=model();need([[s.name,s.class_name,s.size,s.attributes,s.access] for s in m.segments]==schema['expected_real_segments'],'original real native segment size/alignment/access')
    need(m.publics=={n:tuple(v) for n,v in schema['native_publics'].items()},'exact original global public names/sections/offsets')
    need(m.groups==[('DGROUP',(2,3,4,5)),('FLAT',())],'original genuine group memberships')
    need(not m.local_publics and not m.local_externals,'no private promotion or artificial local imports')
    need(m.externals==['int386_','int386x_','__GETDS'],'only genuine external import vector')
    need(len(m.fixups)==102,'102 actual native fields; one private call genuinely resolved')
    need(not any(m._segment(5).data),'real BSS zero')
