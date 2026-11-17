"""Closed GAME source/ELF/COFF/native attribution; never generates instructions."""
from pathlib import Path
import ast,re,json,hashlib,struct,dataclasses,bisect
MODEL_SHA256='833e29fd844363fa361fddf6efc9a76c34a9971bc228a77f5402bb63afe7e75e'
REGISTERS=set('eax ebx ecx edx esi edi esp ebp ax bx cx dx si di sp bp al ah bl bh cl ch dl dh cs ds es fs gs ss eiz'.split())
def need(q,message):
    if not q:raise ValueError('GAME symbolic '+message)
def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def model():
    p=Path(__file__).with_name('contract-model.json');raw=p.read_bytes();need(hashlib.sha256(raw).hexdigest()==MODEL_SHA256,'closed model identity');return json.loads(raw)
def statement(line):
    quote=None;escape=False
    for i,c in enumerate(line):
        if escape:escape=False;continue
        if c=='\\'and quote:escape=True;continue
        if quote:
            if c==quote:quote=None
        elif c in('\"',"'"):quote=c
        elif c=='#':return line[:i].strip()
    need(quote is None,'unterminated source string');return line.strip()
def operands(value):
    # Commas only separate this finite Intel syntax; no tuple/parenthesis
    # displacement spellings are admitted outside the one memory bracket.
    return [p.strip()for p in value.split(',')]
def operand_plan(text,runtime,absolute):
    runtime=set(runtime);absolute=dict(absolute);result=[];mode='intel'
    def expression(value):
        occurrences=[]
        def linear(n):
            if isinstance(n,ast.Constant)and type(n.value)is int:return{},n.value
            if isinstance(n,ast.Name):
                need(n.id in runtime|REGISTERS|set(absolute),'unknown operand symbol '+n.id)
                if n.id in runtime:occurrences.append(n.id);return{n.id:1},0
                if n.id in absolute:return{},absolute[n.id]
                return{n.id:1},0
            if isinstance(n,ast.UnaryOp)and isinstance(n.op,(ast.UAdd,ast.USub)):
                d,c=linear(n.operand);k=-1 if isinstance(n.op,ast.USub)else 1;return{q:k*v for q,v in d.items()},k*c
            if isinstance(n,ast.BinOp)and isinstance(n.op,(ast.Add,ast.Sub,ast.Mult)):
                a,x=linear(n.left);b,y=linear(n.right)
                if isinstance(n.op,ast.Mult):
                    need(not(a and b),'nonlinear address expression');return({q:v*y for q,v in a.items()},x*y)if a else({q:v*x for q,v in b.items()},x*y)
                k=-1 if isinstance(n.op,ast.Sub)else 1;d=dict(a)
                for q,v in b.items():d[q]=d.get(q,0)+k*v
                return d,x+k*y
            need(False,'unsupported operand expression')
        try:d,c=linear(ast.parse(value,mode='eval').body)
        except SyntaxError as e:raise ValueError('GAME symbolic invalid operand expression')from e
        if not occurrences:return None
        need(len(occurrences)==1,'competing/canceled/repeated runtime owner');owner=occurrences[0];need(d.get(owner)==1,'runtime owner coefficient +1');return{'owner':owner,'addend':c,'register_terms':{q:v for q,v in sorted(d.items())if q in REGISTERS and v}}
    for line,raw in enumerate(text.splitlines(),1):
        t=statement(raw)
        if t=='.att_syntax prefix':mode='att';continue
        if t=='.intel_syntax noprefix':mode='intel';continue
        if not t or t.endswith(':'):continue
        if t.startswith('.long '):parts=operands(t[6:])
        elif t.startswith('.'):continue
        else:
            t=re.sub(r'^(?:\{(?:load|store|disp8|disp32)\}\s*)+','',t)
            t=re.sub(r'^(?:rep|repe|repne)\s+','',t)
            if ' 'not in t:continue
            parts=operands(t.split(None,1)[1])
        for number,part in enumerate(parts):
            if mode=='att':
                need(not(set(re.findall(r'[A-Za-z_][A-Za-z_0-9]*',part))&runtime),'no runtime field in finite AT&T immediate syntax');part=part.removeprefix('$').removeprefix('%')
            if '['in part or']'in part:
                match=re.fullmatch(r'(?:(?:byte|word|dword)\s+ptr\s+)?(?:(?:cs|ds|es|ss|fs|gs):\s*)?\[([^\[\]]+)\]',part)
                need(match is not None,'complete memory operand grammar; no ignored prefix/suffix');expr=match[1]
            else:expr=part.removeprefix('OFFSET FLAT:')
            p=expression(expr)
            if p:result.append({'line':line,'operand':number,**p})
    return result

