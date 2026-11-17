"""Fixed whole stock additions preserve source credit and the original57 proofs."""
import hashlib
import copy
import importlib
import json
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
ORIGINAL_OFFSETS={'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib': [16, 1328, 6048, 9200, 9392, 9568, 10384, 11808, 23680, 24496, 33952, 36048, 36880, 37152, 39920, 41968, 47600, 49952, 58256, 58560, 64816, 75200, 111840, 114192, 119472, 119872, 120448, 121232, 121472, 122784, 125664, 130480, 137184, 141568, 148112, 150336, 150768, 159312, 163504, 166752, 167040, 171872, 172144, 9808, 34896, 40944, 81536, 86368], 'toolchains/watcom-10.0-ga/LIB386/math387r.lib': [8608, 9600, 16928, 17280, 19232, 8768, 17616], 'toolchains/watcom-10.5/LIB386/DOS/clib3r.lib': [73808, 196400]}
ORIGINAL_57_SHA256='cb26d44b20fa73a30d890c4e55216b473bdbd727bc0d69bcd666b2728cae4e2d'

@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and (ROOT/'toolchains/watcom-10.5/LIB386/math387r.lib').is_file(),'private stock inputs required')
class NativeFixedExtensionTests(unittest.TestCase):
    def test_whole_vendor_callback_chain_rejects_tail_and_callee_damage(self):
        api=importlib.import_module('tools.inventory_watcom_runtime')
        library='toolchains/watcom-10.5/LIB386/math387r.lib'
        raw=(ROOT/library).read_bytes()
        archive=api.read_archive(raw)
        image=api.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for name,size,fixups in [('__mtherr',5,1),('matherr',3,0)]:
            spec=next(s for s in api.SELECTED[library]if s['name']==name)
            member=api.select_member(raw,archive,spec)
            module=api.Module.parse(raw[member['offset']:member['end']])
            inferred=api.infer_bindings(module,image,1,spec['code_offset'])
            proof=api.native_gate(module,image,inferred,spec['expected'])
            self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),(size,fixups))
            broken=copy.deepcopy(module);broken.segments[0].data[size-1]^=1
            with self.subTest(member=name),self.assertRaises(ValueError):
                api.native_gate(broken,image,inferred,spec['expected'])
            if name=='__mtherr':
                changed=copy.deepcopy(inferred);changed['symbols']['matherr_']=(1,626417)
                with self.assertRaises(ValueError):
                    api.native_gate(module,image,changed,spec['expected'])

    def test_fixed_selection_has_all76_whole105_additions_and_no106_dependency(self):
        api=importlib.import_module('tools.inventory_watcom_runtime')
        self.assertEqual(sum(len(s)for s in api.SELECTED.values()),133)
        self.assertEqual(set(api.LIBRARIES),{
            'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib',
            'toolchains/watcom-10.0-ga/LIB386/math387r.lib',
            'toolchains/watcom-10.5/LIB386/DOS/clib3r.lib',
            'toolchains/watcom-10.5/LIB386/math387r.lib'})
        self.assertEqual(api.LIBRARIES['toolchains/watcom-10.5/LIB386/math387r.lib'],
                         '14c1fde264b0488c4df68aa3c8ca5291857216c6ac3a08f16f505f3d746291c0')
        new=[s for lib,specs in api.SELECTED.items() for s in specs
             if s['offset']not in ORIGINAL_OFFSETS.get(lib,[])]
        self.assertEqual(len(new),76)
        self.assertEqual(sum(s['expected']['initialized_bytes']for s in new),23518)
        self.assertEqual(sum(s['expected']['zero_fill_bytes']for s in new),268)
        self.assertEqual(sum(s['expected']['verified_fixups']for s in new),566)

    def test_full133_native_replay_keeps_original57_dictionaries_and_zero_source_credit(self):
        api=importlib.import_module('tools.inventory_watcom_runtime')
        try:
            report=api.inventory((ROOT/'reference/DUKE3D.EXE').read_bytes(),
                {lib:(ROOT/lib).read_bytes()for lib in api.LIBRARIES},{'ranges':[]})
        except ValueError as error:
            self.fail('fixed complete native replay rejected: '+str(error))
        self.assertEqual(report['totals']['verified_members'],133)
        self.assertEqual(report['totals']['initialized_bytes'],29521)
        self.assertEqual(report['totals']['zero_fill_bytes'],268)
        self.assertEqual(report['totals']['code_bytes'],28045)
        self.assertEqual(report['totals']['verified_fixups'],712)
        old=[c for c in report['components'] if c['offset']in ORIGINAL_OFFSETS.get(c['library'],[])]
        self.assertEqual(len(old),57)
        actual=hashlib.sha256(json.dumps(old,sort_keys=True,separators=(',',':')).encode()).hexdigest()
        self.assertEqual(actual,ORIGINAL_57_SHA256)
        self.assertFalse(report['payload_emitted'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(report['totals']['rebuilt_source_bytes_added'],0)
        self.assertEqual(report['totals']['complete_source_contributions_added'],0)
        self.assertTrue(all(c['rebuilt_source_credit']==0 and c['verification']['verified']for c in report['components']))
        matherr=next(c for c in report['components']if c['name']=='_matherr')
        self.assertEqual(matherr['verification']['verified_fixups'],19)
        self.assertEqual(matherr['verification']['initialized_bytes'],295)
        nominations=[c for c in matherr['constraints']if c.get('symbol')=='__matherr']
        self.assertEqual(len(nominations),1)
        self.assertEqual(nominations[0]['callee_source_credit'],0)
        self.assertEqual(tuple(nominations[0]['value']),(1,626184))
        chain={c['name']:c for c in report['components']if c['name']in ('__mtherr','matherr')}
        self.assertEqual(set(chain),{'__mtherr','matherr'})
        self.assertEqual(chain['__mtherr']['verification']['initialized_bytes'],5)
        self.assertEqual(chain['__mtherr']['verification']['verified_fixups'],1)
        self.assertEqual(tuple(chain['__mtherr']['external_anchor_bindings']['__matherr']),(1,626184))
        self.assertEqual(tuple(chain['__mtherr']['external_anchor_bindings']['matherr_']),(1,626416))
        self.assertEqual(chain['matherr']['verification']['initialized_bytes'],3)
        self.assertEqual(chain['matherr']['verification']['verified_fixups'],0)
        self.assertEqual(tuple(chain['matherr']['external_anchor_bindings']['matherr_']),(1,626416))
        self.assertIn('dependency_nomination',chain['__mtherr']['discovery'])
        self.assertIn('dependency_nomination',chain['matherr']['discovery'])

if __name__=='__main__':unittest.main()
