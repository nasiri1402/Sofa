//
//  ChatRouter.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation
import SwiftUI

final class ChatRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator
    private let project: Project
    private let plan: Project.Plan
    private let step: Project.Plan.Step?

    // MARK: - Inits

    init(
        navigator: Navigator,
        project: Project,
        plan: Project.Plan,
        step: Project.Plan.Step?
    ) {
        self.navigator = navigator
        self.project = project
        self.plan = plan
        self.step = step
    }

    // MARK: - Public Methods

    func back() {
        navigator.pop()
    }
}

// MARK: - ViewFactory

extension ChatRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = ChatViewModel(
            router: self,
            dataStorage: ServiceLayer.dataStorage,
            chatter: ServiceLayer.chatter,
            project: project,
            plan: plan,
            step: step
        )
        let view = ChatView(viewModel: viewModel)
        return AnyView(view)
    }
}
