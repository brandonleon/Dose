import SwiftUI

struct TodaySummaryView: View {
    let sessions: [Session]
    @EnvironmentObject private var themeManager: ThemeManager

    private var averagePainBefore: Double? {
        let values = sessions.compactMap(\.painLevelBefore)
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    private var averagePainAfter: Double? {
        let values = sessions.compactMap(\.painLevelAfter)
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Sessions",
                value: "\(sessions.count)",
                icon: "leaf.fill",
                accentColor: themeManager.accentColor
            )

            if let before = averagePainBefore {
                StatCard(
                    title: "Avg Pain Before",
                    value: String(format: "%.1f", before),
                    icon: "gauge.with.dots.needle.33percent",
                    accentColor: .orange
                )
            }

            if let after = averagePainAfter {
                StatCard(
                    title: "Avg Pain After",
                    value: String(format: "%.1f", after),
                    icon: "gauge.with.dots.needle.67percent",
                    accentColor: .green
                )
            }
        }
    }
}
