"""GAME's byte consumer must retain PREMAP's actual native owner proof."""
from pathlib import Path
from copy import deepcopy
import json
import tempfile
import unittest
from unittest.mock import patch
from tools import probe_game

ROOT=Path(__file__).resolve().parents[1]

class GameAbortOwnerTests(unittest.TestCase):
    def setUp(self):
        self.owner=json.loads((ROOT/'evidence/premap-module.json').read_text())

    def read_peer(self,report):
        with tempfile.TemporaryDirectory(prefix='game-owner-',dir=ROOT/'build') as directory:
            root=Path(directory);(root/'evidence').mkdir()
            (root/'evidence/premap-module.json').write_text(json.dumps(report))
            with patch.object(probe_game,'ROOT',root):
                return probe_game.wait_abort_consumer_evidence()

    def test_consumer_identifies_real_public_byte_owner(self):
        result=self.read_peer(self.owner)
        self.assertTrue(result['storage_owned_by_PREMAP'])
        self.assertFalse(result['storage_owned_by_GAME'])
        self.assertEqual(result['PREMAP_owned_BSS_range_exclusive'],[587552,587557])
        self.assertEqual((result['symbol'],result['target'],result['read_width']),
                         ('_wait_abort',[3,587556],1))

    def test_external_or_private_symbol_cannot_claim_owned_storage(self):
        mutations=[lambda r:r['bss_storage']['source_symbols'].pop('_wait_abort'),
                   lambda r:r['bss_storage']['publics'].pop('_wait_abort'),
                   lambda r:r['bss_storage']['local_symbols'].update(_wait_abort=[3,587556]),
                   lambda r:r['verification']['local_symbols'].update(_wait_abort=[3,587556])]
        for mutate in mutations:
            report=deepcopy(self.owner);mutate(report)
            with self.assertRaises(ValueError):self.read_peer(report)

    def test_whole_extent_address_and_native_operand_constraints_remain_required(self):
        mutations=[lambda r:r['bss_storage'].update(zero_fill_bytes=4),
                   lambda r:r['verification'].update(zero_fill_bytes=4),
                   lambda r:r['bss_storage']['segments'][0].update(target_offset=587568),
                   lambda r:r['bss_storage']['segments'][0].update(compared_bytes=4),
                   lambda r:r['bss_storage']['source_symbols'].update(_wait_abort=5),
                   lambda r:r['verification']['publics'].update(_wait_abort=[3,587557]),
                   lambda r:r['verification'].update(verified=False),
                   lambda r:next(c for c in r['constraints'] if c.get('source_offset')==9570).update(value=[3,587557])]
        for mutate in mutations:
            report=deepcopy(self.owner);mutate(report)
            with self.assertRaises(ValueError):self.read_peer(report)

if __name__=='__main__':unittest.main()
