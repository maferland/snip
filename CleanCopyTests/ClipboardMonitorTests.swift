import Testing
@testable import CleanCopy

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

@Suite("ClipboardMonitor")
struct ClipboardMonitorTests {
    @Test("does not sanitize when disabled")
    func disabledDoesNotSanitize() {
        let provider = MockClipboardProvider()
        let monitor = ClipboardMonitor(provider: provider, sanitizer: URLSanitizer())
        monitor.isEnabled = false
        provider.setString("https://example.com?utm_source=x")
        monitor.checkClipboard()
        #expect(provider.lastSetString == "https://example.com?utm_source=x")
    }

    @Test("debounces rapid clipboard changes")
    func debouncesRapidChanges() {
        let provider = MockClipboardProvider()
        let monitor = ClipboardMonitor(provider: provider, sanitizer: URLSanitizer(), debounceInterval: 0.2)
        monitor.isEnabled = true
        provider.setString("https://example.com?utm_source=1")
        monitor.checkClipboard()
        provider.setString("https://example.com?utm_source=2")
        monitor.checkClipboard()
        #expect(provider.setStringCallCount == 3)
    }
}
