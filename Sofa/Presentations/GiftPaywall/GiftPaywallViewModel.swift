//
//  GiftPaywallViewModel.swift
//  Sofa
//
//  Created by dukes on 4/17/26.
//

import Foundation
import Observation
import StoreKit
import SwiftUI

@MainActor @Observable
final class GiftPaywallViewModel {

    // MARK: - Public Properties

    private(set) var state: GiftPaywallModel.State = .teaser
    private(set) var giftProduct: Product?
    private(set) var standardProduct: Product?
    private(set) var isLoading = false
    private(set) var dismissTrigger = UUID()
    let subscription: GiftPaywallModel.Subscription = .yearly
    private(set) var safariURL: URL?
    var isSafariPresented = false
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let analyticsManager: AnalyticsManager
    private let storeManager: StoreManager

    // MARK: - Inits

    init(
        analyticsManager: AnalyticsManager,
        storeManager: StoreManager,
    ) {
        self.analyticsManager = analyticsManager
        self.storeManager = storeManager

        initialize()
    }
}

// MARK: - Public Methods

extension GiftPaywallViewModel {

    // MARK: - Output

    func formatGiftPrice() -> String {
        let price = formattedPrice(for: giftProduct)
        return String(
            format: String(localized: "justPricePerYearFormat"),
            price,
            unitTitle(for: giftProduct).lowercased()
        )
    }

    func formatStandardPrice() -> String {
        let price = formattedPrice(for: standardProduct)
        return String(
            format: String(localized: "standardPricePerYearFormat"),
            price,
            unitTitle(for: standardProduct).lowercased()
        )
    }

    func formatOfferDiscount() -> String {
        let percent = calculateDiscountFraction()
        return String(
            format: String(localized: "percentOffFormat"),
            percent.formatted(.percent.precision(.fractionLength(0)))
        )
    }

    func formatDiscountBadge() -> String {
        let percent = calculateDiscountFraction()
        return "-\(percent.formatted(.percent.precision(.fractionLength(0))))"
    }

    // MARK: - Input

    func didTapCloseButton() {
        dismissTrigger = UUID()
    }

    func didTapContinueButton() {
        switch state {
        case .teaser: state = .offer
        case .offer: purchaseProduct()
        }
    }

    func didTapRestoreButton() {
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                let isRestored = try await storeManager.restorePurchasedProducts()
                alertItem = AlertItem(
                    title: Text(
                        isRestored
                        ? String(localized: "subscriptionRestored")
                        : String(localized: "subscriptionNotFound")
                    ),
                    message: Text(
                        isRestored
                        ? String(localized: "subscriptionRestoredMessage")
                        : String(localized: "subscriptionNotFoundMessage")
                    ),
                    primaryButton: .default(Text(String(localized: "ok"))) { [weak self] in
                        guard let self else { return }
                        if isRestored {
                            dismissTrigger = UUID()
                        }
                    }
                )
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    func didTapPrivacyButton() {
        guard let url = URL(string: SofaConstants.AppSupport.privacy) else { return }
        safariURL = url
        isSafariPresented = true
    }

    func didTapTermsButton() {
        guard let url = URL(string: SofaConstants.AppSupport.terms) else { return }
        safariURL = url
        isSafariPresented = true
    }
}

// MARK: - Private Methods

extension GiftPaywallViewModel {
    private func initialize() {
        analyticsManager.logPaywall(.gift)
        loadProduct()
    }

    private func loadProduct() {
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                async let giftProduct = storeManager.getProduct(id: subscription.id)
                async let standardProduct = storeManager.getProduct(id: PaywallModel.Subscription.yearly.id)

                self.giftProduct = try await giftProduct
                self.standardProduct = try await standardProduct

                guard self.giftProduct != nil else {
                    alertItem = .error(message: String(localized: "productsEmptyMessage")) { [weak self] in
                        guard let self else { return }
                        dismissTrigger = UUID()
                    }
                    return
                }
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func purchaseProduct() {
        guard let giftProduct else {
            loadProduct()
            return
        }
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                let transaction = try await storeManager.purchaseProduct(giftProduct)
                analyticsManager.logTransaction(transaction, product: giftProduct, for: .gift)
                dismissTrigger = UUID()
            } catch StoreManagerError.purchaseCancelled {
                return
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}

extension GiftPaywallViewModel {
    private func unitTitle(for product: Product?) -> String {
        guard let product else { return String(localized: "year") }
        return switch product.subscription?.subscriptionPeriod.unit {
        case .month: String(localized: "month")
        case .year: String(localized: "year")
        case .week: String(localized: "week")
        case .day where product.subscription?.subscriptionPeriod.value == 7: String(localized: "week")
        case .day: String(localized: "day")
        case .none, .some: String(localized: "year")
        }
    }

    private func formattedPrice(for product: Product?) -> String {
        guard let product else { return "" }
        return product.price.formatted(product.priceFormatStyle)
    }

    private func calculateDiscountFraction() -> Decimal {
        let defaultDiscount: Decimal = 0.3
        guard let standardProduct, let giftProduct, standardProduct.price > .zero else { return defaultDiscount }
        let discount = (standardProduct.price - giftProduct.price) / standardProduct.price
        return max(discount, .zero)
    }

    private func calculateDiscountPercent() -> Int {
        let defaultDiscount = 30
        guard let standardProduct, let giftProduct, standardProduct.price > .zero else { return defaultDiscount }
        let discount = (standardProduct.price - giftProduct.price) / standardProduct.price * 100
        let roundedDiscount = NSDecimalNumber(decimal: discount)
            .rounding(accordingToBehavior: nil)
            .intValue
        let maxDiscount = max(roundedDiscount, .zero)
        return maxDiscount > .zero ? maxDiscount : defaultDiscount
    }
}
