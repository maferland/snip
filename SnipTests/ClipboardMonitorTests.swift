import Foundation
import Testing
@testable import Snip

final class MockClipboardProvider: ClipboardProvider {
    private var _changeCount = 0
    private var _string: String?
    var lastSetString: String?
    var setStringCallCount = 0

    var changeCount: Int { _changeCount }

    func string() -> String? { _string }

    func setString(_ string: String) {
        _string = string
        _changeCount += 1
        lastSetString = string
        setStringCallCount += 1
    }
}

func makeTestSettings() -> SettingsStore {
    SettingsStore(userDefaults: UserDefaults(suiteName: "test-\(UUID().uuidString)")!)
}

func makeTestTrackingStore() -> TrackingParamsStore {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("snip-test-\(UUID().uuidString)")
        .appendingPathComponent("tracking_params.json")
    return TrackingParamsStore(url: url)
}

private func makeMonitor(
    provider: MockClipboardProvider = MockClipboardProvider(),
    debounceInterval: TimeInterval = 0.3
) -> (ClipboardMonitor, MockClipboardProvider) {
    let monitor = ClipboardMonitor(
        provider: provider,
        sanitizer: URLSanitizer(),
        debounceInterval: debounceInterval,
        settings: makeTestSettings(),
        trackingStore: makeTestTrackingStore()
    )
    monitor.isEnabled = true
    return (monitor, provider)
}

@Suite("ClipboardMonitor")
struct ClipboardMonitorTests {
    @Test("does not sanitize when disabled")
    func disabledDoesNotSanitize() {
        let (monitor, provider) = makeMonitor()
        monitor.isEnabled = false
        provider.setString("https://example.com?utm_source=x")
        monitor.checkClipboard()
        #expect(provider.lastSetString == "https://example.com?utm_source=x")
    }

    @Test("sanitizes URL with tracking params")
    func sanitizesTrackingUrl() {
        let (monitor, provider) = makeMonitor()
        provider.setString("https://example.com?utm_source=x&id=1")
        monitor.checkClipboard()
        #expect(provider.lastSetString == "https://example.com?id=1")
    }

    @Test("ignores clipboard with no tracking params")
    func ignoresCleanUrl() {
        let (monitor, provider) = makeMonitor()
        provider.setString("https://example.com?id=1")
        monitor.checkClipboard()
        #expect(provider.setStringCallCount == 1)
    }

    @Test("ignores non-URL clipboard content")
    func ignoresNonUrl() {
        let (monitor, provider) = makeMonitor()
        provider.setString("just some text")
        monitor.checkClipboard()
        #expect(provider.setStringCallCount == 1)
    }

    @Test("debounces rapid clipboard changes")
    func debouncesRapidChanges() {
        let (monitor, provider) = makeMonitor(debounceInterval: 0.2)
        provider.setString("https://example.com?utm_source=1")
        monitor.checkClipboard()
        provider.setString("https://example.com?utm_source=2")
        monitor.checkClipboard()
        #expect(provider.setStringCallCount == 3)
    }

    @Test("retries debounced change after interval passes")
    func retriesDebouncedChange() throws {
        let (monitor, provider) = makeMonitor(debounceInterval: 0.05)
        provider.setString("https://example.com?utm_source=1")
        monitor.checkClipboard()
        #expect(provider.setStringCallCount == 2)

        provider.setString("https://example.com?fbclid=abc")
        monitor.checkClipboard()
        #expect(provider.setStringCallCount == 3)

        Thread.sleep(forTimeInterval: 0.06)
        monitor.checkClipboard()
        #expect(provider.setStringCallCount == 4)
        #expect(provider.lastSetString == "https://example.com")
    }

    @Test("skips when clipboard unchanged between ticks")
    func skipsUnchangedClipboard() {
        let (monitor, provider) = makeMonitor()
        provider.setString("https://example.com?utm_source=x")
        monitor.checkClipboard()
        let countAfterFirst = provider.setStringCallCount
        monitor.checkClipboard()
        monitor.checkClipboard()
        #expect(provider.setStringCallCount == countAfterFirst)
    }

    @Test("uses tracking store config")
    func usesTrackingStoreConfig() throws {
        let provider = MockClipboardProvider()
        let store = makeTestTrackingStore()
        let custom = TrackingParamsConfig(
            global: ["my_tracker"],
            domainScoped: [:],
            domainPrefixScoped: [:]
        )
        try store.save(config: custom)

        let monitor = ClipboardMonitor(
            provider: provider,
            sanitizer: URLSanitizer(),
            settings: makeTestSettings(),
            trackingStore: store
        )
        monitor.isEnabled = true
        provider.setString("https://example.com?my_tracker=1&utm_source=x")
        monitor.checkClipboard()
        #expect(provider.lastSetString == "https://example.com?utm_source=x")
    }
}
