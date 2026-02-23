import Foundation

struct SanitizeResult: Equatable {
    let cleaned: String
    let removedParams: [String]

    var didChange: Bool { !removedParams.isEmpty }
}

final class URLSanitizer {
    func sanitize(_ text: String) -> SanitizeResult {
        var removedParams: [String] = []
        var result = text

        // Find all URLs in text
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return SanitizeResult(cleaned: text, removedParams: [])
        }

        let matches = detector.matches(in: text, range: NSRange(text.startIndex..., in: text))

        // Process in reverse to preserve string indices
        for match in matches.reversed() {
            guard let range = Range(match.range, in: text),
                  let url = match.url,
                  var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                continue
            }

            let host = components.host?.lowercased()
            let domainParams = host.flatMap { TrackingParams.domainScoped[$0] } ?? []

            let originalItems = components.queryItems ?? []
            let filteredItems = originalItems.filter { item in
                let key = item.name.lowercased()
                return !TrackingParams.blocklist.contains(key) && !domainParams.contains(key)
            }

            let removed = originalItems.filter {
                let key = $0.name.lowercased()
                return TrackingParams.blocklist.contains(key) || domainParams.contains(key)
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
}
