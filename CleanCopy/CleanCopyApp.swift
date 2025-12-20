import SwiftUI

@main
struct CleanCopyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(monitor: appDelegate.monitor)
        } label: {
            MenuBarIcon()
        }
        .menuBarExtraStyle(.window)
        .onChange(of: appDelegate.monitor.lastResult) { _, result in
            if let result, result.didChange {
                print("URL Cleaned: removed \(result.removedParams.joined(separator: ", "))")
            }
        }
    }
}

struct MenuBarIcon: View {
    var body: some View {
        if let url = Bundle.module.url(forResource: "MenuBarIcon", withExtension: "png"),
           let nsImage = NSImage(contentsOf: url) {
            nsImage.isTemplate = true
            nsImage.size = NSSize(width: 18, height: 18)
            return Image(nsImage: nsImage)
        } else {
            return Image(systemName: "link")
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
