"""Check the produced logical GLOBAL DATA/BSS without claiming historical scope.

All native bytes/publics/fixups must agree at one placement per segment.
The adjacent96 initialized bytes remain unassigned, and unreferenced ancestral
roles remain hypotheses. No zero scan, opaque filler or cross-module local
anchor proves ownership.
"""
import argparse
import ast
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module,Cursor
from runner import compile_source,compiler_bin
from tools.prove_module import prepare_headers,digest,assert_contributions
from tools.verify_module import verify_module,external_anchor_bindings,ModuleError
from tools.infer_bindings import infer_data_bindings,BindingError
from tools.probe_premap import check_source_interval
from tools.preserve import TARGET_SHA256

OPTIONS=['/4r','/s','/ort','/dAPPVER_EXEDEF=DN3D13G','/dLIBVER_BUILDREV=19960320']
REFERENCE_REPORTS=['engine-function-matches','gamedef-module','sounds-module','mmulti-module',
                   'config-module','player-module','sector-module','premap-module']
DATA_PUBLICS={'_volume_names':0,'_skill_names':99,'_weapon_tiles':200,
              '_weapon_tiles_alignment':222,'_respawnactortime':224,'_respawnitemtime':228,
              '_weaponsandammosprites':232,'_weapons_ammo_alignment':262,
              '_dukefriction':264,'_freezerhurtowner':268,'_networkmode':269,
              '_movesperpacket':270,'_gamequit':271,'_numfreezebounces':272,
              '_bufferjitter':276,'_numinterpolations':280,'_startofdynamicinterpolations':284}
GAME_REFERENCE_COMMIT='88f6fcd83b4d075575653b8ef2a460c971c19337'
GAME_REFERENCE_BLOBS={'src/game/game.c': '931ea0f59cd49a34fe8e98f0c54d1fd8cf791ed8a1cd264283308479fca0dafc', 'tools/probe_game.py': 'e34b27c4f4709f998cd62d4a2853f3aced94f30122abf6e88e2b88fda9957377', 'evidence/game-progress.json': 'c8d7bf36479936176d00e034b68b23e5dad694d373bccd1695171a31c1ebd6c5'}
ISOLATED_DECLARATIONS={'volume_names':{'shared_type':'char[4][33]','definition_type':'char[3][33]'},
                       'skill_names':{'shared_type':'char[5][33]','definition_type':'char[5][20]'}}


def observed_references(module):
    """Accepted complete proof exports/references, filtered by OMF local scope.

    These identify physical references, not GLOBAL array extents or allocation
    ownership. Legacy reports lacking explicit local scope must not be flattened.
    """
    bindings={};origins={};evidence={}
    for name in REFERENCE_REPORTS:
        path=ROOT/'evidence'/(name+'.json');report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256:
            raise ValueError('independent reference target identity mismatch')
        proof=report.get('verification',report.get('module_verification'))
        exports=external_anchor_bindings(proof)
        metadata={key:report[key] for key in ['source','source_sha256','source_inputs_sha256',
                  'compiler_sha256','options','compiler_options','descriptor','descriptor_sha256',
                  'headers_sha256'] if key in report}
        evidence[str(path.relative_to(ROOT))]={'sha256':digest(path),
            'target_sha256':report['target_sha256'],'recorded_producer_inputs':metadata}
        for symbol,value in exports.items():
            if symbol not in module.publics or symbol in module.local_publics:continue
            value=tuple(value)
            if symbol in bindings and bindings[symbol]!=value:
                raise BindingError('conflicting independent external reference: '+symbol)
            bindings[symbol]=value;origins.setdefault(symbol,[]).append(str(path.relative_to(ROOT)))
    return bindings,evidence,origins


