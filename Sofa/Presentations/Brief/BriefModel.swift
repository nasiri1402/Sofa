//
//  BriefModel.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import Foundation

enum BriefModel {

    // MARK: - Stage

    enum Stage: Int, CaseIterable {
        case category
        case focus
        case target
        case currentState
        case preferences
        case timeframe

        var number: Int {
            switch self {
            case .category: 1
            case .focus: 2
            case .target: 3
            case .currentState: 4
            case .preferences: 5
            case .timeframe: 6
            }
        }

        func actionTitle() -> String {
            switch self {
            case .category, .focus, .target, .currentState, .preferences:
                String(localized: "continue")
            case .timeframe:
                String(localized: "startGeneration")
            }
        }
    }

    // MARK: - Direction

    enum Direction {
        case next, previous
    }
}
