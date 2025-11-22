//
//  ProjectEntity.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import SwiftData

@Model
final class ProjectEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: UUID
    @Relationship(deleteRule: .cascade)
    var brief: BriefEntity
    var summary: String
    @Relationship(deleteRule: .cascade)
    var plans: [PlanEntity]
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Inits

    init(from model: Project) {
        self.id = model.id
        self.brief = BriefEntity(from: model.brief)
        self.summary = model.summary
        self.plans = model.plans.map { PlanEntity(from: $0) }
        self.createdAt = model.createdAt
        self.updatedAt = model.updatedAt
    }

    // MARK: - Public Methods

    func toProject() -> Project {
        Project(
            id: id,
            brief: brief.toBrief(),
            summary: summary,
            plans: plans.map { $0.toPlan() }.sorted { $0.createdAt < $1.createdAt },
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Brief

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

// MARK: - Plan

@Model
final class PlanEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: UUID
    var title: String
    var emoji: String
    var firstResults: String
    var budget: Int
    var result: String
    var difficultyRaw: Int
    @Relationship(deleteRule: .cascade)
    var weeks: [WeekEntity]
    var isFavorite: Bool
    var createdAt: Date

    // MARK: - Inits

    init(from model: Project.Plan) {
        self.id = model.id
        self.title = model.title
        self.emoji = model.emoji
        self.firstResults = model.firstResults
        self.budget = model.budget
        self.result = model.result
        self.difficultyRaw = model.difficulty.rawValue
        self.weeks = model.weeks.map { WeekEntity(from: $0) }
        self.isFavorite = model.isFavorite
        self.createdAt = model.createdAt
    }

    // MARK: - Public Methods

    func toPlan() -> Project.Plan {
        Project.Plan(
            id: id,
            title: title,
            emoji: emoji,
            firstResults: firstResults,
            budget: budget,
            result: result,
            difficulty: Project.Plan.Difficulty(rawValue: difficultyRaw) ?? .easy,
            weeks: weeks.map { $0.toWeek() }.sorted { $0.number < $1.number },
            isFavorite: isFavorite,
            createdAt: createdAt
        )
    }
}

// MARK: - Week

@Model
final class WeekEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: UUID
    var number: Int
    @Relationship(deleteRule: .cascade)
    var steps: [StepEntity]

    // MARK: - Inits

    init(from model: Project.Plan.Week) {
        self.id = model.id
        self.number = model.number
        self.steps = model.steps.map { StepEntity(from: $0) }
    }

    // MARK: - Public Methods

    func toWeek() -> Project.Plan.Week {
        Project.Plan.Week(
            id: id,
            number: number,
            steps: steps.map { $0.toStep() }.sorted { $0.number < $1.number }
        )
    }
}

// MARK: - Step

@Model
final class StepEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: UUID
    var title: String
    var number: Int
    var isCompleted: Bool

    // MARK: - Inits

    init(from model: Project.Plan.Step) {
        self.id = model.id
        self.title = model.title
        self.number = model.number
        self.isCompleted = model.isCompleted
    }

    // MARK: - Public Methods

    func toStep() -> Project.Plan.Step {
        Project.Plan.Step(
            id: id,
            title: title,
            number: number,
            isCompleted: isCompleted
        )
    }
}
