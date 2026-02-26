import Foundation

struct TrackingParamsConfig: Codable, Equatable {
    var global: [String]
    var domainScoped: [String: [String]]
    var domainPrefixScoped: [String: [String]]
}

extension TrackingParamsConfig {
    static let defaults = TrackingParamsConfig(
        global: [
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
        ],
        domainScoped: [
            "x.com": ["s", "t"],
            "twitter.com": ["s", "t"],
        ],
        domainPrefixScoped: [
            "amazon": [
                "_encoding",
                "pd_rd_i", "pd_rd_w", "pd_rd_wg", "pd_rd_r",
                "pf_rd_p", "pf_rd_r",
                "content-id",
                "th", "psc",
                "crid", "dib", "dib_tag",
                "keywords", "qid", "sprefix", "sr",
            ],
        ]
    )
}
