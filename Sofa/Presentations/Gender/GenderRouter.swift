//
//  GenderRouter.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

final class GenderRouter: HashableRouter {

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

extension GenderRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = GenderViewModel(router: self, dataStorage: ServiceLayer.dataStorage)
        let view = GenderView(viewModel: viewModel)
        return AnyView(view)
    }
}
