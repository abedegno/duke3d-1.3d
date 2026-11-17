"""Complete symbolic ZONE source owner; source-only production before observation."""
from pathlib import Path
from dataclasses import asdict
import argparse,hashlib,importlib.util,json,shutil,subprocess,sys,tempfile
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
sys.dont_write_bytecode=True
from omf32 import Module
from profiles.gnu_omf.identity import checked_home,digest,profile
from profiles.capstone import identity as decoder
MODEL='src/mact/zone';DESCRIPTOR='modules/mact_zone.json';PROVENANCE='evidence/mact-zone-source-reference.json'
CALLER='evidence/game-progress.json'
CALLER_SHA256='c1f3a6af100bab0a8a80a401d45a7523525daf4bfac5e79b399de27379ca7f06'
TRACKED_STAGE={'authored/ZONE.ASM': 'src/mact/zone.asm', 'authored/zone_counterpart.c': 'src/mact/zone/zone_counterpart.c', 'authored/zone_diagnostics.py': 'src/mact/zone/zone_diagnostics.py', 'authored/GPL-2.0.txt': 'src/mact/zone/GPL-2.0.txt', 'zone_port.py': 'src/mact/zone/zone_port.py', 'contract.py': 'src/mact/zone/contract.py', 'scope_roles.py': 'src/mact/zone/scope_roles.py', 'authored/include/_zone.h': 'src/mact/zone/include/_zone.h', 'authored/include/debug.h': 'src/mact/zone/include/debug.h', 'authored/include/develop.h': 'src/mact/zone/include/develop.h', 'authored/include/file_lib.h': 'src/mact/zone/include/file_lib.h', 'authored/include/linklist.h': 'src/mact/zone/include/linklist.h', 'authored/include/types.h': 'src/mact/zone/include/types.h', 'authored/include/util_lib.h': 'src/mact/zone/include/util_lib.h'}
PRODUCER_TOOLS=['tools/probe_mact_zone.py','profiles/gnu_omf/identity.py','profiles/gnu_omf/profile.json',
 'profiles/gnu_omf/objconv-source-files.json','profiles/gnu_omf/zone-subset.json','profiles/gnu_omf/setup.py','profiles/watcom/tools/omf32.py',
 'profiles/capstone/identity.py','profiles/capstone/files.json','profiles/capstone/setup.py']
OBSERVER_TOOLS=['tools/prove_module.py','tools/infer_bindings.py','tools/match_function.py','tools/verify_module.py','profiles/watcom/tools/le.py','tools/inventory_watcom_runtime.py','tools/probe_game.py','tools/probe_premap.py','tools/build_game_compound.py']
NOTICES=[MODEL+'/README.md','profiles/capstone/README.md','profiles/gnu_omf/README.md','profiles/gnu_omf/ZONE.md']
TARGET_SHA256='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'
LIBRARY='reference/duke3d-reconstructions/MACT386.LIB'
LIBRARY_SHA256='957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db'
MEMBER_SHA256='1d2d19f85ec63e23da9969930d9b394753e137662383913d19e7e694debdb1e9'
EXPECTED={'initialized_bytes':3826,'zero_fill_bytes':48,'verified_fixups':78}
REFERENCE_EXPECTED={'initialized_bytes':3826,'zero_fill_bytes':48,'verified_fixups':114}
LOGICAL_ALIGNMENT={'_TEXT':16,'CONST':4,'_DATA':4,'_BSS':16}
PRIVATE_DEFINITIONS={'Z_GetZonePtr_':[1,0],'Z_SetZonePtr_':[1,36],'Z_ClearZone_':[1,72],'Z_AllocateZone_':[1,220],'Z_GetFreeZone_':[1,280],'_MemoryZone':[4,0],'_MemInfo':[5,0]}
MEMBER={'offset':15360,'size':8040,'name':r'P:\LIBMACT\zone.c','sha256':MEMBER_SHA256}
def dump(p,d):p.write_text(json.dumps(d,indent=2,default=lambda x:x.hex()if isinstance(x,bytes)else x)+'\n')
def snapshot(paths):return {str(Path(p)):digest(p)for p in paths}
def unchanged(before):
 if any(digest(p)!=h for p,h in before.items()):raise ValueError('ZONE input/output changed')
