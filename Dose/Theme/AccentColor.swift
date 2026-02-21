import SwiftUI

enum AccentColor: String, CaseIterable, Identifiable {
    case emerald
    case sage
    case mint
    case forest
    case purple
    case indigo
    case teal
    case coral
    case amber
    case rose
    case slate
    case crimson
    case custom

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .emerald:    Color(red: 0.20, green: 0.78, blue: 0.47)
        case .sage:       Color(red: 0.56, green: 0.74, blue: 0.56)
        case .mint:       Color(red: 0.36, green: 0.85, blue: 0.72)
        case .forest:     Color(red: 0.13, green: 0.55, blue: 0.33)
        case .purple:     Color(red: 0.58, green: 0.34, blue: 0.92)
        case .indigo:     Color(red: 0.35, green: 0.34, blue: 0.84)
        case .teal:       Color(red: 0.24, green: 0.71, blue: 0.71)
        case .coral:      Color(red: 1.00, green: 0.50, blue: 0.38)
        case .amber:      Color(red: 1.00, green: 0.75, blue: 0.22)
        case .rose:       Color(red: 0.92, green: 0.35, blue: 0.55)
        case .slate:      Color(red: 0.47, green: 0.53, blue: 0.60)
        case .crimson:    Color(red: 0.86, green: 0.14, blue: 0.25)
        case .custom:     Color.green
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}
