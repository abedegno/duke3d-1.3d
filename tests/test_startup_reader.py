"""Task339 contract: full raw native inputs and bounded corruptions; no runtime credit."""
from pathlib import Path
from dataclasses import asdict
import hashlib,sys,unittest,json,os
R=Path(__file__).resolve().parents[1]
FIXTURES=Path(os.environ.get('OMF_STARTUP_FIXTURES',str(R/'build/startup-reader-fixtures')))
FIXTURE_PINS={'own335.obj': '778c5e620dbb9c2ccb20e9e1c0e79432d51e907ede04d67130849d10280f70b1', 'own335.exe': '1d376c77e1a18c75f0bf272c7bb939536cf215e02f61a5a2ed232de552b958e2', 'own327.exe': 'a5ff99b08f48181cc1cd136a87092dbc08ec14e8ab29f40b1648ca645201854c', 'stock105-inventory.json': 'd3f36ddb6c19efe74fbf7c4029048efc2e6d3cf9d5f5d3d69e836ff180ac4939'}
sys.path[:0]=[str(R),str(R/'tests'),str(R/'profiles/watcom/tools')]
import omf32 as omf

def rec(kind,payload):
    data=bytes([kind])+(len(payload)+1).to_bytes(2,'little')+payload
    return data+bytes([-sum(data)&255])
def records(raw):
    out=[];p=0
    while p<len(raw):
        end=p+3+int.from_bytes(raw[p+1:p+3],'little')
        out.append((raw[p],raw[p+3:end-1]));p=end
    return out
def replace_first(raw,predicate,kind,payload):
    rs=records(raw)
    i=next(i for i,r in enumerate(rs) if predicate(*r))
    rs[i]=(kind,payload)
    return b''.join(rec(*r) for r in rs)

