"""Verify every segment of a compiled module at explicit target placements.

This proves module contributions and zero-fill obligations, not the full
executable or original linker selection/order. No reference bytes are copied.
"""
from tools.match_function import compare_range,MatchError,validate_group_frames


class ModuleError(ValueError):
    pass


def verify_module(module,image,placements,symbols,*,group_frames=None,logical_origins=None):
    # Optional origin evidence changes only the alignment coordinate. Keep the
    # default proof and all byte/fixup/storage checks exactly as before.
    origins,origin_receipts={},[]
    if logical_origins is not None and not (
            type(logical_origins) in (tuple,list) and not logical_origins):
        from tools.logical_segment_origins import bind_logical_origins
        try:
            origins,origin_receipts=bind_logical_origins(module,image,placements,logical_origins)
        except ValueError as error:
            raise ModuleError(str(error)) from error
    placements={int(k):tuple(v) for k,v in placements.items()}
    symbols={k:tuple(v) for k,v in symbols.items()}
    try:
        frames=validate_group_frames(module,image,placements,group_frames)
    except MatchError as error:
        raise ModuleError(str(error)) from error
    ranges=[]
    for number,seg in enumerate(module.segments,1):
        if not seg.size:
            continue
        if number not in placements:
            raise ModuleError(f'unplaced segment {number}: {seg.name}')
        obj,start=placements[number]
        target=image._object(obj)
        alignment={1:1,2:2,3:16,4:256,5:4}.get(seg.attributes>>5)
        if alignment is None:
            raise ModuleError('unsupported SEGDEF alignment')
        coordinate=start-origins[number] if number in origins else target.base+start
        if coordinate%alignment:
            raise ModuleError(f'segment {seg.name} violates SEGDEF alignment')
        if start<0 or start+seg.size>target.size:
            raise ModuleError('segment placement outside target')
        if any(o==obj and start<end and start+seg.size>begin for o,begin,end in ranges):
            raise ModuleError('overlapping segment placements')
        ranges.append((obj,start,start+seg.size))
    for name,(segment,offset) in module.publics.items():
        seg=module._segment(segment)
        if not seg.size:
            continue
        obj,start=placements[segment]
        value=(obj,start+offset)
        if name in symbols and symbols[name]!=value:
            raise ModuleError(f'conflicting binding for public {name}')
        symbols[name]=value
    reports=[]; initialized=zero_fill=fixups=0
    for number,seg in enumerate(module.segments,1):
        if not seg.size:
            continue
        obj,start=placements[number]
        if seg.class_name.upper()=='BSS':
            if any(seg.data) or any(f.segment==number for f in module.fixups):
                raise ModuleError('BSS contains initialized content or fixups')
            if any(image.file_offset(obj,start+i) is not None for i in range(seg.size)):
                raise ModuleError('BSS target range has file backing')
        try:
            report=compare_range(module,number,0,image,obj,start,seg.size,
                                 symbols,placements,label=seg.name,group_frames=frames)
        except MatchError as error:
            raise ModuleError(f'{seg.name}: {error}') from error
        if not report['match']:
            raise ModuleError(f'{seg.name}: differing bytes at {report["differing_offsets"][:20]}')
        if seg.class_name.upper()=='BSS':zero_fill+=seg.size
        else:initialized+=seg.size
        fixups+=report['verified_fixups']
        reports.append(report)
    local_names=module.local_publics | {module.externals[n-1] for n in module.local_externals}
    local_symbols={n:symbols[n] for n in sorted(local_names) if n in symbols}
    result={'verified':True,'initialized_bytes':initialized,'zero_fill_bytes':zero_fill,
            'verified_fixups':fixups,'segments':reports,'publics':symbols,
            'local_symbols':local_symbols,
            'full_executable_rebuilt':False}
    if frames:
        result['group_frames']=frames
    if origin_receipts:
        result['logical_segment_origins']=origin_receipts
    return result


def external_anchor_bindings(proof):
    """Verified reference/export names only; exclude module-local spellings.

    Local symbols remain in the complete contribution proof. A static name
    such as ENGINE's tempbuf cannot constrain a game's unrelated external.
    Older reports must be replayed to acquire explicit scope metadata.
    """
    if proof.get('verified') is not True:
        raise ValueError('unverified cross-module anchor report')
    symbols=proof['publics']
    local=proof.get('local_symbols')
    if not isinstance(local,dict) or any(n not in symbols or tuple(v)!=tuple(symbols[n])
                                         for n,v in local.items()):
        raise ValueError('missing/inconsistent symbol scope metadata')
    return {n:v for n,v in symbols.items() if n not in local}