def read_provenance():
 e=json.loads((ROOT/PROVENANCE).read_text());spec=json.loads((ROOT/DESCRIPTOR).read_text())
 for field,names in [('tracked_sources_sha256',set(TRACKED_STAGE.values())),('producer_tools_sha256',set(PRODUCER_TOOLS)),('notice_files_sha256',set(NOTICES))]:
  if set(e[field])!=names:raise ValueError('changed ZONE closed '+field)
 pins={**e['tracked_sources_sha256'],**e['producer_tools_sha256'],**e['notice_files_sha256']}
 for p,h in pins.items():
  if digest(ROOT/p)!=h:raise ValueError('changed ZONE source/tool identity '+p)
 if digest(ROOT/DESCRIPTOR)!=e['descriptor_sha256']or spec['expected']!=EXPECTED or spec['name']!='mact_zone':raise ValueError('changed ZONE descriptor')
 if spec['options']!={'assembler':profile()['options']['assembler']+['-L','-no-pad-sections'],'converter':profile()['options']['converter']}:raise ValueError('changed finite ZONE producer options')
 if spec['reference_expected']!=REFERENCE_EXPECTED or spec['original_logical_alignment']!=LOGICAL_ALIGNMENT or spec['original_private_definitions']!=PRIVATE_DEFINITIONS:raise ValueError('changed finite original ZONE scope/alignment/role contract')
 extension=json.loads((ROOT/'profiles/gnu_omf/zone-subset.json').read_text())
 if extension['base_tool_profile_sha256']!=__import__('profiles.gnu_omf.identity',fromlist=['PROFILE_SHA256']).PROFILE_SHA256 or extension['decoder_manifest_sha256']!=decoder.FILES_SHA256:raise ValueError('changed ZONE finite profile extension')
 return e,spec,{**{str(ROOT/p):h for p,h in pins.items()},**snapshot([ROOT/PROVENANCE,ROOT/DESCRIPTOR])}
def load_guard(stage):
 s=importlib.util.spec_from_file_location('_closed_zone_guard',stage/'contract.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def native_inventory(m):
 return {'format':m.format,'segments':[{'name':s.name,'class':s.class_name,'size':s.size,'attributes':s.attributes,'access':s.access}for s in m.segments],
  'publics':m.publics,'local_publics':sorted(m.local_publics),'externals':m.externals,'local_externals':sorted(m.local_externals),'groups':m.groups,'fixups':[asdict(f)for f in m.fixups]}
def validate_native(m,spec):
 if json.loads(json.dumps(native_inventory(m)))!=spec['native_inventory']:raise ValueError('changed complete ZONE native inventory')
 if not m.name or m.comments or m.default_libraries or m.line_numbers or m.local_publics or m.local_externals or m.format_source is not None or m.source_records or m.thread_definitions or m.code_data_ranges or m.dosseg_directives or m.far_call_optimization_segments:raise ValueError('changed ZONE raw metadata/scope')
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
 parent=Path(build).resolve();parent.mkdir(parents=True,exist_ok=True);work=Path(tempfile.mkdtemp(prefix='mact-zone-',dir=parent));stage=work/'source-only';stage.mkdir()
 for n,p in TRACKED_STAGE.items():q=stage/n;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,q)
 s=importlib.util.spec_from_file_location('_zone_port',stage/'zone_port.py');exp=importlib.util.module_from_spec(s);s.loader.exec_module(exp);source,origins=exp.expand()
 (stage/'ZONE.S').write_bytes(source);dump(stage/'origins.json',origins);staged=snapshot(p for p in stage.rglob('*')if p.is_file())
 guard=load_guard(stage);coff,obj,lst=work/'ZONE.COFF',work/'ZONE.OBJ',work/'ZONE.LST';gas=spec['options']['assembler'];conv=profile()['options']['converter']
 commands=[[str(home/'bin/as-new'),*gas,'-al='+str(lst),'-o',str(coff),str(stage/'ZONE.S')]]
 p=subprocess.run(commands[-1],capture_output=True,text=True);(work/'GAS.LOG').write_text(p.stdout+p.stderr)
 if p.returncode or p.stdout or p.stderr:raise ValueError('ZONE assembler failed/diagnostic')
 args=(coff.read_bytes(),source,lst.read_text());pre=guard.preflight(*args);dump(work/'preflight.json',pre)
 commands.append([str(home/'bin/objconv'),*conv,str(coff),str(obj)]);p=subprocess.run(commands[-1],capture_output=True,text=True);(work/'CONVERT.LOG').write_text(p.stdout+p.stderr)
 if p.returncode or p.stderr or 'warning'in p.stdout.lower():raise ValueError('ZONE converter failed/diagnostic')
 post=guard.postflight(*args,obj.read_bytes(),pre);dump(work/'postflight.json',post);validate_private(pre,post,spec);validate_native(Module.parse(obj.read_bytes()),spec)
 outputs=snapshot([coff,obj,lst,work/'GAS.LOG',work/'CONVERT.LOG',work/'preflight.json',work/'postflight.json'])
 unchanged(before);unchanged(staged);unchanged(outputs);checked_home(home);decoder.checked_home(decoder_home)
 result={'kind':'Complete ZONE source-only native producer; target observation separate','source':spec['source'],'source_sha256':digest(ROOT/spec['source']),
  'native_build_directory':str(work),'object':str(obj),'object_sha256':digest(obj),'coff_sha256':digest(coff),'commands':commands,
  'producer_inputs_sha256':before,'staged_inputs_sha256':staged,'outputs_sha256':outputs,'toolchain_sha256':tools,'decoder_sha256':dec,
  'source_reference_evidence':PROVENANCE,'source_reference_sha256':digest(ROOT/PROVENANCE),'source_only':True,'source_credit':0,
  'original_or_target_read_during_production':False,'full_executable_rebuilt':False,'runtime_private_identities':len(post['private_identities']),
  'absolute_constants':len(post['absolute_identities']),'assembler_resolved_branches':len(pre['resolved_branches']),'normal_native_inventory':native_inventory(Module.parse(obj.read_bytes()))}
 dump(work/'source-build.json',result);return result
