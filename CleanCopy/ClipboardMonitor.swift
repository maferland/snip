import AppKit
import Combine

final class ClipboardMonitor: ObservableObject {
    @Published var isEnabled = true
    @Published var lastResult: SanitizeResult?

    private let provider: ClipboardProvider
    private let sanitizer: URLSanitizer
    private let debounceInterval: TimeInterval
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private var lastSanitizedAt: Date?

    init(provider: ClipboardProvider = SystemClipboardProvider(), sanitizer: URLSanitizer = URLSanitizer(), debounceInterval: TimeInterval = 0.3) {
        self.provider = provider
        self.sanitizer = sanitizer
        self.debounceInterval = debounceInterval
    }

    deinit {
        stop()
    }

    func start() {
        lastChangeCount = provider.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func checkClipboard() {
        guard isEnabled else { return }

        let currentCount = provider.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        if let lastSanitizedAt = lastSanitizedAt,
           Date().timeIntervalSince(lastSanitizedAt) < debounceInterval {
            return
        }

        guard let text = provider.string() else { return }

        let result = sanitizer.sanitize(text)
        guard result.didChange else { return }

        provider.setString(result.cleaned)
        lastChangeCount = provider.changeCount
        lastSanitizedAt = Date()

        DispatchQueue.main.async {
            self.lastResult = result
        }
    }
}
