import SwiftUI
import Charts

struct TBreakTimelineView: View {
    let sessions: [Session]
    @EnvironmentObject private var themeManager: ThemeManager

    private var dailyCounts: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.timestamp)
        }

        guard let earliest = sessions.last?.timestamp else { return [] }
        let start = calendar.startOfDay(for: earliest)
        let end = calendar.startOfDay(for: .now)

        var results: [(date: Date, count: Int)] = []
        var current = start
        while current <= end {
            let count = grouped[current]?.count ?? 0
            results.append((date: current, count: count))
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        // Show last 30 days max
        return Array(results.suffix(30))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 30 Days")
                .font(.headline)

            if dailyCounts.isEmpty {
                Text("No session data yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart(dailyCounts, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Sessions", item.count)
                    )
                    .foregroundStyle(themeManager.accentColor.gradient)
                    .cornerRadius(3)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) {
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .aligned) {
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .frame(height: 200)
            }
        }
    }
}
