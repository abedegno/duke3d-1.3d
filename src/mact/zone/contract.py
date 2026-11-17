"""Private ZONE source/COFF/OMF audit. Reads only; never repairs an object.

Closed authored source, qualified true identities, typed CODE pointer tables,
and every translated field are retained. This is not the shared OWN guard.
"""
from pathlib import Path
import ast,hashlib,json,re,struct,sys
from capstone import Cs,CS_ARCH_X86,CS_MODE_32
from capstone.x86 import X86_OP_IMM,X86_OP_MEM
class ContractError(ValueError):pass
def need(ok,why):
    if not ok:raise ContractError(why)
def sha(b):return hashlib.sha256(b).hexdigest()
ROOT=Path(__file__).parent
def constant(text,values):
    tree=ast.parse(text,mode='eval')
    def walk(n):
        if isinstance(n,ast.Constant)and type(n.value)is int:return n.value
        if isinstance(n,ast.Name):need(n.id in values,'unknown constant '+n.id);return values[n.id]
        if isinstance(n,ast.UnaryOp)and isinstance(n.op,ast.USub):return -walk(n.operand)
        if isinstance(n,ast.BinOp):
            a,b=walk(n.left),walk(n.right)
            if isinstance(n.op,ast.Add):return a+b
            if isinstance(n.op,ast.Sub):return a-b
            if isinstance(n.op,ast.Mult):return a*b
        raise ContractError('unsupported pure expression '+text)
    return walk(tree.body)

