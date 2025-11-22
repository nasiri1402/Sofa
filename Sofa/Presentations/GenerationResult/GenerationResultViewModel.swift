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
        router.back()
    }

    func didTapChangeInputButton() {
        guard isPro else {
            isPaywallPresented = true
            return
        }
        router.route(to: .brief(project.brief.copy(id: UUID())) { [weak self] in
            guard let self, let plan = $0.plans.first else { return }
            insertPlan(plan.copy(id: UUID()))
            removeProject($0)
        })
    }

    func didTapGenerateMoreButton() {
        if isPro {
            isDifficultyDialogPresented = true
        } else {
            isPaywallPresented = true
        }
    }

    func didTapDifficultyDialogButton(_ difficulty: Project.Plan.Difficulty) {
        router.route(to: .generationLoader(project.brief.copy(id: UUID()), difficulty: difficulty) { [weak self] in
            guard let self, let plan = $0.plans.first else { return }
            insertPlan(plan.copy(id: UUID()))
            removeProject($0)
        })
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

    private func insertPlan(_ plan: Project.Plan) {
        project.plans.insert(plan, at: .zero)
        project.updatedAt = .now
        saveProject(project)
    }

    private func saveProject(_ project: Project) {
        Task { @MainActor in
            do {
                try dataStorage.saveProject(project)
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func removeProject(_ project: Project) {
        Task { @MainActor in
            do {
                try dataStorage.deleteProject(project)
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}
