//
//  GeneratorViewModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class GeneratorViewModel {

    // MARK: - Public Properties

    private(set) var projects: [Project] = []
    let stories = GeneratorModel.Story.allCases
    var selectedStory: GeneratorModel.Story?
    private(set) var deleteTrigger = UUID()
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let dataStorage: DataStorage

    // MARK: - Inits

    init(dataStorage: DataStorage) {
        self.dataStorage = dataStorage

        initialize()
    }
}

// MARK: - Public Properties

extension GeneratorViewModel {

    // MARK: - Input

    func didTapStoryButton(_ story: GeneratorModel.Story) {
        guard selectedStory != story else { return }
        selectedStory = story
    }

    func didTapProjectButton(_ project: Project) {
        // TODO: Навигация к проекту
    }

    func didTapDeleteProjectButton(_ project: Project) {
        alertItem = AlertItem(
            title: Text(String(localized: "deleteGeneration")),
            message: Text(String(localized: "deleteGenerationMessage")),
            primaryButton: .destructive(Text(String(localized: "delete"))) { [weak self] in
                guard let self else { return }
                deleteProject(project)
            },
            secondaryButton: .cancel(Text(String(localized: "cancel")))
        )
    }

    func didTapGenerateButton() {
        // TODO: Навигация к новой генерации
    }
}

// MARK: - Private Methods

extension GeneratorViewModel {
    private func initialize() {
        fetchProjects()
    }

    private func fetchProjects() {
        Task { @MainActor in
            do {
//                projects = try dataStorage.fetchProjects()
                // TODO: Убрать моковый проект
                projects = [.mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock]
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func deleteProject(_ project: Project) {
        Task { @MainActor in
            do {
                try dataStorage.deleteProject(project)
                deleteTrigger = UUID()
                withAnimation {
                    projects.removeAll { $0.id == project.id }
                }
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}
