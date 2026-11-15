// Regression checks against production view models using deterministic stand-ins.
// No network, real StoreKit purchases, or App Store Connect changes.
// From the repository root:
// xcrun swiftc -parse-as-library -target arm64-apple-macos14.0 \
//   Sofa/Presentations/Paywall/Paywall{Model,ViewModel}.swift \
//   Sofa/Presentations/GiftPaywall/GiftPaywall{Model,ViewModel}.swift \
//   scripts/paywall-regressions.swift -o /tmp/sofa-paywall-regressions
// /tmp/sofa-paywall-regressions
import Foundation
import StoreKit
import SwiftUI

@MainActor final class EligibilityGate {
    var blocked = false
    var reads = 0
    private var continuation: CheckedContinuation<Bool, Never>?
    func read() async -> Bool {
        reads += 1
        if blocked { return await withCheckedContinuation { continuation = $0 } }
        return true
    }
    func release() { blocked = false; continuation?.resume(returning: true); continuation = nil }
}

// Intentionally shadows StoreKit.Product inside this test module only.
struct Product {
    enum Unit { case day, week, month, year }
    struct Period { let unit: Unit; let value: Int }
    struct Offer {
        enum Mode { case freeTrial, payUpFront }
        let paymentMode: Mode
        let period: Period
        let periodCount: Int
    }
    struct Info {
        let subscriptionPeriod: Period
        let introductoryOffer: Offer?
        let gate: EligibilityGate
        var isEligibleForIntroOffer: Bool { get async { await gate.read() } }
    }
    let id: String
    let price: Decimal
    let subscription: Info?
    var currencyCode = "USD"
    var storeDisplayPrice: String? = nil
    var displayPrice: String { storeDisplayPrice ?? price.formatted(priceFormatStyle) }
    var priceFormatStyle: Decimal.FormatStyle.Currency { .currency(code: currencyCode) }
}

