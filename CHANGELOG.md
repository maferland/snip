# Changelog

All notable changes to CleanCopy will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Clipboard provider abstraction for better testability
- Debounce for rapid clipboard changes (prevents duplicate processing)
- Persistent settings via UserDefaults
- Case-insensitive tracking parameter matching
- Expanded test coverage

### Changed
- Switched to SMAppService for "Start at Login" (more reliable)
- App is now distributed as a proper `.app` bundle
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
