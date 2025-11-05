//
//  InProcessViewModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class InProcessViewModel {

    // MARK: - Public Properties

    private(set) var plans: [Project.Plan] = []
    let segments = InProcessModel.Segment.allCases
    var selectedSegment: InProcessModel.Segment = .inWork {
        didSet {
            guard oldValue != selectedSegment else { return }
            filterPlans()
        }
    }
    private(set) var emptyState: InProcessModel.EmptyState?
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let dataStorage: DataStorage

    private var projects: [Project] = []

    // MARK: - Inits

    init(dataStorage: DataStorage) {
        self.dataStorage = dataStorage

        initialize()
    }
}

// MARK: - Public Properties

extension InProcessViewModel {

    // MARK: - Input

    func didTapPlanButton(_ plan: Project.Plan) {
        // TODO: Навигация к плану/проекту
    }
}

// MARK: - Private Methods

extension InProcessViewModel {
    private func initialize() {
        fetchProjects()
    }

    private func fetchProjects() {
        Task { @MainActor in
            do {
                projects = try dataStorage.fetchProjects()
                // TODO: Убрать моковый проект
//                projects = [.mock]
                filterPlans()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func filterPlans() {
        plans = projects.flatMap(\.plans).filter {
            switch selectedSegment {
            case .inWork: !$0.isCompleted
            case .completed: $0.isCompleted
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
            }
        }
    }
}
