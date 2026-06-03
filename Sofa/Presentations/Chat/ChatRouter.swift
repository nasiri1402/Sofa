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
    private let onTapContext: (String) -> Void

    // MARK: - Inits

    init(
        navigator: Navigator,
        project: Project,
        plan: Project.Plan,
        step: Project.Plan.Step?,
        onTapContext: @escaping (String) -> Void
    ) {
        self.navigator = navigator
        self.project = project
        self.plan = plan
        self.step = step
        self.onTapContext = onTapContext
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
            networkMonitor: ServiceLayer.networkMonitor,
            chatter: ServiceLayer.chatter,
            clipboard: ServiceLayer.clipboard,
            project: project,
            plan: plan,
            step: step,
            onTapContext: onTapContext
        )
        let view = ChatView(viewModel: viewModel)
        return AnyView(view)
    }
}