def caller_anchors(work):
 """Accepted current GAME main's actual typed callee, after source production."""
 spec=importlib.util.spec_from_file_location("_ZONE_GAME_caller_graph",ROOT/"tools/build_game_compound.py");game=importlib.util.module_from_spec(spec);spec.loader.exec_module(game)
 from tools.probe_game import OPTIONS
 p=ROOT/CALLER
 if digest(p)!=CALLER_SHA256:raise ValueError('changed accepted GAME caller receipt')
 c=json.loads(p.read_text());source=ROOT/c['source']
 if c['source']!='src/game/game.c'or digest(source)!=c['source_sha256']or c['target_sha256']!=TARGET_SHA256 or c['options']!=OPTIONS or c['compiler_sha256']!='a4f4da1b8b2cd4e38b2b041975fc6b1d131255ae5eb575828b02f927fbf9bf65':raise ValueError('changed GAME caller source/options/compiler/target')
 _,_,graph_pins=game.read_contract()
 paths=[p,source];paths +=[p for directory in game.REFERENCES+game.OVERLAYS for p in (ROOT/directory).iterdir()if p.is_file()and p.suffix.lower()=='.h'];before=snapshot(paths)|graph_pins;headers=Path(work)/'caller-headers';game.prepare_live_headers(headers)
 if{p.name:digest(p)for p in sorted(headers.iterdir())}!=c['headers_sha256']:raise ValueError('changed GAME caller header witness')
 rows=[v for v in c['functions']if v['symbol']=='main_']
 if len(rows)!=1:raise ValueError('ambiguous GAME main caller')
 row=rows[0];v=row['comparison']
 if(row['size'],v['compared_bytes'],v['verified_fixups'],v['match'],v['differing_offsets'])!=(1488,1488,192,True,[]):raise ValueError('incomplete accepted GAME main caller')
 anchor=tuple(row['bindings']['Z_AvailHeap_'])
 if anchor!=(1,549564):raise ValueError('changed typed Z_AvailHeap caller binding')
 unchanged(before);return {'Z_AvailHeap_':anchor},before

