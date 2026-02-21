import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "leaf.fill")
                .font(.system(size: 64))
                .foregroundStyle(themeManager.accentColor)

            VStack(spacing: 4) {
                Text("Dose")
                    .font(.largeTitle.weight(.bold))
                Text("Cannabis Consumption Tracker")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                Text("Track your consumption, manage tolerance breaks, and understand what works for your pain management.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }

            VStack(spacing: 4) {
                Text("All data stored locally on your device")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
