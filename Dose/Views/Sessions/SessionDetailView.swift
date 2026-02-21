import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Bindable var session: Session
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var showDeleteConfirm = false
    @State private var showEdit = false

    var body: some View {
        List {
            Section {
                LabeledContent("Method") {
                    Label(session.dosageMethod.displayName, systemImage: session.dosageMethod.iconName)
                }

                LabeledContent("Time") {
                    Text(DateFormatters.mediumDateTime.string(from: session.timestamp))
                }

                if let amount = session.dosageAmount, !amount.isEmpty {
                    LabeledContent("Amount", value: amount)
                }
            }

            if let strain = session.strain {
                Section("Strain") {
                    LabeledContent("Name", value: strain.name)
                    LabeledContent("Type", value: strain.strainType.displayName)
                    if let thc = strain.thcPercentage {
                        LabeledContent("THC", value: String(format: "%.1f%%", thc))
                    }
                }
            }

            Section("Pain Levels") {
                if let before = session.painLevelBefore {
                    HStack {
                        Text("Before")
                        Spacer()
                        PainScaleView(painLevel: before)
                            .frame(width: 120)
                        Text("\(before)")
                            .font(.headline.monospacedDigit())
                            .frame(width: 30)
                    }
                }
                if let after = session.painLevelAfter {
                    HStack {
                        Text("After")
                        Spacer()
                        PainScaleView(painLevel: after)
                            .frame(width: 120)
                        Text("\(after)")
                            .font(.headline.monospacedDigit())
                            .frame(width: 30)
                    }
                }
                if let delta = session.painDelta {
                    LabeledContent("Change") {
                        Text(delta > 0 ? "+\(delta)" : "\(delta)")
                            .foregroundStyle(delta <= 0 ? .green : .red)
                            .font(.headline.monospacedDigit())
                    }
                }
                if session.painLevelBefore == nil && session.painLevelAfter == nil {
                    Text("No pain data recorded")
                        .foregroundStyle(.secondary)
                }
            }

            if !session.notes.isEmpty {
                Section("Notes") {
                    Text(session.notes)
                }
            }

            Section {
                Button("Delete Session", role: .destructive) {
                    showDeleteConfirm = true
                }
            }
        }
        .navigationTitle("Session Detail")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete this session?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(session)
                dismiss()
            }
        }
    }
}
