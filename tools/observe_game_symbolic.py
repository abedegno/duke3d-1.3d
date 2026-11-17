"""Unmasked whole GAME observation after the closed source-only producer.

Independent actual native provider objects/complete provider proofs constrain
Shutdown callee names. No historical name-inferred GAME anchors are imported.
"""
from pathlib import Path
import argparse,json,sys
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from tools.build_game_symbolic import need,digest,dump,unchanged,read_contract,contract,check_freshness,OBSERVERS
from profiles.gnu_elf_omf.elf32 import elf
from omf32 import Module
from le import LEImage
from tools.map_candidates import locate
from tools.infer_bindings import infer_bindings,infer_data_bindings
from tools.match_function import compare_range
from tools.verify_module import verify_module,external_anchor_bindings
TARGET_SHA256='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'
def provider(image,proof_path,object_path,name):
 p=Path(proof_path).resolve();o=Path(object_path).resolve();r=json.loads(p.read_text());need(r['target_sha256']==TARGET_SHA256,'provider target identity');need(digest(ROOT/r['source'])==r['source_sha256']and digest(ROOT/r['descriptor'])==r['descriptor_sha256'],'live admitted provider source/descriptor');m=Module.parse(o.read_bytes());m=m.without_watcom_debug()if any(s.name.startswith('$$')for s in m.segments)else m;need(name in m.publics and name not in m.local_publics,'actual provider public scope');places={int(k):tuple(v)for k,v in r['placements'].items()};proof=r['verification'];v=verify_module(m,image,places,external_anchor_bindings(proof));need(json.loads(json.dumps(v))==proof,'fresh whole provider object/placement/proof');s,at=m.publics[name];actual=(places[s][0],places[s][1]+at);need(external_anchor_bindings(v)[name]==actual,'actual provider public export');return actual,{str(p):digest(p),str(o):digest(o),str(ROOT/r['source']):digest(ROOT/r['source']),str(ROOT/r['descriptor']):digest(ROOT/r['descriptor'])}

