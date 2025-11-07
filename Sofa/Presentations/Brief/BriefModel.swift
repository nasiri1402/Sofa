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
        case idea, timeframe, experience, startPoint, result, budget, limits

        var number: Int {
            rawValue + 1
        }

        func actionTitle() -> String {
            switch self {
            case .idea, .timeframe, .experience, .startPoint, .result, .budget: String(localized: "continue")
            case .limits: String(localized: "startGeneration")
            }
        }

        func next() -> Stage? {
            switch self {
            case .idea: .timeframe
            case .timeframe: .experience
            case .experience: .startPoint
            case .startPoint: .result
            case .result: .budget
            case .budget: .limits
            case .limits: nil
            }
        }

        func previous() -> Stage? {
            switch self {
            case .idea: nil
            case .timeframe: .idea
            case .experience: .timeframe
            case .startPoint: .experience
            case .result: .startPoint
            case .budget: .result
            case .limits: .budget
            }
        }
    }
}
