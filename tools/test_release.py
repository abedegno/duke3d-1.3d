#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Run public release regressions without discovering imported vendor tests.

The native cases require the local dependencies described in docs/BUILDING.md.
The public source-integrity CI remains independent of those dependencies.
"""
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
PUBLIC_TESTS = (
    'test_actors_c_backend.py',
    'test_actors_omf_link.py',
    'test_game_c_bodies.py',
    'test_game_omf_link.py',
    'test_verified_snapshot.py',
    'test_complete_game_preparation.py',
    'test_complete_native_publication.py',
    'test_complete_source_build.py',
    'test_dos4gw_binding.py',
    'test_game_symbolic_preserved.py',
    'test_native_layout_integration.py',
    'test_native_layout_irq.py',
    'test_native_layout_profile.py',
    'test_native_layout_snapshot.py',
    'test_native_layout_source.py',
    'test_native_layout_writer.py',
    'test_stock_runtime_preparation.py',
    'test_unidentified_data.py',
)


def main():
    (ROOT / 'build').mkdir(exist_ok=True)
    sys.path[:0] = [str(ROOT), str(ROOT / 'tests')]
    suite = unittest.TestSuite()
    for name in PUBLIC_TESTS:
        if not (ROOT / 'tests' / name).is_file():
            raise ValueError(f'Missing public release regression: {name}')
        suite.addTests(unittest.defaultTestLoader.discover(str(ROOT / 'tests'), pattern=name))
    return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1


if __name__ == '__main__':
    sys.exit(main())
