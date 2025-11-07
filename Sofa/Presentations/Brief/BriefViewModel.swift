//
//  BriefViewModel.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class BriefViewModel {

    // MARK: - Public Properties

    private(set) var currentStage: BriefModel.Stage = .idea
    var isPreviousEnabled = false
    var isNextEnabled = false
    private(set) var progress: Double = .zero
    var alertItem: AlertItem?

    var idea = ""

    var timeframe: Project.Brief.Timeframe?

    var experience: Project.Brief.Experience?

    var startPoint = ""

    var goals: Set<Project.Brief.Goal> = []
    var goalMoneyText = ""
    var goalSubscribersText = ""
    var goalOptionText = ""

    var hasBudget: Bool?
    var budgetText = ""

    var limitsText = ""

    // MARK: - Private Properties

    private let isFirstBrief: Bool
    private let onFinish: () -> Void

    private var revealedStages: Set<BriefModel.Stage> = []

    // MARK: - Inits

    init(isFirstBrief: Bool, onFinish: @escaping () -> Void) {
        self.isFirstBrief = isFirstBrief
        self.isPreviousEnabled = !isFirstBrief
        self.onFinish = onFinish

        updateProgress()
    }
}

// MARK: - Public Properties

extension BriefViewModel {

    // MARK: - Input

    func didTapBackButton() {
        switch currentStage {
        case .idea:
            if isFirstBrief {
                break
            } else {
                // TODO: Навигация на главную
                break
            }
        case .timeframe:
            timeframe = nil
            isPreviousEnabled = !isFirstBrief
            previousStage(.idea)
        case .experience:
            experience = nil
            previousStage(.timeframe)
        case .startPoint:
            startPoint.removeAll()
            previousStage(.experience)
        case .result:
            goals.removeAll()
            previousStage(.startPoint)
        case .resultMoney:
            goalMoneyText.removeAll()
            previousStage(.result)
        case .resultSubscribers:
            goalSubscribersText.removeAll()
            if goals.contains(.money) {
                previousStage(.resultMoney)
            } else {
                previousStage(.result)
            }
        case .resultOption:
            goalOptionText.removeAll()
            previousStage(.result)
        case .hasBudget:
            switch true {
            case goals.contains(.subscribers): previousStage(.resultSubscribers)
            case goals.contains(.money): previousStage(.resultMoney)
            case goals.contains(.option): previousStage(.resultOption)
            default: nextStage(.result)
            }
        case .budget:
            budgetText.removeAll()
            previousStage(.hasBudget)
        case .limits:
            limitsText.removeAll()
            if hasBudget == true {
                previousStage(.budget)
            } else {
                previousStage(.hasBudget)
            }
        }
    }

    func didTapContinueButton() {
        switch currentStage {
        case .idea:
            idea = idea.trimmingCharacters(in: .whitespacesAndNewlines)
            nextStage(.timeframe)
        case .timeframe:
            nextStage(.experience)
        case .experience:
            nextStage(.startPoint)
        case .startPoint:
            startPoint = startPoint.trimmingCharacters(in: .whitespacesAndNewlines)
            nextStage(.result)
        case .result:
            switch true {
            case goals.contains(.money): nextStage(.resultMoney)
            case goals.contains(.subscribers): nextStage(.resultSubscribers)
            case goals.contains(.option): nextStage(.resultOption)
            default: nextStage(.hasBudget)
            }
        case .resultMoney:
            if goals.contains(.subscribers) {
                nextStage(.resultSubscribers)
            } else {
                nextStage(.hasBudget)
            }
        case .resultSubscribers:
            nextStage(.hasBudget)
        case .resultOption:
            goalOptionText = goalOptionText.trimmingCharacters(in: .whitespacesAndNewlines)
            nextStage(.hasBudget)
        case .hasBudget:
            if hasBudget == true {
                nextStage(.budget)
            } else {
                nextStage(.limits)
            }
        case .budget:
            nextStage(.limits)
        case .limits:
            limitsText = limitsText.trimmingCharacters(in: .whitespacesAndNewlines)
            startGeneration()
        }
    }

    // MARK: - Output

    func needsReveal(for stage: BriefModel.Stage) -> Bool {
        isFirstBrief && !revealedStages.contains(stage)
    }
}

// MARK: - Private Methods

extension BriefViewModel {
    private func nextStage(_ stage: BriefModel.Stage) {
        isPreviousEnabled = false
        isNextEnabled = false
        revealedStages.insert(currentStage)
        currentStage = stage
        updateProgress()
    }

    private func previousStage(_ stage: BriefModel.Stage) {
        isNextEnabled = true
        revealedStages.remove(currentStage)
        currentStage = stage
        updateProgress()
    }
    
    private func updateProgress() {
        let allCases = BriefModel.Stage.allCases.filter(\.isProgressable)
        progress = max(0, min(1, Double(currentStage.number) / Double(allCases.count)))
    }

    private func startGeneration() {
        // TODO: Начинать генерацию
    }
}
