import Foundation
import Testing
@testable import Snip

@Suite("RulesEditorModel")
struct RulesEditorModelTests {
    private func makeStore() -> TrackingParamsStore {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("snip-test-\(UUID().uuidString)")
            .appendingPathComponent("tracking_params.json")
        return TrackingParamsStore(url: url)
    }

    private func makeModel(store: TrackingParamsStore? = nil) -> (RulesEditorModel, TrackingParamsStore) {
        let s = store ?? makeStore()
        return (RulesEditorModel(store: s), s)
    }

    // MARK: - Global

    @Test("adds global param")
    func addGlobal() {
        let (model, _) = makeModel()
        let countBefore = model.config.global.count
        model.addGlobal("new_tracker")
        #expect(model.config.global.contains("new_tracker"))
        #expect(model.config.global.count == countBefore + 1)
    }

    @Test("prevents duplicate global param")
    func addGlobalDuplicate() {
        let (model, _) = makeModel()
        model.addGlobal("dup")
        let count = model.config.global.count
        model.addGlobal("dup")
        #expect(model.config.global.count == count)
    }

    @Test("normalizes global param to lowercase")
    func addGlobalNormalizesCase() {
        let (model, _) = makeModel()
        model.addGlobal("  UTM_TEST  ")
        #expect(model.config.global.contains("utm_test"))
    }

    @Test("ignores empty global param")
    func addGlobalEmpty() {
        let (model, _) = makeModel()
        let count = model.config.global.count
        model.addGlobal("  ")
        #expect(model.config.global.count == count)
    }

    @Test("removes global param")
    func removeGlobal() {
        let (model, _) = makeModel()
        model.addGlobal("removeme")
        model.removeGlobal("removeme")
        #expect(!model.config.global.contains("removeme"))
    }

    // MARK: - Domain-Scoped

    @Test("adds domain")
    func addDomain() {
        let (model, _) = makeModel()
        model.addDomain("example.com")
        #expect(model.config.domainScoped["example.com"] != nil)
    }

    @Test("prevents duplicate domain")
    func addDomainDuplicate() {
        let (model, _) = makeModel()
        model.addDomain("example.com")
        model.addDomain("example.com")
        #expect(model.config.domainScoped["example.com"] == [])
    }

    @Test("normalizes domain to lowercase")
    func addDomainNormalizesCase() {
        let (model, _) = makeModel()
        model.addDomain("  EXAMPLE.COM  ")
        #expect(model.config.domainScoped["example.com"] != nil)
    }

    @Test("removes domain")
    func removeDomain() {
        let (model, _) = makeModel()
        model.addDomain("example.com")
        model.removeDomain("example.com")
        #expect(model.config.domainScoped["example.com"] == nil)
    }

    @Test("adds domain param")
    func addDomainParam() {
        let (model, _) = makeModel()
        model.addDomain("example.com")
        model.addDomainParam(domain: "example.com", param: "tracker")
        #expect(model.config.domainScoped["example.com"] == ["tracker"])
    }

    @Test("prevents duplicate domain param")
    func addDomainParamDuplicate() {
        let (model, _) = makeModel()
        model.addDomain("example.com")
        model.addDomainParam(domain: "example.com", param: "dup")
        model.addDomainParam(domain: "example.com", param: "dup")
        #expect(model.config.domainScoped["example.com"] == ["dup"])
    }

    @Test("removes domain param")
    func removeDomainParam() {
        let (model, _) = makeModel()
        model.addDomain("example.com")
        model.addDomainParam(domain: "example.com", param: "tracker")
        model.removeDomainParam(domain: "example.com", param: "tracker")
        // Domain auto-removed when last param deleted
        #expect(model.config.domainScoped["example.com"] == nil)
    }

    @Test("auto-removes domain when last param deleted")
    func removeDomainParamAutoRemovesDomain() {
        let (model, _) = makeModel()
        model.addDomain("example.com")
        model.addDomainParam(domain: "example.com", param: "a")
        model.addDomainParam(domain: "example.com", param: "b")
        model.removeDomainParam(domain: "example.com", param: "a")
        #expect(model.config.domainScoped["example.com"] == ["b"])
        model.removeDomainParam(domain: "example.com", param: "b")
        #expect(model.config.domainScoped["example.com"] == nil)
    }

    // MARK: - Domain Prefix

    @Test("adds prefix")
    func addPrefix() {
        let (model, _) = makeModel()
        model.addPrefix("ebay")
        #expect(model.config.domainPrefixScoped["ebay"] != nil)
    }

    @Test("prevents duplicate prefix")
    func addPrefixDuplicate() {
        let (model, _) = makeModel()
        model.addPrefix("ebay")
        model.addPrefix("ebay")
        #expect(model.config.domainPrefixScoped["ebay"] == [])
    }

    @Test("removes prefix")
    func removePrefix() {
        let (model, _) = makeModel()
        model.addPrefix("ebay")
        model.removePrefix("ebay")
        #expect(model.config.domainPrefixScoped["ebay"] == nil)
    }

    @Test("adds prefix param")
    func addPrefixParam() {
        let (model, _) = makeModel()
        model.addPrefix("ebay")
        model.addPrefixParam(prefix: "ebay", param: "tracker")
        #expect(model.config.domainPrefixScoped["ebay"] == ["tracker"])
    }

    @Test("prevents duplicate prefix param")
    func addPrefixParamDuplicate() {
        let (model, _) = makeModel()
        model.addPrefix("ebay")
        model.addPrefixParam(prefix: "ebay", param: "dup")
        model.addPrefixParam(prefix: "ebay", param: "dup")
        #expect(model.config.domainPrefixScoped["ebay"] == ["dup"])
    }

    @Test("removes prefix param and auto-removes prefix")
    func removePrefixParam() {
        let (model, _) = makeModel()
        model.addPrefix("ebay")
        model.addPrefixParam(prefix: "ebay", param: "tracker")
        model.removePrefixParam(prefix: "ebay", param: "tracker")
        #expect(model.config.domainPrefixScoped["ebay"] == nil)
    }

    // MARK: - Persistence

    @Test("save persists to store")
    func savePersists() {
        let (model, store) = makeModel()
        model.addGlobal("persisted_param")
        model.save()
        #expect(model.saved)
        #expect(model.errorMessage == nil)
        #expect(store.config.global.contains("persisted_param"))
    }

    @Test("reset restores defaults")
    func resetRestoresDefaults() {
        let (model, _) = makeModel()
        model.addGlobal("temp")
        model.reset()
        #expect(model.config == .defaults)
        #expect(!model.saved)
        #expect(model.errorMessage == nil)
    }

    // MARK: - hasChanges

    @Test("hasChanges is false initially")
    func hasChangesInitiallyFalse() {
        let (model, _) = makeModel()
        #expect(!model.hasChanges)
    }

    @Test("hasChanges is true after mutation")
    func hasChangesTrueAfterMutation() {
        let (model, _) = makeModel()
        model.addGlobal("new")
        #expect(model.hasChanges)
    }
}
