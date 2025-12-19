# CleanCopy Design

macOS menu bar app that strips tracking parameters from copied URLs.

## Summary

- **Tech:** Swift/SwiftUI
- **Form:** Menu bar app, runs in background
- **Core:** Clipboard polling + URL sanitization
- **No:** URL unshortening, history, persistent storage

## Architecture

```
CleanCopyApp
├── MenuBarView (toggle, support link, quit)
├── ClipboardMonitor (0.5s timer polling)
└── URLSanitizer (detect URLs, strip params)
```

No network calls. Pure local string manipulation.

## Tracking Parameter Blocklist

Exact match on parameter name:

```swift
let trackingParams: Set<String> = [
    // UTM (Google Analytics)
    "utm_source", "utm_medium", "utm_campaign",
    "utm_term", "utm_content", "utm_id",

    // Facebook
    "fbclid", "fb_action_ids", "fb_action_types",

    // Google
    "gclid", "gclsrc", "dclid",

    // Microsoft/Bing
    "msclkid",

    // Twitter/X
    "twclid",

    // Spotify
    "si",

    // Generic trackers
    "ref", "ref_src", "ref_url",
    "mc_eid", "mc_cid",  // Mailchimp
    "_hsenc", "_hsmi",   // HubSpot
    "oly_enc_id", "oly_anon_id",  // Omeda
    "vero_id", "vero_conv",
    "s_kwcid",           // Adobe
    "igshid",            // Instagram
]
```

## URL Sanitization Flow

1. Get clipboard content
2. Extract URLs via NSDataDetector
3. For each URL: parse, filter blocklisted params, reconstruct
4. If params removed: replace clipboard, show notification
5. If nothing changed: do nothing

**Edge cases:**
- Multiple URLs: clean all
- Non-URL text: unchanged
- No tracking params: no notification

## Menu Bar UI

```
┌─────────────────────┐
│ ✓ Enabled           │
├─────────────────────┤
│ Support ☕           │  → buymeacoffee.com link
├─────────────────────┤
│ Quit CleanCopy      │
└─────────────────────┘
```

Icon: link symbol, brief checkmark after cleaning.

## Notification

Only when params actually removed:
```
"URL Cleaned ✨"
"Removed: fbclid, utm_source"
```

## Project Structure

```
CleanCopy/
├── CleanCopyApp.swift
├── ClipboardMonitor.swift
├── URLSanitizer.swift
├── TrackingParams.swift
└── Assets.xcassets/
```

## Distribution

GitHub releases (DMG). Homebrew cask later.

## Permissions

None required (clipboard access is unrestricted on macOS).

## Future (out of scope for v1)

- URL unshortening
- User-configurable rules
- History of cleaned URLs