def check_initialized_storage(module,image,references):
    data=[(n,s) for n,s in enumerate(module.segments,1)
          if s.size and s.class_name.upper()=='DATA']
    if len(data)!=1:raise ValueError('expected one complete identified initialized segment')
    segment,storage=data[0]
    if (storage.name!='_DATA' or storage.attributes!=169 or storage.size!=288 or
            {name:offset for name,(seg,offset) in module.publics.items() if seg==segment}!=DATA_PUBLICS or
            not {'_weapon_tiles_alignment','_weapons_ammo_alignment'}<=module.local_publics):
        raise ValueError('changed initialized GLOBAL native inventory')
    view=copy.deepcopy(module)
    for number,value in enumerate(view.segments,1):
        if number!=segment:value.size=0;value.data=bytearray()
    view.publics={name:value for name,value in view.publics.items() if value[0]==segment}
    view.fixups=[f for f in view.fixups if f.segment==segment]
    anchors={name:tuple(value) for name,value in references.items() if name in view.publics}
    bound=infer_data_bindings(view,anchors)
    if bound['placements']!={segment:(3,30916)}:
        raise BindingError('changed independent initialized GLOBAL placement')
    proof=verify_module(view,image,bound['placements'],bound['symbols'])
    assert_contributions(proof,{'initialized_bytes':288,'zero_fill_bytes':0,'verified_fixups':0})
    proof['source_segments']=[segment]
    proof['scope']='Entire produced 288-byte initialized DATA segment only, including every native public and both named noninstruction alignment residues. The adjacent96-byte range and whole GLOBAL DATA/BSS ownership remain unverified.'
    return proof



def check_label_references(image,publics):
    """Record exact raw LE label operands, without claiming their CODE bodies.

    These PUSH string operands identify the volume/skill selection rows. Other
    consumers have different call ABIs; no call ABI is inferred from these rows.
    """
    definitions=[('_volume_names',33,[189759,189783,189807]),
                 ('_skill_names',20,[190123,190147,190168,190189])]
    fixups={(f.source_object,f.source_offset):f for f in image.read_fixups()}
    code=image.object_bytes(1);rows=[]
    for name,stride,offsets in definitions:
        obj,start=publics[name]
        for index,offset in enumerate(offsets):
            fix=fixups.get((1,offset));target=start+stride*index
            if (fix is None or fix.source_type!=7 or fix.width!=4 or fix.alias or
                    (fix.target_object,fix.target_offset)!=(obj,target) or
                    code[offset-1]!=0x68 or int.from_bytes(code[offset:offset+4],'little')!=target):
                raise ValueError('changed raw label-row reference: '+name)
            rows.append({'symbol':name,'row':index,'row_bytes':stride,
                         'source_object':1,'source_fixup_offset':offset,'source_type':7,
                         'target_object':obj,'target_offset':target,'operand_kind':'PUSH imm32',
                         'associated_code_body_verified':False})
    return rows



def native_data_records(raw):
    """Inventory actual OMF data payloads after the strict parser validates it."""
    Module.parse(raw)
    records=[];position=0
    while position<len(raw):
        kind=raw[position];size=int.from_bytes(raw[position+1:position+3],'little')
        if kind in (0xa0,0xa1,0xa2,0xa3):
            cursor=Cursor(raw[position+3:position+2+size])
            records.append({'kind':hex(kind),'source_segment':cursor.index(),
                            'source_offset':cursor.uint(4 if kind&1 else 2)})
        position+=size+3
    return records


def caller_row_references(global_module,caller,image,report,definitions):
    """Recheck complete native rows before importing observed external names.

    Caller locals/local EXTDEFs and every caller-owned public are excluded,
    including when another module happens to use the same logical spelling.
    """
    if report.get('target_sha256')!=TARGET_SHA256:raise ValueError('caller target mismatch')
    bindings={};origins={}
    for row in report['functions']:
        name=row['symbol']
        if (name not in definitions or definitions[name]!=(row['target_offset'],row['size']) or
                row['comparison'].get('match') is not True):
            raise ValueError('unverified caller interval geometry')
        # This is the unchanged native interval gate, not a trusted match flag.
        check_source_interval(caller,image,name,row['target_offset'],row['size'],row['bindings'])
        start=row['source_offset'];stop=start+row['size']
        if caller.publics[name]!=(1,start):raise ValueError('changed caller native public')
        eligible={caller.externals[f.target-1] for f in caller.fixups
                  if f.segment==1 and start<=f.offset<stop and f.target_method==2 and
                  f.target not in caller.local_externals}
        for symbol,value in row['bindings'].items():
            if (symbol not in eligible or symbol not in global_module.publics or
                    symbol in global_module.local_publics or symbol in caller.publics):continue
            value=tuple(value)
            if symbol in bindings and bindings[symbol]!=value:
                raise BindingError('conflicting fresh caller reference: '+symbol)
            bindings[symbol]=value;origins.setdefault(symbol,[]).append(name)
    return bindings,origins


