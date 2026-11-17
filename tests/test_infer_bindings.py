import unittest
import test_verify_module as fixtures
from tools.infer_bindings import infer_bindings, BindingError


class BindingTests(unittest.TestCase):
    def test_infers_data_placement_from_relocated_public(self):
        mod,image,_=fixtures.ModuleProofTests().fixture()
        report=infer_bindings(mod,image,1,0)
        self.assertEqual(report['symbols']['_value'],(1,8))
        self.assertEqual(report['placements'],{1:(1,0),2:(1,8)})
        self.assertEqual(report['unplaced_segments'],[3])

    def test_disagreement_with_known_symbol_is_failure(self):
        mod,image,_=fixtures.ModuleProofTests().fixture()
        with self.assertRaises(BindingError):
            infer_bindings(mod,image,1,0,known_symbols={'_value':(1,9)})
