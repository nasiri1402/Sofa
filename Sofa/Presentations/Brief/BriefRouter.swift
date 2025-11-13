//
//  BriefRouter.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import SwiftUI

final class BriefRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator
    private let brief: Project.Brief?
    private let onGenerate: (Project) -> Void

    // MARK: - Inits

    init(navigator: Navigator, brief: Project.Brief?, onGenerate: @escaping (Project) -> Void) {
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

extension BriefRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = BriefViewModel(
            router: self,
            projectGenerator: ServiceLayer.projectGenerator,
            brief: brief,
            onGenerate: onGenerate
        )
        let view = BriefView(viewModel: viewModel)
        return AnyView(view)
    }
}