def fresh_caller_references(module,image,home,build):
    from tools.probe_actors import probe as actors_probe,FUNCTIONS as actor_definitions
    from tools.probe_menues import probe as menues_probe,FUNCTIONS as menu_definitions
    bindings={};metadata={};origins={}
    identity_keys=['target_sha256','source','source_sha256','headers_sha256','compiler_sha256','options','functions']
    for name,producer,definitions in [('actors',actors_probe,actor_definitions),
                                      ('menues',menues_probe,menu_definitions)]:
        stage=build/(name+'-references');report=producer(home,stage)
        (build/(name+'-references.json')).write_text(json.dumps(report,indent=2)+'\n')
        obj=stage/(name+'.obj');caller=Module.parse(obj.read_bytes())
        observed,rows=caller_row_references(module,caller,image,report,definitions)
        for symbol,value in observed.items():
            if symbol in bindings and bindings[symbol]!=value:
                raise BindingError('conflicting observed caller binding: '+symbol)
            bindings[symbol]=value
            origins.setdefault(symbol,[]).extend('native:'+name+'/'+row for row in rows[symbol])
        # Hash physical proof+input identities; metadata report backreferences
        # are excluded so a future caller may record GLOBAL progress safely.
        canonical=json.loads(json.dumps({key:report[key] for key in identity_keys}))
        metadata['native:'+name]={'kind':'fresh verified caller-row references, not GLOBAL allocation',
            'canonical_sha256':hashlib.sha256(json.dumps(canonical,sort_keys=True,separators=(',',':')).encode()).hexdigest(),
            'canonical_scope':identity_keys,'native_object_sha256':digest(obj),
            'recorded_producer_inputs':{key:report[key] for key in identity_keys if key!='functions'},
            'verified_function_rows':len(report['functions']),
            'binding_scope':'Only actual external fixups in reverified complete rows; local EXTDEFs, candidate locals and all caller-owned publics excluded.'}
    return bindings,metadata,origins



def reviewed_game_inputs():
    """Read immutable, reviewed GAME inputs without executing its probe code.

    The accepted GAME45 source and canonical header snapshot are pinned. Its
    Git blobs are explicit input dependencies; mutable report backreferences are
    neither refreshed nor imported. No caller CODE is counted again.
    """
    blobs={}
    for path,expected in GAME_REFERENCE_BLOBS.items():
        try:
            raw=subprocess.check_output(['git','show',GAME_REFERENCE_COMMIT+':'+path],cwd=ROOT,stderr=subprocess.PIPE)
        except (subprocess.CalledProcessError,FileNotFoundError) as error:
            raise ValueError('required reviewed GAME Git blob unavailable; no fetch or fallback: '+path) from error
        if hashlib.sha256(raw).hexdigest()!=expected:
            raise ValueError('reviewed GAME blob identity mismatch: '+path)
        blobs[path]=raw
    report=json.loads(blobs['evidence/game-progress.json'])
    definitions=next(ast.literal_eval(node.value) for node in ast.parse(blobs['tools/probe_game.py']).body
        if isinstance(node,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='FUNCTIONS' for t in node.targets))
    if (report['source_sha256']!=GAME_REFERENCE_BLOBS['src/game/game.c'] or
            report['target_sha256']!=TARGET_SHA256 or report['options']!=OPTIONS or
            len(definitions)!=45 or {row['symbol'] for row in report['functions']}!=set(definitions)):
        raise ValueError('changed reviewed GAME core identity/geometry')
    return blobs['src/game/game.c'],report,definitions


