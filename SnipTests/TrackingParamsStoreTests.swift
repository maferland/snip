import Foundation
import Testing
@testable import Snip

@Suite("TrackingParamsStore")
struct TrackingParamsStoreTests {
    private func tempURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("snip-test-\(UUID().uuidString)")
            .appendingPathComponent("tracking_params.json")
    }

    @Test("loads defaults when no file exists")
    func loadsDefaults() {
        let store = TrackingParamsStore(url: tempURL())
        #expect(store.config == .defaults)
    }

    @Test("saves and loads config from file")
    func savesAndLoads() throws {
        let url = tempURL()
        let store = TrackingParamsStore(url: url)

        var custom = TrackingParamsConfig.defaults
        custom.global.append("new_tracker")
        try store.save(json: encode(custom))

        let reloaded = TrackingParamsStore(url: url)
        #expect(reloaded.config.global.contains("new_tracker"))
    }

    @Test("rejects invalid JSON")
    func rejectsInvalidJSON() {
        let store = TrackingParamsStore(url: tempURL())
        #expect(throws: (any Error).self) {
            try store.save(json: "not json {{{")
        }
    }

    @Test("reset restores defaults")
    func resetRestoresDefaults() throws {
        let url = tempURL()
        let store = TrackingParamsStore(url: url)

        let custom = TrackingParamsConfig(global: ["only_this"], domainScoped: [:], domainPrefixScoped: [:])
        try store.save(json: encode(custom))
        #expect(store.config.global == ["only_this"])

        try store.reset()
        #expect(store.config == .defaults)
    }

    @Test("jsonString produces valid JSON")
    func jsonStringIsValid() throws {
        let store = TrackingParamsStore(url: tempURL())
        let data = store.jsonString.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(TrackingParamsConfig.self, from: data)
        #expect(decoded == .defaults)
    }

    private func encode(_ config: TrackingParamsConfig) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try! encoder.encode(config)
        return String(data: data, encoding: .utf8)!
    }
}
