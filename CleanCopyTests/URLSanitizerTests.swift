import Testing
@testable import CleanCopy

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
}