def fresh_reviewed_game_references(module,image,home,build):
    source_bytes,report,definitions=reviewed_game_inputs()
    stage=build/'game-references';stage.mkdir(exist_ok=False)
    source=stage/'game.c';source.write_bytes(source_bytes)
    headers=stage/'include'
    prepare_headers([ROOT/'reference/duke3d-reconstructions',ROOT/'reference/duke3d-reconstructions/MACT'],
                    [ROOT/'src/include',ROOT/'src/game/include',ROOT/'src/engine/include'],headers)
    hashes={p.name:digest(p) for p in sorted(headers.iterdir())}
    if hashes!=report['headers_sha256'] or digest(home/compiler_bin(home)/'wcc386.exe')!=report['compiler_sha256']:
        raise ValueError('reviewed GAME header/compiler input identity mismatch')
    obj=stage/'game.obj';compile_source(home,source,obj,OPTIONS,30,include_dirs=[headers])
    if digest(source)!=report['source_sha256']:raise ValueError('reviewed GAME source changed during compile')
    caller=Module.parse(obj.read_bytes())
    bindings,origins=caller_row_references(module,caller,image,report,definitions)
    keys=['target_sha256','source','source_sha256','headers_sha256','compiler_sha256','options','functions']
    core={key:report[key] for key in keys}
    metadata={'kind':'fresh reviewed immutable GAME caller-row references, not GLOBAL allocation',
        'reviewed_commit':GAME_REFERENCE_COMMIT,'reviewed_blob_sha256':GAME_REFERENCE_BLOBS,
        'canonical_sha256':hashlib.sha256(json.dumps(core,sort_keys=True,separators=(',',':')).encode()).hexdigest(),
        'canonical_scope':keys,'native_object_sha256':digest(obj),
        'recorded_producer_inputs':{key:report[key] for key in keys if key!='functions'},
        'verified_function_rows':45,
        'binding_scope':'Only actual external fixups in freshly reverified complete rows; caller local EXTDEFs, candidate locals and every caller-owned public excluded. Immutable source/probe/report blobs are pinned; mutable report backreferences are excluded from canonical identity. Zero caller CODE credit.'}
    (build/'game-references.json').write_text(json.dumps({'metadata':metadata,'functions':report['functions']},indent=2)+'\n')
    return bindings,{'native:game':metadata},{name:['native:game/'+row for row in rows] for name,rows in origins.items()}


def raw_reference(code,fixups,offset,expected=None):
    rows=[f for f in fixups if f.source_object==1 and f.source_offset==offset]
    if len(rows)!=1:raise ValueError('missing/ambiguous raw reference location')
    fix=rows[0]
    if (fix.source_type!=7 or fix.width!=4 or fix.alias or fix.target_object!=3 or
            int.from_bytes(code[offset:offset+4],'little')!=fix.target_offset or
            expected is not None and (fix.target_object,fix.target_offset)!=tuple(expected)):
        raise ValueError('changed raw reference width/object/operand')
    return (fix.target_object,fix.target_offset)


def raw_opcode(code,offset,opcode):
    if code[offset:offset+len(opcode)]!=opcode:raise ValueError('changed raw producer opcode')


def backup_role_operands(code,fixups,references):
    """Fixed target scalar-to-backup stores, not a whole prediction CODE proof."""
    guards=[(0x120e6,b'\xa1'),(0x120eb,b'\x25'),(0x120f0,b'\x8d\x14\x85'),
            (0x120f7,b'\x8b\x1d'),(0x120fd,b'\x89\x9a'),
            (0x12103,b'\x8b\x1d'),(0x12109,b'\x89\x9a'),
            (0x1210f,b'\x8b\x1d'),(0x12115,b'\x89\x9a'),
            (0x1211b,b'\x8d\x1c\x45'),(0x12122,b'\x66\xa1'),
            (0x12128,b'\x66\x89\x83'),(0x1212f,b'\x0f\xbf\x05'),
            (0x12136,b'\x89\x82'),(0x1213c,b'\xff\x05')]
    for offset,opcode in guards:raw_opcode(code,offset,opcode)
    if (int.from_bytes(code[0x120ec:0x120f0],'little')!=255 or
            any(code[0x120f3:0x120f7]) or any(code[0x1211e:0x12122])):
        raise ValueError('changed backup bound or scaled-index displacement')
    raw_reference(code,fixups,0x120e7,references['_fakemovefifoplc'])
    raw_reference(code,fixups,0x1213e,references['_fakemovefifoplc'])
    for offset,name in [(0x120f9,'_myx'),(0x12105,'_myy'),(0x12111,'_myz'),
                        (0x12124,'_myang'),(0x12132,'_myhoriz')]:
        raw_reference(code,fixups,offset,references[name])
    raw_reference(code,fixups,0x12117,references['_myzbak'])
    roles={};rows=[]
    for name,source,offset,width in [('_myxbak','_myx',0x120ff,4),('_myybak','_myy',0x1210b,4),
                                    ('_myangbak','_myang',0x1212b,2),('_myhorizbak','_myhoriz',0x12138,4)]:
        roles[name]=raw_reference(code,fixups,offset)
        rows.append({'symbol':name,'producer_source_global':source,'source_object':1,
                     'source_fixup_offset':offset,'target_object':roles[name][0],
                     'target_offset':roles[name][1],'element_bytes':width,'index_mask':255,
                     'source_elements':256,'minimum_accessed_extent':256*width,
                     'associated_code_body_verified':False})
    return roles,rows


