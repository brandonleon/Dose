import SwiftUI
import SwiftData

struct PainJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @Query(sort: \PainEntry.timestamp, order: .reverse) private var entries: [PainEntry]
    @State private var showAddEntry = false

    var body: some View {
        List {
            ForEach(entries) { entry in
                PainEntryRow(entry: entry)
            }
            .onDelete { offsets in
                for index in offsets {
                    modelContext.delete(entries[index])
                }
            }
        }
        .overlay {
            if entries.isEmpty {
                EmptyStateView(
                    icon: "heart.text.square",
                    title: "No Pain Entries",
                    message: "Track your pain levels to see patterns over time."
                )
            }
        }
        .navigationTitle("Pain Journal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button { showAddEntry = true } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddEntry) {
            PainEntryFormView()
        }
    }
}

private struct PainEntryRow: View {
    let entry: PainEntry
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(painColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                Text("\(entry.painLevel)")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(painColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(entry.location)
                        .font(.subheadline.weight(.medium))
                    if let context = entry.activityContext, !context.isEmpty {
                        Text("- \(context)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(DateFormatters.mediumDateTime.string(from: entry.timestamp))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
    }

    private var painColor: Color {
        switch entry.painLevel {
        case 1...3: return .green
        case 4...6: return .yellow
        case 7...8: return .orange
        default: return .red
        }
    }
}
