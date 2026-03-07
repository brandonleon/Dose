import SwiftData
import Foundation

enum StorageLocation: String, CaseIterable {
    case iCloud = "iCloud"
    case localOnly = "localOnly"

    var displayName: String {
        switch self {
        case .iCloud: return "iCloud"
        case .localOnly: return "Local Device Only"
        }
    }
}

enum StoragePreference {
    static let userDefaultsKey = "storageLocation"

    static func load() -> StorageLocation? {
        guard let raw = SharedContainer.sharedDefaults.string(forKey: userDefaultsKey) else { return nil }
        return StorageLocation(rawValue: raw)
    }

    static func save(_ location: StorageLocation) {
        SharedContainer.sharedDefaults.set(location.rawValue, forKey: userDefaultsKey)
    }

    static func makeContainer(for location: StorageLocation) -> ModelContainer {
        let url = SharedContainer.containerURL.appending(path: "Dose.store")
        let cloudKit: ModelConfiguration.CloudKitDatabase = location == .iCloud
            ? .private("iCloud.com.brandonleon.Dose")
            : .none
        let config = ModelConfiguration(
            schema: PersistenceConfiguration.schema,
            url: url,
            cloudKitDatabase: cloudKit
        )
        do {
            return try ModelContainer(for: PersistenceConfiguration.schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
