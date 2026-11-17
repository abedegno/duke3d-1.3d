"""Complete symbolic DEBUG source owner; source-only production before observation."""
from pathlib import Path
from dataclasses import asdict
import argparse,hashlib,importlib.util,json,shutil,subprocess,sys,tempfile
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
sys.dont_write_bytecode=True
from omf32 import Module
from profiles.gnu_omf.identity import checked_home,digest,profile
from profiles.capstone import identity as decoder
MODEL='src/mact/debug';DESCRIPTOR='modules/mact_debug.json';PROVENANCE='evidence/mact-debug-source-reference.json'
CALLER='evidence/mact_zone-module.json'
CALLER_SHA256='c2653c044d635ea51c1e37cfc2a5c89425b0d551c4b89b984e10fdd2e00abb47'
TRACKED_STAGE={'authored/DEBUG.S': 'src/mact/debug.asm', 'authored/debug_counterpart.c': 'src/mact/debug/debug_counterpart.c', 'authored/GPL-2.0.txt': 'src/mact/debug/GPL-2.0.txt', 'debug_port.py': 'src/mact/debug/debug_port.py', 'contract.py': 'src/mact/debug/contract.py', 'scope_roles.py': 'src/mact/debug/scope_roles.py', 'authored/include/util_lib.h': 'src/mact/debug/include/util_lib.h', 'authored/include/debug.h': 'src/mact/debug/include/debug.h', 'authored/include/file_lib.h': 'src/mact/debug/include/file_lib.h', 'authored/include/types.h': 'src/mact/debug/include/types.h', 'authored/include/develop.h': 'src/mact/debug/include/develop.h', 'authored/include/_debug.h': 'src/mact/debug/include/_debug.h'}
PRODUCER_TOOLS=['tools/probe_mact_debug.py','profiles/gnu_omf/identity.py','profiles/gnu_omf/profile.json',
 'profiles/gnu_omf/objconv-source-files.json','profiles/gnu_omf/debug-subset.json','profiles/gnu_omf/setup.py','profiles/watcom/tools/omf32.py',
 'profiles/capstone/identity.py','profiles/capstone/files.json','profiles/capstone/setup.py']
OBSERVER_TOOLS=['tools/prove_module.py','tools/infer_bindings.py','tools/match_function.py','tools/verify_module.py','profiles/watcom/tools/le.py','tools/inventory_watcom_runtime.py','tools/probe_mact_zone.py']
NOTICES=[MODEL+'/README.md','profiles/capstone/README.md','profiles/gnu_omf/README.md','profiles/gnu_omf/DEBUG.md']
TARGET_SHA256='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'
LIBRARY='reference/duke3d-reconstructions/MACT386.LIB'
LIBRARY_SHA256='957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db'
MEMBER_SHA256='b2a2b4fe2f8e07f4dabfcd29ee8602be39b5be600b55bcc86ee779a8d78f1e3a'
EXPECTED={'initialized_bytes':1361,'zero_fill_bytes':4,'verified_fixups':76}
REFERENCE_EXPECTED={'initialized_bytes':1361,'zero_fill_bytes':4,'verified_fixups':79}
LOGICAL_ALIGNMENT={'_TEXT':16,'CONST':4,'_DATA':4,'_BSS':16}
PRIVATE_DEFINITIONS={'_DBG_DebugLevel': [4, 0], '_DBG_DebugMask': [4, 8], '_DBG_DebugMode': [4, 4], '_DBG_FileOutputHandle': [5, 0], '_DBG_FileOutputStarted': [4, 100], '_DBG_Out': [4, 104], '_DBG_OutMode': [4, 96], '_DBG_Started': [4, 92]}
MEMBER={'offset':512,'size':4302,'name':r'P:\LIBMACT\debug.c','sha256':MEMBER_SHA256}
def dump(p,d):p.write_text(json.dumps(d,indent=2,default=lambda x:x.hex()if isinstance(x,bytes)else x)+'\n')
def snapshot(paths):return {str(Path(p)):digest(p)for p in paths}
def unchanged(before):
 if any(digest(p)!=h for p,h in before.items()):raise ValueError('DEBUG input/output changed')
