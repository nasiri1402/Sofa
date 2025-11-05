//
//  GenerationResultViewModel.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class GenerationResultViewModel {

    // MARK: - Public Properties

    let project: Project
    var alertItem: AlertItem?
    var isPaywallPresented = false
    
    var isPro: Bool {
        storeManager.hasPurchasedProduct()
    }

    // MARK: - Private Properties

    private let router: GenerationResultRouter
    private let dataStorage: DataStorage
    private let storeManager: StoreManager

    private var profile: Profile?

    // MARK: - Inits

    init(
        router: GenerationResultRouter,
        dataStorage: DataStorage,
        storeManager: StoreManager,
        project: Project
    ) {
        self.router = router
        self.dataStorage = dataStorage
        self.storeManager = storeManager
        self.project = project

        fetchProfile()
    }
}

// MARK: - Public Properties

extension GenerationResultViewModel {

    // MARK: - Input

    func didTapNavigationBarLeadingButton() {
        router.back()
    }

    func didTapChangeInputButton() {
        guard isPro else {
            isPaywallPresented = true
            return
        }
        // TODO: Навигация к настройкам генерации
    }

    func didTapGenerateMoreButton() {
        guard isPro else {
            isPaywallPresented = true
            return
        }
        // TODO: Навигация к лоадеру генератора
    }

    func didTapPlanButton(_ plan: Project.Plan) {
        // TODO: Навигаация к дереву шагов
    }
}

// MARK: - Private Methods

extension GenerationResultViewModel {
    private func fetchProfile() {
        Task { @MainActor in
            do {
                profile = try dataStorage.fetchProfile()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}
