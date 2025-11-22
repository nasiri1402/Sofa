//
//  GeneratorRouter.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation
import Observation
import SwiftUI

enum GeneratorRoute {
    case generationResult(Project)
    case brief
}

@Observable
final class GeneratorRouter: HashableRouter {

    // MARK: - Public Properties

    var path = NavigationPath()

    // MARK: - Public Methods

    func route(to route: GeneratorRoute) {
        let router: any Routable = switch route {
        case .generationResult(let project):
            GenerationResultRouter(navigator: self, project: project)
        case .brief:
            BriefRouter(navigator: self, project: nil, brief: nil)
        }
        push(router)
    }
}

// MARK: - Navigator

extension GeneratorRouter: Navigator {
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
