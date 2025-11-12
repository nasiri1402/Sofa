//
//  GenerationLoaderRouter.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import SwiftUI

final class GenerationLoaderRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator
    private let brief: Project.Brief
    private let onGenerate: (Project) -> Void

    // MARK: - Inits

    init(navigator: Navigator, brief: Project.Brief, onGenerate: @escaping (Project) -> Void) {
        self.navigator = navigator
        self.brief = brief
        self.onGenerate = onGenerate
    }

    // MARK: - Public Methods

    func back() {
        navigator.pop()
    }
}

// MARK: - ViewFactory

extension GenerationLoaderRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = GenerationLoaderViewModel(
            router: self,
            networkMonitor: ServiceLayer.networkMonitor,
            projectGenerator: ServiceLayer.projectGenerator,
            brief: brief,
            onGenerate: onGenerate
        )
        let view = GenerationLoaderView(viewModel: viewModel)
        return AnyView(view)
    }
}
