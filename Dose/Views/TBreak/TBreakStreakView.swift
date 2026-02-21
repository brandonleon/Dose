import SwiftUI

struct TBreakStreakView: View {
    let tBreak: TBreak
    let onEnd: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 16) {
            Text("T-Break Active")
                .font(.headline)
                .foregroundStyle(themeManager.accentColor)

            Text("\(tBreak.currentStreakDays)")
                .font(.system(size: 64, weight: .bold, design: .rounded))

            Text(tBreak.currentStreakDays == 1 ? "day" : "days")
                .font(.title3)
                .foregroundStyle(.secondary)

            if let goal = tBreak.goalDays {
                ProgressView(value: tBreak.progress)
                    .tint(themeManager.accentColor)
                    .padding(.horizontal)

                Text("\(tBreak.currentStreakDays) / \(goal) days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Started \(DateFormatters.mediumDateTime.string(from: tBreak.startDate))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("End T-Break", role: .destructive) {
                onEnd()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16))
    }
}
