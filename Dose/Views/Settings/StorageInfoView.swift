import SwiftUI

struct StorageInfoView: View {
    @State private var currentLocation: StorageLocation = StoragePreference.load() ?? .localOnly
    @State private var pendingLocation: StorageLocation? = nil
    @State private var showConfirmation = false
    @State private var showRestartBanner = false

    var body: some View {
        List {
            Section {
                ForEach(StorageLocation.allCases, id: \.rawValue) { location in
                    StorageOptionRow(
                        location: location,
                        isSelected: currentLocation == location,
                        onTap: {
                            if location != currentLocation {
                                pendingLocation = location
                                showConfirmation = true
                            }
                        }
                    )
                }
            } header: {
                Text("Storage Location")
            } footer: {
                Text("Your data file stays in the same place on your device. Changing to iCloud adds encrypted sync — switching back stops syncing but keeps all your data intact.")
            }

            if showRestartBanner {
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Restart Required")
                                .font(.subheadline.weight(.semibold))
                            Text("Close and reopen Dose to apply your new storage setting.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            currentDetailsSection

            Section {
                NavigationLink("Export Data First") {
                    ExportView()
                }
            } header: {
                Text("Before Switching")
            } footer: {
                Text("Exporting a CSV backup before switching is a good precaution, though your data is preserved during the transition.")
            }
        }
        .navigationTitle("Data Storage")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            confirmationTitle,
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button(confirmationActionLabel, role: .none) {
                applyChange()
            }
            Button("Cancel", role: .cancel) {
                pendingLocation = nil
            }
        } message: {
            Text(confirmationMessage)
        }
    }

    // MARK: - Current Details

    @ViewBuilder
    private var currentDetailsSection: some View {
        let details = detailsFor(currentLocation)
        Section {
            ForEach(details, id: \.title) { item in
                detailRow(icon: item.icon, iconColor: item.color, title: item.title, detail: item.detail)
            }
        } header: {
            Text("\(currentLocation.displayName) — Details")
        }
    }

    // MARK: - Apply Change

    private func applyChange() {
        guard let next = pendingLocation else { return }
        StoragePreference.save(next)
        withAnimation {
            currentLocation = next
            showRestartBanner = true
        }
        pendingLocation = nil
    }

    // MARK: - Confirmation Copy

    private var confirmationTitle: String {
        guard let next = pendingLocation else { return "Change Storage?" }
        switch next {
        case .iCloud:
            return "Switch to iCloud?"
        case .localOnly:
            return "Switch to Local Device?"
        }
    }

    private var confirmationActionLabel: String {
        guard let next = pendingLocation else { return "Switch" }
        return "Switch to \(next.displayName)"
    }

    private var confirmationMessage: String {
        guard let next = pendingLocation else { return "" }
        switch next {
        case .iCloud:
            return "Your data stays on your device and will also sync to iCloud, encrypted and accessible only by you. The change takes effect after you restart Dose."
        case .localOnly:
            return "iCloud sync will stop. Your data remains intact on this device. Data already in iCloud is unaffected. The change takes effect after you restart Dose."
        }
    }

    // MARK: - Detail Items

    private struct DetailItem {
        let icon: String
        let color: Color
        let title: String
        let detail: String
    }

    private func detailsFor(_ location: StorageLocation) -> [DetailItem] {
        switch location {
        case .iCloud:
            return [
                DetailItem(icon: "lock.fill", color: .green, title: "End-to-End Encrypted", detail: "Apple cannot read your data. Only you can access it."),
                DetailItem(icon: "arrow.triangle.2.circlepath", color: .blue, title: "Syncs Across Devices", detail: "Data appears on all Apple devices signed in with your Apple ID."),
                DetailItem(icon: "externaldrive.badge.checkmark", color: .teal, title: "Automatic Backup", detail: "Safe even if your device is lost, stolen, or reset."),
                DetailItem(icon: "person.fill.checkmark", color: .purple, title: "Your Data Only", detail: "Dose has no server access. Your Apple ID is the only gate."),
            ]
        case .localOnly:
            return [
                DetailItem(icon: "nosign", color: .green, title: "Never Leaves This Device", detail: "Stored in your device's secure App Group container. Never transmitted."),
                DetailItem(icon: "xmark.icloud", color: .orange, title: "No Cloud Account Needed", detail: "Works fully offline and without an Apple ID."),
                DetailItem(icon: "exclamationmark.triangle", color: .yellow, title: "No Automatic Backup", detail: "Data is lost if your device is lost or reset without a local backup."),
                DetailItem(icon: "arrow.down.to.line", color: .blue, title: "Manual Export Available", detail: "Use Export in Settings to create a CSV backup anytime."),
            ]
        }
    }

    // MARK: - Helper Views

    private func detailRow(icon: String, iconColor: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(iconColor)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - StorageOptionRow

private struct StorageOptionRow: View {
    let location: StorageLocation
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 17))
                        .foregroundStyle(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(location.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(tagline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.green : Color.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var icon: String {
        location == .iCloud ? "icloud.fill" : "iphone"
    }

    private var iconColor: Color {
        location == .iCloud ? .blue : .orange
    }

    private var tagline: String {
        location == .iCloud ? "Encrypted. Backed up. Private." : "Stays on this device only."
    }
}

#Preview {
    NavigationStack {
        StorageInfoView()
    }
}
