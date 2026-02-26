import Foundation

struct TrackingParamsConfig: Codable, Equatable {
    var global: [String]
    var domainScoped: [String: [String]]
    var domainPrefixScoped: [String: [String]]
}

extension TrackingParamsConfig {
    static let defaults = TrackingParamsConfig(
        global: [
            // UTM
            "utm_source", "utm_medium", "utm_campaign",
            "utm_term", "utm_content", "utm_id",

            // Facebook
            "fbclid", "fb_action_ids", "fb_action_types",

            // Google Ads (appear on any destination site)
            "gclid", "gclsrc", "dclid", "gbraid", "wbraid",
            "gad_source", "gad_campaignid", "gad_adgroupid",

            // Google Analytics cross-site
            "_gl", "_ga", "gtm",

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
            "amazon": ["*"],
            "google": [
                // Session & fingerprinting
                "ei", "sei", "ved", "vet",
                "sxsrf", "iflsig", "dpr",
                "biw", "bih",

                // Search suggestion/autocomplete
                "aqs", "oq", "pq",
                "gs_lcp", "gs_lp", "gs_lcrp", "gs_mss", "gs_ssp",

                // Client & source
                "sclient", "source", "sourceid",
                "client", "channel", "esrc", "sca_esv", "sca_upv",

                // Click/navigation
                "sa", "uact", "cd", "cad", "usg",
                "rlz",

                // Encoding (browsers handle this)
                "ie", "oe",

                // UI interaction
                "iact", "ndsp", "pbx", "scroll", "stick", "forward",
                "cs", "csi", "cp",

                // Preferences/misc
                "prmd", "sc", "z", "npa",
                "cshid", "fbs",
            ],
        ]
    )
}
