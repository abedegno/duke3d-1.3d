"""Normal source-first ROX ELF/fork capsule; original/target are observer-only."""
from pathlib import Path
import sys,os,json,hashlib,shutil,tempfile,subprocess,importlib.util,dataclasses,re
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from omf32 import Module
from profiles.gnu_elf_omf.identity import checked_home,digest,profile
from profiles.gnu_elf_omf.elf32 import elf
MODEL='src/mact/rox';PROVENANCE='evidence/mact-rox-source-reference.json';DESCRIPTOR='modules/mact_rox.json'
SOURCES=['src/mact/rox/C-counterpart/include/_rox.h', 'src/mact/rox/C-counterpart/include/develop.h', 'src/mact/rox/C-counterpart/include/file_lib.h', 'src/mact/rox/C-counterpart/include/linklist.h', 'src/mact/rox/C-counterpart/include/rox.h', 'src/mact/rox/C-counterpart/include/types.h', 'src/mact/rox/C-counterpart/include/util_lib.h', 'src/mact/rox/C-counterpart/include/zone_api.h', 'src/mact/rox/C-counterpart/rox.c', 'src/mact/rox/ROX.S', 'src/mact/rox/elf_contract.py', 'src/mact/rox/literal_source.py', 'src/mact/rox/literals.json', 'src/mact/rox/source_guard.py']
NOTICES=['src/mact/rox/README.md','src/mact/rox/C-counterpart/gpl.txt','profiles/gnu_elf_omf/README.md']
PRODUCERS=['tools/probe_mact_rox.py','profiles/gnu_elf_omf/identity.py','profiles/gnu_elf_omf/profile.json','profiles/gnu_elf_omf/elf32.py','profiles/gnu_elf_omf/setup.py','profiles/gnu_elf_omf/apply_fork.py','profiles/gnu_elf_omf/defined-global.patch','profiles/watcom/tools/omf32.py']
OBSERVERS=['tools/prove_module.py','tools/infer_bindings.py','tools/map_candidates.py','tools/match_function.py','tools/verify_module.py','profiles/watcom/tools/le.py','tools/inventory_watcom_runtime.py','tools/mact_rox_callees.py','tools/probe_mact_zone.py']
EXPECTED={'initialized_bytes':1570,'zero_fill_bytes':256,'verified_fixups':89}
LIBRARY='reference/duke3d-reconstructions/MACT386.LIB';LIBSHA='957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db';TARGETSHA='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4';MEMBERSHA='ef8f9c4ddac7ded7c328bbb6dcc75eb31a2b8e0f7fe343fef4247b38d36789a7'
def dump(p,j):p.write_text(json.dumps(j,indent=2,default=lambda x:x.hex()if isinstance(x,bytes)else x)+'\n')
def snapshot(paths):return{str(Path(p).resolve()):digest(p)for p in paths}
def unchanged(j):
 if any(not Path(p).is_file()or digest(p)!=h for p,h in j.items()):raise ValueError('ROX input/output changed during operation')
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def inventory(m):
 return {'name':m.name,'segments':[[s.name,s.class_name,s.size,s.attributes,s.access]for s in m.segments],'publics':{n:list(v)for n,v in m.publics.items()},'local_publics':sorted(m.local_publics),'externals':m.externals,'local_externals':sorted(m.local_externals),'groups':[[n,list(v)]for n,v in m.groups],'fixups':[dataclasses.asdict(f)for f in m.fixups],'default_libraries':m.default_libraries,'far_call_optimization_segments':sorted(m.far_call_optimization_segments),'format':m.format,'comments':[[k,v.hex()]for k,v in m.comments],'code_data_ranges':[list(v)for v in m.code_data_ranges],'dosseg_directives':m.dosseg_directives,'format_source':m.format_source,'line_numbers':m.line_numbers,'thread_definitions':m.thread_definitions,'source_records':m.source_records,'fixup_encodings':json.loads(json.dumps(m.fixup_encodings,default=lambda x:x.hex()if isinstance(x,bytes)else x))}
