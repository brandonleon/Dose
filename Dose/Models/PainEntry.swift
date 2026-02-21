import Foundation
import SwiftData

@Model
final class PainEntry {
    var timestamp: Date
    var painLevel: Int
    var location: String
    var notes: String
    var activityContext: String?

    init(
        timestamp: Date = .now,
        painLevel: Int,
        location: String = "Lower back",
        notes: String = "",
        activityContext: String? = nil
    ) {
        self.timestamp = timestamp
        self.painLevel = painLevel
        self.location = location
        self.notes = notes
        self.activityContext = activityContext
    }
}
