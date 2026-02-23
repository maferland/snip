import Testing
@testable import Snip

@Suite("URLSanitizer")
struct URLSanitizerTests {
    let sanitizer = URLSanitizer()

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

    @Test("case-insensitive tracking keys")
    func handlesCaseInsensitive() {
        let input = "https://example.com/?UTM_Source=x"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/")
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

    @Test("handles mixed tracking and legit params")
    func handlesMixedParams() {
        let input = "https://example.com/search?q=test&utm_source=google&page=2&fbclid=abc"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/search?q=test&page=2")
        #expect(Set(result.removedParams) == Set(["utm_source", "fbclid"]))
    }

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
}
