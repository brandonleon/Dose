import SwiftUI
import SwiftData

struct StatsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var proManager: ProManager
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]
    @Query(sort: \PainEntry.timestamp, order: .reverse) private var painEntries: [PainEntry]

    @State private var dateRange: DateRange = .month
    @State private var showUpgrade = false

    enum DateRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Mo"
        case year = "Year"
        case all = "All"

        var requiresPro: Bool {
            switch self {
            case .week, .month: return false
            case .threeMonths, .year, .all: return true
            }
        }

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
        let base = proManager.isPro ? sessions : sessions.filter { $0.timestamp >= ProManager.freeHistoryStart }
        guard let start = dateRange.startDate else { return base }
        return base.filter { $0.timestamp >= start }
    }

    private var filteredPainEntries: [PainEntry] {
        let base = proManager.isPro ? painEntries : painEntries.filter { $0.timestamp >= ProManager.freeHistoryStart }
        guard let start = dateRange.startDate else { return base }
        return base.filter { $0.timestamp >= start }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Date range picker — Pro ranges show a lock for free users
                Picker("Range", selection: $dateRange) {
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Label(
                            range.rawValue,
                            systemImage: (range.requiresPro && !proManager.isPro) ? "lock.fill" : ""
                        )
                        .tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: dateRange) { _, newValue in
                    if newValue.requiresPro && !proManager.isPro {
                        dateRange = .month
                        showUpgrade = true
                    }
                }
                .sheet(isPresented: $showUpgrade) {
                    ProUpgradeView()
                }

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
