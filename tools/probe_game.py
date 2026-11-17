"""Fresh native GAME intervals; partial source, never a complete contribution."""
import argparse
import copy
import hashlib
import json
import re
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from le import LEImage
from omf32 import Module
from runner import compile_source,compiler_bin
from tools.prove_module import prepare_headers,digest,prove,assert_contributions
from tools.probe_premap import OPTIONS,check_intervals
from tools.match_function import compare_range,is_alignment_padding
from tools.infer_bindings import infer_bindings,infer_data_bindings,BindingError
from tools.verify_module import verify_module,ModuleError,external_anchor_bindings
from tools.preserve import TARGET_SHA256

FUNCTIONS={'timerhandler_': (464, 16),
 'inittimer_': (480, 48),
 'uninittimer_': (528, 48),
 'gametext_': (576, 272),
 'gametextpart_': (848, 320),
 'minitext_': (1168, 144),
 'gamenumber_': (1312, 48),
 'allowtimetocorrecterrorswhenquitting_': (1360, 128),
 'getpackets_': (1488, 4128),
 'faketimerhandler_': (5616, 3968),
 'checksync_': (9584, 352),
 'check_fta_sounds_': (9936, 560),
 'inventory_': (10496, 64),
 'badguy_': (10560, 320),
 'badguypic_': (10880, 336),
 'myos_': (11216, 160),
 'myospal_': (11376, 112),
 'invennum_': (11488,480),
 'weaponnum_': (11968,688),
 'weaponnum999_': (12656,1008),
 'weapon_amounts_': (13664,1920),
 'digitalnumber_': (15584, 240),
 'displayinventory_': (15824,1008),
 'displayfragbar_': (16832,608),
 'coolgaugetext_': (17440, 4096),
 'tics_': (21536, 144),
 'caches_': (21680, 224),
 'coords_': (21904, 464),
 'operatefta_': (22368, 336),
 'FTA_': (22704, 112),
 'showtwoscreens_': (22816, 16),
 'binscreen_': (22832, 64),
 'gameexit_': (22896,224),
 'strget_': (23120, 464),
 'displayrest_': (23584,2192),
 'updatesectorz_': (25776, 352),
 'view_': (26128, 768),
 'drawbackground_': (26896, 944),
 'displayrooms_': (27840,2752),
 'LocateTheLocator_': (30592, 80),
 'EGS_': (30672, 544),
 'animatesprites_': (47744,6880),
 'cheats_': (54624,3664),
 'nonsharedkeys_': (58288,4096),
 'comlinehelp_': (62384,432),
 'printstr_': (63888, 80),
 'Logo_': (63968,1072),
 'ShutDown_': (65120, 48),
 'compilecons_': (65168,112),
 'Startup_': (65280,304),
 'sendscore_': (65584, 48),
 'getnames_': (65632,192),
 'main_': (65824,1488),
 'opendemoread_': (67312,288),
 'opendemowrite_': (67600,336),
 'record_': (67936,272),
 'closedemowrite_': (68208,160),
 'playback_': (68368,1088),
 'moveloop_': (69456,160),
 'fakedomovethingscorrect_': (69616,448),
 'fakedomovethings_': (70064,4032),
 'domovethings_': (74096,1008),
 'doorders_': (75104,640),
 'dobonus_': (75744,5216),
 'cameratext_': (80960, 512),
 'vglass_': (81472,240),
 'lotsofglass_': (81712, 608),
 'spriteglass_': (82320, 208),
 'ceilingglass_': (82528, 304),
 'lotsofcolourglass_': (82832, 608),
 'SetupGameButtons_': (83440, 624),
 'GetTime_': (84064, 16),
 'loadtmb_': (65040,80),
 'CenterCenter_': (84080,16),
 'UpperLeft_': (84096,16),
 'LowerRight_': (84112,16),
 'CenterThrottle_': (84128,16),
 'CenterRudder_': (84144,14)}
OMITTED=[]
# Later helper candidates have no interval at their native neighboring publics.
EXCLUDED_LATER=['gametextpal','minitextshade','writestring','testcd','copyprotect','adduserquote']