def source_preflight(text,spec=None):
    spec=model()if spec is None else spec;defs={};absolute={};public=set();imports=set();private=set();section=None;data=[];align=[]
    sections={'_TEXT','CONST','CONST2','_DATA','_BSS'}
    for line,raw in enumerate(text.splitlines(),1):
        t=statement(raw)
        if not t:continue
        if t.endswith(':'):
            name=t[:-1];need(re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*',name)is not None and name not in defs and name not in absolute and section in sections,'unique real definition');defs[name]=section;continue
        if t.startswith('.section '):
            need(t in['.section _TEXT,"ax",@progbits','.section CONST,"aw",@progbits','.section CONST2,"aw",@progbits','.section _DATA,"aw",@progbits','.section _BSS,"aw",@nobits'],'only five genuine named sections');section=t.split()[1].split(',')[0]
        elif t.startswith(('.globl ','.extern ','.local ')):
            key,values=t.split(None,1);names=values.split(',');need(all(re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*',n)for n in names),'declaration spelling');target={'.globl':public,'.extern':imports,'.local':private}[key]
            need(not(set(names)&target),'duplicate declaration');target.update(names)
        elif t.startswith('.equ '):
            m=re.fullmatch(r'\.equ ([A-Za-z_][A-Za-z_0-9]*), (-?(?:[0-9]+|0x[0-9a-fA-F]+))',t);need(m is not None,'only genuine numeric mathematical ABS');name=m[1];need(name not in defs and name not in absolute,'duplicate ABS');absolute[name]=int(m[2],0)
        elif t.startswith('.p2align '):need((section,t)in[('_TEXT','.p2align 4'),('_BSS','.p2align 4'),('CONST','.p2align 2'),('CONST2','.p2align 2'),('_DATA','.p2align 2')],'actual alignment only');align.append([line,section,t])
        elif t.startswith(('.ascii ','.byte ','.short ','.long ','.zero ')):
            need(section in sections and section!='CONST2','real data section');data.append([line,section,t])
            if t.startswith('.ascii '):need(section in('CONST','_DATA'),'no instruction string payload');need(type(ast.literal_eval(t[7:]))is str,'one logical literal capacity')
            if section=='_TEXT':need(t.startswith(('.zero ','.long '))and[line,section,t]in spec['CODE_data_rows'],'only actual C initializers and typed case tables, no opcode arrays')
            if section=='_BSS':need(t.startswith('.zero ')and re.fullmatch(r'\.zero [0-9]+',t)is not None,'only real zero-fill declarations')
        elif t.startswith('.'):
            need(t in['.intel_syntax noprefix','.att_syntax prefix','.code32','.file "GAME.S"','.allow_index_reg'],'unsupported directive/runtime alias')
        else:need(section=='_TEXT','instruction outside CODE')
    need(defs==spec['source_definitions']and absolute==spec['absolute_constants'],'all real source definitions/numeric values only');need(sorted(public)==spec['declared_globals']and sorted(imports)==spec['declared_imports']and sorted(private)==spec['declared_private'],'exact genuine global/import/private declarations');need(data==spec['data_rows']and align==spec['align_rows'],'all real typed data/storage/capacities');runtime=set(defs)|imports|sections|{'.text','.data','.bss'};plan=operand_plan(text,runtime,absolute);need(plan==spec['operand_roles'],'every entire operand has its genuine owner and coefficient');return defs,plan

def parse_listing(text,listing):
    lines=text.splitlines();rows={}
    for raw in listing.splitlines():
        if raw.startswith('GAS LISTING ')or not raw.strip():continue
        if '\t'in raw:
            lead,t=raw.split('\t',1);f=lead.split();need(f and f[0].isdigit()and len(f)in(1,3),'listing row');n=int(f[0]);need(1<=n<=len(lines)and t.rstrip()==lines[n-1].rstrip()and n not in rows,'native full source listing');rows[n]={'line':n,'text':lines[n-1],'offset':int(f[1],16)if len(f)==3 else None,'data':bytes.fromhex(f[2])if len(f)==3 else b''}
        else:
            f=raw.split();need(len(f)==2 and f[0].isdigit()and int(f[0])in rows,'listing continuation');rows[int(f[0])]['data']+=bytes.fromhex(f[1])
    need(set(rows)==set(range(1,len(lines)+1)),'listing complete source lines');return rows

def preflight(path,text,listing,e):
    raw_elf(path);spec=model();defs,plan=source_preflight(text,spec);sections={q['name']:q for q in e['sections']};by={q['name']:q for tab in e['symbols'].values()for q in tab if q['name']}
    all_symbols=[q for tab in e['symbols'].values()for q in tab];need(len([q for q in all_symbols if q['name']])==len(by),'unique complete ELF named identities');need([q for q in all_symbols if not q['name']]==spec['ELF_unnamed_symbols'],'all actual null/section identity records');actual={n:{k:q[k]for k in['value','size','binding','type','other','section']}for n,q in by.items()};need(actual==spec['ELF_named_symbols'],'all native qualified symbols/scopes/ABS values');need(all(q['binding']in(0,1)and q['other']==0 and q['type']in(0,3,4)for tab in e['symbols'].values()for q in tab),'no weak/TLS/hidden/COMMON/unsupported identity');need({q['name']:{k:q[k]for k in['type','flags','size','align','backed']}for q in e['sections']}==spec['ELF_sections'],'exact ELF sections/type/flags/extent/alignment');need(len(e['relocations'])==5018,'all actual fields');fields={(r['source_section'],r['offset']):r for r in e['relocations']};need(len(fields)==5018,'unique ELF field set');need(all(r['type']in(1,2)and r['source_section']==sections['_TEXT']['index']for r in fields.values()),'only actual CODE ABS32/PC32 fields')
    rows=parse_listing(text,listing);current=None;at={q['index']:0 for q in e['sections']};owned=[];instructions=[];prefix=None;byline={}
    for p in plan:byline.setdefault(p['line'],[]).append(p)
    from capstone import Cs,CS_ARCH_X86,CS_MODE_32
    md=Cs(CS_ARCH_X86,CS_MODE_32);md.detail=True
    for line,row in rows.items():
        t=statement(row['text'])
        if t.startswith('.section '):current=sections[t.split()[1].split(',')[0]]['index']
        if t.endswith(':'):
            q=by[t[:-1]];need((q['section'],q['value'])==(current,at[current]),'physical source identity coordinate '+t[:-1])
        if row['offset']is None:continue
        payload=row['data'];need(current is not None and row['offset']==at[current],'complete contiguous source backing')
        if t.startswith('.ascii '):payload=ast.literal_eval(t[7:]).encode('latin1')
        if t.startswith('.zero '):payload=bytes(int(t[6:],0))
        q=e['sections'][current]
        if q['type']!=8:need(bytes.fromhex(q['bytes'])[row['offset']:row['offset']+len(payload)]==payload,'full native listing section backing')
        row.update(section=current,data=payload.hex());at[current]+=len(payload);owned.append(row)
        if current==sections['_TEXT']['index']and not t.startswith('.'):
            if t=='rep':need(prefix is None and payload==b'\xf3','genuine REP instruction prefix');prefix=row;continue
            start=row['offset'];block=payload
            if prefix:need(prefix['offset']+len(bytes.fromhex(prefix['data']))==start,'contiguous real prefix');start=prefix['offset'];block=bytes.fromhex(prefix['data'])+payload;prefix=None
            ins=list(md.disasm(block,start));need(len(ins)==1 and ins[0].size==len(block),'one complete real mnemonic; no encoded payload');instructions.append({'line':line,'offset':start,'size':len(block)})
    need(prefix is None,'complete final instruction');need(all(at[sections[n]['index']]==sections[n]['size']for n in['_TEXT','CONST','CONST2','_DATA','_BSS']),'all real segment ends owned');need(len(instructions)==spec['instruction_count'],'all actual instructions')
    # Source owners are bound to actual displacement/immediate fields. Two-field
    # MOVs get two separate source operands, never a dropped second field.
    startrows=sorted((q for q in owned if q['section']==sections['_TEXT']['index']),key=lambda q:q['offset']);starts=[q['offset']for q in startrows];roles=[]
    from capstone.x86 import X86_OP_MEM,X86_OP_IMM
    for key,r in fields.items():
        pos=bisect.bisect_right(starts,r['offset'])-1;need(pos>=0,'field source row');row=startrows[pos];payload=bytes.fromhex(row['data']);need(row['offset']<=r['offset']and r['offset']+4<=row['offset']+len(payload),'complete field inside source statement');t=statement(row['text'])
        if t.startswith('.long '):operand=(r['offset']-row['offset'])//4
        else:
            ins=list(md.disasm(payload,row['offset']));need(len(ins)==1,'complete field instruction');i=ins[0];delta=r['offset']-i.address
            if delta==i.disp_offset and i.disp_size==4:c=[k for k,v in enumerate(i.operands)if v.type==X86_OP_MEM]
            elif delta==i.imm_offset and i.imm_size==4:c=[k for k,v in enumerate(i.operands)if v.type==X86_OP_IMM]
            else:need(False,'actual field must be complete displacement/immediate')
            need(len(c)==1,'one source operand per actual field');operand=c[0]
        candidates=[p for p in byline.get(row['line'],[])if p['operand']==operand];need(len(candidates)==1,'one genuine entire operand owner');p=candidates[0];owner=by[p['owner']];symbol=r['symbol'];add=(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff
        if symbol['binding']==1:need(symbol['name']==p['owner']and add==(p['addend']&0xffffffff),'actual GLOBAL/import owner equation')
        else:need(symbol['type']==3 and owner['binding']==0 and owner['section']==symbol['section']and(symbol['value']+add)&0xffffffff==(owner['value']+p['addend'])&0xffffffff,'genuine private section+V equation')
        roles.append({'field':r['offset'],'section':r['source_section'],'source_operand':p,'ELF':r})
    return{'all_source_definitions':defs,'instructions':len(instructions),'all5018_fields':roles,'source_rows':owned,'all_real_section_bytes_owned':True}

def inventory(m):
    need(set(vars(m))=={'name','segments','publics','local_publics','externals','local_externals','groups','fixups','default_libraries','far_call_optimization_segments','comments','dosseg_directives','code_data_ranges','line_numbers','format','format_source','fixup_encodings','thread_definitions','source_records'},'complete native metadata schema')
    encoded=json.dumps(m.fixup_encodings,sort_keys=True,default=lambda q:{'bytes':bytes(q).hex()}).encode()
    return{'fixup_encodings_sha256':hashlib.sha256(encoded).hexdigest(),'source_records':m.source_records,'name':m.name,'segments':[[q.name,q.class_name,q.size,q.attributes,q.access]for q in m.segments],'publics':{n:list(v)for n,v in m.publics.items()},'local_publics':sorted(m.local_publics),'externals':m.externals,'local_externals':sorted(m.local_externals),'groups':[[n,list(v)]for n,v in m.groups],'fixups':[dataclasses.asdict(q)for q in m.fixups],'default_libraries':m.default_libraries,'far_call_optimization_segments':m.far_call_optimization_segments,'comments':[[k,v.hex()]for k,v in m.comments],'dosseg_directives':m.dosseg_directives,'code_data_ranges':m.code_data_ranges,'line_numbers':m.line_numbers,'format':m.format,'format_source':m.format_source,'thread_definitions':m.thread_definitions}
def postflight(e,m,pre):
    spec=model();need(inventory(m)==spec['native_inventory'],'all native scope/PUB coordinates/segments/classes/access/imports/groups/typed fields');sections={q.name:i+1 for i,q in enumerate(m.segments)};ef={(e['sections'][r['source_section']]['name'],r['offset']):r for r in e['relocations']};mf={(m._segment(f.segment).name,f.offset):f for f in m.fixups};need(len(m.fixups)==len(mf)==len(ef)==5018 and set(mf)==set(ef),'complete unique ELF/native field bijection')
    for section in m.segments:
        need(hashlib.sha256(bytes(section.data)).hexdigest()==spec['native_data_sha256'][section.name],'all actual source native bytes '+section.name)
    for key,r in ef.items():
        f=mf[key];need((f.width,f.location,f.relative)==(4,9,r['type']==2),'native complete field geometry');add=(int.from_bytes(m._segment(f.segment).data[f.offset:f.offset+4],'little')+f.displacement)&0xffffffff;need(add==(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff,'ELF/native addend identity');symbol=r['symbol']
        if symbol['binding']==1:need(f.target_method==2 and m.externals[f.target-1]==symbol['name']and(f.frame_method,f.frame)==(5,None),'native GLOBAL/import identity')
        else:need(f.target_method==0 and m._segment(f.target).name==e['sections'][symbol['section']]['name']and(f.frame_method,f.frame)==(1,2),'native LOCAL section+V/FLAT frame')
    return{'all5018_complete_unique_source_ELF_native_roles':True,'all109_native_PUBLIC_coordinates_and_true_scope':True,'all_native_runtime_bytes_retained':True,'source_credit':0}

def raw_elf(path):
 b=path.read_bytes();need(b[:16]==b'\x7fELF\x01\x01\x01'+bytes(9),'ELF32 little-endian identity')
 h=struct.unpack_from('<HHIIIIIHHHHHH',b,16);need(h[:5]==(1,3,1,0,0)and h[6:]==(0,52,0,0,40,13,12),'closed ET_REL i386 header')
 need(h[5]+40*h[11]==len(b),'complete ELF ends at section headers');headers=[struct.unpack_from('<IIIIIIIIII',b,h[5]+40*i)for i in range(h[11])];need(headers[0]==(0,)*10,'null section')
 covered=set(range(52))|set(range(h[5],len(b)))
 for i,q in enumerate(headers[1:],1):
  name,kind,flags,addr,off,size,link,info,align,entry=q;need(addr==0 and kind in(1,2,3,8,9)and align in(1,4,16),'unsupported section attributes')
  if kind==9:need((flags,link,info,align,entry)==(64,10,4,4,8)and size%8==0,'exact relocation schema')
  elif kind==2:need((flags,link,align,entry)==(0,11,4,16)and size%16==0,'exact symbol schema');need(b[off:off+16]==bytes(16),'null symbol')
  else:need(link==info==entry==0,'unexpected section link/entry metadata')
  if kind==8 or size==0:continue
  need(52<=off<=off+size<=h[5],'ET_REL file backing (runtime alignment is sh_addralign)' );r=set(range(off,off+size));need(not covered&r,'overlapping ELF ranges');covered|=r
 need(all(i in covered or v==0 for i,v in enumerate(b)),'substantive unowned ELF bytes');return {'bytes':len(b),'section_headers':13,'all_substantive_file_bytes_owned':True}
