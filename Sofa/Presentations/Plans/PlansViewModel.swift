//
//  PlansViewModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class PlansViewModel {

    // MARK: - Public Properties

    private(set) var plans: [Project.Plan] = []
    let segments = PlansModel.Segment.allCases
    var selectedSegment: PlansModel.Segment = .inWork {
        didSet {
            guard oldValue != selectedSegment else { return }
            filterPlans()
        }
    }
    private(set) var emptyState: PlansModel.EmptyState?
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let router: PlansRouter
    private let dataStorage: DataStorage

    private var projects: [Project] = []

    // MARK: - Inits

    init(router: PlansRouter, dataStorage: DataStorage) {
        self.router = router
        self.dataStorage = dataStorage
    }
}

// MARK: - Public Properties

extension PlansViewModel {

    // MARK: - Input

    func didViewAppear() {
        fetchProjects()
    }

    func didTapPlanButton(_ plan: Project.Plan) {
        guard let project = findProject(for: plan) else { return }
        router.route(to: .stepTree(project, plan))
    }
}

// MARK: - Private Methods

extension PlansViewModel {
    private func fetchProjects() {
        Task { @MainActor in
            do {
                projects = try dataStorage.fetchProjects()
                filterPlans()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func findProject(for plan: Project.Plan) -> Project? {
        projects.first { $0.plans.contains { $0.id == plan.id } }
    }

    private func filterPlans() {
        plans = projects.flatMap(\.plans).filter {
            switch selectedSegment {
            case .inWork: !$0.isCompleted && $0.progress > .zero
            case .completed: $0.isCompleted
            case .favorites: $0.isFavorite
            }
        }
        checkEmptyState()
    }

    private func checkEmptyState() {
        guard plans.isEmpty else {
            emptyState = nil
            return
        }
        withAnimation {
            emptyState = switch selectedSegment {
            case .inWork: .inWork
            case .completed: .completed
            case .favorites: .favorites
            }
        }
    }
}
