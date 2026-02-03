import Foundation
import Combine

final class SettingsStore: ObservableObject {
    private let userDefaults: UserDefaults
    private static let isEnabledKey = "isEnabled"

    @Published var isEnabled: Bool {
        didSet {
            userDefaults.set(isEnabled, forKey: Self.isEnabledKey)
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if userDefaults.object(forKey: Self.isEnabledKey) == nil {
            self.isEnabled = true
        } else {
            self.isEnabled = userDefaults.bool(forKey: Self.isEnabledKey)
        }
    }
}
