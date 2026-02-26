# Snip

## Release Rules

- **Every deployed change MUST have a new version number.** No exceptions.
- Bump `Snip.app/Contents/Info.plist` (both `CFBundleVersion` and `CFBundleShortVersionString`)
- Tag format: `v{major}.{minor}.{patch}`
- Release CI triggers only on tag push — never re-tag, always increment

## Config Conventions

- `domainPrefixScoped` with `["*"]` = strip ALL query params for that domain family
