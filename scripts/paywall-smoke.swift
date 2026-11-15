// Runtime smoke tests for the real paywall model/view model without network,
// purchases, Firebase, or an App Store account. Run with the command below.
// xcrun swiftc -parse-as-library -target arm64-apple-macos14.0 \
//   Sofa/Presentations/Paywall/PaywallModel.swift \
//   Sofa/Presentations/Paywall/PaywallViewModel.swift \
//   Sofa/Services/StoreManager/StoreManager.swift scripts/paywall-smoke.swift \
//   -o /tmp/sofa-paywall-smoke && /tmp/sofa-paywall-smoke
import Foundation
import StoreKit
import SwiftUI

// Minimal collaborators for the production view model; never call a real store.
struct NetworkMonitor { let isConnected: Bool }
final class AnalyticsManager {
    func logPaywall(_ placement: PaywallModel.Placement) {}
    func logTransaction(_ transaction: StoreKit.Transaction, product: Product, for placement: PaywallModel.Placement) {}
}
enum SofaConstants {
    enum AppStorage { static let isGiftAvailable = "SOFA.PaywallSmoke.isGiftAvailable" }
    enum AppSupport {
        static let privacy = "https://example.com/privacy"
        static let terms = "https://example.com/terms"
    }
}
struct AlertItem {
    let title: Text
    let message: Text
    let primaryButton: Alert.Button
    var secondaryButton: Alert.Button?
    static func error(message: String, onOK: @escaping () -> Void = {}) -> Self {
        Self(title: Text("Error"), message: Text(message), primaryButton: .default(Text("OK"), action: onOK))
    }
    static func noInternetConnection(onRetry: @escaping () -> Void) -> Self {
        Self(title: Text("Offline"), message: Text("Retry"), primaryButton: .default(Text("Retry"), action: onRetry))
    }
}
final class EmptyStore: StoreManager {
    let failsLoading: Bool
    private(set) var purchaseCalls = 0
    init(failsLoading: Bool = false) { self.failsLoading = failsLoading }
    func configure() {}
    func getProducts() async throws -> [Product] {
        if failsLoading { throw StoreManagerError.purchaseFailed }
        return []
    }
    func getProduct(id: String) async throws -> Product? { nil }
    func purchaseProduct(_ product: Product) async throws -> StoreKit.Transaction {
        purchaseCalls += 1
        throw StoreManagerError.purchaseFailed
    }
    func updatePurchasedProducts() async {}
    func restorePurchasedProducts() async throws -> Bool { false }
    func hasPurchasedProduct() -> Bool { false }
}

@main
struct PaywallSmoke {
    @MainActor static func settled(_ model: PaywallViewModel) async {
        for _ in 0..<100 where model.isLoading {
            try? await Task.sleep(for: .milliseconds(10))
        }
        precondition(!model.isLoading, "Loading did not settle")
    }

    @MainActor static func main() async {
        precondition(PaywallModel.Subscription.allCases == [.yearly, .monthly])
        precondition(PaywallModel.Subscription.monthly.id == "com.ai.sofa.subscriptions.month")
        precondition(PaywallModel.Subscription.yearly.id == "com.ai.sofa.subscriptions.year")
        precondition(PaywallModel.Subscription(id: "com.ai.sofa.subscriptions.week.3trial") == nil)
        precondition(PaywallModel.Subscription.yearly.isBestValue)
        precondition(!PaywallModel.Subscription.monthly.isBestValue)
        print("PASS product choices, product IDs and annual recommendation")

        let store = EmptyStore()
        let model = PaywallViewModel(storeManager: store,
            networkMonitor: NetworkMonitor(isConnected: true),
            analyticsManager: AnalyticsManager(), placement: .settings)
        precondition(model.selectedSubscription == .yearly)
        precondition(!model.canStartMonthlyTrial && !model.isTrialOn && !model.canPurchase)
        await settled(model)
        precondition(model.subscriptions.isEmpty && model.alertItem != nil)
        precondition(!model.canPurchase && !model.canStartMonthlyTrial)
        model.didTapSubscriptionButton(.monthly)
        precondition(model.selectedSubscription == .yearly)
        model.didTapContinueButton()
        precondition(store.purchaseCalls == 0)
        print("PASS missing products: no fabricated trial, invalid selection or purchase")

        model.didTapRestoreButton()
        await settled(model)
        precondition(model.alertItem != nil && !model.canStartMonthlyTrial)
        print("PASS empty restore completes without unlocking PRO or advertising a trial")

        let offline = PaywallViewModel(storeManager: EmptyStore(),
            networkMonitor: NetworkMonitor(isConnected: false),
            analyticsManager: AnalyticsManager(), placement: .settings)
        await settled(offline)
        precondition(offline.alertItem != nil && !offline.canPurchase)
        print("PASS offline state exits loading and offers recovery")

        let failure = PaywallViewModel(storeManager: EmptyStore(failsLoading: true),
            networkMonitor: NetworkMonitor(isConnected: true),
            analyticsManager: AnalyticsManager(), placement: .settings)
        await settled(failure)
        precondition(failure.alertItem != nil && !failure.canPurchase)
        print("PASS product load error exits loading and blocks purchase")
        print("All runtime smoke tests passed. Actual StoreKit offer/purchase/restore QA remains required.")
    }
}
