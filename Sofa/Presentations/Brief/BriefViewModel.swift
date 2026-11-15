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

    private(set) var currentStage: BriefModel.Stage = .category
    var isPreviousEnabled = false
    var isNextEnabled = false
    private(set) var progress: Double = .zero
    var alertItem: AlertItem?

    var category: Project.Brief.Category?
    var focus = ""
    var target = ""
    var currentState = ""
    var preferences = ""
    var timeframe: Project.Brief.Timeframe?

    // MARK: - Private Properties

    private let router: BriefRouter?
    private let projectGenerator: ProjectGenerator

    @ObservationIgnored @AppStorage(SofaConstants.AppStorage.isBeforeLaunched)
    private var isBeforeLaunched = false
    private var revealedStages: Set<BriefModel.Stage> = []

    // MARK: - Inits

    init(
        router: BriefRouter?,
        projectGenerator: ProjectGenerator,
        brief: Project.Brief?
    ) {
        self.router = router
        self.projectGenerator = projectGenerator
        self.isPreviousEnabled = isBeforeLaunched
        self.isNextEnabled = brief != nil

        if let brief {
            category = brief.category
            focus = brief.focus
            target = brief.target
            currentState = brief.currentState
            preferences = brief.preferences
            timeframe = brief.timeframe
        }
    }
}

// MARK: - Public Methods

extension BriefViewModel {

    // MARK: - Input

    func didViewAppear() {
        updateProgress()
    }

    func didTapBackButton() {
        switch currentStage {
        case .category: handleCategory(for: .previous)
        case .focus: handleFocus(for: .previous)
        case .target: handleTarget(for: .previous)
        case .currentState: handleCurrentState(for: .previous)
        case .preferences: handlePreferences(for: .previous)
        case .timeframe: handleTimeframe(for: .previous)
        }
    }

    func didTapContinueButton() {
        switch currentStage {
        case .category: handleCategory(for: .next)
        case .focus: handleFocus(for: .next)
        case .target: handleTarget(for: .next)
        case .currentState: handleCurrentState(for: .next)
        case .preferences: handlePreferences(for: .next)
        case .timeframe: handleTimeframe(for: .next)
        }
    }

    func selectCategory(_ category: Project.Brief.Category) {
        guard self.category != category else {
            isNextEnabled = true
            return
        }
        self.category = category
        focus.removeAll()
        target.removeAll()
        currentState.removeAll()
        preferences.removeAll()
        timeframe = nil
        isNextEnabled = true
    }

    func selectFocus(_ focus: String) {
        guard self.focus != focus else {
            isNextEnabled = true
            return
        }
        self.focus = focus
        target.removeAll()
        currentState.removeAll()
        preferences.removeAll()
        timeframe = nil
        isNextEnabled = true
    }

    // MARK: - Output

    func needsReveal(for stage: BriefModel.Stage) -> Bool {
        !isBeforeLaunched && !revealedStages.contains(stage)
    }
}

// MARK: - Private Methods

extension BriefViewModel {
    private func handleCategory(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            guard category != nil else { return }
            isNextEnabled = !focus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            nextStage(.focus)
        case .previous:
            router?.back()
        }
    }

    private func handleFocus(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            let trimmedFocus = focus.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedFocus.isEmpty else { return }
            focus = trimmedFocus
            isNextEnabled = !target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            nextStage(.target)
        case .previous:
            isPreviousEnabled = isBeforeLaunched
            previousStage(.category)
        }
    }

    private func handleTarget(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            let trimmedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedTarget.isEmpty else { return }
            target = trimmedTarget
            isNextEnabled = !currentState.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            nextStage(.currentState)
        case .previous:
            previousStage(.focus)
        }
    }

    private func handleCurrentState(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            let trimmedCurrentState = currentState.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedCurrentState.isEmpty else { return }
            currentState = trimmedCurrentState
            isNextEnabled = !preferences.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            nextStage(.preferences)
        case .previous:
            previousStage(.target)
        }
    }

    private func handlePreferences(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            let trimmedPreferences = preferences.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedPreferences.isEmpty else { return }
            preferences = trimmedPreferences
            isNextEnabled = timeframe != nil
            nextStage(.timeframe)
        case .previous:
            previousStage(.currentState)
        }
    }

    private func handleTimeframe(for direction: BriefModel.Direction) {
        switch direction {
        case .next:
            guard timeframe != nil else { return }
            revealedStages.insert(currentStage)
            startGeneration()
        case .previous:
            previousStage(.preferences)
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
        let allCases = BriefModel.Stage.allCases
        progress = max(0, min(1, Double(currentStage.number) / Double(allCases.count)))
    }

    private func startGeneration() {
        guard let category, let timeframe else { return }
        let brief = Project.Brief(
            id: UUID(),
            category: category,
            focus: focus,
            target: target,
            currentState: currentState,
            preferences: preferences,
            timeframe: timeframe
        )
        router?.route(to: .generationLoader(brief, difficulty: .average))
    }
}
