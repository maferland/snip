import SwiftUI
import AppKit

struct RulesEditorView: View {
    @ObservedObject var store: TrackingParamsStore
    @State private var jsonText = ""
    @State private var errorMessage: String?
    @State private var saved = false

    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $jsonText)
                .font(.system(.body, design: .monospaced))
                .onChange(of: jsonText) { _, _ in
                    errorMessage = nil
                    saved = false
                }

            Divider()

            HStack {
                if let error = errorMessage {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                } else if saved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Saved")
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                Spacer()

                Button("Reset to Defaults") {
                    do {
                        try store.reset()
                        jsonText = store.jsonString
                        saved = false
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }

                Button("Save") {
                    do {
                        try store.save(json: jsonText)
                        jsonText = store.jsonString
                        saved = true
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
                .keyboardShortcut("s")
            }
            .padding(10)
        }
        .frame(minWidth: 480, minHeight: 400)
        .onAppear {
            jsonText = store.jsonString
        }
    }
}

final class RulesEditorWindowController {
    private var window: NSWindow?

    func show(store: TrackingParamsStore) {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = RulesEditorView(store: store)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 500),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Snip \u{2014} Tracking Rules"
        window.contentView = NSHostingView(rootView: view)
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = window
    }
}