def check_code_prefix(module,image):
    """Check all native initializer data and padding before timerhandler.

    Three 80-byte automatic buffer initializers and the bonus animation's
    20/30-long symbolic tables occupy 440 bytes of compiler-marked CODE data.
    Native padding adds eight bytes. Target bytes0..16 are outside this source
    contribution and remain unassigned; they are never copied into source.
    """
    if module.publics.get('timerhandler_')!=(1,448):
        raise ValueError('unexpected GAME leading prefix extent')
    if module.code_data_ranges!=[(1,0,440)]:
        raise ValueError('unexpected GAME recognized CODE data extent')
    if any(seg==1 and offset<448 for seg,offset in module.publics.values()):
        raise ValueError('unexpected public in GAME initializer prefix')
    if not is_alignment_padding(bytes(module.segments[0].data[440:448])):
        raise ValueError('unexpected GAME prefix alignment')
    proof=compare_range(module,1,0,image,1,16,448,{},
                        {1:(1,16)},label='GAME leading native initializer data/alignment')
    if not proof['match'] or proof['verified_fixups']!=0:
        raise ValueError('unmasked GAME leading prefix mismatch')
    proof.update({'source_segment':1,'source_offset':0,'recognized_data_bytes':440,
                  'automatic_buffer_initializer_bytes':240,'bonus_animation_table_bytes':200,
                  'native_alignment_bytes':8,'complete_prefix_verified':True})
    return proof



def check_initialized_data(module,image,bindings):
    """Prove complete GAME _DATA, including identified alignment residue.

    CONST and BSS remain outside this projection. Padding names are inferred
    local source objects, never exported anchors or instruction payloads.
    """
    segment,origin=module.publics['_cameradist']
    data=module.segments[segment-1]
    if origin!=0 or data.name!='_DATA' or data.class_name!='DATA' or data.size!=864:
        raise ValueError('changed GAME initialized DATA extent')
    if tuple(bindings['_cameradist'])!=(3,29560):
        raise ValueError('changed GAME initialized DATA placement')
    layout={'_cameradist':0,'_cameraclock':4,'_eightytwofifty':8,
            '_inferred_serial_alignment':9,'_CommandSoundToggleOff':12,
            '_CommandMusicToggleOff':16,'_confilename':20,'_groupfilename':148,
            '_boardfilename':276,'_debug_on':404,'_actor_tog':405,
            '_memorycheckoveride':406,'_frecfilep':408,'_todd':412,
            '_inferred_copyright_alignment':493,'_TimerPtr':496,'_framecnt':500,
            '_inputloc':504,'_inferred_inputloc_alignment':506,'_oyrepeat':508,
            '_cheatquotes':512,'_which_demo':862,'_in_menu':863}
    actual={n:o for n,(s,o) in module.publics.items() if s==segment}
    if actual!=layout:raise ValueError('changed GAME initialized DATA object layout')
    gap_specs=[('_inferred_serial_alignment',9,3,'_eightytwofifty',1,'_CommandSoundToggleOff'),
               ('_inferred_copyright_alignment',493,3,'_todd',81,'_TimerPtr'),
               ('_inferred_inputloc_alignment',506,2,'_inputloc',2,'_oyrepeat')]
    target_fixups=image.read_fixups()
    gaps=[]
    for name,start,size,left,left_size,right in gap_specs:
        if (name not in module.local_publics or actual[left]+left_size!=start or
                actual[right]!=start+size or (29560+start+size)%4):
            raise ValueError('changed GAME DATA alignment gap: '+name)
        if any(f.target_object==3 and 29560+start<=f.target_offset<29560+start+size
               for f in target_fixups):
            raise ValueError('target reference into GAME DATA alignment gap: '+name)
        for fix in module.fixups:
            source=module.segments[fix.segment-1].data
            addend=int.from_bytes(source[fix.offset:fix.offset+fix.width],'little')+fix.displacement
            offset=None
            if fix.target_method==0 and fix.target==segment:offset=addend
            if fix.target_method==2:
                symbol=module.externals[fix.target-1]
                if symbol in actual:offset=actual[symbol]+addend
            if offset is not None and start<=offset<start+size:
                raise ValueError('source reference into GAME DATA alignment gap: '+name)
        gaps.append({'symbol':name,'source_offset':start,'size':size,
                     'target_object':3,'target_offset':29560+start,
                     'left_object':left,'left_object_size':left_size,'right_object':right,
                     'inferred_name':True,'local':True,'runtime_fixup_references':0,
                     'kind':'identified noninstruction DATA alignment residue'})
    if data.data[492]!=0 or 0 in data.data[412:492]:
        raise ValueError('changed GAME copyright string extent')
    boundary_path=ROOT/'evidence/gamedef-module.json'
    boundary=json.loads(boundary_path.read_text())
    if boundary.get('target_sha256')!=TARGET_SHA256 or boundary['verification'].get('verified') is not True:
        raise ValueError('changed GAME next DATA boundary identity')
    rows=[r for r in boundary['verification']['segments'] if r['symbol']=='_DATA']
    if len(rows)!=1 or (rows[0]['target_object'],rows[0]['target_offset'])!=(3,30424):
        raise ValueError('changed GAME next DATA boundary')
    view=copy.deepcopy(module)
    for number,value in enumerate(view.segments,1):
        if number!=segment:value.size=0;value.data=bytearray()
    view.fixups=[f for f in view.fixups if f.segment==segment]
    view.publics={n:(s,o) for n,(s,o) in view.publics.items() if s==segment}
    proof=verify_module(view,image,{segment:(3,29560)},{})
    assert_contributions(proof,{'initialized_bytes':864,'zero_fill_bytes':0,'verified_fixups':0})
    proof.update({'source_segment':segment,'alignment_residues':gaps,
                  'ordinary_native_zero_alignment':{'source_offset':407,'size':1},
                  'next_complete_data_boundary':{'evidence':'evidence/gamedef-module.json',
                       'evidence_sha256':digest(boundary_path),'target_object':3,'target_offset':30424},
                  'scope':'Complete864-byte GAME _DATA only, including three identified inferred local alignment residues and one ordinary native zero alignment byte. Other initialized CONST storage, BSS and whole GAME remain unverified. No complete module contribution is claimed.'})
    return proof

