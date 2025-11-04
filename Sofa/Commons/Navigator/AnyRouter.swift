//
//  AnyRouter.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import SwiftUI

// MARK: - ViewFactory

protocol ViewFactory {
    @MainActor
    func makeView() -> AnyView
}

// MARK: - AnyRouter

struct AnyRouter {

    // MARK: - Private Properties

    private let router: any Routable

    private let onEquals: (any Routable) -> Bool

    // MARK: - Inits

    init<T: Routable>(_ router: T) {
        self.router = router
        onEquals = {
            guard let otherRouter = $0 as? T else { return false }
            return router == otherRouter
        }
    }
}

// MARK: - Routable

typealias Routable = ViewFactory & Hashable

extension AnyRouter: Routable {
    func makeView() -> AnyView {
        router.makeView()
    }

    func hash(into hasher: inout Hasher) {
        router.hash(into: &hasher)
    }

    static func == (lhs: AnyRouter, rhs: AnyRouter) -> Bool {
        lhs.onEquals(rhs.router)
    }
}
