"""Complete normal WAD ELF capsule, source-first and observer-only references."""
from pathlib import Path
import sys,os,json,hashlib,shutil,tempfile,subprocess,importlib.util,dataclasses,re
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')];sys.dont_write_bytecode=True
from omf32 import Module
from profiles.gnu_elf_omf.identity import checked_home,digest,profile
from profiles.gnu_elf_omf.elf32 import elf
MODEL='src/mact/wad';PROVENANCE='evidence/mact-wad-source-reference.json';DESCRIPTOR='modules/mact_wad.json'
SOURCES=['src/mact/wad/WAD.C', 'src/mact/wad/WAD.S', 'src/mact/wad/coff_contract.py', 'src/mact/wad/elf_contract.py', 'src/mact/wad/lineage/include/_wad.h', 'src/mact/wad/lineage/include/crc.h', 'src/mact/wad/lineage/include/develop.h', 'src/mact/wad/lineage/include/file_lib.h', 'src/mact/wad/lineage/include/lumptype.h', 'src/mact/wad/lineage/include/types.h', 'src/mact/wad/lineage/include/util_lib.h', 'src/mact/wad/lineage/include/wad.h', 'src/mact/wad/lineage/include/wadtype.h', 'src/mact/wad/source_contract.py']
NOTICES=[MODEL+'/README.md',MODEL+'/GPL-2.0.txt','profiles/gnu_elf_omf/README.md','profiles/capstone/README.md']
PRODUCERS=['tools/probe_mact_wad.py','profiles/gnu_elf_omf/identity.py','profiles/gnu_elf_omf/profile.json','profiles/gnu_elf_omf/elf32.py','profiles/watcom/tools/omf32.py']
OBSERVERS=['tools/prove_module.py','tools/infer_bindings.py','tools/map_candidates.py','tools/match_function.py','tools/verify_module.py','profiles/watcom/tools/le.py','tools/inventory_watcom_runtime.py','tools/mact_wad_callees.py','profiles/capstone/identity.py','profiles/capstone/files.json']
EXPECTED={'initialized_bytes':4384,'zero_fill_bytes':140,'verified_fixups':245};TARGETSHA='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4';LIBRARY='reference/duke3d-reconstructions/MACT386.LIB';LIBSHA='957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db';MEMBERSHA='ed59d08b219765234d4c9c001582b0e669443f4becc1af6da08f6532db654782'
def need(condition,message):
 if not condition:raise ValueError('WAD '+message)
def dump(p, j):
    p.write_text(json.dumps(j, indent=2, default=lambda x: x.hex() if isinstance(x, bytes) else x) + '\n')

def snapshot(paths):
    return {str(Path(p).resolve()): digest(p) for p in paths}

def unchanged(j):
    if any((not Path(p).is_file() or digest(p) != h for p, h in j.items())):
        raise ValueError('ROX input/output changed during operation')

def load(name, p):
    s = importlib.util.spec_from_file_location(name, p)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m

def inventory(m):
    return {'name': m.name, 'segments': [[s.name, s.class_name, s.size, s.attributes, s.access] for s in m.segments], 'publics': {n: list(v) for n, v in m.publics.items()}, 'local_publics': sorted(m.local_publics), 'externals': m.externals, 'local_externals': sorted(m.local_externals), 'groups': [[n, list(v)] for n, v in m.groups], 'fixups': [dataclasses.asdict(f) for f in m.fixups], 'default_libraries': m.default_libraries, 'far_call_optimization_segments': sorted(m.far_call_optimization_segments), 'format': m.format, 'comments': [[k, v.hex()] for k, v in m.comments], 'code_data_ranges': [list(v) for v in m.code_data_ranges], 'dosseg_directives': m.dosseg_directives, 'format_source': m.format_source, 'line_numbers': m.line_numbers, 'thread_definitions': m.thread_definitions, 'source_records': m.source_records, 'fixup_encodings': json.loads(json.dumps(m.fixup_encodings, default=lambda x: x.hex() if isinstance(x, bytes) else x))}
