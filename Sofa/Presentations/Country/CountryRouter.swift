//
//  CountryRouter.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

final class CountryRouter: HashableRouter {

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

extension CountryRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = CountryViewModel(router: self, dataStorage: ServiceLayer.dataStorage)
        let view = CountryView(viewModel: viewModel)
        return AnyView(view)
    }
}
