import SwiftUI

struct SessionCardView: View {
    let session: Session
    var showTimeSince: Bool = false
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.dosageMethod.iconName)
                .font(.title2)
                .foregroundStyle(themeManager.accentColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.dosageMethod.displayName)
                        .font(.subheadline.weight(.semibold))

                    if let strain = session.strain {
                        Text("- \(strain.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 12) {
                    if showTimeSince {
                        Text(session.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundStyle(themeManager.accentColor)
                        + Text(" ago")
                            .font(.caption)
                            .foregroundStyle(themeManager.accentColor)
                    } else {
                        Text(DateFormatters.timeOnly.string(from: session.timestamp))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let amount = session.dosageAmount, !amount.isEmpty {
                        Text(amount)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let before = session.painLevelBefore,
                       let after = session.painLevelAfter {
                        HStack(spacing: 2) {
                            Text("\(before)")
                                .foregroundStyle(.orange)
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                            Text("\(after)")
                                .foregroundStyle(.green)
                        }
                        .font(.caption)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(themeManager.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}
