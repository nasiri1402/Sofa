//
//  PlansRouter.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation
import Observation
import SwiftUI

enum PlansRoute {
    case stepTree(Project, Project.Plan)
}

@Observable
final class PlansRouter: HashableRouter {

    // MARK: - Public Properties

    var path = NavigationPath()

    // MARK: - Public Methods

    func route(to route: PlansRoute) {
        switch route {
        case .stepTree(let project, let plan):
            let router = StepTreeRouter(navigator: self, project: project, plan: plan)
            push(router)
        }
    }
}

// MARK: - Navigator

extension PlansRouter: Navigator {
    func push(_ router: any Routable) {
        path.append(AnyRouter(router))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }
}
