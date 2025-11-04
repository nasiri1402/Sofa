//
//  SettingsRouter.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import Observation
import SwiftUI

enum SettingsRoute {
    case myData
}

@Observable
final class SettingsRouter: HashableRouter {

    // MARK: - Public Properties

    var path = NavigationPath()

    // MARK: - Public Methods

    func route(to route: SettingsRoute) {
        switch route {
        case .myData:
            let router = MyDataRouter(navigator: self)
            push(router)
        }
    }
}

// MARK: - Navigator

extension SettingsRouter: Navigator {
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