def chat_role_operands(code,fixups,references,callees):
    """Measured earlier one-message overlay stores; no caller CODE credit."""
    guards=[(0xe6b,b'\xba'),(0xe70,b'\xb8'),(0xe75,b'\xbe'),(0xe7a,b'\xe8'),
            (0xe7f,b'\x0f\xbf\xc3'),(0xe82,b'\x66\x89\x35'),(0xe89,b'\x30\xd2'),
            (0xe8b,b'\xbb'),(0xe90,b'\x88\x90'),(0xe96,b'\xb8'),(0xe9b,b'\xb6\x01'),
            (0xe9d,b'\x89\x1d'),(0xea3,b'\xe8'),(0xea8,b'\x88\x35'),(0xeae,b'\x88\x35')]
    for offset,opcode in guards:raw_opcode(code,offset,opcode)
    if int.from_bytes(code[0xe76:0xe7a],'little')!=160 or int.from_bytes(code[0xe97:0xe9b],'little')!=243:
        raise ValueError('changed raw chat literal')
    packet=tuple(references['_packbuf']);raw_reference(code,fixups,0xe6c,(packet[0],packet[1]+1))
    destination=raw_reference(code,fixups,0xe71)
    raw_reference(code,fixups,0xe8c,destination)
    raw_reference(code,fixups,0xe92,(destination[0],destination[1]-1))
    raw_reference(code,fixups,0xeaa,references['_pus']);raw_reference(code,fixups,0xeb0,references['_pub'])
    for offset,name in [(0xe7a,'strcpy_'),(0xea3,'sound_')]:
        call=(1,offset+5+int.from_bytes(code[offset+1:offset+5],'little',signed=True))
        if call!=tuple(callees[name]):raise ValueError('changed raw chat consumer callee')
    roles={'_received_quote_time':raw_reference(code,fixups,0xe85),
           '_received_quote':raw_reference(code,fixups,0xe9f)}
    rows=[{'symbol':'_received_quote_time','source_object':1,'source_fixup_offset':0xe85,
           'target_object':roles['_received_quote_time'][0],'target_offset':roles['_received_quote_time'][1],
           'stored_bytes':2,'literal':160,'associated_code_body_verified':False},
          {'symbol':'_received_quote','source_object':1,'source_fixup_offset':0xe9f,
           'target_object':roles['_received_quote'][0],'target_offset':roles['_received_quote'][1],
           'stored_bytes':4,'stored_string_buffer':list(destination),
           'source_string_buffer':[packet[0],packet[1]+1],
           'associated_code_body_verified':False}]
    return roles,rows


def raw_state_roles(image,references):
    if hashlib.sha256(image.data).hexdigest()!=TARGET_SHA256:raise ValueError('raw role target identity mismatch')
    callees={}
    for name in REFERENCE_REPORTS:
        report=json.loads((ROOT/'evidence'/(name+'.json')).read_text())
        exports=external_anchor_bindings(report.get('verification',report.get('module_verification')))
        for symbol in ['strcpy_','sound_']:
            if symbol in exports:
                value=tuple(exports[symbol])
                if symbol in callees and callees[symbol]!=value:raise BindingError('conflicting raw consumer callee')
                callees[symbol]=value
    code=image.object_bytes(1);fixups=image.read_fixups()
    backups,backup_rows=backup_role_operands(code,fixups,references)
    chat,chat_rows=chat_role_operands(code,fixups,references,callees)
    return {**backups,**chat},{'prediction_backups':backup_rows,'single_message_overlay':chat_rows,
        'consumer_callees':callees,'scope':'Exact target opcode/LE producer and typed-store roles only; full associated CODE bodies and historical storage ownership are not newly proved.'}