def preflight(raw,source,listing):
    import importlib.util
    spec=importlib.util.spec_from_file_location('_zone_closed_port',ROOT/'zone_port.py')
    adapter=importlib.util.module_from_spec(spec);spec.loader.exec_module(adapter)
    expected,origins=adapter.expand();need(source==expected,'complete authored source closure')
    need(len(raw)>=340,'COFF header')
    machine,ns,stamp,sp,nt,opt,flags=struct.unpack_from('<HHIIIHH',raw)
    need((machine,ns,opt,flags)==(332,8,0,260),'closed COFF header')
    start=sp+18*nt;need(start+4<=len(raw),'symbol bounds');length=struct.unpack_from('<I',raw,start)[0]
    need(length>=4 and start+length==len(raw),'string geometry/trailing');strings=raw[start:]
    def name(data):
        if data[:4]==bytes(4):
            i=struct.unpack_from('<I',data,4)[0];need(4<=i<len(strings),'string index');z=strings.find(b'\0',i);need(z>=0,'string terminator');n=strings[i:z]
        else:n=data.split(b'\0',1)[0];need(data==n.ljust(8,b'\0'),'short name padding')
        need(n and all(32<c<127 for c in n),'name syntax');return n.decode('ascii')
    sections=[];ranges=[(0,340),(sp,start),(start,len(raw))]
    schema=[('.text',1613758496,'CODE',0),('.data',3224371264,'DATA',0),('.bss',3224371328,'BSS',0),('_TEXT',1611661344,'CODE',2367),('CONST',3222274112,'DATA',1427),('CONST2',3222274112,'DATA',0),('_DATA',3222274112,'DATA',32),('_BSS',3222274176,'BSS',48)]
    for i,(n,attrs,cls,expected_size)in enumerate(schema):
        h=raw[20+40*i:60+40*i];p,v,size,pos,rp,lp,nr,nl,a=struct.unpack_from('<IIIIIIHHI',h,8)
        need((name(h[:8]),p,v,lp,nl,a,size)==(n,0,0,0,0,attrs,expected_size),'closed complete section geometry/schema')
        backed=size>0 and cls!='BSS'
        if not backed:need((pos,rp,nr)==(0,0,0),'closed empty/unbacked BSS')
        else:
            need(340<=pos and pos+size<=sp,'section backing');ranges.append((pos,pos+size))
            need((nr==0 and rp==0)or(nr>0 and 340<=rp and rp+10*nr<=sp),'relocation backing')
            if nr:ranges.append((rp,rp+10*nr))
        sections.append(dict(number=i+1,name=n,class_name=cls,size=size,flags=a,backed=backed,data=raw[pos:pos+size]if backed else bytes(size),relocation_pointer=rp,relocation_count=nr))
    used=set()
    for a,z in ranges:
        need(a<z and z<=len(raw)and not used.intersection(range(a,z)),'file range overlap');used.update(range(a,z))
    need(all(i in used or b==0 for i,b in enumerate(raw)),'unknown file padding')
    # Listing includes every source line and exact full bytes, including pointer tables.
    lines=source.decode('ascii').splitlines();rows={};headers=[]
    for line in listing.splitlines():
        if not line.strip():continue
        if line.startswith('GAS LISTING '):
            m=re.fullmatch(r'GAS LISTING (.+?)\s+page ([1-9][0-9]*)\s*',line)
            need(m is not None and Path(m[1]).name=='ZONE.S'and Path(m[1]).is_absolute()and int(m[2])==len(headers)+1,'listing header');headers.append(m[1]);continue
        if '\t'in line:
            prefix,text=line.split('\t',1);f=prefix.split();need(f and f[0].isdigit()and len(f)in(1,3),'listing row');i=int(f[0]);need(1<=i<=len(lines)and text.rstrip()==lines[i-1].rstrip()and i not in rows,'listing/source identity');rows[i]=dict(line=i,text=lines[i-1],offset=int(f[1],16)if len(f)==3 else None,data=bytes.fromhex(f[2])if len(f)==3 else b'')
        else:
            f=line.split();need(len(f)==2 and f[0].isdigit()and int(f[0])in rows,'listing continuation');rows[int(f[0])]['data']+=bytes.fromhex(f[1])
    need(headers and set(rows)==set(range(1,len(lines)+1)),'complete listing')
    current=1;lc={s['number']:0 for s in sections};defs={};pubs=set();imports=set();constants={};emitted=[]
    for i in range(1,len(lines)+1):
        row=rows[i];text=row['text'].partition('#')[0].strip()
        if text.startswith('.section '):current=next(s['number']for s in sections if s['name']==text.split()[1].split(',')[0])
        if text.startswith('.globl '):pubs.update(text.split()[1].split(','))
        if text.startswith('.extern '):imports.add(text.split()[1])
        if text.startswith('.equ '):n,e=text[5:].split(',',1);need(n not in constants,'duplicate ABS');constants[n]=constant(e,constants)
        if text.endswith(':'):
            n=text[:-1];need(re.fullmatch('[A-Za-z_][A-Za-z_0-9]*',n)and n not in defs,'true source identity');defs[n]=dict(name=n,section=current,value=lc[current],line=i,uses=[])
        if row['offset']is not None:
            need(row['offset']==lc[current],'listing coordinate');s=sections[current-1];need(s['data'][lc[current]:lc[current]+len(row['data'])]==row['data'],'listing/COFF full bytes');row.update(section=current,text=text);lc[current]+=len(row['data']);emitted.append(row)
            if text.startswith('.ascii '):need(row['data']==ast.literal_eval(text[7:]).encode('ascii')and s['name']=='CONST','readable diagnostic literal')
            if text.startswith('.space '):need(s['name']=='_BSS'and int(text[7:])in(4,12)and row['data']==bytes(int(text[7:])),'real unbacked DPMI fields')
            if text.startswith(('.byte ','.short ')):
                width=1 if text.startswith('.byte ')else 2;v=constant(text.split(' ',1)[1],constants);need(0<=v<1<<(8*width)and row['data']==v.to_bytes(width,'little'),'named/formula scalar data')
            if text.startswith('.balign '):
                a,fill=(int(x,0)for x in text[8:].split(','));need(a==4 and fill==(144 if s['class_name']=='CODE'else 0)and len(row['data'])<4 and row['data']==bytes([fill])*len(row['data'])and lc[current]%4==0,'ordinary4alignment')
    need(all(lc[s['number']]==s['size']for s in sections),'complete source byte ownership')
    syms=[];primary={};structural=set();i=0
    while i<nt:
        b=raw[sp+18*i:sp+18*(i+1)];v,sec,typ,cls,aux=struct.unpack_from('<IhHBB',b,8);need(i+aux<nt,'aux bounds');n=name(b[:8]);ar=[raw[sp+18*(i+j+1):sp+18*(i+j+2)]for j in range(aux)]
        if cls==103:need(i==0 and n=='.file'and(sec,v,typ,aux)==(-2,0,0,1)and ar==[b'zone.S'.ljust(18,b'\0')],'FILE schema');kind='file'
        elif cls==3 and aux==1:
            need(1<=sec<=8 and sec not in structural and v==typ==0,'section symbol');s=sections[sec-1];need(n==s['name']and ar==[struct.pack('<IHHIhB3s',s['size'],s['relocation_count'],0,0,0,0,bytes(3))],'section aux');structural.add(sec);kind='structural'
        elif sec==-1:need(n in constants and(v,typ,cls,aux)==(constants[n],0,3,0),'ABS source identity');kind='absolute'
        elif sec==0:need(n in imports and(v,typ,cls,aux)==(0,0,2,0),'import scope/schema');kind='external'
        else:
            need(n in defs and(sec,v)==(defs[n]['section'],defs[n]['value'])and typ==aux==0 and cls==(2 if n in pubs else 3),'public/private complete identity');kind='public'if n in pubs else'private'
        s=dict(index=i,name=n,value=v,section=sec,type=typ,storage_class=cls,aux_count=aux,kind=kind,raw_hex=b.hex(),aux_raw_hex=[x.hex()for x in ar]);syms.append(s);primary[i]=s;i+=1+aux
    need(structural=={1,2,3,4,5,7,8},'exact structural identities; empty unreferenced CONST2 has no native primary symbol')
    for k,names in [('public',pubs),('external',imports),('absolute',set(constants)),('private',set(defs)-pubs)]:need({s['name']for s in syms if s['kind']==k}==names,'complete '+k+' identity')
    relocations=[];coverage=set();md=Cs(CS_ARCH_X86,CS_MODE_32);md.detail=True;uses=[];branches=[]
    for s in sections:
        for j in range(s['relocation_count']):
            off,idx,k=struct.unpack_from('<IIH',raw,s['relocation_pointer']+10*j);need(k in(6,20)and idx in primary and off+4<=s['size']and(s['number'],off)not in coverage,'COFF typed field')
            p=primary[idx];need(p['kind']in('structural','external')and p['value']==0,'folded section or external only; no directV assumption');a=int.from_bytes(s['data'][off:off+4],'little');r=dict(segment=s['number'],offset=off,type=k,target_name=p['name'],target_section=p['section'],target_index=idx,inline_A=a);relocations.append(r)
            need(not any((s['number'],x)in coverage for x in range(off,off+4)),'field overlap');coverage.update((s['number'],x)for x in range(off,off+4))
    associated=set()
    for row in emitted:
        text=row['text'];payload=row['data'];section=row['section'];off=row['offset'];symbols=[n for n in list(defs)+list(imports)if re.search(r'(?<![A-Za-z_0-9])'+re.escape(n)+r'(?![A-Za-z_0-9])',text)]
        fields=[r for r in relocations if r['segment']==section and off<=r['offset']<off+len(payload)]
        if text.startswith('.long '):
            args=[x.strip()for x in text[6:].split(',')];need(section==7 and len(payload)==4*len(args)and not fields and all(constant(x,constants)==0 for x in args)and payload==bytes(len(payload)),'real initialized eight-pointer owner')
            continue
        if not symbols:need(not fields,'field without named source');continue
        ins=list(md.disasm(payload,off));need(len(ins)==1 and ins[0].size==len(payload),'one complete symbolic instruction');ins=ins[0]
        for n in symbols:
            d=defs.get(n,dict(section=0,value=0));pos=text.index(n);memory=text.rfind('[',0,pos)>text.rfind(']',0,pos)
            if not fields:
                need(d['section']==section==4 and len(symbols)==1 and text.split()[-1]==n and ins.mnemonic in('call','jmp','ja','jae','jb','jbe','je','jne','jg','jge','jl','jle')and len(ins.operands)==1 and ins.operands[0].type==X86_OP_IMM and ins.operands[0].imm==d['value'],'resolved named branch target');branches.append(dict(name=n,line=row['line'],source=off,target=d['value'],bytes=payload.hex()));defs[n]['uses'].append(row['line']);continue
            if memory:
                field=off+ins.disp_offset;width=ins.disp_size;expression=text[text.rfind('[',0,pos)+1:text.index(']',pos)]
                # Source addend expression has exactly one symbol plus real registers.
                vals=dict(constants);vals[n]=0
                for reg in('eax','ebx','ecx','edx','esi','edi','ebp','esp'):vals[reg]=0
                delta=constant(expression,vals)
                mem=[o.mem for o in ins.operands if o.type==X86_OP_MEM];need(len(mem)==1,'one memory operand')
                expected_regs={}
                for reg in('eax','ebx','ecx','edx','esi','edi','ebp','esp'):
                    values=dict(vals);values[reg]=1;coefficient=constant(expression,values)-delta
                    if coefficient:expected_regs[reg]=coefficient
                actual_regs={}
                for register,coefficient in[(mem[0].base,1),(mem[0].index,mem[0].scale)]:
                    if register:
                        register=ins.reg_name(register);actual_regs[register]=actual_regs.get(register,0)+coefficient
                need(expected_regs==actual_regs,'source base/index/scale geometry')
                need(ins.reg_name(mem[0].segment)=='cs'if 'cs:['in text else mem[0].segment==0,'exact explicit segment override')
            else:
                need(text=='call '+n or 'OFFSET FLAT:'+n in text,'externalCALL or actual address immediate');field=off+ins.imm_offset;width=ins.imm_size;delta=0
            f=next((r for r in fields if r['offset']==field),None);need(width==4 and f is not None and f['target_section']==d['section']and f['inline_A']==((d['value']+delta)&0xffffffff)and f['type']==(20 if text=='call '+n else 6),'source V+addend and exact typed field')
            associated.add((section,field));u=dict(name=n,line=row['line'],kind='instruction-address',field=f,source_value=d['value'],source_addend=delta,origin=origins[row['line']-1]);uses.append(u)
            if n in defs:defs[n]['uses'].append(row['line'])
    need(associated=={(r['segment'],r['offset'])for r in relocations},'all field source roles; missing '+repr([r for r in relocations if(r['segment'],r['offset'])not in associated]))
    return dict(version='private-zone-v1',source_sha256=sha(source),coff_sha256=sha(raw),listing_sha256=sha(listing.encode()),sections=sections,symbols=syms,definitions=defs,constants=constants,relocations=relocations,symbolic_uses=uses,resolved_branches=branches,origins=origins)

