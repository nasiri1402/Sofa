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

    private(set) var project: Project
    var alertItem: AlertItem?
    var isPaywallPresented = false
    
    var isPro: Bool {
        storeManager.hasPurchasedProduct()
    }

    // MARK: - Private Properties

    private let router: GenerationResultRouter
    private let dataStorage: DataStorage
    private let storeManager: StoreManager

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
    }
}

// MARK: - Public Properties

extension GenerationResultViewModel {

    // MARK: - Input

    func didViewAppear() {
        fetchProject()
    }

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
        router.route(to: .stepTree(project, plan))
    }
}

// MARK: - Private Methods

extension GenerationResultViewModel {
    private func fetchProject() {
        Task { @MainActor in
            do {
                project = try dataStorage.fetchProject(id: project.id) ?? project
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}