def observe(receipt,target,*,keyboard_proof,keyboard_object,control_proof,control_object):
 receipt=Path(receipt).resolve();r=json.loads(receipt.read_text());need(r['source_only']and r['source_credit']==0 and not r['target_SDK_Cobject_decoder_emitter_read'],'source-first receipt');e,d,_=read_contract();need(all(digest(ROOT/n)==h for n,h in e['observer_tools_sha256'].items()),'observer helper identity');observer_pins={str(ROOT/n):h for n,h in e['observer_tools_sha256'].items()};profile_paths={p for p in r['inputs_sha256']if p.endswith('/bin/as-new')};need(len(profile_paths)==1,'one actual GNU home');home=Path(next(iter(profile_paths))).parent.parent;decpaths={p for p in r['inputs_sha256']if p.endswith('/capstone/__init__.py')};need(len(decpaths)==1,'one actual decoder home');decoder=Path(next(iter(decpaths))).parent.parent;gpaths={p for p in r['inputs_sha256']if p.lower().endswith('/binb/wasm.exe')};need(len(gpaths)==1,'one actual GA home');ga=Path(next(iter(gpaths))).parent.parent;check_freshness(r,home,decoder,ga)
 target=Path(target).resolve();need(digest(target)==TARGET_SHA256,'immutable target');im=LEImage.parse(target.read_bytes());m=Module.parse(Path(r['object']).read_bytes());need(contract.inventory(m)==contract.model()['native_inventory'],'source native inventory');providers={};pins={str(target):digest(target),str(receipt):digest(receipt),**observer_pins}
 for proof,obj,name in [(keyboard_proof,keyboard_object,'KB_Shutdown_'),(control_proof,control_object,'CONTROL_Shutdown_')]:
  value,pp=provider(im,proof,obj,name);providers[name]=value;pins.update(pp)
 nominations=locate(m,{i:im.object_bytes(i)for i,o in enumerate(im.objects,1)if o.flags&4});candidates=sorted({(z['object'],z['offset']-row['source_offset'])for row in nominations for z in row['locations']});attempts=[];wins=[]
 for obj,base in candidates:
  try:
   b=infer_bindings(m,im,obj,base,known_symbols=providers);symbols=b['symbols'];places=b['placements'];code=compare_range(m,1,0,im,obj,base,84142,symbols,places,label='complete GAME CODE/all actual fields');need(code['match']and code['verified_fixups']==5018,'complete CODE84142/5018');functions={};publics=sorted((off,n)for n,(s,off)in m.publics.items()if s==1)
   for i,(at,n)in enumerate(publics):
    end=publics[i+1][0]if i+1<len(publics)else m._segment(1).size;f=compare_range(m,1,at,im,obj,base+at,end-at,symbols,places,label=n);need(f['match'],'complete function '+n);functions[n]=f
   need(len(functions)==81,'all81 complete public functions');checks={}
   for number in [2,4,5]:
    po,at=places[number];s=m._segment(number);checks[s.name]=compare_range(m,number,0,im,po,at,s.size,symbols,places,label='complete '+s.name)
   need(checks['_DATA']['match']and checks['_BSS']['match'],'complete actual DATA and BSS range');const=checks['CONST'];need(not const['match']and const['differing_offsets']==d['known_negative_CONST_offsets']and all(m._segment(2).data[k]==0 for k in const['differing_offsets']),'exact seven still-zero CONST negatives')
   try:whole=verify_module(m,im,places,symbols)
   except ValueError as ex:whole={'verified':False,'error':str(ex)}
   else:raise ValueError('whole target gate must retain seven CONST differences')
   tail=Module.parse(Path(r['tail_object']).read_bytes());tb=infer_data_bindings(tail,{n:symbols[n]for n in tail.publics});tp=verify_module(tail,im,tb['placements'],tb['symbols']);need(tp['initialized_bytes']==0 and tp['zero_fill_bytes']==15,'complete genuine public tail15');prefix=compare_range(m,1,0,im,obj,base,448,symbols,places,label='complete leading prefix448');need(prefix['match'],'complete leading prefix');wins.append({'bindings':b,'complete_CODE':code,'functions':functions,'complete_segments':checks,'leading448':prefix,'tail':tp,'tail_bindings':tb,'whole_target_strict_negative':whole});attempts.append({'placement':[obj,base],'CODE_match':True,'whole_target_match':False,'negative':'seven CONST bytes'})
  except ValueError as ex:attempts.append({'placement':[obj,base],'CODE_match':False,'error':str(ex)})
 need(len(wins)==1,'one complete CODE/fields/data/storage candidate '+repr(attempts));check_freshness(r,home,decoder,ga);unchanged(pins);result={'kind':'Normal source-only whole GAME backend candidate; target seven CONST negative','source_build':r,'verification':wins[0],'nominations':nominations,'all_candidate_gates':attempts,'fresh_actual_Shutdown_provider_exports':providers,'observer_inputs_sha256':pins,'source_credit':0,'complete_module_admission':False,'full_executable_match':False,'historical_ShutDown_partial_invalidated':True,'original77_unrelated_intervals_unchanged':True,'C_BSS_qualification':'full4160 zero-fill range and common anchors; not independently named target identities for every palette/compiler-private role'};return result

def main():
 p=argparse.ArgumentParser(description=__doc__)
 for n in['source-build','target','keyboard-proof','keyboard-object','control-proof','control-object','report']:p.add_argument('--'+n,type=Path,required=True)
 a=p.parse_args();r=observe(a.source_build,a.target,keyboard_proof=a.keyboard_proof,keyboard_object=a.keyboard_object,control_proof=a.control_proof,control_object=a.control_object);dump(a.report,r);print('GAME CODE84142/5018/all81/source DATA+BSS+tail pass; strict seven CONST negative')
if __name__=='__main__':main()
