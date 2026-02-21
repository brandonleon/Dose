import Foundation

enum DosageMethod: String, Codable, CaseIterable, Identifiable {
    case flower
    case vape
    case edible
    case tincture
    case topical
    case concentrate
    case capsule
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .flower: "Flower"
        case .vape: "Vape"
        case .edible: "Edible"
        case .tincture: "Tincture"
        case .topical: "Topical"
        case .concentrate: "Concentrate"
        case .capsule: "Capsule"
        case .other: "Other"
        }
    }

    var iconName: String {
        switch self {
        case .flower: "leaf.fill"
        case .vape: "cloud.fill"
        case .edible: "birthday.cake.fill"
        case .tincture: "drop.fill"
        case .topical: "hand.raised.fill"
        case .concentrate: "flame.fill"
        case .capsule: "pills.fill"
        case .other: "ellipsis.circle.fill"
        }
    }
}
