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
    var idea: String
    var timeframeRaw: Int
    var experienceRaw: Int
    var startPoint: String
    var resultGoalsRaw: Set<Int>
    var resultMoney: Int?
    var resultSubscribers: Int?
    var resultOption: String?
    var budget: Int?
    var limits: String

    // MARK: - Inits

    init(from model: Project.Brief) {
        self.id = model.id
        self.idea = model.idea
        self.timeframeRaw = model.timeframe.rawValue
        self.experienceRaw = model.experience.rawValue
        self.startPoint = model.startPoint
        self.resultGoalsRaw = Set(model.result.goals.map(\.rawValue))
        self.resultMoney = model.result.money
        self.resultSubscribers = model.result.subscribers
        self.resultOption = model.result.option
        self.budget = model.budget
        self.limits = model.limits
    }

    // MARK: - Public Methods

    func toBrief() -> Project.Brief {
        Project.Brief(
            id: id,
            idea: idea,
            timeframe: Project.Brief.Timeframe(rawValue: timeframeRaw) ?? .month1,
            experience: Project.Brief.Experience(rawValue: experienceRaw) ?? .beginner,
            startPoint: startPoint,
            result: Project.Brief.Result(
                goals: Set(resultGoalsRaw.map { Project.Brief.Goal(rawValue: $0) ?? .money }),
                money: resultMoney,
                subscribers: resultSubscribers,
                option: resultOption
            ),
            budget: budget,
            limits: limits
        )
    }
}
