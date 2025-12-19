# CleanCopy Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a macOS menu bar app that automatically strips tracking parameters from copied URLs.

**Architecture:** SwiftUI app with NSApplicationDelegateAdaptor for menu bar. Timer-based clipboard polling (0.5s). URLComponents for parsing/reconstructing URLs.

**Tech Stack:** Swift 5.9, SwiftUI, macOS 14+ (Sonoma)

---

## Task 1: Create Xcode Project

**Files:**
- Create: `CleanCopy.xcodeproj`
- Create: `CleanCopy/CleanCopyApp.swift`

**Step 1: Create project via Xcode CLI**

Run:
```bash
cd /Users/marc-antoine.ferland/dev/clean-copy
mkdir -p CleanCopy
```

**Step 2: Create Package.swift for SPM-based build**

Create `Package.swift`:
```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CleanCopy",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CleanCopy",
            path: "CleanCopy"
        ),
        .testTarget(
            name: "CleanCopyTests",
            dependencies: ["CleanCopy"],
            path: "CleanCopyTests"
        )
    ]
)
```

**Step 3: Create minimal app entry point**

Create `CleanCopy/CleanCopyApp.swift`:
```swift
import SwiftUI

@main
struct CleanCopyApp: App {
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
```

**Step 4: Build to verify setup**

Run: `swift build`
Expected: Build Succeeded

**Step 5: Commit**

```bash
git add .
git commit -m "feat: init swift package"
```

---

## Task 2: TrackingParams - Blocklist Definition

**Files:**
- Create: `CleanCopy/TrackingParams.swift`
- Create: `CleanCopyTests/TrackingParamsTests.swift`

**Step 1: Write the failing test**

Create `CleanCopyTests/TrackingParamsTests.swift`:
```swift
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
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter TrackingParams`
Expected: FAIL - cannot find TrackingParams

**Step 3: Write minimal implementation**

Create `CleanCopy/TrackingParams.swift`:
```swift
import Foundation

enum TrackingParams {
    static let blocklist: Set<String> = [
        // UTM (Google Analytics)
        "utm_source", "utm_medium", "utm_campaign",
        "utm_term", "utm_content", "utm_id",

        // Facebook
        "fbclid", "fb_action_ids", "fb_action_types",

        // Google
        "gclid", "gclsrc", "dclid",

        // Microsoft/Bing
        "msclkid",

        // Twitter/X
        "twclid",

        // Spotify
        "si",

        // Generic trackers
        "ref", "ref_src", "ref_url",
        "mc_eid", "mc_cid",
        "_hsenc", "_hsmi",
        "oly_enc_id", "oly_anon_id",
        "vero_id", "vero_conv",
        "s_kwcid",
        "igshid",
    ]
}
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter TrackingParams`
Expected: PASS

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add tracking params blocklist"
```

---

## Task 3: URLSanitizer - Core Logic

**Files:**
- Create: `CleanCopy/URLSanitizer.swift`
- Create: `CleanCopyTests/URLSanitizerTests.swift`

**Step 1: Write failing tests**

Create `CleanCopyTests/URLSanitizerTests.swift`:
```swift
import Testing
@testable import CleanCopy

@Suite("URLSanitizer")
struct URLSanitizerTests {
    let sanitizer = URLSanitizer()

    @Test("removes utm params from URL")
    func removesUtmParams() {
        let input = "https://example.com/page?utm_source=twitter&utm_medium=social&id=123"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/page?id=123")
        #expect(result.removedParams == ["utm_source", "utm_medium"])
    }

    @Test("removes fbclid from URL")
    func removesFbclid() {
        let input = "https://example.com/?fbclid=abc123"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/")
        #expect(result.removedParams == ["fbclid"])
    }

    @Test("removes si from Spotify URL")
    func removesSpotifySi() {
        let input = "https://open.spotify.com/track/123?si=abc456"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://open.spotify.com/track/123")
        #expect(result.removedParams == ["si"])
    }

