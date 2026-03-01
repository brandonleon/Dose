import SwiftData

enum PersistenceConfiguration {
    static let schema = Schema([
        Session.self,
        Strain.self,
        PainEntry.self,
        TBreak.self
    ])

    static let sharedModelContainer: ModelContainer = {
        let config = ModelConfiguration(
            schema: schema,
            url: SharedContainer.containerURL.appending(path: "Dose.store"),
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
