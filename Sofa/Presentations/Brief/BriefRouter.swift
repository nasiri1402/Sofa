//
//  BriefRouter.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import SwiftUI

enum BriefRoute {
    case generationLoader(Project.Brief, difficulty: Project.Plan.Difficulty, onGenerate: (Project) -> Void)
}

final class BriefRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator
    private let brief: Project.Brief?
    private let onGenerate: ((Project) -> Void)?

    // MARK: - Inits

    init(navigator: Navigator, brief: Project.Brief?, onGenerate: ((Project) -> Void)?) {
        self.navigator = navigator
        self.brief = brief
        self.onGenerate = onGenerate
    }

    // MARK: - Public Methods

    func route(to route: BriefRoute) {
        let router: any Routable = switch route {
        case .generationLoader(let brief, let difficulty, let onGenerate):
            GenerationLoaderRouter(
                navigator: navigator,
                brief: brief,
                difficulty: difficulty,
                onGenerate: onGenerate
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
            brief: brief,
            onGenerate: onGenerate
        )
        let view = BriefView(viewModel: viewModel)
        return AnyView(view)
    }
}
