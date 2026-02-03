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

    @Test("blocklist contains only lowercase keys")
    func blocklistIsLowercase() {
        for param in TrackingParams.blocklist {
            #expect(param == param.lowercased(), "Param '\(param)' should be lowercase")
        }
    }

    @Test("blocklist has no duplicates")
    func blocklistHasNoDuplicates() {
        let array = Array(TrackingParams.blocklist)
        #expect(array.count == Set(array).count, "Blocklist contains duplicates")
    }
}
