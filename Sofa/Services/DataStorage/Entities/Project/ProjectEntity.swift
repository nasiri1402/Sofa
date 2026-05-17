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
    var hasLifetimeAccess = false
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Inits

    init(from model: Project) {
        self.id = model.id
        self.brief = BriefEntity(from: model.brief)
        self.summary = model.summary
        self.plans = model.plans.map { PlanEntity(from: $0) }
        self.hasLifetimeAccess = model.hasLifetimeAccess
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
            hasLifetimeAccess: hasLifetimeAccess,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
