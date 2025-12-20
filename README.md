# CleanCopy

macOS menu bar app that automatically strips tracking parameters from copied URLs.

## Features

- Runs silently in menu bar
- Detects URLs when you copy them
- Removes tracking params (utm_*, fbclid, gclid, si, etc.)
- Toggle on/off from menu

## Install

Build from source:
```bash
swift build -c release
cp .build/release/CleanCopy /usr/local/bin/
```

Run on login: Add to System Settings > General > Login Items.

## Blocked Parameters

utm_source, utm_medium, utm_campaign, utm_term, utm_content, utm_id, fbclid, fb_action_ids, fb_action_types, gclid, gclsrc, dclid, msclkid, twclid, si, ref, ref_src, ref_url, mc_eid, mc_cid, _hsenc, _hsmi, oly_enc_id, oly_anon_id, vero_id, vero_conv, s_kwcid, igshid

## Support

[Buy me a coffee](https://buymeacoffee.com/maferland)
