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
    var isPaywallPresented = false

    var isPro: Bool {
        storeManager.hasPurchasedProduct()
    }

    // MARK: - Private Properties

    private let router: GeneratorRouter
    private let storeManager: StoreManager
    private let dataStorage: DataStorage

    @ObservationIgnored @AppStorage(SofaConstants.AppStorage.isBeforeLaunched)
    private var isBeforeLaunched = false

    // MARK: - Inits

    init(
        router: GeneratorRouter,
        storeManager: StoreManager,
        dataStorage: DataStorage
    ) {
        self.router = router
        self.storeManager = storeManager
        self.dataStorage = dataStorage
    }
}

// MARK: - Public Properties

extension GeneratorViewModel {

    // MARK: - Input

    func didViewAppear() {
        fetchProjects()

        guard !isBeforeLaunched else { return }
        router.route(to: .brief)
    }

    func didTapStoryButton(_ story: GeneratorModel.Story) {
        guard selectedStory != story else { return }
        selectedStory = story
    }

    func didTapProjectButton(_ project: Project) {
        router.route(to: .generationResult(project))
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
        if isPro {
            router.route(to: .brief)
        } else {
            isPaywallPresented = true
        }
    }
}

// MARK: - Private Methods

extension GeneratorViewModel {
    private func fetchProjects() {
        Task { @MainActor in
            do {
                projects = try dataStorage.fetchProjects()
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
