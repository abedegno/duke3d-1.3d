# SPDX-License-Identifier: GPL-2.0-or-later
"""Finite ACTORS C/NASM source-native relocatable OMF linker."""
from pathlib import Path
from dataclasses import replace, asdict
import sys, struct, hashlib, json, copy
R=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(R/'profiles/watcom/tools'))
from omf32 import Module,Segment,Fixup,Cursor

def need(q,s):
 if not q:raise ValueError(s)
def idx(n):
 need(0<=n<32768,'index exceeds OMF range');return bytes([n])if n<128 else bytes([0x80|(n>>8),n&255])
def name(s):
 b=s.encode('latin1');need(len(b)<256,'name too long');return bytes([len(b)])+b
def record(t,p):
 need(len(p)+1<=65535,'record too long');h=bytes([t])+struct.pack('<H',len(p)+1)+p;return h+bytes([-sum(h)&255])
def records(raw):
 at=0
 while at<len(raw):
  t=raw[at];n=int.from_bytes(raw[at+1:at+3],'little');need(n>0 and at+n+3<=len(raw),'truncated input record');r=raw[at:at+n+3];need(not r[-1] or not sum(r)&255,'bad input checksum');yield t,r[3:-1];at+=n+3
 need(at==len(raw),'input trailing bytes')
C_SEGMENTS = [('_TEXT', 'CODE', 42884, 105), ('CONST', 'DATA', 0, 169), ('CONST2', 'DATA', 0, 169), ('_DATA', 'DATA', 0, 169), ('_BSS', 'BSS', 6, 105)]
ASM_SEGMENTS = [('_TEXT', 'CODE', 18790, 41), ('CONST', 'DATA', 67, 169)]
MERGED_SEGMENTS = [('_TEXT', 'CODE', 61674, 105), ('CONST', 'DATA', 67, 169), ('CONST2', 'DATA', 0, 169), ('_DATA', 'DATA', 0, 169), ('_BSS', 'BSS', 6, 105)]
C_PUBLICS = {'_dmval': (5, 0), '_radius_status_record': (1, 0), 'updateinterpolations_': (1, 32), 'setinterpolation_': (1, 80), 'stopinterpolation_': (1, 160), 'dointerpolations_': (1, 272), 'restoreinterpolations_': (1, 384), 'ceilingspace_': (1, 432), 'floorspace_': (1, 512), 'addammo_': (1, 592), 'addweapon_': (1, 704), 'checkavailinven_': (1, 880), 'checkavailweapon_': (1, 1136), 'ifsquished_': (1, 1680), 'hitradius_': (1, 1968), 'movesprite_': (1, 4128), 'ssp_': (1, 5312), 'insertspriteq_': (1, 5408), 'lotsofmoney_': (1, 5488), 'guts_': (1, 5616), 'gutsdir_': (1, 5856), 'setsectinterpolate_': (1, 6096), 'clearsectinterpolate_': (1, 6256), 'ms_': (1, 6400), 'movefta_': (1, 6656), 'ifhitsectors_': (1, 7504), 'ifhitbyweapon_': (1, 7568), 'movecyclers_': (1, 8432), 'movedummyplayers_': (1, 8704), 'moveplayers_': (1, 9200), 'movefx_': (1, 10160), 'movefallers_': (1, 11328), 'movestandables_': (1, 12144), 'bounce_': (1, 19904), 'moveweapons_': (1, 20416), 'movetransports_': (1, 23840), 'moveactors_': (1, 27216), 'moveexplosions_': (1, 38752), '_otherp': (5, 4)}
C_PRIVATE = {"_dmval", "_radius_status_record"}

def inventory_input(raw,m):
 """Reject unrepresented fields; prove initialized-byte/BSS coverage exactly."""
 need(m.format=='standard-omf' and not(m.line_numbers or m.dosseg_directives or m.source_records),'unsupported native input metadata')
 coverage=[bytearray(s.size) for s in m.segments];comments=[]
 for t,p in records(raw):
  if t==0x88:comments.append((p[0],p[1],p[2:]))
  if t in (0xa0,0xa1):
   c=Cursor(p);seg=c.index();off=c.uint(4 if t&1 else 2);data=c.bytes(c.left());s=m._segment(seg)
   need(off+len(data)<=s.size,'input data outside declared extent');need(not any(coverage[seg-1][off:off+len(data)]),'overlapping input data');coverage[seg-1][off:off+len(data)]=b'\1'*len(data)
  need(t not in (0xa2,0xa3),'LIDATA not supported by coverage witness')
 for s,c in zip(m.segments,coverage):
  need(not any(c) if s.class_name=='BSS' else all(c),'initialized input coverage gap/BSS data')
 return comments

