import Foundation
import Testing
@testable import Snip

@Suite("SettingsStore")
struct SettingsStoreTests {
    @Test("persists enabled state")
    func persistsEnabled() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let store = SettingsStore(userDefaults: defaults)
        store.isEnabled = false
        let reloaded = SettingsStore(userDefaults: defaults)
        #expect(reloaded.isEnabled == false)
    }

    @Test("defaults to enabled")
    func defaultsToEnabled() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let store = SettingsStore(userDefaults: defaults)
        #expect(store.isEnabled == true)
    }
}
