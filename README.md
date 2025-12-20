# CleanCopy

> Automatically strip tracking junk from URLs when you copy them.

You copy `https://example.com/article?utm_source=twitter&utm_medium=social&fbclid=abc123`

Your clipboard gets `https://example.com/article`

No action needed. Just copy links like normal.

## Why?

Every link you share is full of tracking garbage. `utm_source`, `fbclid`, `gclid` — they let companies track where you came from and follow you around the web.

CleanCopy removes them automatically. Copy a link, share a clean link.

## Install

**Download** the latest release from [Releases](https://github.com/maferland/clean-copy/releases).

Or build from source:
```bash
git clone https://github.com/maferland/clean-copy.git
cd clean-copy
swift build -c release
sudo cp .build/release/CleanCopy /usr/local/bin/
```

## Usage

Run `CleanCopy`. A link icon appears in your menu bar. That's it.

- **Enabled/Disabled** — Toggle cleaning on/off
- **Start at Login** — Run automatically when you log in
- **Quit** — Stop the app

## What Gets Removed

| Tracker | Source |
|---------|--------|
| `utm_*` | Google Analytics |
| `fbclid` | Facebook |
| `gclid`, `dclid` | Google Ads |
| `msclkid` | Microsoft/Bing |
| `twclid` | Twitter/X |
| `si` | Spotify |
| `igshid` | Instagram |
| `mc_eid`, `mc_cid` | Mailchimp |
| `_hsenc`, `_hsmi` | HubSpot |
| `ref`, `ref_src` | Generic referral |

[Full list in source](CleanCopy/TrackingParams.swift)

## Privacy

CleanCopy runs entirely on your Mac. No network requests. No data collection. No analytics (ironic, right?).

## Requirements

- macOS 14 (Sonoma) or later
- ~5MB disk space

## Support

If CleanCopy saves you from tracking junk, consider buying me a coffee:

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow?style=for-the-badge&logo=buy-me-a-coffee)](https://buymeacoffee.com/maferland)

## License

MIT
