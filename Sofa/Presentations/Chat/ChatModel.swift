//
//  ChatModel.swift
//  Sofa
//
//  Created by dukes on 6/1/26.
//

import Foundation

enum ChatModel {

    // MARK: - SendingState

    enum SendingState: Equatable {
        case initializingChat, analyzingPlan, thinking

        var title: String {
            switch self {
            case .initializingChat: String(localized: "initializingChat")
            case .analyzingPlan: String(localized: "analyzingPlan")
            case .thinking: String(localized: "thinking")
            }
        }
    }
}
