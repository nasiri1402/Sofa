//
//  AnalyticsManager.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Adapty
import StoreKit

final class AnalyticsManager: NSObject {

    // MARK: - Private Properties

    private var retryCount: Int = .zero

    private var arePaywallsLoaded = false
    private var paywalls = [PaywallModel.Placement: AdaptyPaywall]()

    private lazy var adaptyQueue = DispatchQueue(
        label: SofaConstants.AppInfo.bundleIdentifier + ".adapty",
        qos: .utility
    )
    nonisolated private let paywallsSyncQueue = DispatchQueue(
        label: SofaConstants.AppInfo.bundleIdentifier + "adapty.paywalls.sync"
    )
    private lazy var paywallsLoadCompletionQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.isSuspended = true
        return operationQueue
    }()

    // MARK: - Public Methods

    func configure() {
        initializeAdapty()
    }
}

// MARK: - Adapty

extension AnalyticsManager {
    func logPaywall(_ placement: PaywallModel.Placement) {
        let operation: () -> Void = { [weak self] in
            guard let self else { return }
            guard let paywall = paywalls[placement] else {
                debugPrint("Paywall not found for \(placement.rawValue)")
                return
            }
            Adapty.logShowPaywall(paywall) { error in
                if let error {
                    debugPrint("Failed to log Adapty paywall for \(placement.rawValue): \(error).")
                } else {
                    debugPrint("Adapty paywall view recorded successfully. Placement: \(placement.rawValue)")
                }
            }
        }
        guard arePaywallsLoaded else {
            paywallsLoadCompletionQueue.addOperation(operation)
            return
        }
        operation()
    }

    func logTransaction(_ transaction: Transaction, product: Product, for placement: PaywallModel.Placement) {
        let operation: () -> Void = { [weak self] in
            guard let self else { return }
            guard let paywall = paywalls[placement] else {
                debugPrint("Paywall not found for \(placement.rawValue).")
                return
            }
            bindPaywall(paywall, with: transaction, retryCount: .zero) { result in
                switch result {
                case .failure(let error):
                    debugPrint(
                        "Transaction binding failed for placement \(placement.rawValue): \(error.localizedDescription)"
                    )
                case .success:
                    debugPrint("Successfully bound transaction for placement \(placement.rawValue)")
                }
            }
        }
        guard arePaywallsLoaded else {
            paywallsLoadCompletionQueue.addOperation(operation)
            return
        }
        operation()
    }

    // MARK: - Private Methods

    private func initializeAdapty() {
        let configuration = AdaptyConfiguration
            .builder(withAPIKey: Secrets.adapty)
            .with(observerMode: true)
            .with(callbackDispatchQueue: adaptyQueue)
            .with(logLevel: .error)
            .build()

        Adapty.activate(with: configuration) { [weak self] error in
            guard let self else { return }
            if let error {
                debugPrint("Failed to initialize Adapty SDK: \(error.localizedDescription)")
            } else {
                Task { @MainActor in
                    self.loadPaywalls()
                }
            }
        }
    }

    private func loadPaywalls() {
        let dispatchGroup = DispatchGroup()
        var results: [PaywallModel.Placement: Result<AdaptyPaywall, AdaptyError>] = [:]

        PaywallModel.Placement.allCases.forEach { placement in
            dispatchGroup.enter()
            Adapty.getPaywall(placementId: placement.rawValue) { [weak self] result in
                guard let self else { return }
                // Единственная точка записи в словарь — сериал-очередь
                paywallsSyncQueue.async {
                    results[placement] = result
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: adaptyQueue) { [weak self] in
            guard let self else { return }
            for (placement, result) in results {
                switch result {
                case .failure(let error):
                    debugPrint("Failed to load paywall for placement \(placement.rawValue): \(error)")
                case .success(let paywall):
                    paywalls[placement] = paywall
                }
            }
            debugPrint("Adapty paywalls are loaded successfully.")
            arePaywallsLoaded = true
            paywallsLoadCompletionQueue.isSuspended = false
        }
    }

    /// В данном методе рекурсия необходима для верного связывания эксперимента и транзакции. Выдержка с доки Adapty:
    /// We recommend delaying the call for setting the variation ID until after the Recipe validation and implementing a retry logic with a delay of 5 seconds and a limit of 3 attempts.
    /// This approach can help ensure that the variation ID is set correctly and reduce the likelihood of errors or unexpected behavior.
    private func bindPaywall(
        _ paywall: AdaptyPaywall,
        with transaction: Transaction,
        retryCount: Int,
        completion: ((Result<Void, Error>) -> Void)?
    ) {
        self.retryCount = retryCount
        let variationId = paywall.variationId
        // Задержка больше с каждой новой попыткой
        let delayInSeconds = self.retryCount * 5
        adaptyQueue.asyncAfter(deadline: .now() + .seconds(delayInSeconds)) { [weak self] in
            Adapty.reportTransaction(transaction, withVariationId: variationId) { [weak self] error in
                guard let self else { return }
                if let error {
                    if retryCount < 3 {
                        Task { @MainActor in
                            self.bindPaywall(
                                paywall,
                                with: transaction,
                                retryCount: retryCount + 1,
                                completion: completion
                            )
                        }
                        return
                    } else {
                        completion?(.failure(error))
                    }
                } else {
                    completion?(.success(()))
                }
            }
        }
    }
}

// MARK: - Secrets

extension AnalyticsManager {
    private enum Secrets {

        // MARK: - Public Properties

        static var adapty: String {
            String(bytes: unmask(maskedAdapty), encoding: .utf8) ?? ""
        }

        // MARK: - Private Properties

        private static let maskedAdapty: [UInt8] = [
            2
        ]

        // MARK: - Private Methods

        private static func unmask(_ data: [UInt8]) -> [UInt8] {
            data.enumerated().map { i, m in m ^ mask(at: i) }
        }

        private static func mask(at index: Int) -> UInt8 {
            UInt8(((index * 73) ^ 0xA5) & 0xFF)
        }
    }
}
