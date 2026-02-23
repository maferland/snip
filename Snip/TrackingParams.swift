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

    static let domainScoped: [String: Set<String>] = [
        "x.com": ["s", "t"],
        "twitter.com": ["s", "t"],
    ]
}
