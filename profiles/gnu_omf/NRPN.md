# Finite NRPN tool-profile extension

The original profile.json and setup receipt retain their reviewed hardware
identity without rewriting historical pins. The explicit additional NRPN
scope is recorded in nrpn-subset.json and enforced by its separate module
contract and pinned decoder profile. It reuses the same binaries/options;
the hardware-specific source grammar/guard remains unchanged. This extension
does not grant general COFF, private-symbol or ABI support.

The public source-build/setup instructions remain in README.md. Neither profile
introduces a target instruction emitter or an object patch. NRPN source alone
produces its COFF; every converter field has a checked typed source equation.
