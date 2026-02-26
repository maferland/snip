import AppKit
import SwiftUI

private final class StubClipboardProvider: ClipboardProvider {
    var changeCount: Int { 0 }
    func string() -> String? { nil }
    func setString(_ string: String) {}
}

private struct RenderedSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ZStack {
                Capsule()
                    .fill(configuration.isOn ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 32, height: 20)
                Circle()
                    .fill(.white)
                    .shadow(radius: 1)
                    .frame(width: 16, height: 16)
                    .offset(x: configuration.isOn ? 6 : -6)
            }
            configuration.label
        }
        .onTapGesture { configuration.isOn.toggle() }
    }
}

enum ScreenshotGenerator {
    @MainActor static func generate(outputPath: String, scale: CGFloat = 3.0) {
        let settings = SettingsStore(userDefaults: UserDefaults(suiteName: "screenshot-\(UUID())") ?? .standard)
        settings.isEnabled = true

        let store = TrackingParamsStore(url: URL(filePath: "/dev/null"))
        let monitor = ClipboardMonitor(
            provider: StubClipboardProvider(),
            settings: settings,
            trackingStore: store
        )
        monitor.lastResult = SanitizeResult(
            cleaned: "https://amazon.ca/dp/1984855743",
            removedParams: ["utm_source", "fbclid", "gclid"]
        )

        let view = MenuBarView(monitor: monitor, settings: settings, onEditRules: {})
            .toggleStyle(RenderedSwitchStyle())
            .background(Color(nsColor: .windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(4)
            .environment(\.colorScheme, .dark)

        let renderer = ImageRenderer(content: view)
        renderer.scale = scale

        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:])
        else {
            fputs("Failed to render screenshot\n", stderr)
            exit(1)
        }

        do {
            let url = URL(filePath: outputPath)
            try png.write(to: url)
            print("Screenshot saved to \(outputPath) (\(Int(scale))x)")
        } catch {
            fputs("Failed to write: \(error)\n", stderr)
            exit(1)
        }
    }
}
