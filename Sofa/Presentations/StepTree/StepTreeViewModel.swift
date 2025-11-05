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
    private(set) var selectedWeek: Project.Plan.Week?
    var alertItem: AlertItem?
    var isPaywallPresented = false
    var isWellDone = false

    var isPro: Bool {
        storeManager.hasPurchasedProduct()
    }

    // MARK: - Private Properties

    private let router: StepTreeRouter
    private let dataStorage: DataStorage
    private let storeManager: StoreManager

    private var project: Project

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

        initialize()
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

    func didTapWeekButton(_ week: Project.Plan.Week) {
        guard selectedWeek?.id != week.id else { return }
        if week.number > 1, !isPro {
            isPaywallPresented = true
        } else {
            selectedWeek = week
        }
    }

    func didTapStepButton(_ step: Project.Plan.Step) {
        guard var week = selectedWeek else { return }
        if let stepIndex = week.steps.firstIndex(where: { $0.id == step.id }) {
            week.steps[stepIndex].isCompleted.toggle()
        }
        if let weekIndex = plan.weeks.firstIndex(where: { $0.id == week.id }) {
            plan.weeks[weekIndex] = week
        }
        if let planIndex = project.plans.firstIndex(where: { $0.id == plan.id }) {
            project.plans[planIndex] = plan
        }
        selectedWeek = week
        isWellDone = plan.isCompleted
        saveProject()
    }

    func didTapViewPlanButton() {
        isWellDone = false
    }
}

// MARK: - Private Methods

extension StepTreeViewModel {
    private func initialize() {
        isWellDone = plan.isCompleted
        selectedWeek = if isPro {
            plan.weeks.first { !$0.isCompleted } ?? plan.weeks.last
        } else {
            plan.weeks.first
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
