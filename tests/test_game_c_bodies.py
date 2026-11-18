"""Native C proofs distinguish function bodies from following CODE tables."""
from pathlib import Path
import hashlib
import json
import shutil
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT / 'profiles/watcom/tools')]
from runner import compile_source
from omf32 import Module
from le import LEImage
from tools.match_function import compare_range, match_function
from tools.build_game_compound import prepare_live_headers, OPTIONS, SOURCE


class GameCFunctionBodies(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.home = ROOT / 'toolchains/watcom-10.0-ga'
        cls.target = ROOT / 'reference/DUKE3D.EXE'
        if not cls.home.is_dir() or not cls.target.is_file() or not shutil.which('dosbox-x'):
            raise unittest.SkipTest('install GA/DOSBox-X and supply the original reference executable')
        raw = cls.target.read_bytes()
        if hashlib.sha256(raw).hexdigest() != 'a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4':
            raise ValueError('wrong registered v1.3D reference')
        cls.image = LEImage.parse(raw)
        (ROOT / 'build').mkdir(exist_ok=True)
        cls.temp = tempfile.TemporaryDirectory(prefix='game-c-body-tests-', dir=ROOT / 'build')
        cls.work = Path(cls.temp.name)
        cls.headers = cls.work / 'include'
        prepare_live_headers(cls.headers)
        cls.source = (ROOT / SOURCE).read_text()
        compile_source(cls.home, ROOT / SOURCE, cls.work / 'GAME.OBJ', OPTIONS, 60, include_dirs=[cls.headers])
        cls.full = Module.parse((cls.work / 'GAME.OBJ').read_bytes())
        cls.sprite = tuple(json.loads((ROOT / 'modules/gamedef.json').read_bytes())['symbol_anchors']['_sprite'])

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def standalone(self, name, body):
        source = self.work / (name + '.c')
        obj = source.with_suffix('.obj')
        source.write_text('#include "duke3d.h"\n\n' + body + '\n')
        compile_source(self.home, source, obj, OPTIONS, 60, include_dirs=[self.headers])
        return Module.parse(obj.read_bytes())

    def test_wallswitchcheck_is_complete_exact_c_not_its_following_switch_table(self):
        start = self.source.index('char wallswitchcheck(short i)')
        body = self.source[start:self.source.index('\n\nlong tempwallptr;', start)]
        standalone = self.standalone('wall', body)
        proof = match_function(standalone, 'wallswitchcheck_', self.image, 1, 31216, 160, {'_sprite': self.sprite})
        self.assertTrue(proof['match'])
        self.assertEqual(proof['verified_fixups'], 1)
        seg, at = self.full.publics['wallswitchcheck_']
        full = compare_range(self.full, seg, at, self.image, 1, 31216, 160, {'_sprite': self.sprite})
        self.assertTrue(full['match'])
        self.assertGreater(self.full.publics['spawn_'][1] - at, 160)
        with self.assertRaises(ValueError):
            match_function(standalone, 'wallswitchcheck_', self.image, 1, 31216, 160,
                           {'_sprite': (self.sprite[0], self.sprite[1] + 4)})
        wrong = self.standalone('wall_wrong', body.replace('return 1;', 'return 2;'))
        self.assertFalse(match_function(wrong, 'wallswitchcheck_', self.image, 1, 31216, 160,
                                       {'_sprite': self.sprite})['match'])


if __name__ == '__main__':
    unittest.main()
