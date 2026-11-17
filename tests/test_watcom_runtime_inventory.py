"""Stock dependencies earn native coverage only after complete-member proof."""
import copy
from dataclasses import replace
import hashlib
import importlib
import json
from pathlib import Path
import struct
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def record(kind, payload):
    prefix = bytes([kind]) + struct.pack('<H', len(payload) + 1) + payload
    return prefix + bytes([-sum(prefix) & 255])


def archive_fixture(member=None):
    member = member or record(0x80, b'\x04unit') + record(0x8a, b'\0')
    # One 16-byte header page, member page(s), LIBEND to dictionary at 512.
    header = b'\xf0\x0d\0' + struct.pack('<IHB', 512, 1, 1) + bytes(6)
    body = header + member
    body += bytes(-len(body) % 16)
    body += b'\xf1' + struct.pack('<H', 512 - len(body) - 3)
    body += bytes(512 - len(body))
    return body + bytes(512), member


class RuntimeInventoryTests(unittest.TestCase):
    def api(self):
        self.assertTrue((ROOT/'tools/inventory_watcom_runtime.py').is_file(),
                        'selected stock-member inventory implementation missing')
        return importlib.import_module('tools.inventory_watcom_runtime')

    def test_exact_member_extent_excludes_page_padding_and_dictionary(self):
        api = self.api(); raw, member = archive_fixture()
        archive = api.read_archive(raw)
        self.assertEqual(archive['page_size'], 16)
        self.assertEqual(archive['dictionary_offset'], 512)
        self.assertEqual(len(archive['members']), 1)
        selected = api.select_member(raw, archive, {
            'offset': 16, 'size': 14, 'sha256': digest(member), 'name': 'unit'})
        self.assertEqual(selected['end'], 30)
        self.assertEqual(selected['padding_bytes'], 2)
        self.assertEqual([r['kind'] for r in selected['records']], [0x80, 0x8a])
        self.assertEqual([r['checksum'] for r in selected['records']], ['valid', 'valid'])
        omitted = bytearray(member); omitted[-1] = 0
        other, _ = archive_fixture(bytes(omitted))
        self.assertEqual(api.read_archive(other)['members'][0]['records'][-1]['checksum'],
                         'omitted')

    def test_bad_record_boundary_checksum_padding_and_dictionary_are_rejected(self):
        api = self.api(); raw, _ = archive_fixture()
        cases = []
        broken = bytearray(raw); broken[1:3] = b'\x0c\0'; cases.append(broken)
        broken = bytearray(raw); broken[3:7] = struct.pack('<I', 16); cases.append(broken)
        broken = bytearray(raw); broken[7:9] = b'\x02\0'; cases.append(broken)
        broken = bytearray(raw); broken[17:19] = b'\xff\xff'; cases.append(broken)
        broken = bytearray(raw); broken[22] ^= 1; cases.append(broken)
        broken = bytearray(raw); broken[30] = 1; cases.append(broken)
        broken = bytearray(raw); broken[32] = 0x80; cases.append(broken)
        cases.append(raw[:-1])
        for n, damaged in enumerate(cases):
            with self.subTest(case=n), self.assertRaises(ValueError):
                api.read_archive(bytes(damaged))

    def test_embedded_object_wrong_name_extent_and_member_hash_cannot_be_selected(self):
        api = self.api(); raw, member = archive_fixture(); archive = api.read_archive(raw)
        spec = {'offset': 16, 'size': 14, 'sha256': digest(member), 'name': 'unit'}
        for change in ({'offset': 17}, {'size': 16}, {'sha256': '0'*64}, {'name': 'other'}):
            with self.subTest(change=change), self.assertRaises(ValueError):
                api.select_member(raw, archive, dict(spec, **change))

    def test_changed_member_bytes_and_nested_header_cannot_hide_in_archive(self):
        api = self.api(); raw, member = archive_fixture(); archive = api.read_archive(raw)
        spec = {'offset': 16, 'size': 14, 'sha256': digest(member), 'name': 'unit'}
        damaged = bytearray(raw); damaged[22] ^= 1
        with self.assertRaisesRegex(ValueError, 'identity'):
            api.select_member(bytes(damaged), archive, spec)
        nested, _ = archive_fixture(record(0x80, b'\x04unit') + member)
        with self.assertRaisesRegex(ValueError, 'nested'):
            api.read_archive(nested)
        # Framing may inventory a startup member the native parser does not support;
        # it must never reinterpret its MODEND or silently accept it as native proof.
        startup, _ = archive_fixture(record(0x80, b'\x04unit') + record(0x8a, b'\xc1\x50\x01\0\0'))
        framed = api.read_archive(startup)['members'][0]
        with self.assertRaisesRegex(ValueError, 'MODEND'):
            api.Module.parse(startup[framed['offset']:framed['end']])

    def test_overlap_union_never_adds_source_credit_or_double_subtracts(self):
        api = self.api()
        ranges = [{'object': 1, 'start': 10, 'end': 30, 'class': 'CODE'},
                  {'object': 3, 'start': 7, 'end': 11, 'class': 'DATA'}]
        accepted = [{'owner': 'a', 'object': 1, 'start': 15, 'end': 25, 'size': 10},
                    {'owner': 'b', 'object': 1, 'start': 20, 'end': 30, 'size': 10},
                    {'owner': 'rand', 'object': 3, 'start': 7, 'end': 11, 'size': 4}]
        result = api.coverage_totals(ranges, accepted)
        self.assertEqual(result['code_bytes'], 20)
        self.assertEqual(result['overlap_code_bytes'], 15)
        self.assertEqual(result['overlap_initialized_bytes'], 19)
        self.assertEqual(result['additional_supplied_initialized_bytes'], 5)
        self.assertEqual(result['additional_supplied_code_bytes'], 5)
        self.assertEqual(result['rebuilt_source_bytes_added'], 0)
        self.assertEqual(result['complete_source_contributions_added'], 0)
        with self.assertRaises(ValueError):
            api.coverage_totals(ranges + [ranges[0]], accepted)
        with self.assertRaises(ValueError):
            api.coverage_totals(ranges, [dict(accepted[0], size=1)])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib').is_file(),
                     'private original target and stock compiler libraries required')
