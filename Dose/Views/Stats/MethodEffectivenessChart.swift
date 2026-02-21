import SwiftUI
import Charts

struct MethodEffectivenessChart: View {
    let sessions: [Session]
    @EnvironmentObject private var themeManager: ThemeManager

    struct MethodStat: Identifiable {
        let id = UUID()
        let method: DosageMethod
        let sessionCount: Int
        let averagePainRelief: Double
    }

    private var stats: [MethodStat] {
        let grouped = Dictionary(grouping: sessions) { $0.dosageMethod }
        return grouped.compactMap { method, methodSessions in
            let deltas = methodSessions.compactMap(\.painDelta)
            guard !deltas.isEmpty else {
                return MethodStat(method: method, sessionCount: methodSessions.count, averagePainRelief: 0)
            }
            let avgRelief = -Double(deltas.reduce(0, +)) / Double(deltas.count)
            return MethodStat(method: method, sessionCount: methodSessions.count, averagePainRelief: avgRelief)
        }
        .sorted { $0.averagePainRelief > $1.averagePainRelief }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Method Effectiveness")
                .font(.headline)

            if stats.isEmpty {
                Text("Log sessions with pain levels to see effectiveness")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart(stats) { stat in
                    BarMark(
                        x: .value("Relief", stat.averagePainRelief),
                        y: .value("Method", stat.method.displayName)
                    )
                    .foregroundStyle(themeManager.accentColor.gradient)
                    .annotation(position: .trailing, alignment: .leading) {
                        Text("\(stat.sessionCount)x")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartXAxisLabel("Avg Pain Relief")
                .frame(height: CGFloat(stats.count) * 44)
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
}
