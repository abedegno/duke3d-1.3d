# SPDX-License-Identifier: GPL-2.0-or-later
"""Finite mixed-language GAME source-unit linker; no target/image inputs.

Reserved GLOBAL undefined companion names are transport for explicitly declared
unit-private owners. The output preserves real C LPUB storage and uses genuine
LEXT references; this is a custom source-unit ABI, not ordinary C extern linkage.
"""
from pathlib import Path
from dataclasses import replace,asdict
import sys,struct,json,hashlib
from collections import Counter
R=next(p for p in Path(__file__).resolve().parents if (p/'profiles/watcom/tools/omf32.py').is_file())
sys.path[:0]=[str(R/'tools'),str(R/'profiles/watcom/tools')]
from omf32 import Module,Segment,Cursor
from actors_omf_link import need,idx,name,record,records
PREFIX='__GAME_UNIT_TEXT_'
C_SEGMENTS=[('_TEXT','CODE',440,105),('CONST','DATA',0,169),('CONST2','DATA',0,169),('_DATA','DATA',864,169),('_BSS','BSS',4160,105),('CONST','DATA',4274,169),('GAME_C2','CODE',20270,105),('GAME_C1','CODE',14919,105),('GAME_C0','CODE',30912,105)]
ASM_SEGMENTS=[('GAME_INIT_ALIGN','CODE',8,41),('GAME_SPAWN','CODE',16288,41),('GAME_CMD','CODE',1305,41)]
LAYOUT=[[(0,1),(1,1),(0,9),(1,2),(0,8),(1,3),(0,7)],[(0,2),(0,6)],[(0,3)],[(0,4)],[(0,5)]]
SCAFFOLD=[('_TEXT','CODE',105),('CONST','DATA',169),('CONST2','DATA',169),('_DATA','DATA',169),('_BSS','BSS',105)]
ALIASES={f'game_text_spawn_{n}' for n in(440,496,536)}|{f'game_text_checkcommandline_{n}' for n in(1432,1464,1488,1500,1512,1532,1552,1572,1596,1608,1624,1644,1664,1672)}

def load_json(raw):
 """Parse declarations without allowing JSON's silent duplicate-key overwrite."""
 def pairs(rows):
  d={}
  for k,v in rows:need(k not in d,'duplicate declaration key');d[k]=v
  return d
 return json.loads(raw,object_pairs_hook=pairs)