def read_provenance(project=ROOT):
 project=Path(project).resolve();raw=(project/PROVENANCE).read_bytes();desc=(project/DESCRIPTOR).read_bytes();e=json.loads(raw);spec=json.loads(desc)
 for field,paths in [('tracked_sources_sha256',SOURCES),('notice_files_sha256',NOTICES),('producer_tools_sha256',PRODUCERS)]:
  need(set(e[field])==set(paths),'closed '+field)
  for p,h in e[field].items():need(digest(project/p)==h,'changed source/tool/notice '+p)
 need(hashlib.sha256(desc).hexdigest()==e['descriptor_sha256']and spec['name']=='mact_wad'and spec['expected']==EXPECTED and spec['options']==profile()['options'],'descriptor/profile');pins={str((project/p).resolve()):h for field in ['tracked_sources_sha256','notice_files_sha256','producer_tools_sha256']for p,h in e[field].items()};pins.update({str(project/PROVENANCE):hashlib.sha256(raw).hexdigest(),str(project/DESCRIPTOR):hashlib.sha256(desc).hexdigest()});unchanged(pins);return e,spec,pins

def check_native(m,spec):need(inventory(m)==spec['native_inventory'],'complete native metadata/scope/field roles')

def build_source(home=None,build=None,*,project=ROOT):
 project=Path(project).resolve();home=Path(home or os.environ.get('GNU_ELF_OMF_HOME',ROOT/'toolchains/gnu-elf-omf')).resolve();e,spec,pins=read_provenance(project);tools=checked_home(home);pins.update({str(home/p):h for p,h in tools.items()});pins.update(snapshot([Path(sys.executable).resolve()]));parent=Path(build or project/'build/wad').resolve();parent.mkdir(parents=True,exist_ok=True);w=Path(tempfile.mkdtemp(prefix='wad-elf-',dir=parent));stage=w/'source-only';stage.mkdir()
 for p in SOURCES+NOTICES:
  q=stage/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(project/p,q)
 unchanged(pins);staged=snapshot(stage/p for p in SOURCES+NOTICES);need(all(digest(stage/p)==pins[str((project/p).resolve())]for p in SOURCES+NOTICES),'source-stage identity');model=stage/MODEL;contract=load('closed_wad_source',model/'source_contract.py');source=contract.check((model/'WAD.S').read_text());unchanged(staged);unchanged(pins)
 commands=[[str(home/'bin/as-new'),*profile()['options']['assembler'],'-al='+str(w/'WAD.LST'),'-o',str(w/'WAD.ELF'),str(model/'WAD.S')]];p=subprocess.run(commands[-1],capture_output=True,text=True);(w/'GAS.LOG').write_text(p.stdout+p.stderr);need(p.returncode==0 and not(p.stdout or p.stderr),'assembler error/warning');unchanged(pins);unchanged(staged);checked_home(home);eview=elf(w/'WAD.ELF');schema=load('closed_wad_elf',model/'elf_contract.py').check((w/'WAD.ELF').read_bytes(),eview,(model/'WAD.S').read_text());dump(w/'preflight.json',eview);dump(w/'source-schema.json',{'source':source,'ELF':schema});outputs=snapshot([w/'WAD.ELF',w/'WAD.LST',w/'preflight.json',w/'source-schema.json'])
 for form,suffix in [('-fomf32','OBJ'),('-fcoff32','COFF')]:
  commands.append([str(home/'bin/objconv'),form,'-wex',str(w/'WAD.ELF'),str(w/('WAD.'+suffix))]);p=subprocess.run(commands[-1],capture_output=True,text=True);(w/('CONVERT-'+suffix+'.LOG')).write_text(p.stdout+p.stderr);need(p.returncode==0 and not p.stderr and'warning'not in p.stdout.lower(),'converter error/warning');unchanged(pins);unchanged(staged);unchanged(outputs);checked_home(home);outputs.update(snapshot([w/('WAD.'+suffix)]))
 m=Module.parse((w/'WAD.OBJ').read_bytes());check_native(m,spec);coff=load('closed_wad_coff',model/'coff_contract.py').check(w,eview,m);dump(w/'COFF-identity.json',coff);outputs.update(snapshot([w/'COFF-identity.json']));unchanged(pins);unchanged(staged);checked_home(home);r={'source_only':True,'original_or_target_read':False,'project':str(project),'home':str(home),'inputs_sha256':pins,'staged_sha256':staged,'native_outputs_sha256':outputs,'object':str(w/'WAD.OBJ'),'object_sha256':digest(w/'WAD.OBJ'),'commands':commands,'native_inventory':inventory(m),'source_credit':0};dump(w/'source-build.json',r);return w