def packet_plan(path,size):
 lines=path.read_text().splitlines();need(lines[0]=='OMF_PACKETS_V1' and lines[1]==f'section _TEXT {size}' and lines[-1]=='end','packet plan schema');spans=[];at=0
 for line in lines[2:-1]:
  tag,a,n=line.split();a,n=int(a),int(n);need(tag=='packet' and a==at and 0<n<=1024,'packet coverage/order');spans.append((a,n));at+=n
 need(at==size,'packet plan complete extent');return spans

def coalesce(inputs):
 """Concatenate same-named source segments, retaining explicit empty scaffold."""
 need(len(inputs)==2,'requires C and NASM contributions')
 mods=[Module.parse(raw)for raw in inputs]
 for raw,module,role in zip(inputs,mods,('C','ASM')):validate_finite(raw,module,role)
 comments=[inventory_input(raw,m)for raw,m in zip(inputs,mods)]
 private_owners={}
 for owner,source in enumerate(mods):
  for n in source.local_publics:
   need(n not in private_owners,'ambiguous private definition across contributions');private_owners[n]=owner
 for owner,source in enumerate(mods):
  for i,n in enumerate(source.externals,1):
   if i in source.local_externals:need(private_owners.get(n)==owner,'local external lacks same-owner private definition')
   else:need(n not in private_owners,'global external aliases a source-private definition')
 m=Module(name='ACTORS');m.segments=[replace(s,data=bytearray(),size=0)for s in mods[0].segments]
 need([(s.name,s.class_name)for s in m.segments]==[('_TEXT','CODE'),('CONST','DATA'),('CONST2','DATA'),('_DATA','DATA'),('_BSS','BSS')],'declared C scaffold changed')
 maps=[];extmaps=[];groupmaps=[];contributions=[]
 for source in mods:
  sm={}
  for old,s in enumerate(source.segments,1):
   matches=[i for i,z in enumerate(m.segments,1)if(z.name,z.class_name)==(s.name,s.class_name)];need(len(matches)==1,'unknown/ambiguous source segment')
   new=matches[0];dest=m._segment(new);need(s.access is None,'access extension not supported');need(dest.size%{1:1,2:2,3:16,4:256,5:4}[s.attributes>>5]==0,'contribution alignment incompatible');sm[old]=(new,dest.size);dest.data.extend(s.data);dest.size+=s.size
   contributions.append({'input':len(maps),'source_segment':old,'output_segment':new,'output_offset':sm[old][1],'size':s.size,'BSS':s.class_name=='BSS'})
  maps.append(sm)
  gm={}
  for old,(g,members)in enumerate(source.groups,1):
   mapped=tuple(sm[s][0]for s in members);hits=[i for i,x in enumerate(m.groups,1)if x[0]==g]
   if hits:need(m.groups[hits[0]-1]==(g,mapped),'conflicting groups');gm[old]=hits[0]
   else:m.groups.append((g,mapped));gm[old]=len(m.groups)
  groupmaps.append(gm)
  for n,(seg,off)in source.publics.items():
   need(n not in m.publics,'duplicate source public including private collision');s,base=sm[seg];m.publics[n]=(s,base+off)
   if n in source.local_publics:m.local_publics.add(n)
  em={}
  for old,n in enumerate(source.externals,1):
   local=old in source.local_externals
   # Distinct private source identities must never be merged by name.
   hits=[i for i,x in enumerate(m.externals,1)if x==n and (i in m.local_externals)==local]
   need(not(local and hits),'duplicate private external identity requires namespacing')
   if hits:new=hits[0]
   else:m.externals.append(n);new=len(m.externals)
   em[old]=new
   if local:m.local_externals.add(new)
  extmaps.append(em)
  for seg,a,z in source.code_data_ranges:
   sn,base=sm[seg];m.code_data_ranges.append((sn,a+base,z+base))
  m.default_libraries.extend(x for x in source.default_libraries if x not in m.default_libraries)
  m.far_call_optimization_segments.extend(sm[x][0]for x in source.far_call_optimization_segments if sm[x][0]not in m.far_call_optimization_segments)
 for no,source in enumerate(mods):
  sm,gm,em=maps[no],groupmaps[no],extmaps[no]
  for f in source.fixups:
   need(f.width==4 and f.location==9 and f.target_method in (0,2) and f.frame_method in (1,5),'unsupported typed relocation')
   seg,base=sm[f.segment];target=em[f.target]if f.target_method==2 else sm[f.target][0];disp=f.displacement+(sm[f.target][1]if f.target_method==0 else 0);frame=gm[f.frame]if f.frame_method==1 else None
   m.fixups.append(replace(f,segment=seg,offset=base+f.offset,target=target,displacement=disp,frame=frame))
 # Metadata comments are retained; segment-bearing directives get semantic mapping.
 merged_comments=[]
 for no,rows in enumerate(comments):
  sm=maps[no]
  for flags,k,p in rows:
   if k==0xa2:continue # one pass separator belongs to the new module
   if k==0xfd:
    c=Cursor(p);op=c.uint(1);seg=c.index();w=4 if op==ord('S')else 2;a,z=c.uint(w),c.uint(w);need(not c.left(),'range metadata');sn,base=sm[seg];p=bytes([ord('S')])+idx(sn)+struct.pack('<II',base+a,base+z)
   elif k==0xfe and p[:1]==b'O':
    c=Cursor(p[1:]);old=c.index();need(not c.left(),'far-call directive');p=b'O'+idx(sm[old][0])
   if k==0x9f and any(y[1]==k and y[2]==p for y in merged_comments):continue
   merged_comments.append((flags,k,p))
 occupied=set()
 for f in m.fixups:
  cells={(f.segment,f.offset+j)for j in range(f.width)};need(not occupied&cells,'overlapping typed source fields');occupied|=cells
 m.comments=[(k,p)for flags,k,p in merged_comments]+[(0xa2,b'\1')]
 return m,merged_comments,contributions

