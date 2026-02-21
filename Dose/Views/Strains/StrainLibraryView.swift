import SwiftUI
import SwiftData

struct StrainLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @Query(sort: \Strain.name) private var strains: [Strain]
    @State private var showAddStrain = false
    @State private var searchText = ""

    private var filteredStrains: [Strain] {
        if searchText.isEmpty { return strains }
        return strains.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var favorites: [Strain] {
        filteredStrains.filter(\.isFavorite)
    }

    private var others: [Strain] {
        filteredStrains.filter { !$0.isFavorite }
    }

    var body: some View {
        List {
            if !favorites.isEmpty {
                Section("Favorites") {
                    ForEach(favorites) { strain in
                        NavigationLink(value: strain) {
                            strainRow(strain)
                        }
                    }
                    .onDelete { offsets in
                        delete(from: favorites, at: offsets)
                    }
                }
            }

            Section(favorites.isEmpty ? "Strains" : "Other") {
                ForEach(others) { strain in
                    NavigationLink(value: strain) {
                        strainRow(strain)
                    }
                }
                .onDelete { offsets in
                    delete(from: others, at: offsets)
                }
            }
        }
        .overlay {
            if strains.isEmpty {
                EmptyStateView(
                    icon: "leaf.circle",
                    title: "No Strains",
                    message: "Add your first strain to start tracking effectiveness."
                )
            }
        }
        .searchable(text: $searchText, prompt: "Search strains")
        .navigationTitle("Strain Library")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Strain.self) { strain in
            StrainDetailView(strain: strain)
        }
        .toolbar {
            Button { showAddStrain = true } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddStrain) {
            StrainFormView()
        }
    }

    private func strainRow(_ strain: Strain) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(strain.name)
                    .font(.body.weight(.medium))
                HStack(spacing: 8) {
                    Text(strain.strainType.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let thc = strain.thcPercentage {
                        Text("THC \(String(format: "%.1f", thc))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            if strain.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
    }

    private func delete(from source: [Strain], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(source[index])
        }
    }
}
