import Foundation
import Testing
@testable import Snip

@Suite("TrackingParamsConfig")
struct TrackingParamsConfigTests {
    let config = TrackingParamsConfig.defaults

    @Test("contains common tracking params")
    func containsCommonParams() {
        #expect(config.global.contains("utm_source"))
        #expect(config.global.contains("fbclid"))
        #expect(config.global.contains("gclid"))
        #expect(config.global.contains("si"))
    }

    @Test("does not contain legitimate params")
    func doesNotContainLegitParams() {
        #expect(!config.global.contains("id"))
        #expect(!config.global.contains("page"))
        #expect(!config.global.contains("q"))
    }

    @Test("global contains only lowercase keys")
    func globalIsLowercase() {
        for param in config.global {
            #expect(param == param.lowercased(), "Param '\(param)' should be lowercase")
        }
    }

    @Test("global has no duplicates")
    func globalHasNoDuplicates() {
        #expect(config.global.count == Set(config.global).count, "Global list contains duplicates")
    }

    @Test("domain-scoped keys and values are lowercase")
    func domainScopedIsLowercase() {
        for (domain, params) in config.domainScoped {
            #expect(domain == domain.lowercased(), "Domain '\(domain)' should be lowercase")
            for param in params {
                #expect(param == param.lowercased(), "Param '\(param)' for \(domain) should be lowercase")
            }
        }
    }

    @Test("domain-scoped params don't overlap global")
    func domainScopedNoOverlapWithGlobal() {
        let globalSet = Set(config.global)
        for (domain, params) in config.domainScoped {
            let overlap = Set(params).intersection(globalSet)
            #expect(overlap.isEmpty, "Domain '\(domain)' has params \(overlap) already in global")
        }
    }

    @Test("domain-prefix-scoped keys and values are lowercase")
    func domainPrefixScopedIsLowercase() {
        for (prefix, params) in config.domainPrefixScoped {
            #expect(prefix == prefix.lowercased(), "Prefix '\(prefix)' should be lowercase")
            for param in params {
                #expect(param == param.lowercased(), "Param '\(param)' for \(prefix) should be lowercase")
            }
        }
    }

    @Test("domain-prefix-scoped params don't overlap global")
    func domainPrefixScopedNoOverlapWithGlobal() {
        let globalSet = Set(config.global)
        for (prefix, params) in config.domainPrefixScoped {
            let overlap = Set(params).intersection(globalSet)
            #expect(overlap.isEmpty, "Prefix '\(prefix)' has params \(overlap) already in global")
        }
    }

    @Test("encodes and decodes to JSON roundtrip")
    func jsonRoundtrip() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        let decoded = try JSONDecoder().decode(TrackingParamsConfig.self, from: data)
        #expect(decoded == config)
    }
}
