"""Compile and prove complete module contributions from a fixed descriptor.

This does not link the complete executable or prove historic symbol spelling.
"""
import argparse
from dataclasses import asdict
import hashlib
import json
from pathlib import Path
import shutil
import sys
import tempfile

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import compile_source,assemble_source,compiler_bin
from tools.infer_bindings import infer_bindings,infer_data_bindings
from tools.verify_module import verify_module
from tools.preserve import TARGET_SHA256
from tools.object_contributions import without_watcom_debug


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def prepare_headers(reference: Path | list[Path], overlay: Path | list[Path], output: Path) -> None:
    output.mkdir(parents=True,exist_ok=False)
    references=reference if isinstance(reference,list) else [reference]
    overlays=overlay if isinstance(overlay,list) else [overlay]
    reference_names={}
    for directory,is_reference in [(p,True) for p in references]+[(p,False) for p in overlays]:
        seen=set()
        for path in sorted(directory.iterdir()):
            if path.is_file() and path.suffix.lower()=='.h':
                name=path.name.lower()
                if name in seen:
                    raise ValueError('case-colliding header names')
                seen.add(name)
                if is_reference:
                    identity=digest(path)
                    if name in reference_names and reference_names[name]!=identity:
                        raise ValueError('conflicting reference header names')
                    reference_names[name]=identity
                shutil.copyfile(path,output/name)


def assert_contributions(report: dict,expected: dict) -> None:
    if report.get('verified') is not True:
        raise ValueError('module has not been verified')
    keys={'initialized_bytes','zero_fill_bytes','verified_fixups'}
    if set(expected)!=keys or expected['initialized_bytes']<=0:
        raise ValueError('incomplete expected module contribution contract')
    for key in sorted(keys):
        if report.get(key)!=expected[key]:
            raise ValueError(f'incomplete {key}: {report.get(key)} != {expected[key]}')


def assert_native_inventory(module, spec):
    """Check an optional raw segment/library contract before any debug view."""
    if 'native_segments' in spec:
        actual=[{'name':s.name,'class':s.class_name,'size':s.size,
                 'attributes':s.attributes,'access':s.access} for s in module.segments]
        if actual!=spec['native_segments']:
            raise ValueError('native segment inventory differs from contract')
    if ('expected_default_libraries' in spec and
            module.default_libraries!=spec['expected_default_libraries']):
        raise ValueError('native default libraries differ from contract')


