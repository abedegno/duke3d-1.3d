"""Hand-authored native Easy/thread OMF fixtures, never High C SDK output."""
from copy import deepcopy
from dataclasses import asdict,replace
from pathlib import Path
import struct
import sys
import unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT/'profiles/watcom/tools'),str(ROOT)]
from omf32 import Module,OMFError
from le import LEImage
from tools.verify_module import verify_module,ModuleError
from tools.infer_bindings import infer_bindings,infer_data_bindings,BindingError
from easy_omf_fixtures import rec,name,u32,records,object_bytes,linked_image


class EasyOMFTests(unittest.TestCase):
    def test_full_native_easy_and_standard_variants_resolve_identically(self):
        # Catch short Easy offsets, wrong LOC5 semantics, discarded threads,
        # redefinition mutating old uses, or a verifier relocation waiver.
        image=LEImage.parse(linked_image())
        for easy,threads in ((True,True),(True,False),(False,True),(False,False)):
            with self.subTest(easy=easy,threads=threads):
                module=Module.parse(object_bytes(easy,threads))
                self.assertEqual([s.size for s in module.segments],[0x10020,0x10020])
                self.assertEqual(module.publics,{'own_code_high':(1,0x10000),'own_data_high':(2,0x10010)})
                expected=[
                    (1,0x10000,4,9,False,1,1,0,2,0),
                    (1,0x10004,4,9,False,1,1,0,2,0x10001),
                    (1,0x10008,4,9,False,1,1,2,1,0)]
                self.assertEqual([tuple(asdict(f).values()) for f in module.fixups],expected)
                proof=verify_module(module,image,{1:(1,0),2:(2,0)},
                                    {'own_external':(2,0x10010)},group_frames={1:(2,0)})
                self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),(131136,3))
                self.assertFalse(proof['full_executable_rebuilt'])
                if easy:
                    self.assertEqual(module.format,'easy-omf386')
                    self.assertEqual(module.format_source['flags'],0x80)
                    self.assertEqual(module.format_source['payload'],b'80386')
                    self.assertEqual([s.attributes for s in module.segments],[0xa8,0xa8])
                    self.assertEqual([s.access for s in module.segments],[None,None])
                    self.assertEqual([e['raw_location'] for e in module.fixup_encodings],[5,5,5])
                if threads:
                    self.assertEqual(len(module.thread_definitions),3)
                    self.assertEqual([e['target_definition'] for e in module.fixup_encodings],[1,1,2])
                    self.assertEqual(module.thread_definitions[2]['replaces'],1)

    def test_easy_preserves_complete_original_record_metadata(self):
        # Catch lost PUBDEF group/type/comment flags/record forms during normalization.
        raw=object_bytes()
        module=Module.parse(raw)
        self.assertEqual(b''.join(r[2] for r in module.source_records),raw)
        self.assertEqual([r[0] for r in module.source_records],list(range(len(module.source_records))))

    @staticmethod
    def small(extra=(),easy=True,with_data=True):
        rs=records(easy,False)
        # Independent definition prefix, then a small data association.
        prefix=rs[:next(i for i,r in enumerate(rs) if r[0] in (0xa0,0xa1))]
        if with_data:prefix.append((0xa0 if easy else 0xa1,b'\x01'+u32(0)+bytes(16)))
        return b''.join(rec(*r) for r in prefix+list(extra)+[(0x8a,b'\0')])

    def test_marker_order_flags_payload_and_empty_header_cannot_switch_late(self):
        marker=rec(0x88,b'\x80\xaa80386');h=rec(0x80,b'\0');end=rec(0x8a,b'\0')
        for raw,error in ((marker+h+end,'order'),
                          (h+rec(0x88,b'\x80\0translator')+marker+end,'order'),
                          (h+marker+marker+end,'order'),
                          (h+h+marker+end,'order'),
                          (h+marker+h+end,'headers'),
                          (rec(0x88,b'\x80\0translator')+h+marker+end,'order')):
            with self.subTest(raw=raw),self.assertRaisesRegex(OMFError,error):Module.parse(raw)
        for flags in (0,0x40,0xc0):
            with self.subTest(flags=flags),self.assertRaisesRegex(OMFError,'unsupported.*flags'):
                Module.parse(h+rec(0x88,bytes([flags,0xaa])+b'80386')+end)
        for payload in (b'',b'8038',b'80386\0',b'80386X',b'80387'):
            with self.subTest(payload=payload),self.assertRaisesRegex(OMFError,'unsupported'):
                Module.parse(h+rec(0x88,b'\x80\xaa'+payload)+end)

    def test_easy_rejects_unmeasured_records_comments_attributes_access_locations(self):
        for kind in (0x99,0x91,0xa1,0x9d,0x8b,0xa2,0xa3,0x94,0x95,0xb4,0xb6,0xc0):
            with self.subTest(kind=kind),self.assertRaisesRegex(OMFError,'unsupported Easy OMF record'):
                Module.parse(self.small([(kind,b'')]))
        for payload in (b'\x80\xaaOS220',b'\x80\x9fmath387r',b'\x80\xfeT1234',b'\x80\xa2\1',b'\x80\x9e'):
            with self.subTest(payload=payload),self.assertRaisesRegex(OMFError,'unsupported Easy OMF comment'):
                Module.parse(self.small([(0x88,payload)]))
        for attr in (0x20,0xa9,0xaa,0x68):
            with self.subTest(attr=attr),self.assertRaisesRegex(OMFError,'SEGDEF'):
                Module.parse(self.small([(0x98,bytes([attr])+u32(32)+b'\x02\x03\x01')]))
        for suffix in (b'\0',b'\2',b'\2\0'):
            with self.subTest(suffix=suffix),self.assertRaisesRegex(OMFError,'access'):
                Module.parse(self.small([(0x98,b'\xa8'+u32(32)+b'\x02\x03\x01'+suffix)]))
        for loc in (0,1,2,3,4,6,9,11,13,15):
            with self.subTest(loc=loc),self.assertRaisesRegex(OMFError,'location'):
                Module.parse(self.small([(0x9c,bytes([0xc0|(loc<<2),0,0x54,2]))]))

    def test_standard_loc5_is_two_bytes_and_helpers_reject_it(self):
        module=Module.parse(self.small([(0x9d,b'\xd4\0\x54\2')],easy=False))
        self.assertEqual((module.fixups[0].location,module.fixups[0].width),(5,2))
        with self.assertRaisesRegex(ModuleError,'width/location'):
            verify_module(module,LEImage.parse(linked_image()),{1:(1,0),2:(2,0)},{})

    def test_all_thread_slots_namespaces_methods_and_redefinition_are_independent(self):
        # Two separate namespaces, mixed inline/thread references, P0 then P1.
        defs=b''.join(bytes([0x40|(1<<2)|slot,1,slot,2]) for slot in range(4))
        refs=b''.join(bytes([0xd4,slot*4,0x80|(slot<<4)|8|4|slot]) for slot in range(4))
        module=Module.parse(self.small([(0x9c,defs),(0x9c,refs)]))
        self.assertEqual([(f.frame_method,f.frame,f.target_method,f.target) for f in module.fixups],[(1,1,0,2)]*4)
        self.assertEqual([e['frame_definition'] for e in module.fixup_encodings],[0,2,4,6])
        self.assertEqual([e['target_definition'] for e in module.fixup_encodings],[1,3,5,7])
        for fm,datum in ((0,2),(1,1),(2,1),(4,None),(5,None)):
            for tm,targ in ((0,2),(1,1),(2,1)):
                with self.subTest(fm=fm,tm=tm):
                    definition=bytes([0x40|(fm<<2)])+(bytes([datum]) if datum else b'')+bytes([tm<<2,targ])
                    m=Module.parse(self.small([(0x9c,definition+b'\xd4\0\x88'+u32(0x10001)),(0x9c,b'\xd4\4\x8c')]))
                    self.assertEqual([(f.frame_method,f.frame,f.target_method,f.target,f.displacement) for f in m.fixups],[(fm,datum,tm,targ,0x10001),(fm,datum,tm,targ,0)])
        # Legal aliases preserve raw method/frame bits, consuming target datum.
        m=Module.parse(self.small([(0x9c,b'\x44\1\x10\2\xd4\0\xcc')]))
        self.assertEqual((m.fixups[0].frame,m.fixups[0].target),(1,2))
        self.assertEqual(m.thread_definitions[1]['encoded_method'],4)
        self.assertEqual(m.fixup_encodings[0]['raw_frame_field'],4)
        for fix in (b'\xd4\0\x9c',b'\xd4\0\x8d',b'\xd4\0\x8c'):
            with self.subTest(fix=fix),self.assertRaisesRegex(OMFError,'undefined'):
                Module.parse(self.small([(0x9c,fix)]))

    def test_thread_state_survives_records_dosseg_and_pass_boundary_but_not_modules(self):
        # Definitions before data are legal; DOSSEG breaks data, not definitions.
        rs=records(False,False);prefix=rs[:next(i for i,r in enumerate(rs) if r[0]==0xa1)]
        defs=(0x9d,b'\x44\1\0\2')
        data=(0xa1,b'\1'+u32(0)+bytes(16));fix=(0x9d,b'\xe4\0\x8c')
        dosseg=(0x88,b'\x80\x9e');separator=(0x88,b'\x40\xa2\1');timestamp=(0x88,b'\x80\xfeT1234')
        def parse(tail):return Module.parse(b''.join(rec(*r) for r in prefix+list(tail)+[(0x8a,b'\0')]))
        m=parse([defs,data,dosseg,separator,timestamp,data,fix,fix])
        self.assertEqual(len(m.fixups),2)
        self.assertEqual([e['target_definition'] for e in m.fixup_encodings],[1,1])
        with self.assertRaisesRegex(OMFError,'preceding data'):parse([defs,data,dosseg,fix])
        with self.assertRaisesRegex(OMFError,'undefined'):parse([data,fix])
        # A thread definition alone is metadata, never a fake relocation.
        m=parse([defs]);self.assertEqual(m.fixups,[])
        self.assertEqual(len(m.thread_definitions),2)

    def test_new_thread_paths_validate_indexes_datums_reserved_bits_and_truncations(self):
        for head in (0x00,0x04,0x08,0x40,0x44,0x48):
            for datum in (b'\0',b'\x7f',b'\x80',b''):
                with self.subTest(head=head,datum=datum),self.assertRaises(OMFError):
                    Module.parse(self.small([(0x9c,bytes([head])+datum)]))
        for head in (0x20,0x60,0x58,0x5c,0x0c,0x1c,0x4c):
            with self.subTest(head=head),self.assertRaisesRegex(OMFError,'thread'):
                Module.parse(self.small([(0x9c,bytes([head]))]))
        for fd,tail in ((0x10,b'\0\2'),(0x10,b'\1\0'),(0x12,b'\1\2')):
            with self.subTest(fd=fd,tail=tail),self.assertRaises(OMFError):
                Module.parse(self.small([(0x9c,b'\xd4\0'+bytes([fd])+tail+u32(0))]))
        # Every boundary of an otherwise valid four-byte displacement is tested.
        for sub in (b'\xd4',b'\xd4\0',b'\xd4\0\x10',b'\xd4\0\x10\1',
                    b'\xd4\0\x10\1\2',b'\xd4\0\x10\1\2\1',
                    b'\xd4\0\x10\1\2\1\0',b'\xd4\0\x10\1\2\1\0\0'):
            with self.subTest(sub=sub),self.assertRaisesRegex(OMFError,'truncated'):
                Module.parse(self.small([(0x9c,sub)]))
        with self.assertRaisesRegex(OMFError,'outside preceding data'):
            Module.parse(self.small([(0x9c,b'\xd4\x0d\x54\2')]))
        with self.assertRaisesRegex(OMFError,'preceding data'):
            Module.parse(self.small([(0x9c,b'\xd4\0\x54\2')],with_data=False))

    def test_two_byte_thread_indexes_refer_to_previously_defined_tables(self):
        extras=[(0x98,b'\xa8'+u32(0)+b'\2\3\1')]*126
        # Segment128 is valid; group128 and external128 are independently defined.
        extras += [(0x9a,b'\6')]*127+[(0x8c,name('extra')+b'\0')]*127
        for frame,target in ((0,0),(1,1),(2,2)):
            m=Module.parse(self.small(extras+[(0x9c,bytes([0x40|(frame<<2)])+b'\x80\x80'+bytes([target<<2])+b'\x80\x80'+b'\xd4\0\x8c')]))
            self.assertEqual((m.fixups[0].frame,m.fixups[0].target),(128,128))

    def test_record_framing_checksum_and_easy_wide_bounds_remain_strict(self):
        raw=object_bytes();damaged=bytearray(raw);damaged[8]^=1
        for data,error in ((bytes(damaged),'checksum'),(raw[:-1],'truncated'),(raw[:-5],'MODEND'),(raw+b'X','trailing')):
            with self.subTest(error=error),self.assertRaisesRegex(OMFError,error):Module.parse(data)
        # Existing zero-checksum omission convention applies without weakening nonzero validation.
        rs=records();encoded=[rec(*r) for r in rs];encoded[1]=encoded[1][:-1]+b'\0'
        self.assertEqual(Module.parse(b''.join(encoded)).format,'easy-omf386')
        for kind,payload in ((0xa0,b'\1'+u32(0x10020)+b'X'),
                             (0x90,b'\0\1'+name('outside')+u32(0x10021)+b'\0'),
                             (0x98,b'\xa8'+u32(64*1024*1024+1)+b'\2\3\1')):
            with self.subTest(kind=kind),self.assertRaises(OMFError):Module.parse(self.small([(kind,payload)]))
        for width in range(4):
            with self.subTest(width=width),self.assertRaises(OMFError):
                Module.parse(self.small([(0xa0,b'\1'+u32(1)[:width])]))

    def test_whole_gate_rejects_body_relocation_frame_and_placement_damage(self):
        image=LEImage.parse(linked_image());module=Module.parse(object_bytes())
        places={1:(1,0),2:(2,0)};symbols={'own_external':(2,0x10010)}
        def prove(m=module,p=places,s=symbols,f=None,img=image):
            return verify_module(m,img,p,s,group_frames=f)
        for frames in (None,{1:(1,0)},{1:(2,4)},{2:(2,0)}):
            with self.subTest(frames=frames),self.assertRaises(ModuleError):prove(f=frames)
        for seg,off in ((0,1),(0,0x1001f),(1,1),(1,0x1001f),(0,0x10000)):
            m=deepcopy(module);m.segments[seg].data[off]^=1
            with self.subTest(seg=seg,off=off),self.assertRaises(ModuleError):prove(m=m,f={1:(2,0)})
        for change in ({'target':1},{'displacement':1},{'relative':True}):
            m=deepcopy(module);m.fixups[0]=replace(m.fixups[0],**change)
            with self.subTest(change=change),self.assertRaises(ModuleError):prove(m=m,f={1:(2,0)})
        m=deepcopy(module);m.fixups.append(m.fixups[0])
        with self.assertRaisesRegex(ModuleError,'overlap'):prove(m=m,f={1:(2,0)})
        m=deepcopy(module);m.fixups.pop()
        with self.assertRaisesRegex(ModuleError,'unaccounted'):prove(m=m,f={1:(2,0)})
        with self.assertRaises(ModuleError):prove(p={1:(1,0)},f={1:(2,0)})
        with self.assertRaises(ModuleError):prove(s={},f={1:(2,0)})
        with self.assertRaises(ModuleError):prove(s={'own_external':(1,0x10010)},f={1:(2,0)})
        inferred=infer_bindings(module,image,1,0,known_symbols=symbols)
        self.assertEqual(inferred['placements'],places)
        self.assertEqual(inferred['symbols']['own_external'],(2,0x10010))
        with self.assertRaisesRegex(BindingError,'no relocations'):infer_data_bindings(module,{'own_data_high':(2,0x10010)})

    def test_relocation_free_easy_data_proves_without_fabricated_fixups(self):
        # A high-offset complete data source needs anchors, not dummy relocations.
        rs=[(0x80,name('own-data')),(0x88,b'\x80\xaa80386'),
            (0x96,name('')+name('DATA')),
            (0x98,b'\xa8'+u32(0x10020)+b'\2\2\1'),
            (0x90,b'\0\1'+name('own_data_high')+u32(0x10010)+b'\0')]
        body=bytearray(0x10020);body[-4:]=b'OWND'
        rs += [(0xa0,b'\1'+u32(off)+body[off:off+512]) for off in range(0,len(body),512)]
        rs += [(0x8a,b'\0')]
        module=Module.parse(b''.join(rec(*r) for r in rs))
        self.assertEqual(module.fixups,[])
        bindings=infer_data_bindings(module,{'own_data_high':(2,0x10010)})
        proof=verify_module(module,LEImage.parse(linked_image()),bindings['placements'],bindings['symbols'])
        self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),(65568,0))
        self.assertEqual(module.thread_definitions,[])

    def test_explicit_and_threaded_zero_displacement_provenance_is_distinct(self):
        m=Module.parse(self.small([(0x9c,b'\xd4\0\x54\2'),
                                  (0x9c,b'\xd4\4\x50\2'+u32(0))]))
        self.assertEqual([f.displacement for f in m.fixups],[0,0])
        self.assertEqual([e['displacement_present'] for e in m.fixup_encodings],[False,True])
        self.assertEqual([e['displacement_width'] for e in m.fixup_encodings],[0,4])
        self.assertNotEqual(m.fixup_encodings[0]['raw_bytes'],m.fixup_encodings[1]['raw_bytes'])

    def test_complete_gate_checks_loader_target_and_group_membership(self):
        module=Module.parse(object_bytes());image=LEImage.parse(linked_image())
        def prove(m=module,img=image):
            return verify_module(m,img,{1:(1,0),2:(2,0)},
                                 {'own_external':(2,0x10010)},group_frames={1:(2,0)})
        for field,delta in ((2,12),(5,1)):
            raw=bytearray(image.data);raw[image.fixup_record_start+field]^=delta
            with self.subTest(field=field),self.assertRaises(ModuleError):prove(img=LEImage.parse(bytes(raw)))
        m=deepcopy(module);m.groups=[('DGROUP',())]
        with self.assertRaisesRegex(ModuleError,'member target'):prove(m=m)

    def test_standard_inline_choices_in_threaded_module_remain_auditable(self):
        m=Module.parse(self.small([(0x9d,b'\x44\1\0\2'),
                                  (0x9d,b'\xe4\0\x54\2'),
                                  (0x9d,b'\xe4\4\x50\2'+u32(0)),
                                  (0x9d,b'\xe4\x08\x8c')],easy=False))
        self.assertEqual([e['target_thread'] for e in m.fixup_encodings],[False,False,True])
        self.assertEqual([e['displacement_present'] for e in m.fixup_encodings],[False,True,False])
        self.assertEqual([e['raw_fixdat'] for e in m.fixup_encodings],[0x54,0x50,0x8c])

    def test_standard_even_and_odd_thread_displacement_widths_stay_distinct(self):
        for kind,loc,payload,want in ((0x9c,0xc4,b'\x21\x43',0x4321),
                                     (0x9d,0xe4,u32(0x10001),0x10001)):
            with self.subTest(kind=kind):
                m=Module.parse(self.small([(kind,b'\0\2'),(kind,bytes([loc,0,0x58])+payload)],easy=False))
                self.assertEqual(m.fixups[0].displacement,want)
                self.assertEqual(m.fixup_encodings[0]['displacement_width'],len(payload))

    def test_native_threaded_self_relative_call_requires_no_loader_relocation(self):
        for easy,kind,loc in ((True,0x9c,0x94),(False,0x9d,0xa4)):
            rs=records(easy,True)
            first=next(i for i,r in enumerate(rs) if r[0]==kind)
            rs[first]=(kind,rs[first][1]+b'\1\1')  # target thread1 = own CODE
            third=next(i for i,r in enumerate(rs) if r[0]==kind and r[1].startswith(b'\x08\x01'))
            rs.insert(third+1,(kind,bytes([loc,12,0x5d])))
            module=Module.parse(b''.join(rec(*r) for r in rs))
            raw=bytearray(linked_image());raw[4096+0x1000c:4096+0x10010]=b'\xf0\xff\xfe\xff'
            image=LEImage.parse(bytes(raw))
            self.assertEqual(len(image.read_fixups()),3)
            proof=verify_module(module,image,{1:(1,0),2:(2,0)},
                                {'own_external':(2,0x10010)},group_frames={1:(2,0)})
            self.assertEqual(proof['verified_fixups'],4)
            self.assertTrue(module.fixups[3].relative)
            inferred=infer_bindings(module,image,1,0)
            self.assertEqual(inferred['placements'],{1:(1,0),2:(2,0)})

    def test_easy_public_group_index_cannot_name_an_undefined_group(self):
        with self.assertRaisesRegex(OMFError,'public group'):
            Module.parse(self.small([(0x90,b'\2\1'+name('bad_group')+u32(0)+b'\0')]))

    def test_easy_reserved_comment_flags_cannot_use_standard_ga_padding_exception(self):
        # A complete otherwise-proven module must fail before any verifier gate.
        rs=records();rs.insert(2,(0x88,b'\4\0\0'))
        with self.assertRaisesRegex(OMFError,'flags'):
            Module.parse(b''.join(rec(*r) for r in rs))
        # Preserve the existing measured standard GA filler convention.
        standard=records(False,False);standard.insert(1,(0x88,b'\4\0\0'))
        module=Module.parse(b''.join(rec(*r) for r in standard))
        proof=verify_module(module,LEImage.parse(linked_image()),{1:(1,0),2:(2,0)},
                            {'own_external':(2,0x10010)},group_frames={1:(2,0)})
        self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),(131136,3))

    def test_easy_null_theadr_name_is_a_present_header_and_complete_native_proof(self):
        # IBM2.4.1 permits the null name; presence and name content differ.
        rs=records();rs[0]=(0x80,b'\0')
        raw=b''.join(rec(*r) for r in rs);module=Module.parse(raw)
        self.assertEqual(module.name,'')
        self.assertEqual(b''.join(r[2] for r in module.source_records),raw)
        proof=verify_module(module,LEImage.parse(linked_image()),{1:(1,0),2:(2,0)},
                            {'own_external':(2,0x10010)},group_frames={1:(2,0)})
        self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),(131136,3))
        # Legacy standard behavior remains unchanged by the Easy declaration.
        with self.assertRaisesRegex(OMFError,'missing module header'):
            Module.parse(rec(0x80,b'\0')+rec(0x8a,b'\0'))

@unittest.skipUnless((ROOT/'reference/audiolib-reconstructions/LIB/PAWE32.LIB').is_file()
                     and (ROOT/'reference/DUKE3D.EXE').is_file(),'private PAWE32/target witnesses required')
class PAWE32ReferenceTests(unittest.TestCase):
    def test_all_original_members_pass_complete_gate_and_mutation_negatives(self):
        from easy_omf_fixtures import replay_pawe32
        result=replay_pawe32()
        self.assertEqual((result['initialized_bytes'],result['verified_fixups']),(42064,681))
        self.assertEqual(result['source_credit'],0)
        self.assertFalse(result['full_executable_rebuilt'])
        self.assertEqual(len(result['members']),7)

if __name__=='__main__':unittest.main()