def serialize(m,comments,spans):
 end=0
 for at,n in spans:
  need(at==end and 0<n<=1024,'noncontiguous packet coverage');end+=n
 need(end==m.segments[0].size,'incomplete CODE packet coverage')
 out=bytearray(record(0x80,name(m.name)));names=[''];
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
  group=next((i for i,(g,members)in enumerate(m.groups,1)if seg in members),0)
  out+=record(0xb7 if n in m.local_publics else 0x91,idx(group)+idx(seg)+name(n)+struct.pack('<I',off)+idx(0))
 for flags,k,p in comments:out+=record(0x88,bytes([flags,k])+p)
 out+=record(0x88,b'\x80\xa2\x01')
 emitted=[]
 for sn,s in enumerate(m.segments,1):
  if s.class_name=='BSS':need(not any(s.data),'BSS bytes must be zero');continue
  packets=spans if s.name=='_TEXT'else[(a,min(1024,s.size-a))for a in range(0,s.size,1024)]
  for at,n in packets:
   need(at+n<=s.size,'packet outside source segment');out+=record(0xa1,idx(sn)+struct.pack('<I',at)+s.data[at:at+n]);fix=bytearray()
   for fi,f in enumerate(m.fixups):
    if f.segment!=sn or not at<=f.offset<at+n:continue
    need(f.offset+f.width<=at+n,'packet splits relocation');off=f.offset-at;first=0x80|(0 if f.relative else 0x40)|(f.location<<2)|(off>>8);fd=(f.frame_method<<4)|f.target_method|(4 if f.displacement==0 else 0);fix+=bytes([first,off&255,fd])
    if f.frame_method<=2:fix+=idx(f.frame)
    if f.target_method<=2:fix+=idx(f.target)
    if f.displacement:fix+=struct.pack('<I',f.displacement)
    emitted.append(fi)
   if fix:out+=record(0x9d,fix)
 need(sorted(emitted)==list(range(len(m.fixups))),'lost/duplicate relocation coverage')
 out+=record(0x8a,b'\0');return bytes(out)

