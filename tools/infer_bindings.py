"""Infer consistent placements from target fixups and direct call operands.

These are constraints to be checked by verify_module, not independent proof
of historical symbol spellings or complete original binary ownership.
"""


class BindingError(ValueError):
    pass


def infer_data_bindings(module,known_symbols):
    """Place relocation-free data from explicit, independent public anchors."""
    if not known_symbols or module.fixups:
        raise BindingError('data-only proof requires anchors and no relocations')
    if any(s.size and s.class_name.upper() not in ('DATA','BSS') for s in module.segments):
        raise BindingError('data-only proof contains a non-data segment')
    placements={};symbols={};constraints=[]
    for name,(obj,target) in known_symbols.items():
        if name not in module.publics:
            raise BindingError('data anchor is not a source public')
        segment,offset=module.publics[name]
        if target<offset or obj<1:
            raise BindingError('invalid data anchor placement')
        placement=(obj,target-offset)
        if segment in placements and placements[segment]!=placement:
            raise BindingError('conflicting data anchor placements')
        placements[segment]=placement;symbols[name]=(obj,target)
        constraints.append({'kind':'independent data public anchor','symbol':name,
                            'source_segment':segment,'source_offset':offset,
                            'target_object':obj,'target_offset':target})
    if any(s.size and n not in placements for n,s in enumerate(module.segments,1)):
        raise BindingError('unanchored nonempty data segment')
    return {'placements':placements,'symbols':symbols,'constraints':constraints}


def infer_bindings(module,image,code_object,code_base,*,known_symbols=None):
    code_segments=[n for n,s in enumerate(module.segments,1) if s.size and s.class_name.upper()=='CODE']
    if len(code_segments)!=1:
        raise BindingError('expected exactly one nonempty CODE segment')
    code=code_segments[0]
    placements={code:(code_object,code_base)}
    symbols={k:tuple(v) for k,v in (known_symbols or {}).items()}
    target=image.object_bytes(code_object)
    source=module.segments[code-1].data
    if code_base<0 or code_base+len(source)>len(target):
        raise BindingError('CODE segment placement outside target')
    le_fixups={}
    for f in image.read_fixups():
        if f.source_type==8 and f.width!=4:
            raise BindingError('unsupported relative loader width')
        key=(f.source_object,f.source_offset)
        value=(f.source_type,f.target_object,f.target_offset,f.alias)
        if key in le_fixups and le_fixups[key]!=value:
            raise BindingError('conflicting target fixups')
        le_fixups[key]=value

    def put(table,key,value):
        if key in table and table[key]!=value:
            raise BindingError(f'conflicting placement/binding for {key}: {table[key]} != {value}')
        table[key]=value

    for name,(seg,off) in module.publics.items():
        if seg==code:
            put(symbols,name,(code_object,code_base+off))
    constraints=[]
    occupied=set()
    for fix in module.fixups:
        if fix.segment!=code:
            continue
        if fix.width!=4 or fix.location!=9:
            raise BindingError('unsupported fixup width/location')
        locations=set(range(fix.offset,fix.offset+fix.width))
        if occupied & locations:
            raise BindingError('overlapping object fixups')
        occupied.update(locations)
        pos=code_base+fix.offset
        addend=int.from_bytes(source[fix.offset:fix.offset+4],'little')+fix.displacement
        loader=le_fixups.get((code_object,pos))
        if fix.relative:
            if loader is not None:
                flat_frame=(fix.frame_method==1 and fix.frame is not None and
                            1<=fix.frame<=len(module.groups) and
                            module.groups[fix.frame-1][0]=='FLAT')
                if (loader[0]!=8 or loader[3] or loader[1]==code_object or
                    fix.target_method!=2 or fix.displacement!=0 or
                    not (flat_frame or fix.frame_method==5)):
                    raise BindingError('unsupported relative loader fixup')
                # Original WLINK retains the input addend in this field;
                # the LE loader replaces it with the final cross-object rel32.
                if int.from_bytes(target[pos:pos+4],'little')!=addend:
                    raise BindingError('stored relative loader addend differs from source')
                _,obj,effective,_=loader
            else:
                obj=code_object
                effective=pos+4+int.from_bytes(target[pos:pos+4],'little',signed=True)
        else:
            if loader is None or loader[0]!=7 or loader[3]:
                raise BindingError(f'missing/unsupported loader fixup at {pos:#x}')
            _,obj,effective,_=loader
            if int.from_bytes(target[pos:pos+4],'little')!=effective:
                raise BindingError('loader target disagrees with stored absolute operand')
        value=(obj,(effective-addend)&0xffffffff)
        if value[1]>image._object(obj).size:
            raise BindingError('inferred target outside object')
        if fix.target_method==2:
            name=module.externals[fix.target-1]
            put(symbols,name,value)
            if name in module.publics:
                seg,off=module.publics[name]
                put(placements,seg,(obj,value[1]-off))
            constraints.append({'source_offset':fix.offset,'symbol':name,'value':value})
        elif fix.target_method==0:
            put(placements,fix.target,value)
            constraints.append({'source_offset':fix.offset,'segment':fix.target,'value':value})
        else:
            raise BindingError('unsupported target method')
    for name,(seg,off) in module.publics.items():
        if seg in placements:
            obj,start=placements[seg]
            put(symbols,name,(obj,start+off))
    return {'placements':placements,'symbols':symbols,'constraints':constraints,
            'unplaced_segments':[n for n,s in enumerate(module.segments,1)
                                 if s.size and n not in placements]}
