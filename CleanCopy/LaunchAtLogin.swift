import Foundation

enum LaunchAtLogin {
    private static let plistPath: URL = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent("Library/LaunchAgents/com.maferland.CleanCopy.plist")
    }()

    private static let executablePath = "/usr/local/bin/CleanCopy"

    static var isEnabled: Bool {
        FileManager.default.fileExists(atPath: plistPath.path)
    }

    static func enable() {
        let plist: [String: Any] = [
            "Label": "com.maferland.CleanCopy",
            "ProgramArguments": [executablePath],
            "RunAtLoad": true,
            "KeepAlive": false
        ]

        // Create LaunchAgents directory if needed
        let dir = plistPath.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        // Write plist
        let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try? data?.write(to: plistPath)
    }

    static func disable() {
        try? FileManager.default.removeItem(at: plistPath)
    }

    static func toggle() {
        if isEnabled {
            disable()
        } else {
            enable()
        }
    }
}
