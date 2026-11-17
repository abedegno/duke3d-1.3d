"""Module-local closed source/ELF/native attribution for CONTROL; no rewriting."""
import re,hashlib,ast,struct
PUBLICS=set('CONTROL_Ack_ CONTROL_ApplyAxis_ CONTROL_AxisFunctionState_ CONTROL_ButtonFunctionState_ CONTROL_CenterJoystick_ CONTROL_CheckRange_ CONTROL_ClearAssignments_ CONTROL_ClearButton_ CONTROL_ClearFlags_ CONTROL_ClearKeyboardFunction_ CONTROL_ClearUserInput_ CONTROL_DefineFlag_ CONTROL_DigitizeAxis_ CONTROL_ExternalSetup_ CONTROL_ExternalStartup_ CONTROL_FilterJoyDelta_ CONTROL_FlagActive_ CONTROL_GetDeviceButtons_ CONTROL_GetInput_ CONTROL_GetJoyAbs_ CONTROL_GetJoyDelta_ CONTROL_GetMouseButtons_ CONTROL_GetMouseDelta_ CONTROL_GetMouseSensitivity_ CONTROL_GetTime_ CONTROL_GetUserInput_ CONTROL_JoyButtons_ CONTROL_KeyboardFunctionPressed_ CONTROL_MapAnalogAxis_ CONTROL_MapButton_ CONTROL_MapDigitalAxis_ CONTROL_MapKey_ CONTROL_PollDevices_ CONTROL_PollExternalControl_ CONTROL_PrintAxes_ CONTROL_PrintControlFlag_ CONTROL_PrintKeyMap_ CONTROL_ScaleAxis_ CONTROL_SetAnalogAxisScale_ CONTROL_SetFlag_ CONTROL_SetJoyScale_ CONTROL_SetMouseSensitivity_ CONTROL_SetupJoy_ CONTROL_ShutJoy_ CONTROL_Shutdown_ CONTROL_StartJoy_ CONTROL_StartMouse_ CONTROL_Startup_ CONTROL_WaitRelease_ _CONTROL_ButtonHeldState1 _CONTROL_ButtonHeldState2 _CONTROL_ButtonState1 _CONTROL_ButtonState2 _CONTROL_ExternalEnabled _CONTROL_JoysPresent _CONTROL_JoystickEnabled _CONTROL_JoystickPort _CONTROL_MouseEnabled _CONTROL_MousePresent _CONTROL_RudderEnabled'.split())
IMPORTS=set('MOUSE_GetDelta_ MOUSE_GetButtons_ MOUSE_Init_ _Joy_mask JoyStick_Vals_ _Joy_x2 _Joy_y2 _Joy_x1 _Joy_y1 memset_ CheckParm_ printf_ __argv atol_ int386_ Error_ _KB_KeyDown ServiceEvents_ MOUSE_Shutdown_'.split())
PRIVATE=set('_CONTROL_Axes _CONTROL_AxesMap _CONTROL_AxesScale _CONTROL_ButtonClicked _CONTROL_ButtonClickedCount _CONTROL_ButtonClickedState _CONTROL_ButtonClickedTime _CONTROL_DeviceButtonMapping _CONTROL_DeviceButtonState _CONTROL_DoubleClickSpeed _CONTROL_External _CONTROL_Flags _CONTROL_FlightStickMode _CONTROL_HatEnabled _CONTROL_JoyXAxis _CONTROL_JoyXAxis2 _CONTROL_JoyYAxis _CONTROL_JoyYAxis2 _CONTROL_KeyMapping _CONTROL_LastAxes _CONTROL_MouseSensitivity _CONTROL_NumAxes _CONTROL_NumButtons _CONTROL_Started _CONTROL_ThrottleEnabled _CONTROL_UserInputCleared _CONTROL_UserInputDelay _GetTime _JoyDefs _ticrate'.split())
def need(x,msg):
 if not x:raise ValueError(msg)
