import StoreKit
import Foundation

@MainActor
class ProManager: ObservableObject {
    static let productID = "com.brandonleon.Dose.pro"

    /// Free tier history window in days.
    static let freeHistoryDays = 30

    static var freeHistoryStart: Date {
        Calendar.current.date(byAdding: .day, value: -freeHistoryDays, to: .now) ?? .now
    }

    @Published private(set) var isPro: Bool = false
    @Published private(set) var product: Product? = nil
    @Published private(set) var purchasing: Bool = false

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await _ in Transaction.updates {
                await self?.refreshStatus()
            }
        }
        Task { await refresh() }
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Public

    func purchase() async throws {
        guard let product else { return }
        purchasing = true
        defer { purchasing = false }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            guard case .verified(let tx) = verification else { return }
            await tx.finish()
            await refreshStatus()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await refreshStatus()
    }

    // MARK: - Private

    private func refresh() async {
        async let fetchProduct: () = loadProduct()
        async let fetchStatus: () = refreshStatus()
        _ = await (fetchProduct, fetchStatus)
    }

    private func loadProduct() async {
        let products = try? await Product.products(for: [Self.productID])
        product = products?.first
    }

    private func refreshStatus() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               tx.productID == Self.productID,
               tx.revocationDate == nil {
                entitled = true
            }
        }
        isPro = entitled
    }
}
