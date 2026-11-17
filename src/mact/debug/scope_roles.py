"""Closed original/private/field correspondence, observer only; no fake Module locals."""
from dataclasses import asdict
from tools.verify_module import external_anchor_bindings
class AuditError(ValueError):pass
def need(p,s):
 if not p:raise AuditError(s)
def correspondence(original,native,pre,post,proof):
 mapped={1:4,2:5,3:6,4:7,5:8};source_globals=set(original.publics)-original.local_publics;private=set(original.local_publics);defs=pre['definitions'];syms={s['name']:s for s in pre['symbols']};imports={n for i,n in enumerate(original.externals,1)if n not in original.publics};rows=[];privates=[];nativefields={(f.segment,f.offset):f for f in native.fixups};used=set();rawcode=bytes(native.segments[3].data)
 need(set(native.publics)==source_globals and not(native.local_publics or native.local_externals),'exact genuine exported/anonymous native scope')
 need(native.externals==[s['name']for s in pre['symbols']if s['kind']=='external']and set(native.externals)==imports,'exact seven real imports')
 need({original.externals[i-1]for i in original.local_externals}==private,'original complete local external correspondence')
 need(set(external_anchor_bindings(proof))==source_globals|imports and not private&set(external_anchor_bindings(proof)),'private external-anchor leakage')
 for name in sorted(private):
  need(name in defs and name in syms,'missing original true private source definition')
  d,s=defs[name],syms[name];seg,off=original.publics[name]
  need((s['storage_class'],s['aux_count'],s['kind'],s['section'],s['value'])==(3,0,'private',mapped[seg],off),'true private class/value/section identity')
  need((d['section'],d['value'])==(mapped[seg],off)and d['uses'],'private definition and real source use correspondence')
  need(name not in native.publics and name not in native.externals,'private promotion/import')
  privates.append({'name':name,'original_definition':[seg,off],'COFF':s,'source':d,'native_coordinate':[mapped[seg],off],'scope':'genuine nonPUBLIC; no named OMF local record manufactured','qualified_identity':next(s['qualified_identity']for s in post['private_identities']if s['name']==name)})
 for i,f in enumerate(original.fixups):
  key=(mapped[f.segment],f.offset);g=nativefields.get(key);a=int.from_bytes(original.segments[f.segment-1].data[f.offset:f.offset+f.width],'little');need(f.width==4 and f.location==9 and f.displacement==0,'bounded original role width/method datum')
  name=original.externals[f.target-1]if f.target_method==2 else None
  if g is not None:
   need(g.width==4 and g.location==9 and g.relative==f.relative and g.displacement==0,'native typed role geometry');used.add(key)
   if f.target_method==2 and name not in original.publics:
    need(g.target_method==2 and native.externals[g.target-1]==name,'external target-name role')
   else:
    target_seg,target_value=(original.publics[name]if name else(f.target,0));need(not f.relative and g.target_method==0 and g.target==mapped[target_seg],'internal section target role')
    need(int.from_bytes(native.segments[g.segment-1].data[g.offset:g.offset+4],'little')==target_value+a,'complete internal B+V+A field')
   source=[u for u in pre['symbolic_uses']if u['field']['segment']==g.segment and u['field']['offset']==g.offset];need(len(source)==1,'one actual named native field source role')
   rows.append({'original':asdict(f),'original_raw':original.fixup_encodings[i],'original_name':name,'native':asdict(g),'source_role':source[0],'representation':'typed native field, all raw choices retained'})
  else:
   need(f.segment==1 and f.relative and f.target_method==2 and name in original.publics and original.publics[name][0]==1,'only genuinely resolved same-TU CODE calls may lose OMF relocation')
   need(rawcode[f.offset-1]==0xe8,'actual complete CALL opcode')
   resolved=f.offset+4+int.from_bytes(rawcode[f.offset:f.offset+4],'little',signed=True);expected=original.publics[name][1]+a
   need(resolved==expected,'resolved PC-relative equation target+addend-(field+4)')
   branches=[b for b in pre['resolved_branches']if b['source']==f.offset-1 and b['name']==name and b['target']==expected];need(len(branches)==1,'resolved native source CALL-name correspondence')
   rows.append({'original':asdict(f),'original_raw':original.fixup_encodings[i],'original_name':name,'native_field':[4,f.offset],'inline_signed_A':int.from_bytes(rawcode[f.offset:f.offset+4],'little',signed=True),'next_eip':f.offset+4,'resolved_target':resolved,'source_branch':branches[0],'representation':'assembler-resolved genuine same-TU CALL; no invented native fixup'})
 need(len(rows)==79 and len(nativefields)==len(used)==76,'complete original/native field coverage')
 fields=set(q for f in original.fixups if f.segment==1 for q in range(f.offset,f.offset+f.width))
 need(all(x==y for i,(x,y)in enumerate(zip(original.segments[0].data,native.segments[3].data))if i not in fields),'all CODE bytes outside every original field literal-equal')
 need(bytes(original.segments[1].data)==bytes(native.segments[4].data),'complete CONST176 lexical values')
 datafields={q for f in original.fixups if f.segment==4 for q in range(f.offset,f.offset+f.width)}
 need(all(x==y for i,(x,y)in enumerate(zip(original.segments[3].data,native.segments[6].data))if i not in datafields),'all DATA152 outside four typed public callbacks literal-equal')
 need(len(datafields)==16 and len(original.segments[3].data)==len(native.segments[6].data)==152,'exact complete DATA geometry/four fields')

 return {'original_roles':79,'native_typed_roles':76,'resolved_same_TU_CALL_roles':3,'all_original_roles':rows,'private_identities':privates,'complete_source_COFF_private_count':len(post['private_identities']),'all_source_private_names_preserved':len(post['private_identities'])==len([s for s in pre['symbols']if s['kind']=='private']),'structural_source_fields':{'BSS':'4unbacked bytes;actual file handle','DATA':'152initialized bytes;6real scalars/mask21/output_t4'},'all_CODE_outside_original_fields_literal_equal':True,'CONST176_and_DATA152_nonfield_literal_equal':True,'private_anchor_names':[],'source_credit':0}