    @Test("preserves non-tracking params")
    func preservesLegitParams() {
        let input = "https://example.com/search?q=hello&page=2"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/search?q=hello&page=2")
        #expect(result.removedParams.isEmpty)
    }

    @Test("handles URL with no query params")
    func handlesNoParams() {
        let input = "https://example.com/page"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "https://example.com/page")
        #expect(result.removedParams.isEmpty)
    }

    @Test("returns original for non-URL text")
    func handlesNonUrl() {
        let input = "not a url"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "not a url")
        #expect(result.removedParams.isEmpty)
    }

    @Test("handles multiple URLs in text")
    func handlesMultipleUrls() {
        let input = "Check https://a.com?fbclid=1 and https://b.com?gclid=2"
        let result = sanitizer.sanitize(input)
        #expect(result.cleaned == "Check https://a.com and https://b.com")
        #expect(Set(result.removedParams) == Set(["fbclid", "gclid"]))
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter URLSanitizer`
Expected: FAIL - cannot find URLSanitizer

**Step 3: Write implementation**

Create `CleanCopy/URLSanitizer.swift`:
```swift
import Foundation

struct SanitizeResult {
    let cleaned: String
    let removedParams: [String]

    var didChange: Bool { !removedParams.isEmpty }
}

final class URLSanitizer {
    func sanitize(_ text: String) -> SanitizeResult {
        var removedParams: [String] = []
        var result = text

        // Find all URLs in text
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return SanitizeResult(cleaned: text, removedParams: [])
        }

        let matches = detector.matches(in: text, range: NSRange(text.startIndex..., in: text))

        // Process in reverse to preserve string indices
        for match in matches.reversed() {
            guard let range = Range(match.range, in: text),
                  let url = match.url,
                  var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                continue
            }

            let originalItems = components.queryItems ?? []
            let filteredItems = originalItems.filter { item in
                !TrackingParams.blocklist.contains(item.name)
            }

            let removed = originalItems.filter { TrackingParams.blocklist.contains($0.name) }.map(\.name)
            removedParams.append(contentsOf: removed)

            if removed.isEmpty { continue }

            components.queryItems = filteredItems.isEmpty ? nil : filteredItems

            if let cleanedURL = components.url?.absoluteString {
                result.replaceSubrange(range, with: cleanedURL)
            }
        }

        return SanitizeResult(cleaned: result, removedParams: removedParams)
    }
}
```

**Step 4: Run tests to verify they pass**

Run: `swift test --filter URLSanitizer`
Expected: PASS

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add URL sanitizer with tracking param removal"
```

---

## Task 4: ClipboardMonitor - Clipboard Polling

**Files:**
- Create: `CleanCopy/ClipboardMonitor.swift`

**Step 1: Write the ClipboardMonitor**

Create `CleanCopy/ClipboardMonitor.swift`:
```swift
import AppKit
import Combine

final class ClipboardMonitor: ObservableObject {
    @Published var isEnabled = true
    @Published var lastResult: SanitizeResult?

    private let sanitizer = URLSanitizer()
    private var timer: Timer?
    private var lastChangeCount: Int = 0

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
```

**Step 2: Build to verify**

Run: `swift build`
Expected: Build Succeeded

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add clipboard monitor with polling"
```

---

## Task 5: Menu Bar UI

**Files:**
- Modify: `CleanCopy/CleanCopyApp.swift`
- Create: `CleanCopy/MenuBarView.swift`

**Step 1: Create MenuBarView**

Create `CleanCopy/MenuBarView.swift`:
```swift
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var monitor: ClipboardMonitor
    let supportURL = URL(string: "https://buymeacoffee.com/maferland")!

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Toggle(isOn: $monitor.isEnabled) {
                Text(monitor.isEnabled ? "Enabled" : "Disabled")
            }
            .toggleStyle(.checkbox)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            Button {
                NSWorkspace.shared.open(supportURL)
            } label: {
                HStack {
                    Text("Support")
                    Text("☕")
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            Button("Quit CleanCopy") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .keyboardShortcut("q")
        }
        .frame(width: 180)
    }
}
```

**Step 2: Update CleanCopyApp**

Replace `CleanCopy/CleanCopyApp.swift`:
```swift
import SwiftUI
import UserNotifications

