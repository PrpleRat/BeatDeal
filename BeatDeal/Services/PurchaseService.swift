import Foundation
import StoreKit

@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()

    @Published private(set) var isPro = false
    @Published private(set) var generatedCount = 0
    @Published private(set) var isPurchasing = false
    @Published var showPaywall = false
    @Published var lastError: String?

    private var updateTask: Task<Void, Never>?

    private init() {
        isPro = UserDefaults.standard.bool(forKey: AppConstants.storageKeyIsPro)
        generatedCount = UserDefaults.standard.integer(forKey: AppConstants.storageKeyGeneratedCount)
        updateTask = listenForTransactions()
        Task { await refreshEntitlements() }
    }

    deinit {
        updateTask?.cancel()
    }

    var needsPaywall: Bool {
        !isPro && generatedCount >= AppConstants.freeContractLimit
    }

    func recordGeneration() {
        generatedCount += 1
        UserDefaults.standard.set(generatedCount, forKey: AppConstants.storageKeyGeneratedCount)
    }

    func unlockPro() {
        isPro = true
        UserDefaults.standard.set(true, forKey: AppConstants.storageKeyIsPro)
        showPaywall = false
    }

    func checkPaywallBeforeGenerate() -> Bool {
        if needsPaywall {
            showPaywall = true
            return false
        }
        return true
    }

    func purchase() async {
        isPurchasing = true
        lastError = nil
        defer { isPurchasing = false }

        do {
            let products = try await Product.products(for: [AppConstants.productID])
            guard let product = products.first else {
                // Dev / simulateur sans produit configuré — débloquer pour tests
                unlockPro()
                return
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified = verification {
                    unlockPro()
                }
            case .userCancelled:
                break
            case .pending:
                lastError = "Achat en attente de validation."
            @unknown default:
                break
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isPurchasing = true
        lastError = nil
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if !isPro {
                lastError = "Aucun achat à restaurer."
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == AppConstants.productID {
                unlockPro()
                return
            }
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result,
                   transaction.productID == AppConstants.productID {
                    unlockPro()
                    await transaction.finish()
                }
            }
        }
    }
}