def wait_abort_consumer_evidence():
    """Pin GAME's byte consumer to PREMAP's complete native storage owner."""
    path=ROOT/'evidence/premap-module.json'
    report=json.loads(path.read_text())
    proof=report['verification']
    if (report.get('target_sha256')!=TARGET_SHA256 or not proof['verified'] or
            proof['initialized_bytes']!=12932 or proof['zero_fill_bytes']!=5 or
            proof['verified_fixups']!=815):
        raise ValueError('unverified PREMAP abort owner evidence')
    if proof['publics'].get('waitforeverybody_')!=[1,250512]:
        raise ValueError('changed PREMAP wait function')
    offsets=[9570,9674,9908]
    for offset in offsets:
        if {'source_offset':offset,'symbol':'_wait_abort','value':[3,587556]} not in report['constraints']:
            raise ValueError('changed PREMAP abort-byte binding')
    storage=report['bss_storage']
    expected_segment={'symbol':'_BSS','target_object':3,'target_offset':587552,
                      'compared_bytes':5,'verified_fixups':0,'differing_offsets':[],'match':True}
    if (not storage['verified'] or storage['initialized_bytes']!=0 or
            storage['zero_fill_bytes']!=5 or storage['verified_fixups']!=0 or
            storage['source_segments']!=[5] or storage['segments']!=[expected_segment] or
            storage.get('source_symbols')!={'_dmval':0,'_wait_abort':4} or
            storage.get('publics')!={'_wait_abort':[3,587556]} or
            storage.get('local_symbols')!={'_dmval':[3,587552]} or
            proof['publics'].get('_wait_abort')!=[3,587556] or
            '_wait_abort' in proof['local_symbols']):
        raise ValueError('changed PREMAP native abort-byte definition or owned BSS')
    return {'symbol':'_wait_abort','target':[3,587556],'read_width':1,
            'historical_name_proved':False,'storage_owned_by_PREMAP':True,
            'storage_owned_by_GAME':False,
            'PREMAP_owned_BSS_range_exclusive':[587552,587557],
            'function':['waitforeverybody_',250512,416],
            'source_constraint_offsets':offsets,
            'evidence':str(path.relative_to(ROOT)),'evidence_sha256':digest(path),
            'scope':'GAME consumes the real public PREMAP abort byte. Ordinary native whole-module inference proves PREMAP BSS5 with private scratch at0 and abort at4; no conditional neighbor placement or GAME allocation is claimed.'}