def read_provenance():
 e=json.loads((ROOT/PROVENANCE).read_text());spec=json.loads((ROOT/DESCRIPTOR).read_text())
 for field,names in [('tracked_sources_sha256',set(TRACKED_STAGE.values())),('producer_tools_sha256',set(PRODUCER_TOOLS)),('notice_files_sha256',set(NOTICES))]:
  if set(e[field])!=names:raise ValueError('changed DEBUG closed '+field)
 pins={**e['tracked_sources_sha256'],**e['producer_tools_sha256'],**e['notice_files_sha256']}
 for p,h in pins.items():
  if digest(ROOT/p)!=h:raise ValueError('changed DEBUG source/tool identity '+p)
 if digest(ROOT/DESCRIPTOR)!=e['descriptor_sha256']or spec['expected']!=EXPECTED or spec['name']!='mact_debug':raise ValueError('changed DEBUG descriptor')
 if spec['options']!={'assembler':profile()['options']['assembler']+['-L','-no-pad-sections'],'converter':profile()['options']['converter']}:raise ValueError('changed finite DEBUG producer options')
 if spec['reference_expected']!=REFERENCE_EXPECTED or spec['original_logical_alignment']!=LOGICAL_ALIGNMENT or spec['original_private_definitions']!=PRIVATE_DEFINITIONS:raise ValueError('changed finite original DEBUG scope/alignment/role contract')
 extension=json.loads((ROOT/'profiles/gnu_omf/debug-subset.json').read_text())
 if extension['base_tool_profile_sha256']!=__import__('profiles.gnu_omf.identity',fromlist=['PROFILE_SHA256']).PROFILE_SHA256 or extension['decoder_manifest_sha256']!=decoder.FILES_SHA256:raise ValueError('changed DEBUG finite profile extension')
 return e,spec,{**{str(ROOT/p):h for p,h in pins.items()},**snapshot([ROOT/PROVENANCE,ROOT/DESCRIPTOR])}
