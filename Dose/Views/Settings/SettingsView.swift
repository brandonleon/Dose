import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var proManager: ProManager
    @State private var showUpgrade = false

    var body: some View {
        List {
            if !proManager.isPro {
                Section {
                    Button {
                        showUpgrade = true
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.accentColor.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 17))
                                    .foregroundStyle(themeManager.accentColor)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Upgrade to Dose Pro")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Unlimited history · Long-term charts")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

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
        .sheet(isPresented: $showUpgrade) {
            ProUpgradeView()
        }
    }
}
