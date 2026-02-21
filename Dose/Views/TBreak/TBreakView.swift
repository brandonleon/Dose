import SwiftUI
import SwiftData

struct TBreakView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @Query(sort: \TBreak.startDate, order: .reverse) private var tBreaks: [TBreak]
    @Query(sort: \Session.timestamp, order: .reverse) private var sessions: [Session]

    @State private var showStartSheet = false
    @State private var goalDaysText = "7"
    @State private var breakNotes = ""

    private var activeTBreak: TBreak? {
        tBreaks.first(where: \.isActive)
    }

    private var dailyAverage: Double {
        guard let oldest = sessions.last?.timestamp else { return 0 }
        let days = max(1, Calendar.current.dateComponents([.day], from: oldest, to: .now).day ?? 1)
        return Double(sessions.count) / Double(days)
    }

    private var weeklyAverage: Double { dailyAverage * 7 }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Averages
                HStack(spacing: 16) {
                    StatCard(
                        title: "Daily Avg",
                        value: String(format: "%.1f", dailyAverage),
                        icon: "calendar.day.timeline.leading",
                        accentColor: themeManager.accentColor
                    )
                    StatCard(
                        title: "Weekly Avg",
                        value: String(format: "%.1f", weeklyAverage),
                        icon: "calendar",
                        accentColor: themeManager.accentColor
                    )
                }

                // Active T-Break
                if let tBreak = activeTBreak {
                    TBreakStreakView(tBreak: tBreak) {
                        endTBreak(tBreak)
                    }
                } else {
                    AccentButton("Start T-Break", icon: "timer") {
                        showStartSheet = true
                    }
                }

                // Timeline
                TBreakTimelineView(sessions: sessions)

                // Past T-Breaks
                if tBreaks.contains(where: { !$0.isActive }) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Past T-Breaks")
                            .font(.headline)

                        ForEach(tBreaks.filter { !$0.isActive }) { tb in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(tb.currentStreakDays) days")
                                        .font(.subheadline.weight(.medium))
                                    Text(DateFormatters.shortDate.string(from: tb.startDate))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if let goal = tb.goalDays {
                                    Text("Goal: \(goal)d")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("T-Break")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Start T-Break", isPresented: $showStartSheet) {
            TextField("Goal days (e.g. 7)", text: $goalDaysText)
                .keyboardType(.numberPad)
            Button("Start") { startTBreak() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Set a goal for your tolerance break.")
        }
    }

    private func startTBreak() {
        let goalDays = Int(goalDaysText)
        let tBreak = TBreak(goalDays: goalDays)
        modelContext.insert(tBreak)
        try? modelContext.save()

        if let days = goalDays {
            Task {
                let granted = await NotificationService.shared.requestAuthorization()
                if granted {
                    NotificationService.shared.scheduleReminders(for: days, from: tBreak.startDate)
                }
            }
        }
    }

    private func endTBreak(_ tBreak: TBreak) {
        tBreak.actualEndDate = .now
        try? modelContext.save()
        NotificationService.shared.cancelAllTBreakReminders()
    }
}
