//
//  GenerationLoaderViewModel.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class GenerationLoaderViewModel {

    // MARK: - Public Properties

    private(set) var message: GenerationLoaderModel.Message = .analyzing
    private(set) var feedbackTrigger = UUID()
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let router: GenerationLoaderRouter
    private let networkMonitor: NetworkMonitor
    private let projectGenerator: ProjectGenerator
    private let dataStorage: DataStorage
    private let project: Project?
    private let brief: Project.Brief
    private let difficulty: Project.Plan.Difficulty

    private var messagePool = GenerationLoaderModel.Message.allCases

    @ObservationIgnored @AppStorage(SofaConstants.AppStorage.isBeforeLaunched)
    private var isBeforeLaunched = false

    // MARK: - Inits

    init(
        router: GenerationLoaderRouter,
        networkMonitor: NetworkMonitor,
        projectGenerator: ProjectGenerator,
        dataStorage: DataStorage,
        project: Project?,
        brief: Project.Brief,
        difficulty: Project.Plan.Difficulty,
    ) {
        self.router = router
        self.networkMonitor = networkMonitor
        self.projectGenerator = projectGenerator
        self.dataStorage = dataStorage
        self.project = project
        self.brief = brief
        self.difficulty = difficulty

        generateProject()
    }
}

// MARK: - Public Methods

extension GenerationLoaderViewModel {

    // MARK: - Input

    func didFinishReveal() {
        // Если пул пуст, то восстанавливаем все варианты
        if messagePool.isEmpty {
            messagePool = GenerationLoaderModel.Message.allCases
        }
        // Исключаем текущее сообщение, чтобы не повторялось подряд
        guard let newMessage = messagePool.filter({ $0 != message }).randomElement() else { return }
        message = newMessage
        messagePool.removeAll { $0 == newMessage }
    }
}

// MARK: - Private Methods

extension GenerationLoaderViewModel {
    private func generateProject() {
        guard networkMonitor.isConnected else {
            alertItem = .noInternetConnection(
                onOK: { [weak self] in
                    guard let self else { return }
                    router.back()
                },
                onRetry: { [weak self] in
                    guard let self else { return }
                    generateProject()
                }
            )
            return
        }
        Task { @MainActor in
            do {
                var generatedProject = try await projectGenerator.generate(brief: brief, difficulty: difficulty)
                if project == nil, !isBeforeLaunched {
                    generatedProject.hasLifetimeAccess = true
                    isBeforeLaunched = true
                }
                let resultProject = try mergePlansIfNeeded(with: generatedProject)
                feedbackTrigger = UUID()
                router.route(to: .generationResult(resultProject))
            } catch {
                alertItem = .error(message: error.localizedDescription) { [weak self] in
                    guard let self else { return }
                    router.back()
                }
            }
        }
    }

    private func mergePlansIfNeeded(with generatedProject: Project) throws -> Project {
        guard var existingProject = project else {
            try dataStorage.saveProject(generatedProject)
            return generatedProject
        }
        // Если есть старый проект с которым пришли на новую генерацию, то добавляем новый план
        if let newPlan = generatedProject.plans.first {
            existingProject.plans.append(newPlan.copy(id: UUID()))
            existingProject.updatedAt = .now
            try dataStorage.saveProject(existingProject)
        }
        return existingProject
    }
}
