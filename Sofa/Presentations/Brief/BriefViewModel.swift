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
    var goalMoney = ""
    var goalSubscribers = ""
    var goalOption = ""

    var hasBudget: Bool?
    var budget = ""

    var limits = ""

    // MARK: - Private Properties

    private let router: BriefRouter?
    private let projectGenerator: ProjectGenerator
    private let initialBrief: Project.Brief?
    private let onGenerate: ((Project) -> Void)?

    @ObservationIgnored @AppStorage(SofaConstants.AppStorage.isBeforeLaunched)
    private var isBeforeLaunched = false
    private var revealedStages: Set<BriefModel.Stage> = []

    // MARK: - Inits

    init(
        router: BriefRouter?,
        projectGenerator: ProjectGenerator,
        brief: Project.Brief?,
        onGenerate: ((Project) -> Void)?
    ) {
        self.router = router
        self.projectGenerator = projectGenerator
        self.initialBrief = brief
        self.onGenerate = onGenerate
        self.isPreviousEnabled = isBeforeLaunched
        self.isNextEnabled = isBeforeLaunched

        if let brief {
            idea = brief.idea
            timeframe = brief.timeframe
            experience = brief.experience
            startPoint = brief.startPoint
            goals = brief.result.goals
            goalMoney = brief.result.money?.description ?? ""
            goalSubscribers = brief.result.subscribers?.description ?? ""
            goalOption = brief.result.option ?? ""
            hasBudget = brief.budget != nil
            budget = brief.budget?.description ?? ""
            limits = brief.limits
        }
    }
}

// MARK: - Public Properties

extension BriefViewModel {

    // MARK: - Input

    func didViewAppear() {
        updateProgress()
    }

    func didTapBackButton() {
        switch currentStage {
        case .idea: handleIdea(for: .previous)
        case .timeframe: handleTimeframe(for: .previous)
        case .experience: handleExperience(for: .previous)
        case .startPoint: handleStartPoint(for: .previous)
        case .result: handleResult(for: .previous)
        case .resultMoney: handleResultMoney(for: .previous)
        case .resultSubscribers: handleResultSubscribers(for: .previous)
        case .resultOption: handleResultOption(for: .previous)
        case .hasBudget: handleHasBudget(for: .previous)
        case .budget: handleBudget(for: .previous)
        case .limits: handleLimits(for: .previous)
        case .loader: break
        }
    }

    func didTapContinueButton() {
        switch currentStage {
        case .idea: handleIdea(for: .next)
        case .timeframe: handleTimeframe(for: .next)
        case .experience: handleExperience(for: .next)
        case .startPoint: handleStartPoint(for: .next)
        case .result: handleResult(for: .next)
        case .resultMoney: handleResultMoney(for: .next)
        case .resultSubscribers: handleResultSubscribers(for: .next)
        case .resultOption: handleResultOption(for: .next)
        case .hasBudget: handleHasBudget(for: .next)
        case .budget: handleBudget(for: .next)
        case .limits: handleLimits(for: .next)
        case .loader: break
        }
    }

    // MARK: - Output

    func needsReveal(for stage: BriefModel.Stage) -> Bool {
        !isBeforeLaunched && !revealedStages.contains(stage)
    }
}

// MARK: - Private Methods