def independent_anchors(module,build):
    referenced={module.externals[f.target-1] for f in module.fixups if f.target_method==2}
    known={name:(1,target) for name,(target,_) in FUNCTIONS.items()}
    hashes={}
    def retain(name,value):
        if name not in referenced and name not in FUNCTIONS:return
        value=tuple(value)
        if name in known and known[name]!=value:
            raise ValueError('conflicting independent GAME binding: '+name)
        known[name]=value
    for filename,key in [('engine-function-matches.json','module_verification'),
                         ('gamedef-module.json','verification'),
                         ('sounds-module.json','verification'),
                         ('mmulti-module.json','verification'),
                         ('config-module.json','verification'),
                         ('fx_man-module.json','verification'),
                         ('music-module.json','verification'),
                         ('player-module.json','verification'),
                         ('premap-module.json','verification'),
                         ('sector-module.json','verification')]:
        path=ROOT/'evidence'/filename
        report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256:
            raise ValueError('complete GAME anchor target mismatch')
        for name,value in external_anchor_bindings(report[key]).items():retain(name,value)
        hashes[str(path.relative_to(ROOT))]=digest(path)
    # These two real provider exports must constrain ShutDown before interval
    # inference. Its old per-function proof assigned their logical names in
    # reverse, allowing an incorrect C call order to look byte-identical.
    for filename,symbol in [('mact_keyboard-module.json','KB_Shutdown_'),
                            ('mact_control-module.json','CONTROL_Shutdown_')]:
        path=ROOT/'evidence'/filename;raw=path.read_bytes();report=json.loads(raw)
        if report.get('target_sha256')!=TARGET_SHA256:
            raise ValueError('shutdown provider target mismatch: '+filename)
        exports=external_anchor_bindings(report['verification'])
        if symbol not in exports:
            raise ValueError('missing genuine shutdown provider export: '+symbol)
        retain(symbol,exports[symbol])
        hashes[str(path.relative_to(ROOT))]=hashlib.sha256(raw).hexdigest()
    for filename in ['actors-progress.json','premap-progress.json','menues-progress.json']:
        path=ROOT/'evidence'/filename
        report=json.loads(path.read_text())
        if report.get('target_sha256')!=TARGET_SHA256:
            raise ValueError('partial GAME anchor target mismatch')
        for function in report['functions']:
            if function['comparison']['match'] is not True:
                raise ValueError('unverified partial GAME function anchor')
            retain(function['symbol'],(1,function['target_offset']))
        hashes[str(path.relative_to(ROOT))]=digest(path)
    abort=wait_abort_consumer_evidence()
    retain(abort['symbol'],abort['target'])
    hashes[abort['evidence']]=abort['evidence_sha256']
    # Legacy reports predate symbol-scope metadata. Replay their complete
    # descriptors rather than importing local names as cross-module exports.
    replays={}
    for name,version,folder in [('task_man','10.5','task-man-anchor'),
                                ('rts','10.0-ga','rts-anchor')]:
        replay=prove(name,ROOT/('toolchains/watcom-'+version),build/folder)
        for symbol,value in external_anchor_bindings(replay['verification']).items():
            retain(symbol,value)
        replays[name]=replay
    return known,hashes,replays


def check_native_diagnostics(log):
    """Retain only the two exact diagnostics of real discarded-result bodies.

    Their ancestral char declarations remain pending historical type recovery.
    No dummy return, header change or compiler warning suppression is allowed.
    """
    warning=re.compile(r"SOURCE\.C\(\d+\): Warning! W107: Missing return value for function '(moveloop|domovethings)'")
    text=log.read_text();accepted=[]
    for line in text.splitlines():
        if re.search(r'(?:Warning|Error)!|\b[WE]\d{3}\b',line):
            match=warning.fullmatch(line)
            if match is None:raise ValueError('unexpected GAME compiler diagnostic: '+line)
            accepted.append(match.group(1))
    summaries=re.findall(r'^SOURCE\.C: \d+ lines, included \d+, (\d+) warnings, (\d+) errors$',text,re.M)
    if (accepted!=['moveloop','domovethings'] or summaries!=[('2','0')]):
        raise ValueError('unexpected GAME compiler diagnostic inventory')
    return {'accepted_warning_functions':accepted,'warning_count':2,'error_count':0,
            'log_sha256':digest(log),'historical_return_types_proved':False,
            'policy':'Only exact W107 missing-return diagnostics for moveloop/domovethings; every native caller discards the result. Canonical void/type humanization remains unproved.'}


