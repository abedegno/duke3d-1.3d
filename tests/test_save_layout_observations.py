from pathlib import Path
import unittest
from dataclasses import replace
from tools.inspect_save_layout import ROOT,observe,decode_packet
from le import LEImage


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file(),'private target required')
class SaveLayoutTests(unittest.TestCase):
    def test_explicit_record_extents_distinguish_engine_and_game_arrays(self):
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        result=observe(image)
        records={r['address']:r for r in result['constant_pointer_records']}
        for address,size,count in [(1104832,44,4096),(120728,71,2048),
                                   (376112,1362,16),(375856,16,16),
                                   (287488,4,20000),(266136,4,4096),
                                   (410192,2,64)]:
            self.assertEqual((records[address]['item_size'],records[address]['count']),(size,count))
        self.assertEqual(result['write_calls'],56)
        reads={r['address']:r for r in result['reader']['constant_pointer_records']}
        for address in [1104832,120728,376112,287488,266136,410192]:
            self.assertEqual((reads[address]['item_size'],reads[address]['count']),
                             (records[address]['item_size'],records[address]['count']))
        self.assertEqual(result['matching_reader_writer_records'],47)
        self.assertFalse(result['full_module_verified'])
        self.assertFalse(result['full_executable_rebuilt'])
        self.assertEqual(result['new_recovered_contributions'],0)
        self.assertEqual(records[376112]['address']+1362*16,397904)
        code=image.object_bytes(1)
        fixups={(f.source_object,f.source_offset):f for f in image.read_fixups()}
        record=records[376112]
        broken=dict(fixups);del broken[(1,record['pointer_operand'])]
        with self.assertRaisesRegex(ValueError,'pointer fixup'):
            decode_packet(code,record['call_offset'],broken)
        pointer=fixups[(1,record['pointer_operand'])]
        for offset in [record['packet_offset']-1,record['packet_offset']+2,
                       record['packet_offset']+7,record['pointer_operand']+1,
                       record['call_offset']+2]:
            broken=dict(fixups);broken[(1,offset)]=replace(pointer,source_offset=offset)
            with self.subTest(overlapping_fixup=offset),self.assertRaisesRegex(ValueError,'overlap'):
                decode_packet(code,record['call_offset'],broken)
