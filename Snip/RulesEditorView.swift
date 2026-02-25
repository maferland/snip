import SwiftUI
import AppKit

struct RulesEditorView: View {
    @ObservedObject var store: TrackingParamsStore
    @State private var model: RulesEditorModel?
    @State private var newGlobalParam = ""
    @State private var newDomainName = ""
    @State private var newDomainParam: [String: String] = [:]
    @State private var newPrefixName = ""
    @State private var newPrefixParam: [String: String] = [:]

    var body: some View {
        if let model {
            content(model)
        } else {
            Color.clear.onAppear { model = RulesEditorModel(store: store) }
        }
    }

    private func content(_ model: RulesEditorModel) -> some View {
        VStack(spacing: 0) {
            Form {
                globalSection(model)
                domainScopedSection(model)
                domainPrefixSection(model)
            }
            .formStyle(.grouped)

            Divider()
            statusBar(model)
        }
        .frame(minWidth: 480, minHeight: 500)
    }

    // MARK: - Global

    private func globalSection(_ model: RulesEditorModel) -> some View {
        Section {
            ForEach(model.config.global, id: \.self) { param in
                paramRow(param) { model.removeGlobal(param) }
            }
            addField(text: $newGlobalParam, placeholder: "e.g. tracking_id") {
                model.addGlobal(newGlobalParam)
                newGlobalParam = ""
            }
        } header: {
            Label("Always Remove", systemImage: "globe")
        } footer: {
            Text("Stripped from every URL")
        }
    }

    // MARK: - Domain-Scoped

    private func domainScopedSection(_ model: RulesEditorModel) -> some View {
        Section {
            ForEach(model.config.domainScoped.keys.sorted(), id: \.self) { domain in
                DisclosureGroup {
                    ForEach(model.config.domainScoped[domain] ?? [], id: \.self) { param in
                        paramRow(param) { model.removeDomainParam(domain: domain, param: param) }
                    }
                    addField(
                        text: dictBinding(for: domain, in: $newDomainParam),
                        placeholder: "e.g. tracker"
                    ) {
                        let text = newDomainParam[domain] ?? ""
                        model.addDomainParam(domain: domain, param: text)
                        newDomainParam[domain] = ""
                    }
                } label: {
                    domainLabel(domain) { model.removeDomain(domain) }
                }
            }
            addField(text: $newDomainName, placeholder: "e.g. reddit.com") {
                model.addDomain(newDomainName)
                newDomainName = ""
            }
        } header: {
            Label("Domain-Specific", systemImage: "network")
        } footer: {
            Text("Stripped only on exact domain match")
        }
    }

    // MARK: - Domain Prefix

    private func domainPrefixSection(_ model: RulesEditorModel) -> some View {
        Section {
            ForEach(model.config.domainPrefixScoped.keys.sorted(), id: \.self) { prefix in
                DisclosureGroup {
                    ForEach(model.config.domainPrefixScoped[prefix] ?? [], id: \.self) { param in
                        paramRow(param) { model.removePrefixParam(prefix: prefix, param: param) }
                    }
                    addField(
                        text: dictBinding(for: prefix, in: $newPrefixParam),
                        placeholder: "e.g. tracker"
                    ) {
                        let text = newPrefixParam[prefix] ?? ""
                        model.addPrefixParam(prefix: prefix, param: text)
                        newPrefixParam[prefix] = ""
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(prefix).font(.system(.body, design: .monospaced))
                            Text("Matches \(prefix).com, \(prefix).ca, \(prefix).co.uk, \u{2026}")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button { model.removePrefix(prefix) } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            addField(text: $newPrefixName, placeholder: "e.g. ebay") {
                model.addPrefix(newPrefixName)
                newPrefixName = ""
            }
        } header: {
            Label("Domain Family", systemImage: "rectangle.stack")
        } footer: {
            Text("Matches all TLDs for a domain name")
        }
    }

    // MARK: - Shared Components

    private func paramRow(_ param: String, onDelete: @escaping () -> Void) -> some View {
        HStack {
            Text(param).font(.system(.body, design: .monospaced))
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
    }

    private func domainLabel(_ domain: String, onDelete: @escaping () -> Void) -> some View {
        HStack {
            Text(domain).font(.system(.body, design: .monospaced))
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
    }

    private func addField(text: Binding<String>, placeholder: String, action: @escaping () -> Void) -> some View {
        HStack {
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                .onSubmit(action)
            Button(action: action) {
                Image(systemName: "plus.circle.fill")
            }
            .disabled(text.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    private func dictBinding(for key: String, in dict: Binding<[String: String]>) -> Binding<String> {
        Binding(
            get: { dict.wrappedValue[key] ?? "" },
            set: { dict.wrappedValue[key] = $0 }
        )
    }

    // MARK: - Status Bar

    private func statusBar(_ model: RulesEditorModel) -> some View {
        HStack {
            if let error = model.errorMessage {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                Text(error).font(.caption).foregroundStyle(.red)
            } else if model.saved {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                Text("Saved").font(.caption).foregroundStyle(.green)
            } else if model.hasChanges {
                Image(systemName: "pencil.circle.fill").foregroundStyle(.orange)
                Text("Unsaved changes").font(.caption).foregroundStyle(.orange)
            }

            Spacer()

            Button("Reset to Defaults") { model.reset() }

            Button("Save") { model.save() }
                .keyboardShortcut("s")
                .disabled(!model.hasChanges)
        }
        .padding(10)
    }
}

final class RulesEditorWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?

    func show(store: TrackingParamsStore) {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = RulesEditorView(store: store)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 560),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Snip \u{2014} Tracking Rules"
        window.contentView = NSHostingView(rootView: view)
        window.delegate = self
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = window
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
    }
}
