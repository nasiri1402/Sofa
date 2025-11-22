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
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let router: GenerationLoaderRouter
    private let networkMonitor: NetworkMonitor
    private let projectGenerator: ProjectGenerator
    private let brief: Project.Brief
    private let difficulty: Project.Plan.Difficulty
    private let onGenerate: (Project) -> Void

    private var messagePool = GenerationLoaderModel.Message.allCases

    // MARK: - Inits

    init(
        router: GenerationLoaderRouter,
        networkMonitor: NetworkMonitor,
        projectGenerator: ProjectGenerator,
        brief: Project.Brief,
        difficulty: Project.Plan.Difficulty,
        onGenerate: @escaping (Project) -> Void
    ) {
        self.router = router
        self.networkMonitor = networkMonitor
        self.projectGenerator = projectGenerator
        self.brief = brief
        self.difficulty = difficulty
        self.onGenerate = onGenerate

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
            alertItem = AlertItem(
                title: Text(String(localized: "noInternetConnection")),
                message: Text(String(localized: "noInternetConnectionMessage")),
                primaryButton: .default(Text(String(localized: "ok"))) { [weak self] in
                    guard let self else { return }
                    router.back()
                },
                secondaryButton: .default(Text(String(localized: "retry"))) { [weak self] in
                    guard let self else { return }
                    generateProject()
                }
            )
            return
        }
        Task { @MainActor in
            do {
                let project = try await projectGenerator.generate(brief: brief, difficulty: difficulty)
                onGenerate(project)
                router.back()
            } catch {
                alertItem = .error(message: error.localizedDescription) { [weak self] in
                    guard let self else { return }
                    router.back()
                }
            }
        }
    }
}
