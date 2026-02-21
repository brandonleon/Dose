import SwiftUI
import SwiftData

struct PainEntryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var painLevel: Double = 5
    @State private var location = "Lower back"
    @State private var activityContext = ""
    @State private var notes = ""

    private let locations = [
        "Lower back", "Upper back", "Neck", "Shoulders",
        "Hips", "Legs", "Full body", "Other"
    ]

    private let contexts = [
        "", "Morning", "Afternoon", "Evening", "Night",
        "After sitting", "After standing", "After exercise",
        "After work", "After sleep"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Pain Level") {
                    PainScaleSlider(value: $painLevel, label: "Current Pain")
                }

                Section("Location") {
                    Picker("Location", selection: $location) {
                        ForEach(locations, id: \.self) { loc in
                            Text(loc).tag(loc)
                        }
                    }
                }

                Section("Context") {
                    Picker("Activity", selection: $activityContext) {
                        Text("None").tag("")
                        ForEach(contexts.filter { !$0.isEmpty }, id: \.self) { ctx in
                            Text(ctx).tag(ctx)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log Pain")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = PainEntry(
                            painLevel: Int(painLevel),
                            location: location,
                            notes: notes,
                            activityContext: activityContext.isEmpty ? nil : activityContext
                        )
                        modelContext.insert(entry)
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
