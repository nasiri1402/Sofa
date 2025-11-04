//
//  StoreManager.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import StoreKit

// MARK: - Interfaces

protocol StoreManager {
    /// Подготавливает сервис к работе
    /// - Warning: Вызывать сразу при старте приложения
    func configure()

    /// Получить возможные к покупке продукты
    /// - Returns: Возможные продукты
    @MainActor
    func getProducts() async throws -> [Product]

    /// Купить продукт
    /// - Parameter product: Продукт
    @MainActor @discardableResult
    func purchaseProduct(_ product: Product) async throws -> Transaction

    /// Обновляет информацию о приобретённых продуктах
    @MainActor
    func updatePurchasedProducts() async

    /// Восстанавливает приобретённые продукты
    /// - Returns: Флаг указывающий были ли приобретенные продукты ранее
    @MainActor
    func restorePurchasedProducts() async throws -> Bool

    /// Проверяет, есть ли актуальные купленные продукты
    func hasPurchasedProduct() -> Bool
}

// MARK: - Errors

enum StoreManagerError: LocalizedError {
    case purchasePending
    case purchaseFailed
    case purchaseCancelled

    var errorDescription: String? {
        switch self {
        case .purchasePending: String(localized: "storeManagerErrorPurchasePending")
        case .purchaseFailed: String(localized: "storeManagerErrorPurchaseFailed")
        case .purchaseCancelled: String(localized: "storeManagerErrorPurchaseCancelled")
        }
    }
}

// MARK: - Implementations

final class DefaultStoreManager: StoreManager {

    // MARK: - Private Properties

    private var products: [Product] = []
    private var purchasedProductIDs = Set<String>()
    private var updatesTask: Task<Void, Never>?

    // MARK: - Public Properties

    func configure() {
        updatesTask = observeTransactionUpdates()
        Task {
            try? await loadProducts()
            await updatePurchasedProducts()
            try? await finishUnfinishedTransactions()
        }
    }

    @MainActor
    func updatePurchasedProducts() async {
        // Сброс текущих ID перед обновлением
        purchasedProductIDs.removeAll()

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil, transaction.expirationDate.map({ $0 > Date() }) == true {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }

    @MainActor
    func getProducts() async throws -> [Product] {
        if products.isEmpty {
            try await loadProducts()
        }
        return products
    }

    @MainActor @discardableResult
    func purchaseProduct(_ product: Product) async throws -> Transaction {
        try await finishUnfinishedTransactions()
        let result = try await product.purchase()
        switch result {
        case let .success(.verified(transaction)):
            await transaction.finish()
            await updatePurchasedProducts()
            return transaction
        case .success(.unverified): throw StoreManagerError.purchaseFailed
        case .userCancelled: throw StoreManagerError.purchaseCancelled
        case .pending: throw StoreManagerError.purchasePending
        @unknown default: throw StoreManagerError.purchaseFailed
        }
    }

    @MainActor
    func restorePurchasedProducts() async throws -> Bool {
        try await AppStore.sync()
        await updatePurchasedProducts()
        return !purchasedProductIDs.isEmpty
    }

    func hasPurchasedProduct() -> Bool {
        !purchasedProductIDs.isEmpty
    }

    // MARK: - Private Methods

    @MainActor
    private func loadProducts() async throws {
        products = try await Product.products(
            for: PaywallModel.Subscription.allCases.map(\.id)
        ).sorted { $0.price > $1.price }
    }

    /// Используется как failsafe против бага при покупке
    /// Когда пользователю может вернуться success со старой транзакцией вместо отображения confirmation sheet
    private func finishUnfinishedTransactions() async throws {
        for await result in Transaction.unfinished {
            switch result {
            case .unverified: break
            case .verified(let transaction): await transaction.finish()
            }
        }
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task {
            for await _ in Transaction.updates {
                await updatePurchasedProducts()
            }
        }
    }
}