extension BriefViewModel {
    private func handleIdea(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            let trimmedIdea = idea.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedIdea.isEmpty else { return }
            isNextEnabled = timeframe != nil
            nextStage(.timeframe)
            idea = trimmedIdea
        case .previous:
            router?.back()
        }
    }

    private func handleTimeframe(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            guard timeframe != nil else { return }
            isNextEnabled = experience != nil
            nextStage(.experience)
        case .previous:
            isPreviousEnabled = isBeforeLaunched
            previousStage(.idea)
            timeframe = nil
        }
    }

    private func handleExperience(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            guard experience != nil else { return }
            isNextEnabled = !startPoint.isEmpty
            nextStage(.startPoint)
        case .previous:
            previousStage(.timeframe)
            experience = nil
        }
    }

    private func handleStartPoint(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            let trimmedStartPoint = startPoint.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedStartPoint.isEmpty else { return }
            isNextEnabled = !goals.isEmpty
            nextStage(.result)
            startPoint = trimmedStartPoint
        case .previous:
            previousStage(.experience)
            startPoint.removeAll()
        }
    }

    private func handleResult(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            guard !goals.isEmpty else { return }
            switch true {
            case goals.contains(.money):
                isNextEnabled = !goalMoney.isEmpty
                nextStage(.resultMoney)
            case goals.contains(.subscribers):
                isNextEnabled = !goalSubscribers.isEmpty
                nextStage(.resultSubscribers)
            case goals.contains(.option):
                isNextEnabled = !goalOption.isEmpty
                nextStage(.resultOption)
            default:
                isNextEnabled = hasBudget != nil
                nextStage(.hasBudget)
            }
        case .previous:
            previousStage(.startPoint)
            goals.removeAll()
        }
    }

    private func handleResultMoney(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            guard Int(goalMoney) != nil else { return }
            if goals.contains(.subscribers) {
                isNextEnabled = !goalSubscribers.isEmpty
                nextStage(.resultSubscribers)
            } else {
                isNextEnabled = hasBudget != nil
                nextStage(.hasBudget)
            }
        case .previous:
            previousStage(.result)
            goalMoney.removeAll()
        }
    }

    private func handleResultSubscribers(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            guard Int(goalSubscribers) != nil else { return }
            isNextEnabled = hasBudget != nil
            nextStage(.hasBudget)
        case .previous:
            if goals.contains(.money) {
                previousStage(.resultMoney)
            } else {
                previousStage(.result)
            }
            goalSubscribers.removeAll()
        }
    }

    private func handleResultOption(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            let trimmedGoalOption = goalOption.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedGoalOption.isEmpty else { return }
            isNextEnabled = hasBudget != nil
            nextStage(.hasBudget)
            goalOption = trimmedGoalOption
        case .previous:
            previousStage(.result)
            goalOption.removeAll()
        }
    }

    private func handleHasBudget(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            guard let hasBudget else { return }
            if hasBudget {
                isNextEnabled = !budget.isEmpty
                nextStage(.budget)
            } else {
                isNextEnabled = !limits.isEmpty
                nextStage(.limits)
            }
        case .previous:
            switch true {
            case goals.contains(.subscribers): previousStage(.resultSubscribers)
            case goals.contains(.money): previousStage(.resultMoney)
            case goals.contains(.option): previousStage(.resultOption)
            default: previousStage(.result)
            }
            hasBudget = nil
        }
    }

    private func handleBudget(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            guard Int(budget) != nil else { return }
            isNextEnabled = !limits.isEmpty
            nextStage(.limits)
        case .previous:
            previousStage(.hasBudget)
            budget.removeAll()
        }
    }

    private func handleLimits(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            let trimmedLimits = limits.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLimits.isEmpty else { return }
            limits = trimmedLimits
            isNextEnabled = false
            nextStage(.loader)
            startGeneration()
        case .previous:
            if hasBudget == true {
                previousStage(.budget)
            } else {
                previousStage(.hasBudget)
            }
            limits.removeAll()
        }
    }

    private func nextStage(_ stage: BriefModel.Stage) {
        isPreviousEnabled = isBeforeLaunched
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
        guard let timeframe, let experience else { return }
        let brief = Project.Brief(
            id: UUID(),
            idea: idea,
            timeframe: timeframe,
            experience: experience,
            startPoint: startPoint,
            result: Project.Brief.Result(
                goals: goals,
                money: Int(goalMoney),
                subscribers: Int(goalSubscribers),
                option: goalOption
            ),
            budget: Int(budget),
            limits: limits
        )
        Task { @MainActor in
            do {
                let project = try await projectGenerator.generate(brief: brief)
                onGenerate?(project)
                router?.back()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}
