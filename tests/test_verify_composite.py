"""Complete emitted-object ownership, cross references and scope isolation."""
from copy import deepcopy
from dataclasses import replace
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/'profiles/watcom/tools'),
                str(ROOT/'profiles/watcom/tests')]
from le import LEImage
from omf32 import Module, Segment, Fixup
from test_le import with_fixups
from tools.verify_module import ModuleError
try:
    from tools.verify_composite import verify_composite
except ModuleNotFoundError:
    verify_composite = None


class CompositeTests(unittest.TestCase):
    def setUp(self):
        raw = bytearray(with_fixups(b'\x07\0\x01\0\x01\x08\0'))
        raw[0x440:0x446] = b'\xa1\x08\0\0\0\xc3'
        raw[0x448:0x44c] = b'ABCD'
        self.image = LEImage.parse(bytes(raw))
        self.modules = {
            'reader': Module(name='reader', segments=[
                Segment('_TEXT', 'CODE', 6, 0x69,
                        bytearray(b'\xa1\0\0\0\0\xc3'))],
                publics={'read_': (1, 0)}, externals=['_value'],
                groups=[('FLAT', ())],
                fixups=[Fixup(1, 1, 4, 9, False, 1, 1, 2, 1, 0)]),
            'storage': Module(name='storage', segments=[
                Segment('_DATA', 'DATA', 4, 0xa9, bytearray(b'ABCD')),
                Segment('_BSS', 'BSS', 4, 0xa9, bytearray(4))],
                publics={'_value': (1, 0), '_buffer': (2, 0)})}
        self.placements = {'reader': {1: (1, 0)},
                           'storage': {1: (1, 8), 2: (1, 24)}}
        self.expected = [(1, 0, 6, 'initialized'),
                         (1, 8, 4, 'initialized'), (1, 24, 4, 'BSS')]

    def prove(self, **kwargs):
        self.assertIsNotNone(verify_composite, 'complete composite gate missing')
        args = dict(modules=self.modules, image=self.image,
                    placements=self.placements, symbols={},
                    expected_ranges=self.expected)
        args.update(kwargs)
        return verify_composite(**args)

    def test_cross_object_pointer_uses_actual_export_and_accounts_every_segment(self):
        proof = self.prove()
        self.assertTrue(proof['verified'])
        self.assertEqual((proof['initialized_bytes'], proof['zero_fill_bytes'],
                          proof['verified_fixups']), (10, 4, 1))
        self.assertEqual(proof['publics']['_value'], (1, 8))
        self.assertEqual(set(proof['components']), {'reader', 'storage'})
        self.assertFalse(proof['full_executable_rebuilt'])

    def test_missing_extra_and_wrong_kind_obligations_reject(self):
        for expected in (self.expected[:-1],
                         self.expected + [(1, 28, 1, 'BSS')],
                         [*self.expected[:-1], (1, 24, 4, 'initialized')],
                         [(1, 0, 12, 'initialized'), self.expected[-1]]):
            with self.subTest(expected=expected), self.assertRaises(ModuleError):
                self.prove(expected_ranges=expected)

    def test_duplicate_export_rejects_before_binding_or_byte_proof(self):
        self.modules['storage'].publics['read_'] = (1, 0)
        with self.assertRaisesRegex(ModuleError, 'duplicate.*public|duplicate.*export'):
            self.prove()

    def test_conflicting_external_anchor_cannot_override_actual_export(self):
        with self.assertRaisesRegex(ModuleError, 'conflict'):
            self.prove(symbols={'_value': (1, 9)})

    def test_private_same_spelling_keeps_independent_scope(self):
        for module in self.modules.values():
            module.publics['private_scratch'] = (1, 0)
            module.local_publics.add('private_scratch')
        proof = self.prove()
        self.assertNotIn('private_scratch', proof['publics'])
        self.assertEqual(proof['components']['reader']['local_symbols'],
                         {'private_scratch': (1, 0)})
        self.assertEqual(proof['components']['storage']['local_symbols'],
                         {'private_scratch': (1, 8)})

    def test_private_export_cannot_resolve_another_objects_external(self):
        self.modules['storage'].local_publics.add('_value')
        with self.assertRaises(ModuleError):
            self.prove()

    def test_private_name_in_external_anchor_map_cannot_leak_between_objects(self):
        self.modules['storage'].local_publics.add('_value')
        with self.assertRaisesRegex(ModuleError, 'private|local'):
            self.prove(symbols={'_value': (1, 8)})

    def test_unresolved_local_external_does_not_inherit_global_binding(self):
        self.modules['reader'].local_externals.add(1)
        with self.assertRaisesRegex(ModuleError, 'local|private'):
            self.prove()

    def test_global_external_cannot_be_redirected_to_own_same_named_local(self):
        reader = self.modules['reader']
        reader.publics['_value'] = (1, 0)
        reader.local_publics.add('_value')
        # Make the illegal local binding match the pointer to expose scope
        # laundering independently of ordinary relocated-byte rejection.
        raw = bytearray(with_fixups(b'\x07\0\x01\0\x01\0\0'))
        raw[0x440:0x446] = b'\xa1\0\0\0\0\xc3'
        raw[0x448:0x44c] = b'ABCD'
        self.image = LEImage.parse(bytes(raw))
        with self.assertRaisesRegex(ModuleError, 'ambiguous|scope'):
            self.prove()

    def test_same_spelling_global_and_local_external_indices_reject(self):
        reader = self.modules['reader']
        reader.externals.append('_value')
        reader.local_externals.add(2)
        reader.publics['_value'] = (1, 0)
        reader.local_publics.add('_value')
        raw = bytearray(with_fixups(b'\x07\0\x01\0\x01\0\0'))
        raw[0x440:0x446] = b'\xa1\0\0\0\0\xc3'
        raw[0x448:0x44c] = b'ABCD'
        self.image = LEImage.parse(bytes(raw))
        with self.assertRaisesRegex(ModuleError, 'ambiguous|scope'):
            self.prove()

    def test_overlapping_producers_reject_before_proof(self):
        self.placements['storage'][1] = (1, 0)
        with self.assertRaisesRegex(ModuleError, 'overlap'):
            self.prove()

    def test_unplaced_or_extra_placement_reject(self):
        for changes in ({}, {1: (1, 8), 2: (1, 24), 99: (1, 0)}):
            with self.subTest(changes=changes), self.assertRaises(ModuleError):
                self.prove(placements={**self.placements, 'storage': changes})

    def test_numeric_coercion_and_duplicate_normalized_indices_reject(self):
        for places in ({1.5: (1, 0)}, {True: (1, 0)},
                       {1: (1, 0), '1': (1, 0)}, {1: (1, 0.5)}):
            with self.subTest(places=places), self.assertRaises(ModuleError):
                self.prove(placements={**self.placements, 'reader': places})

    def test_bad_tail_and_fixup_cannot_hide_in_another_proof(self):
        for damage in ('tail', 'pointer', 'addend'):
            modules = deepcopy(self.modules)
            if damage == 'tail':
                modules['storage'].segments[0].data[-1] ^= 1
            elif damage == 'pointer':
                modules['reader'].segments[0].data[1] = 1
            else:
                modules['reader'].fixups[0] = replace(
                    modules['reader'].fixups[0], displacement=1)
            with self.subTest(damage=damage), self.assertRaises(ModuleError):
                self.prove(modules=modules)

    def test_empty_and_mismatched_producer_sets_reject(self):
        for changes in ({'modules': {}}, {'placements': {}},
                        {'modules': {**self.modules, 'empty': Module()}}):
            with self.subTest(changes=changes), self.assertRaises(ModuleError):
                self.prove(**changes)


if __name__ == '__main__':
    unittest.main()