def prove(module_name: str,home: Path,build: Path) -> dict:
    if module_name=='irq':
        from tools.probe_irq_symbolic import probe
        return probe(home,build)
    if module_name in {'gf1_dma','gf1_utils_native'}:
        from tools.probe_gf1_symbolic import probe
        return probe(module_name,home,build)
    if module_name in {'sndscape','sndsrc','pas16','irq','blaster'}:
        from tools.probe_audio_layout import probe
        return probe(module_name,home,build)
    if module_name=='mact_control':
        from tools.probe_mact_control import probe
        return probe(home,build)
    if module_name=='mact_clrmap':
        from tools.probe_mact_clrmap import probe
        return probe(home,build)
    if module_name=='mact_lbmlib':
        from tools.probe_mact_lbmlib import probe
        return probe(home,build)
    if module_name=='mact_tlibdos':
        from tools.probe_mact_tlibdos import probe
        return probe(home,build)
    if module_name=='mact_wad':
        from tools.probe_mact_wad import probe
        return probe(home,build)
    if module_name=='mact_penttime':
        from tools.probe_mact_penttime import probe
        return probe(home,build)
    if module_name=='mact_mipmap':
        from tools.probe_mact_mipmap import probe
        return probe(home,build)
    if module_name=='mact_rox':
        from tools.probe_mact_rox import probe
        return probe(home,build)
    if module_name=='mact_vidmsdos':
        from tools.probe_mact_vidmsdos import probe
        return probe(home,build)
    if module_name in {'gf1_voltab','gf1_wdigital'}:
        from tools.probe_gf1_tiny import probe
        return probe(module_name,home,build)
    if module_name=='mact_vector':
        from tools.probe_mact_vector import probe
        return probe(home,build)
    if module_name=='mact_time':
        from tools.probe_mact_time import probe
        return probe(home,build)
    if module_name=='gf1_digital':
        from tools.probe_gf1_digital import probe
        return probe(home,build)
    if module_name=='gf1_wsound':
        from tools.probe_gf1_wsound import probe
        return probe(home,build)
    if module_name=='gf1_sound':
        from tools.probe_gf1_sound import probe
        return probe(home,build)
    if module_name=='gf1_note':
        from tools.probe_gf1_note import probe
        return probe(home,build)
    if module_name=='gf1_dram':
        from tools.probe_gf1_dram import probe
        return probe(home,build)
    if module_name=='mact_debug':
        from tools.probe_mact_debug import probe
        return probe(home,build)
    if module_name=='mact_zone':
        from tools.probe_mact_zone import probe
        return probe(home,build)
    if module_name=='pawe_midieng':
        from tools.probe_pawe_midieng import probe
        return probe(home, build)
    if module_name=='pawe_sbkload':
        from tools.probe_pawe_sbkload import probe
        return probe(home,build)
    if module_name=='pawe_nrpn':
        from tools.probe_pawe_nrpn import probe
        return probe(home,build)
    if module_name=='pawe_hardware':
        from tools.probe_pawe_hardware import probe
        return probe(home,build)
    if module_name=='gf1_detct':
        from tools.probe_gf1_detct import probe
        return probe(home,build)
    if module_name=='gf1_ainit':
        from tools.probe_gf1_ainit import probe
        return probe(home,build)
    if module_name=='mact_tokenlib':
        from tools.probe_mact_tokenlib import probe
        return probe(home,build)
    if module_name=='mact_scriplib':
        from tools.probe_mact_scriplib import probe
        return probe(home,build)
    if module_name in {'gf1_wtimer','gf1_wdma','gf1_wmem','gf1_wnote','gf1_wvoic','gf1_wuart'}:
        from tools.probe_gf1_init import probe
        build.mkdir(parents=True,exist_ok=True)
        native=Path(tempfile.mkdtemp(prefix=module_name+'-',dir=build))/'native'
        return probe(module_name,home,native)
    if module_name=='gf1_globals':
        from tools.probe_gf1_globals import probe
        return probe(home,build)
    if module_name=='mact_rgb':
        from tools.probe_mact_rgb import probe
        return probe(home,build)
    if module_name in {'gf1_scale','gf1_divisor'}:
        from tools.probe_gf1_data import prove as prove_data
        build.mkdir(parents=True,exist_ok=True)
        native=Path(tempfile.mkdtemp(prefix=module_name+'-',dir=build))/'native'
        report=prove_data(module_name,home,native)
        report['native_build_directory']=str(native.resolve())
        return report
    if module_name=='mact_file':
        from tools.probe_mact_file import probe
        return probe(home,build)
    if module_name=='mact_util':
        from tools.probe_mact_util import probe
        return probe(home,build)
    if module_name=='mact_random':
        from tools.probe_mact_random import probe
        return probe(home,build)
    if module_name=='actors':
        from tools.probe_actors_composite import probe
        build.mkdir(parents=True,exist_ok=True)
        native=Path(tempfile.mkdtemp(prefix='actors-',dir=build))/'native'
        report=probe(home,native)
        report['native_build_directory']=str(native.resolve())
        return report
    if module_name not in {'rts','animlib','ll_man','task_man','dpmi','mpu401','pitch','dma','sndsrc','irq','sndscape','blaster','al_midi','midi','guswave','pas16','cache1d','fx_man','awe32','music','multivoc','mv_mix','mv_mix16','mvreverb','gus','gusmidi','user','gmtimbre','engine_asm','mmulti','sounds','config','gamedef','sector','player','premap','debugio','menues','watcom_rand','gf1_mixer','gf1_uart','gf1_rec','gf1_timer','gf1_addr','gf1_dma1','gf1_error','mact_crc','gf1_utils','mact_mathutil','actors','mact_random','mact_util','mact_file','mact_scriplib','mact_tokenlib','gf1_scale','gf1_divisor','mact_rgb','mact_keyboard','gf1_globals','gf1_sem','gf1_isr','gf1_wtimer','gf1_wdma','gf1_wmem','gf1_wnote','gf1_wvoic','gf1_wuart','gf1_wave','gf1_mem','gf1_voice','gf1_wisr','gf1_note1','gf1_patch','gf1_pat1','gf1_midi','gf1_digpause','gf1_digpos'}:
        raise ValueError('unknown recovered module')
    descriptor=ROOT/'modules'/f'{module_name}.json'
    config_bytes=descriptor.read_bytes()
    spec=json.loads(config_bytes)
    if 'bss_boundary' in spec or (module_name=='premap' and 'boundary_evidence' in spec):
        raise ValueError('BSS boundary overrides are unsupported; native ownership must infer placement')
    binary=(ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(binary).hexdigest()!=TARGET_SHA256:
        raise ValueError('reference identity mismatch')
    image=LEImage.parse(binary)
    source=ROOT/spec['source'];source_hash=digest(source)
    build.mkdir(parents=True,exist_ok=True)
    obj=build/f'{module_name}.obj'
    producer=spec.get('producer','watcom')
    if producer in ('tasm','masm'):
        hashes={}
        assemble_source(home,source,obj,spec['options'],30,producer=producer)
        identity={'assembler_sha256':digest(home/('TASM.EXE' if producer=='tasm' else 'MASM.EXE'))}
    elif producer=='watcom':
        with tempfile.TemporaryDirectory(prefix='headers-',dir=build) as temporary:
            headers=Path(temporary)/'include'
            reference=spec.get('reference_headers','dukenukem3d/source')
            reference=([ROOT/p for p in reference] if isinstance(reference,list)
                       else ROOT/reference)
            overlay=spec.get('overlay_headers','src/include')
            overlay=([ROOT/p for p in overlay] if isinstance(overlay,list) else ROOT/overlay)
            prepare_headers(reference,overlay,headers)
            hashes={p.name:digest(p) for p in sorted(headers.iterdir())}
            compile_source(home,source,obj,spec['options'],30,include_dirs=[headers])
        identity={'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe')}
    else:
        raise ValueError('unsupported source producer')
    if digest(source)!=source_hash:
        raise ValueError('source changed during compilation')
    module=Module.parse(obj.read_bytes())
    assert_native_inventory(module,spec)
    if 'expected_publics' in spec or 'expected_local_publics' in spec:
        publics=spec.get('expected_publics')
        local=spec.get('expected_local_publics')
        if (not isinstance(publics,dict) or not isinstance(local,list) or
                any(not isinstance(n,str) or not n for n in publics) or
                any(not isinstance(v,list) or len(v)!=2 or
                    any(type(x) is not int for x in v) for v in publics.values()) or
                any(not isinstance(n,str) for n in local) or
                len(set(local))!=len(local) or not set(local)<=publics.keys()):
            raise ValueError('incomplete native public/scope contract')
        if (module.publics!={n:tuple(v) for n,v in publics.items()} or
                module.local_publics!=set(local)):
            raise ValueError('native public definitions or local scopes differ from contract')
    if 'expected_externals' in spec:
        if (module.externals!=spec['expected_externals'] or
                sorted(module.local_externals)!=spec.get('expected_local_externals',[])):
            raise ValueError('native external declarations or local scopes differ from contract')
    if 'expected_fixups' in spec:
        if [asdict(fix) for fix in module.fixups]!=spec['expected_fixups']:
            raise ValueError('native fixup target roles differ from contract')
    if 'expected_groups' in spec:
        if [[name,list(members)] for name,members in module.groups]!=spec['expected_groups']:
            raise ValueError('native group membership differs from contract')
    metadata={}
    if spec.get('debug_format')=='watcom':
        module,excluded=without_watcom_debug(module)
        metadata={'debug_metadata':{'format':'Watcom native',
                                   'excluded_segments':excluded,
                                   'line_entries':len(module.line_numbers)}}
    elif 'debug_format' in spec:
        raise ValueError('unsupported debug format')
    code_segments={n for n,s in enumerate(module.segments,1) if s.class_name.upper()=='CODE' and s.size}
    if sum(module.segments[n-1].size for n in code_segments)!=spec['code_bytes']:
        raise ValueError('compiled text does not cover the complete expected module')
    code_publics=sum(seg in code_segments for seg,_ in module.publics.values())
    if code_publics!=spec['code_publics']:
        raise ValueError('compiled CODE public count differs from recovered module')
    if spec.get('data_only'):
        if len(module.publics)!=spec['data_publics']:
            raise ValueError('data public count differs from recovered module')
        inferred=infer_data_bindings(module,spec['symbol_anchors'])
    else:
        inferred=infer_bindings(module,image,spec['code_object'],spec['code_offset'],
                                known_symbols=spec.get('symbol_anchors',{}))
        if module_name=='gf1_utils':
            from tools.probe_gf1 import complete_utils_bindings
            inferred=complete_utils_bindings(module,image,inferred)
    proof=verify_module(module,image,inferred['placements'],inferred['symbols'])
    assert_contributions(proof,spec['expected'])
    return {'kind':f'complete {spec["name"]} object contributions, not a full executable',
            'target_sha256':TARGET_SHA256,'source':spec['source'],
            'source_sha256':source_hash,'headers_sha256':hashes,
            'descriptor':str(descriptor.relative_to(ROOT)),
            'descriptor_sha256':hashlib.sha256(config_bytes).hexdigest(),
            **identity,
            **metadata,
            'options':spec['options'],'placements':inferred['placements'],
            'constraints':inferred['constraints'],'verification':proof,
            'symbol_anchors':spec.get('symbol_anchors',{}),
            'anchor_evidence':spec.get('anchor_evidence'),
            'unresolved_project_work':['other modules','linker and binder reproduction',
                                       'whole-file identity','humanization'],
            'full_executable_rebuilt':False}


