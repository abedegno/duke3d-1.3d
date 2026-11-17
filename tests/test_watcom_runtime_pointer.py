"""A supplied DATA pointer nominates a binding, never a partial native proof."""
import copy
from dataclasses import replace
import importlib
from pathlib import Path
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
LIBRARY = ROOT/'toolchains/watcom-10.5/LIB386/math387r.lib'


@unittest.skipUnless(LIBRARY.is_file() and (ROOT/'reference/DUKE3D.EXE').is_file(),
                     'private original stock math library and target required')
class NativeMatherrPointerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.api = importlib.import_module('tools.inventory_watcom_runtime')
        cls.original = cls.api.Module.parse(LIBRARY.read_bytes()[31472:32331])
        cls.image = cls.api.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        cls.inferred = cls.api.infer_bindings(cls.original, cls.image, 1, 625264)

    def nomination(self, module=None, image=None, inferred=None):
        self.assertTrue(hasattr(self.api, 'nominate_matherr_initializer'),
                        'fixed matherr DATA pointer nomination is missing')
        return self.api.nominate_matherr_initializer(
            module or self.original, image or self.image,
            self.inferred if inferred is None else inferred)

    def bound(self, module=None):
        result = copy.deepcopy(self.inferred)
        nomination = self.nomination(module)
        result['symbols'][nomination['symbol']] = nomination['value']
        result['constraints'].append(nomination)
        return result

    def test_unique_actual_data_pointer_enables_whole_member_and_retains_scope(self):
        expected = {'initialized_bytes': 295, 'zero_fill_bytes': 0, 'verified_fixups': 19}
        with self.assertRaisesRegex(ValueError, '__matherr'):
            self.api.native_gate(self.original, self.image, self.inferred, expected,
                                 group_frames={1: (3, 0)})
        before = copy.deepcopy(self.inferred)
        nomination = self.nomination()
        self.assertEqual(nomination['symbol'], '__matherr')
        self.assertEqual(nomination['value'], (1, 626184))
        self.assertEqual(nomination['callee_source_credit'], 0)
        self.assertEqual(self.inferred, before)
        proof = self.api.native_gate(self.original, self.image, self.bound(), expected,
                                     group_frames={1: (3, 0)})
        self.assertTrue(proof['verified'])
        self.assertEqual(proof['verified_fixups'], 19)
        self.assertEqual(proof['initialized_bytes'], 295)
        self.assertEqual(proof['local_symbols'], {'_Msgs': (3, 29532)})
        self.assertNotIn('_Msgs', self.api.external_anchor_bindings(proof))
        self.assertFalse(proof['full_executable_rebuilt'])

    def test_nomination_rejects_changed_source_pointer_geometry_addends_and_scope(self):
        self.nomination()
        pointer = self.original.fixups[-1]
        for fields in ({'offset': 1}, {'width': 2}, {'location': 5}, {'relative': True},
                       {'frame_method': 1, 'frame': 1}, {'target_method': 0},
                       {'target': 2}, {'target': True}, {'displacement': 1}):
            module = copy.deepcopy(self.original)
            module.fixups[-1] = replace(pointer, **fields)
            with self.subTest(pointer=fields), self.assertRaises(ValueError):
                self.nomination(module)
        for kind in ('raw_addend', 'duplicate', 'local_external', 'local_owner',
                     'defined_callee', 'owner_offset', 'external_name', 'segment', 'group'):
            module = copy.deepcopy(self.original)
            if kind == 'raw_addend': module.segments[3].data[0] = 1
            elif kind == 'duplicate': module.fixups.append(pointer)
            elif kind == 'local_external': module.local_externals.add(1)
            elif kind == 'local_owner': module.local_publics.add('__RWD_matherr')
            elif kind == 'defined_callee': module.publics['__matherr'] = (1, 0)
            elif kind == 'owner_offset': module.publics['__RWD_matherr'] = (4, 1)
            elif kind == 'external_name': module.externals[0] = 'another_hook'
            elif kind == 'segment': module.segments[3].attributes = 73
            elif kind == 'group': module.groups = [('DGROUP', (2, 3, 5))]
            with self.subTest(source=kind), self.assertRaises(ValueError):
                self.nomination(module)

    def test_nomination_requires_unique_exact_native_kind_and_file_backed_field(self):
        self.nomination()
        edges = list(self.image.read_fixups())
        edge = next(e for e in edges if (e.source_object, e.source_offset) == (3, 73156))
        for fields in ({'source_type': 8}, {'width': 2}, {'alias': True},
                       {'source_object': 1}, {'source_offset': 73160},
                       {'target_object': 3}, {'target_offset': 626185},
                       {'target_address': 691721}):
            changed = [replace(e, **fields) if e == edge else e for e in edges]
            with self.subTest(edge=fields), patch.object(self.image, 'read_fixups', return_value=changed), self.assertRaises(ValueError):
                self.nomination()
        for changed in ([e for e in edges if e != edge], edges + [edge]):
            with self.subTest(edges=len(changed)), patch.object(self.image, 'read_fixups', return_value=changed), self.assertRaises(ValueError):
                self.nomination()
        image = copy.deepcopy(self.image)
        position = image.file_offset(3, 73156)
        data = bytearray(image.data); data[position] ^= 1; image.data = bytes(data)
        with self.assertRaises(ValueError): self.nomination(image=image)
        image = copy.deepcopy(self.image)
        page_index = image._object(3).first_page - 1 + 73156 // image.page_size
        pages = list(image.pages); pages[page_index] = replace(pages[page_index], file_offset=None)
        image.pages = tuple(pages)
        with self.assertRaises(ValueError): self.nomination(image=image)

    def test_existing_bindings_are_validated_without_overwriting_conflicts(self):
        self.nomination()
        for kind in ('CODE', 'DATA', 'missing_DATA', 'owner', 'callee', 'boolean_callee'):
            inferred = copy.deepcopy(self.inferred)
            if kind == 'CODE': inferred['placements'][1] = (1, 625265)
            elif kind == 'DATA': inferred['placements'][4] = (3, 73160)
            elif kind == 'missing_DATA': del inferred['placements'][4]
            elif kind == 'owner': inferred['symbols']['__RWD_matherr'] = (3, 73160)
            elif kind == 'callee': inferred['symbols']['__matherr'] = (1, 626185)
            elif kind == 'boolean_callee': inferred['symbols']['__matherr'] = (True, 626184)
            before = copy.deepcopy(inferred)
            with self.subTest(binding=kind), self.assertRaises(ValueError):
                self.nomination(inferred=inferred)
            self.assertEqual(inferred, before)
        inferred = copy.deepcopy(self.inferred)
        inferred['symbols']['__matherr'] = (1, 626184)
        self.assertEqual(self.nomination(inferred=inferred)['value'], (1, 626184))

    def test_pointer_nomination_never_accepts_damaged_code_const_or_fixups(self):
        self.nomination()
        expected = {'initialized_bytes': 295, 'zero_fill_bytes': 0, 'verified_fixups': 19}
        for segment, offset in ((1, 124), (2, 0), (2, 137), (3, 27)):
            module = copy.deepcopy(self.original); module.segments[segment-1].data[offset] ^= 1
            with self.subTest(segment=segment, offset=offset), self.assertRaises(ValueError):
                self.api.native_gate(module, self.image, self.bound(module), expected,
                                     group_frames={1: (3, 0)})
        module = copy.deepcopy(self.original)
        module.fixups[0] = replace(module.fixups[0], displacement=1)
        with self.assertRaises(ValueError):
            self.api.native_gate(module, self.image, self.bound(module), expected,
                                 group_frames={1: (3, 0)})


if __name__ == '__main__':
    unittest.main()
