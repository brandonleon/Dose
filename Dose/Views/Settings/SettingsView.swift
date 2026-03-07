import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        List {
            Section("Appearance") {
                NavigationLink("Accent Color") {
                    ThemePickerView()
                }

                HStack {
                    Text("Current")
                    Spacer()
                    Circle()
                        .fill(themeManager.accentColor)
                        .frame(width: 24, height: 24)
                    Text(themeManager.selectedAccent.displayName)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Data") {
                NavigationLink("Export Data") {
                    ExportView()
                }
                NavigationLink("Data Storage") {
                    StorageInfoView()
                }
            }

            Section("Strain Library") {
                NavigationLink("Manage Strains") {
                    StrainLibraryView()
                }
            }

            Section("About") {
                NavigationLink("About Dose") {
                    AboutView()
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
