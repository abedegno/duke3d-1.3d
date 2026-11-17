#!/usr/bin/env python3
"""Build a full uncredited CONTROL source/link candidate; preserve whole negatives.

Source-only compilation has no original SDK/target inputs. Optional observation
runs strictly after production and never changes the compiled object or bindings.
"""
import argparse
from dataclasses import asdict
import hashlib,json,os,shutil,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from runner import compile_source
from tools.build_gf1_init_candidate import encoded,metadata
SPEC='candidates/mact_control.json'
SOURCE='src/mact/control.c'
HEADERS='src/mact/control/include'
PROVENANCE='evidence/control-candidate-reference.json'
LINEAGE='src/mact/control/README.md'
OPTIONS=['/omaxnet','/zp4','/5r']
TOOLS=['tools/build_control_candidate.py','tools/build_gf1_init_candidate.py',
       'profiles/watcom/tools/runner.py','profiles/watcom/tools/omf32.py']
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def model_digest(value):return hashlib.sha256(json.dumps(value,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def runtime_model(module):
    """All runtime/encoding fields, bytes and DATA residue remain significant.

    THEADR and validated E9 DOS timestamps are producer metadata, not runtime.
    Ordered dependency paths/terminator and all other metadata are retained.
    No segment, scope, named field, source coordinate or operand is normalized.
    """
    deps=metadata(module)['E9_dependencies']
    out={k:v for k,v in vars(module).items()if k not in {'name','segments','comments'}}
    out['segments']=[asdict(s)for s in module.segments]
    out['comments']=[c for c in module.comments if c[0]!=0xe9]
    out['dependency_paths']=[d.get('path')for d in deps]
    return encoded(out)
def runtime_digest(module):return model_digest(runtime_model(module))
def read_spec():
    spec=json.loads((ROOT/SPEC).read_text())
    if(spec['name']!='mact_control'or spec['source']!=SOURCE or spec['options']!=OPTIONS or
       spec['source_credit']!=0 or spec['complete_module']is not False or spec['fixed_target_layout_verified']is not False or
       spec['expected_runtime']!={'initialized_bytes':7312,'zero_fill_bytes':1612,'fixups':467}or
       spec['original_expected']!={'initialized_bytes':7452,'zero_fill_bytes':1612,'verified_fixups':470}or
       spec['source_runtime_sha256']==spec['original_runtime_sha256']or
       spec['strict_whole_error']!='conflicting binding for public CONTROL_StartJoy_'or
       spec['DATA_differing_offsets']!=[17,18,19]):
        raise ValueError('CONTROL candidate must retain full real source and whole negative')
    return spec
def assert_runtime(module,spec):
    if runtime_digest(module)!=spec['source_runtime_sha256']:
        raise ValueError('complete CONTROL source runtime mismatch')
    counts={'initialized_bytes':sum(s.size for s in module.segments if s.class_name!='BSS'),
            'zero_fill_bytes':sum(s.size for s in module.segments if s.class_name=='BSS'),'fixups':len(module.fixups)}
    if counts!=spec['expected_runtime']:raise ValueError('CONTROL source runtime geometry mismatch')
    return counts
def compile_candidate(build,*,home=None):
    spec_hash=sha(ROOT/SPEC);spec=read_spec()
    if sha(ROOT/SPEC)!=spec_hash:raise ValueError('CONTROL spec changed during validation')
    home=Path(home).resolve()if home else ROOT/spec['toolchain']
    raw=(ROOT/PROVENANCE).read_bytes();provenance=json.loads(raw)
    if(set(provenance['producer_tools_sha256'])!=set(TOOLS)or
       provenance['source_sha256']!=spec['source_sha256']or provenance['headers_sha256']!=spec['headers_sha256']or
       provenance['fixed_profile']!=OPTIONS or provenance['source_credit']!=0 or
       provenance['complete_module']is not False or provenance['fixed_target_layout_verified']is not False or
       provenance['full_executable_rebuilt']is not False or set(provenance['notice_and_lineage_sha256'])!={LINEAGE}):
        raise ValueError('changed CONTROL closed provenance/producer contract')
    expected={str(ROOT/SPEC):spec_hash,str(ROOT/PROVENANCE):hashlib.sha256(raw).hexdigest(),str(ROOT/SOURCE):spec['source_sha256']}
    expected.update({str(ROOT/p):v for p,v in provenance['producer_tools_sha256'].items()})
    expected.update({str(ROOT/p):v for p,v in provenance['notice_and_lineage_sha256'].items()})
    expected.update({str(home/p):v for p,v in spec['tool_sha256'].items()})
    headers={p.name:sha(p)for p in sorted((ROOT/HEADERS).iterdir())if p.is_file()}
    if headers!=spec['headers_sha256']:raise ValueError('changed CONTROL seven-header identity')
    expected.update({str(ROOT/HEADERS/p):v for p,v in headers.items()})
    tool_headers={p.relative_to(home/'H').as_posix():sha(p)for p in sorted((home/'H').rglob('*'))if p.is_file()}
    if len(tool_headers)!=spec['tool_header_count']or model_digest(tool_headers)!=spec['tool_headers_inventory_sha256']:
        raise ValueError('changed CONTROL GA header identity')
    expected.update({str(home/'H'/p):v for p,v in tool_headers.items()})
    emulator=os.environ.get('EXHUME_DOSBOX_X')or shutil.which('dosbox-x')
    if not emulator:raise ValueError('missing DOSBox-X')
    expected[str(Path(emulator).resolve())]=sha(Path(emulator).resolve())
    if any(sha(p)!=v for p,v in expected.items()):raise ValueError('CONTROL source/header/tool identity changed')
    build=Path(build).resolve();build.mkdir(parents=True,exist_ok=True);work=Path(tempfile.mkdtemp(prefix='control-',dir=build))
    stage=work/'source-only';includes=stage/'include';includes.mkdir(parents=True);source=stage/'control.c';shutil.copyfile(ROOT/SOURCE,source)
    for name in headers:shutil.copyfile(ROOT/HEADERS/name,includes/name)
    staged={str(p):sha(p)for p in stage.rglob('*')if p.is_file()}
    if staged[str(source)]!=spec['source_sha256']or{p.name:sha(p)for p in includes.iterdir()}!=headers:
        raise ValueError('CONTROL staged identity changed')
    (work/'input-freeze.json').write_text(json.dumps({'live':expected,'staged':staged},indent=2)+'\n')
    obj=work/'mact_control.obj';compile_source(home,source,obj,OPTIONS,45,include_dirs=[includes])
    log=obj.with_suffix('.log').read_text(errors='replace')
    if '0 warnings, 0 errors'not in log or 'Warning!'in log or 'Error!'in log:raise ValueError('CONTROL native compiler diagnostics')
    module=Module.parse(obj.read_bytes())
    # Preserve actual output/receipt even if the full byte fingerprint fails.
    (work/'actual-module.json').write_text(json.dumps(encoded(vars(module)),indent=2)+'\n')
    if any(sha(p)!=v for p,v in {**expected,**staged}.items()):raise ValueError('CONTROL source/header/tool changed during compilation')
    counts=assert_runtime(module,spec)
    result={'candidate':'mact_control','source_credit':0,'complete_module':False,'fixed_target_layout_verified':False,
       'full_executable_rebuilt':False,'source':SOURCE,'source_sha256':spec['source_sha256'],'object':str(obj),'object_sha256':sha(obj),
       'native_build_directory':str(work),'runtime_sha256':runtime_digest(module),'runtime':counts,
       'publics':module.publics,'local_publics':sorted(module.local_publics),'externals':module.externals,'local_externals':sorted(module.local_externals),
       'global_definitions':{n:v for n,v in module.publics.items()if n not in module.local_publics},
       'external_dependencies':[n for i,n in enumerate(module.externals,1)if i not in module.local_externals and n not in module.publics],
       'same_module_global_extdefs':[n for i,n in enumerate(module.externals,1)if i not in module.local_externals and n in module.publics],
       'groups':module.groups,'segments':[{k:v for k,v in asdict(s).items()if k!='data'}for s in module.segments],
       'native_metadata':metadata(module),'all_compile_inputs_unchanged':True,'producer_input_freeze':str(work/'input-freeze.json'),
       'original_or_target_read_during_production':False,'known_remaining_failure':spec['strict_whole_error']}
    (work/'candidate-result.json').write_text(json.dumps(result,indent=2)+'\n');return result

def observe_candidate(obj,reference_root,*,build):
    """Reference-only observer; all ordinary strict whole failures stay visible."""
    from le import LEImage
    from tools.infer_bindings import infer_bindings
    from tools.verify_module import verify_module
    from tools.match_function import compare_range
    spec=read_spec();obj=Path(obj);module=Module.parse(obj.read_bytes());assert_runtime(module,spec)
    ref=Path(reference_root);image_path=ref/'DUKE3D.EXE';lib=ref/'duke3d-reconstructions/MACT386.LIB';before={str(p):sha(p)for p in [obj,image_path,lib]}
    if sha(image_path)!=spec['target_sha256']or sha(lib)!=spec['library_sha256']:raise ValueError('CONTROL observer identity changed')
    rec=spec['original_member'];raw=lib.read_bytes()[rec['offset']:rec['offset']+rec['extent']]
    if hashlib.sha256(raw).hexdigest()!=rec['sha256']:raise ValueError('CONTROL complete original member changed')
    old=Module.parse(raw)
    if runtime_digest(old)!=spec['original_runtime_sha256']:raise ValueError('CONTROL original runtime changed')
    image=LEImage.parse(image_path.read_bytes());bound=infer_bindings(old,image,1,spec['code_offset'])
    if bound['placements']!={int(k):tuple(v)for k,v in spec['placements'].items()}:raise ValueError('CONTROL original placements changed')
    proof=verify_module(old,image,bound['placements'],bound['symbols'])
    if any(proof[k]!=v for k,v in spec['original_expected'].items()):raise ValueError('CONTROL original whole incomplete')
    try:verify_module(module,image,bound['placements'],bound['symbols'])
    except ValueError as e:failure=str(e)
    else:raise ValueError('unexpected CONTROL whole positive; separate review required')
    if failure!=spec['strict_whole_error']:raise ValueError('CONTROL actual whole failure changed: '+failure)
    owned=dict(bound['symbols'])
    for n,(s,o)in module.publics.items():
        if s in bound['placements']:
            ob,start=bound['placements'][s];owned[n]=(ob,start+o)
    try:verify_module(module,image,bound['placements'],owned)
    except ValueError as e:owned_failure=str(e)
    else:raise ValueError('unexpected source-owned CONTROL whole positive')
    noncode={str(s):compare_range(module,s,0,image,*bound['placements'][s],module.segments[s-1].size,owned,bound['placements'],label='complete actual source segment')for s in(2,4,5)}
    differences=[i for i,(a,b)in enumerate(zip(module.segments[3].data,old.segments[3].data))if a!=b]
    if differences!=[17,18,19]or not noncode['2']['match']or not noncode['5']['match']:raise ValueError('CONTROL initialized/storage discrepancy changed')
    rows={};raw_different=[]
    for n,(s,start)in sorted(module.publics.items(),key=lambda x:x[1]):
        if s!=1:continue
        stop=min([o for q,o in module.publics.values()if q==1 and o>start],default=module.segments[0].size)
        os,begin=old.publics[n];end=min([o for q,o in old.publics.values()if q==1 and o>begin],default=old.segments[0].size)
        raw_equal=bytes(module.segments[0].data[start:stop])==bytes(old.segments[0].data[begin:end])
        if not raw_equal:raw_different.append(n)
        try:comparison=compare_range(module,1,start,image,1,spec['code_offset']+begin,stop-start,owned,bound['placements'],label=n)
        except ValueError as e:comparison={'error':str(e)}
        rows[n]={'source_offset':start,'source_extent':stop-start,'original_offset':begin,'original_extent':end-begin,'raw_bytes_equal':raw_equal,'strict_comparison':comparison}
    if len(rows)!=49 or sorted(raw_different)!=spec['raw_CODE_different_functions']:raise ValueError('CONTROL complete function inventory changed')
    bss={n:v for n,v in module.publics.items()if v[0]==5}
    if len(bss)!=25 or any(old.publics[n]!=v for n,v in bss.items()):raise ValueError('CONTROL real BSS roles changed')
    result={'source_credit':0,'complete_module':False,'fixed_target_layout_verified':False,'full_executable_rebuilt':False,
       'original_whole_verification':proof,'source_whole_error':failure,'source_owned_whole_error':owned_failure,
       'actual_DATA_differing_offsets':differences,'complete_nonCODE':noncode,'all_49_function_diagnostics':rows,
       'raw_CODE_different_functions':sorted(raw_different),'raw_CODE_equal_count':49-len(raw_different),
       'all25_BSS_roles_equal':True,'original_bindings':bound,'source_owned_symbols':owned,
       'comparison_scope':'Full segments and real whole function extents, no coordinate override/partial source credit.'}
    if any(sha(p)!=v for p,v in before.items()):raise ValueError('CONTROL observer inputs changed')
    build=Path(build);build.mkdir(parents=True,exist_ok=True);(build/'reference-observation.json').write_text(json.dumps(result,indent=2)+'\n');return result

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--build',type=Path,required=True);p.add_argument('--home',type=Path);p.add_argument('--observe',action='store_true');p.add_argument('--reference-root',type=Path,default=ROOT/'reference');a=p.parse_args()
    result=compile_candidate(a.build,home=a.home)
    if a.observe:result['observation']=observe_candidate(result['object'],a.reference_root,build=Path(result['native_build_directory']))
    print(json.dumps(result,indent=2))
if __name__=='__main__':main()
