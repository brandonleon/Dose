import Foundation

enum ExportService {
    static func exportSessionsCSV(sessions: [Session]) -> String {
        var csv = "Timestamp,Method,Amount,Strain,Pain Before,Pain After,Notes\n"
        let formatter = ISO8601DateFormatter()

        for s in sessions {
            let fields = [
                formatter.string(from: s.timestamp),
                s.dosageMethod.displayName,
                s.dosageAmount ?? "",
                s.strain?.name ?? "",
                s.painLevelBefore.map(String.init) ?? "",
                s.painLevelAfter.map(String.init) ?? "",
                escapeCSV(s.notes)
            ]
            csv += fields.joined(separator: ",") + "\n"
        }
        return csv
    }

    static func exportPainEntriesCSV(entries: [PainEntry]) -> String {
        var csv = "Timestamp,Pain Level,Location,Activity Context,Notes\n"
        let formatter = ISO8601DateFormatter()

        for e in entries {
            let fields = [
                formatter.string(from: e.timestamp),
                String(e.painLevel),
                escapeCSV(e.location),
                escapeCSV(e.activityContext ?? ""),
                escapeCSV(e.notes)
            ]
            csv += fields.joined(separator: ",") + "\n"
        }
        return csv
    }

    private static func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}
