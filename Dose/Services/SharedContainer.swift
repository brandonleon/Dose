import Foundation

enum SharedContainer {
    static let appGroupIdentifier = "group.com.brandonleon.Dose"

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    static var containerURL: URL {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) ?? URL.documentsDirectory
    }
}
