#!/usr/bin/env swift

import Foundation

// Verify the default config JSON is valid by encoding and decoding
struct TrackingParamsConfig: Codable, Equatable {
    var global: [String]
    var domainScoped: [String: [String]]
    var domainPrefixScoped: [String: [String]]
}

// Simulate the defaults
let defaults = TrackingParamsConfig(
    global: [
        "utm_source", "utm_medium", "utm_campaign",
        "utm_term", "utm_content", "utm_id",
        "fbclid", "fb_action_ids", "fb_action_types",
        "gclid", "gclsrc", "dclid",
        "msclkid",
        "twclid",
        "si",
        "ref", "ref_src", "ref_url",
        "mc_eid", "mc_cid",
        "_hsenc", "_hsmi",
        "oly_enc_id", "oly_anon_id",
        "vero_id", "vero_conv",
        "s_kwcid",
        "igshid",
    ],
    domainScoped: [
        "x.com": ["s", "t"],
        "twitter.com": ["s", "t"],
    ],
    domainPrefixScoped: [
        "amazon": ["_encoding", "pd_rd_i", "pd_rd_w", "pd_rd_wg", "pd_rd_r", "pf_rd_p", "pf_rd_r", "content-id", "th", "psc"],
    ]
)

// Test: JSON roundtrip
print("Testing JSON roundtrip...")
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let data = try encoder.encode(defaults)
let decoded = try JSONDecoder().decode(TrackingParamsConfig.self, from: data)
assert(decoded == defaults, "JSON roundtrip failed")
print("\u{2713} JSON roundtrip OK")

// Test: no duplicates in global
print("\nTesting no duplicates in global...")
assert(defaults.global.count == Set(defaults.global).count, "Global list has duplicates")
print("\u{2713} No duplicates")

// Test: all lowercase
print("\nTesting all lowercase...")
for param in defaults.global {
    assert(param == param.lowercased(), "Param '\(param)' should be lowercase")
}
print("\u{2713} All lowercase")

print("\n\u{2705} All tests passed!")
