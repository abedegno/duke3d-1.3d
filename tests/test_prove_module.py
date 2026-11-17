import unittest
from tools.prove_module import assert_contributions


class ContributionContractTests(unittest.TestCase):
    def test_incomplete_initialized_contribution_rejected(self):
        report={'verified':True,'initialized_bytes':9,'zero_fill_bytes':4,'verified_fixups':1}
        with self.assertRaises(ValueError):
            assert_contributions(report,{'initialized_bytes':10,'zero_fill_bytes':4,'verified_fixups':1})

    def test_unverified_report_rejected_even_with_right_counts(self):
        report={'verified':False,'initialized_bytes':10,'zero_fill_bytes':4,'verified_fixups':1}
        with self.assertRaises(ValueError):
            assert_contributions(report,{'initialized_bytes':10,'zero_fill_bytes':4,'verified_fixups':1})

    def test_complete_counts_accepted(self):
        report={'verified':True,'initialized_bytes':10,'zero_fill_bytes':4,'verified_fixups':1}
        assert_contributions(report,{'initialized_bytes':10,'zero_fill_bytes':4,'verified_fixups':1})
