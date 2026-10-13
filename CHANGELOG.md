# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- `LoadConcreteMemory` option to load concrete values from the binary (e.g., globals) ([#38](https://github.com/vusec/inspectre-gadget/pull/38))
- Reasoner support for user-space programs: `reasoner` config section with `AllowKernelAddresses` and `AllowUserAddresses` (`inspectre reason --config`) ([#39](https://github.com/vusec/inspectre-gadget/pull/39))
- Reasoner support for secret dependent branches (SDB), results in the `exploitable_w_sdb` columns ([#40](https://github.com/vusec/inspectre-gadget/pull/40))

### Changed

- Gadgets whose base has an indirect secret dependency (`base_has_indirect_secret_dependency`) are now not exploitable by default

## [1.2.0] - 2026-10-09

After the InSpectre Gadget paper release, many features were added and bugs fixed.
Please check the git commit logs to see all changes up to now.

The most important features added:

- Half-Spectre gadget support ([#28](https://github.com/vusec/inspectre-gadget/pull/28))
- Aggressive speculation feature ([#29](https://github.com/vusec/inspectre-gadget/pull/29))
- Reasoner support for dispatch gadgets ([#32](https://github.com/vusec/inspectre-gadget/pull/32))
- Secret dependent branch (SDB) covert-channel support ([#33](https://github.com/vusec/inspectre-gadget/pull/33))

[Unreleased]: https://github.com/vusec/inspectre-gadget/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/vusec/inspectre-gadget/compare/v1.1...v1.2.0
