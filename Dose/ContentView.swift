import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var showQuickLog: Bool

    var body: some View {
        TabView {
            NavigationStack { DashboardView(showQuickLog: $showQuickLog) }
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            NavigationStack { PainJournalView() }
                .tabItem { Label("Journal", systemImage: "book.fill") }
            NavigationStack { TBreakView() }
                .tabItem { Label("T-Break", systemImage: "timer") }
            NavigationStack { StatsView() }
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(themeManager.accentColor)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
