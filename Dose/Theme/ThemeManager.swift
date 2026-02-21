import SwiftUI

final class ThemeManager: ObservableObject {
    private let defaults: UserDefaults

    @Published var selectedAccent: AccentColor {
        didSet { defaults.set(selectedAccent.rawValue, forKey: Keys.accentColor) }
    }

    @Published var customHex: String {
        didSet { defaults.set(customHex, forKey: Keys.customHex) }
    }

    var accentColor: Color {
        if selectedAccent == .custom {
            return Color(hex: customHex) ?? AccentColor.emerald.color
        }
        return selectedAccent.color
    }

    var cardBackground: Color { Color(.systemGray6) }
    var secondaryText: Color { .secondary }

    private enum Keys {
        static let accentColor = "dose_accent_color"
        static let customHex = "dose_custom_hex"
    }

    init() {
        let defaults = UserDefaults(suiteName: SharedContainer.appGroupIdentifier) ?? .standard
        self.defaults = defaults

        let storedAccent = defaults.string(forKey: Keys.accentColor) ?? AccentColor.emerald.rawValue
        self.selectedAccent = AccentColor(rawValue: storedAccent) ?? .emerald
        self.customHex = defaults.string(forKey: Keys.customHex) ?? "#33C778"
    }
}
