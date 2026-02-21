import SwiftUI
import Charts

struct ConsumptionTrendChart: View {
    let sessions: [Session]
    @EnvironmentObject private var themeManager: ThemeManager

    private var dailyCounts: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.timestamp)
        }
        return grouped.map { (date: $0.key, count: $0.value.count) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Consumption Trend")
                .font(.headline)

            if dailyCounts.isEmpty {
                Text("No data yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart(dailyCounts, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Sessions", item.count)
                    )
                    .foregroundStyle(themeManager.accentColor)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Sessions", item.count)
                    )
                    .foregroundStyle(themeManager.accentColor.opacity(0.1).gradient)
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
}
