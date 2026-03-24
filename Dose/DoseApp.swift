import SwiftUI
import SwiftData

@main
struct DoseApp: App {
    @StateObject private var themeManager = ThemeManager()
    @State private var showQuickLog = false

    var body: some Scene {
        WindowGroup {
            ContentView(showQuickLog: $showQuickLog)
                .environmentObject(themeManager)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    if url.scheme == "kanalog" && url.host == "quicklog" {
                        showQuickLog = true
                    }
                }
        }
        .modelContainer(PersistenceConfiguration.sharedModelContainer)
    }
}
