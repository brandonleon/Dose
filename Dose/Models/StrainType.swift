import Foundation

enum StrainType: String, Codable, CaseIterable, Identifiable {
    case indica
    case sativa
    case hybrid

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .indica: "Indica"
        case .sativa: "Sativa"
        case .hybrid: "Hybrid"
        }
    }
}
