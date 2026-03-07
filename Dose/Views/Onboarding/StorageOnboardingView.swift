import SwiftUI

struct StorageOnboardingView: View {
    let onComplete: (StorageLocation) -> Void

    @State private var selected: StorageLocation = .iCloud

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 60)
                        .padding(.bottom, 40)

                    optionCards
                        .padding(.horizontal, 20)

                    privacyNote
                        .padding(.horizontal, 20)
                        .padding(.top, 28)

                    continueButton
                        .padding(.horizontal, 20)
                        .padding(.top, 36)
                        .padding(.bottom, 48)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.3), Color.green.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.green)
            }

            VStack(spacing: 8) {
                Text("Your Data, Your Choice")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text("Dose is privacy-first. Choose where your health data lives.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Option Cards

    private var optionCards: some View {
        VStack(spacing: 14) {
            StorageOptionCard(
                location: .iCloud,
                selected: $selected,
                icon: "icloud.fill",
                iconColor: .blue,
                title: "iCloud (Recommended)",
                tagline: "Encrypted. Private. Backed up.",
                bullets: [
                    ("lock.fill", "End-to-end encrypted — Apple cannot read it"),
                    ("person.fill.checkmark", "Only you can access your data"),
                    ("arrow.triangle.2.circlepath", "Syncs across all your Apple devices"),
                    ("externaldrive.badge.checkmark", "Protected if your phone is lost or broken"),
                ]
            )

            StorageOptionCard(
                location: .localOnly,
                selected: $selected,
                icon: "iphone",
                iconColor: .orange,
                title: "Local Device Only",
                tagline: "Stays on this device. No cloud.",
                bullets: [
                    ("nosign", "Never leaves your device"),
                    ("xmark.icloud", "No iCloud account required"),
                    ("exclamationmark.triangle", "Lost if your device is lost or reset"),
                    ("arrow.down.to.line", "Can export manually via CSV"),
                ]
            )
        }
    }

    // MARK: - Privacy Note

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.secondary)
                .font(.footnote)
                .padding(.top, 1)

            Text("Both options keep your data fully private. Dose never sends your data to any third-party servers. Your consumption and pain records belong to you alone.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            onComplete(selected)
        } label: {
            Text("Continue with \(selected == .iCloud ? "iCloud" : "Local Storage")")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.green)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - StorageOptionCard

private struct StorageOptionCard: View {
    let location: StorageLocation
    @Binding var selected: StorageLocation
    let icon: String
    let iconColor: Color
    let title: String
    let tagline: String
    let bullets: [(String, String)]

    private var isSelected: Bool { selected == location }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selected = location
            }
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                // Header row
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(iconColor.opacity(0.18))
                            .frame(width: 44, height: 44)
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundStyle(iconColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(tagline)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.green : Color.secondary)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Bullet points
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(bullets, id: \.1) { bullet in
                        HStack(spacing: 10) {
                            Image(systemName: bullet.0)
                                .font(.footnote)
                                .foregroundStyle(iconColor.opacity(0.8))
                                .frame(width: 16)
                            Text(bullet.1)
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.75))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected ? 0.08 : 0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? Color.green.opacity(0.6) : Color.white.opacity(0.08),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StorageOnboardingView { location in
        print("Selected: \(location.displayName)")
    }
}
