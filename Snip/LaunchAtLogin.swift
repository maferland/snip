import ServiceManagement
import os

enum LaunchAtLogin {
    private static let logger = Logger(subsystem: "com.snip.app", category: "LaunchAtLogin")

    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func enable() {
        do {
            try SMAppService.mainApp.register()
        } catch {
            logger.error("Failed to enable launch at login: \(error.localizedDescription)")
        }
    }

    static func disable() {
        do {
            try SMAppService.mainApp.unregister()
        } catch {
            logger.error("Failed to disable launch at login: \(error.localizedDescription)")
        }
    }
}
