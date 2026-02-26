import Testing
@testable import Snip

@Suite("URLSanitizer")
struct URLSanitizerTests {
    let sanitizer = URLSanitizer()

    // MARK: - Global params

    @Test("removes utm params from URL")
    func removesUtmParams() {
        let input = "https://example.com/page?utm_source=twitter&utm_medium=social&id=123"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/page?id=123")
        #expect(result.removedParams == ["utm_source", "utm_medium"])
    }

    @Test("removes fbclid from URL")
    func removesFbclid() {
        let input = "https://example.com/?fbclid=abc123"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/")
        #expect(result.removedParams == ["fbclid"])
    }

    @Test("removes si from Spotify URL")
    func removesSpotifySi() {
        let input = "https://open.spotify.com/track/123?si=abc456"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://open.spotify.com/track/123")
        #expect(result.removedParams == ["si"])
    }

    @Test("case-insensitive tracking keys")
    func handlesCaseInsensitive() {
        let input = "https://example.com/?UTM_Source=x"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/")
    }

    @Test("handles mixed tracking and legit params")
    func handlesMixedParams() {
        let input = "https://example.com/search?q=test&utm_source=google&page=2&fbclid=abc"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/search?q=test&page=2")
        #expect(Set(result.removedParams) == Set(["utm_source", "fbclid"]))
    }

    // MARK: - Domain-scoped

    @Test("strips domain-scoped params from x.com")
    func stripsDomainParamsXCom() {
        let input = "https://x.com/claudeai/status/123?s=46&t=KXPbHPPrKUEWvS_-L9Mbdg"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://x.com/claudeai/status/123")
        #expect(Set(result.removedParams) == Set(["s", "t"]))
    }

    @Test("strips domain-scoped params from twitter.com")
    func stripsDomainParamsTwitter() {
        let input = "https://twitter.com/user/status/456?s=20&t=abc"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://twitter.com/user/status/456")
        #expect(Set(result.removedParams) == Set(["s", "t"]))
    }

    @Test("preserves s and t on non-Twitter domains")
    func preservesDomainParamsElsewhere() {
        let input = "https://example.com/?s=query&t=value"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/?s=query&t=value")
        #expect(result.removedParams.isEmpty)
    }

    @Test("strips both global and domain-scoped params on x.com")
    func stripsMixedGlobalAndDomainParams() {
        let input = "https://x.com/user/status/789?utm_source=share&s=46&t=xyz"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://x.com/user/status/789")
        #expect(Set(result.removedParams) == Set(["utm_source", "s", "t"]))
    }

    @Test("strips domain-scoped params with www. prefix")
    func stripsDomainParamsWithWww() {
        let input = "https://www.x.com/user/status/123?s=20&t=abc"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.x.com/user/status/123")
        #expect(Set(result.removedParams) == Set(["s", "t"]))
    }

    // MARK: - Amazon (strip-all via wildcard)

    @Test("strips all params from amazon.ca")
    func stripsAllAmazonCa() {
        let input = "https://www.amazon.ca/Product/dp/123?_encoding=UTF8&pd_rd_w=rTtCm&psc=1&crid=3NX&keywords=test"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.amazon.ca/Product/dp/123")
        #expect(result.removedParams.count == 5)
    }

    @Test("strips all params from amazon.com affiliate link")
    func stripsAmazonAffiliate() {
        let input = "https://www.amazon.com/dp/B09C19RQJP?psc=1&linkCode=sl1&tag=jash09-20&linkId=42620d1f&language=en_US&ref_=as_li_ss_tl"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.amazon.com/dp/B09C19RQJP")
        #expect(result.removedParams.count == 6)
    }

    // MARK: - Google search

    @Test("strips Google search tracking, keeps query")
    func stripsGoogleSearch() {
        let input = "https://www.google.com/search?q=dowel+canadian+tire&sca_esv=abc&biw=1793&bih=1090&sxsrf=xyz&ei=abc&ved=0ah&uact=5&oq=dowel+canadian+tire&gs_lp=Egx&sclient=gws-wiz-serp"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.google.com/search?q=dowel+canadian+tire")
    }

    @Test("preserves Google search functional params")
    func preservesGoogleFunctional() {
        let input = "https://www.google.com/search?q=test&tbm=isch&tbs=isz:l&hl=en&safe=active&ei=abc&ved=0"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.google.com/search?q=test&tbm=isch&tbs=isz:l&hl=en&safe=active")
        #expect(Set(result.removedParams) == Set(["ei", "ved"]))
    }

    @Test("strips Google search on google.ca")
    func stripsGoogleCa() {
        let input = "https://www.google.ca/search?q=test&ei=abc&ved=0&sclient=gws&rlz=xyz"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.google.ca/search?q=test")
    }

    // MARK: - YouTube

