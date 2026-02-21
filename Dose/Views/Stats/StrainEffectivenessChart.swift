import SwiftUI
import Charts

struct StrainEffectivenessChart: View {
    let sessions: [Session]
    @EnvironmentObject private var themeManager: ThemeManager

    struct StrainStat: Identifiable {
        let id = UUID()
        let strainName: String
        let sessionCount: Int
        let averagePainRelief: Double
    }

    private var stats: [StrainStat] {
        let withStrain = sessions.filter { $0.strain != nil }
        let grouped = Dictionary(grouping: withStrain) { $0.strain!.name }
        return grouped.compactMap { name, strainSessions in
            let deltas = strainSessions.compactMap(\.painDelta)
            guard !deltas.isEmpty else {
                return StrainStat(strainName: name, sessionCount: strainSessions.count, averagePainRelief: 0)
            }
            let avgRelief = -Double(deltas.reduce(0, +)) / Double(deltas.count)
            return StrainStat(strainName: name, sessionCount: strainSessions.count, averagePainRelief: avgRelief)
        }
        .sorted { $0.averagePainRelief > $1.averagePainRelief }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Strain Effectiveness")
                .font(.headline)

            if stats.isEmpty {
                Text("Log sessions with strains and pain levels to compare")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart(stats) { stat in
                    BarMark(
                        x: .value("Relief", stat.averagePainRelief),
                        y: .value("Strain", stat.strainName)
                    )
                    .foregroundStyle(themeManager.accentColor.gradient)
                    .annotation(position: .trailing, alignment: .leading) {
                        Text("\(stat.sessionCount)x")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartXAxisLabel("Avg Pain Relief")
                .frame(height: max(CGFloat(stats.count) * 44, 88))
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
}
