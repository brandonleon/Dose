import SwiftUI
import SwiftData

struct StrainFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var strain: Strain?

    @State private var name: String = ""
    @State private var strainType: StrainType = .hybrid
    @State private var thcString: String = ""
    @State private var cbdString: String = ""
    @State private var notes: String = ""
    @State private var isFavorite: Bool = false

    private var isEditing: Bool { strain != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Strain Name", text: $name)
                    Picker("Type", selection: $strainType) {
                        ForEach(StrainType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("Potency") {
                    HStack {
                        Text("THC %")
                        Spacer()
                        TextField("e.g. 22.5", text: $thcString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    HStack {
                        Text("CBD %")
                        Spacer()
                        TextField("e.g. 0.5", text: $cbdString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }

                Section("Notes") {
                    TextField("Personal notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle("Favorite", isOn: $isFavorite)
                }
            }
            .navigationTitle(isEditing ? "Edit Strain" : "Add Strain")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let strain {
                    name = strain.name
                    strainType = strain.strainType
                    thcString = strain.thcPercentage.map { String($0) } ?? ""
                    cbdString = strain.cbdPercentage.map { String($0) } ?? ""
                    notes = strain.notes
                    isFavorite = strain.isFavorite
                }
            }
        }
    }

    private func save() {
        if let strain {
            strain.name = name.trimmingCharacters(in: .whitespaces)
            strain.strainType = strainType
            strain.thcPercentage = Double(thcString)
            strain.cbdPercentage = Double(cbdString)
            strain.notes = notes
            strain.isFavorite = isFavorite
        } else {
            let newStrain = Strain(
                name: name.trimmingCharacters(in: .whitespaces),
                strainType: strainType,
                thcPercentage: Double(thcString),
                cbdPercentage: Double(cbdString),
                notes: notes,
                isFavorite: isFavorite
            )
            modelContext.insert(newStrain)
        }
        try? modelContext.save()
    }
}