def source_preflight(text,model):
 check_operand_owners(text)
 need(not re.search(r'(?im)^\s*(?:\.org|\.incbin|\.byte|\.word|\.short)\b',text.replace('.byte 0','')),'instruction/data payload directive')
 publics=set();imports=set();defs={};section=None;current=None;table_count=0
 for n,line in enumerate(text.splitlines(),1):
  t=line.partition('#')[0].strip()
  if not t:continue
  if t.startswith('.section '):section=t.split()[1].split(',')[0]
  if t.startswith('.globl '):publics.update(t[7:].split(','))
  if t.startswith('.extern '):imports.update(t[8:].split(','))
  if t.endswith(':'):current=t[:-1];need(re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*',current)and current not in defs,'unique real source definition');defs[current]={'section':section,'line':n}
  if t.startswith('.long ')and section=='_TEXT':need(current.startswith('control_')and'table'in current,'only real typed switch tables in CODE');need(all(x in defs or re.fullmatch(r'control_(?:branch|case)_[0-9]+',x)for x in t[6:].split(',')),'symbolic table entries');table_count+=1
  if t.startswith('.ascii '):need(section=='CONST','literal outside CONST');ast.literal_eval(t[7:])
  if t.startswith('.byte '):need(section=='_DATA'and current=='_CONTROL_JoystickPort'and t=='.byte 0','only genuine BYTE joystick port')
  if t.startswith('.p2align '):need((section in('_TEXT','_BSS')and t=='.p2align 4')or(section in('CONST','CONST2','_DATA')and t=='.p2align 2'),'only genuine original section/data alignment')
  if t.startswith('.skip '):need(section=='_BSS'and current in{n for n,_,_ in model.BSS},'only genuine BSS allocations')
  if t.startswith('.'):
   need(t.startswith(('.section ','.globl ','.extern ','.file ','.ascii ','.long ','.p2align ','.skip ','.byte '))or t in('.intel_syntax noprefix','.code32'),'unsupported source directive')
 need(publics==PUBLICS and imports==IMPORTS and PRIVATE.issubset(defs)and not PRIVATE&publics,'exact genuine public/private/import scope');need({n for n,z in defs.items()if z['section']=='_DATA'}=={n for n,_ in model.DATA}and{n for n,z in defs.items()if z['section']=='_BSS'}=={n for n,_,_ in model.BSS}and{n for n,z in defs.items()if z['section']=='CONST'}=={n for n,_,_ in model.LITERALS}and not any(z['section']=='CONST2'for z in defs.values()),'only genuine typed data/storage/literal identities; no aliases');need(table_count==5,'all five actual switch tables');return defs

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

def preflight(path,text,listing,e,model):
 file_contract=raw_elf(path)
 defs=source_preflight(text,model);secs={s['name']:s for s in e['sections']};symbols=[s for tab in e['symbols'].values()for s in tab];by={s['name']:s for s in symbols if s['name']};need({s['name']for s in symbols if s['binding']==1 and 0<s['section']<65520}==PUBLICS,'all ELF real globals');need({s['name']for s in symbols if s['binding']==1 and s['section']==0}==IMPORTS,'all true imports');need(all(s['binding']in(0,1)and s['other']==0 and s['type']in(0,3,4)for s in symbols),'weak/hidden/TLS/unsupported symbols');need({n for n in defs}=={s['name']for s in symbols if s['name']and 0<s['section']<65520 and s['type']==0},'every genuine source identity retained')
 need(set(secs)=={'','.text','.data','.bss','_TEXT','CONST','CONST2','_DATA','_BSS','.rel_TEXT','.symtab','.strtab','.shstrtab'},'closed ELF section graph');need(secs['_TEXT']['size']==6329,'complete CODE6329 including final RET/tails/tables');need({n:secs[n]['align']for n in ['_TEXT','CONST','CONST2','_DATA','_BSS']}=={'_TEXT':16,'CONST':4,'CONST2':4,'_DATA':4,'_BSS':16},'genuine original section alignment');need([(secs[n]['type'],secs[n]['flags'])for n in ['_TEXT','CONST','CONST2','_DATA','_BSS']]==[(1,6),(1,3),(1,3),(1,3),(8,3)],'real section class/permissions');need(all(secs[n]['size']==0 for n in ['.text','.data','.bss','CONST2']),'unexpected empty default section data');need(all(r['type']in(1,2)and r['source_section']==secs['_TEXT']['index']for r in e['relocations']),'unmeasured relocation grammar');need(all(r['symbol']['binding']==1 or r['symbol']['type']==3 for r in e['relocations']),'unmeasured direct local/ABS relocation')
 literals,_=model.generate();expected=b''.join(t.encode('ascii')+bytes(cap-len(t.encode('ascii')))for _,t,cap in model.LITERALS);need(bytes.fromhex(secs['CONST']['bytes'])==expected and len(expected)==1055,'all logical literal capacities');data=bytearray()
 for n,v in model.DATA:
  if n=='_CONTROL_JoystickPort':data+=bytes(4)
  else:data+=(v&0xffffffff).to_bytes(4,'little')
 need(bytes.fromhex(secs['_DATA']['bytes'])==data and len(data)==68,'all actual typed scalar state');need(secs['_BSS']['size']==sum(c*z for _,c,z in model.BSS)==1612,'all real BSS allocations')
 at=0;owners={}
 for n,c,z in model.BSS:
  s=by[n];need((s['binding'],s['section'],s['value'])==(1 if n in PUBLICS else 0,secs['_BSS']['index'],at),'true storage identity '+n);owners[n]=[s['section'],at,c*z];at+=c*z
 at=0
 for n,v in model.DATA:
  s=by[n];need((s['binding'],s['section'],s['value'])==(1 if n in PUBLICS else 0,secs['_DATA']['index'],at),'true scalar identity '+n);owners[n]=[s['section'],at,4 if n!='_CONTROL_JoystickPort'else 1];at+=4
 # Native GAS listing ties every emitted fragment to its exact source statement.
 lines=text.splitlines();rows={};current=1;table_models={};dispatches=[];relocs={(r['source_section'],r['offset']):r for r in e['relocations']};offsets={s['index']:0 for s in e['sections']};code_rows=[];all_rows=[]
 for row in listing.splitlines():
  if row.startswith('GAS LISTING ')or not row.strip():continue
  if '\t'in row:
   lead,t=row.split('\t',1);f=lead.split();need(f and f[0].isdigit()and len(f)in(1,3),'listing row shape');n=int(f[0]);need(1<=n<=len(lines)and t.rstrip()==lines[n-1].rstrip()and n not in rows,'complete listing source identity');rows[n]={'line':n,'text':lines[n-1],'offset':int(f[1],16)if len(f)==3 else None,'data':bytes.fromhex(f[2])if len(f)==3 else b''}
  else:
   f=row.split();need(len(f)==2 and f[0].isdigit()and int(f[0])in rows,'listing continuation');rows[int(f[0])]['data']+=bytes.fromhex(f[1])
 need(set(rows)==set(range(1,len(lines)+1)),'listing covers every source line')
 from capstone import Cs,CS_ARCH_X86,CS_MODE_32
 md=Cs(CS_ARCH_X86,CS_MODE_32);md.detail=True
 for n,row in rows.items():
  t=row['text'].partition('#')[0].strip()
  if t.startswith('.section '):current=secs[t.split()[1].split(',')[0]]['index']
  if t.endswith(':'):
   name=t[:-1];need((by[name]['section'],by[name]['value'])==(current,offsets[current]),'true source/local identity coordinate '+name)
  if row['offset']is None:continue
  need(row['offset']==offsets[current],'all source coordinates contiguous');payload=row['data']
  if t.startswith('.ascii '):payload=ast.literal_eval(t[7:]).encode('ascii')
  if t.startswith('.skip '):payload=bytes(eval(t[6:],{'__builtins__':{}},{}))
  # BSS listing truncates zero display; its full declared extent is checked.
  section=e['sections'][current]
  if section['type']!=8:need(bytes.fromhex(section['bytes'])[row['offset']:row['offset']+len(payload)]==payload,'listing owns all section bytes')
  row.update(section=current,data=payload.hex());offsets[current]+=len(payload);all_rows.append(row)
  if current==secs['_TEXT']['index']:
   if t.startswith('.long '):
    entries=t[6:].split(',');need(len(payload)==4*len(entries),'complete real switch table')
    name=next(n for n,z in by.items()if z['section']==current and z['value']==row['offset']and n in defs and'table'in n);table_models[name]=entries
    for j,label in enumerate(entries):
     q=by[label];f=relocs[(current,row['offset']+4*j)];need(q['section']==current and q['binding']==0 and f['type']==1 and f['symbol']['type']==3 and f['symbol']['section']==current and(f['inline_signed']&0xffffffff)==q['value'],'actual named CS case pointer equation')
   else:
    ins=list(md.disasm(payload,row['offset']));need(len(ins)==1 and ins[0].size==len(payload),'one complete real source mnemonic');code_rows.append({'line':n,'offset':row['offset'],'size':len(payload),'mnemonic':ins[0].mnemonic,'operands':ins[0].op_str})
    from capstone.x86 import X86_OP_MEM,X86_REG_CS
    i=ins[0]
    if i.mnemonic=='jmp'and len(i.operands)==1 and i.operands[0].type==X86_OP_MEM and i.operands[0].mem.segment==X86_REG_CS:
     names=[q for q in defs if'table'in q and q in t];need(len(names)==1 and i.operands[0].mem.scale==4 and i.disp_size==4,'real CS indexed-table dispatch');f=relocs[(current,row['offset']+i.disp_offset)];need(f['type']==1 and f['symbol']['type']==3 and f['symbol']['section']==current and(f['inline_signed']&0xffffffff)==by[names[0]]['value'],'real CS table address');dispatches.append({'table':names[0],'source_line':n,'instruction':row['offset']})
 need(all(offsets[secs[n]['index']]==secs[n]['size']for n in ['_TEXT','CONST','CONST2','_DATA','_BSS']),'full source ownership of section ends')
 need({n:len(v)for n,v in table_models.items()}=={'control_hat_button_table':4,'control_apply_analog_table':6,'control_clear_direction_table':7,'control_start_device_table':6,'control_start_message_table':5}and{d['table']for d in dispatches}==set(table_models)and len(dispatches)==5,'all five actual C tables/CS dispatches')
 operand_roles=bind_operand_fields(text,e,all_rows,md)
 return {'operand_field_roles':operand_roles,'typed_switch_tables':table_models,'CS_dispatches':dispatches,'raw_ELF_contract':file_contract,'ELF':e,'source_definitions':defs,'private_storage':owners,'instruction_count':len(code_rows),'instructions':code_rows,'all_source_rows':all_rows,'source_private_names':sorted(set(defs)-PUBLICS)}
def postflight(e,m,pre):
 names={s.name:i+1 for i,s in enumerate(m.segments)};need(set(names)>={'_TEXT','CONST','CONST2','_DATA','_BSS'},'all native source sections');need(not(m.local_publics or m.local_externals),'private locals cannot become OMF exports');need(set(m.publics)==PUBLICS,'all native real PUBLICs');need(set(m.externals)-PUBLICS==IMPORTS,'no lost/extra actual import');
 for s in e['sections']:
  if s['name']in names:
   q=m._segment(names[s['name']]);expected=bytearray(bytes(q.size)if s['type']==8 else bytes.fromhex(s['bytes']))
   for f in e['relocations']:
    if f['source_section']==s['index'] and f['type']==2:
     off=f['offset'];expected[off:off+4]=((int.from_bytes(expected[off:off+4],'little')+4)&0xffffffff).to_bytes(4,'little')
   need(q.size==s['size']and bytes(q.data)==expected,'converter changes substantive bytes or typed PC32 addend projection')
 return {'verified_source_transformation':True,'native_segments':[(s.name,s.class_name,s.size,s.attributes)for s in m.segments],'private_OMF_exports':[],'ELF_private_identities':pre['source_private_names'],'native_fixups':len(m.fixups)}

# Appended to module-local source contract: source identities, never target addresses.
def operand_plan(text):
 owners=set(re.findall(r'(?m)^([A-Za-z_][A-Za-z_0-9]*):\s*$',text))
 for line in text.splitlines():
  t=line.partition('#')[0].strip()
  if t.startswith(('.extern ','.globl ')):owners.update(t.split(None,1)[1].split(','))
 registers=set('eax ebx ecx edx esi edi esp ebp ax bx cx dx si di sp bp al ah bl bh cl ch dl dh cs ds es fs gs ss'.split())
 def expression(expr):
  occurrences=[]
  def linear(n):
   if isinstance(n,ast.Constant)and type(n.value)is int:return {},n.value
   if isinstance(n,ast.Name):
    need(n.id in owners|registers,'unsupported runtime operand symbol '+n.id)
    if n.id in owners:occurrences.append(n.id)
    return {n.id:1},0
   if isinstance(n,ast.UnaryOp)and isinstance(n.op,(ast.USub,ast.UAdd)):
    v,c=linear(n.operand);k=-1 if isinstance(n.op,ast.USub)else 1;return {n:k*a for n,a in v.items()},k*c
   if isinstance(n,ast.BinOp)and isinstance(n.op,(ast.Add,ast.Sub,ast.Mult)):
    a,x=linear(n.left);b,y=linear(n.right)
    if isinstance(n.op,ast.Mult):
     need(not(a and b),'nonlinear runtime operand owner expression')
     return({n:k*y for n,k in a.items()},x*y)if a else({n:k*x for n,k in b.items()},x*y)
    k=-1 if isinstance(n.op,ast.Sub)else 1;out=dict(a)
    for n,v in b.items():out[n]=out.get(n,0)+k*v
    return out,x+k*y
   need(False,'unsupported runtime owner expression')
  try:v,c=linear(ast.parse(expr,mode='eval').body)
  except SyntaxError as e:raise ValueError('invalid runtime operand owner expression')from e
  if not occurrences:return None
  need(len(occurrences)==1,'competing/canceled/repeated runtime owner terms')
  owner=occurrences[0];need(v.get(owner)==1,'runtime owner coefficient must be +1')
  need(all(n in registers or n==owner for n,k in v.items()if k),'competing runtime owner coefficient')
  return {'owner':owner,'coefficient':1,'addend':c,'register_terms':{n:k for n,k in sorted(v.items())if n in registers and k}}
 out=[]
 for line,t in enumerate(text.splitlines(),1):
  t=t.partition('#')[0].strip()
  if not t or t.endswith(':'):continue
  if t.startswith('.long '):parts=t[6:].split(',')
  elif t.startswith('.'):continue
  else:
   t=re.sub(r'^(?:\{[A-Za-z0-9]+\}\s*)+','',t)
   if t.startswith(('repne ','repe ','rep ')):t=t.split(None,1)[1]
   if ' 'not in t:continue
   parts=t.split(None,1)[1].split(',')
  for operand,part in enumerate(parts):
   part=part.strip()
   if '['in part or ']'in part:
    # GAS also accepts displacement expressions BEFORE/AFTER brackets. Those
    # cannot be discarded: this closed source grammar consumes the ENTIRE
    # memory operand, including the actual width/segment prefix and suffix.
    memory=re.fullmatch(r'(?:(?:byte|word|dword)\s+ptr\s+)?(?:(?:cs|ds|es|ss|fs|gs):\s*)?\[([^\[\]]+)\]',part)
    need(memory is not None,'complete memory operand grammar; no ignored prefix/suffix or extra brackets')
    expr=memory[1]
   else:expr=part.removeprefix('OFFSET FLAT:')
   p=expression(expr)
   if p:out.append({'line':line,'operand':operand,**p})
 return out

def check_operand_owners(text):
 import json
 from pathlib import Path
 manifest=Path(__file__).with_name('operand_roles.json')
 need(manifest.is_file(),'missing runtime operand owner role manifest')
 expected=json.loads(manifest.read_text())
 need(operand_plan(text)==expected,'runtime operand owner role differs; section-base/offset substitution rejected')
 return expected


def bind_operand_fields(text,e,rows,md):
 """Each emitted ELF field must originate in its one genuine source owner."""
 plan=check_operand_owners(text);byline={}
 for p in plan:byline.setdefault(p['line'],[]).append(p)
 symbols={s['name']:s for tab in e['symbols'].values()for s in tab if s['name']};roles=[]
 from capstone.x86 import X86_OP_MEM,X86_OP_IMM
 for r in e['relocations']:
  row=next(q for q in rows if q['section']==r['source_section']and q['offset']<=r['offset']<q['offset']+len(bytes.fromhex(q['data'])))
  t=row['text'].partition('#')[0].strip();payload=bytes.fromhex(row['data'])
  if t.startswith('.long '):operand=(r['offset']-row['offset'])//4
  else:
   ins=list(md.disasm(payload,row['offset']));need(len(ins)==1,'one operand-owner instruction');i=ins[0];rel=r['offset']-i.address
   if rel==i.disp_offset and i.disp_size==4:candidates=[k for k,v in enumerate(i.operands)if v.type==X86_OP_MEM]
   elif rel==i.imm_offset and i.imm_size==4:candidates=[k for k,v in enumerate(i.operands)if v.type==X86_OP_IMM]
   else:need(False,'field not actual displacement/immediate')
   need(len(candidates)==1,'unique real field operand');operand=candidates[0]
  p=[p for p in byline.get(row['line'],[])if p['operand']==operand];need(len(p)==1,'exactly one runtime owner per actual ELF field');p=p[0];owner=symbols[p['owner']];q=r['symbol'];add=(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff
  if q['binding']==1:need(q['name']==p['owner']and add==(p['addend']&0xffffffff),'actual GLOBAL/import operand owner')
  else:need(q['type']==3 and owner['binding']==0 and owner['section']==q['section']and(q['value']+add)&0xffffffff==(owner['value']+p['addend'])&0xffffffff,'actual private section+V operand owner')
  roles.append({'field':r['offset'],'section':r['source_section'],'source_operand':p,'ELF':r})
 need(len(roles)==470,'all470 source-owned ELF fields');return roles
