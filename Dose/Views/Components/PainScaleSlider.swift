import SwiftUI

struct PainScaleSlider: View {
    @Binding var value: Double
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(value))")
                    .font(.title2.weight(.bold).monospacedDigit())
                    .foregroundStyle(painColor)
            }

            Slider(value: $value, in: 1...10, step: 1) {
                Text(label)
            } minimumValueLabel: {
                Text("1").font(.caption2)
            } maximumValueLabel: {
                Text("10").font(.caption2)
            }
            .tint(painColor)
        }
    }

    private var painColor: Color {
        switch Int(value) {
        case 1...3: return .green
        case 4...6: return .yellow
        case 7...8: return .orange
        default: return .red
        }
    }
}
