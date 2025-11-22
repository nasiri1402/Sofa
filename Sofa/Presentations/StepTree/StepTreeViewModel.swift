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
    var isWellDone = false

    // MARK: - Private Properties

    private let router: StepTreeRouter
    private let dataStorage: DataStorage

    private var project: Project

    // MARK: - Inits

    init(
        router: StepTreeRouter,
        dataStorage: DataStorage,
        project: Project,
        plan: Project.Plan
    ) {
        self.router = router
        self.dataStorage = dataStorage
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
        selectedWeek = week
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
        selectedWeek = plan.weeks.first { !$0.isCompleted } ?? plan.weeks.last
    }

    private func saveProject() {
        Task { @MainActor in
            do {
                let updatedProject = project
                updatedProject.updatedAt = .now
                try dataStorage.saveProject(updatedProject)
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}
