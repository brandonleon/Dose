import SwiftUI

struct DailySummaryView: View {
    let sessions: [Session]
    @EnvironmentObject private var themeManager: ThemeManager

    private var dailyGroups: [(date: Date, sessions: [Session])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.timestamp)
        }
        return grouped.map { (date: $0.key, sessions: $0.value) }
            .sorted { $0.date > $1.date }
            .prefix(14)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Summary")
                .font(.headline)

            if dailyGroups.isEmpty {
                Text("No sessions yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(dailyGroups, id: \.date) { group in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(DateFormatters.monthDay.string(from: group.date))
                                .font(.subheadline.weight(.semibold))
                            Text(DateFormatters.dayOfWeek.string(from: group.date))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(group.sessions.count) session\(group.sessions.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        HStack(spacing: 8) {
                            let methods = Set(group.sessions.map(\.dosageMethod))
                            ForEach(Array(methods), id: \.self) { method in
                                let count = group.sessions.filter { $0.dosageMethod == method }.count
                                HStack(spacing: 3) {
                                    Image(systemName: method.iconName)
                                        .font(.caption2)
                                    Text("\(count)")
                                        .font(.caption)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}
