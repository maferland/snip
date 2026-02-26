import Foundation

struct SanitizeResult: Equatable {
    let cleaned: String
    let removedParams: [String]

    var didChange: Bool { !removedParams.isEmpty }
}

final class URLSanitizer {
    private let detector: NSDataDetector?

    init() {
        self.detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    }

    func sanitize(_ text: String, config: TrackingParamsConfig = .defaults) -> SanitizeResult {
        guard let detector else {
            return SanitizeResult(cleaned: text, removedParams: [])
        }

        var removedParams: [String] = []
        var result = text

        let matches = detector.matches(in: text, range: NSRange(text.startIndex..., in: text))
        let globalBlocklist = Set(config.global)

        for match in matches.reversed() {
            guard let range = Range(match.range, in: text),
                  let url = match.url,
                  var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                continue
            }

            let host = components.host?.lowercased()
                .replacingOccurrences(of: "www.", with: "")
            let domainParams = domainParamsFor(host: host ?? "", config: config)

            let originalItems = components.queryItems ?? []
            let filteredItems = originalItems.filter { item in
                let key = item.name.lowercased()
                return !globalBlocklist.contains(key) && !domainParams.contains(key)
            }

            let removed = originalItems.filter {
                let key = $0.name.lowercased()
                return globalBlocklist.contains(key) || domainParams.contains(key)
            }.map(\.name)
            removedParams.append(contentsOf: removed)

            if removed.isEmpty { continue }

            components.queryItems = filteredItems.isEmpty ? nil : filteredItems

            if let cleanedURL = components.url?.absoluteString {
                result.replaceSubrange(range, with: cleanedURL)
            }
        }

        return SanitizeResult(cleaned: result, removedParams: removedParams)
    }

    private func domainParamsFor(host: String, config: TrackingParamsConfig) -> Set<String> {
        var params = Set(config.domainScoped[host] ?? [])
        for (prefix, prefixParams) in config.domainPrefixScoped {
            if host.hasPrefix(prefix + ".") {
                params.formUnion(prefixParams)
            }
        }
        return params
    }
}