def postflight(raw_coff,source,listing,raw,receipt):
    need(receipt==preflight(raw_coff,source,listing),'preflight receipt identity/recomputation')
    from omf32 import Module,Cursor
    from dataclasses import asdict
    at=0;segdefs=0
    while at<len(raw):
        need(at+3<=len(raw),'output record header before allocation')
        kind=raw[at];length=int.from_bytes(raw[at+1:at+3],'little');end=at+3+length
        need(length>0 and end<=len(raw)and sum(raw[at:end])%256==0 and kind in(128,150,153,154,140,145,161,157,138),'output record before allocation')
        if kind==153:
            need(segdefs<len(receipt['sections']),'extra output section before allocation');s=receipt['sections'][segdefs];c=Cursor(raw[at+3:end-1]);attr,size=c.uint(1),c.uint(4)
            need((attr,size)==(169 if segdefs<3 else 41,s['size'])and(c.index(),c.index(),c.index())==(6+segdefs,{'CODE':2,'DATA':3,'BSS':4}[s['class_name']],0)and not c.left(),'output source geometry before allocation');segdefs+=1
        at=end
    need(segdefs==len(receipt['sections']),'missing output section before allocation')
    m=Module.parse(raw)
    need(m.format=='standard-omf'and m.groups==[('FLAT',())],'standard output/FLAT')
    need(not(m.local_publics or m.local_externals or m.comments or m.default_libraries or m.line_numbers or m.thread_definitions or m.code_data_ranges or m.dosseg_directives or m.far_call_optimization_segments),'no output scope/metadata erasure')
    publics={s['name']:(s['section'],s['value'])for s in receipt['symbols']if s['kind']=='public'};externals=[s['name']for s in receipt['symbols']if s['kind']=='external'];need(m.publics==publics and m.externals==externals,'all public/import identities')
    need(len(m.segments)==len(receipt['sections']),'output geometry count')
    for s,t in zip(receipt['sections'],m.segments):need((t.name,t.class_name,t.size,t.attributes,t.access,bytes(t.data))==(s['name'],s['class_name'],s['size'],169 if s['number']<=3 else 41,None,s['data']),'complete unpatched bytes/section geometry')
    expected=[]
    for r in receipt['relocations']:
        ext=r['target_section']==0
        expected.append(dict(segment=r['segment'],offset=r['offset'],width=4,location=9,relative=r['type']==20,frame_method=5 if ext else 1,frame=None if ext else 1,target_method=2 if ext else 0,target=externals.index(r['target_name'])+1 if ext else r['target_section'],displacement=0))
    need([asdict(f)for f in m.fixups]==expected,'all typed converter equations')
    need(len(m.fixup_encodings)==len(expected),'all encoded fields')
    for e,f in zip(m.fixup_encodings,expected):need(e['record_kind']==157 and e['raw_location']==9 and not e['frame_thread']and not e['target_thread']and not e['displacement_present']and e['raw_fixdat']==((f['frame_method']<<4)|4|f['target_method']),'raw encoded choices')
    # Raw record coverage, checksums, no unrecognized record silently discarded.
    p=0;coverage=[set()for s in m.segments];records=[]
    while p<len(raw):
        k=raw[p];n=int.from_bytes(raw[p+1:p+3],'little');z=p+3+n;need(n>0 and z<=len(raw)and sum(raw[p:z])%256==0 and k in(128,150,153,154,140,145,161,157,138),'raw output record contract');body=raw[p+3:z-1]
        if k==161:
            # The measured five segments use one-byte indices.
            seg=body[0];off=int.from_bytes(body[1:5],'little');span=set(range(off,off+len(body)-5));need(1<=seg<=8 and span and not span&coverage[seg-1]and max(span)<m.segments[seg-1].size,'LEDATA full nonoverlap');coverage[seg-1].update(span)
        if k==138:need(body==b'\0'and z==len(raw),'sole final MODEND')
        records.append(dict(kind=k,offset=p,length=n,sha256=sha(raw[p:z])));p=z
    need(all(c==(set()if s.class_name=='BSS'else set(range(s.size)))for c,s in zip(coverage,m.segments)),'all bytes serialized once')
    return dict(version='private-zone-v1',coff_sha256=receipt['coff_sha256'],omf_sha256=sha(raw),all_bytes_exact=True,typed_fixups=expected,encoded_fixups=m.fixup_encodings,raw_records=records,private_identities=[dict(**s,translation_unit='zone:'+receipt['source_sha256'],qualified_identity='zone:'+receipt['source_sha256']+':'+str(s['index']),source=receipt['definitions'][s['name']],output_coordinate=[s['section'],s['value']],output_name_record=None)for s in receipt['symbols']if s['kind']=='private'],absolute_identities=[s for s in receipt['symbols']if s['kind']=='absolute'],source_credit=0)
