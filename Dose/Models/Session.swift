import Foundation
import SwiftData

@Model
final class Session {
    var timestamp: Date
    var dosageMethodRaw: String
    var dosageAmount: String?
    var painLevelBefore: Int?
    var painLevelAfter: Int?
    var notes: String
    var strain: Strain?

    var dosageMethod: DosageMethod {
        get { DosageMethod(rawValue: dosageMethodRaw) ?? .other }
        set { dosageMethodRaw = newValue.rawValue }
    }

    var painDelta: Int? {
        guard let before = painLevelBefore, let after = painLevelAfter else { return nil }
        return after - before
    }

    init(
        timestamp: Date = .now,
        dosageMethod: DosageMethod = .flower,
        dosageAmount: String? = nil,
        painLevelBefore: Int? = nil,
        painLevelAfter: Int? = nil,
        notes: String = "",
        strain: Strain? = nil
    ) {
        self.timestamp = timestamp
        self.dosageMethodRaw = dosageMethod.rawValue
        self.dosageAmount = dosageAmount
        self.painLevelBefore = painLevelBefore
        self.painLevelAfter = painLevelAfter
        self.notes = notes
        self.strain = strain
    }
}
