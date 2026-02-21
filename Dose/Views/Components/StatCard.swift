import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var accentColor: Color = .green

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(accentColor)

            Text(value)
                .font(.title2.weight(.bold).monospacedDigit())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
}
