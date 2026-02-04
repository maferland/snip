import SwiftUI

@main
struct SnipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(monitor: appDelegate.monitor, settings: appDelegate.monitor.settings)
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

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        monitor.start()
    }
}
