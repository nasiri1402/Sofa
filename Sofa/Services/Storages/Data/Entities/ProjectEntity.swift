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
    var prompt: String
    var summary: String
    @Relationship(deleteRule: .cascade)
    var plans: [PlanEntity]
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Inits

    init(from model: Project) {
        self.id = model.id
        self.prompt = model.prompt
        self.summary = model.summary
        self.plans = model.plans.map { PlanEntity(from: $0) }
        self.createdAt = model.createdAt
        self.updatedAt = model.updatedAt
    }

    // MARK: - Public Methods

    func toProject() -> Project {
        Project(
            id: id,
            prompt: prompt,
            summary: summary,
            plans: plans.map { $0.toPlan() },
            createdAt: createdAt,
            updatedAt: updatedAt
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
    var result: String
    var difficultyRaw: Int
    @Relationship(deleteRule: .cascade)
    var steps: [StepEntity]

    // MARK: - Inits

    init(from model: Project.Plan) {
        self.id = model.id
        self.title = model.title
        self.emoji = model.emoji
        self.result = model.result
        self.difficultyRaw = model.difficulty.rawValue
        self.steps = model.steps.map { StepEntity(from: $0) }
    }

    // MARK: - Public Methods

    func toPlan() -> Project.Plan {
        Project.Plan(
            id: id,
            title: title,
            emoji: emoji,
            result: result,
            difficulty: Project.Plan.Difficulty(rawValue: difficultyRaw) ?? .easy,
            steps: steps.map { $0.toStep() }
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
    var isCompleted: Bool

    // MARK: - Inits

    init(from model: Project.Plan.Step) {
        self.id = model.id
        self.title = model.title
        self.isCompleted = model.isCompleted
    }

    // MARK: - Public Methods

    func toStep() -> Project.Plan.Step {
        Project.Plan.Step(
            id: id,
            title: title,
            isCompleted: isCompleted
        )
    }
}