def _raw_inventory(raw,m,role,expected=None):
 need(m.format=='standard-omf' and not(m.line_numbers or m.dosseg_directives or m.source_records),'unsupported native metadata')
 if expected is not None:need([(s.name,s.class_name,s.size,s.attributes)for s in m.segments]==expected,'finite SEGDEF semantics changed')
 need(all(s.access is None and s.attributes&31==9 for s in m.segments),'only public combine USE32 without access extension')
 coverage=[bytearray(s.size)for s in m.segments];comments=[];pubs=set();exts=set();names=[''];si=0;last_data_kind=None
 allowed={0x80,0x88,0x96,0x99,0x9a,0x8c,0xb4,0xb5,0x90,0x91,0xb6,0xb7,0xa0,0xa1,0xa3,0x9c,0x9d,0x8a}
 for t,p in records(raw):
  need(t in allowed,'unrepresented native record');c=Cursor(p)
  if t==0x96:
   while c.left():names.append(c.name())
  elif t==0x99:
   attrs,z=c.uint(1),c.uint(4);n,k,o=c.index(),c.index(),c.index();need(not c.left() and names[o]=='','unsupported overlay/access')
   need((names[n],names[k],z,attrs)==(m.segments[si].name,m.segments[si].class_name,m.segments[si].size,m.segments[si].attributes),'raw SEGDEF differs');si+=1
  elif t in(0x90,0x91,0xb6,0xb7):
   need(t&1==1,'16-bit PUBDEF unsupported');group,seg=c.index(),c.index();need(1<=seg<=len(m.segments),'absolute public unsupported');need(group==0 or seg in m.groups[group-1][1] or m.groups[group-1][0]=='FLAT','public group disagrees')
   while c.left():
    n=c.name();off=c.uint(4 if t&1 else 2);need(c.index()==0,'PUBDEF type unsupported');need(n not in pubs,'duplicate native definition');pubs.add(n);need(off<=m._segment(seg).size,'public outside contribution')
  elif t in(0x8c,0xb4,0xb5):
   while c.left():
    n=c.name();need(c.index()==0,'EXTDEF type unsupported');need(n not in exts,'duplicate or local/global external collision');exts.add(n)
  elif t in(0x9c,0x9d):need(last_data_kind in(0xa0,0xa1),'fixup association with LIDATA unsupported')
  elif t in(0xa0,0xa1,0xa3):
   last_data_kind=t
   seg=c.index();off=c.uint(4 if t&1 else 2)
   if t==0xa3:
    # GA's actual initialized zero runs: one non-nested literal block.
    repeat,children=c.uint(4),c.uint(2);need(children==0,'nested LIDATA unsupported');literal=c.bytes(c.uint(1));need(not c.left() and len(literal)==1 and literal==b'\0' and repeat>0,'finite LIDATA zero run changed');need(0<=off<=m._segment(seg).size and repeat<=m._segment(seg).size-off,'LIDATA exceeds contribution');data=literal*repeat
   else:data=c.bytes(c.left())
   need(off+len(data)<=m._segment(seg).size,'initialized data outside extent');v=coverage[seg-1];need(not any(v[off:off+len(data)]),'overlapping initialized data');v[off:off+len(data)]=b'\1'*len(data)
   need(bytes(m._segment(seg).data[off:off+len(data)])==data,'parsed source bytes differ')
  elif t==0x88:
   flags,k=c.uint(1),c.uint(1);q=c.bytes(c.left());comments.append((flags,k,q))
   if k==0:need(flags==4 and not any(q),'padding metadata changed')
   elif k==0xaa:need(flags==128 and q==b'OS220','format metadata changed')
   elif k==0x9b:need(flags==128 and q==b'3fOp','processor metadata changed')
   elif k==0xfe:
    need(flags==128,'directive flags changed')
    if q[:1]==b'O':d=Cursor(q[1:]);m._segment(d.index());need(not d.left(),'far-call directive malformed')
    else:need(q==b'D\1\0C','debug directive changed')
   elif k==0xfd:
    d=Cursor(q);need(flags==128 and d.uint(1)==ord('S'),'CODE range format');s=d.index();a,z=d.uint(4),d.uint(4);need(not d.left() and 0<=a<=z<=m._segment(s).size,'CODE range malformed')
   elif k==0xe9:
    need(flags==128,'dependency flags changed')
    if q:d=Cursor(q);d.bytes(4);d.name();need(not d.left(),'dependency malformed')
   elif k==0x9f:need(flags==128 and q in(b'clib3r',b'math387r',b'emu387'),'library metadata changed')
   elif k==0xa2:need(flags==128 and q==b'\1','pass separator changed')
   else:raise ValueError('unrepresented comment')
  elif t==0x8a:need(p==b'\0','start address or module flags unsupported')
 need(si==len(m.segments),'missing raw segment')
 for s,v in zip(m.segments,coverage):need(not any(v) if s.class_name=='BSS' else all(v),'initialized coverage gap/BSS bytes')
 occupied=set()
 for f in m.fixups:
  need(f.width==4 and f.location==9 and f.target_method in(0,2),'unsupported field geometry')
  need((f.frame_method==1 and f.frame is not None and m.groups[f.frame-1]==('FLAT',()))or(f.frame_method==5 and f.frame is None),'unsupported frame semantics')
  if role=='c':need(f.frame_method==1,'C frame changed')
  elif role=='assembly':need((f.target_method==2 and f.frame_method==5)or(f.target_method==0 and f.frame_method==1),'ASM typed target/frame pairing changed')
  cells={(f.segment,x)for x in range(f.offset,f.offset+f.width)};need(not cells&occupied,'overlapping fixups');occupied|=cells
  need(f.offset>=0 and f.offset+f.width<=m._segment(f.segment).size,'split/outside relocation')
 return comments

