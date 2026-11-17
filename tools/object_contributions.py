"""Separate documented Watcom debugger metadata from loadable contributions.

The complete object remains parsed and preserved. Only an explicit producer
descriptor may request this view; verify_module itself still checks every
nonempty segment it receives, with no masks or inferred exclusions.
"""
import copy
import hashlib


def without_watcom_debug(module):
    """Return a checked loadable view plus an inventory of excluded metadata."""
    debug=set()
    for number,seg in enumerate(module.segments,1):
        if seg.name not in ('$$SYMBOLS','$$TYPES') and seg.class_name not in ('DEBSYM','DEBTYP'):
            continue
        if ((seg.name,seg.class_name) not in {('$$SYMBOLS','DEBSYM'),('$$TYPES','DEBTYP')}
                or seg.attributes!=0x20 or seg.access!=2
                or (0xaa,b'OS220') not in module.comments
                or (0xfe,b'D\x01\x03C') not in module.comments):
            raise ValueError('unsupported Watcom debug segment identity')
        debug.add(number)
    if not debug:
        raise ValueError('expected Watcom debug segments')
    if any(segment in debug for segment,_ in module.publics.values()):
        raise ValueError('public symbol in debug metadata')
    if any(debug.intersection(members) for _,members in module.groups):
        raise ValueError('loadable group includes debug metadata')
    if debug.intersection(module.far_call_optimization_segments):
        raise ValueError('call optimization directive references debug metadata')
    if any(segment in debug for segment,_,_ in module.code_data_ranges):
        raise ValueError('code/data directive references debug metadata')
    for fix in module.fixups:
        if fix.segment in debug:
            continue
        if (fix.target_method==0 and fix.target in debug or
                fix.frame_method==0 and fix.frame in debug):
            raise ValueError('runtime fixup references debug metadata')
    view=copy.deepcopy(module)
    excluded=[]
    for number in sorted(debug):
        seg=module.segments[number-1]
        excluded.append({'segment':number,'name':seg.name,'class':seg.class_name,
                         'bytes':seg.size,'segdef_access':seg.access,
                         'fixups':sum(f.segment==number for f in module.fixups),
                         'sha256':hashlib.sha256(seg.data).hexdigest(),
                         'scope':'non-loadable Watcom debugger metadata; excluded from source coverage'})
        # Preserve segment numbering so runtime targets and publics are intact.
        view.segments[number-1].size=0
        view.segments[number-1].data=bytearray()
    view.fixups=[f for f in view.fixups if f.segment not in debug]
    return view,excluded
