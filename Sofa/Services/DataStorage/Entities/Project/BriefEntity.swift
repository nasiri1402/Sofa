//
//  BriefEntity.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation
import SwiftData

@Model
final class BriefEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: UUID
    var categoryRaw: String?
    var focus: String?
    var target: String?
    var currentState: String?
    var preferences: String?
    var timeframeRaw: Int

    // These properties belong to the 1.2.0 schema. Keeping them optional makes
    // the 1.2.1 schema additive, so SwiftData can preserve existing briefs.
    var idea: String?
    var experienceRaw: Int?
    var startPoint: String?
    var resultGoalsRaw: Set<Int>?
    var resultMoney: Int?
    var resultSubscribers: Int?
    var resultOption: String?
    var budget: Int?
    var limits: String?

    // MARK: - Inits

    init(from model: Project.Brief) {
        self.id = model.id
        self.categoryRaw = model.category.rawValue
        self.focus = model.focus
        self.target = model.target
        self.currentState = model.currentState
        self.preferences = model.preferences
        self.timeframeRaw = model.timeframe.rawValue
        self.idea = nil
        self.experienceRaw = nil
        self.startPoint = nil
        self.resultGoalsRaw = nil
        self.resultMoney = nil
        self.resultSubscribers = nil
        self.resultOption = nil
        self.budget = nil
        self.limits = nil
    }

    // MARK: - Public Methods

    func toBrief() -> Project.Brief {
        Project.Brief(
            id: id,
            category: Project.Brief.Category(rawValue: categoryRaw ?? "") ?? .productivity,
            focus: nonEmpty(focus) ?? nonEmpty(idea) ?? "",
            target: nonEmpty(target) ?? legacyTarget,
            currentState: nonEmpty(currentState) ?? nonEmpty(startPoint) ?? "",
            preferences: nonEmpty(preferences) ?? legacyPreferences,
            timeframe: Project.Brief.Timeframe(rawValue: timeframeRaw) ?? .month1
        )
    }

    // MARK: - Private Properties

    private var legacyTarget: String {
        if let resultOption = nonEmpty(resultOption) {
            return resultOption
        }
        if let resultMoney {
            return String(resultMoney)
        }
        if let resultSubscribers {
            return String(resultSubscribers)
        }
        return nonEmpty(idea) ?? ""
    }

    private var legacyPreferences: String {
        var components: [String] = []
        if let limits = nonEmpty(limits) {
            components.append(limits)
        }
        if let budget {
            components.append("Budget: \(budget)")
        }
        return components.joined(separator: ", ")
    }

    private func nonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