def _bank_rows(bank):
 if isinstance(bank,(str,bytes)):bank=load_json(bank)
 rows=bank['message_map'];seen=set();at=0;result={}
 for row in rows:
  n='_'+row['name'];data=bytes.fromhex(row['data']);need(n not in seen and row['offset']==at and len(data)>0,'bank source map overlap/duplicate/gap');seen.add(n);result[n]=(at,len(data),data);at+=len(data)
 need(at==bank['authored_bytes'] and len(rows)==bank['authored_messages'],'bank extent/count')
 return result,at

def coalesce(c_raw,asm_raw,declaration,bank_model):
 """Combine the two complete fixed GAME source outputs, in authored order."""
 if isinstance(declaration,(bytes,str)):declaration=load_json(declaration)
 need({r['source_name']for r in declaration['aliases']}==ALIASES,'closed GAME alias set changed')
 mods=[Module.parse(c_raw),Module.parse(asm_raw)]
 need(mods[0].groups==[('DGROUP',(2,3,4,5,6)),('FLAT',())] and mods[1].groups==[('FLAT',())],'finite groups changed')
 need(len(mods[0].fixups)==4275 and len(mods[1].fixups)==745,'finite field count changed')
 comments=[_raw_inventory(c_raw,mods[0],'c',C_SEGMENTS),_raw_inventory(asm_raw,mods[1],'assembly',ASM_SEGMENTS)]
 need(Counter((f,k)for f,k,p in comments[0])=={(4,0):202,(128,233):44,(128,254):5,(128,159):3,(128,170):1,(128,155):1,(128,253):1} and not comments[1],'finite represented metadata inventory changed')
 need(mods[1].publics=={'spawn_':(2,160),'checkcommandline_':(3,233)} and not mods[1].local_publics,'finite ASM exports changed')
 need(mods[0].default_libraries==['clib3r','math387r','emu387'] and not mods[1].default_libraries,'finite library list changed')
 need(mods[0].far_call_optimization_segments==[1,7,8,9] and mods[0].code_data_ranges==[(1,0,440)],'finite code metadata changed')
 return _combine([c_raw,asm_raw],mods,comments,declaration,bank_model,LAYOUT,SCAFFOLD,6,4274)

