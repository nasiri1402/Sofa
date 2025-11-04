//
//  AgeRouter.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

final class AgeRouter: HashableRouter {

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

extension AgeRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = AgeViewModel(router: self, dataStorage: ServiceLayer.dataStorage)
        let view = AgeView(viewModel: viewModel)
        return AnyView(view)
    }
}