def observe(work,*,project=ROOT):
 from le import LEImage
 from tools.map_candidates import locate
 from tools.infer_bindings import infer_bindings
 from tools.verify_module import verify_module,external_anchor_bindings
 from tools.mact_wad_callees import verify_callees
 from profiles.capstone import identity as decoder
 project=Path(project).resolve();w=Path(work).resolve();r=json.loads((w/'source-build.json').read_text());need(r['source_only']and not r['original_or_target_read']and r['project']==str(project),'source boundary/project');unchanged(r['inputs_sha256']);unchanged(r['staged_sha256']);unchanged(r['native_outputs_sha256']);checked_home(r['home']);evidence,spec,current=read_provenance(project);need(set(evidence['observer_tools_sha256'])==set(OBSERVERS),'observer keys');need(all(digest(ROOT/p)==h for p,h in evidence['observer_tools_sha256'].items()),'observer identities');observer=snapshot([ROOT/p for p in OBSERVERS]+[ROOT/LIBRARY,ROOT/'reference/DUKE3D.EXE']);sha=digest
 lib = ROOT / LIBRARY
 target = ROOT / 'reference/DUKE3D.EXE'
 if not (sha(lib) == '957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db' and sha(target) == 'a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'):
     raise ValueError('WAD complete whole/scope/role guard')
 raw = lib.read_bytes()[23552:33464]
 if not hashlib.sha256(raw).hexdigest() == 'ed59d08b219765234d4c9c001582b0e669443f4becc1af6da08f6532db654782':
     raise ValueError('WAD complete whole/scope/role guard')
 orig = Module.parse(raw)
 m = Module.parse((w / 'WAD.OBJ').read_bytes())
 im = LEImage.parse(target.read_bytes())
 locations = locate(m, {n: im.object_bytes(n) for n, o in enumerate(im.objects, 1) if o.flags & 4})
 candidates = sorted({(v['object'], v['offset'] - row['source_offset']) for row in locations for v in row.get('locations', [])})
 attempts = []
 wins = []
 for obj, base in candidates:
     try:
         ob = infer_bindings(orig, im, obj, base)
         op = verify_module(orig, im, ob['placements'], ob['symbols'])
         sb = infer_bindings(m, im, obj, base)
         p = verify_module(m, im, sb['placements'], sb['symbols'])
         if not (p['initialized_bytes'], p['zero_fill_bytes'], p['verified_fixups']) == (4384, 140, 245):
             raise ValueError('WAD complete whole/scope/role guard')
         if not (op['initialized_bytes'], op['zero_fill_bytes'], op['verified_fixups']) == (4384, 140, 245):
             raise ValueError('WAD complete whole/scope/role guard')
         if not external_anchor_bindings(p) == external_anchor_bindings(op):
             raise ValueError('WAD complete whole/scope/role guard')
         wins.append((ob, op, sb, p))
         attempts.append({'placement': [obj, base], 'match': True})
     except (ValueError, AssertionError) as err:
         attempts.append({'placement': [obj, base], 'match': False, 'error': str(err)})
 if not len(wins) == 1:
     raise ValueError((attempts, locations))
 ob, op, sb, p = wins[0]
 codeobj, base = sb['placements'][4]
 if not m.publics == {n: (4, v) for n, (s, v) in orig.publics.items() if n not in orig.local_publics}:
     raise ValueError('WAD complete whole/scope/role guard')
 if not (len(m.publics) == 26 and len(set(m.publics.values())) == 25 and (not (m.local_publics or m.local_externals))):
     raise ValueError('WAD complete whole/scope/role guard')
 e = json.loads((w / 'preflight.json').read_text())
 syms = [s for tab in e['symbols'].values() for s in tab]
 byname = {s['name']: s for s in syms if s['name']}
 emap = {s['index']: next((i for i, q in enumerate(m.segments, 1) if q.name == s['name'])) for s in e['sections'] if s['name'] in {q.name for q in m.segments}}
 mnames = {s.name: i for i, s in enumerate(m.segments, 1)}
 ef = {(emap[z['source_section']], z['offset']): z for z in e['relocations']}
 nf = {(f.segment, f.offset): f for f in m.fixups}
 private = {}
 roles = []
 pn = selfcalls = 0
 lines = (w / 'WAD.LST').read_text().splitlines()
 src = (w / 'source-only' / MODEL / 'WAD.S').read_text().splitlines()
 rows = {}
 section = None
 lineno_section = {}
 current = None
 for n, line in enumerate(src, 1):
     t = line.partition('#')[0].strip()
     if t.startswith('.section '):
         current = t.split()[1].split(',')[0]
     lineno_section[n] = current
 for line in lines:
     if '\t' in line:
         lead, text = line.split('\t', 1)
         parts = lead.split()
         if not parts or not parts[0].isdigit():
             continue
         n = int(parts[0])
         if not text.rstrip() == src[n - 1].rstrip():
             raise ValueError('WAD complete whole/scope/role guard')
         if len(parts) == 3 and re.fullmatch('[0-9a-f]+', parts[1]) and re.fullmatch('[0-9A-F]+', parts[2]):
             rows[n] = {'line': n, 'section': lineno_section[n], 'offset': int(parts[1], 16), 'data': bytes.fromhex(parts[2]), 'source': text.strip()}
     else:
         parts = line.split()
         if len(parts) == 2 and parts[0].isdigit() and (int(parts[0]) in rows) and re.fullmatch('[0-9A-F]+', parts[1]):
             rows[int(parts[0])]['data'] += bytes.fromhex(parts[1])
 code = bytes.fromhex(next((s['bytes'] for s in e['sections'] if s['name'] == '_TEXT')))
 listing = [z for z in rows.values() if z['section'] == '_TEXT']
 cursor = 0
 for z in listing:
     if not (z['offset'] == cursor and z['data'] == code[cursor:cursor + len(z['data'])]):
         raise ValueError('WAD complete whole/scope/role guard')
     cursor += len(z['data'])
 if not cursor == 3326:
     raise ValueError('WAD complete whole/scope/role guard')
 for name in orig.local_publics:
     sym = byname[name]
     sn = emap[sym['section']]
     original_segment, off = orig.publics[name]
     if not (sym['binding'] == 0 and sym['type'] == 0 and ((sn, sym['value']) == (mnames[orig._segment(original_segment).name], off))):
         raise ValueError('WAD complete whole/scope/role guard')
     o, a = sb['placements'][sn]
     if not (o, a + off) == tuple(op['local_symbols'][name]):
         raise ValueError('WAD complete whole/scope/role guard')
     if not (name not in m.publics and name not in m.externals):
         raise ValueError('WAD complete whole/scope/role guard')
     private[name] = {'ELF': sym, 'native_segment': sn, 'target': [o, a + off]}
 
 def fieldtarget(mod, f, places, symbols):
     a = int.from_bytes(mod._segment(f.segment).data[f.offset:f.offset + 4], 'little') + f.displacement
     if f.target_method == 2:
         obj, start = symbols[mod.externals[f.target - 1]]
     else:
         if not f.target_method == 0:
             raise ValueError('WAD complete whole/scope/role guard')
         obj, start = places[f.target]
     return (obj, start + a)
 for f in orig.fixups:
     sn = mnames[orig._segment(f.segment).name]
     g = nf[sn, f.offset]
     er = ef[sn, f.offset]
     name = orig.externals[f.target - 1] if f.target_method == 2 else orig._segment(f.target).name
     if not (f.width, f.location, f.relative) == (g.width, g.location, g.relative):
         raise ValueError('WAD complete whole/scope/role guard')
     if not fieldtarget(orig, f, ob['placements'], ob['symbols']) == fieldtarget(m, g, sb['placements'], p['publics']):
         raise ValueError('WAD complete whole/scope/role guard')
     add = int.from_bytes(m._segment(sn).data[g.offset:g.offset + 4], 'little')
     if not add == er['inline_signed'] + (4 if er['type'] == 2 else 0) & 4294967295:
         raise ValueError('WAD complete whole/scope/role guard')
     if name in private:
         s = private[name]['ELF']
         oldadd = int.from_bytes(orig._segment(f.segment).data[f.offset:f.offset + 4], 'little') + f.displacement
         if not (er['symbol']['binding'] == 0 and er['symbol']['section'] == s['section']):
             raise ValueError('WAD complete whole/scope/role guard')
         if not er['symbol']['value'] + add + g.displacement == s['value'] + oldadd:
             raise ValueError('WAD complete whole/scope/role guard')
         if not (g.target_method, g.target) == (0, emap[s['section']]):
             raise ValueError('WAD complete whole/scope/role guard')
         row = next((z for z in listing if z['offset'] <= g.offset < z['offset'] + len(z['data'])))
         if not re.search('(?<![A-Za-z_0-9])' + re.escape(name) + '(?![A-Za-z_0-9])', row['source']):
             raise ValueError('WAD complete whole/scope/role guard')
         pn += 1
         kind = 'actual-qualified-private'
     elif f.relative and f.target_method == 2 and (name in m.publics):
         if not (f.relative and f.target_method == 2 and (name in m.publics)):
             raise ValueError('WAD complete whole/scope/role guard')
         if not ((g.frame_method, g.target_method, g.displacement) == (5, 2, 0) and m.externals[g.target - 1] == name):
             raise ValueError('WAD complete whole/scope/role guard')
         if not (er['symbol']['name'] == name and er['symbol']['binding'] == 1 and (er['symbol']['value'] == m.publics[name][1])):
             raise ValueError('WAD complete whole/scope/role guard')
         selfcalls += 1
         kind = 'new-real-public-selfCALL-EXTDEF'
     else:
         kind = 'retained-actual-field'
     roles.append({'original': dataclasses.asdict(f), 'source': dataclasses.asdict(g), 'ELF': er, 'name': name, 'target': fieldtarget(m, g, sb['placements'], p['publics']), 'kind': kind})
 if not (len(roles) == 245 and len(private) == 9 and (pn == 81) and (selfcalls == 14)):
     raise ValueError('WAD complete whole/scope/role guard')
 if not set(m.externals) - set(m.publics) == set(spec['original_imports']):
     raise ValueError('WAD complete whole/scope/role guard')

 check_native(m,spec)
 decoder_home=Path(os.environ.get('CAPSTONE_HOME',ROOT/'toolchains/capstone')).resolve();cs=decoder.load(decoder_home);decoder_pins={str(decoder_home/p):h for p,h in decoder.checked_home(decoder_home).items()};dis=cs.Cs(cs.CS_ARCH_X86,cs.CS_MODE_32);instructions=list(dis.disasm(bytes(m._segment(4).data),0));need(len(instructions)==len(listing)==1157 and sum(i.size for i in instructions)==3326,'complete1157 actual instruction decode');need(all((i.address,i.size)==(z['offset'],len(z['data']))for i,z in zip(instructions,listing)),'source/decoded instruction ownership')
 callees,callee_pins=verify_callees(im,{n:external_anchor_bindings(p)[n]for n in spec['original_imports']});need(not set(private)&set(external_anchor_bindings(p)),'private anchor leakage');unchanged(r['inputs_sha256']);unchanged(r['staged_sha256']);unchanged(r['native_outputs_sha256']);unchanged(observer);unchanged(callee_pins);unchanged(decoder_pins);checked_home(r['home'])
 out={'kind':'complete normal WAD source contributions, not full executable','source':MODEL+'/WAD.S','source_sha256':digest(project/MODEL/'WAD.S'),'source_reference_sha256':digest(project/PROVENANCE),'descriptor':DESCRIPTOR,'descriptor_sha256':digest(project/DESCRIPTOR),'target_sha256':TARGETSHA,'source_build':r,'verification':p,'reference_verification':op,'placements':sb['placements'],'constraints':sb['constraints'],'native_build_directory':str(w),'native_inventory':inventory(m),'private_correspondences':private,'private_references':pn,'public_self_call_fields':selfcalls,'all_original_roles':roles,'complete_CODE_listing':[dict(z,data=z['data'].hex())for z in listing],'nominations':locations,'complete_candidate_gates':attempts,'callee_verifications':callees,'callee_inputs_sha256':callee_pins,'observer_inputs_sha256':observer,'decoder_inputs_sha256':decoder_pins,'source_credit':0,'full_executable_rebuilt':False};dump(w/'whole-proof.json',out);return out

def probe(home,build):return observe(build_source(home,build))
if __name__=='__main__':
 import argparse
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--build',type=Path,required=True);p.add_argument('--report',type=Path,required=True);p.add_argument('--elf-home',type=Path);p.add_argument('--source-only',action='store_true');a=p.parse_args();w=build_source(a.elf_home,a.build);r=json.loads((w/'source-build.json').read_text())if a.source_only else observe(w);a.report.parent.mkdir(parents=True,exist_ok=True);dump(a.report,r);print(w)
