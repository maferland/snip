import SwiftUI
import os

private let logger = Logger(subsystem: "com.snip.app", category: "SnipApp")

@main
struct SnipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                monitor: appDelegate.monitor,
                settings: appDelegate.monitor.settings,
                onEditRules: { appDelegate.rulesEditor.show(store: appDelegate.monitor.trackingStore) }
            )
            .toggleStyle(.switch)
        } label: {
            Image(systemName: "scissors")
        }
        .menuBarExtraStyle(.window)
        .onChange(of: appDelegate.monitor.lastResult) { _, result in
            if let result, result.didChange {
                logger.info("URL Cleaned: removed \(result.removedParams.joined(separator: ", "))")
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let monitor = ClipboardMonitor()
    let rulesEditor = RulesEditorWindowController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let idx = CommandLine.arguments.firstIndex(of: "--screenshot") {
            let output = CommandLine.arguments.dropFirst(idx + 1).first ?? "snip-screenshot.png"
            ScreenshotGenerator.generate(outputPath: output)
            NSApp.terminate(nil)
            return
        }

        NSApp.setActivationPolicy(.accessory)
        monitor.start()
    }
}
