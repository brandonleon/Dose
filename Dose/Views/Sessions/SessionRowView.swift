import SwiftUI

struct SessionRowView: View {
    let session: Session
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.dosageMethod.iconName)
                .foregroundStyle(themeManager.accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(session.dosageMethod.displayName)
                        .font(.subheadline.weight(.medium))
                    if let strain = session.strain {
                        Text(strain.name)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(themeManager.accentColor.opacity(0.15), in: Capsule())
                    }
                }
                HStack(spacing: 8) {
                    Text(DateFormatters.timeOnly.string(from: session.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let amount = session.dosageAmount, !amount.isEmpty {
                        Text(amount)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if let before = session.painLevelBefore,
               let after = session.painLevelAfter {
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        Text("\(before)")
                            .foregroundStyle(.orange)
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                        Text("\(after)")
                            .foregroundStyle(.green)
                    }
                    .font(.caption.monospacedDigit())
                }
            }
        }
    }
}
