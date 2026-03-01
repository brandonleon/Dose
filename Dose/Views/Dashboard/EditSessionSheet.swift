import SwiftUI
import SwiftData
import WidgetKit

struct EditSessionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    @Bindable var session: Session

    @State private var selectedMethod: DosageMethod
    @State private var dosageAmount: String
    @State private var painLevelBefore: Double
    @State private var painLevelAfter: Double
    @State private var trackPainBefore: Bool
    @State private var trackPainAfter: Bool
    @State private var selectedStrain: Strain?
    @State private var notes: String
    @State private var timestamp: Date
    @State private var showStrainPicker = false

    @Query(sort: \Strain.name) private var strains: [Strain]

    init(session: Session) {
        self.session = session
        _selectedMethod = State(initialValue: session.dosageMethod)
        _dosageAmount = State(initialValue: session.dosageAmount ?? "")
        _painLevelBefore = State(initialValue: Double(session.painLevelBefore ?? 5))
        _painLevelAfter = State(initialValue: Double(session.painLevelAfter ?? 5))
        _trackPainBefore = State(initialValue: session.painLevelBefore != nil)
        _trackPainAfter = State(initialValue: session.painLevelAfter != nil)
        _selectedStrain = State(initialValue: session.strain)
        _notes = State(initialValue: session.notes)
        _timestamp = State(initialValue: session.timestamp)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Method") {
                    DosageMethodPicker(selection: $selectedMethod)
                }

                Section("Dosage") {
                    TextField("Amount (e.g., 2 puffs, 10mg)", text: $dosageAmount)
                }

                Section("Time") {
                    DatePicker("Logged at", selection: $timestamp)
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
            .navigationTitle("Edit Session")
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
        session.dosageMethod = selectedMethod
        session.dosageAmount = dosageAmount.isEmpty ? nil : dosageAmount
        session.timestamp = timestamp
        session.painLevelBefore = trackPainBefore ? Int(painLevelBefore) : nil
        session.painLevelAfter = trackPainAfter ? Int(painLevelAfter) : nil
        session.notes = notes
        session.strain = selectedStrain
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