class NativeRuntimeInventoryTests(unittest.TestCase):
    api = RuntimeInventoryTests.api

    def test_two_fixed_105_members_require_complete_bytes_fixups_and_aliases(self):
        api = self.api()
        library = 'toolchains/watcom-10.5/LIB386/DOS/clib3r.lib'
        self.assertIn(library, api.LIBRARIES,
                      'fixed 10.5 whole-member dependency missing')
        raw = (ROOT/library).read_bytes()
        archive = api.read_archive(raw)
        image = api.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        selected = {s['name']: s for s in api.SELECTED[library]}
        self.assertTrue({'vprintf', 'nrealloc'}.issubset(selected))
        cases = [('vprintf', 591233, 17, 2, {'vprintf_'}),
                 ('nrealloc', 591259, 158, 9, {'realloc_', '_nrealloc_'})]
        for name, base, size, fixups, exports in cases:
            spec = selected[name]
            member = api.select_member(raw, archive, spec)
            module = api.Module.parse(raw[member['offset']:member['end']])
            inferred = api.infer_bindings(module, image, 1, base)
            proof = api.native_gate(module, image, inferred, spec['expected'])
            with self.subTest(member=name):
                self.assertEqual((proof['initialized_bytes'], proof['zero_fill_bytes'],
                                  proof['verified_fixups']), (size, 0, fixups))
                self.assertEqual(module.publics, {n: (1, 0) for n in exports})
                self.assertEqual({n: api.external_anchor_bindings(proof)[n] for n in exports},
                                 {n: (1, base) for n in exports})
                self.assertFalse(module.local_publics)
                self.assertFalse(module.local_externals)
                self.assertEqual(inferred['placements'], {1: (1, base)})
            # Complete CODE includes literal bytes, tails and original fixup addends.
            for offset in range(size):
                broken = copy.deepcopy(module); broken.segments[0].data[offset] ^= 1
                with self.subTest(member=name, byte=offset), self.assertRaises(ValueError):
                    api.native_gate(broken, image, inferred, spec['expected'])
            for n, f in enumerate(module.fixups):
                broken = copy.deepcopy(module)
                broken.fixups[n] = replace(f, displacement=f.displacement+1)
                with self.subTest(member=name, fixup=n), self.assertRaises(ValueError):
                    api.native_gate(broken, image, inferred, spec['expected'])
            for export in exports:
                wrong = copy.deepcopy(inferred); wrong['symbols'][export] = (1, base+1)
                with self.subTest(member=name, export=export), self.assertRaises(ValueError):
                    api.native_gate(module, image, wrong, spec['expected'])
            for nomination in (base-1, base+1):
                with self.subTest(member=name, nomination=nomination), self.assertRaises(ValueError):
                    wrong = api.infer_bindings(module, image, 1, nomination)
                    api.native_gate(module, image, wrong, spec['expected'])
            wrong = copy.deepcopy(inferred); wrong['placements'][1] = (1, base+1)
            with self.assertRaises(ValueError):
                api.native_gate(module, image, wrong, spec['expected'])
            broken = copy.deepcopy(module); broken.segments[0].size -= 1
            broken.segments[0].data = broken.segments[0].data[:-1]
            with self.assertRaises(ValueError):
                api.native_gate(broken, image, inferred, spec['expected'])
            for change in ({'offset': spec['offset']+1}, {'size': spec['size']-1},
                           {'sha256': '0'*64}, {'name': 'other'}):
                with self.subTest(member=name, identity=change), self.assertRaises(ValueError):
                    api.select_member(raw, archive, dict(spec, **change))
        target = (ROOT/'reference/DUKE3D.EXE').read_bytes()
        libraries = {n: (ROOT/n).read_bytes() for n in api.LIBRARIES}
        for changed in ('bytes', 'missing', 'alternative'):
            wrong = dict(libraries)
            if changed == 'bytes':
                damaged = bytearray(raw); damaged[73808+20] ^= 1
                wrong[library] = bytes(damaged)
            elif changed == 'missing':
                del wrong[library]
            else:
                wrong[library] = (ROOT/'toolchains/watcom-10.6/LIB386/DOS/clib3r.lib').read_bytes()
            with self.subTest(library=changed), self.assertRaisesRegex(ValueError, 'identity'):
                api.inventory(target, wrong, {'ranges': []})

    def test_stack_initializer_requires_unique_edge_and_whole_original_member(self):
        api=self.api()
        self.assertTrue(hasattr(api,'nominate_stk_initializer'),
                        'strict stack initializer nomination missing')
        raw=(ROOT/'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib').read_bytes()
        module=api.Module.parse(raw[86368:86808])
        image=api.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        inferred=api.infer_bindings(module,image,1,590832)
        nomination=api.nominate_stk_initializer(module,image,inferred)
        self.assertEqual((nomination['segment'],nomination['value']),(4,(3,73220)))
        placed=copy.deepcopy(inferred);placed['placements'][4]=nomination['value']
        expected={'initialized_bytes':98,'zero_fill_bytes':0,'verified_fixups':6}
        proof=api.native_gate(module,image,placed,expected,group_frames={1:(3,0)})
        self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),(98,6))
        self.assertEqual(proof['publics']['__CHK'],(1,590840))
        for segment,offset in ((1,71),(2,0),(2,19),(4,0),(4,1),(4,2),(4,5)):
            broken=copy.deepcopy(module);broken.segments[segment-1].data[offset]^=1
            with self.subTest(segment=segment,offset=offset),self.assertRaises(ValueError):
                api.native_gate(broken,image,placed,expected,group_frames={1:(3,0)})
        for n,f in enumerate(module.fixups):
            broken=copy.deepcopy(module);broken.fixups[n]=replace(f,displacement=1)
            with self.subTest(fixup=n),self.assertRaises(ValueError):
                api.native_gate(broken,image,placed,expected,group_frames={1:(3,0)})
        for frames in (None,{1:(1,0)},{1:(3,2)}):
            with self.subTest(frames=frames),self.assertRaises(ValueError):
                api.native_gate(module,image,placed,expected,group_frames=frames)
        edges=list(image.read_fixups())
        edge=next(e for e in edges if (e.source_object,e.source_offset)==(3,73222))
        for wrong in ([e for e in edges if e!=edge],
                      edges+[replace(edge,source_offset=73228)],
                      [replace(e,alias=True) if e==edge else e for e in edges]):
            with self.subTest(edges=len(wrong)),patch.object(image,'read_fixups',return_value=wrong),self.assertRaises(ValueError):
                api.nominate_stk_initializer(module,image,inferred)
        broken=copy.deepcopy(module)
        i=next(i for i,f in enumerate(broken.fixups) if f.segment==4)
        broken.fixups[i]=replace(broken.fixups[i],target=2)
        with self.assertRaises(ValueError):api.nominate_stk_initializer(broken,image,inferred)
        # A header is not part of the edge nomination; the full gate above must
        # still reject its changed byte rather than crediting the pointer alone.
        broken=copy.deepcopy(module);broken.segments[3].data[1]^=1
        self.assertEqual(api.nominate_stk_initializer(broken,image,inferred)['value'],(3,73220))

    def test_six_additional_members_require_complete_native_gates(self):
        api=self.api()
        report=api.inventory((ROOT/'reference/DUKE3D.EXE').read_bytes(),
            {name:(ROOT/name).read_bytes() for name in api.LIBRARIES}, {'ranges':[]})
        expected={'find386':(130,4),'strerror':(408,18),'vsprintf':(40,2),
                  'inirt386':(154,4),'floor':(68,2),'math2err':(429,29)}
        rows={r['name']:r for r in report['components'] if r['name'] in expected}
        self.assertEqual(set(rows),set(expected))
        for name,(size,fixups) in expected.items():
            row=rows[name];proof=row['verification']
            with self.subTest(member=name):
                self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),
                                 (size,fixups))
                self.assertEqual(row['rebuilt_source_credit'],0)
                self.assertFalse(row['discovery']['location_scan_is_proof'])
        self.assertEqual(rows['math2err']['placements'][2],(3,28864))
        self.assertEqual(rows['math2err']['verification']['group_frames'],{1:(3,0)})
        self.assertEqual(rows['find386']['verification']['group_frames'],{1:(3,0)})
        self.assertEqual({r['name'] for r in report['blockers']},{'seg386'})

    def test_math_error_pool_pointer_and_group_constraints_are_not_masks(self):
        api=self.api()
        library='toolchains/watcom-10.0-ga/LIB386/math387r.lib'
        selected={r['name']:r for r in api.SELECTED[library]}
        self.assertIn('math2err',selected)
        spec=selected['math2err'];raw=(ROOT/library).read_bytes()
        module=api.Module.parse(raw[spec['offset']:spec['offset']+spec['size']])
        image=api.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        inferred=api.infer_bindings(module,image,1,623887)
        inferred['placements'][2]=(3,28864)
        proof=api.native_gate(module,image,inferred,spec['expected'],group_frames={1:(3,0)})
        self.assertEqual((proof['initialized_bytes'],proof['verified_fixups']),(429,29))
        for segment,last in ((1,228),(2,107),(4,91)):
            damaged=copy.deepcopy(module);damaged.segments[segment-1].data[last]^=1
            with self.subTest(segment=segment),self.assertRaises(ValueError):
                api.native_gate(damaged,image,inferred,spec['expected'],group_frames={1:(3,0)})
        for placement in ((3,28865),None):
            wrong=copy.deepcopy(inferred)
            if placement is None:del wrong['placements'][2]
            else:wrong['placements'][2]=placement
            with self.subTest(pool=placement),self.assertRaises(ValueError):
                api.native_gate(module,image,wrong,spec['expected'],group_frames={1:(3,0)})
        with self.assertRaises(ValueError):
            api.native_gate(module,image,inferred,spec['expected'])
        with self.assertRaises(ValueError):
            api.native_gate(module,image,inferred,spec['expected'],group_frames={1:(1,0)})

    def test_complete_emu387_member_and_verified_hook_dependency(self):
        api = self.api()
        library = 'toolchains/watcom-10.0-ga/LIB386/DOS/emu387.lib'
        self.assertIn(library, api.LIBRARIES, 'whole supplied emulator is not registered')
        spec, = api.SELECTED[library]
        raw = (ROOT/library).read_bytes()
        member = api.select_member(raw, api.read_archive(raw), spec)
        module = api.Module.parse(raw[member['offset']:member['end']])
        image = api.LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        bound = api.infer_bindings(module, image, 1, spec['code_offset'])
        proof = api.native_gate(module, image, bound, spec['expected'], group_frames=spec['group_frames'])
        self.assertEqual((proof['initialized_bytes'], proof['zero_fill_bytes'], proof['verified_fixups']), (12960, 0, 692))
        self.assertEqual([(s.name, s.size) for s in module.segments], [('_DATA',122),('_TEXT',12838)])
        self.assertEqual(bound['placements'], {1:(3,72920),2:(1,610168)})
        self.assertEqual(proof['publics']['__GETDS'], (1,586216))
        # Existing independently verified hook pointer identifies __int7.
        hook_library = 'toolchains/watcom-10.5/LIB386/DOS/clib3r.lib'
        hook = next(x for x in api.SELECTED[hook_library] if x['name']=='hook387')
        data = (ROOT/hook_library).read_bytes()
        entry = api.select_member(data, api.read_archive(data), hook)
        owner = api.Module.parse(data[entry['offset']:entry['end']])
        placed = api.infer_bindings(owner,image,1,hook['code_offset'])
        hp = api.native_gate(owner,image,placed,hook['expected'],group_frames=hook.get('group_frames'))
        self.assertEqual(proof['publics']['__int7'], hp['publics']['__int7'])
        self.assertEqual(proof['publics']['__int7'],(1,611168))
        for kind in ['first-F0-addend','second-callee','CODE-tail','DATA-tail','public','group']:
            broken=copy.deepcopy(module); bindings=copy.deepcopy(bound); frames=spec['group_frames']
            if kind=='first-F0-addend': broken.segments[1].data[1134]=1
            elif kind=='second-callee': bindings['symbols']['__GETDS']=(1,586217)
            elif kind=='CODE-tail': broken.segments[1].data[-1]^=1
            elif kind=='DATA-tail': broken.segments[0].data[-1]^=1
            elif kind=='public': bindings['symbols']['__int7']=(1,611169)
            else: frames={1:(1,0)}
            with self.subTest(kind=kind),self.assertRaises(ValueError):
                api.native_gate(broken,image,bindings,spec['expected'],group_frames=frames)

    def test_selected_complete_members_and_identity_damage(self):
        api = self.api()
        target = (ROOT/'reference/DUKE3D.EXE').read_bytes()
        libraries = {name: (ROOT/name).read_bytes() for name in api.LIBRARIES}
        # Empty diagnostic ranges require no controller output for native replay.
        report = api.inventory(target, libraries, {'ranges': []})
        self.assertEqual(report['totals']['verified_members'], 134)
        self.assertEqual(report['totals']['initialized_bytes'], 42481)
        self.assertEqual(report['totals']['code_bytes'], 40883)
        self.assertEqual(report['totals']['verified_fixups'], 1404)
        self.assertEqual(report['totals']['zero_fill_bytes'], 268)
        self.assertEqual(report['totals']['overlap_initialized_bytes'], 62)
        self.assertEqual(report['totals']['additional_supplied_initialized_bytes'], 42419)
        self.assertEqual(report['totals']['additional_supplied_code_bytes'], 40825)
        self.assertEqual(report['totals']['complete_source_contributions_added'], 0)
        rand = next(m for m in report['components'] if m['name'] == 'rand')
        self.assertEqual(rand['source_status'], 'supplied original stock toolchain component')
        self.assertEqual(rand['verification']['local_symbols'],
                         {'_next': (3, 71832), 'initrandnext_': (1, 583791)})
        self.assertNotIn('_next', rand['external_anchor_bindings'])
        self.assertNotIn('initrandnext_', rand['external_anchor_bindings'])
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(len(report['blockers']), 1)
        for case in ('target', 'library'):
            damaged_target = bytearray(target); damaged_libraries = dict(libraries)
            if case == 'target': damaged_target[-1] ^= 1
            else:
                name = next(iter(libraries)); raw = bytearray(libraries[name]); raw[40] ^= 1
                damaged_libraries[name] = bytes(raw)
            with self.subTest(case=case), self.assertRaisesRegex(ValueError, 'identity'):
                api.inventory(bytes(damaged_target), damaged_libraries, {'ranges': []})
        with self.assertRaisesRegex(ValueError, 'identity'):
            api.inventory(target[:-1], libraries, {'ranges': []})

    def test_native_whole_member_tail_public_callee_and_extent_damage(self):
        api = self.api()
        from tools.prove_module import Module, LEImage
        from tools.infer_bindings import infer_bindings
        target = LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        library = 'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib'
        raw = (ROOT/library).read_bytes(); archive = api.read_archive(raw)
        spec = next(m for m in api.SELECTED[library] if m['name'] == 'rand')
        api.select_member(raw, archive, spec)
        module = Module.parse(raw[spec['offset']:spec['offset']+spec['size']])
        inferred = infer_bindings(module, target, 1, spec['code_offset'])
        baseline = api.native_gate(module, target, inferred, spec['expected'])
        self.assertEqual((baseline['initialized_bytes'], baseline['verified_fixups']), (62, 3))
        for segment, offset in ((1, 57), (4, 3)):
            broken = copy.deepcopy(module); broken.segments[segment-1].data[offset] ^= 1
            with self.subTest(segment=segment), self.assertRaises(ValueError):
                api.native_gate(broken, target, inferred, spec['expected'])
        broken = copy.deepcopy(module)
        broken.fixups[1] = replace(broken.fixups[1], displacement=1)
        with self.assertRaises(ValueError):
            api.native_gate(broken, target, inferred, spec['expected'])
        for name in module.publics:
            wrong = copy.deepcopy(inferred); obj, off = wrong['symbols'][name]
            wrong['symbols'][name] = (obj, off+1)
            with self.subTest(public=name), self.assertRaises(ValueError):
                api.native_gate(module, target, wrong, spec['expected'])
        broken = copy.deepcopy(module); broken.segments[0].size -= 1
        broken.segments[0].data = broken.segments[0].data[:-1]
        with self.assertRaises(ValueError):
            api.native_gate(broken, target, inferred, spec['expected'])
        missing = copy.deepcopy(inferred); del missing['placements'][4]
        with self.assertRaises(ValueError):
            api.native_gate(module, target, missing, spec['expected'])


if __name__ == '__main__':
    unittest.main()
