"""Observer-only independent supplied SDK/CRT owner proofs, zero source credit."""
from pathlib import Path
import json,hashlib
ROOT=Path(__file__).resolve().parents[1]
def verify_callees(image,expected):
 from tools.probe_mact_control import need,digest,snapshot,LIBRARY,LIBSHA
 from tools.inventory_watcom_runtime import read_archive,select_member
 from tools.map_candidates import locate
 from tools.infer_bindings import infer_bindings
 from tools.verify_module import verify_module,external_anchor_bindings
 from tools.match_function import compare_range
 from omf32 import Module
 result={};pins={};seen={}
 def prove(raw,names,label,code_only=False):
  m=Module.parse(raw);need(all(n in m.publics and n not in m.local_publics for n in names),'real independent provider PUBLICs');
  if label=='joystick.asm':
   # Real original TEXT has empty class and lives in object2; do not rename it.
   places={}
   for name in names:
    sn,off=m.publics[name];obj,at=expected[name];v=(obj,at-off);need(sn not in places or places[sn]==v,'all six joystick owner equations');places[sn]=v
   p=verify_module(m,image,places,{});need(all(tuple(p['publics'][n])==tuple(expected[n])for n in names),'whole original joystick owner fields');result[label]={'supplied_original_observer_only':True,'source_credit':0,'whole_verification':p,'placements_from_all_six_actual_public_equations':places,'actual_owned_roles':{n:p['publics'][n]for n in names}};seen.update({n:p['publics'][n]for n in names});return
  loc=locate(m,{i:image.object_bytes(i)for i,o in enumerate(image.objects,1)if o.flags&4});bases={(z['object'],z['offset']-row['source_offset'])for row in loc for z in row.get('locations',[])};wins=[];attempts=[]
  for obj,base in sorted(bases):
   try:
    b=infer_bindings(m,image,obj,base)
    if code_only:
     sn=next(i for i,q in enumerate(m.segments,1)if q.class_name=='CODE'and q.size);segment=m._segment(sn);need(all(m.publics[n][0]==sn for n in names),'CODE-only actual provider scope');whole_error=None
     try:verify_module(m,image,b['placements'],b['symbols'])
     except ValueError as err:whole_error=str(err)
     need(whole_error=='segment _DATA violates SEGDEF alignment','known VID whole-DATA negative remains explicit');co,cb=b['placements'][sn];v=compare_range(m,sn,0,image,co,cb,segment.size,b['symbols'],b['placements'],label='Complete original VID CODE provider')
     need(v['match']and v['compared_bytes']==segment.size,'entire VID CODE including all tails');p={'verified_complete_CODE_only':True,'publics':{n:[co,cb+m.publics[n][1]]for n in names},'CODE_comparison':v,'whole_module_negative':whole_error,'source_credit':0};a=p['publics']
    else:p=verify_module(m,image,b['placements'],b['symbols']);a=external_anchor_bindings(p)
    need(all(tuple(a[n])==tuple(expected[n])for n in names),'named independently owned callee binding');wins.append(p);attempts.append({'placement':[obj,base],'match':True})
   except(ValueError,AssertionError)as e:attempts.append({'placement':[obj,base],'match':False,'error':str(e)})
  need(len(wins)==1,'unique complete provider '+label+' '+repr(attempts));p=wins[0];result[label]={'supplied_original_observer_only':True,'source_credit':0,'whole_verification':p,'actual_owned_roles':{n:p['publics'][n]for n in names},'member_sha256':hashlib.sha256(raw).hexdigest(),'candidate_gates':attempts};seen.update({n:p['publics'][n]for n in names})
 sdk=ROOT/LIBRARY;raw=sdk.read_bytes();need(digest(sdk)==LIBSHA,'SDK observer identity');archive=read_archive(raw);pins.update(snapshot([sdk]));spec=json.loads((ROOT/'modules/mact_control.json').read_text())
 for entry in spec['independent_provider_members']:
  member=select_member(raw,archive,entry);prove(raw[member['offset']:member['end']],entry['required_names'],entry['name'],code_only=entry['name']==r'P:\LIBMACT\vidmsdos.c')
 runtime=ROOT/'evidence/watcom-runtime-components.json';stock=json.loads(runtime.read_text());pins.update(snapshot([runtime]))
 for stem,name in [('set386','memset_'),('printf','printf_'),('int386','int386_')]:
  c=next(c for c in stock['components']if c['name']==stem);lib=ROOT/c['library'];raw=lib.read_bytes()[c['offset']:c['end']];need(hashlib.sha256(raw).hexdigest()==c['sha256'],'supplied stock member identity');m=Module.parse(raw);need(name in m.publics and name not in m.local_publics,'stock actual ownership');p=verify_module(m,image,{int(k):v for k,v in c['placements'].items()},c['verification']['publics'],group_frames={int(k):v for k,v in c['verification'].get('group_frames',{}).items()}or None);need(json.loads(json.dumps(p))==c['verification']and tuple(p['publics'][name])==tuple(expected[name]),'whole supplied stock role');result[stem]={'supplied_original_observer_only':True,'source_credit':0,'whole_verification':p,'actual_owned_roles':{name:p['publics'][name]}};seen[name]=p['publics'][name];pins.update(snapshot([lib]))
 # __argv is owned by argcv386, not the importing initargv component.
 init=next(c for c in stock['components']if c['name']=='initargv');lib=ROOT/init['library'];raw=lib.read_bytes()[init['offset']:init['end']];need(hashlib.sha256(raw).hexdigest()==init['sha256'],'actual initargv identity');im=Module.parse(raw);need('__Init_Argv_'in im.publics,'real constructor ownership');ip=verify_module(im,image,{int(k):v for k,v in init['placements'].items()},init['verification']['publics'],group_frames={int(k):v for k,v in init['verification'].get('group_frames',{}).items()}or None);need(json.loads(json.dumps(ip))==init['verification'],'complete actual initargv');ctor=tuple(ip['publics']['__Init_Argv_']);pins.update(snapshot([lib]))
 entry=spec['argv_stock_observer'];lib=ROOT/entry['library'];raw=lib.read_bytes();member=select_member(raw,read_archive(raw),entry);av=Module.parse(raw[member['offset']:member['end']]);need(av.publics=={'__argc':(2,0),'__argv':(2,4)}and len(av.fixups)==1,'genuine argc/argv initializer graph');obj,off=expected['__argv'];avdata=(obj,off-4);wins=[]
 for f in image.read_fixups():
  if (f.source_type,f.width,f.target_object,f.target_offset,f.alias)==(7,4,*ctor,False):
   try:
    p=verify_module(av,image,{2:avdata,4:(f.source_object,f.source_offset-2)},{'__Init_Argv_':ctor});wins.append(p)
   except ValueError:pass
 need(len(wins)==1,'unique full supplied argcv initializer+DATA');p=wins[0];need(tuple(p['publics']['__argv'])==tuple(expected['__argv']),'actual argv owner target');result['argcv386-not-new-accepted-inventory']={'supplied_original_observer_only':True,'source_credit':0,'whole_verification':p,'actual_owned_roles':{'__argv':p['publics']['__argv']},'independent_initargv_verification':ip};seen['__argv']=p['publics']['__argv'];pins.update(snapshot([lib]))
 entry=spec['additional_stock_observer'];lib=ROOT/entry['library'];raw=lib.read_bytes();member=select_member(raw,read_archive(raw),entry);prove(raw[member['offset']:member['end']],['atol_'],'supplied-atol-not-new-accepted-inventory');pins.update(snapshot([lib]));need(set(seen)==set(expected),'complete19 independent imported role closure');return result,pins
