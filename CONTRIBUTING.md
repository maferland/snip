# Contributing to CleanCopy

Thanks for your interest in contributing.

## Quick Start

```bash
git clone https://github.com/maferland/clean-copy.git
cd clean-copy
swift build
swift test
```

## Adding Tracking Parameters

Edit `CleanCopy/TrackingParams.swift` and add the parameter name (lowercase) to the blocklist. Include a comment noting the source.

Run tests to verify:
```bash
swift test
```

## Code Style

- Follow existing patterns
- Keep it simple
- No unnecessary dependencies

## Pull Requests

1. Fork the repo
2. Create a branch (`git checkout -b fix/something`)
3. Make your changes
4. Run tests (`swift test`)
5. Submit a PR

## Reporting Issues

Open an issue with:
- macOS version
- Steps to reproduce
- Expected vs actual behavior

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