@main
struct CleanCopyApp: App {
    @StateObject private var monitor = ClipboardMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(monitor: monitor)
        } label: {
            Image(systemName: "link")
        }
        .menuBarExtraStyle(.window)
        .onChange(of: monitor.lastResult) { _, result in
            if let result, result.didChange {
                showNotification(result: result)
            }
        }
    }

    init() {
        DispatchQueue.main.async {
            self.monitor.start()
        }
        requestNotificationPermission()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func showNotification(result: SanitizeResult) {
        let content = UNMutableNotificationContent()
        content.title = "URL Cleaned ✨"
        content.body = "Removed: \(result.removedParams.joined(separator: ", "))"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
```

**Step 3: Build to verify**

Run: `swift build`
Expected: Build Succeeded

**Step 4: Commit**

```bash
git add .
git commit -m "feat: add menu bar UI with notifications"
```

---

## Task 6: App Icon & Info.plist

**Files:**
- Create: `CleanCopy/Info.plist`

**Step 1: Create Info.plist for LSUIElement (no dock icon)**

Create `CleanCopy/Info.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>CleanCopy</string>
    <key>CFBundleIdentifier</key>
    <string>com.maferland.CleanCopy</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
</dict>
</plist>
```

**Step 2: Update Package.swift to include Info.plist**

Update `Package.swift`:
```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CleanCopy",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CleanCopy",
            path: "CleanCopy",
            resources: [.copy("Info.plist")]
        ),
        .testTarget(
            name: "CleanCopyTests",
            dependencies: ["CleanCopy"],
            path: "CleanCopyTests"
        )
    ]
)
```

**Step 3: Build to verify**

Run: `swift build`
Expected: Build Succeeded

**Step 4: Commit**

```bash
git add .
git commit -m "feat: add Info.plist for menu bar only app"
```

---

## Task 7: Final Integration Test

**Step 1: Run all tests**

Run: `swift test`
Expected: All tests pass

**Step 2: Build release**

Run: `swift build -c release`
Expected: Build Succeeded

**Step 3: Test manually**

Run: `.build/release/CleanCopy`
- Verify menu bar icon appears
- Copy URL with tracking params
- Verify notification appears
- Verify clipboard is cleaned

**Step 4: Commit**

```bash
git add .
git commit -m "chore: verify integration"
```

---

## Task 8: README

**Files:**
- Create: `README.md`

**Step 1: Create README**

Create `README.md`:
```markdown
# CleanCopy

macOS menu bar app that automatically strips tracking parameters from copied URLs.

## Features

- Runs silently in menu bar
- Detects URLs when you copy them
- Removes tracking params (utm_*, fbclid, gclid, etc.)
- Shows notification when URL is cleaned

## Install

Download from [Releases](https://github.com/maferland/CleanCopy/releases).

Or build from source:
```bash
swift build -c release
cp .build/release/CleanCopy /Applications/
```

## Support

[Buy me a coffee ☕](https://buymeacoffee.com/maferland)
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README"
```

---

## Summary

8 tasks total. Each task is TDD where applicable, with exact file paths and complete code.

**Order matters:** Tasks must be done sequentially (1→8).

**Total new files:** 8
- Package.swift
- CleanCopy/CleanCopyApp.swift
- CleanCopy/TrackingParams.swift
- CleanCopy/URLSanitizer.swift
- CleanCopy/ClipboardMonitor.swift
- CleanCopy/MenuBarView.swift
- CleanCopy/Info.plist
- README.md
