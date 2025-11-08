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
            isPreviousEnabled = !isFirstBrief
            previousStage(.idea)
            timeframe = nil
        case .experience:
            previousStage(.timeframe)
            experience = nil
        case .startPoint:
            previousStage(.experience)
            startPoint.removeAll()
        case .result:
            previousStage(.startPoint)
            goals.removeAll()
        case .resultMoney:
            previousStage(.result)
            goalMoneyText.removeAll()
        case .resultSubscribers:
            if goals.contains(.money) {
                previousStage(.resultMoney)
            } else {
                previousStage(.result)
            }
            goalSubscribersText.removeAll()
        case .resultOption:
            previousStage(.result)
            goalOptionText.removeAll()
        case .hasBudget:
            switch true {
            case goals.contains(.subscribers): previousStage(.resultSubscribers)
            case goals.contains(.money): previousStage(.resultMoney)
            case goals.contains(.option): previousStage(.resultOption)
            default: nextStage(.result)
            }
            hasBudget = nil
        case .budget:
            previousStage(.hasBudget)
            budgetText.removeAll()
        case .limits:
            if hasBudget == true {
                previousStage(.budget)
            } else {
                previousStage(.hasBudget)
            }
            limitsText.removeAll()
        }
    }

    func didTapContinueButton() {
        switch currentStage {
        case .idea:
            let trimmedIdea = idea.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedIdea.isEmpty else { return }
            nextStage(.timeframe)
            idea = trimmedIdea
        case .timeframe:
            guard timeframe != nil else { return }
            nextStage(.experience)
        case .experience:
            guard experience != nil else { return }
            nextStage(.startPoint)
        case .startPoint:
            let trimmedStartPoint = startPoint.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedStartPoint.isEmpty else { return }
            nextStage(.result)
            startPoint = trimmedStartPoint
        case .result:
            guard !goals.isEmpty else { return }
            switch true {
            case goals.contains(.money): nextStage(.resultMoney)
            case goals.contains(.subscribers): nextStage(.resultSubscribers)
            case goals.contains(.option): nextStage(.resultOption)
            default: nextStage(.hasBudget)
            }
        case .resultMoney:
            guard Int(goalMoneyText) != nil else { return }
            if goals.contains(.subscribers) {
                nextStage(.resultSubscribers)
            } else {
                nextStage(.hasBudget)
            }
        case .resultSubscribers:
            guard Int(goalSubscribersText) != nil else { return }
            nextStage(.hasBudget)
        case .resultOption:
            let trimmedGoalOption = goalOptionText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedGoalOption.isEmpty else { return }
            nextStage(.hasBudget)
            goalOptionText = trimmedGoalOption
        case .hasBudget:
            guard let hasBudget else { return }
            if hasBudget {
                nextStage(.budget)
            } else {
                nextStage(.limits)
            }
        case .budget:
            let trimmedBudget = budgetText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedBudget.isEmpty else { return }
            nextStage(.limits)
            budgetText = trimmedBudget
        case .limits:
            let trimmedLimits = limitsText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLimits.isEmpty else { return }
            limitsText = trimmedLimits
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
