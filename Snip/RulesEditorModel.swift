import Foundation

@Observable
final class RulesEditorModel {
    var config: TrackingParamsConfig
    var saved = false
    var errorMessage: String?

    private let store: TrackingParamsStore
    private let originalConfig: TrackingParamsConfig

    var hasChanges: Bool { config != originalConfig }

    init(store: TrackingParamsStore) {
        self.store = store
        self.config = store.config
        self.originalConfig = store.config
    }

    // MARK: - Global

    func addGlobal(_ param: String) {
        let normalized = param.trimmedLowercased
        guard !normalized.isEmpty, !config.global.contains(normalized) else { return }
        config.global.append(normalized)
        saved = false
    }

    func removeGlobal(_ param: String) {
        config.global.removeAll { $0 == param }
        saved = false
    }

    // MARK: - Domain-Scoped

    func addDomain(_ domain: String) {
        let normalized = domain.trimmedLowercased
        guard !normalized.isEmpty, config.domainScoped[normalized] == nil else { return }
        config.domainScoped[normalized] = []
        saved = false
    }

    func removeDomain(_ domain: String) {
        config.domainScoped.removeValue(forKey: domain)
        saved = false
    }

    func addDomainParam(domain: String, param: String) {
        let normalized = param.trimmedLowercased
        guard !normalized.isEmpty, !(config.domainScoped[domain]?.contains(normalized) ?? false) else { return }
        config.domainScoped[domain, default: []].append(normalized)
        saved = false
    }

    func removeDomainParam(domain: String, param: String) {
        config.domainScoped[domain]?.removeAll { $0 == param }
        if config.domainScoped[domain]?.isEmpty == true {
            config.domainScoped.removeValue(forKey: domain)
        }
        saved = false
    }

    // MARK: - Domain Prefix

    func addPrefix(_ prefix: String) {
        let normalized = prefix.trimmedLowercased
        guard !normalized.isEmpty, config.domainPrefixScoped[normalized] == nil else { return }
        config.domainPrefixScoped[normalized] = []
        saved = false
    }

    func removePrefix(_ prefix: String) {
        config.domainPrefixScoped.removeValue(forKey: prefix)
        saved = false
    }

    func addPrefixParam(prefix: String, param: String) {
        let normalized = param.trimmedLowercased
        guard !normalized.isEmpty, !(config.domainPrefixScoped[prefix]?.contains(normalized) ?? false) else { return }
        config.domainPrefixScoped[prefix, default: []].append(normalized)
        saved = false
    }

    func removePrefixParam(prefix: String, param: String) {
        config.domainPrefixScoped[prefix]?.removeAll { $0 == param }
        if config.domainPrefixScoped[prefix]?.isEmpty == true {
            config.domainPrefixScoped.removeValue(forKey: prefix)
        }
        saved = false
    }

    // MARK: - Persistence

    func save() {
        do {
            try store.save(config: config)
            saved = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        config = .defaults
        saved = false
        errorMessage = nil
    }
}

extension String {
    var trimmedLowercased: String {
        trimmingCharacters(in: .whitespaces).lowercased()
    }
}
