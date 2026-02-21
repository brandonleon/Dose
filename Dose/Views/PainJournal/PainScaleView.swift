import SwiftUI

struct PainScaleView: View {
    let painLevel: Int

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...10, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(level <= painLevel ? colorForLevel(level) : Color(.systemGray5))
                    .frame(height: 16)
            }
        }
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 1...3: return .green
        case 4...6: return .yellow
        case 7...8: return .orange
        default: return .red
        }
    }
}