def load_guard(stage):
 s=importlib.util.spec_from_file_location('_closed_debug_guard',stage/'contract.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def native_inventory(m):
 return {'format':m.format,'segments':[{'name':s.name,'class':s.class_name,'size':s.size,'attributes':s.attributes,'access':s.access}for s in m.segments],
  'publics':m.publics,'local_publics':sorted(m.local_publics),'externals':m.externals,'local_externals':sorted(m.local_externals),'groups':m.groups,'fixups':[asdict(f)for f in m.fixups]}
def validate_native(m,spec):
 if json.loads(json.dumps(native_inventory(m)))!=spec['native_inventory']:raise ValueError('changed complete DEBUG native inventory')
 if not m.name or m.comments or m.default_libraries or m.line_numbers or m.local_publics or m.local_externals or m.format_source is not None or m.source_records or m.thread_definitions or m.code_data_ranges or m.dosseg_directives or m.far_call_optimization_segments:raise ValueError('changed DEBUG raw metadata/scope')
def validate_private(pre,post,spec):
 """Closed source-only private profile; no target/archive/helper graph reads."""
 sections={1:4,2:5,3:6,4:7,5:8};symbols={v['name']:v for v in pre['symbols']};recorded={v['name']for v in post['private_identities']}
 for name,(segment,offset)in spec['original_private_definitions'].items():
  v=symbols.get(name);d=pre['definitions'].get(name)
  if not v or not d or name not in recorded or (v['kind'],v['storage_class'],v['aux_count'],v['section'],v['value'])!=('private',3,0,sections[segment],offset)or(d['section'],d['value'])!=(sections[segment],offset)or not d['uses']:raise ValueError('changed genuine source private definition '+name)
def build_source(home,build,decoder_home=None):
 e,spec,before=read_provenance();home=Path(home).resolve();decoder_home=Path(decoder_home or ROOT/'toolchains/capstone').resolve()
 tools=checked_home(home);dec=decoder.checked_home(decoder_home);decoder.load(decoder_home)
 before.update({str(home/p):h for p,h in tools.items()});before.update({str(decoder_home/p):h for p,h in dec.items()});before.update(snapshot([Path(sys.executable).resolve()]))
 parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);work=Path(tempfile.mkdtemp(prefix='mact-debug-',dir=parent));stage=work/'source-only';stage.mkdir()
 for n,p in TRACKED_STAGE.items():q=stage/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,q)
 s=importlib.util.spec_from_file_location('_debug_port',stage/'debug_port.py');exp=importlib.util.module_from_spec(s);s.loader.exec_module(exp);source,origins=exp.expand()
 (stage/'DEBUG.S').write_bytes(source);dump(stage/'origins.json',origins);staged=snapshot(p for p in stage.rglob('*')if p.is_file())
 guard=load_guard(stage);coff,obj,lst=work/'DEBUG.COFF',work/'DEBUG.OBJ',work/'DEBUG.LST';gas=spec['options']['assembler'];conv=profile()['options']['converter']
 commands=[[str(home/'bin/as-new'),*gas,'-al='+str(lst),'-o',str(coff),str(stage/'DEBUG.S')]]
 p=subprocess.run(commands[-1],capture_output=True,text=True);(work/'GAS.LOG').write_text(p.stdout+p.stderr)
 if p.returncode or p.stdout or p.stderr:raise ValueError('DEBUG assembler failed/diagnostic')
 args=(coff.read_bytes(),source,lst.read_text());pre=guard.preflight(*args);dump(work/'preflight.json',pre)
 commands.append([str(home/'bin/objconv'),*conv,str(coff),str(obj)]);p=subprocess.run(commands[-1],capture_output=True,text=True);(work/'CONVERT.LOG').write_text(p.stdout+p.stderr)
 if p.returncode or p.stderr or 'warning'in p.stdout.lower():raise ValueError('DEBUG converter failed/diagnostic')
 post=guard.postflight(*args,obj.read_bytes(),pre);dump(work/'postflight.json',post);validate_private(pre,post,spec);validate_native(Module.parse(obj.read_bytes()),spec)
 outputs=snapshot([coff,obj,lst,work/'GAS.LOG',work/'CONVERT.LOG',work/'preflight.json',work/'postflight.json'])
 unchanged(before);unchanged(staged);unchanged(outputs);checked_home(home);decoder.checked_home(decoder_home)
 result={'kind':'Complete DEBUG source-only native producer; target observation separate','source':spec['source'],'source_sha256':digest(ROOT/spec['source']),
  'native_build_directory':str(work),'object':str(obj),'object_sha256':digest(obj),'coff_sha256':digest(coff),'commands':commands,
  'producer_inputs_sha256':before,'staged_inputs_sha256':staged,'outputs_sha256':outputs,'toolchain_sha256':tools,'decoder_sha256':dec,
  'source_reference_evidence':PROVENANCE,'source_reference_sha256':digest(ROOT/PROVENANCE),'source_only':True,'source_credit':0,
  'original_or_target_read_during_production':False,'full_executable_rebuilt':False,'runtime_private_identities':len(post['private_identities']),
  'absolute_constants':len(post['absolute_identities']),'assembler_resolved_branches':len(pre['resolved_branches']),'normal_native_inventory':native_inventory(Module.parse(obj.read_bytes()))}
 dump(work/'source-build.json',result);return result