    @Test("strips YouTube tracking, keeps video ID and timestamp")
    func stripsYouTube() {
        let input = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&feature=youtu.be&ab_channel=Test&si=abc123&t=42"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=42")
    }

    // MARK: - LinkedIn

    @Test("strips LinkedIn tracking")
    func stripsLinkedIn() {
        let input = "https://www.linkedin.com/posts/user_activity-123?trk=feed&lipi=abc&licu=xyz"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.linkedin.com/posts/user_activity-123")
    }

    // MARK: - eBay

    @Test("strips eBay tracking")
    func stripsEbay() {
        let input = "https://www.ebay.com/itm/12345?_trkparms=abc&_trksid=def&mkcid=1&mkrid=2"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.ebay.com/itm/12345")
    }

    @Test("strips eBay tracking on ebay.ca")
    func stripsEbayCa() {
        let input = "https://www.ebay.ca/itm/12345?_trksid=abc&campid=def"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.ebay.ca/itm/12345")
    }

    // MARK: - Reddit

    @Test("strips Reddit tracking")
    func stripsReddit() {
        let input = "https://www.reddit.com/r/swift/comments/abc?correlation_id=xyz&ref_source=share&ref_campaign=share_link"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://www.reddit.com/r/swift/comments/abc")
    }

    // MARK: - New global trackers

    @Test("strips TikTok and affiliate trackers")
    func stripsNewGlobalTrackers() {
        let input = "https://example.com/page?id=1&ttclid=abc&mkt_tok=def&awc=ghi"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/page?id=1")
        #expect(Set(result.removedParams) == Set(["ttclid", "mkt_tok", "awc"]))
    }

    @Test("uses custom config when provided")
    func usesCustomConfig() {
        let custom = TrackingParamsConfig(
            global: ["custom_tracker"],
            domainScoped: [:],
            domainPrefixScoped: [:]
        )
        let input = "https://example.com/?custom_tracker=1&utm_source=x"
        let result = sanitizer.sanitize(input, config: custom)
        #expect(result.cleaned == "https://example.com/?utm_source=x")
        #expect(result.removedParams == ["custom_tracker"])
    }

    // MARK: - Passthrough / no-op

    @Test("preserves non-tracking params")
    func preservesLegitParams() {
        let input = "https://example.com/search?q=hello&page=2"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/search?q=hello&page=2")
        #expect(result.removedParams.isEmpty)
    }

    @Test("handles URL with no query params")
    func handlesNoParams() {
        let input = "https://example.com/page"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/page")
        #expect(result.removedParams.isEmpty)
    }

    @Test("returns original for non-URL text")
    func handlesNonUrl() {
        let input = "not a url"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "not a url")
        #expect(result.removedParams.isEmpty)
    }

    @Test("returns original for empty string")
    func handlesEmptyString() {
        let result = sanitizer.sanitize("")
        #expect(result.cleaned == "")
        #expect(result.removedParams.isEmpty)
    }

    // MARK: - URL structure edge cases

    @Test("handles multiple URLs in text")
    func handlesMultipleUrls() {
        let input = "Check https://a.com?fbclid=1 and https://b.com?gclid=2"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "Check https://a.com and https://b.com")
        #expect(Set(result.removedParams) == Set(["fbclid", "gclid"]))
    }

    @Test("preserves fragments and removes trackers")
    func preservesFragment() {
        let input = "https://example.com/page?utm_source=x#section"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/page#section")
    }

    @Test("handles percent-encoded query")
    func handlesPercentEncoded() {
        let input = "https://example.com/?utm_source=x&q=hello%20world"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/?q=hello%20world")
    }

    @Test("handles URL with trailing punctuation")
    func handlesTrailingPunctuation() {
        let input = "Check this: https://example.com/?fbclid=123."
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "Check this: https://example.com/.")
    }

    @Test("handles URL in parentheses")
    func handlesParentheses() {
        let input = "(see https://example.com/?utm_source=x)"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "(see https://example.com/)")
    }

    @Test("handles URL with port number")
    func handlesPort() {
        let input = "https://example.com:8080/?utm_source=x&id=1"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com:8080/?id=1")
        #expect(result.removedParams == ["utm_source"])
    }

    @Test("handles param with empty value")
    func handlesEmptyParamValue() {
        let input = "https://example.com/?utm_source=&id=123"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/?id=123")
        #expect(result.removedParams == ["utm_source"])
    }

    @Test("preserves URL when only non-tracking params remain")
    func preservesCleanUrl() {
        let input = "https://example.com/page?id=42&lang=en"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == input)
        #expect(!result.didChange)
    }

    @Test("strips all trackers from URL with only trackers")
    func stripsAllTrackers() {
        let input = "https://example.com/?utm_source=x&fbclid=y&gclid=z"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/")
        #expect(result.removedParams.count == 3)
    }
}
