import SwiftUI
import StoreKit

struct ProUpgradeView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var proManager: ProManager
    @Environment(\.dismiss) private var dismiss

    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 32)
                        .padding(.bottom, 36)

                    featuresSection
                        .padding(.horizontal, 20)

                    pricingSection
                        .padding(.horizontal, 20)
                        .padding(.top, 32)

                    actionButtons
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                }
            }
            .navigationTitle("Dose Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Purchase Failed", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [themeManager.accentColor.opacity(0.3), themeManager.accentColor.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 38))
                    .foregroundStyle(themeManager.accentColor)
            }

            VStack(spacing: 6) {
                Text("Unlock Your Full History")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("See how your pain and consumption trends change over months, not just weeks.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: 0) {
            featureRow(
                icon: "clock.arrow.circlepath",
                iconColor: themeManager.accentColor,
                title: "Unlimited History",
                detail: "Access every session and pain entry you've ever logged — no 30-day cutoff."
            )
            Divider().padding(.leading, 52)
            featureRow(
                icon: "chart.xyaxis.line",
                iconColor: .blue,
                title: "Long-Term Trend Charts",
                detail: "3-month, yearly, and all-time views in Stats to spot patterns over time."
            )
            Divider().padding(.leading, 52)
            featureRow(
                icon: "icloud.fill",
                iconColor: .cyan,
                title: "iCloud Sync (Coming Soon)",
                detail: "Encrypted sync across all your Apple devices — included with Pro when available."
            )
        }
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func featureRow(icon: String, iconColor: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Pricing

    private var pricingSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("One-Time Purchase")
                        .font(.headline)
                    Text("Pay once, own it forever. No subscription.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(proManager.product?.displayPrice ?? "$1.99")
                    .font(.title2.bold())
                    .foregroundStyle(themeManager.accentColor)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    do {
                        try await proManager.purchase()
                        if proManager.isPro { dismiss() }
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            } label: {
                Group {
                    if proManager.purchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Upgrade to Pro")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(themeManager.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(proManager.purchasing || proManager.product == nil)

            Button {
                Task {
                    do {
                        try await proManager.restorePurchases()
                        if proManager.isPro { dismiss() }
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            } label: {
                Text("Restore Purchase")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .disabled(proManager.purchasing)
        }
    }
}

#Preview {
    ProUpgradeView()
        .environmentObject(ThemeManager())
        .environmentObject(ProManager())
}
