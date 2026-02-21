import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let columns = [GridItem(.adaptive(minimum: 56))]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Predefined colors
                VStack(alignment: .leading, spacing: 12) {
                    Text("Accent Color")
                        .font(.headline)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(AccentColor.allCases.filter { $0 != .custom }) { accent in
                            Button {
                                themeManager.selectedAccent = accent
                            } label: {
                                Circle()
                                    .fill(accent.color)
                                    .frame(width: 48, height: 48)
                                    .overlay {
                                        if themeManager.selectedAccent == accent {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.white)
                                                .font(.headline.weight(.bold))
                                        }
                                    }
                                    .shadow(
                                        color: themeManager.selectedAccent == accent ? accent.color.opacity(0.5) : .clear,
                                        radius: 6
                                    )
                            }
                        }
                    }
                }

                Divider()

                // Custom color
                VStack(alignment: .leading, spacing: 12) {
                    Text("Custom Color")
                        .font(.headline)

                    HStack {
                        ColorPicker("Pick a color", selection: customColorBinding)
                            .labelsHidden()

                        Text(themeManager.customHex)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)

                        Spacer()

                        if themeManager.selectedAccent == .custom {
                            Text("Active")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(themeManager.accentColor.opacity(0.2), in: Capsule())
                        }
                    }
                }

                // Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preview")
                        .font(.headline)

                    HStack(spacing: 12) {
                        AccentButton("Button", icon: "hand.tap.fill") {}

                        Toggle("Toggle", isOn: .constant(true))
                            .tint(themeManager.accentColor)
                            .labelsHidden()
                    }

                    ProgressView(value: 0.7)
                        .tint(themeManager.accentColor)
                }
            }
            .padding()
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var customColorBinding: Binding<Color> {
        Binding(
            get: { Color(hex: themeManager.customHex) ?? .green },
            set: { newColor in
                themeManager.customHex = newColor.hexString
                themeManager.selectedAccent = .custom
            }
        )
    }
}