def main(default_module=None):
    p=argparse.ArgumentParser(description=__doc__)
    if default_module is None:
        p.add_argument('module',choices=['gf1_dma', 'gf1_utils_native', 'mact_clrmap', 'mact_control', 'mact_lbmlib', 'mact_tlibdos', 'mact_wad', 'mact_penttime', 'mact_mipmap', 'rts', 'animlib', 'll_man', 'task_man', 'dpmi', 'mpu401', 'pitch', 'dma', 'sndsrc', 'irq', 'sndscape', 'blaster', 'al_midi', 'midi', 'guswave', 'pas16', 'cache1d', 'fx_man', 'awe32', 'music', 'multivoc', 'mv_mix', 'mv_mix16', 'mvreverb', 'gus', 'gusmidi', 'user', 'gmtimbre', 'engine_asm', 'mmulti', 'sounds', 'config', 'gamedef', 'sector', 'player', 'premap', 'debugio', 'menues', 'watcom_rand', 'gf1_mixer', 'gf1_uart', 'gf1_rec', 'gf1_timer', 'gf1_addr', 'gf1_dma1', 'gf1_error', 'mact_crc', 'gf1_utils', 'mact_mathutil', 'actors', 'mact_random', 'mact_util', 'mact_file', 'mact_scriplib', 'mact_tokenlib', 'gf1_scale', 'gf1_divisor', 'mact_rgb', 'mact_keyboard', 'gf1_globals', 'gf1_sem', 'gf1_isr', 'gf1_wtimer', 'gf1_wdma', 'gf1_wmem', 'gf1_wnote', 'gf1_wvoic', 'gf1_wuart', 'gf1_wave', 'gf1_mem', 'gf1_voice', 'gf1_wisr', 'gf1_note1', 'gf1_patch', 'gf1_pat1', 'gf1_midi', 'gf1_ainit', 'gf1_detct', 'pawe_nrpn', 'mact_zone', 'pawe_midieng', 'pawe_sbkload', 'pawe_hardware', 'gf1_digpause', 'gf1_digpos', 'mact_vidmsdos', 'gf1_dram', 'gf1_digital', 'gf1_note', 'gf1_voltab', 'gf1_wdigital', 'mact_debug', 'mact_time', 'gf1_sound', 'gf1_wsound', 'mact_vector','mact_rox'])
    p.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    p.add_argument('--build',type=Path)
    p.add_argument('--report',type=Path)
    a=p.parse_args();name=default_module or a.module
    report=prove(name,a.home.resolve(),(a.build or ROOT/'build'/f'{name}-proof').resolve())
    output=a.report or ROOT/'evidence'/f'{name}-module.json'
    output.parent.mkdir(parents=True,exist_ok=True)
    output.write_text(json.dumps(report,indent=2)+'\n')
    v=report['verification']
    print(f"{name.upper()} VERIFIED: {v['initialized_bytes']} initialized bytes, "
          f"{v['zero_fill_bytes']} BSS bytes, {v['verified_fixups']} fixups")


if __name__=='__main__':
    main()
