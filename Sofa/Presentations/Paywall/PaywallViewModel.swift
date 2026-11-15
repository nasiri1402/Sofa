//
//  PaywallViewModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import Observation
import StoreKit
import SwiftUI

@MainActor @Observable
final class PaywallViewModel {

    // MARK: - Public Properties

    private(set) var products: [Product] = []
    private(set) var subscriptions: [PaywallModel.Subscription] = []
    private(set) var selectedSubscription: PaywallModel.Subscription
    private(set) var isLoading = false
    private(set) var dismissTrigger = UUID()
    private(set) var safariURL: URL?
    var isSafariPresented = false
    var alertItem: AlertItem?
    private(set) var canStartMonthlyTrial = false
    var isTrialOn: Bool {
        selectedSubscription == .monthly && canStartMonthlyTrial
    }

    var canPurchase: Bool {
        !isLoading && findProduct(for: selectedSubscription) != nil
    }

    // MARK: - Private Properties

    private let storeManager: StoreManager
    private let networkMonitor: NetworkMonitor
    private let analyticsManager: AnalyticsManager
    private let placement: PaywallModel.Placement

    @ObservationIgnored @AppStorage(SofaConstants.AppStorage.isGiftAvailable)
    private var isGiftAvailable = true

    // MARK: - Inits

    init(
        storeManager: StoreManager,
        networkMonitor: NetworkMonitor,
        analyticsManager: AnalyticsManager,
        placement: PaywallModel.Placement
    ) {
        self.storeManager = storeManager
        self.networkMonitor = networkMonitor
        self.analyticsManager = analyticsManager
        self.placement = placement
        self.selectedSubscription = .yearly

        initialize()
    }
}

// MARK: - Public Methods

extension PaywallViewModel {

    // MARK: - Input

    func didTapRestoreButton() {
        guard !isLoading else { return }
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                let isRestored = try await storeManager.restorePurchasedProducts()
                await refreshMonthlyTrialEligibility()
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

    func didTapSubscriptionButton(_ subscription: PaywallModel.Subscription) {
        guard !isLoading, subscriptions.contains(subscription) else { return }
        selectedSubscription = subscription
    }

    func didTapContinueButton() {
        guard canPurchase, let product = findProduct(for: selectedSubscription) else { return }
        purchaseProduct(product)
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

    // MARK: - Output

    func formatFreePrice() -> String {
        guard let product = findProduct(for: selectedSubscription) else { return "$0.00" }
        return Decimal.zero.formatted(product.priceFormatStyle)
    }

    func formatPrice(for subscription: PaywallModel.Subscription) -> String {
        guard let product = findProduct(for: subscription) else { return "" }
        return product.displayPrice
    }

    func formatPriceDescription(for subscription: PaywallModel.Subscription) -> String {
        let description = switch subscription {
        case .yearly: String(localized: "just") + " " + getPricePerMonth(for: subscription)
        case .monthly: canStartMonthlyTrial
            ? String(localized: "try3DaysFree")
            : String(localized: "cancelAnyTime")
        }
        return description.lowercased()
    }

    func getUnit(for subscription: PaywallModel.Subscription) -> String {
        guard let product = findProduct(for: subscription) else { return "" }
        return switch product.subscription?.subscriptionPeriod.unit {
        case .month: String(localized: "month")
        case .year: String(localized: "year")
        case .week: String(localized: "week")
        case .day where product.subscription?.subscriptionPeriod.value == 7: String(localized: "week")
        case .none, .some: ""
        }
    }
}

// MARK: - Private Methods

extension PaywallViewModel {
    private func initialize() {
        analyticsManager.logPaywall(placement)
        loadProducts()
    }

    private func loadProducts() {
        guard !isLoading else { return }
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                products = try await storeManager.getProducts()
                subscriptions = PaywallModel.Subscription.allCases.filter { subscription in
                    products.contains { $0.id == subscription.id }
                }
                if !subscriptions.contains(selectedSubscription), let first = subscriptions.first {
                    selectedSubscription = first
                }
                await refreshMonthlyTrialEligibility()
                guard subscriptions.isEmpty else { return }
                guard networkMonitor.isConnected else {
                    alertItem = .noInternetConnection(onRetry: { [weak self] in
                        guard let self else { return }
                        loadProducts()
                    })
                    return
                }
                alertItem = AlertItem(
                    title: Text(String(localized: "productsEmpty")),
                    message: Text(String(localized: "productsEmptyMessage")),
                    primaryButton: .default(Text(String(localized: "ok"))) { [weak self] in
                        guard let self else { return }
                        dismissTrigger = UUID()
                    },
                    secondaryButton: .default(Text(String(localized: "retry"))) { [weak self] in
                        guard let self else { return }
                        loadProducts()
                    }
                )
            } catch {
                alertItem = .error(message: error.localizedDescription) { [weak self] in
                    guard let self else { return }
                    dismissTrigger = UUID()
                }
            }
        }
    }

    private func findProduct(for subscription: PaywallModel.Subscription?) -> Product? {
        products.first { subscription?.id == $0.id }
    }

    private func refreshMonthlyTrialEligibility() async {
        // Eligibility alone can be true even when no offer is configured.
        // Never promise three free days unless StoreKit confirms both the
        // configured duration and the customer's eligibility in this group.
        guard let info = findProduct(for: .monthly)?.subscription,
              let offer = info.introductoryOffer,
              offer.paymentMode == .freeTrial,
              offer.period.unit == .day,
              offer.period.value == 3,
              offer.periodCount == 1 else {
            canStartMonthlyTrial = false
            return
        }
        canStartMonthlyTrial = await info.isEligibleForIntroOffer
    }

    private func purchaseProduct(_ product: Product) {
        guard !isLoading else { return }
        let wasTrialPromised = isTrialOn
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                await refreshMonthlyTrialEligibility()
                // If eligibility changed, update the visible terms and let the
                // customer confirm again instead of silently charging them.
                guard !wasTrialPromised || canStartMonthlyTrial else { return }
                let transaction = try await storeManager.purchaseProduct(product)
                analyticsManager.logTransaction(transaction, product: product, for: placement)
                isGiftAvailable = false
                dismissTrigger = UUID()
            } catch StoreManagerError.purchaseCancelled {
                return
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func getPricePerMonth(for subscription: PaywallModel.Subscription) -> String {
        guard let product = findProduct(for: subscription) else { return "" }
        let productPrice = product.price
        let pricePerMonth: Decimal = switch product.subscription?.subscriptionPeriod.unit {
        case .month: productPrice
        case .year: productPrice / 12
        case .none, .some: .zero
        }
        return pricePerMonth.formatted(product.priceFormatStyle) + "/" + String(localized: "month").lowercased()
    }

    private func getPricePerDay(for subscription: PaywallModel.Subscription) -> String {
        guard let product = findProduct(for: subscription) else { return "" }
        let productPrice = product.price
        let pricePerDay: Decimal = switch product.subscription?.subscriptionPeriod.unit {
        case .day: productPrice
        case .week: productPrice / 7
        case .month: productPrice / 30
        case .year: productPrice / 365
        case .none, .some: .zero
        }
        return pricePerDay.formatted(product.priceFormatStyle) + "/" + String(localized: "day").lowercased()
    }
}
