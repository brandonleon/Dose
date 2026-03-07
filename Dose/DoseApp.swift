import SwiftUI
import SwiftData

@main
struct DoseApp: App {
    @StateObject private var themeManager = ThemeManager()
    @State private var showQuickLog = false

    // Resolved on every launch from saved preference; nil only on very first launch.
    @State private var storageLocation: StorageLocation? = StoragePreference.load()
    @State private var modelContainer: ModelContainer? = StoragePreference.load().map {
        StoragePreference.makeContainer(for: $0)
    }

    var body: some Scene {
        WindowGroup {
            if let container = modelContainer {
                ContentView(showQuickLog: $showQuickLog)
                    .environmentObject(themeManager)
                    .preferredColorScheme(.dark)
                    .modelContainer(container)
                    .onOpenURL { url in
                        if url.scheme == "dose" && url.host == "quicklog" {
                            showQuickLog = true
                        }
                    }
            } else {
                StorageOnboardingView { chosen in
                    StoragePreference.save(chosen)
                    storageLocation = chosen
                    modelContainer = StoragePreference.makeContainer(for: chosen)
                }
            }
        }
    }
}
