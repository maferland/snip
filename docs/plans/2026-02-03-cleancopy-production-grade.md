# CleanCopy Production Grade Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Upgrade CleanCopy to production-grade quality with a hardened app bundle, improved clipboard handling, expanded tests, signed/notarized distribution, and a premium open-source README + minimal community docs.

**Architecture:** Keep a lightweight menu bar app but refactor internals to separate clipboard access, sanitization, and settings. Package as a signed `.app` with a notarized DMG and Homebrew cask distribution.

**Tech Stack:** Swift 5.9, SwiftUI, SwiftPM, AppKit, SMAppService, Swift Testing, GitHub Releases, Homebrew Cask.

---

### Task 1: Add a clipboard provider abstraction

**Files:**
- Modify: `CleanCopy/ClipboardMonitor.swift`
- Create: `CleanCopy/ClipboardProvider.swift`
- Test: `CleanCopyTests/ClipboardMonitorTests.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import CleanCopy

@Suite("ClipboardMonitor")
struct ClipboardMonitorTests {
    @Test("does not sanitize when disabled")
    func disabledDoesNotSanitize() {
        let provider = MockClipboardProvider()
        let monitor = ClipboardMonitor(provider: provider, sanitizer: URLSanitizer())
        monitor.isEnabled = false
        provider.setString("https://example.com?utm_source=x")
        monitor.checkClipboard()
        #expect(provider.lastSetString == nil)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with "Cannot find 'MockClipboardProvider'" or "no member 'checkClipboard'"

**Step 3: Write minimal implementation**

```swift
protocol ClipboardProvider {
    var changeCount: Int { get }
    func string() -> String?
    func setString(_ string: String)
}

