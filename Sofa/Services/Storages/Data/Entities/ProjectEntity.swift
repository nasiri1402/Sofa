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
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var emoji: String
    var createdAt: Date
    var updatedAt: Date

    init(from model: Project) {
        self.id = model.id
        self.title = model.title
        self.summary = model.summary
        self.emoji = model.emoji
        self.createdAt = model.createdAt
        self.updatedAt = model.updatedAt
    }

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