def check_source_identity(source,identity):
    if digest(source)!=identity:raise ValueError('GAME source changed during compilation')


def palette_consumer_evidence():
    """Real public palette roles from complete independent PREMAP/PLAYER sources."""
    reports={};values={};hashes={}
    for filename,source,descriptor,names in [
            ('premap-module.json','src/game/premap.c','modules/premap.json',
             ['_waterpal','_slimepal','_titlepal','_drealms','_endingpal']),
            ('player-module.json','src/game/player.c','modules/player.json',
             ['_waterpal','_slimepal'])]:
        path=ROOT/'evidence'/filename;report=json.loads(path.read_text())
        if (report.get('target_sha256')!=TARGET_SHA256 or
                report.get('source_sha256')!=digest(ROOT/source) or
                report.get('descriptor_sha256')!=digest(ROOT/descriptor)):
            raise ValueError('stale independent GAME palette consumer: '+filename)
        anchors=external_anchor_bindings(report['verification'])
        selected={n:tuple(anchors[n]) for n in names}
        for n,value in selected.items():
            if n in values and values[n]!=value:
                raise ValueError('conflicting independent GAME palette identity: '+n)
            values[n]=value
        reports[filename]={'source':source,'descriptor':descriptor,'public_roles':selected}
        hashes[str(path.relative_to(ROOT))]=digest(path)
    return {'public_roles':values,'independent_consumers':reports,'evidence_sha256':hashes,
            'scope':'Source-public palette consumers; no private anchor or historical spelling claim.'}

def check_compound_storage(module,tail,image,functions):
    from tools.build_game_compound import PREFIX,TAIL_OFFSETS
    bindings={n:tuple(v) for row in functions for n,v in row['bindings'].items()}
    placements={}
    for row in functions:
        for number,value in row['placements'].items():
            number=int(number);value=tuple(value)
            if number==1:continue
            if number in placements and placements[number]!=value:
                raise ValueError('conflicting GAME source non-CODE placement')
            placements[number]=value
    if placements.get(5)!=(3,73568):raise ValueError('changed CODE-derived GAME C-prefix base')
    seg=module.segments[4]
    physical={n:(3,placements[5][1]+off)for n,(number,off)in module.publics.items()if number==5}
    if (seg.size!=4160 or seg.class_name!='BSS' or any(seg.data) or any(f.segment==5 for f in module.fixups)
            or {n:off for n,(number,off)in module.publics.items()if number==5}!=PREFIX
            or {n for n in module.local_publics if module.publics[n][0]==5}!={'_frameval','_dmval'}):
        raise ValueError('changed GAME C-prefix allocation/private scope')
    if any(image.file_offset(3,p)is not None for p in range(73568,77728)):
        raise ValueError('GAME C-prefix target has file backing')
    zero=compare_range(module,5,0,image,3,73568,4160,bindings,placements,
                       label='GAME C BSS prefix zero-fill/range only')
    if not zero['match']:raise ValueError('GAME C-prefix zero-fill differs')
    if set(tail.publics)!=set(TAIL_OFFSETS)or tail.local_publics or tail.local_externals:
        raise ValueError('changed GAME real public tail scope')
    for n in tail.publics:
        if n in module.publics or n not in module.externals or module.externals.index(n)+1 in module.local_externals:
            raise ValueError('GAME tail is not a genuine nonlocal C consumer: '+n)
        if n not in bindings:raise ValueError('missing accepted CODE-derived GAME tail anchor: '+n)
    bound=infer_data_bindings(tail,{n:bindings[n]for n in tail.publics})
    proof=verify_module(tail,image,bound['placements'],bound['symbols'])
    if (proof['initialized_bytes'],proof['zero_fill_bytes'],proof['verified_fixups'])!=(0,15,0):
        raise ValueError('changed GAME public tail complete extent')
    expected={n:(3,77728+off)for n,off in TAIL_OFFSETS.items()}
    if bound['symbols']!=expected or bound['placements']!={3:(3,77728)}:
        raise ValueError('changed six GAME native public role addresses')
    palette=palette_consumer_evidence()
    for n,value in palette['public_roles'].items():
        if physical.get(n)!=value or (n in bindings and bindings[n]!=value):
            raise ValueError('changed source-owned GAME palette role: '+n)
    unproved={'_tempwallptr','_dmval'}
    qualified={n:physical[n]for n in physical if n not in unproved}
    anchored={n:value for n,value in qualified.items()if n not in ('_waterpal','_slimepal')}
    for n,value in anchored.items():
        if bindings.get(n)!=value:raise ValueError('changed independently anchored C-prefix role: '+n)
    return {'C_prefix_zero_fill_range':zero,'C_physical_definitions':physical,
            'C_prefix_CODE_anchored_roles':anchored,'C_prefix_qualified_target_roles':qualified,
            'palette_consumer_evidence':palette,'unproved_prefix_target_role_names':sorted(unproved),
            'all_historical_prefix_name_addresses_verified':False,
            'C_private_scope':{'_frameval':'LPUB+LEXT','_dmval':'LPUB only; no target-role anchor'},
            'tail_whole_verification':proof,'tail_bindings':bound,
            'tail_source_public_definitions':tail.publics,'combined_source_BSS_bytes':4175,
            'actual_source_attachment_order':['game.obj','GMTAIL.OBJ'],
            'whole_GAME_verified':False,'scope':'C prefix4160 is zero-fill/range at a CODE-anchored base. Five actual public palette definitions agree with real GAME/PREMAP/PLAYER consumers; tempwallptr/dmval target names remain unproved. Six real live public tail roles have a complete15-byte BSS proof. No extra gap/object/private promotion or whole GAME credit.'}


