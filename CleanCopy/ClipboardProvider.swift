import AppKit

protocol ClipboardProvider: AnyObject {
    var changeCount: Int { get }
    func string() -> String?
    func setString(_ string: String)
}

final class SystemClipboardProvider: ClipboardProvider {
    private let pasteboard = NSPasteboard.general

    var changeCount: Int { pasteboard.changeCount }

    func string() -> String? {
        pasteboard.string(forType: .string)
    }

    func setString(_ string: String) {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }
}
