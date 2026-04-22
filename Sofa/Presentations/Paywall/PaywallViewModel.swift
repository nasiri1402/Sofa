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
    var isTrialOn: Bool {
        didSet {
            guard oldValue != isTrialOn else { return }
            selectedSubscription = isTrialOn ? .weekly : .yearly
        }
    }

    // MARK: - Private Properties

    private let storeManager: StoreManager
    private let networkMonitor: NetworkMonitor
    private let analyticsManager: AnalyticsManager
    private let placement: PaywallModel.Placement

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
        self.selectedSubscription = .weekly
        self.isTrialOn = true

        initialize()
    }
}

// MARK: - Public Methods

extension PaywallViewModel {

    // MARK: - Input

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

    func didTapSubscriptionButton(_ subscription: PaywallModel.Subscription) {
        guard selectedSubscription.id != subscription.id else { return }
        selectedSubscription = subscription
        isTrialOn = subscription.withTrial
    }

    func didTapContinueButton() {
        guard let product = findProduct(for: selectedSubscription) else { return }
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
        return product.price.formatted(product.priceFormatStyle)
    }

    func formatPriceDescription(for subscription: PaywallModel.Subscription) -> String {
        let description = switch subscription {
        case .yearly: String(localized: "just") + " " + getPricePerWeek(for: subscription)
        case .weekly: String(localized: "cheaperThanCoffee") + " ☕"
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
        Task { @MainActor in
            do {
                products = try await storeManager.getProducts()
                subscriptions = products.compactMap { PaywallModel.Subscription(id: $0.id) }
                guard subscriptions.isEmpty else { return }
                alertItem = AlertItem(
                    title: Text(
                        networkMonitor.isConnected
                        ? String(localized: "productsEmpty")
                        : String(localized: "noInternetConnection")
                    ),
                    message: Text(
                        networkMonitor.isConnected
                        ? String(localized: "productsEmptyMessage")
                        : String(localized: "noInternetConnectionMessage")
                    ),
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

    private func purchaseProduct(_ product: Product) {
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                let transaction = try await storeManager.purchaseProduct(product)
                analyticsManager.logTransaction(transaction, product: product, for: placement)
                dismissTrigger = UUID()
            } catch StoreManagerError.purchaseCancelled {
                return
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func getPricePerWeek(for subscription: PaywallModel.Subscription) -> String {
        guard let product = findProduct(for: subscription) else { return "" }
        let productPrice = product.price
        let pricePerWeek: Decimal = switch product.subscription?.subscriptionPeriod.unit {
        case .day, .week: productPrice
        case .month: productPrice / 4
        case .year: productPrice / 52
        case .none, .some: .zero
        }
        return pricePerWeek.formatted(product.priceFormatStyle) + "/" + String(localized: "week").lowercased()
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
