import AppKit
import Combine

final class ClipboardMonitor: ObservableObject {
    @Published var isEnabled = true
    @Published var lastResult: SanitizeResult?

    private let sanitizer = URLSanitizer()
    private var timer: Timer?
    private var lastChangeCount: Int = 0

    deinit {
        stop()
    }

    func start() {
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        guard isEnabled else { return }

        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        guard let text = pasteboard.string(forType: .string) else { return }

        let result = sanitizer.sanitize(text)
        guard result.didChange else { return }

        // Update clipboard with cleaned text
        pasteboard.clearContents()
        pasteboard.setString(result.cleaned, forType: .string)
        lastChangeCount = pasteboard.changeCount

        // Publish result for notification
        DispatchQueue.main.async {
            self.lastResult = result
        }
    }
}
