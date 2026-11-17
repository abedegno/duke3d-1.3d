"""Whole source-built MACT RNG, with private scope and zero-fill obligations."""
from copy import deepcopy
import hashlib
import importlib
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT),str(ROOT/'profiles/watcom/tools')]
from omf32 import Module
from le import LEImage
from tools.verify_module import verify_module, external_anchor_bindings


class MactRandomTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.workspace=tempfile.TemporaryDirectory(prefix='mact-random-test-')
        cls.build=Path(cls.workspace.name)

    @classmethod
    def tearDownClass(cls): cls.workspace.cleanup()

    def producer(self):
        self.assertTrue((ROOT/'tools/probe_mact_random.py').is_file(),
                        'complete MACT RNG source producer unavailable')
        return importlib.import_module('tools.probe_mact_random')

    def report(self):
        if not hasattr(self.__class__,'fresh_report'):
            self.__class__.fresh_report=self.producer().probe(
                ROOT/'toolchains/watcom-10.0-ga',self.build/'positive')
        return self.__class__.fresh_report

    def test_complete_native_source_contribution(self):
        report=self.report();v=report['verification']
        self.assertTrue(v['verified'])
        self.assertEqual((v['initialized_bytes'],v['verified_fixups'],v['zero_fill_bytes']),
                         (2279,13,4))
        self.assertEqual([(s['target_object'],s['target_offset'],s['compared_bytes'])
                          for s in v['segments']],[(1,564800,227),(3,68356,2052),(3,2129488,4)])
        self.assertEqual(v['local_symbols'],{'_rndindex':(3,2129488),'_sndindex':(3,70404)})
        self.assertEqual(set(external_anchor_bindings(v)),{
            'GetRandomNumberSeed_','InitializeRandomNumberGenerator_',
            'SetRandomNumberIndex_','GetRandomNumberIndex_','GameRandom_','Random_',
            '_RandomTable','_dos_gettime_'})
        self.assertEqual(report['source_geometry']['segments'][-1]['attributes'],0xa9)
        self.assertEqual(report['reference_geometry']['bss_attributes'],0x69)
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertIn('profiles/watcom/tools/omf32.py',report['proof_tools_sha256'])
        self.assertIn('0 warnings, 0 errors',(self.build/'positive/mact_random.log').read_text())

    def test_actual_source_and_primary_header_corruptions_reject(self):
        producer=self.producer()
        source=(ROOT/'src/mact/random.c').read_text()
        changes=[
            ('time-field','clock.minute * clock.second','clock.hour * clock.second'),
            ('seed-operation','clock.minute * clock.second','clock.minute + clock.second'),
            ('dos-api','_dos_gettime(&clock);','_dos_settime(&clock);'),
            ('modulus','% SIZE_OF_RANDOM_TABLE','% (SIZE_OF_RANDOM_TABLE-1)'),
            ('increment','rndindex+1','rndindex+2'),
            ('mask','rndindex=(rndindex+1)&(SIZE_OF_RANDOM_TABLE-1);',
                    'rndindex=(rndindex+1)&(SIZE_OF_RANDOM_TABLE-2);'),
            ('state','return RandomTable[sndindex];','return RandomTable[rndindex];'),
            ('return-width','unsigned char GameRandom','int GameRandom'),
            ('index-scope','static int rndindex;','int rndindex;'),
            ('sound-initializer','static int sndindex=0;','static int sndindex=1;'),
            ('rnd-file-backing','static int rndindex;','static int rndindex=1;'),
        ]
        with tempfile.TemporaryDirectory(prefix='mact-random-source-') as temporary:
            stage=Path(temporary)
            for name in ('src/mact/random/include','modules','evidence','reference'):
                (stage/name).mkdir(parents=True,exist_ok=True)
            for name in ('src/mact/random/include/_rt_rand.h','modules/mact_random.json',
                         'evidence/mact-random-source-reference.json'):
                shutil.copyfile(ROOT/name,stage/name)
            (stage/'reference/DUKE3D.EXE').symlink_to(ROOT/'reference/DUKE3D.EXE')
            for name,old,new in changes:
                with self.subTest(name=name):
                    self.assertEqual(source.count(old),1)
                    (stage/'src/mact/random.c').write_text(source.replace(old,new,1))
                    with patch.object(producer,'ROOT',stage), self.assertRaises(ValueError):
                        producer.probe(ROOT/'toolchains/watcom-10.0-ga',stage/name)
            (stage/'src/mact/random.c').write_text(source)
            header=(ROOT/'src/mact/random/include/_rt_rand.h').read_text()
            import re
            match=re.search(r'(RandomTable\s*\[[^]]+\]\s*=\s*\{\s*)(\d+)',header)
            wrong=str(int(match.group(2))^1)
            (stage/'src/mact/random/include/_rt_rand.h').write_text(
                header[:match.start(2)]+wrong+header[match.end(2):])
            with patch.object(producer,'ROOT',stage), self.assertRaisesRegex(ValueError,'differing bytes'):
                producer.probe(ROOT/'toolchains/watcom-10.0-ga',stage/'table')

    def test_native_tails_bindings_scopes_and_zero_fill_reject(self):
        producer=self.producer();report=self.report()
        module=Module.parse((self.build/'positive/mact_random.obj').read_bytes())
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for segment,offset in ((1,0),(1,226),(4,0),(4,1024),(4,2047),(4,2048),(5,0)):
            with self.subTest(segment=segment,offset=offset):
                bad=deepcopy(module);bad.segments[segment-1].data[offset]^=1
                with self.assertRaises(ValueError):
                    verify_module(bad,image,report['placements'],report['symbols'])
        spec=json.loads((ROOT/'modules/mact_random.json').read_text())
        for kind in ('global-index','local-table','external-scope','shift-public','extent'):
            bad=deepcopy(module)
            if kind=='global-index':bad.local_publics.remove('_rndindex')
            elif kind=='local-table':bad.local_publics.add('_RandomTable')
            elif kind=='external-scope':bad.local_externals.clear()
            elif kind=='shift-public':bad.publics['Random_']=(1,205)
            else:bad.segments[0].size-=1
            with self.subTest(kind=kind),self.assertRaises(ValueError):producer.check_module(bad,spec)
        for name,value in (('_dos_gettime_',(1,591196)),('_RandomTable',(3,68357))):
            symbols=dict(report['symbols']);symbols[name]=value
            with self.subTest(symbol=name),self.assertRaises(ValueError):
                verify_module(module,image,report['placements'],symbols)
        placements=deepcopy(report['placements']);placements[5]=(3,2129489)
        with self.assertRaises(ValueError):verify_module(module,image,placements,report['symbols'])
        bss=deepcopy(module);bss.segments[0].size=0;bss.segments[3].size=0
        bss.publics={'_rndindex':(5,0)}
        with self.assertRaisesRegex(ValueError,'file backing'):
            verify_module(bss,image,{5:(3,68356)},{})

    def test_descriptor_contract_rejects_numeric_and_scope_damage(self):
        producer=self.producer();self.report()
        module=Module.parse((self.build/'positive/mact_random.obj').read_bytes())
        spec=json.loads((ROOT/'modules/mact_random.json').read_text())
        cases=[]
        for field,value in [('expected_local_publics',None),('expected_local_externals',[]),
                            ('expected_externals',[]),('expected_segments',[])]:
            bad=deepcopy(spec);bad[field]=value;cases.append(bad)
        for value in (1.0,True,'1'):
            bad=deepcopy(spec);bad['expected_publics']['Random_'][0]=value;cases.append(bad)
        for bad in cases:
            with self.subTest(bad=bad),self.assertRaises(ValueError):producer.check_module(module,bad)

    def test_tracked_primary_lineage_and_standalone_build_inputs(self):
        producer=self.producer();self.report()
        record=json.loads((ROOT/'evidence/mact-random-source-reference.json').read_text())
        self.assertEqual(record['primary_source']['files']['rott/_RT_RAND.H'],
                         '2c148310adb7d153d70aa9162f63538ccacb5d5e4e870e6cb963101670711c41')
        for name,expected in record['headers'].items():
            self.assertEqual(hashlib.sha256((ROOT/name).read_bytes()).hexdigest(),expected)
        self.assertFalse(record['original_reference']['used_as_build_output'])
        self.assertFalse(record['byte_return']['historical_signedness_proved'])
        # Only owned tracked source/descriptor/provenance and the target are
        # available; no MACT library, research tree or extraction stage exists.
        with tempfile.TemporaryDirectory(prefix='mact-random-standalone-') as temporary:
            stage=Path(temporary)
            for name in ('src/mact/random.c','src/mact/random/include/_rt_rand.h',
                         'modules/mact_random.json','evidence/mact-random-source-reference.json'):
                path=stage/name;path.parent.mkdir(parents=True,exist_ok=True)
                shutil.copyfile(ROOT/name,path)
            (stage/'reference').mkdir()
            (stage/'reference/DUKE3D.EXE').symlink_to(ROOT/'reference/DUKE3D.EXE')
            with patch.object(producer,'ROOT',stage):
                result=producer.probe(ROOT/'toolchains/watcom-10.0-ga',stage/'fresh')
            self.assertEqual(result['verification'],self.report()['verification'])

    def test_producer_rejects_malformed_descriptor_values(self):
        producer=self.producer()
        spec=json.loads((ROOT/'modules/mact_random.json').read_text())
        cases=[{'code_bytes':227.0},{'code_publics':6.0},
               {'symbol_anchors':{'_dos_gettime_':[True,591195]}},
               {'expected':{**spec['expected'],'zero_fill_bytes':4.0}}]
        with tempfile.TemporaryDirectory(prefix='mact-random-spec-') as temporary:
            stage=Path(temporary)
            for name in ('src/mact/random.c','src/mact/random/include/_rt_rand.h',
                         'modules/mact_random.json','evidence/mact-random-source-reference.json'):
                path=stage/name;path.parent.mkdir(parents=True,exist_ok=True)
                shutil.copyfile(ROOT/name,path)
            (stage/'reference').mkdir()
            (stage/'reference/DUKE3D.EXE').symlink_to(ROOT/'reference/DUKE3D.EXE')
            for changes in cases:
                candidate=deepcopy(spec);candidate.update(changes)
                (stage/'modules/mact_random.json').write_text(json.dumps(candidate))
                with self.subTest(changes=changes),patch.object(producer,'ROOT',stage),self.assertRaises(ValueError):
                    producer.probe(ROOT/'toolchains/watcom-10.0-ga',stage/'fresh')


if __name__=='__main__':unittest.main()
