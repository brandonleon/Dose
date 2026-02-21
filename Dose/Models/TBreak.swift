import Foundation
import SwiftData

@Model
final class TBreak {
    var startDate: Date
    var targetEndDate: Date?
    var actualEndDate: Date?
    var goalDays: Int?
    var notes: String

    var isActive: Bool {
        actualEndDate == nil
    }

    var currentStreakDays: Int {
        let end = actualEndDate ?? .now
        return Calendar.current.dateComponents([.day], from: startDate, to: end).day ?? 0
    }

    var progress: Double {
        guard let goal = goalDays, goal > 0 else { return 0 }
        return min(Double(currentStreakDays) / Double(goal), 1.0)
    }

    init(
        startDate: Date = .now,
        goalDays: Int? = nil,
        notes: String = ""
    ) {
        self.startDate = startDate
        self.goalDays = goalDays
        self.notes = notes
        if let days = goalDays {
            self.targetEndDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)
        }
    }
}
