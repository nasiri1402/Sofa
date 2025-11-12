//
//  GenerationLoaderModel.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import Foundation

enum GenerationLoaderModel {

    // MARK: - Message

    enum Message: CaseIterable {
        case analyzing, selecting, preparing, gathering, building
        case optimizing, refining, validating, thinking, learning
        case connecting, understanding

        var description: String {
            switch self {
            case .analyzing: String(localized: "analyzingYourGoal")
            case .selecting: String(localized: "selectingScenarios")
            case .preparing: String(localized: "preparingAnActionPlan")
            case .gathering: String(localized: "gatheringInsights")
            case .building: String(localized: "buildingYourStrategy")
            case .optimizing: String(localized: "optimizingResults")
            case .refining: String(localized: "refiningSuggestions")
            case .validating: String(localized: "validatingData")
            case .thinking: String(localized: "thinkingAhead")
            case .learning: String(localized: "learningFromPattern")
            case .connecting: String(localized: "connectingTheDots")
            case .understanding: String(localized: "understandingYourIntent")
            }
        }
    }
}
