# SPDX-License-Identifier: GPL-2.0-or-later
"""Synthetic metadata and zero-data fixtures, never original instruction bytes."""
from pathlib import Path
import copy
import struct
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tools import actors_omf_link as link


def fixture(role):
    segments = link.C_SEGMENTS if role == 'C' else link.ASM_SEGMENTS
    names = (['', '', 'CODE', 'DATA', 'BSS', 'FLAT', 'DGROUP', '_TEXT', 'CONST', 'CONST2', '_DATA', '_BSS']
             if role == 'C' else ['', '', '_TEXT', 'CODE', 'CONST', 'DATA'])
    ni = {n: i for i, n in enumerate(names)}
    out = bytearray(link.record(0x80, link.name('SYNTHETIC')))
    out += link.record(0x96, b''.join(link.name(n) for n in names[1:]))
    for n, k, size, attrs in segments:
        width = 4 if role == 'C' else 2
        out += link.record(0x99 if role == 'C' else 0x98,
                           bytes([attrs]) + size.to_bytes(width, 'little') +
                           link.idx(ni[n]) + link.idx(ni[k]) + link.idx(1))
    if role == 'C':
        out += link.record(0x9a, link.idx(ni['DGROUP']) + b''.join(b'\xff' + link.idx(i) for i in (2, 3, 4, 5)))
        out += link.record(0x9a, link.idx(ni['FLAT']))
    count = 119 if role == 'C' else 62
    for i in range(1, count + 1):
        local = role == 'C' and i == 16
        n = '_radius_status_record' if local else 'synthetic_external_' + str(i)
        out += link.record(0xb4 if local else 0x8c, link.name(n) + b'\0')
    publics = link.C_PUBLICS if role == 'C' else {'moveeffectors_': (1, 12)}
    for n, (seg, at) in publics.items():
        group = (2 if seg == 1 else 1) if role == 'C' else 0
        kind = 0xb7 if n in link.C_PRIVATE else 0x91
        out += link.record(kind, link.idx(group) + link.idx(seg) + link.name(n) + struct.pack('<I', at) + b'\0')
    if role == 'C':
        comments = [(128, 170, b'OS220'), (128, 155, b'3fOp'),
                    (128, 254, b'D\1\0C'), (128, 254, b'O\1'),
                    (128, 253, b'S\1' + struct.pack('<II', 0, 24))]
        comments += [(128, 233, b'\0' * 4 + link.name('C:\\SOURCE.C'))]
        comments += [(128, 233, b'')] * 41
        comments += [(4, 0, b'\0')] * 91
        comments += [(128, 159, b'math387r'), (128, 159, b'emu387')]
    else:
        comments = [(0, 0, b'\x1dThe Netwide Assembler 2.16.03'), (64, 162, b'\1')]
    for flags, k, p in comments:
        out += link.record(0x88, bytes([flags, k]) + p)
    for sn, (_, klass, size, _) in enumerate(segments, 1):
        if klass == 'BSS':
            continue
        for at in range(0, size, 1024):
            n = min(1024, size - at)
            out += link.record(0xa1, link.idx(sn) + struct.pack('<I', at) + bytes(n))
            if sn == 1 and at == 0:
                # One finite flat32 external field, and one section-local table
                # field; each contributes every addend to the semantic graph.
                frame = 0x10 if role == 'C' else 0x50
                f = b'\xe4\x20' + bytes([frame | 6])
                if role == 'C':
                    f += b'\2'
                f += b'\1'
                f += b'\xe4\x40' + bytes([frame | 4])
                if role == 'C':
                    f += b'\2'
                f += b'\1'
                out += link.record(0x9d, f)
    out += link.record(0x8a, b'\0')
    return bytes(out)


def mutate(raw, kind, operation, occurrence=0):
    out = bytearray()
    seen = 0
    changed = False
    for t, p in link.records(raw):
        if t == kind and seen == occurrence:
            t, p = operation(t, bytearray(p))
            changed = True
        if t == kind:
            seen += 1
        out += link.record(t, p)
    assert changed
    return bytes(out)


class ActorsOmfLinkTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.c, cls.asm = fixture('C'), fixture('ASM')

    def rejects_input(self, raw, role='ASM'):
        with self.assertRaises(ValueError):
            link.coalesce([self.c, raw] if role == 'ASM' else [raw, self.asm])

    def test_synthetic_source_link_and_repacketization(self):
        m, comments, contributions = link.coalesce([self.c, self.asm])
        normal = link.serialize(m, comments, link.source_packets([self.c, self.asm]))
        self.assertEqual(link.verify_roundtrip(m, normal)['typed_fixups'], 4)
        spans = [(at, min(512, 61674 - at)) for at in range(0, 61674, 512)]
        planned = link.repacketize(normal, spans)
        self.assertEqual(link.graph(link.Module.parse(normal)), link.graph(link.Module.parse(planned)))
        self.assertEqual(sum(x['size'] for x in contributions), 61747)
        self.assertEqual(link.Module.parse(planned).local_publics, link.C_PRIVATE)

    def test_use16_rejected(self):
        self.rejects_input(mutate(self.asm, 0x98, lambda t, p: (t, bytes([p[0] & ~1]) + p[1:])))

    def test_private_combine_rejected(self):
        self.rejects_input(mutate(self.asm, 0x98, lambda t, p: (t, bytes([p[0] & ~0x1c]) + p[1:])))

    def test_page_alignment_rejected(self):
        self.rejects_input(mutate(self.asm, 0x98, lambda t, p: (t, bytes([(p[0] & 31) | 0x80]) + p[1:])))

    def test_nonempty_overlay_rejected(self):
        self.rejects_input(mutate(self.asm, 0x98, lambda t, p: (t, p[:-1] + b'\2')))

    def test_undefined_public_group_rejected(self):
        self.rejects_input(mutate(self.asm, 0x91, lambda t, p: (t, b'\x7f' + p[1:])))

    def test_external_type_rejected(self):
        self.rejects_input(mutate(self.asm, 0x8c, lambda t, p: (t, p[:-1] + b'\1')))

    def test_public_type_rejected(self):
        self.rejects_input(mutate(self.asm, 0x91, lambda t, p: (t, p[:-1] + b'\1')))

    def test_private_public_promotion_rejected(self):
        self.rejects_input(mutate(self.c, 0xb7, lambda t, p: (0x91, p)), 'C')

    def test_private_external_promotion_rejected(self):
        self.rejects_input(mutate(self.c, 0xb4, lambda t, p: (0x8c, p)), 'C')

    def test_unsupported_comment_flags_rejected(self):
        self.rejects_input(mutate(self.asm, 0x88, lambda t, p: (t, b'\x80' + p[1:])))

    def test_code_gap_rejected(self):
        raw = b''.join(link.record(t, p) for i, (t, p) in enumerate(link.records(self.asm)) if not (t == 0xa1 and p[1:5] == struct.pack('<I', 1024)))
        self.rejects_input(raw)

    def test_code_overlap_rejected(self):
        raw = mutate(self.asm, 0xa1, lambda t, p: (t, p[:1] + b'\0' * 4 + p[5:]), occurrence=1)
        self.rejects_input(raw)

    def test_missing_output_packet_rejected(self):
        m, comments, _ = link.coalesce([self.c, self.asm])
        spans = link.source_packets([self.c, self.asm])
        with self.assertRaisesRegex(ValueError, 'incomplete CODE'):
            link.serialize(m, comments, spans[:-1])

    def test_split_field_rejected(self):
        m, comments, _ = link.coalesce([self.c, self.asm])
        spans = [(0, 34), (34, 990)] + [(at, min(1024, 61674-at)) for at in range(1024, 61674, 1024)]
        with self.assertRaisesRegex(ValueError, 'splits relocation'):
            link.serialize(m, comments, spans)

    def test_global_import_cannot_bind_other_contribution_private(self):
        raw = mutate(self.asm, 0x8c,
                     lambda t, p: (t, link.name('_radius_status_record') + b'\0'))
        with self.assertRaisesRegex(ValueError, 'global external aliases'):
            link.coalesce([self.c, raw])

    def test_local_import_requires_own_private_definition(self):
        raw = mutate(self.c, 0xb4,
                     lambda t, p: (t, link.name('moveeffectors_') + b'\0'))
        self.rejects_input(raw, 'C')

    def test_wrong_real_role_not_hidden_by_addend_graph(self):
        m, comments, _ = link.coalesce([self.c, self.asm])
        wrong = copy.deepcopy(m)
        from dataclasses import replace
        wrong.fixups[0] = replace(wrong.fixups[0], target=2)
        out = link.serialize(wrong, comments, link.source_packets([self.c, self.asm]))
        with self.assertRaisesRegex(ValueError, 'semantic graph'):
            link.verify_roundtrip(m, out)


if __name__ == '__main__':
    unittest.main()