def graph(m):
 """Canonical semantic graph with actual addends and linker-private identity."""
 def target(f):
  if f.target_method==2:
   n=m.externals[f.target-1]
   if n in m.publics:
    seg,off=m.publics[n];return ('section',m._segment(seg).name,off)
   return ('external',n,f.target in m.local_externals)
  return ('section',m._segment(f.target).name,0)
 fields=[]
 for f in m.fixups:
  t=target(f);add=f.displacement+int.from_bytes(m._segment(f.segment).data[f.offset:f.offset+4],'little')
  if t[0]=='section':t=(t[0],t[1],t[2]+add);add=0
  frame=('flat',)if f.frame_method==1 and m.groups[f.frame-1][0]=='FLAT'else('target',)if f.frame_method==5 else('unsupported',f.frame_method,f.frame)
  # FLAT versus target frames coincide for same-flat-model32 relocations.
  need(frame[0]!='unsupported','unsupported canonical frame')
  fields.append((m._segment(f.segment).name,f.offset,f.width,f.location,f.relative,t,add))
 bytes_by_section={}
 for sn,s in enumerate(m.segments,1):
  data=bytearray(s.data)
  for f in m.fixups:
   if f.segment==sn:data[f.offset:f.offset+f.width]=b'\0'*f.width
  bytes_by_section[s.name]=data.hex()
 return {'sections':[(s.name,s.class_name,s.size,s.attributes)for s in m.segments],'bytes_except_explicit_typed_addends':bytes_by_section,'fields':sorted(fields,key=repr),'publics':sorted((n,m._segment(s).name,o,n in m.local_publics)for n,(s,o)in m.publics.items()),'private_external_symbols':sorted(m.externals[i-1]for i in m.local_externals),'groups':m.groups,'libraries':m.default_libraries,'code_data':m.code_data_ranges,'far_call':m.far_call_optimization_segments,'comments':m.comments}

def verify_roundtrip(expected,raw):
 actual=Module.parse(raw);validate_finite(raw,actual,'merged');need(graph(expected)==graph(actual),'serialized semantic graph differs');return {'serialized_semantic_graph_equal':True,'initialized_bytes':sum(s.size for s in actual.segments if s.class_name!='BSS'),'BSS_bytes':sum(s.size for s in actual.segments if s.class_name=='BSS'),'typed_fixups':len(actual.fixups),'private_publics':sorted(actual.local_publics),'local_externals':sorted(actual.local_externals)}


def source_packets(inputs):
 need(len(inputs)==2,'requires C and NASM contributions')
 spans=[];base=0
 for raw,role in zip(inputs,('C','ASM')):
  module=Module.parse(raw);validate_finite(raw,module,role);inventory_input(raw,module)
  code=next(i for i,s in enumerate(module.segments,1)if s.name=='_TEXT')
  local=[]
  for t,p in records(raw):
   if t in (0xa0,0xa1):
    c=Cursor(p);sn=c.index();at=c.uint(4 if t&1 else 2);n=c.left()
    if sn==code:local.append((base+at,n))
  spans.extend(sorted(local));base+=module._segment(code).size
 end=0
 for at,n in spans:
  need(at==end and n>0,'source packet coverage gap');end+=n
 need(end==base,'source packet extent mismatch');return spans

def repacketize(raw,planned_spans):
 m=Module.parse(raw);validate_finite(raw,m,'merged');comments=inventory_input(raw,m)
 comments=[x for x in comments if x[1]!=0xa2]
 out=serialize(m,comments,planned_spans);verify_roundtrip(m,out);return out


