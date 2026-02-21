import SwiftUI
import SwiftData

struct ExportView: View {
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]
    @Query(sort: \PainEntry.timestamp, order: .reverse) private var painEntries: [PainEntry]

    private var sessionsCSV: String {
        ExportService.exportSessionsCSV(sessions: sessions)
    }

    private var painCSV: String {
        ExportService.exportPainEntriesCSV(entries: painEntries)
    }

    var body: some View {
        List {
            Section("Sessions") {
                LabeledContent("Total", value: "\(sessions.count)")

                if !sessions.isEmpty {
                    ShareLink(
                        "Export Sessions CSV",
                        item: sessionsCSV,
                        preview: SharePreview(
                            "Dose Sessions Export",
                            image: Image(systemName: "doc.text")
                        )
                    )
                }
            }

            Section("Pain Journal") {
                LabeledContent("Total", value: "\(painEntries.count)")

                if !painEntries.isEmpty {
                    ShareLink(
                        "Export Pain Entries CSV",
                        item: painCSV,
                        preview: SharePreview(
                            "Dose Pain Journal Export",
                            image: Image(systemName: "doc.text")
                        )
                    )
                }
            }

            Section {
                Text("Exports include all data in CSV format. Open in Numbers, Excel, or any spreadsheet app.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}