def check_native(m,spec):
 if inventory(m)!=spec['native_inventory']:raise ValueError('ROX complete native metadata/inventory differs')

def read_provenance(project=ROOT):
 project=Path(project).resolve();raw_e=(project/PROVENANCE).read_bytes();raw_s=(project/DESCRIPTOR).read_bytes();e=json.loads(raw_e);spec=json.loads(raw_s)
 for field,paths in [('tracked_sources_sha256',SOURCES),('notice_files_sha256',NOTICES),('producer_tools_sha256',PRODUCERS)]:
  if set(e[field])!=set(paths):raise ValueError('ROX closed '+field+' key set differs')
  for p,h in e[field].items():
   if digest(project/p)!=h:raise ValueError('ROX source/tool/notice changed: '+p)
 if digest(project/DESCRIPTOR)!=e['descriptor_sha256']or spec['name']!='mact_rox'or spec['expected']!=EXPECTED:raise ValueError('changed ROX descriptor')
 if spec['options']!=profile()['options']:raise ValueError('changed ROX fixed profile')
 pins={str((project/p).resolve()):h for field in ['tracked_sources_sha256','notice_files_sha256','producer_tools_sha256']for p,h in e[field].items()};pins.update({str(project/PROVENANCE):hashlib.sha256(raw_e).hexdigest(),str(project/DESCRIPTOR):hashlib.sha256(raw_s).hexdigest()});unchanged(pins);return e,spec,pins

def build_source(home=None,build=None,*,project=ROOT):
 project=Path(project).resolve();home=Path(home or os.environ.get('GNU_ELF_OMF_HOME',ROOT/'toolchains/gnu-elf-omf')).resolve();e,spec,pins=read_provenance(project);tools=checked_home(home);pins.update(snapshot([Path(sys.executable).resolve()]));toolpins={str(home/p):h for p,h in tools.items()};pins.update(toolpins)
 parent=Path(build or project/'build/mact-rox').resolve();parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='rox-elf-',dir=parent));stage=w/'source-only';stage.mkdir()
 for p in SOURCES+NOTICES:
  q=stage/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(project/p,q)
 unchanged(pins);staged=snapshot(stage/p for p in SOURCES+NOTICES)
 for p in SOURCES+NOTICES:
  if digest(stage/p)!=pins[str((project/p).resolve())]:raise ValueError('ROX stage differs from pinned source')
 model=stage/MODEL;guard=load('closed_rox_source',model/'source_guard.py');text=(model/'ROX.S').read_text();back=text
 for old,new in SECTION_DIRECTIVES.items():
  if back.count(new)!=1:raise ValueError('ROX ELF directive context differs')
  back=back.replace(new,old)
 source_contract=guard.check(back);lit=load('logical_rox_literals',model/'literal_source.py');lt,locations,total=lit.generate()
 if total!=342:raise ValueError('ROX logical string extent differs')
 (model/'ROX_LITERALS.INC').write_text(lt);unchanged(staged);staged=snapshot(p for p in stage.rglob('*')if p.is_file());commands=[[str(home/'bin/as-new'),*profile()['options']['assembler'],'-I',str(model),'-al='+str(w/'ROX.LST'),'-o',str(w/'ROX.ELF'),str(model/'ROX.S')]]
 p=subprocess.run(commands[-1],capture_output=True,text=True);(w/'GAS.LOG').write_text(p.stdout+p.stderr)
 if p.returncode or p.stdout or p.stderr:raise ValueError('ROX assembler failed/warned; see '+str(w/'GAS.LOG'))
 unchanged(pins);unchanged(staged);checked_home(home);raw=(w/'ROX.ELF').read_bytes();eview=elf(w/'ROX.ELF');schema=load('closed_rox_elf',model/'elf_contract.py').check(raw,eview,guard);symbols=[s for tab in eview['symbols'].values()for s in tab]
 if{s['name']for s in symbols if s['binding']==1 and s['section']>0}!=guard.PUBLICS or{s['name']for s in symbols if s['binding']==1 and s['section']==0}!=guard.IMPORTS:raise ValueError('ROX global/import scopes differ')
 if{s['name']:s['value']for s in symbols if s['section']==65521 and s['type']!=4}!=guard.FIELDS:raise ValueError('ROX ABS identities differ')
 allowed=guard.PUBLICS|guard.PRIVATE|{'rox_branch_'+str(i).zfill(2)for i in range(1,36)}|set(locations)
 if{s['name']for s in symbols if 0<s['section']<65520 and s['type']==0}!=allowed:raise ValueError('ROX private source identities differ')
 native_before=snapshot([w/'ROX.ELF',w/'ROX.LST']);dump(w/'preflight.json',{'source_contract':source_contract,'closed_ELF_schema':schema,'elf':eview,'symbols':symbols,'literal_locations':locations,'reverse_COFF_source_sha256':hashlib.sha256(back.encode()).hexdigest()});commands.append([str(home/'bin/objconv'),*profile()['options']['converter'],str(w/'ROX.ELF'),str(w/'ROX.OBJ')]);p=subprocess.run(commands[-1],capture_output=True,text=True);(w/'CONVERT.LOG').write_text(p.stdout+p.stderr)
 if p.returncode or p.stderr or'warning'in p.stdout.lower():raise ValueError('ROX converter failed/warned; see '+str(w/'CONVERT.LOG'))
 unchanged(native_before);unchanged(pins);unchanged(staged);checked_home(home);m=Module.parse((w/'ROX.OBJ').read_bytes())
 check_native(m,spec)
 receipt={'source_only':True,'original_or_target_read':False,'project':str(project),'home':str(home),'inputs_sha256':pins,'staged_sha256':staged,'native_producer_outputs_sha256':snapshot([w/'ROX.ELF',w/'ROX.LST',w/'ROX.OBJ',w/'preflight.json']),'object':str(w/'ROX.OBJ'),'object_sha256':digest(w/'ROX.OBJ'),'commands':commands,'native_inventory':inventory(m),'source_credit':0};dump(w/'source-build.json',receipt);return w