protocol StoreManager {
    @MainActor func getProducts() async throws -> [Product]
    @MainActor func getProduct(id: String) async throws -> Product?
    @MainActor func purchaseProduct(_ product: Product) async throws -> StoreKit.Transaction
    @MainActor func restorePurchasedProducts() async throws -> Bool
}
enum StoreManagerError: Error { case purchaseCancelled }
struct NetworkMonitor { let isConnected: Bool }
final class AnalyticsManager {
    func logPaywall(_ placement: PaywallModel.Placement) {}
    func logTransaction(_ transaction: StoreKit.Transaction, product: Product, for placement: PaywallModel.Placement) {}
}
enum SofaConstants {
    enum AppStorage { static let isGiftAvailable = "SOFA.QA.DiagnosticGift" }
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
@MainActor final class ProbeStore: StoreManager {
    let products: [Product]
    var purchaseCalls = 0
    init(_ products: [Product]) { self.products = products }
    func getProducts() async throws -> [Product] { products }
    func getProduct(id: String) async throws -> Product? { products.first { $0.id == id } }
    func purchaseProduct(_ product: Product) async throws -> StoreKit.Transaction {
        purchaseCalls += 1
        throw StoreManagerError.purchaseCancelled
    }
    func restorePurchasedProducts() async throws -> Bool { false }
}

@main struct MonetizationProbes {
    @MainActor static func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<100 {
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(10))
        }
        preconditionFailure("Probe did not settle")
    }
    @MainActor static func main() async {
        let gate = EligibilityGate()
        let monthly = Product(id: "com.ai.sofa.subscriptions.month", price: Decimal(string: "4.99")!,
            subscription: .init(subscriptionPeriod: .init(unit: .month, value: 1),
                introductoryOffer: .init(paymentMode: .freeTrial, period: .init(unit: .day, value: 3), periodCount: 1), gate: gate))
        let annual = Product(id: "com.ai.sofa.subscriptions.year", price: Decimal(string: "39.99")!,
            subscription: .init(subscriptionPeriod: .init(unit: .year, value: 1), introductoryOffer: nil, gate: gate))
        let gift = Product(id: "com.ai.sofa.subscriptions.year.gift", price: Decimal(string: "29.99")!,
            subscription: .init(subscriptionPeriod: .init(unit: .year, value: 1), introductoryOffer: nil, gate: gate))

        // Store-provided display strings must survive formatting/locale differences verbatim.
        for (currency, amount, displayed) in [
            ("USD", "39.99", "$39.99"),
            ("EUR", "39.99", "39,99 €"),
            ("JPY", "4800", "¥4,800"),
            ("KWD", "3.750", "KWD 3.750"),
        ] {
            let regionalProduct = Product(id: annual.id, price: Decimal(string: amount)!,
                subscription: annual.subscription, currencyCode: currency, storeDisplayPrice: displayed)
            let regionalModel = PaywallViewModel(storeManager: ProbeStore([regionalProduct]),
                networkMonitor: .init(isConnected: true), analyticsManager: AnalyticsManager(), placement: .settings)
            await waitUntil { !regionalModel.isLoading }
            precondition(regionalModel.formatPrice(for: .yearly) == displayed, currency)
            precondition(regionalModel.formatPrice(for: .monthly).isEmpty)
            print("PASS: StoreKit display price preserved for \(currency)")
        }
        let store = ProbeStore([annual, monthly])
        let model = PaywallViewModel(storeManager: store, networkMonitor: .init(isConnected: true),
            analyticsManager: AnalyticsManager(), placement: .settings)
        await waitUntil { !model.isLoading }
        precondition(model.canStartMonthlyTrial)
        model.didTapSubscriptionButton(.monthly)
        precondition(model.isTrialOn)
        precondition(model.selectedSubscription == .monthly)
        model.didTapSubscriptionButton(.yearly)
        precondition(model.selectedSubscription == .yearly)
        precondition(!model.isTrialOn)
        print("PASS: trial status follows explicit monthly/yearly card selection")

        gate.blocked = true
        let previousReads = gate.reads
        model.didTapContinueButton()
        await waitUntil { gate.reads > previousReads }
        precondition(model.isLoading && store.purchaseCalls == 0)
        print("KNOWN RISK (unchanged by request): annual purchase waits for monthly trial eligibility")
        gate.release()
        await waitUntil { !model.isLoading }
        precondition(store.purchaseCalls == 1)

        let missingStandardStore = ProbeStore([gift])
        let giftModel = GiftPaywallViewModel(analyticsManager: AnalyticsManager(), storeManager: missingStandardStore)
        await waitUntil { !giftModel.isLoading }
        precondition(giftModel.giftProduct != nil && giftModel.standardProduct == nil && giftModel.alertItem == nil)
        precondition(giftModel.formatDiscountBadge() == nil && giftModel.formatOfferDiscount() == nil)
        print("PASS: no invented Gift percentage when the standard price is missing")
        giftModel.didTapContinueButton() // teaser -> offer
        giftModel.didTapContinueButton() // purchase request one
        giftModel.didTapContinueButton() // purchase request two, before UI redraw
        await waitUntil { missingStandardStore.purchaseCalls == 2 }
        print("KNOWN RISK (unchanged by request): duplicate Gift actions submit two mocked calls, not actual charges")

        let validGift = GiftPaywallViewModel(analyticsManager: AnalyticsManager(), storeManager: ProbeStore([annual, gift]))
        await waitUntil { !validGift.isLoading }
        precondition(validGift.formatDiscountBadge()?.contains("25") == true)
        precondition(validGift.formatOfferDiscount() != nil)
        print("PASS: $39.99 versus $29.99 displays the actual rounded discount of 25%")

        func product(_ id: String, _ price: String, currency: String = "USD",
                     unit: Product.Unit = .year, count: Int = 1) -> Product {
            Product(id: id, price: Decimal(string: price)!,
                    subscription: .init(subscriptionPeriod: .init(unit: unit, value: count),
                                        introductoryOffer: nil, gate: gate), currencyCode: currency)
        }
        let standardID = annual.id
        let giftID = gift.id
        let hiddenCases: [(String, [Product])] = [
            ("missing Gift", [annual]),
            ("zero standard price", [product(standardID, "0"), gift]),
            ("equal prices", [annual, product(giftID, "39.99")]),
            ("Gift costs more", [annual, product(giftID, "49.99")]),
            ("different currencies", [annual, product(giftID, "29.99", currency: "EUR")]),
            ("different period units", [annual, product(giftID, "29.99", unit: .month)]),
            ("different period lengths", [annual, product(giftID, "29.99", count: 2)]),
        ]
        for (label, products) in hiddenCases {
            let candidate = GiftPaywallViewModel(analyticsManager: AnalyticsManager(), storeManager: ProbeStore(products))
            await waitUntil { !candidate.isLoading }
            precondition(candidate.formatDiscountBadge() == nil && candidate.formatOfferDiscount() == nil, label)
            print("PASS: discount hidden for \(label)")
        }
        let regional = GiftPaywallViewModel(analyticsManager: AnalyticsManager(), storeManager: ProbeStore([
            product(standardID, "100", currency: "EUR"), product(giftID, "80", currency: "EUR")
        ]))
        await waitUntil { !regional.isLoading }
        precondition(regional.formatDiscountBadge()?.contains("20") == true)
        print("PASS: actual regional prices, not a fixed US percentage, determine the discount")
        print("Regression checks completed; StoreKit products and transactions were mocked.")
    }
}
