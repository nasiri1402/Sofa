//
//  StepTreeViewModel.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class StepTreeViewModel {

    // MARK: - Public Properties

    private(set) var plan: Project.Plan
    var alertItem: AlertItem?
    var isPaywallPresented = false

    var isPro: Bool {
        storeManager.hasPurchasedProduct()
    }

    // MARK: - Private Properties

    private let router: StepTreeRouter
    private let dataStorage: DataStorage
    private let storeManager: StoreManager

    private var project: Project
    private var profile: Profile?

    // MARK: - Inits

    init(
        router: StepTreeRouter,
        dataStorage: DataStorage,
        storeManager: StoreManager,
        project: Project,
        plan: Project.Plan
    ) {
        self.router = router
        self.dataStorage = dataStorage
        self.storeManager = storeManager
        self.project = project
        self.plan = plan

        fetchProfile()
    }
}

// MARK: - Public Properties

extension StepTreeViewModel {

    // MARK: - Input

    func didTapNavigationBarLeadingButton() {
        router.back()
    }

    func didTapNavigationBarTrailingButton() {
        plan.isFavorite.toggle()
        if let index = project.plans.firstIndex(where: { $0.id == plan.id }) {
            project.plans[index].isFavorite = plan.isFavorite
        }
        saveProject()
    }
}

// MARK: - Private Methods

extension StepTreeViewModel {
    private func fetchProfile() {
        Task { @MainActor in
            do {
                profile = try dataStorage.fetchProfile()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func saveProject() {
        Task { @MainActor in
            do {
                try dataStorage.saveProject(project)
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}