final class SystemClipboardProvider: ClipboardProvider {
    private let pasteboard = NSPasteboard.general
    var changeCount: Int { pasteboard.changeCount }
    func string() -> String? { pasteboard.string(forType: .string) }
    func setString(_ string: String) {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }
}
```

Update `ClipboardMonitor` to accept `provider` and `sanitizer` via init, expose `checkClipboard()` for tests, and replace direct pasteboard calls with the provider.

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS

**Step 5: Commit**

```bash
git add CleanCopy/ClipboardProvider.swift CleanCopy/ClipboardMonitor.swift CleanCopyTests/ClipboardMonitorTests.swift
git commit -m "refactor: add clipboard provider abstraction"
```

---

### Task 2: Add debounce/backoff for clipboard changes

**Files:**
- Modify: `CleanCopy/ClipboardMonitor.swift`
- Test: `CleanCopyTests/ClipboardMonitorTests.swift`

**Step 1: Write the failing test**

```swift
@Test("debounces rapid clipboard changes")
func debouncesRapidChanges() {
    let provider = MockClipboardProvider()
    let monitor = ClipboardMonitor(provider: provider, sanitizer: URLSanitizer(), debounceInterval: 0.2)
    monitor.isEnabled = true
    provider.setString("https://example.com?utm_source=1")
    monitor.checkClipboard()
    provider.setString("https://example.com?utm_source=2")
    monitor.checkClipboard()
    #expect(provider.setStringCallCount == 1)
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL

**Step 3: Write minimal implementation**

Add a `debounceInterval` property, track `lastSanitizedAt`, and skip sanitize if the last change was too recent. Keep defaults conservative (e.g., 0.3s) to avoid annoying UX.

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS

**Step 5: Commit**

```bash
git add CleanCopy/ClipboardMonitor.swift CleanCopyTests/ClipboardMonitorTests.swift
git commit -m "feat: debounce clipboard sanitization"
```

---

### Task 3: Harden URL sanitization edge cases

**Files:**
- Modify: `CleanCopy/URLSanitizer.swift`
- Test: `CleanCopyTests/URLSanitizerTests.swift`

**Step 1: Write the failing tests**

```swift
@Test("preserves fragments and removes trackers")
func preservesFragment() {
    let input = "https://example.com/page?utm_source=x#section"
    let result = URLSanitizer().sanitize(input)
    #expect(result.cleaned == "https://example.com/page#section")
}

@Test("handles percent-encoded query")
func handlesPercentEncoded() {
    let input = "https://example.com/?utm_source=x&q=hello%20world"
    let result = URLSanitizer().sanitize(input)
    #expect(result.cleaned == "https://example.com/?q=hello%20world")
}

@Test("case-insensitive tracking keys")
func handlesCaseInsensitive() {
    let input = "https://example.com/?UTM_Source=x"
    let result = URLSanitizer().sanitize(input)
    #expect(result.cleaned == "https://example.com/")
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL

**Step 3: Write minimal implementation**

Normalize query item names to lowercase for matching (preserve original values), and ensure fragments are preserved by URLComponents rebuild.

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS

**Step 5: Commit**

```bash
git add CleanCopy/URLSanitizer.swift CleanCopyTests/URLSanitizerTests.swift
git commit -m "fix: sanitize edge cases and preserve fragments"
```

---

### Task 4: Add a lightweight settings store

**Files:**
- Create: `CleanCopy/SettingsStore.swift`
- Modify: `CleanCopy/ClipboardMonitor.swift`
- Modify: `CleanCopy/MenuBarView.swift`
- Test: `CleanCopyTests/SettingsStoreTests.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import CleanCopy

@Suite("SettingsStore")
struct SettingsStoreTests {
    @Test("persists enabled state")
    func persistsEnabled() {
        let store = SettingsStore(userDefaults: .init(suiteName: "test")!)
        store.isEnabled = false
        let reloaded = SettingsStore(userDefaults: store.userDefaults)
        #expect(reloaded.isEnabled == false)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL

**Step 3: Write minimal implementation**

Create a `SettingsStore` wrapper around `UserDefaults` for `isEnabled` and `launchAtLogin`, inject it into `ClipboardMonitor`/`MenuBarView`, and bind toggles to it.

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS

**Step 5: Commit**

```bash
git add CleanCopy/SettingsStore.swift CleanCopy/ClipboardMonitor.swift CleanCopy/MenuBarView.swift CleanCopyTests/SettingsStoreTests.swift
git commit -m "feat: persist user settings"
```

---

### Task 5: Switch to Launch at Login via SMAppService

**Files:**
- Modify: `CleanCopy/LaunchAtLogin.swift`
- Modify: `CleanCopy/MenuBarView.swift`

**Step 1: Write the failing test**

Skip unit tests for SMAppService integration; ensure manual verification step instead.

**Step 2: Implement**

Replace plist-based LaunchAgent with `SMAppService.mainApp.register()` / `.unregister()` and `SMAppService.mainApp.status`. Keep a fallback if needed for older macOS (but target is macOS 14).

**Step 3: Manual verification**

Run: launch app → toggle “Start at Login” → confirm `System Settings > General > Login Items` shows CleanCopy.

**Step 4: Commit**

```bash
git add CleanCopy/LaunchAtLogin.swift CleanCopy/MenuBarView.swift
git commit -m "feat: use SMAppService for login item"
```

---

### Task 6: Build an app bundle and update entry points

**Files:**
- Modify: `Package.swift`
- Modify: `Makefile`
- Modify: `CleanCopy/CleanCopyApp.swift`

**Step 1: Write failing build step**

Run: `make release`
Expected: FAIL because app bundle not produced.

**Step 2: Implement**

Add a packaging script (`scripts/package_app.sh`) to build a `.app` bundle with icons and Info.plist. Update Makefile to call it and produce the DMG from `.app`.

**Step 3: Run build**

Run: `make release VERSION=vX.Y.Z NEXT_VERSION=vX.Y.Z`
Expected: `CleanCopy-vX.Y.Z-macos.dmg` created.

**Step 4: Commit**

```bash
git add Package.swift Makefile scripts/package_app.sh CleanCopy/CleanCopyApp.swift
git commit -m "build: package app bundle for release"
```

---

### Task 7: Add signing and notarization

**Files:**
- Modify: `scripts/package_app.sh`
- Modify: `Makefile`

**Step 1: Implement**

Add signing via `codesign --sign "$SIGN_IDENTITY" --options runtime --timestamp` and notarization via `xcrun notarytool submit ... --wait`, then `xcrun stapler staple`.

**Step 2: Manual verification**

Run: `spctl -a -vv CleanCopy.app`
Expected: accepted with Developer ID.

**Step 3: Commit**

```bash
git add scripts/package_app.sh Makefile
git commit -m "build: sign and notarize app bundle"
```

---

### Task 8: Update Homebrew cask for DMG app bundle

**Files:**
- Modify: `cleancopy.rb`

**Step 1: Implement**

Update `binary` to `app "CleanCopy.app"` (or `app` stanza), update URL and checksum to the notarized DMG.

**Step 2: Commit**

```bash
git add cleancopy.rb
git commit -m "release: update homebrew cask for app bundle"
```

---

### Task 9: Update tests for new behavior + coverage

**Files:**
- Modify: `CleanCopyTests/URLSanitizerTests.swift`
- Create: `CleanCopyTests/TrackingParamsTests.swift`

**Step 1: Write tests**

Add test that blocklist contains only lowercase keys and is sorted (snapshot). Add tests for multi-URL text and punctuation edge cases.

**Step 2: Run tests**

Run: `swift test`
Expected: PASS

**Step 3: Commit**

```bash
git add CleanCopyTests/URLSanitizerTests.swift CleanCopyTests/TrackingParamsTests.swift
git commit -m "test: expand tracking params coverage"
```

---

### Task 10: Redesign README and add lightweight docs

**Files:**
- Modify: `README.md`
- Create: `CONTRIBUTING.md`
- Create: `CHANGELOG.md`
- Modify: `assets/icon.png`
- Modify: `assets/tray.png`

**Step 1: Write README draft**

Include hero section, concise “why”, install options, how it works, privacy promise, screenshots, and support links (Buy Me a Coffee + GitHub Sponsors).

**Step 2: Add docs**

Create minimal CONTRIBUTING and CHANGELOG.

**Step 3: Update icons**

Replace app icon and tray icon with new identity assets.

**Step 4: Commit**

```bash
git add README.md CONTRIBUTING.md CHANGELOG.md assets/icon.png assets/tray.png
git commit -m "docs: refresh README and add lightweight docs"
```

---

### Task 11: Final verification

**Step 1: Run tests**

Run: `swift test`
Expected: PASS

**Step 2: Run release build**

Run: `make release VERSION=vX.Y.Z NEXT_VERSION=vX.Y.Z`
Expected: DMG created, notarized, and ready for release.

**Step 3: Commit (if needed)**

```bash
git add -A
git commit -m "chore: finalize production-grade release"
```
