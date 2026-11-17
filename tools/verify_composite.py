"""Verify complete emitted objects and their exact combined contribution union.

Objects retain their original segments and relocations. Explicit placements
prove contributions, not historical linker selection/order or executable identity.
"""
from tools.verify_module import ModuleError, verify_module


def _integer(value):
    return type(value) is int


def _location(image, value):
    if not isinstance(value, (tuple, list)) or len(value) != 2 or not all(
            _integer(n) for n in value):
        raise ModuleError('invalid composite object/offset binding')
    obj, offset = value
    if not 1 <= obj <= len(image.objects) or not 0 <= offset <= image._object(obj).size:
        raise ModuleError('composite binding outside target')
    return obj, offset


def _placements(module, image, mapping):
    if not isinstance(mapping, dict):
        raise ModuleError('invalid composite placements')
    result = {}
    for key, value in mapping.items():
        if _integer(key):
            number = key
        elif isinstance(key, str) and key.isascii() and key.isdecimal() and str(int(key)) == key:
            number = int(key)
        else:
            raise ModuleError('invalid composite segment index')
        if number in result:
            raise ModuleError('duplicate normalized composite segment index')
        result[number] = _location(image, value)
    required = {n for n, seg in enumerate(module.segments, 1) if seg.size}
    if not required or result.keys() != required:
        raise ModuleError('composite placements must cover exactly every nonempty segment')
    return result


def _union(image, ranges):
    checked = []
    for value in ranges:
        if not isinstance(value, (tuple, list)) or len(value) != 4:
            raise ModuleError('invalid composite range obligation')
        obj, start, size, kind = value
        _location(image, (obj, start))
        if not _integer(size) or size <= 0 or kind not in ('initialized', 'BSS'):
            raise ModuleError('invalid composite range size/kind')
        if start + size > image._object(obj).size:
            raise ModuleError('composite range outside target')
        checked.append((obj, start, start + size, kind))
    if not checked:
        raise ModuleError('empty composite range obligations')
    result = []
    for obj, start, end, kind in sorted(checked):
        if result and result[-1][0] == obj:
            previous = result[-1]
            if start < previous[2]:
                raise ModuleError('overlapping composite ranges')
            if start == previous[2] and kind == previous[3]:
                result[-1] = (obj, previous[1], end, kind)
                continue
        result.append((obj, start, end, kind))
    return result


def verify_composite(modules, image, placements, symbols, expected_ranges, *, group_frames=None):
    """Prove all emitted segments, unique exports and exact range obligations.

    Inputs are name-keyed parsed OMF modules and placements. Expected ranges
    are (LE object, offset, byte count, 'initialized' or 'BSS'). Local names
    never become another producer's external anchors. No object is modified.
    """
    if not isinstance(modules, dict) or not modules or any(
            not isinstance(name, str) or not name for name in modules):
        raise ModuleError('invalid composite producer set')
    if not isinstance(placements, dict) or placements.keys() != modules.keys():
        raise ModuleError('mismatched composite producer placements')
    frames = {} if group_frames is None else group_frames
    if not isinstance(frames, dict) or not frames.keys() <= modules.keys():
        raise ModuleError('unknown composite group-frame producer')
    if not isinstance(symbols, dict) or any(
            not isinstance(name, str) or not name for name in symbols):
        raise ModuleError('invalid composite external bindings')
    shared = {name: _location(image, value) for name, value in symbols.items()}
    normalized = {}
    emitted = []
    exports = {}
    private_names = set()
    for name, module in modules.items():
        places = normalized[name] = _placements(module, image, placements[name])
        if not module.local_publics <= module.publics.keys():
            raise ModuleError('invalid composite local public scope')
        if any(not _integer(n) or not 1 <= n <= len(module.externals)
               for n in module.local_externals):
            raise ModuleError('invalid composite local external scope')
        private_names.update(module.local_publics)
        local_external_names = {module.externals[n - 1] for n in module.local_externals}
        global_external_names = {n for i, n in enumerate(module.externals, 1)
                                 if i not in module.local_externals}
        if global_external_names & (module.local_publics | local_external_names):
            raise ModuleError('ambiguous composite local/global external scope')
        private_names.update(local_external_names)
        for number, seg in enumerate(module.segments, 1):
            if not seg.size:
                continue
            obj, start = places[number]
            emitted.append((obj, start, seg.size,
                            'BSS' if seg.class_name.upper() == 'BSS' else 'initialized'))
        for public, (segment, offset) in module.publics.items():
            if segment not in places or not _integer(offset) or not (
                    0 <= offset <= module.segments[segment - 1].size):
                raise ModuleError('public outside composite contribution')
            if public in module.local_publics:
                continue
            if public in exports:
                raise ModuleError(f'duplicate composite public export: {public}')
            obj, start = places[segment]
            value = (obj, start + offset)
            if public in shared and shared[public] != value:
                raise ModuleError(f'conflicting composite public binding: {public}')
            exports[public] = value
    if (shared.keys() & private_names) - exports.keys():
        raise ModuleError('private/local symbol cannot be a composite external anchor')
    actual = _union(image, emitted)
    expected = _union(image, expected_ranges)
    if actual != expected:
        raise ModuleError('composite emitted union differs from complete range obligations')
    shared.update(exports)
    proofs = {}
    for name, module in modules.items():
        private_externals = {module.externals[n - 1] for n in module.local_externals}
        if not private_externals <= module.local_publics:
            raise ModuleError('unresolved composite private/local external')
        private = module.local_publics | private_externals
        bindings = {n: value for n, value in shared.items() if n not in private}
        proofs[name] = verify_module(module, image, normalized[name], bindings,
                                     group_frames=frames.get(name))
    return {
        'verified': True,
        'initialized_bytes': sum(p['initialized_bytes'] for p in proofs.values()),
        'zero_fill_bytes': sum(p['zero_fill_bytes'] for p in proofs.values()),
        'verified_fixups': sum(p['verified_fixups'] for p in proofs.values()),
        'components': proofs,
        'publics': shared,
        'local_symbols': {},
        'ranges': [{'object': obj, 'offset': start, 'size': end - start, 'kind': kind}
                   for obj, start, end, kind in actual],
        'unique_public_definitions': True,
        'complete_emitted_union_verified': True,
        'full_executable_rebuilt': False,
    }
