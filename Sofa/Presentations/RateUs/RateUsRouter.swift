//
//  RateUsRouter.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

final class RateUsRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator

    // MARK: - Inits

    init(navigator: Navigator) {
        self.navigator = navigator
    }

    // MARK: - Public Methods

    func back() {
        navigator.pop()
    }
}

// MARK: - ViewFactory

extension RateUsRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = RateUsViewModel(router: self)
        let view = RateUsView(viewModel: viewModel)
        return AnyView(view)
    }
}
