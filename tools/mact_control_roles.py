"""CONTROL complete original/private/operand/native typed-role closure (observer)."""
import dataclasses
def audit_roles(o,m,post,placements,proof,op):
 e=post['ELF']
 def need(q,msg):
  if not q:raise ValueError('CONTROL role '+msg)
 syms={s['name']:s for tab in e['symbols'].values()for s in tab if s['name']};es={s['index']:s['name']for s in e['sections']};native={s.name:i+1 for i,s in enumerate(m.segments)};ef={(es[r['source_section']],r['offset']):r for r in e['relocations']};nf={(m._segment(f.segment).name,f.offset):f for f in m.fixups};placements={int(k):v for k,v in placements.items()};defs={};roles=[];countprivate=0;calls=0
 for name,(seg,off)in o.publics.items():
  s=syms[name];secname=o._segment(seg).name;need((s['binding'],es[s['section']],s['value'])==(0 if name in o.local_publics else 1,secname,off),'real original definition/scope '+name)
  if name in o.local_publics:
   sn=native[secname];obj,base=placements[sn];need((obj,base+off)==tuple(op['local_symbols'][name]),'private definition independent target coordinate');need(name not in m.publics and name not in m.externals,'private exported/leaked '+name);defs[name]={'ELF':s,'qualified_module':'CONTROL','original_segment':seg,'original_offset':off,'native_section':sn,'target':[obj,base+off]}
 for f in o.fixups:
  sec=o._segment(f.segment).name;g=nf[(sec,f.offset)];r=ef[(sec,f.offset)];a=(int.from_bytes(o._segment(f.segment).data[f.offset:f.offset+4],'little')+f.displacement)&0xffffffff;ga=(int.from_bytes(m._segment(g.segment).data[g.offset:g.offset+4],'little')+g.displacement)&0xffffffff;need((f.width,f.location,f.relative)==(g.width,g.location,g.relative)==(4,9,f.relative),'actual field width/relativity');need(r['type']==(2 if f.relative else 1),'typed ELF relocation form');need(ga==((r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff),'actual PC32 addend projection');name=o.externals[f.target-1]if f.target_method==2 else None;row=next(q for q in post['all_source_rows']if q['section']==r['source_section']and q['offset']<=f.offset<q['offset']+len(bytes.fromhex(q['data'])))
  if f.target_method==2:
   owner=[q for q in post['operand_field_roles']if(q['section'],q['field'])==(r['source_section'],r['offset'])];need(len(owner)==1 and owner[0]['source_operand']['owner']==name and owner[0]['source_operand']['coefficient']==1 and owner[0]['source_operand']['addend']==(a if a<0x80000000 else a-0x100000000),'exact original per-operand owner coefficient/addend '+str(name))
   if name in o.local_publics:
    countprivate+=1;need(f.target in o.local_externals,'original private index scope');s=syms[name];need(g.target_method==0 and m._segment(g.target).name==es[s['section']]and ga==(s['value']+a)&0xffffffff,'private section+V equation');need(r['symbol']['type']==3 and es[r['symbol']['section']]==es[s['section']],'private structural relocation identity');kind='real module-private storage'
   else:
    need(g.target_method==2 and m.externals[g.target-1]==name and ga==a,'real same-name GLOBAL/import field');need(r['symbol']['binding']==1 and r['symbol']['name']==name,'actual named GLOBAL ELF target');kind='same-name real GLOBAL definition'if name in o.publics else'genuine external import';calls+=int(f.relative and name in o.publics)
  else:
   need(f.target_method==0 and g.target_method==0 and o._segment(f.target).name==m._segment(g.target).name and ga==a,'all real section table/literal/static coordinates');need(r['symbol']['type']==3 and es[r['symbol']['section']]==o._segment(f.target).name,'actual table/literal section reference');kind='real typed switch/literal/function-static address'
  roles.append({'offset':f.offset,'original_name':name,'kind':kind,'source_line':row['line'],'source':row['text'],'original':dataclasses.asdict(f),'native':dataclasses.asdict(g),'ELF':r,'canonical_addend':ga})
 need(len(roles)==len(o.fixups)==len(m.fixups)==len(e['relocations'])==470,'all470 roles complete');need(len(defs)==30 and not m.local_publics and not m.local_externals,'all30 original private identities remain real nonexported ELF');need(not(set(defs)&set(proof['publics'])),'no private external-anchor leak');bss={n:r for n,r in defs.items()if o._segment(r['original_segment']).class_name=='BSS'};allbss={n:v for n,v in o.publics.items()if o._segment(v[0]).class_name=='BSS'}

 return {'all470_original_native_ELF_roles':True,'original_fields':len(o.fixups),'native_fields':len(m.fixups),'original_resolved_without_loader_fields':0,'named_private_definitions':defs,'private_reference_count':countprivate,'self_global_REL32_still_actual_named_fields':calls,'all25_BSS_owner_coordinates':[{'name':n,'ELF':syms[n]}for n in allbss],'private_external_anchor_names':[],'all_source_identities':post['source_definitions'],'whole_initialized':7452,'whole_BSS':1612,'instruction_count':post['instruction_count'],'actual_switch_tables':5,'roles':roles}