class StartupReader(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        for name,expected in FIXTURE_PINS.items():
            path=FIXTURES/name
            if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest()!=expected:
                raise AssertionError('Missing/changed startup observer fixture '+str(path)+'; see docs/omf-startup-reader.md and OMF_STARTUP_FIXTURES')
        cls.stock=(R/'toolchains/watcom-10.5/LIB386/DOS/clib3r.lib').read_bytes()[80464:82331]
        assert hashlib.sha256(cls.stock).hexdigest()=='9ca09fa62ddd3ecaa4975e24bd529020f970ed84312692061c95edc9afec4ffb'
        cls.own=(FIXTURES/'own335.obj').read_bytes()
    def parse(self,raw):
        self.assertTrue(callable(getattr(omf,'parse_startup',None)), 'opt-in startup reader is absent')
        return omf.parse_startup(raw)
    def test_complete_native_inputs_keep_entry_ranges_and_all_records(self):
        for raw,size,fixups,ranges,entry in [
            (self.stock,727,34,[(1,2,120),(1,490,491),(1,725,727)],0),
            (self.own,25,2,[(1,2,10)],10)]:
            with self.subTest(size=size):
                with self.assertRaises(omf.OMFError):omf.Module.parse(raw)
                parsed=self.parse(raw);m=parsed.module
                self.assertEqual(parsed.profile,'watcom-startup-32-v1')
                self.assertEqual(m.segments[0].size,size)
                self.assertEqual(len(m.fixups),fixups)
                self.assertEqual(m.code_data_ranges,ranges)
                self.assertEqual((parsed.entry['segment'],parsed.entry['displacement'],parsed.entry['displacement_width']),(1,entry,2))
                self.assertEqual(parsed.entry['raw_payload'],b'\xc1\x50\x01'+entry.to_bytes(2,'little'))
                self.assertEqual(b''.join(r['raw_record'] for r in parsed.records),raw)
                self.assertEqual([r['ordinal'] for r in parsed.records],list(range(len(records(raw)))))
                self.assertEqual([(x['segment'],x['start'],x['stop']) for x in parsed.annotations],ranges)
                self.assertTrue(all(x['flags']==128 and x['directive']==ord('s') and x['offset_width']==2 and x['pass_two'] for x in parsed.annotations))
        obs=json.loads((FIXTURES/'stock105-inventory.json').read_text())
        m=self.parse(self.stock).module
        self.assertEqual(m.externals,obs['externals'])
        self.assertEqual(m.publics,{n:tuple(v[:2])for n,v in obs['publics'].items()})
        self.assertEqual([(s.name,s.class_name,s.size,s.attributes)for s in m.segments],[(s['name'],s['class'],s['size'],s['attributes'])for s in obs['segments']])
        self.assertEqual([asdict(f) for f in m.fixups],[{k:v for k,v in f.items() if k in asdict(m.fixups[0])}for f in obs['fixups']])
    def test_bad_or_unmeasured_entry_forms_reject(self):
        for kind,payload in [(0x8a,p)for p in [b'\x81\x50\x01\0\0',b'\xc0\x50\x01\0\0',b'\xc1\x54\x01\0\0',b'\xc1\xd0\x01\0\0',b'\xc1\x50\0\0\0',b'\xc1\x50\x7f\0\0',b'\xc1\x50\x80',b'\xc1\x50\x01\0',b'\xc1\x50\x01\xff\xff',b'\xc1\x50\x01\0\0\0\0']]+[(0x8b,b'\xc1\x50\x01\0\0\0\0')]:
            damaged=replace_first(self.stock,lambda k,p:k==0x8a,kind,payload)
            with self.subTest(payload=payload.hex()),self.assertRaises(omf.OMFError):self.parse(damaged)
        with self.assertRaises(omf.OMFError):self.parse(self.stock+rec(0x8a,b'\0'))
    def test_bad_or_unmeasured_postpass_annotations_reject(self):
        for payload in [b'\0\xfd\x73\x01\x02\0\x78\0',b'\x80\xfd\x53\x01\x02\0\x78\0',b'\x80\xfd\x74\x01\x02\0\x78\0',b'\x80\xfd\x73\0\x02\0\x78\0',b'\x80\xfd\x73\x7f\x02\0\x78\0',b'\x80\xfd\x73\x01\x78\0\x02\0',b'\x80\xfd\x73\x01\0\0\xff\xff',b'\x80\xfd\x73\x01\0',b'\x80\xfe\x73\x01\x02\0\x78\0']:
            damaged=replace_first(self.stock,lambda k,p:k==0x88 and p[:2]==b'\x80\xfd',0x88,payload)
            with self.subTest(payload=payload.hex()),self.assertRaises(omf.OMFError):self.parse(damaged)
    def test_entry_and_annotation_require_defined_use32_code(self):
        for attr,klass in [(0x68,5),(0x69,6)]:
            # First SEGDEF name is2/class5. DATA class is6 in actual stock LNAMES.
            rs=records(self.stock);i=next(i for i,(k,p) in enumerate(rs)if k==0x99)
            p=bytearray(rs[i][1]);p[0]=attr;p[6]=klass;rs[i]=(0x99,bytes(p))
            with self.subTest(attr=attr,klass=klass),self.assertRaises(omf.OMFError):self.parse(b''.join(rec(*r)for r in rs))

    def test_annotation_closes_data_but_retains_and_redefines_threads(self):
        from easy_omf_fixtures import records as fixture_records,u32
        rs=fixture_records(False,False)
        prefix=rs[:next(i for i,r in enumerate(rs)if r[0]==0xa1)]
        definitions=(0x9d,b'\x44\1\0\2')
        data=(0xa1,b'\1'+u32(0)+bytes(16))
        fd=(0x88,b'\x80\xfd\x73\1\0\0\x10\0')
        sep=(0x88,b'\x40\xa2\1')
        fix=(0x9d,b'\xe4\0\x8c')
        def raw(tail):return b''.join(rec(*r)for r in prefix+list(tail)+[(0x8a,b'\0')])
        parsed=self.parse(raw([definitions,data,sep,fd,data,fix,(0x9d,b'\0\1'),fd,data,fix]))
        m=parsed.module
        self.assertEqual([(f.frame_method,f.frame,f.target_method,f.target)for f in m.fixups],[(1,1,0,2),(1,1,0,1)])
        self.assertEqual([x['target_definition']for x in m.fixup_encodings],[1,2])
        self.assertEqual(m.thread_definitions[2]['replaces'],1)
        self.assertEqual(len(parsed.annotations),2)
        with self.assertRaisesRegex(omf.OMFError,'preceding data'):
            self.parse(raw([definitions,data,sep,fd,fix]))
        with self.assertRaisesRegex(omf.OMFError,'undefined'):
            self.parse(raw([data,sep,fd,data,fix]))
    def test_annotated_bytes_still_undergo_complete_normal_proof(self):
        from easy_omf_fixtures import records as fixture_records,linked_image
        from le import LEImage
        from tools.verify_module import verify_module,ModuleError
        rs=fixture_records(False,True)
        i=next(i for i,r in enumerate(rs)if r[0]==0xa1)
        rs.insert(i,(0x88,b'\x40\xa2\1'))
        rs.insert(i+2,(0x88,b'\x80\xfd\x73\1\0\0\x10\0'))
        m=self.parse(b''.join(rec(*r)for r in rs)).module
        image=LEImage.parse(linked_image())
        proof=verify_module(m,image,{1:(1,0),2:(2,0)},{'own_external':(2,0x10010)},group_frames={1:(2,0)})
        self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),(131136,3))
        m.segments[0].data[0]^=1
        with self.assertRaises(ModuleError):
            verify_module(m,image,{1:(1,0),2:(2,0)},{'own_external':(2,0x10010)},group_frames={1:(2,0)})
    def test_no_entry_default_and_easy_boundaries_are_preserved(self):
        from easy_omf_fixtures import object_bytes
        raw=object_bytes(False,True)
        parsed=self.parse(raw)
        self.assertIsNone(parsed.entry)
        self.assertEqual(asdict(parsed.module),asdict(omf.Module.parse(raw)))
        with self.assertRaises(omf.OMFError):self.parse(object_bytes(True,True))

    def test_native_entry_placements_match_actual_le_headers(self):
        from le import LEImage
        own=self.parse(self.own)
        image=LEImage.parse((FIXTURES/'own335.exe').read_bytes())
        self.assertEqual((image.entry_object,image.entry_offset),(1,10))
        self.assertEqual((1,0+own.entry['displacement']),(image.entry_object,image.entry_offset))
        # Separate authentic GA CRT/C fixture executed42; this is not the raw-entry1012 fixture.
        lib=(R/'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib').read_bytes()
        raw=lib[76320:76320+1853]
        self.assertEqual(hashlib.sha256(raw).hexdigest(),'9cd54a753ba95691fa995c6da83f9a77b5fb0b8b8e6a1aaab86d3ba5bdc32aa8')
        startup=self.parse(raw)
        self.assertEqual(startup.module.code_data_ranges,[(1,2,122),(1,492,493)])
        self.assertEqual(len(startup.module.fixups),34)
        self.assertEqual(startup.entry['displacement'],0)
        cimage=LEImage.parse((FIXTURES/'own327.exe').read_bytes())
        self.assertEqual((cimage.entry_object,cimage.entry_offset),(1,92))
        self.assertEqual((1,92+startup.entry['displacement']),(cimage.entry_object,cimage.entry_offset))

if __name__=='__main__':unittest.main()