def caller_anchors(work):
 """Accepted current normal ZONE typed calls; observer only, no research inputs."""
 s=importlib.util.spec_from_file_location('_debug_current_zone_caller',ROOT/'tools/probe_mact_zone.py');zone=importlib.util.module_from_spec(s);s.loader.exec_module(zone)
 p=ROOT/CALLER
 if digest(p)!=CALLER_SHA256:raise ValueError('changed accepted ZONE caller receipt')
 c=json.loads(p.read_text());e,ds,live=zone.read_provenance()
 if c['source']!='src/mact/zone.asm'or c['source_sha256']!=digest(ROOT/c['source'])or c['target_sha256']!=TARGET_SHA256 or c['source_reference_sha256']!=digest(ROOT/zone.PROVENANCE)or c['descriptor_sha256']!=digest(ROOT/zone.DESCRIPTOR):raise ValueError('changed current ZONE source/header/descriptor witness')
 # Replay every closed producer input at its actual current location; paths in
 # the historical native receipt are identity receipts, not required files.
 source_keys=[k for k in c['producer_inputs_sha256']if k.endswith('/'+c['source'])]
 if len(source_keys)!=1:raise ValueError('ambiguous ZONE source identity')
 prefix=source_keys[0][:-len(c['source'])];expected={}
 for name,h in c['producer_inputs_sha256'].items():
  if name.startswith(prefix):expected[str(ROOT/name[len(prefix):])]=h
  else:expected[name]=h
 if expected!=live|{str(ROOT/'toolchains/gnu-omf'/p):h for p,h in c['toolchain_sha256'].items()}|{str(ROOT/'toolchains/capstone'/p):h for p,h in c['decoder_sha256'].items()}|snapshot([Path(sys.executable).resolve()]):raise ValueError('changed complete ZONE producer input set/options/header/tool witness')
 unchanged(expected)
 v=c['verification'];roles=c['scope_role_correspondence']
 if any(v[k]!=n for k,n in [('verified',True),('initialized_bytes',3826),('zero_fill_bytes',48),('verified_fixups',78)])or(roles['original_roles'],roles['native_typed_roles'],roles['resolved_same_TU_CALL_roles'])!=(114,78,36):raise ValueError('incomplete accepted ZONE caller')
 edges=[r for r in c['constraints']if r.get('symbol')=='DBG_DbgString_']
 if [r['source_offset']for r in edges]!=[1977,1994,2009,2062,2092,2113,2141,2163]or any(tuple(r['value'])!=(1,545200)for r in edges):raise ValueError('changed eight actual typed DEBUG caller edges')
 if tuple(v['publics']['DBG_DbgString_'])!=(1,545200)or ds['options']!={'assembler':c['commands'][0][1:6],'converter':c['commands'][1][1:3]}:raise ValueError('changed ZONE native producer options or typed target')
 return {'DBG_DbgString_':(1,545200)},live|expected|snapshot([p])

