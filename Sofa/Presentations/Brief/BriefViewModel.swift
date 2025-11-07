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

    var result: Project.Brief.Result?
    var goals: Set<Project.Brief.Goal> = []
    var goalMoneyText = ""
    var goalSubscribersText = ""
    var goalOptionText = ""
    private(set) var isGoalMoneyHidden = false
    private(set) var isGoalSubscribersHidden = false
    private(set) var isGoalOptionHidden = false

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
        case .timeframe:
            timeframe = nil
            isPreviousEnabled = !isFirstBrief
            previousStage()
        case .experience:
            experience = nil
            previousStage()
        case .startPoint:
            startPoint.removeAll()
            previousStage()
        case .result:
            if !isGoalSubscribersHidden {
                isGoalSubscribersHidden = true
                isNextEnabled = true
                goalSubscribersText.removeAll()
            } else if !isGoalMoneyHidden {
                isGoalMoneyHidden = true
                isNextEnabled = true
                goalMoneyText.removeAll()
            } else if !isGoalOptionHidden {
                isGoalOptionHidden = true
                isNextEnabled = true
                goalOptionText.removeAll()
            } else {
                previousStage()
            }
        default: break
        }
    }

    func didTapContinueButton() {
        switch currentStage {
        case .idea:
            idea = idea.trimmingCharacters(in: .whitespacesAndNewlines)
            nextStage()
        case .timeframe, .experience:
            nextStage()
        case .startPoint:
            startPoint = startPoint.trimmingCharacters(in: .whitespacesAndNewlines)
            nextStage()
        case .result:
            if goals.contains(.money) {
                isGoalMoneyHidden = false
            } else if goals.contains(.subscribers) {
                isGoalSubscribersHidden = false
            } else if goals.contains(.option){
                isGoalOptionHidden = false
            } else {
                isGoalMoneyHidden = true
                isGoalSubscribersHidden = true
                isGoalOptionHidden = true
                nextStage()
            }
        default: break
        }
    }

    // MARK: - Output

    func needsReveal(for stage: BriefModel.Stage) -> Bool {
        isFirstBrief && !revealedStages.contains(stage)
    }
}

// MARK: - Private Methods

extension BriefViewModel {
    private func nextStage(_ stage: BriefModel.Stage? = nil) {
        isPreviousEnabled = false
        isNextEnabled = false
        revealedStages.insert(currentStage)
        currentStage = if let stage {
            stage
        } else {
            currentStage.next() ?? currentStage
        }
        updateProgress()
    }

    private func previousStage(_ stage: BriefModel.Stage? = nil) {
        isNextEnabled = true
        revealedStages.remove(currentStage)
        currentStage = if let stage {
            stage
        } else {
            currentStage.previous() ?? currentStage
        }
        updateProgress()
    }

    private func updateProgress() {
        progress = Double(currentStage.number) / Double(BriefModel.Stage.allCases.count)
    }
}
