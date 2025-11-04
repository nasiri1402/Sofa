//
//  NameRouter.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

final class NameRouter: HashableRouter {

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

extension NameRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = NameViewModel(router: self, dataStorage: ServiceLayer.dataStorage)
        let view = NameView(viewModel: viewModel)
        return AnyView(view)
    }
}