def check_produced_storage(module,image,references,records):
    inventory={n:(s.name,s.class_name,s.size,s.attributes) for n,s in enumerate(module.segments,1) if s.size}
    if inventory!={4:('_DATA','DATA',288,169),5:('_BSS','BSS',505130,105)}:
        raise ValueError('changed produced logical DATA/BSS inventory')
    if any(row['source_segment']==5 for row in records):raise ValueError('native BSS has initialized OMF payload')
    if any('declaration_context' in name or 'unused_later_' in name for name in list(module.publics)+module.externals):
        raise ValueError('declaration-control alias/typedef payload emitted')
    if '_dmval' not in module.local_publics:raise ValueError('changed own dmval scope')
    bound=infer_data_bindings(module,references)
    if bound['placements']!={4:(3,30916),5:(3,77808)}:raise BindingError('changed produced storage placement')
    proof=verify_module(module,image,bound['placements'],bound['symbols'])
    assert_contributions(proof,{'initialized_bytes':288,'zero_fill_bytes':505130,'verified_fixups':0})
    proof['scope']='Every produced DATA/BSS byte, public and fixup at one placement per native segment. Historical GLOBAL ownership and unreferenced ancestral role names remain conditional; the adjacent96 initialized bytes remain unassigned. No complete contribution is counted.'
    return bound,proof


