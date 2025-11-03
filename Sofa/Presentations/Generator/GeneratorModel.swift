//
//  GeneratorModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

enum GeneratorModel {

    // MARK: - Story

    enum Story: Hashable, CaseIterable {
        case green, orange, red

        var title: String {
            switch self {
            case .green: String(localized: "storyGreenTitle")
            case .orange: String(localized: "storyOrangeTitle")
            case .red: String(localized: "storyRedTitle")
            }
        }

        var emoji: String {
            switch self {
            case .green: "💡"
            case .orange: "❓"
            case .red: "✖️"
            }
        }

        var color: Color {
            switch self {
            case .green: .green34C759
            case .orange: .orangeFF9500
            case .red: .redFF3B30
            }
        }
    }
}
