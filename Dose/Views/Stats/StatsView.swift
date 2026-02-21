import SwiftUI
import SwiftData

struct StatsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]
    @Query(sort: \PainEntry.timestamp, order: .reverse) private var painEntries: [PainEntry]

    @State private var dateRange: DateRange = .month

    enum DateRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Mo"
        case year = "Year"
        case all = "All"

        var startDate: Date? {
            let cal = Calendar.current
            switch self {
            case .week: return cal.date(byAdding: .day, value: -7, to: .now)
            case .month: return cal.date(byAdding: .month, value: -1, to: .now)
            case .threeMonths: return cal.date(byAdding: .month, value: -3, to: .now)
            case .year: return cal.date(byAdding: .year, value: -1, to: .now)
            case .all: return nil
            }
        }
    }

    private var filteredSessions: [Session] {
        guard let start = dateRange.startDate else { return sessions }
        return sessions.filter { $0.timestamp >= start }
    }

    private var filteredPainEntries: [PainEntry] {
        guard let start = dateRange.startDate else { return painEntries }
        return painEntries.filter { $0.timestamp >= start }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Date range picker
                Picker("Range", selection: $dateRange) {
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)

                // Summary cards
                HStack(spacing: 16) {
                    StatCard(
                        title: "Total Sessions",
                        value: "\(filteredSessions.count)",
                        icon: "leaf.fill",
                        accentColor: themeManager.accentColor
                    )
                    StatCard(
                        title: "Pain Entries",
                        value: "\(filteredPainEntries.count)",
                        icon: "heart.text.square",
                        accentColor: .orange
                    )
                }

                ConsumptionTrendChart(sessions: filteredSessions)
                MethodEffectivenessChart(sessions: filteredSessions)
                StrainEffectivenessChart(sessions: filteredSessions)
                DailySummaryView(sessions: filteredSessions)
            }
            .padding()
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
}
