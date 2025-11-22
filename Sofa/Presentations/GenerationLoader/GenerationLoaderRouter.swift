//
//  GenerationLoaderRouter.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import SwiftUI

enum GenerationLoaderRoute {
    case generationResult(Project)
}

final class GenerationLoaderRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator
    private let project: Project?
    private let brief: Project.Brief
    private let difficulty: Project.Plan.Difficulty

    // MARK: - Inits

    init(
        navigator: Navigator,
        project: Project?,
        brief: Project.Brief,
        difficulty: Project.Plan.Difficulty
    ) {
        self.navigator = navigator
        self.project = project
        self.brief = brief
        self.difficulty = difficulty
    }

    // MARK: - Public Methods

    func route(to route: GenerationLoaderRoute) {
        let router: any Routable = switch route {
        case .generationResult(let project):
            GenerationResultRouter(navigator: navigator, project: project)
        }
        navigator.push(router)
    }

    func back() {
        navigator.pop()
    }
}

// MARK: - ViewFactory

extension GenerationLoaderRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = GenerationLoaderViewModel(
            router: self,
            networkMonitor: ServiceLayer.networkMonitor,
            projectGenerator: ServiceLayer.projectGenerator,
            dataStorage: ServiceLayer.dataStorage,
            project: project,
            brief: brief,
            difficulty: difficulty
        )
        let view = GenerationLoaderView(viewModel: viewModel)
        return AnyView(view)
    }
}