def _combine(raws,mods,comments,declaration,bank_model,layout,scaffold,bank_segment,bank_size):
 """Internal engine shared only by production and the separately closed native fixture."""
 need(len(mods)==len(raws)==len(comments)==2,'exactly two physical source roles required')
 need(declaration['schema']==1 and declaration['unit']=='GAME' and declaration['input_roles']==['c','assembly'] and declaration['reserved_prefix']==PREFIX,'source unit/roles/prefix changed')
 bank,total=_bank_rows(bank_model);need(total==bank_size,'bank source extent changed');c,a=mods
 need(bytes(c._segment(bank_segment).data)==b''.join(v[2]for v in bank.values()),'source bank bytes changed')
 owners={}
 for no,m in enumerate(mods):
  for n,coords in m.publics.items():
   need(n not in owners,'duplicate/ambiguous owner');need(not n.startswith(PREFIX),'reserved alias definition');owners[n]=(no,coords,n in m.local_publics)
 for n,(off,cap,data)in bank.items():need(owners.get(n)==(0,(bank_segment,off),True),'bank owner scope/coordinates changed')
 alias={};declowners=set()
 for row in declaration['aliases']:
  n,owner=row['alias'],row['owner'];need(n==PREFIX+row['source_name'] and owner=='_'+row['source_name'],'alias/owner suffix changed');need(n not in alias and owner not in declowners,'duplicate alias/owner declaration');declowners.add(owner)
  need(row['owner_input']=='c' and row['owner_scope']=='LPUBDEF' and row['input_role']=='assembly' and row['input_scope']=='GLOBAL undefined transport' and row['final_scope']=='unit-private LEXTDEF -> LPUBDEF','alias roles/scopes changed')
  need(row['owner_segment']==bank_segment and row['owner_segment_name']==c._segment(bank_segment).name and row['owner_segment_size']==bank_size,'wrong bank contribution identity')
  need(owner in bank and bank[owner][:2]==(row['offset'],row['capacity']),'alias owner offset/capacity changed')
  need(owners.get(owner)==(0,(bank_segment,row['offset']),True),'alias does not select actual private C owner');alias[n]=row
 used={}
 for no,m in enumerate(mods):
  need(len(set(m.externals))==len(m.externals),'duplicate/local-global external collision')
  for i,n in enumerate(m.externals,1):
   local=i in m.local_externals
   if n.startswith(PREFIX):
    need(no==1 and n in alias and not local and n not in owners,'undeclared/C-side/non-global alias')
    fields=[j for j,f in enumerate(m.fixups)if f.target_method==2 and f.target==i];need(fields,'unused alias import');used[n]=(i,fields)
   elif local:need(n in owners and owners[n][0]==no and owners[n][2],'local external lacks same-input LPUB owner')
   else:need(n not in owners or not owners[n][2],'ordinary global external spells private owner')
 need(set(used)==set(alias),'missing declared import')
 out=Module(name='GAME');maps=[{},{}];contributions=[]
 for dest,(parts,(n,k,attrs))in enumerate(zip(layout,scaffold),1):
  s=Segment(n,k,0,attrs,bytearray());out.segments.append(s)
  for no,old in parts:
   need(old not in maps[no],'source segment represented twice');src=mods[no]._segment(old);need(src.class_name==k,'contribution class mismatch');base=s.size;need(base%{1:1,2:2,3:16,4:256,5:4}[src.attributes>>5]==0,'source contribution alignment')
   maps[no][old]=(dest,base);s.size+=src.size;s.data.extend(src.data);contributions.append(dict(input=('c','assembly')[no],source_segment=old,output_segment=dest,output_offset=base,size=src.size,BSS=k=='BSS'))
 need(all(set(sm)==set(range(1,len(m.segments)+1))for sm,m in zip(maps,mods)),'missing source contribution')
 gmaps=[]
 for no,m in enumerate(mods):
  gm={}
  for old,(n,members)in enumerate(m.groups,1):
   mapped=tuple(dict.fromkeys(maps[no][i][0]for i in members));hits=[i for i,x in enumerate(out.groups,1)if x[0]==n]
   if hits:need(out.groups[hits[0]-1]==(n,mapped),'conflicting group');gm[old]=hits[0]
   else:out.groups.append((n,mapped));gm[old]=len(out.groups)
  gmaps.append(gm)
  for n,(s,off)in m.publics.items():
   dest,base=maps[no][s];out.publics[n]=(dest,base+off)
   if n in m.local_publics:out.local_publics.add(n)
 extmaps=[];extreceipt=[];identities={}
 for no,m in enumerate(mods):
  em={}
  for old,n in enumerate(m.externals,1):
   semantic=alias[n]['owner']if n in alias else n;local=n in alias or old in m.local_externals;key=(semantic,local)
   need((semantic,not local)not in identities,'local/global semantic external collision')
   if key not in identities:
    out.externals.append(semantic);identities[key]=len(out.externals)
    if local:out.local_externals.add(len(out.externals))
   em[old]=identities[key];extreceipt.append(dict(input=('c','assembly')[no],external_index=old,native_name=n,native_scope='LEXTDEF'if old in m.local_externals else 'GLOBAL undefined transport'if n in alias else 'EXTDEF',semantic_owner=semantic,final_external_index=em[old],final_scope='LEXTDEF'if local else 'EXTDEF'))
  extmaps.append(em)
 for no,m in enumerate(mods):
  sm,em,gm=maps[no],extmaps[no],gmaps[no]
  for f in m.fixups:
   seg,base=sm[f.segment];target=em[f.target]if f.target_method==2 else sm[f.target][0];disp=(f.displacement+(sm[f.target][1]if f.target_method==0 else 0))&0xffffffff
   out.fixups.append(replace(f,segment=seg,offset=base+f.offset,target=target,displacement=disp,frame=gm[f.frame]if f.frame_method==1 else None))
  for seg,a,z in m.code_data_ranges:
   sn,base=sm[seg];out.code_data_ranges.append((sn,base+a,base+z))
  out.far_call_optimization_segments.extend(sm[x][0]for x in m.far_call_optimization_segments)
  out.default_libraries.extend(m.default_libraries)
 merged=[]
 for no,rows in enumerate(comments):
  for flags,k,p in rows:
   if k==0xa2:continue
   if k==0xfe and p[:1]==b'O':cur=Cursor(p[1:]);p=b'O'+idx(maps[no][cur.index()][0])
   elif k==0xfd:
    cur=Cursor(p);need(cur.uint(1)==ord('S'),'range opcode');sn,base=maps[no][cur.index()];aa,z=cur.uint(4),cur.uint(4);p=b'S'+idx(sn)+struct.pack('<II',base+aa,base+z)
   merged.append((flags,k,p))
 out.comments=[(k,p)for _,k,p in merged]+[(0xa2,b'\1')]
 aliases=[]
 for n,row in alias.items():
  old,fields=used[n];owner=row['owner'];aliases.append(dict(declaration=row,input_role='assembly',input_external_index=old,input_scope='GLOBAL undefined transport',input_fields=[dict(index=i,**asdict(mods[1].fixups[i]))for i in fields],owner_input='c',owner_native_LPUB=list(c.publics[owner]),capacity=row['capacity'],final_LEXT_index=extmaps[1][old],final_scope='unit-private LEXTDEF -> LPUBDEF',final_LPUB=list(out.publics[owner])))
 receipt=dict(schema=1,unit='GAME',private_ABI='GLOBAL undefined input transport resolves to declared same-unit private LPUB; final LEXT scope is semantic, not literal input-scope conservation',inputs=[dict(role=role,sha256=hashlib.sha256(raw).hexdigest(),segments=len(m.segments),initialized=sum(s.size for s in m.segments if s.class_name!='BSS'),BSS=sum(s.size for s in m.segments if s.class_name=='BSS'),fixups=len(m.fixups))for role,raw,m in zip(('c','assembly'),raws,mods)],contributions=contributions,group_maps=gmaps,external_maps=extreceipt,aliases=aliases,initialized_bytes=sum(s.size for s in out.segments if s.class_name!='BSS'),BSS_bytes=sum(s.size for s in out.segments if s.class_name=='BSS'),typed_fixups=len(out.fixups))
 receipt['initialized_records']=[]
 for no,raw in enumerate(raws):
  for ordinal,(kind,p)in enumerate(records(raw)):
   if kind not in(0xa0,0xa1,0xa3):continue
   cur=Cursor(p);old=cur.index();off=cur.uint(4 if kind&1 else 2)
   if kind==0xa3:
    repeat,children=cur.uint(4),cur.uint(2);literal=cur.bytes(cur.uint(1));need(0<=off<=mods[no]._segment(old).size and repeat<=mods[no]._segment(old).size-off,'LIDATA exceeds contribution');data=literal*repeat
   else:data=cur.bytes(cur.left())
   dest,base=maps[no][old];receipt['initialized_records'].append(dict(input=('c','assembly')[no],record_ordinal=ordinal,record_type=hex(kind),source_segment=old,source_offset=off,encoded_payload_sha256=hashlib.sha256(p).hexdigest(),expanded_bytes=len(data),expanded_sha256=hashlib.sha256(data).hexdigest(),output_segment=dest,output_offset=base+off,encoding='single zero-literal repeat expanded to LEDATA'if kind==0xa3 else 'literal LEDATA'))
 verify_conservation(mods,out,maps,extmaps,gmaps)
 return out,merged,receipt

