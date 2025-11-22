//
//  BriefRouter.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import SwiftUI

enum BriefRoute {
    case generationLoader(Project.Brief, difficulty: Project.Plan.Difficulty)
}

final class BriefRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator
    private let project: Project?
    private let brief: Project.Brief?

    // MARK: - Inits

    init(navigator: Navigator, project: Project?, brief: Project.Brief?) {
        self.navigator = navigator
        self.project = project
        self.brief = brief
    }

    // MARK: - Public Methods

    func route(to route: BriefRoute) {
        let router: any Routable = switch route {
        case .generationLoader(let brief, let difficulty):
            GenerationLoaderRouter(
                navigator: navigator,
                project: project,
                brief: brief,
                difficulty: difficulty
            )
        }
        navigator.push(router)
    }

    func back() {
        navigator.pop()
    }
}

// MARK: - ViewFactory

extension BriefRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = BriefViewModel(
            router: self,
            projectGenerator: ServiceLayer.projectGenerator,
            brief: brief
        )
        let view = BriefView(viewModel: viewModel)
        return AnyView(view)
    }
}
