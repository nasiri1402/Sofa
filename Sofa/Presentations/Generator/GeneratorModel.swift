//
//  GeneratorModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

enum GeneratorModel {

    // MARK: - Story

    enum Story: String, Identifiable, Hashable, CaseIterable {
        case green, orange, red

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .green: String(localized: "storyGreenPage1Title")
            case .orange: String(localized: "storyOrangePage1Title")
            case .red: String(localized: "storyRedPage1Title")
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
