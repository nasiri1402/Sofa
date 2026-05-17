//
//  PlanEntity.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation
import SwiftData

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
    @Relationship(deleteRule: .cascade)
    var chat: ChatEntity?
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
        self.chat = model.chat.map { ChatEntity(from: $0) }
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
            chat: chat?.toChat(),
            isFavorite: isFavorite,
            createdAt: createdAt
        )
    }
}
