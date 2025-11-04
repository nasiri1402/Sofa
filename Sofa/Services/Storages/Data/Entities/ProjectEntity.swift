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

    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var emoji: String
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Inits

    init(from model: Project) {
        self.id = model.id
        self.title = model.title
        self.summary = model.summary
        self.emoji = model.emoji
        self.createdAt = model.createdAt
        self.updatedAt = model.updatedAt
    }

    // MARK: - Public Methods

    func toProject() -> Project {
        Project(
            id: id,
            title: title,
            summary: summary,
            emoji: emoji,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
