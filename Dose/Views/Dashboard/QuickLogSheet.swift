import SwiftUI
import SwiftData
import WidgetKit

struct QuickLogSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var selectedMethod: DosageMethod = .flower
    @State private var dosageAmount = ""
    @State private var painLevelBefore: Double = 5
    @State private var painLevelAfter: Double = 5
    @State private var trackPainBefore = false
    @State private var trackPainAfter = false
    @State private var selectedStrain: Strain?
    @State private var notes = ""
    @State private var showStrainPicker = false

    @Query(sort: \Strain.name) private var strains: [Strain]

    var body: some View {
        NavigationStack {
            Form {
                Section("Method") {
                    DosageMethodPicker(selection: $selectedMethod)
                }

                Section("Dosage") {
                    TextField("Amount (e.g., 2 puffs, 10mg)", text: $dosageAmount)
                }

                Section("Strain") {
                    if let strain = selectedStrain {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(strain.name)
                                    .font(.subheadline.weight(.medium))
                                Text(strain.strainType.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Change") { showStrainPicker = true }
                            Button("Clear") { selectedStrain = nil }
                                .foregroundStyle(.red)
                        }
                    } else {
                        Button("Select Strain") { showStrainPicker = true }
                    }
                }

                Section("Pain Level Before") {
                    Toggle("Track pain before", isOn: $trackPainBefore)
                    if trackPainBefore {
                        PainScaleSlider(value: $painLevelBefore, label: "Before")
                    }
                }

                Section("Pain Level After") {
                    Toggle("Track pain after", isOn: $trackPainAfter)
                    if trackPainAfter {
                        PainScaleSlider(value: $painLevelAfter, label: "After")
                    }
                }

                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log Session")
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
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showStrainPicker) {
                StrainPickerView(selection: $selectedStrain)
            }
        }
    }

    private func save() {
        let session = Session(
            dosageMethod: selectedMethod,
            dosageAmount: dosageAmount.isEmpty ? nil : dosageAmount,
            painLevelBefore: trackPainBefore ? Int(painLevelBefore) : nil,
            painLevelAfter: trackPainAfter ? Int(painLevelAfter) : nil,
            notes: notes,
            strain: selectedStrain
        )
        modelContext.insert(session)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
