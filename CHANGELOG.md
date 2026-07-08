# Changelog

All notable changes to Snip will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.8.0] - 2026-07-08

### Fixed
- `CFBundleVersion` / `CFBundleShortVersionString` are now Apple-standard numeric values (the leading `v` from the release tag is stripped)
- Only a leading `www.` is stripped when resolving a URL's host for rule matching (previously `www.` was removed anywhere in the host)

### Changed
- Log subsystem now matches the bundle identifier (`com.maferland.snip`)

### Removed
- Stale top-level `VERSION` file — the version is derived from the release tag

## [2.7.0] - 2026-03-12

### Added
- LinkedIn `rcm` tracking parameter

### Changed
- Releases are now built, signed, and notarized by CI on tag push; `make release` only tags and pushes

## [2.6.0] - 2026-02-25

### Added
- Domain-family stripping for YouTube, LinkedIn, eBay, and Reddit
- Expanded global tracker list

## [2.5.0] - 2026-02-25

### Added
- Google search parameter stripping
- Expanded global tracker list

## [2.4.0] - 2026-02-25

### Added
- Wildcard strip-all rule for Amazon URLs
- Amazon search tracking parameters

### Changed
- Release workflow with ephemeral Homebrew tap update
- Extracted `RulesEditorModel`, added structured logging, removed dead code

## [2.3.0] - 2026-02-24

### Added
- Form-based rules editor with in-app JSON config
- Screenshot generator for docs

## [2.2.0] - 2026-02-24

### Added
- New app icon
- Version label in the menu bar

## [2.1.0] - 2026-02-23

### Added
- Domain-scoped tracking parameter stripping

## [2.0.0] - 2026-02-04

### Added
- Clipboard provider abstraction for better testability
- Debounce for rapid clipboard changes (prevents duplicate processing)
- Persistent settings via UserDefaults
- Case-insensitive tracking parameter matching
- Expanded test coverage

### Changed
- Rebranded from CleanCopy to Snip with new assets
- Switched to SMAppService for "Start at Login" (more reliable)
- App is now distributed as a proper `.app` bundle, signed and notarized
- Updated Homebrew cask for app bundle installation

### Fixed
- URL fragments are now preserved when removing trackers
- Percent-encoded query parameters handled correctly

## [1.1.0] - 2024-12-19

### Added
- Custom menu bar icon
- Homebrew tap installation option
- Start at Login option

### Changed
- Redesigned menu UI with left-aligned toggles

## [1.0.0] - 2024-12-19

### Added
- Initial release
- Automatic URL sanitization
- Menu bar app with enable/disable toggle
- Support for common tracking parameters (UTM, Facebook, Google, etc.)
