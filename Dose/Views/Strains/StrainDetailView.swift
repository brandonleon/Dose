import SwiftUI

struct StrainDetailView: View {
    @Bindable var strain: Strain
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showEdit = false

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Type")
                    Spacer()
                    Text(strain.strainType.displayName)
                        .foregroundStyle(.secondary)
                }

                if let thc = strain.thcPercentage {
                    HStack {
                        Text("THC")
                        Spacer()
                        Text("\(String(format: "%.1f", thc))%")
                            .foregroundStyle(.secondary)
                    }
                }

                if let cbd = strain.cbdPercentage {
                    HStack {
                        Text("CBD")
                        Spacer()
                        Text("\(String(format: "%.1f", cbd))%")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !strain.notes.isEmpty {
                Section("Notes") {
                    Text(strain.notes)
                }
            }

            Section("Sessions (\(strain.sessions.count))") {
                if strain.sessions.isEmpty {
                    Text("No sessions with this strain yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(strain.sessions.sorted(by: { $0.timestamp > $1.timestamp }).prefix(10), id: \.self) { session in
                        HStack {
                            Image(systemName: session.dosageMethod.iconName)
                                .foregroundStyle(themeManager.accentColor)
                            Text(session.dosageMethod.displayName)
                            Spacer()
                            Text(DateFormatters.mediumDateTime.string(from: session.timestamp))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(strain.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showEdit = true } label: {
                    Text("Edit")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    strain.isFavorite.toggle()
                } label: {
                    Image(systemName: strain.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(strain.isFavorite ? .yellow : .secondary)
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            StrainFormView(strain: strain)
        }
    }
}
