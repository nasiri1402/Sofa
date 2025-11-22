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
    var isDifficultyDialogPresented = false
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
        router.routeToRoot()
    }

    func didTapChangeInputButton() {
        guard isPro else {
            isPaywallPresented = true
            return
        }
        router.route(to: .brief(project, project.brief.copy(id: UUID())))
    }

    func didTapGenerateMoreButton() {
        if isPro {
            isDifficultyDialogPresented = true
        } else {
            isPaywallPresented = true
        }
    }

    func didTapDifficultyDialogButton(_ difficulty: Project.Plan.Difficulty) {
        router.route(to: .generationLoader(project, project.brief.copy(id: UUID()), difficulty))
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
