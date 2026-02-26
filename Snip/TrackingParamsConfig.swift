import Foundation

struct TrackingParamsConfig: Codable, Equatable {
    var global: [String]
    var domainScoped: [String: [String]]
    var domainPrefixScoped: [String: [String]]
}

extension TrackingParamsConfig {
    static let defaults = TrackingParamsConfig(
        global: [
            // UTM (standard + common extensions)
            "utm_source", "utm_medium", "utm_campaign",
            "utm_term", "utm_content", "utm_id",
            "utm_cid", "utm_creative", "utm_keyword",

            // Facebook/Meta
            "fbclid", "fb_action_ids", "fb_action_types",
            "fb_ref", "fb_source",

            // Google Ads (appear on any destination site)
            "gclid", "gclsrc", "dclid", "gbraid", "wbraid",
            "gad_source", "gad_campaignid", "gad_adgroupid",
            "srsltid",

            // Google Analytics cross-site
            "_gl", "_ga", "gtm",

            // Microsoft/Bing
            "msclkid",

            // TikTok
            "ttclid",

            // Twitter/X
            "twclid",

            // Yandex
            "yclid", "ysclid",

            // Spotify
            "si",

            // Affiliate networks
            "awc",
            "cjevent", "cjdata",
            "irgwc", "irclickid",

            // HubSpot
            "_hsenc", "_hsmi", "hsctatracking",
            "__hsfp", "__hssc", "__hstc",

            // Marketo
            "mkt_tok",

            // Matomo/Piwik
            "mtm_campaign", "mtm_cid", "mtm_content",
            "mtm_medium", "mtm_source",
            "pk_campaign", "pk_medium", "pk_source",

            // Branch.io (mobile deep linking)
            "_branch_match_id", "_branch_referrer",

            // Generic trackers
            "ref", "ref_src", "ref_url",
            "mc_eid", "mc_cid",
            "oly_enc_id", "oly_anon_id",
            "vero_id", "vero_conv",
            "s_kwcid", "s_cid",
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

            // YouTube: keep v (video), t (timestamp), list, index
            "youtube": [
                "feature", "kw", "pp",
                "ab_channel",
            ],

            // LinkedIn
            "linkedin": [
                "trk", "trkinfo", "trackingid",
                "lipi", "licu",
                "refid", "original_referer",
            ],

            // eBay
            "ebay": [
                "_trkparms", "_trksid",
                "hash", "mkcid", "mkrid",
                "campid", "toolid",
            ],

            // Reddit
            "reddit": [
                "correlation_id",
                "ref_source", "ref_campaign",
            ],
        ]
    )
}