def observe(result):
 from le import LEImage
 from tools.infer_bindings import infer_bindings
 from tools.verify_module import verify_module,external_anchor_bindings
 e,spec,pins=read_provenance()
 if set(e['observer_tools_sha256'])!=set(OBSERVER_TOOLS):raise ValueError('changed observer helper set')
 for p,h in e['observer_tools_sha256'].items():
  if digest(ROOT/p)!=h:raise ValueError('changed ZONE observer identity '+p)
  pins[str(ROOT/p)]=h
 obj=Path(result['object']);image_path=ROOT/'reference/DUKE3D.EXE';lib=ROOT/LIBRARY;pins.update(snapshot([obj,image_path,lib]))
 if pins[str(image_path)]!=TARGET_SHA256 or pins[str(lib)]!=LIBRARY_SHA256:raise ValueError('changed target/original identity')
 from tools.inventory_watcom_runtime import read_archive,select_member
 archive=read_archive(lib.read_bytes())
 if archive['sha256']!=LIBRARY_SHA256:raise ValueError('changed original MACT archive')
 member=select_member(lib.read_bytes(),archive,MEMBER);raw=lib.read_bytes()[member['offset']:member['end']]
 if hashlib.sha256(raw).hexdigest()!=MEMBER_SHA256:raise ValueError('changed complete original ZONE member')
 work=Path(result['native_build_directory']);anchors,caller_pins=caller_anchors(work);pins.update(caller_pins)
 m=Module.parse(obj.read_bytes());image=LEImage.parse(image_path.read_bytes());validate_native(m,spec)
 base=anchors['Z_AvailHeap_'][1]-m.publics['Z_AvailHeap_'][1];b=infer_bindings(m,image,1,base,known_symbols=anchors)
 if b['unplaced_segments']or json.loads(json.dumps(b['symbols']))!=spec['symbol_anchors']:raise ValueError('changed full ZONE inferred bindings')
 for name,alignment in spec['original_logical_alignment'].items():
  seg=next(i for i,s in enumerate(m.segments,1)if s.name==name and s.size)
  if b['placements'][seg][1]%alignment:raise ValueError('changed original logical alignment '+name)
 proof=verify_module(m,image,b['placements'],b['symbols']);original=Module.parse(raw)
 if json.loads(json.dumps(native_inventory(original)))!=spec['reference_inventory']:raise ValueError('changed original complete scope/field inventory')
 ob=infer_bindings(original,image,1,base,known_symbols=anchors);op=verify_module(original,image,ob['placements'],ob['symbols'],group_frames={1:(3,0)})
 if any(proof[k]!=v for k,v in EXPECTED.items())or any(op[k]!=v for k,v in REFERENCE_EXPECTED.items())or proof['publics']!=external_anchor_bindings(op):raise ValueError('complete source/reference contribution differs')
 work=Path(result['native_build_directory']);stage=work/'source-only';s=importlib.util.spec_from_file_location('_zone_scope_correspondence',stage/'scope_roles.py');scope=importlib.util.module_from_spec(s);s.loader.exec_module(scope)
 pre=json.loads((work/'preflight.json').read_text());post=json.loads((work/'postflight.json').read_text());roles=scope.correspondence(original,m,pre,post,proof);roles=json.loads(json.dumps(roles,default=lambda v:v.hex()));dump(work/'scope-role-correspondence.json',roles)

 unchanged(pins)
 for field in ['producer_inputs_sha256','staged_inputs_sha256','outputs_sha256']:unchanged(result[field])
 return {**result,'kind':'Complete source-native ZONE owner, not complete SDK/EXE','source_only':False,'target_sha256':TARGET_SHA256,
  'descriptor':DESCRIPTOR,'descriptor_sha256':digest(ROOT/DESCRIPTOR),'reference_member_sha256':MEMBER_SHA256,'caller_evidence':CALLER,'caller_evidence_sha256':CALLER_SHA256,
  'scope_role_correspondence':roles,'scope_role_correspondence_sha256':digest(work/'scope-role-correspondence.json'),'original_member':member,'placements':b['placements'],'constraints':b['constraints'],'symbol_anchors':b['symbols'],'verification':proof,'reference_verification':op,
  'observer_inputs_sha256':pins,'unresolved_work':['Ordinary C Z_Malloc matching/private ABI and alias humanization','other SDK owners','actual DOS/DPMI runtime validation','final source link/binder/full EXE']}
def probe(home,build,decoder_home=None):return observe(build_source(home,build,decoder_home))
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--home',type=Path,default=ROOT/'toolchains/gnu-omf');p.add_argument('--decoder-home',type=Path,default=ROOT/'toolchains/capstone');p.add_argument('--build',type=Path,required=True);p.add_argument('--source-only',action='store_true');p.add_argument('--report',type=Path);a=p.parse_args();r=build_source(a.home,a.build,a.decoder_home)if a.source_only else probe(a.home,a.build,a.decoder_home)
 if a.report:a.report.parent.mkdir(parents=True,exist_ok=True);dump(a.report,r)
 print(json.dumps(r,indent=2))
if __name__=='__main__':main()