def verify_conservation(mods,out,maps,extmaps,gmaps):
 """Independent per-input literal-byte and typed-expression witness."""
 expected=[]
 for no,m in enumerate(mods):
  for old,s in enumerate(m.segments,1):
   dest,base=maps[no][old];z=out._segment(dest);need(bytes(z.data[base:base+s.size])==bytes(s.data),'literal source-byte conservation')
  for f in m.fixups:
   dest,base=maps[no][f.segment];target=extmaps[no][f.target]if f.target_method==2 else maps[no][f.target][0];disp=(f.displacement+(maps[no][f.target][1]if f.target_method==0 else 0))&0xffffffff
   expected.append((dest,base+f.offset,f.width,f.location,f.relative,f.frame_method,gmaps[no][f.frame]if f.frame_method==1 else None,f.target_method,target,disp))
 need(expected==[tuple(asdict(f).values())for f in out.fixups],'typed source-expression conservation')
 need(sum(s.size for m in mods for s in m.segments)==sum(s.size for s in out.segments),'source extent conservation')
 expected_publics={};expected_private=set()
 for no,m in enumerate(mods):
  for n,(sn,off)in m.publics.items():
   dest,base=maps[no][sn];need(n not in expected_publics,'duplicate witness definition');expected_publics[n]=(dest,base+off)
   if n in m.local_publics:expected_private.add(n)
 need(out.publics==expected_publics and out.local_publics==expected_private,'definition/scope conservation')
 for no,m in enumerate(mods):
  need(set(extmaps[no])==set(range(1,len(m.externals)+1)),'missing input external mapping')
  for old,n in enumerate(m.externals,1):
   new=extmaps[no][old];alias=n.startswith(PREFIX);semantic='_'+n[len(PREFIX):]if alias else n
   need(out.externals[new-1]==semantic and (new in out.local_externals)==(alias or old in m.local_externals),'external semantic identity/scope conservation')
 need(not any(n.startswith(PREFIX)for n in [*out.publics,*out.externals]),'leftover reserved alias')
 need(all(out.externals[i-1]in out.local_publics for i in out.local_externals),'final local external lacks actual LPUB')
 expected_groups=[]
 for no,m in enumerate(mods):
  for old,(n,members)in enumerate(m.groups,1):
   mapped=(n,tuple(dict.fromkeys(maps[no][x][0]for x in members)))
   if mapped not in expected_groups:expected_groups.append(mapped)
   need(out.groups[gmaps[no][old]-1]==mapped,'group map semantic conservation')
 need(out.groups==expected_groups,'group inventory conservation')
 need(out.default_libraries==[x for m in mods for x in m.default_libraries],'library inventory conservation')
 need(out.far_call_optimization_segments==[maps[no][x][0]for no,m in enumerate(mods)for x in m.far_call_optimization_segments],'far-call directive multiplicity conservation')
 need(out.code_data_ranges==[(maps[no][sn][0],maps[no][sn][1]+a,maps[no][sn][1]+z)for no,m in enumerate(mods)for sn,a,z in m.code_data_ranges],'CODE range conservation')
 for bss in(False,True):need(sum(s.size for m in mods for s in m.segments if (s.class_name=='BSS')==bss)==sum(s.size for s in out.segments if (s.class_name=='BSS')==bss),'initialized/BSS extent conservation')