SECTION_DIRECTIVES={'.section _TEXT,"xr0"':'.section _TEXT,"ax",@progbits\n.p2align 4','.section CONST,"dw0"':'.section CONST,"aw",@progbits\n.p2align 2','.section _DATA,"dw0"':'.section _DATA,"aw",@progbits\n.p2align 2','.section _BSS,"b0"':'.section _BSS,"aw",@nobits\n.p2align 4'}

def observe(work,*,project=ROOT):
 from le import LEImage
 from tools.infer_bindings import infer_bindings
 from tools.map_candidates import locate
 from tools.verify_module import verify_module,external_anchor_bindings
 from tools.mact_rox_callees import verify_callees
 project=Path(project).resolve();w=Path(work).resolve();receipt=json.loads((w/'source-build.json').read_text())
 if receipt['project']!=str(project):raise ValueError('ROX source project identity differs')
 if not receipt['source_only']or receipt['original_or_target_read']:raise ValueError('ROX producer boundary')
 unchanged(receipt['inputs_sha256']);unchanged(receipt['staged_sha256']);unchanged(receipt['native_producer_outputs_sha256']);checked_home(receipt['home']);evidence,spec,current=read_provenance(project)
 if set(evidence['observer_tools_sha256'])!=set(OBSERVERS):raise ValueError('ROX closed observer key set')
 if any(digest(ROOT/p)!=h for p,h in evidence['observer_tools_sha256'].items()):raise ValueError('ROX observer identity changed')
 observer=snapshot([ROOT/p for p in OBSERVERS]+[ROOT/LIBRARY,ROOT/'reference/DUKE3D.EXE']);sha=digest
 lib=ROOT/LIBRARY;target=ROOT/'reference/DUKE3D.EXE';assert sha(lib)=='957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db'and sha(target)=='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4';raw=lib.read_bytes()[8192:12643];assert hashlib.sha256(raw).hexdigest()=='ef8f9c4ddac7ded7c328bbb6dcc75eb31a2b8e0f7fe343fef4247b38d36789a7'
 m=Module.parse(Path(receipt['object']).read_bytes());check_native(m,spec);orig=Module.parse(raw);im=LEImage.parse(target.read_bytes());locations=locate(m,{n:im.object_bytes(n)for n,o in enumerate(im.objects,1)if o.flags&4});bases=None
 for row in locations:
  if row['status']=='insufficient_anchor':continue
  c={(v['object'],v['offset']-row['source_offset'])for v in row['locations']};bases=c if bases is None else bases&c
 assert bases and len(bases)==1,(locations,bases)
 o,a=next(iter(bases));ob=infer_bindings(orig,im,o,a);op=verify_module(orig,im,ob['placements'],ob['symbols']);sb=infer_bindings(m,im,o,a,known_symbols=external_anchor_bindings(op));p=verify_module(m,im,sb['placements'],sb['symbols']);assert(p['initialized_bytes'],p['zero_fill_bytes'],p['verified_fixups'])==(1570,256,89);assert(op['initialized_bytes'],op['zero_fill_bytes'],op['verified_fixups'])==(1570,256,89)
 assert external_anchor_bindings(p)==external_anchor_bindings(op);assert m.publics=={n:(4,v)for n,(s,v)in orig.publics.items()if n not in orig.local_publics};assert not(m.local_publics or m.local_externals)
 pre=json.loads((w/'preflight.json').read_text());e=pre['elf'];syms=pre['symbols'];byname={s['name']:s for s in syms if s['name']};ef={r['offset']:r for r in e['relocations']};nf={f.offset:f for f in m.fixups}
 # Every actual instruction is attributed to the unchanged authored expression.
 listing=[];active=False;rows={}
 for line in(w/'ROX.LST').read_text().splitlines():
  if '\t'in line:
   lead,text=line.split('\t',1);parts=lead.split();text=text.strip()
   if not parts or not parts[0].isdigit():continue
   n=int(parts[0])
   if text=='.section _TEXT,"ax",@progbits':active=True;continue
   if active and text.startswith('.section '):break
   if active and len(parts)==3 and re.fullmatch('[0-9a-f]+',parts[1])and re.fullmatch('[0-9A-F]+',parts[2]):rows[n]={'line':n,'offset':int(parts[1],16),'data':bytes.fromhex(parts[2]),'source':text}
  elif active:
   parts=line.split()
   if len(parts)==2 and parts[0].isdigit()and int(parts[0])in rows and re.fullmatch('[0-9A-F]+',parts[1]):rows[int(parts[0])]['data']+=bytes.fromhex(parts[1])
 rawcode=bytes.fromhex(e['sections'][4]['bytes']);cursor=0
 for row in rows.values():assert row['offset']==cursor and row['data']==rawcode[cursor:cursor+len(row['data'])];cursor+=len(row['data']);listing.append({**row,'data':row['data'].hex()})
 assert cursor==1217 and len(rows)==436
 elf_to_native={s['index']:next(n for n,q in enumerate(m.segments,1)if q.name==s['name'])for s in e['sections']if s['name']in{q.name for q in m.segments}}
 private={};roles=[];private_refs=0;self_calls=0
 for name in orig.local_publics:
  s=byname[name];assert s['binding']==0 and s['type']==0;native_section=elf_to_native[s['section']];assert native_section in(6,7);assert orig.publics[name]==({6:4,7:5}[native_section],s['value']);oo,aa=sb['placements'][native_section];coord=(oo,aa+s['value']);assert coord==tuple(op['local_symbols'][name]);private[name]={'actual_ELF_identity':s,'target':coord}
 for f in orig.fixups:
  assert f.segment==1 and f.width==4;g=nf[f.offset];r=ef[f.offset];name=orig.externals[f.target-1]if f.target_method==2 else None;assert(g.segment,g.offset,g.width,g.location,g.relative)==(4,f.offset,f.width,f.location,f.relative)
  add=int.from_bytes(m._segment(4).data[g.offset:g.offset+4],'little',signed=False);eladd=r['inline_signed'];assert add==(eladd+(4 if r['type']==2 else 0))&0xffffffff
  if name in orig.local_publics:
   s=private[name]['actual_ELF_identity'];assert r['type']==1 and r['symbol']['binding']==0 and r['symbol']['section']==s['section'];assert r['symbol']['value']+add==s['value'];assert(g.target_method,g.target,g.displacement)==(0,elf_to_native[s['section']],0);line=next(q for q in listing if q['offset']<=f.offset<q['offset']+len(bytes.fromhex(q['data'])));assert re.search(r'\b'+re.escape(name)+r'\b',line['source']);private_refs+=1;kind='real-private-section+V'
  elif name in orig.publics:
   assert f.relative and(g.frame_method,g.target_method,g.displacement)==(5,2,0)and m.externals[g.target-1]==name;assert r['symbol']['binding']==1 and r['symbol']['name']==name and r['symbol']['value']==m.publics[name][1];assert add==0 and eladd==-4;self_calls+=1;kind='preserved-real-public-EXTDEF-self-call'
  else:
   if g.target_method==2:assert m.externals[g.target-1]==name and r['symbol']['name']==name and r['symbol']['section']==0
   kind='existing-import-or-literal-field'
  roles.append({'original':dataclasses.asdict(f),'original_named_target':name,'ELF':r,'native':dataclasses.asdict(g),'native_inline_unsigned':add,'kind':kind})
 assert len(roles)==89 and self_calls==12 and private_refs==29 and len(private)==5

 callees,callee_pins=verify_callees(im,{n:external_anchor_bindings(p)[n]for n in m.externals if n not in m.publics})
 assert not set(private)&set(external_anchor_bindings(p));assert set(m.externals)-set(m.publics)==set(callees_by_name(callees))
 unchanged(receipt['inputs_sha256']);unchanged(receipt['staged_sha256']);unchanged(receipt['native_producer_outputs_sha256']);unchanged(observer);unchanged(callee_pins);checked_home(receipt['home'])
 out={'kind':'complete normal ROX source contributions, not final executable','source':'src/mact/rox/ROX.S','source_sha256':digest(project/'src/mact/rox/ROX.S'),'descriptor':DESCRIPTOR,'descriptor_sha256':digest(project/DESCRIPTOR),'source_reference_sha256':digest(project/PROVENANCE),'target_sha256':TARGETSHA,'source_only':True,'original_or_target_read_during_production':False,'native_build_directory':str(w),'verification':p,'reference_verification':op,'placements':sb['placements'],'constraints':sb['constraints'],'symbol_anchors':external_anchor_bindings(p),'source_build':receipt,'private_correspondences':private,'private_references':private_refs,'public_self_call_fields':self_calls,'all_original_roles':roles,'complete_instruction_listing':listing,'source_first_nominations':locations,'unique_common_nomination':[o,a],'native_inventory':inventory(m),'callee_verifications':callees,'callee_inputs_sha256':callee_pins,'observer_inputs_sha256':observer,'source_credit':0,'full_executable_rebuilt':False,'remaining_work':['Original C lowering humanization; explicit linker default libraries; complete link/file layout']};dump(w/'whole-proof.json',out);return out

def callees_by_name(callees):
 names={}
 for r in callees.values():names.update(r.get('named_callees',r.get('named_callee',{})))
 return names

def probe(home,build):
 return observe(build_source(home,build))
if __name__=='__main__':
 import argparse
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True);p.add_argument('--elf-home',type=Path);p.add_argument('--source-only',action='store_true');a=p.parse_args();w=build_source(a.elf_home,a.build);r=json.loads((w/'source-build.json').read_text())if a.source_only else observe(w);a.report.parent.mkdir(parents=True,exist_ok=True);dump(a.report,r);print(w)
