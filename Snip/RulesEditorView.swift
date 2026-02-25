import SwiftUI
import AppKit

struct RulesEditorView: View {
    @ObservedObject var store: TrackingParamsStore
    @State private var config: TrackingParamsConfig = .defaults
    @State private var newGlobalParam = ""
    @State private var newDomainName = ""
    @State private var newDomainParam: [String: String] = [:]
    @State private var newPrefixName = ""
    @State private var newPrefixParam: [String: String] = [:]
    @State private var saved = false
    @State private var errorMessage: String?

    private var hasChanges: Bool { config != store.config }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                globalSection
                domainScopedSection
                domainPrefixSection
            }
            .formStyle(.grouped)

            Divider()
            statusBar
        }
        .frame(minWidth: 480, minHeight: 500)
        .onAppear { config = store.config }
    }

    // MARK: - Global

    private var globalSection: some View {
        Section {
            ForEach(config.global, id: \.self) { param in
                paramRow(param) { removeGlobal(param) }
            }
            addField(text: $newGlobalParam, placeholder: "e.g. tracking_id", action: addGlobal)
        } header: {
            Label("Always Remove", systemImage: "globe")
        } footer: {
            Text("Stripped from every URL")
        }
    }

    private func addGlobal() {
        let param = newGlobalParam.trimmedLowercased
        guard !param.isEmpty, !config.global.contains(param) else { return }
        config.global.append(param)
        newGlobalParam = ""
        saved = false
    }

    private func removeGlobal(_ param: String) {
        config.global.removeAll { $0 == param }
        saved = false
    }

    // MARK: - Domain-Scoped

    private var domainScopedSection: some View {
        Section {
            ForEach(config.domainScoped.keys.sorted(), id: \.self) { domain in
                DisclosureGroup {
                    ForEach(config.domainScoped[domain] ?? [], id: \.self) { param in
                        paramRow(param) { removeDomainParam(domain: domain, param: param) }
                    }
                    addField(
                        text: dictBinding(for: domain, in: $newDomainParam),
                        placeholder: "e.g. tracker",
                        action: { addDomainParam(domain: domain) }
                    )
                } label: {
                    domainLabel(domain) { removeDomain(domain) }
                }
            }
            addField(text: $newDomainName, placeholder: "e.g. reddit.com", action: addDomain)
        } header: {
            Label("Domain-Specific", systemImage: "network")
        } footer: {
            Text("Stripped only on exact domain match")
        }
    }

    private func addDomain() {
        let domain = newDomainName.trimmedLowercased
        guard !domain.isEmpty, config.domainScoped[domain] == nil else { return }
        config.domainScoped[domain] = []
        newDomainName = ""
        saved = false
    }

    private func removeDomain(_ domain: String) {
        config.domainScoped.removeValue(forKey: domain)
        newDomainParam.removeValue(forKey: domain)
        saved = false
    }

    private func addDomainParam(domain: String) {
        let param = (newDomainParam[domain] ?? "").trimmedLowercased
        guard !param.isEmpty, !(config.domainScoped[domain]?.contains(param) ?? false) else { return }
        config.domainScoped[domain, default: []].append(param)
        newDomainParam[domain] = ""
        saved = false
    }

    private func removeDomainParam(domain: String, param: String) {
        config.domainScoped[domain]?.removeAll { $0 == param }
        if config.domainScoped[domain]?.isEmpty == true {
            config.domainScoped.removeValue(forKey: domain)
        }
        saved = false
    }

    // MARK: - Domain Prefix

    private var domainPrefixSection: some View {
        Section {
            ForEach(config.domainPrefixScoped.keys.sorted(), id: \.self) { prefix in
                DisclosureGroup {
                    ForEach(config.domainPrefixScoped[prefix] ?? [], id: \.self) { param in
                        paramRow(param) { removePrefixParam(prefix: prefix, param: param) }
                    }
                    addField(
                        text: dictBinding(for: prefix, in: $newPrefixParam),
                        placeholder: "e.g. tracker",
                        action: { addPrefixParam(prefix: prefix) }
                    )
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(prefix).font(.system(.body, design: .monospaced))
                            Text("Matches \(prefix).com, \(prefix).ca, \(prefix).co.uk, \u{2026}")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button { removePrefix(prefix) } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            addField(text: $newPrefixName, placeholder: "e.g. ebay", action: addPrefix)
        } header: {
            Label("Domain Family", systemImage: "rectangle.stack")
        } footer: {
            Text("Matches all TLDs for a domain name")
        }
    }

    private func addPrefix() {
        let prefix = newPrefixName.trimmedLowercased
        guard !prefix.isEmpty, config.domainPrefixScoped[prefix] == nil else { return }
        config.domainPrefixScoped[prefix] = []
        newPrefixName = ""
        saved = false
    }

    private func removePrefix(_ prefix: String) {
        config.domainPrefixScoped.removeValue(forKey: prefix)
        newPrefixParam.removeValue(forKey: prefix)
        saved = false
    }

    private func addPrefixParam(prefix: String) {
        let param = (newPrefixParam[prefix] ?? "").trimmedLowercased
        guard !param.isEmpty, !(config.domainPrefixScoped[prefix]?.contains(param) ?? false) else { return }
        config.domainPrefixScoped[prefix, default: []].append(param)
        newPrefixParam[prefix] = ""
        saved = false
    }

    private func removePrefixParam(prefix: String, param: String) {
        config.domainPrefixScoped[prefix]?.removeAll { $0 == param }
        if config.domainPrefixScoped[prefix]?.isEmpty == true {
            config.domainPrefixScoped.removeValue(forKey: prefix)
        }
        saved = false
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

    private var statusBar: some View {
        HStack {
            if let error = errorMessage {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                Text(error).font(.caption).foregroundStyle(.red)
            } else if saved {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                Text("Saved").font(.caption).foregroundStyle(.green)
            } else if hasChanges {
                Image(systemName: "pencil.circle.fill").foregroundStyle(.orange)
                Text("Unsaved changes").font(.caption).foregroundStyle(.orange)
            }

            Spacer()

            Button("Reset to Defaults") {
                config = .defaults
                saved = false
                errorMessage = nil
            }

            Button("Save") { save() }
                .keyboardShortcut("s")
                .disabled(!hasChanges)
        }
        .padding(10)
    }

    private func save() {
        do {
            try store.save(config: config)
            saved = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private extension String {
    var trimmedLowercased: String {
        trimmingCharacters(in: .whitespaces).lowercased()
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
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 560),
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