def probe(home,build):
    from tools.build_game_compound import build_source,check_freshness,observer_snapshot,unchanged
    produced=build_source(home,build)
    build=Path(produced['native_build_directory'])
    observer_inputs=observer_snapshot()
    observer_inputs[str(ROOT/'reference/DUKE3D.EXE')]=TARGET_SHA256
    binary=(ROOT/'reference/DUKE3D.EXE').read_bytes()
    if hashlib.sha256(binary).hexdigest()!=TARGET_SHA256:
        raise ValueError('reference GAME target identity mismatch')
    image=LEImage.parse(binary)
    source=ROOT/'src/game/game.c';identity=produced['source_sha256']
    headers=build/'include';obj=Path(produced['C_object'])
    diagnostics=check_native_diagnostics(obj.with_suffix('.log'))
    check_source_identity(source,identity)
    module=Module.parse(obj.read_bytes())
    tail=Module.parse(Path(produced['tail_object']).read_bytes())
    known,anchors,replays=independent_anchors(module,build)
    functions=check_intervals(module,image,FUNCTIONS,known)
    prefix=check_code_prefix(module,image)
    bindings={n:tuple(v) for row in functions for n,v in row['bindings'].items()}
    initialized_data=check_initialized_data(module,image,bindings)
    compound_storage=check_compound_storage(module,tail,image,functions)
    try:
        full=infer_bindings(module,image,1,prefix['target_offset'],known_symbols=known)
        verify_module(module,image,full['placements'],full['symbols'])
    except (BindingError,ModuleError) as error:
        full_gate={'verified':False,'error':str(error)}
    else:raise ValueError('whole GAME candidate unexpectedly passes; promote deliberately')
    observer_inputs.update({str(ROOT/path):identity for path,identity in anchors.items()})
    unchanged(observer_inputs)
    check_freshness(produced,home)
    return {'kind':'partial GAME compound C+public-tail intervals/DATA/storage projections, not a complete contribution',
            'source_build':produced,'compound_storage':compound_storage,
            'observer_inputs_sha256':observer_inputs,
            'native_build_directory':str(build),
            'source_only':False,'original_and_target_observed_only_after_source_production':True,
            'target_sha256':TARGET_SHA256,'source':'src/game/game.c','source_sha256':identity,
            'headers_sha256':{p.name:digest(p) for p in sorted(headers.iterdir())},
            'compiler_sha256':digest(home/compiler_bin(home)/'wcc386.exe'),'options':OPTIONS,
            'compiler_diagnostics':diagnostics,
            'anchor_evidence_sha256':anchors,'native_anchor_replays':replays,
            'functions':functions,
            'matched_function_bytes':sum(row['size'] for row in functions),
            'matched_function_fixups':sum(row['comparison']['verified_fixups'] for row in functions),
            'source_code_bytes':sum(seg.size for seg in module.segments if seg.class_name=='CODE'),
            'omitted_code_bodies':OMITTED,
            'excluded_later_code_bodies':EXCLUDED_LATER,
            'wait_abort_consumer':wait_abort_consumer_evidence(),
            'unverified_code_publics':sorted(n for n,(seg,_) in module.publics.items()
                                           if module.segments[seg-1].class_name=='CODE' and n not in FUNCTIONS),
            'source_segment_inventory':[{'segment':i,'name':seg.name,'class':seg.class_name,
                                          'size':seg.size,'verified':i==initialized_data['source_segment']}
                                         for i,seg in enumerate(module.segments,1) if seg.size],
            'full_module_gate':full_gate,'leading_code_prefix':prefix,
            'leading_code_prefix_verified':True,
            'unassigned_preceding_code_range':{'target_object':1,'target_offset':0,'size':16,
                                               'ownership_verified':False},
            'initialized_data_verified':False,'bss_verified':False,
            'owned_data_verified':True,'initialized_data_projection':initialized_data,
            'other_initialized_storage_verified':False,
            'prediction_physics':{
                'gravity_increment':256,'contact_shift':6,
                'source_frame_bytes':72,'native_frame_bytes':72,
                'gravity_target_instruction_offsets':[72141,72146,72151],
                'contact_shift_immediate_target_offsets':[71120,71123],
                'alignment_bytes':15,'typed_fixups':289,
                'GLOBAL_gc_historical_role_proved':False,'BSS_ownership_proved':False,
                'scope':'Whole native C prediction interval, including all typed fixups and compiler alignment. The literal gravity and paired contact shifts restore observed earlier physics. Physical user byte8 and player byte1332 retain existing provisional header spellings. No ASM companion, compiler allocation steering or GLOBAL gc ownership is inferred.'},
            'measured_user_byte8_role':{
                'logical_role':'clipping','temporary_header_spelling':'over_shoulder_on',
                'target_object':3,'target_offset':579676,'user_relative_offset':8,
                'cheat_index':20,'cheat_table_target_offset':54520,
                'cheat_case_target_offset':55501,'body_symbol':'cheats_',
                'byte5_role_verified':False,
                'scope':'Complete native clip-cheat consumer proof; controller owns shared field-name correction. No over-shoulder role is inferred for byte5.'},
            'cheat_buffer_observations':{
                'source_symbol':'_cheatbuf','source_size':10,'source_storage_owner':'src/game/game_tail.asm','target_object':3,
                'target_offset':77728,'length_symbol':'_cheatbuflen',
                'length_target_offset':77739,'restorepalette_target_offset':77741,
                'screencapt_target_offset':77742,
                'nomorelogohack_storage_owned':False,
                'nomorelogohack_active_consumer':False,
                'whole_bss_allocation_verified':False,
                'scope':'The complete cheats interval constrains buffer/length references at common BSS base73568. The later nomorelogohack declaration is unused by the restored main and Logo, with no active consumer or storage claim. Whole BSS remains unverified.'},
            'consumer_reference_roles':{
                '_lockptr':{'target':[3,1665920],'role':'caches consumer reference only',
                            'scope_link_model_verified':False},
                '_cacleng':{'target':[3,1682304],'role':'caches consumer reference only',
                            'scope_link_model_verified':False}},
            'scope':'Only the listed78 complete public intervals, the separate448-byte native initializer/padding prefix and complete864-byte native _DATA projection are verified. Every byte/fixup is checked. Complete ShutDown now binds the genuine independently proved CONTROL then KB provider exports; its earlier reversed per-function callee nomination is invalid history, not preserved proof. Names and non-CODE placements agree; all registered function CODE placements agree at native base16. The preceding target16 bytes are unassigned. All actual body candidates are now emitted, although three principal emitted publics remain unverified: wallswitchcheck, spawn and checkcommandline. Later gametextpal/minitextshade, writestring/testcd/copyprotect and adduserquote are excluded at their proven native neighboring positions and absent from active GAME call inventory, without new byte credit. The earlier quote-helper role is implemented by native direct pointer/timer stores in complete domovethings. CACHE1D lockptr/cacleng consumer bindings do not prove exported visibility; the accepted CACHE1D export repair permits a separately compiled native consumer link, but whole GAME linking remains unverified. Complete gameexit includes its unchanged compiler-resolved ShutDown displacement and every24 typed fixups; the direct E8 has no OMF relocation and does not independently infer the CODE base. Its prior conservative unregistered status is corrected by fresh whole-interval replays on both frozen61 and current source. Historical spelling of the archive buffer and inferred padding names is unproved. Complete animatesprites includes its native trailing 25-entry cheats switch table and alignment. Complete nonsharedkeys includes every input/save/message branch and native alignment; its CONTROL state globals and GAME BSS references constrain consumers, not producer visibility or complete storage allocation. Complete comlinehelp includes every58 generated parser-table entry. Complete compilecons restores canonical label/hittype and mymembuf/sprite bindings plus the confile/archive recompile message. Complete loadtmb preserves the earlier loadfromgrouponly archive-scope argument; all five unchanged joystick calibration prompts and their full tails also match. Complete Startup restores the measured network-player limit without the later abort prompt or ready-flag loop. Complete getnames sends the earlier type6/version103 name broadcast with its synchronization wait. Complete main restores the earlier archive/heap/TEN/UART/video/restart/drawing paths and the existing PREMAP abort-byte consumer without allocating it. Complete demo read/write preserves the earlier ten-record format without version/first-demo/AI/newer-state records; the writer explicitly preserves the raw frecfilep value passed to ENGINE kclose, without historical-type or API-intent claims. Complete record/closedemowrite preserve the earlier count/header behavior. Complete playback/moveloop/fakecorrect retain the native shared epilogue and discarded movement results; only the exact two W107 diagnostics for the retained ancestral char declarations are permitted. Complete domovethings has the earlier inline quote pointer/timer and simulation call order. Complete doorders includes all ten generated bonus-table entries and native alignment. Complete prediction restores literal256 gravity and paired enemy-contact shifts6, including its true15-byte native compiler alignment and every289 typed fixups. Its72-byte stack frame follows those genuine behavior corrections. Complete bonus5216/all402fixups and Logo1072/all88fixups now agree with common source-owned palette placement. The GAME-only header delays the real endingpal first declaration, without source instructions or storage-owner changes. The raw-target-informed spawn candidate and wallswitchcheck remain unverified, including their generated table tails. Restored checkcommandline remains unverified at two compiler-resolved branches into the shared spawn epilogue; Logo has a complete body/typed-field proof under the repaired genuine declaration context. Unverified extents alone receive no credit. Complete cheats proves clipping at user byte8 using the temporary existing header spelling; byte5 remains unproved. The published ten-byte cheat buffer, genuine counter and length byte have distinct public ASM storage owners with accepted CODE anchors. The C-prefix4160 projection proves zero-fill/range at a common base, not the two remaining unproved tempwallptr/compiler-private dmval name addresses. The complete15-byte real public tail and accepted palette/capture consumers agree, while the unused nomorelogohack declaration has no active emitted consumer or storage credit. Other bodies/embedded data, initialized CONST storage/BSS, common full placement, linker/binder, whole executable identity and humanization remain unverified. No complete contribution is claimed.',
            'new_complete_contributions':0,'full_executable_rebuilt':False}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home',type=Path,default=ROOT/'toolchains/watcom-10.0-ga')
    parser.add_argument('--build',type=Path,required=True)
    parser.add_argument('--report',type=Path,required=True)
    parser.add_argument('--source-only',action='store_true',help='build both ordinary source objects without target/SDK-object/caller observation')
    args=parser.parse_args()
    if args.source_only:
        from tools.build_game_compound import build_source
        report=build_source(args.home.resolve(),args.build.resolve())
        args.report.parent.mkdir(parents=True,exist_ok=True)
        args.report.write_text(json.dumps(report,indent=2)+'\n')
        print('GAME COMPOUND SOURCE BUILT; partial/no target observation')
        return
    report=probe(args.home.resolve(),args.build.resolve())
    args.report.parent.mkdir(parents=True,exist_ok=True)
    args.report.write_text(json.dumps(report,indent=2)+'\n')
    print(f"GAME IN PROGRESS: {len(report['functions'])} intervals, "
          f"{report['matched_function_bytes']} bytes, {report['matched_function_fixups']} fixups; "
          f"DATA {report['initialized_data_projection']['initialized_bytes']} bytes; module unverified")


if __name__=='__main__':main()