def _packets(m,sn):
 s=m._segment(sn);at=0;fields=sorted((f.offset,f.offset+f.width)for f in m.fixups if f.segment==sn)
 while at<s.size:
  end=min(at+1024,s.size)
  for a,z in fields:
   if a<end<z:end=a;break
  need(end>at,'unsplittable source field');yield at,end-at;at=end

def serialize(m,comments,spans=None):
 """Serialize complete bytes; packet boundaries never split a typed field."""
 need(all(f.width==4 and f.location==9 and f.target_method in(0,2) and ((f.frame_method==1 and f.frame is not None and m.groups[f.frame-1]==('FLAT',()))or(f.frame_method==5 and f.frame is None)) for f in m.fixups),'unsupported serialized field semantics')
 out=bytearray(record(0x80,name(m.name)));names=['']
 for s in m.segments:
  for n in(s.name,s.class_name):
   if n not in names:names.append(n)
 for n,_ in m.groups:
  if n not in names:names.append(n)
 out+=record(0x96,b''.join(name(n)for n in names[1:]));ni={n:i for i,n in enumerate(names)}
 for s in m.segments:out+=record(0x99,bytes([s.attributes])+struct.pack('<I',s.size)+idx(ni[s.name])+idx(ni[s.class_name])+idx(0))
 for n,members in m.groups:out+=record(0x9a,idx(ni[n])+b''.join(b'\xff'+idx(s)for s in members))
 for i,n in enumerate(m.externals,1):out+=record(0xb4 if i in m.local_externals else 0x8c,name(n)+idx(0))
 for n,(seg,off)in m.publics.items():
  group=next((i for i,(_,members)in enumerate(m.groups,1)if seg in members),0);out+=record(0xb7 if n in m.local_publics else 0x91,idx(group)+idx(seg)+name(n)+struct.pack('<I',off)+idx(0))
 for flags,k,p in comments:out+=record(0x88,bytes([flags,k])+p)
 out+=record(0x88,b'\x80\xa2\1');emitted=[]
 for sn,s in enumerate(m.segments,1):
  if s.class_name=='BSS':need(not any(s.data),'BSS contains initialized bytes');continue
  packets=list(spans)if sn==1 and spans is not None else list(_packets(m,sn));end=0
  for at,n in packets:
   need(at==end and 0<n<=1024 and at+n<=s.size,'packet overlap/gap/extent');end=at+n;out+=record(0xa1,idx(sn)+struct.pack('<I',at)+s.data[at:at+n]);fix=bytearray()
   for i,f in sorted(enumerate(m.fixups),key=lambda item:(item[1].segment,item[1].offset)):
    if f.segment!=sn or not at<=f.offset<at+n:continue
    need(f.offset+f.width<=at+n,'packet splits relocation');off=f.offset-at;fix+=bytes([0x80|(0 if f.relative else 0x40)|(f.location<<2)|(off>>8),off&255,(f.frame_method<<4)|f.target_method|(4 if f.displacement==0 else 0)])
    if f.frame_method<=2:fix+=idx(f.frame)
    if f.target_method<=2:fix+=idx(f.target)
    if f.displacement:fix+=struct.pack('<I',f.displacement&0xffffffff)
    emitted.append(i)
   if fix:out+=record(0x9d,fix)
  need(end==s.size,'incomplete packet extent')
 need(sorted(emitted)==list(range(len(m.fixups))),'lost/duplicate fields');out+=record(0x8a,b'\0');return bytes(out)

