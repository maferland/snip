import SwiftUI
import UserNotifications

@main
struct CleanCopyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(monitor: appDelegate.monitor)
        } label: {
            Image(systemName: "link")
        }
        .menuBarExtraStyle(.window)
        .onChange(of: appDelegate.monitor.lastResult) { _, result in
            if let result, result.didChange {
                showNotification(result: result)
            }
        }
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

class AppDelegate: NSObject, NSApplicationDelegate {
    let monitor = ClipboardMonitor()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - makes app menu bar only
        NSApp.setActivationPolicy(.accessory)

        monitor.start()
        requestNotificationPermission()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}