def validate_finite(raw,m,role):
 """Validate raw metadata erased by Module against the finite ACTORS products.

 This is deliberately not a general OMF linker. Source C owns five scaffold
 segments; the named NASM contribution has byte-aligned public USE32 CODE.
 """
 expected={'C':C_SEGMENTS,'ASM':ASM_SEGMENTS,'merged':MERGED_SEGMENTS}[role]
 need([(s.name,s.class_name,s.size,s.attributes)for s in m.segments]==expected,'finite SEGDEF semantics changed')
 need(all(s.access is None for s in m.segments),'SEGDEF extension unsupported')
 expected_publics=({'moveeffectors_':(1,12)} if role=='ASM'else dict(C_PUBLICS))
 if role=='merged':expected_publics['moveeffectors_']=(1,42896)
 need(m.publics==expected_publics,'finite source public coordinates changed')
 need(m.local_publics==(set()if role=='ASM'else C_PRIVATE),'finite private public scope changed')
 need(all(n not in m.local_publics for i,n in enumerate(m.externals,1)if i not in m.local_externals),'global external aliases private definition')
 need([m.externals[i-1]for i in sorted(m.local_externals)]==([]if role=='ASM'else['_radius_status_record']),'finite local external scope changed')
 need(m.groups==([]if role=='ASM'else[('DGROUP',(2,3,4,5)),('FLAT',())]),'finite groups changed')
 need(m.default_libraries==([]if role=='ASM'else['math387r','emu387']),'finite default libraries changed')
 need(m.code_data_ranges==([]if role=='ASM'else[(1,0,24)]),'finite CODE data metadata changed')
 need(m.far_call_optimization_segments==([]if role=='ASM'else[1]),'finite far-call metadata changed')
 need(len(m.externals)==({'C':119,'ASM':62}.get(role,len(m.externals))),'finite extern inventory changed')
 for f in m.fixups:
  need(f.width==4 and f.location==9 and f.target_method in(0,2),'finite fixup type changed')
  if role=='C':need(f.frame_method==1 and f.frame==2,'C FLAT frame changed')
  elif role=='ASM':need(f.frame_method==5 and f.frame is None,'ASM target frame changed')
 names=[''];seen_segments=0;comment_counts={}
 allowed={0x80,0x88,0x96,0x98,0x99,0x9a,0x8c,0xb4,0xb5,0x90,0x91,0xb6,0xb7,0xa0,0xa1,0x9c,0x9d,0x8a,0x8b}
 for t,p in records(raw):
  need(t in allowed,'unrepresented raw record')
  c=Cursor(p)
  if t==0x96:
   while c.left():names.append(c.name())
  elif t in (0x98,0x99):
   need(t==(0x98 if role=='ASM' else 0x99),'SEGDEF record width changed')
   attrs,size=c.uint(1),c.uint(4 if t&1 else 2);n,k,o=c.index(),c.index(),c.index()
   need(not c.left() and o==(0 if role=='merged' else 1) and names[o]=='','SEGDEF overlay/access metadata unsupported')
   need((names[n],names[k],size,attrs)==expected[seen_segments],'raw SEGDEF tuple changed');seen_segments+=1
  elif t in(0x90,0x91,0xb6,0xb7):
   group,seg=c.index(),c.index()
   required=0 if role=='ASM' or (role=='merged'and seg==1)else 2 if seg==1 else 1
   need(group==required,'PUBDEF group changed')
   while c.left():
    n=c.name();c.uint(4 if t&1 else 2);need(c.index()==0,'PUBDEF type unsupported')
  elif t in(0x8c,0xb4,0xb5):
   while c.left():c.name();need(c.index()==0,'EXTDEF type unsupported')
  elif t==0x88:
   flags,k=c.uint(1),c.uint(1);payload=c.bytes(c.left());key=(flags,k);comment_counts[key]=comment_counts.get(key,0)+1
   if k==0:need((flags==4 and not any(payload))or(flags==0 and payload==b'\x1dThe Netwide Assembler 2.16.03'),'unsupported translator/padding comment')
   elif k==0xaa:need(flags==128 and payload==b'OS220','format comment changed')
   elif k==0x9b:need(flags==128 and payload==b'3fOp','processor/model comment changed')
   elif k==0xfe:need(flags==128 and payload in(b'D\x01\x00C',b'O\x01'),'linker directive changed')
   elif k==0xfd:need(flags==128 and payload==b'S\x01'+struct.pack('<II',0,24),'CODE range directive changed')
   elif k==0x9f:need(flags==128 and payload in(b'math387r',b'emu387'),'default library comment changed')
   elif k==0xe9:
    need(flags==128,'dependency flags changed')
    if payload:
     d=Cursor(payload);d.bytes(4);path=d.name();need(not d.left(),'dependency fields changed')
     import re
     need(re.fullmatch(r'C:\\SOURCE\.C|C:\\INC0\\[A-Za-z_0-9]+\.h|D:\\H\\(?:sys\\)?[A-Za-z_0-9]+\.[hH]',path)is not None,'dependency path unsupported')
   elif k==0xa2:need(payload==b'\1' and flags==(64 if role=='ASM' else 128),'pass separator changed')
   else:raise ValueError('unsupported raw comment class')
 need(seen_segments==len(expected),'raw SEGDEF inventory incomplete')
 expected_names={'C':['','', 'CODE','DATA','BSS','FLAT','DGROUP','_TEXT','CONST','CONST2','_DATA','_BSS'],'ASM':['','','_TEXT','CODE','CONST','DATA'],'merged':['','_TEXT','CODE','CONST','DATA','CONST2','_DATA','_BSS','BSS','DGROUP','FLAT']}
 need(names==expected_names[role],'finite LNAMES inventory changed')
 cc={(128,170):1,(128,155):1,(128,254):2,(128,233):42,(128,253):1,(4,0):91,(128,159):2}
 ac={(0,0):1,(64,162):1}
 wanted=cc if role=='C'else ac if role=='ASM'else{**cc,(0,0):1,(128,162):1}
 need(comment_counts==wanted,'finite raw comment inventory changed')
