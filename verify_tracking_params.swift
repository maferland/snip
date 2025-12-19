#!/usr/bin/env swift

import Foundation

enum TrackingParams {
    static let blocklist: Set<String> = [
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
        "mc_eid", "mc_cid",
        "_hsenc", "_hsmi",
        "oly_enc_id", "oly_anon_id",
        "vero_id", "vero_conv",
        "s_kwcid",
        "igshid",
    ]
}

// Test: contains common tracking params
print("Testing common tracking params...")
assert(TrackingParams.blocklist.contains("utm_source"), "Failed: utm_source")
assert(TrackingParams.blocklist.contains("fbclid"), "Failed: fbclid")
assert(TrackingParams.blocklist.contains("gclid"), "Failed: gclid")
assert(TrackingParams.blocklist.contains("si"), "Failed: si")
print("✓ All common tracking params present")

// Test: does not contain legitimate params
print("\nTesting legitimate params are not blocked...")
assert(!TrackingParams.blocklist.contains("id"), "Failed: id should not be blocked")
assert(!TrackingParams.blocklist.contains("page"), "Failed: page should not be blocked")
assert(!TrackingParams.blocklist.contains("q"), "Failed: q should not be blocked")
print("✓ Legitimate params not in blocklist")

print("\n✅ All tests passed!")
