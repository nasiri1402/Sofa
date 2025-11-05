//
//  GenerationResultRouter.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation
import SwiftUI

enum GenerationResultRoute {
    case stepTree
}

final class GenerationResultRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator
    private let project: Project

    // MARK: - Inits

    init(navigator: Navigator, project: Project) {
        self.navigator = navigator
        self.project = project
    }

    // MARK: - Public Methods

    func route(to route: GenerationResultRoute) {
        
    }

    func back() {
        navigator.pop()
    }
}

// MARK: - ViewFactory

extension GenerationResultRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = GenerationResultViewModel(
            router: self,
            dataStorage: ServiceLayer.dataStorage,
            storeManager: ServiceLayer.storeManager,
            project: project
        )
        let view = GenerationResultView(viewModel: viewModel)
        return AnyView(view)
    }
}
