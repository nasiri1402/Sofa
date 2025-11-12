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
        case idea, timeframe, experience, startPoint
        case result, resultMoney, resultSubscribers, resultOption
        case hasBudget, budget, limits, loader

        var number: Int {
            switch self {
            case .idea: 1
            case .timeframe: 2
            case .experience: 3
            case .startPoint: 4
            case .result, .resultMoney, .resultSubscribers, .resultOption: 5
            case .hasBudget, .budget: 6
            case .limits: 7
            case .loader: 8
            }
        }

        var isProgressable: Bool {
            switch self {
            case .resultMoney, .resultSubscribers, .resultOption, .budget, .loader: false
            default: true
            }
        }

        func actionTitle() -> String {
            switch self {
            case .idea, .timeframe, .experience, .startPoint, .hasBudget, .budget: String(localized: "continue")
            case .result, .resultMoney, .resultSubscribers, .resultOption, .loader: String(localized: "continue")
            case .limits: String(localized: "startGeneration")
            }
        }
    }

    // MARK: - Direction

    enum Direction {
        case next, previous
    }
}
