import Testing
@testable import Snip

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

    @Test("domain-scoped keys and values are lowercase")
    func domainScopedIsLowercase() {
        for (domain, params) in TrackingParams.domainScoped {
            #expect(domain == domain.lowercased(), "Domain '\(domain)' should be lowercase")
            for param in params {
                #expect(param == param.lowercased(), "Param '\(param)' for \(domain) should be lowercase")
            }
        }
    }

    @Test("domain-scoped params don't overlap global blocklist")
    func domainScopedNoOverlapWithGlobal() {
        for (domain, params) in TrackingParams.domainScoped {
            let overlap = params.intersection(TrackingParams.blocklist)
            #expect(overlap.isEmpty, "Domain '\(domain)' has params \(overlap) already in global blocklist")
        }
    }
}
