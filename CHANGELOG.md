# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
To be tagged as v`1.0.0`
### Changed
- organized files under `src/` directory
- moved old scripts under `legacy/` directory
- region scripts: can modify/manipulate "pasted" regions, work with subregions etc
### Added
- `GUI` mini framework under `src/aod/gui/v1`
- `command palette` script
  - can search through actions (only main window for now, easy to extend)
  - can run actions on certain triggers (eg on item selection change, every 2 seconds etc)
- midi item to items arrangement conversion (to be documented)
### TODO
- document midi item to arrangement script
- add inverse arrangement to midi item script
- video demonstrating region items

## [0.1.0] - 2017-12-25
The old state

[unreleased]: https://github.com/actonDev/Reaper-Scripts/compare/master...develop
[0.1.0] https://github.com/actonDev/Reaper-Scripts/tree/0.1.0