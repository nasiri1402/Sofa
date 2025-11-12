//
//  GenerationResultRouter.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation
import SwiftUI

enum GenerationResultRoute {
    case stepTree(Project, Project.Plan)
    case generationLoader(Project.Brief, onGenerate: (Project) -> Void)
}

final class GenerationResultRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator
    private let project: Project

    // MARK: - Inits

    init(navigator: Navigator, project: Project) {
        self.navigator = navigator
        self.project = project
    }

    // MARK: - Public Methods

    func route(to route: GenerationResultRoute) {
        let router: any Routable = switch route {
        case .stepTree(let project, let plan):
            StepTreeRouter(navigator: navigator, project: project, plan: plan)
        case .generationLoader(let brief, let onGenerate):
            GenerationLoaderRouter(navigator: navigator, brief: brief, onGenerate: onGenerate)
        }
        navigator.push(router)
    }

    func back() {
        navigator.pop()
    }
}

// MARK: - ViewFactory

extension GenerationResultRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = GenerationResultViewModel(
            router: self,
            dataStorage: ServiceLayer.dataStorage,
            storeManager: ServiceLayer.storeManager,
            project: project
        )
        let view = GenerationResultView(viewModel: viewModel)
        return AnyView(view)
    }
}
