import SwiftUI

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
        } label: {
            Image(systemName: "scissors")
        }
        .menuBarExtraStyle(.window)
        .onChange(of: appDelegate.monitor.lastResult) { _, result in
            if let result, result.didChange {
                print("URL Cleaned: removed \(result.removedParams.joined(separator: ", "))")
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let monitor = ClipboardMonitor()
    let rulesEditor = RulesEditorWindowController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        monitor.start()
    }
}