def graph(m):
 """Exact graph retains inline field bytes, scopes, raw parsed metadata and frames."""
 return dict(name=m.name,segments=[(s.name,s.class_name,s.size,s.attributes,bytes(s.data).hex(),s.access)for s in m.segments],publics=m.publics,local_publics=sorted(m.local_publics),externals=m.externals,local_externals=sorted(m.local_externals),groups=m.groups,fixups=[asdict(f)for f in m.fixups],libraries=m.default_libraries,far_call=m.far_call_optimization_segments,code_data=m.code_data_ranges,comments=m.comments)

def verify_roundtrip(expected,raw):
 actual=Module.parse(raw);_raw_inventory(raw,actual,'merged');a,b=graph(expected),graph(actual)
 # Native packet order may change the traversal order, never any field identity.
 a['fixups']=sorted(a['fixups'],key=repr);b['fixups']=sorted(b['fixups'],key=repr)
 need(a==b,'serialized complete semantic graph differs')
 return dict(serialized_semantic_graph_equal=True,initialized_bytes=sum(s.size for s in actual.segments if s.class_name!='BSS'),BSS_bytes=sum(s.size for s in actual.segments if s.class_name=='BSS'),typed_fixups=len(actual.fixups))


def repacketize(raw, planned_spans):
    module = Module.parse(raw)
    comments = _raw_inventory(raw, module, 'merged')
    comments = [item for item in comments if item[1] != 0xa2]
    result = serialize(module, comments, planned_spans)
    verify_roundtrip(module, result)
    return result
