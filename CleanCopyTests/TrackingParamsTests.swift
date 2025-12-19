import Testing
@testable import CleanCopy

@Suite("TrackingParams")
struct TrackingParamsTests {
    @Test("contains common tracking params")
    func containsCommonParams() {
        #expect(TrackingParams.blocklist.contains("utm_source"))
        #expect(TrackingParams.blocklist.contains("fbclid"))
        #expect(TrackingParams.blocklist.contains("gclid"))
        #expect(TrackingParams.blocklist.contains("si"))
    }

    @Test("does not contain legitimate params")
    func doesNotContainLegitParams() {
        #expect(!TrackingParams.blocklist.contains("id"))
        #expect(!TrackingParams.blocklist.contains("page"))
        #expect(!TrackingParams.blocklist.contains("q"))
    }
}
