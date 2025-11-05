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

    private(set) var displayProjects: [Project] = []
    let segments = InProcessModel.Segment.allCases
    var selectedSegment: InProcessModel.Segment = .inWork {
        didSet {
            guard oldValue != selectedSegment else { return }
            filterProjects()
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
                filterProjects()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func filterProjects() {
        displayProjects = projects.filter {
            switch selectedSegment {
            case .inWork: !$0.isCompleted
            case .completed: $0.isCompleted
            }
        }
        checkEmptyState()
    }

    private func checkEmptyState() {
        guard displayProjects.isEmpty else { return }
        emptyState = switch selectedSegment {
        case .inWork: .inWork
        case .completed: .completed
        }
    }
}