def observe(result):
 from le import LEImage
 from tools.infer_bindings import infer_bindings
 from tools.verify_module import verify_module,external_anchor_bindings
 e,spec,pins=read_provenance()
 if set(e['observer_tools_sha256'])!=set(OBSERVER_TOOLS):raise ValueError('changed observer helper set')
 for p,h in e['observer_tools_sha256'].items():
  if digest(ROOT/p)!=h:raise ValueError('changed DEBUG observer identity '+p)
  pins[str(ROOT/p)]=h
 obj=Path(result['object']);image_path=ROOT/'reference/DUKE3D.EXE';lib=ROOT/LIBRARY;pins.update(snapshot([obj,image_path,lib]))
 if pins[str(image_path)]!=TARGET_SHA256 or pins[str(lib)]!=LIBRARY_SHA256:raise ValueError('changed target/original identity')
 from tools.inventory_watcom_runtime import read_archive,select_member
 archive=read_archive(lib.read_bytes())
 if archive['sha256']!=LIBRARY_SHA256:raise ValueError('changed original MACT archive')
 member=select_member(lib.read_bytes(),archive,MEMBER);raw=lib.read_bytes()[member['offset']:member['end']]
 if hashlib.sha256(raw).hexdigest()!=MEMBER_SHA256:raise ValueError('changed complete original DEBUG member')
 work=Path(result['native_build_directory']);anchors,caller_pins=caller_anchors(work);pins.update(caller_pins)
 m=Module.parse(obj.read_bytes());image=LEImage.parse(image_path.read_bytes());validate_native(m,spec)
 base=anchors['DBG_DbgString_'][1]-m.publics['DBG_DbgString_'][1];b=infer_bindings(m,image,1,base,known_symbols=anchors)
 if b['unplaced_segments']or json.loads(json.dumps(b['symbols']))!=spec['symbol_anchors']:raise ValueError('changed full DEBUG inferred bindings')
 for name,alignment in spec['original_logical_alignment'].items():
  seg=next(i for i,s in enumerate(m.segments,1)if s.name==name and s.size)
  if b['placements'][seg][1]%alignment:raise ValueError('changed original logical alignment '+name)
 proof=verify_module(m,image,b['placements'],b['symbols']);original=Module.parse(raw)
 if json.loads(json.dumps(native_inventory(original)))!=spec['reference_inventory']:raise ValueError('changed original complete scope/field inventory')
 ob=infer_bindings(original,image,1,base,known_symbols=anchors);op=verify_module(original,image,ob['placements'],ob['symbols'],group_frames={1:(3,0)})
 if any(proof[k]!=v for k,v in EXPECTED.items())or any(op[k]!=v for k,v in REFERENCE_EXPECTED.items())or proof['publics']!=external_anchor_bindings(op):raise ValueError('complete source/reference contribution differs')
 work=Path(result['native_build_directory']);stage=work/'source-only';s=importlib.util.spec_from_file_location('_debug_scope_correspondence',stage/'scope_roles.py');scope=importlib.util.module_from_spec(s);s.loader.exec_module(scope)
 pre=json.loads((work/'preflight.json').read_text());post=json.loads((work/'postflight.json').read_text());roles=scope.correspondence(original,m,pre,post,proof);roles=json.loads(json.dumps(roles,default=lambda v:v.hex()));dump(work/'scope-role-correspondence.json',roles)

 unchanged(pins)
 for field in ['producer_inputs_sha256','staged_inputs_sha256','outputs_sha256']:unchanged(result[field])
 return {**result,'kind':'Complete source-native DEBUG owner, not complete SDK/EXE','source_only':False,'target_sha256':TARGET_SHA256,
  'descriptor':DESCRIPTOR,'descriptor_sha256':digest(ROOT/DESCRIPTOR),'reference_member_sha256':MEMBER_SHA256,'caller_evidence':CALLER,'caller_evidence_sha256':CALLER_SHA256,
  'scope_role_correspondence':roles,'scope_role_correspondence_sha256':digest(work/'scope-role-correspondence.json'),'original_member':member,'placements':b['placements'],'constraints':b['constraints'],'symbol_anchors':b['symbols'],'verification':proof,'reference_verification':op,
  'observer_inputs_sha256':pins,'unresolved_work':['Ordinary C matching of two formatting bodies; legacy boolean/vararg schedule humanization','other SDK owners','actual DOS/DPMI runtime validation','final source link/binder/full EXE']}
def probe(home,build,decoder_home=None):return observe(build_source(home,build,decoder_home))
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path,default=ROOT/'toolchains/gnu-omf');p.add_argument('--decoder-home',type=Path,default=ROOT/'toolchains/capstone');p.add_argument('--build',type=Path,required=True);p.add_argument('--source-only',action='store_true');p.add_argument('--report',type=Path);a=p.parse_args();r=build_source(a.home,a.build,a.decoder_home)if a.source_only else probe(a.home,a.build,a.decoder_home)
 if a.report:a.report.parent.mkdir(parents=True,exist_ok=True);dump(a.report,r)
 print(json.dumps(r,indent=2))
if __name__=='__main__':main()
