import SwiftUI

struct MenuBarView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @ObservedObject var settings: SettingsStore
    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    var onEditRules: () -> Void
    let supportURL = URL(string: "https://buymeacoffee.com/maferland")!

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        return version.hasPrefix("v") ? version : "v\(version)"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "scissors")
                    .font(.title2)
                    .foregroundStyle(.primary)
                Text("Snip")
                    .font(.headline)
                Text(appVersion)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Circle()
                    .fill(settings.isEnabled ? .green : .gray.opacity(0.5))
                    .frame(width: 10, height: 10)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()

            // Status
            if let result = monitor.lastResult, result.didChange {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Removed \(result.removedParams.count) tracker\(result.removedParams.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)

                Divider()
            }

            // Controls
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Toggle("", isOn: $settings.isEnabled)
                        .controlSize(.small)
                        .labelsHidden()
                    Text("Enabled")
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)

                HStack {
                    Toggle("", isOn: $launchAtLogin)
                        .controlSize(.small)
                        .labelsHidden()
                        .onChange(of: launchAtLogin) { _, newValue in
                            if newValue {
                                LaunchAtLogin.enable()
                            } else {
                                LaunchAtLogin.disable()
                            }
                        }
                    Text("Start at Login")
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
            }
            .padding(.vertical, 6)

            Divider()

            // Actions
            VStack(spacing: 0) {
                Button {
                    onEditRules()
                } label: {
                    HStack {
                        Label("Edit Rules", systemImage: "slider.horizontal.3")
                        Spacer()
                    }
                }
                .buttonStyle(MenuButtonStyle())

                Button {
                    NSWorkspace.shared.open(supportURL)
                } label: {
                    HStack {
                        Label("Support", systemImage: "heart")
                        Spacer()
                        Text("\u{2615}")
                    }
                }
                .buttonStyle(MenuButtonStyle())

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    HStack {
                        Label("Quit", systemImage: "xmark.circle")
                        Spacer()
                        Text("\u{2318}Q")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(MenuButtonStyle())
                .keyboardShortcut("q")
            }
        }
        .frame(width: 220)
    }
}

struct MenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear)
            .contentShape(Rectangle())
    }
}
