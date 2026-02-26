import Foundation
import Combine

final class TrackingParamsStore: ObservableObject {
    @Published private(set) var config: TrackingParamsConfig

    private let fileURL: URL

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    static var defaultURL: URL {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return FileManager.default.temporaryDirectory
                .appendingPathComponent("Snip")
                .appendingPathComponent("tracking_params.json")
        }
        return appSupport
            .appendingPathComponent("Snip")
            .appendingPathComponent("tracking_params.json")
    }

    init(url: URL = TrackingParamsStore.defaultURL) {
        self.fileURL = url
        if let data = try? Data(contentsOf: url),
           let config = try? JSONDecoder().decode(TrackingParamsConfig.self, from: data) {
            self.config = config
        } else {
            self.config = .defaults
        }
    }

    var jsonString: String {
        guard let data = try? Self.encoder.encode(config),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    func save(json: String) throws {
        guard let data = json.data(using: .utf8) else {
            throw ConfigError.invalidJSON
        }
        let newConfig = try JSONDecoder().decode(TrackingParamsConfig.self, from: data)
        try write(newConfig)
        config = newConfig
    }

    func save(config: TrackingParamsConfig) throws {
        try write(config)
        self.config = config
    }

    func reset() throws {
        try write(.defaults)
        config = .defaults
    }

    private func write(_ config: TrackingParamsConfig) throws {
        let data = try Self.encoder.encode(config)
        let dir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try data.write(to: fileURL)
    }

    enum ConfigError: LocalizedError {
        case invalidJSON

        var errorDescription: String? {
            switch self {
            case .invalidJSON: return "Invalid JSON"
            }
        }
    }
}