def probe(home,build):
    target=ROOT/'reference/DUKE3D.EXE'
    if digest(target)!=TARGET_SHA256:raise ValueError('reference identity mismatch')
    image=LEImage.parse(target.read_bytes())
    source=ROOT/'src/game/global.c';identity=digest(source)
    build.mkdir(parents=True,exist_ok=False);headers=build/'include'
    prepare_headers([ROOT/'reference/duke3d-reconstructions',ROOT/'reference/duke3d-reconstructions/MACT'],
                    [ROOT/'src/include',ROOT/'src/game/include',ROOT/'src/engine/include'],headers)
    header_text=(headers/'duke3d.h').read_text()
    for name,dimensions in [('volume_names','[4][33]'),('skill_names','[5][33]')]:
        if 'extern char '+name+dimensions+';' not in header_text:
            raise ValueError('changed isolated shared array declaration: '+name)
    obj=build/'global.obj';compile_source(home,source,obj,OPTIONS,30,include_dirs=[headers])
    if digest(source)!=identity:raise ValueError('source changed during native compilation')
    raw=obj.read_bytes();module=Module.parse(raw)
    if any(s.size and s.class_name.upper()=='CODE' for s in module.segments):
        raise ValueError('GLOBAL state candidate unexpectedly emits CODE')
    for name in ISOLATED_DECLARATIONS:
        alias='unused_later_'+name+'_declaration'
        if any(alias in symbol for symbol in list(module.publics)+module.externals):
            raise ValueError('isolated later declaration emits a public/external payload')
    references,evidence,origins=observed_references(module)
    caller_bindings,caller_evidence,caller_origins=fresh_caller_references(module,image,home,build)
    for name,value in caller_bindings.items():
        if name in references and references[name]!=value:raise BindingError('conflicting caller/global reference: '+name)
        references[name]=value;origins.setdefault(name,[]).extend(caller_origins[name])
    evidence.update(caller_evidence)
    game_bindings,game_evidence,game_origins=fresh_reviewed_game_references(module,image,home,build)
    for name,value in game_bindings.items():
        if name in references and references[name]!=value:raise BindingError('conflicting reviewed GAME reference: '+name)
        references[name]=value;origins.setdefault(name,[]).extend(game_origins[name])
    evidence.update(game_evidence)
    raw_bindings,raw_roles=raw_state_roles(image,references)
    for name,value in raw_bindings.items():
        if name in references and references[name]!=value:raise BindingError('conflicting raw/native role: '+name)
        references[name]=value;origins.setdefault(name,[]).append('raw:target producer operands')
    initialized=check_initialized_storage(module,image,references)
    labels=check_label_references(image,initialized['publics'])
    records=native_data_records(raw)
    produced,verification=check_produced_storage(module,image,references,records)
    rows=[]
    for name,value in sorted(references.items()):
        segment,offset=module.publics[name]
        rows.append({'symbol':name,'source_segment':segment,'source_offset':offset,
                     'observed_external_binding':list(value),
                     'implied_placement':[value[0],value[1]-offset],
                     'reference_evidence':origins[name],'allocation_verified':False})
    full_gate={'verified':False,'error':'Historical GLOBAL ownership remains open: adjacent96 initialized bytes are unassigned.'}
    return {'kind':'native logical GLOBAL DATA/BSS projection; historical allocation remains open',
            'target_sha256':TARGET_SHA256,'source':'src/game/global.c','source_sha256':identity,
            'headers_sha256':{p.name:digest(p) for p in sorted(headers.iterdir())},
            'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe'),'options':OPTIONS,
            'declaration_isolation':ISOLATED_DECLARATIONS,
            'source_declaration_isolation':{name:{
                'alias':alias,'canonical_header_declaration_lines':[line.strip() for line in header_text.splitlines()
                    if re.search(r'\b'+re.escape(name)+r'\b',line) and 'extern' in line]}
                for name,alias in re.findall(r'^#define (\w+) (unused_later_\w+_declaration)$',source.read_text(),re.M)},
            'native_object_sha256':hashlib.sha256(raw).hexdigest(),
            'isolated_alias_payload_verified_absent':True,
            'reference_evidence':evidence,'observed_external_bindings':references,
            'binding_scope':'Scope-filtered accepted complete exports/references, freshly reverified ACTORS/MENUES/reviewed GAME caller externals, and fixed raw semantic producer operands. These identify addresses and scoped roles, not historical allocation ownership. Candidate/caller locals and caller-owned publics are excluded.',
            'binding_diagnostics':rows,'source_code_bytes':0,'raw_label_references':labels,
            'raw_state_roles':raw_roles,'produced_storage_verification':verification,
            'produced_storage_placements':produced['placements'],'produced_storage_constraints':produced['constraints'],
            'native_data_records':records,'matched_bss_bytes':505130,'historical_allocation_verified':False,
            'source_only_order_control':{'unused_typedefs_per_definition':32,'runtime_allocations_added':0,
                'scope':'Fixed meaningful names/types with unused declaration-buffer separation; no BSS initializer records or emitted alias/typedef symbols.'},
            'unreferenced_source_publics':sorted(set(module.publics)-set(references)),
            'unreferenced_source_roles_verified':False,
            'native_inventory':[{'source_segment':n,'name':s.name,'class':s.class_name,
                                 'size':s.size,'attributes':s.attributes} for n,s in enumerate(module.segments,1)],
            'initialized_storage':initialized,'matched_initialized_data_bytes':288,
            'initialized_data_verified':False,'bss_verified':True,
            'unverified_storage':[{'source_segment':n,'name':s.name,'class':s.class_name,
                                   'size':s.size,'verified':False} for n,s in enumerate(module.segments,1)
                                  if s.size and n not in produced['placements']],
            'unidentified_adjacent_initialized_range':{'target_object':3,'start':30820,'end':30916,
                                                       'bytes':96,'allocation_verified':False},
            'full_module_gate':full_gate,
            'scope':'All produced native DATA288/BSS505130 bytes/publics/fixups verify together at DATA30916/BSS77808. Complete caller exports and freshly reverified scope-safe ACTORS/MENUES/reviewed GAME rows agree; fixed raw backup/chat producer operands provide explicitly scoped data roles with no extra CODE credit. Unused typedefs control only frontend order and add no runtime memory or object payload. Historical GLOBAL allocation ownership is still open: adjacent96 initialized bytes are unassigned, and unreferenced ancestral role names remain hypotheses. No opaque filler, BSS initialized payload, zero scan or complete contribution claim.',
            'new_complete_contributions':0,'full_executable_rebuilt':False}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    parser.add_argument('--build',type=Path,required=True)
    parser.add_argument('--report',type=Path,required=True)
    args=parser.parse_args();report=probe(args.home.resolve(),args.build.resolve())
    args.report.write_text(json.dumps(report,indent=2)+'\n')
    print('GLOBAL IN PROGRESS:288 DATA/505130 native BSS bytes verify; historical ownership remains open')


if __name__=='__main__':main()
