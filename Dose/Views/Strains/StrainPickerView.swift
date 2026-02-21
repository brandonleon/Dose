import SwiftUI
import SwiftData

struct StrainPickerView: View {
    @Binding var selection: Strain?
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Strain.name) private var strains: [Strain]
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
        NavigationStack {
            List {
                if !favorites.isEmpty {
                    Section("Favorites") {
                        ForEach(favorites) { strain in
                            strainButton(strain)
                        }
                    }
                }

                Section(favorites.isEmpty ? "Strains" : "Other") {
                    ForEach(others) { strain in
                        strainButton(strain)
                    }
                }
            }
            .overlay {
                if strains.isEmpty {
                    EmptyStateView(
                        icon: "leaf.circle",
                        title: "No Strains",
                        message: "Add strains from the Strain Library first."
                    )
                }
            }
            .searchable(text: $searchText, prompt: "Search strains")
            .navigationTitle("Select Strain")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func strainButton(_ strain: Strain) -> some View {
        Button {
            selection = strain
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(strain.name)
                    Text(strain.strainType.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if selection?.persistentModelID == strain.persistentModelID {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}
