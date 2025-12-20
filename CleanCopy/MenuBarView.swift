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
