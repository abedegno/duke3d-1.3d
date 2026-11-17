"""Prove three source-built MACT assembly members at measured LE placements.

Native WASM output alone supplies contribution bytes. Original archive members
are separately verified references; the empty-class TEXT is never reclassified.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import CompilerError,run_batch,assembly_source_name
from tools.inventory_watcom_runtime import read_archive,select_member
from tools.preserve import TARGET_SHA256
from tools.prove_module import assert_contributions
from tools.verify_module import verify_module

ASSEMBLER_SHA256 = 'a4419d0acab40f841d6fd00540f1813f6128d9630fbb150fc4618646c358f7f2'
LIBRARY_SHA256 = '957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db'
OPTIONS = ['-fo=OUT.OBJ']
# Independently measured original member geometry, not target instruction arrays.
CONTRACTS = {
    'pent': {'data':16,'text':56,'offset':0,'data_offset':67936,'fixups':6,
             'publics':{'_PENT_timeh':[2,8],'_PENT_timel':[2,12],
                        'PENT_Start_':[3,0],'PENT_Stop_':[3,22]},
             'member':{'offset':5120,'size':282,'name':'pent.asm',
                       'sha256':'24fd4545aa51b8a88882287773b92b9f9172f02939432fe075577a5629d01361'},
             'data_names':{'previous_high':'dd','previous_low':'dd','_PENT_timeh':'dd','_PENT_timel':'dd'}},
    'precise': {'data':2,'text':61,'offset':64,'data_offset':67964,'fixups':7,
                'publics':{'PRECISION_High_':[3,0],'PRECISION_Low_':[3,35]},
                'member':{'offset':14336,'size':276,'name':'precise.asm',
                          'sha256':'ea4bf6d0214c0c8720e138723c3324a15bc6c3a0021db3a96e478691e1613077'},
                'data_names':{'control_word':'dw'}},
    'joystick': {'data':17,'text':93,'offset':128,'data_offset':67966,'fixups':5,
                 'publics':{'_Joy_x1':[2,0],'_Joy_y1':[2,4],'_Joy_x2':[2,8],
                            '_Joy_y2':[2,12],'_Joy_mask':[2,16],'JoyStick_Vals_':[3,0]},
                 'member':{'offset':14848,'size':334,'name':'joystick.asm',
                           'sha256':'9761006539692927b7d17bb9c13570895bdf4e1252aae103df55e7fcc1e3d071'},
                 'data_names':{'_Joy_x1':'dd','_Joy_y1':'dd','_Joy_x2':'dd','_Joy_y2':'dd','_Joy_mask':'db'}},
}


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def expected_spec(name):
    c = CONTRACTS[name]
    placements = {'2':[3,c['data_offset']], '3':[2,c['offset']]}
    return {'name':'MACT_'+name.upper(),'source':f'src/mact/{name}.asm',
            'producer':'native-wasm','options':OPTIONS,
            'source_reference_evidence':'evidence/mact-asm-source-reference.json',
            'placements':placements,
            'segments':[['_TEXT','CODE',0,73],['_DATA','DATA',c['data'],73],['TEXT','',c['text'],97]],
            'publics':c['publics'],
            'symbol_anchors':{n:[placements[str(s)][0],placements[str(s)][1]+o]
                              for n,(s,o) in c['publics'].items()},
            'instruction_object':2,'instruction_bytes':c['text'],
            'object1_code_bytes':0,
            'expected':{'initialized_bytes':c['data']+c['text'],'zero_fill_bytes':0,'verified_fixups':c['fixups']}}


def load_spec(name):
    if name not in CONTRACTS:
        raise ValueError('unknown MACT assembly member')
    spec = json.loads((ROOT/'modules'/f'mact_{name}.json').read_text())
    if spec != expected_spec(name):
        raise ValueError('changed measured MACT descriptor contract')
    return spec


def validate_source(name,text):
    """Require mnemonic instructions and meaningful zero-initialized scalars.

    No includes/macros, binary emission, origin changes, aliases or numeric
    instruction arrays may hide output outside the symbolic source body.
    """
    names = CONTRACTS[name]['data_names']
    seen = {}
    mnemonics = {'push','pop','xor','rdtsc','mov','ret','sub','sbb','fclex','fstcw',
                 'and','or','fldcw','pushf','cli','out','inc','cmp','je','in',
                 'test','jz','jnz','sti','popf'}
    for line in text.splitlines():
        line = line.split(';',1)[0].strip()
        if not line: continue
        if line.lower() in {'.586','.387','.model flat','end'}: continue
        words = line.split()
        if words[0].lower() == 'public' and re.fullmatch(r'public\s+[\w, ]+',line,re.I): continue
        if re.fullmatch(r'\w+:',line): continue
        if len(words) >= 2 and words[1].lower() in {'segment','ends','proc','endp'}: continue
        if len(words) >= 2 and words[1].lower() in {'dd','dw','db'}:
            key = words[0]
            if key not in names or words[1:] != [names[key],'0'] or key in seen:
                raise ValueError('opaque or unexpected scalar initializer')
            seen[key] = words[1]
            continue
        if words[0].lower() not in mnemonics:
            raise ValueError('unsupported source emission/directive: '+line)
    if seen != names: raise ValueError('missing meaningful MACT storage')


def assemble_native(home,source,output,timeout=30,*,source_name=None):
    """Fixed native command, private DOS stage, and confirmed output publication."""
    filename = assembly_source_name(source_name)
    executable = home/'BINB/wasm.exe'
    if not executable.is_file() or digest(executable.read_bytes()) != ASSEMBLER_SHA256:
        raise CompilerError('pinned native WASM identity mismatch')
    source_raw = source.read_bytes()
    output = output.resolve()
    output.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='mact-wasm-',dir=output.parent) as directory:
        stage = Path(directory)
        (stage/filename).write_bytes(source_raw)
        batch = ('@echo off\r\nset WATCOM=D:\\\r\nset PATH=D:\\BINB;D:\\BIN\r\n'
                 'D:\\BINB\\wasm.exe '+filename+' -fo=OUT.OBJ > ASSEMBLE.LOG\r\n'
                 'if errorlevel 1 goto failed\r\necho OK>STATUS.TXT\r\ngoto end\r\n'
                 ':failed\r\necho FAILED>STATUS.TXT\r\n:end\r\n')
        run_batch(home,stage,batch,timeout)
        log = (stage/'ASSEMBLE.LOG').read_bytes() if (stage/'ASSEMBLE.LOG').exists() else b''
        error_path = stage/Path(filename).with_suffix('.ERR')
        errors = error_path.read_bytes() if error_path.exists() else b''
        output.with_suffix('.log').write_bytes(log)
        output.with_suffix('.err').write_bytes(errors)
        status = (stage/'STATUS.TXT').read_text().strip() if (stage/'STATUS.TXT').exists() else ''
        obj = stage/'OUT.OBJ'
        if status != 'OK' or errors or not obj.is_file() or not obj.stat().st_size:
            raise CompilerError(f'Native assembly failed (status {status!r}):\n'+(log+errors).decode('cp437',errors='replace'))
        if source.read_bytes() != source_raw or digest(executable.read_bytes()) != ASSEMBLER_SHA256:
            raise ValueError('source/assembler identity changed during assembly')
        Module.parse(obj.read_bytes())
        shutil.copyfile(obj,output)
    return output


def target_image():
    raw = (ROOT/'reference/DUKE3D.EXE').read_bytes()
    if len(raw) != 1179131 or digest(raw) != TARGET_SHA256:
        raise ValueError('target identity mismatch')
    return LEImage.parse(raw)


def check_module(name,module,image,spec=None):
    canonical = load_spec(name)
    if spec is not None and spec != canonical:
        raise ValueError('changed measured descriptor placements/bindings')
    spec = canonical
    geometry = [[s.name,s.class_name,s.size,s.attributes] for s in module.segments]
    if geometry != spec['segments']:
        raise ValueError('changed native segment geometry')
    if ({n:list(v) for n,v in module.publics.items()} != spec['publics'] or
            module.externals or module.local_publics or module.local_externals):
        raise ValueError('changed native public/external geometry')
    proof = verify_module(module,image,spec['placements'],spec['symbol_anchors'])
    assert_contributions(proof,spec['expected'])
    return proof


def original_references(image,raw=None):
    if raw is None: raw = (ROOT/'reference/duke3d-reconstructions/MACT386.LIB').read_bytes()
    archive = read_archive(raw)
    if archive['sha256'] != LIBRARY_SHA256:
        raise ValueError('original archive identity mismatch')
    reports = []
    for name,c in CONTRACTS.items():
        member = select_member(raw,archive,c['member'])
        module = Module.parse(raw[member['offset']:member['end']])
        proof = check_module(name,module,image)
        reports.append({'member':member,'verification':proof,'reference_only':True,
                        'scope':'Original member reference only; zero source-built contribution credit'})
    return reports


def prove(name,home,build):
    spec = load_spec(name)
    image = target_image()
    source = ROOT/spec['source']
    raw = source.read_bytes()
    validate_source(name,raw.decode('ascii'))
    build.mkdir(parents=True,exist_ok=True)
    obj = build/f'{name}.obj'
    assemble_native(home,source,obj)
    if source.read_bytes() != raw: raise ValueError('source identity changed')
    module = Module.parse(obj.read_bytes())
    proof = check_module(name,module,image)
    return {'kind':f'complete native source-built MACT {name.upper()} contributions',
            'target_sha256':TARGET_SHA256,'source':spec['source'],'source_sha256':digest(raw),
            'headers_sha256':{},'assembler_sha256':ASSEMBLER_SHA256,'options':OPTIONS,
            'descriptor':f'modules/mact_{name}.json',
            'descriptor_sha256':digest((ROOT/'modules'/f'mact_{name}.json').read_bytes()),
            'native_object_sha256':digest(obj.read_bytes()),
            'native_log_sha256':digest(obj.with_suffix('.log').read_bytes()),
            'native_error_log_sha256':digest(obj.with_suffix('.err').read_bytes()),
            'placements':spec['placements'],'verification':proof,
            'native_inventory':spec['segments'],'object1_code_bytes':0,
            'instruction_object':2,'instruction_bytes':spec['instruction_bytes'],
            'initialized_scalar_bytes':CONTRACTS[name]['data'],
            'original_reference':{'library_sha256':LIBRARY_SHA256,**CONTRACTS[name]['member'],
                                  'reference_only':True},
            'full_executable_rebuilt':False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    parser.add_argument('--build',type=Path,required=True)
    parser.add_argument('--report',type=Path,default=ROOT/'evidence/mact-asm-progress.json')
    args = parser.parse_args()
    refs = original_references(target_image())
    reports = {name:prove(name,args.home,args.build/name) for name in CONTRACTS}
    for name,report in reports.items():
        (ROOT/'evidence'/f'mact-{name}-module.json').write_text(json.dumps(report,indent=2)+'\n')
    report = {'kind':'three complete source-built MACT assembly contributions',
              'target_sha256':TARGET_SHA256,'original_reference_proofs':refs,
              'modules':reports,'new_complete_contributions':3,'initialized_bytes':245,
              'instruction_object2_bytes':210,'initialized_scalar_bytes':35,
              'verified_fixups':18,'zero_fill_bytes':0,'object1_code_bytes':0,
              'excluded_alignment_bytes':11,'full_executable_rebuilt':False}
    args.report.write_text(json.dumps(report,indent=2)+'\n')
    print('MACT native source proofs: 245 initialized bytes, 18 fixups; no whole-file claim')


if __name__ == '__main__': main()
