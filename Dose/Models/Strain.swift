import Foundation
import SwiftData

@Model
final class Strain {
    var name: String
    var strainTypeRaw: String
    var thcPercentage: Double?
    var cbdPercentage: Double?
    var notes: String
    var isFavorite: Bool
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Session.strain)
    var sessions: [Session]

    var strainType: StrainType {
        get { StrainType(rawValue: strainTypeRaw) ?? .hybrid }
        set { strainTypeRaw = newValue.rawValue }
    }

    init(
        name: String,
        strainType: StrainType = .hybrid,
        thcPercentage: Double? = nil,
        cbdPercentage: Double? = nil,
        notes: String = "",
        isFavorite: Bool = false,
        createdAt: Date = .now
    ) {
        self.name = name
        self.strainTypeRaw = strainType.rawValue
        self.thcPercentage = thcPercentage
        self.cbdPercentage = cbdPercentage
        self.notes = notes
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.sessions = []
    }
}
