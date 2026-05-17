//
//  StepTreeRouter.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation
import SwiftUI

enum StepTreeRoute {
    case chat(Project, Project.Plan, Project.Plan.Step?)
}

final class StepTreeRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator
    private let project: Project
    private let plan: Project.Plan

    // MARK: - Inits

    init(navigator: Navigator, project: Project, plan: Project.Plan) {
        self.navigator = navigator
        self.project = project
        self.plan = plan
    }

    // MARK: - Public Methods

    func route(to route: StepTreeRoute) {
        switch route {
        case .chat(let project, let plan, let step):
            let router = ChatRouter(
                navigator: navigator,
                project: project,
                plan: plan,
                step: step
            )
            navigator.push(router)
        }
    }

    func back() {
        navigator.pop()
    }
}

// MARK: - ViewFactory

extension StepTreeRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = StepTreeViewModel(
            router: self,
            dataStorage: ServiceLayer.dataStorage,
            storeManager: ServiceLayer.storeManager,
            project: project,
            plan: plan
        )
        let view = StepTreeView(viewModel: viewModel)
        return AnyView(view)
    }
}
