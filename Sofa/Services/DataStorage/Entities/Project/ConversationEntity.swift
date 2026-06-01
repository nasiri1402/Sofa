//
//  ConversationEntity.swift
//  Sofa
//
//  Created by dukes on 5/19/26.
//

import Foundation
import SwiftData

@Model
final class ConversationEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: String
    var context: String
    var isDirty: Bool

    // MARK: - Inits

    init(from model: Project.Plan.Chat.Conversation) {
        self.id = model.id
        self.context = model.context
        self.isDirty = model.isDirty
    }

    // MARK: - Public Methods

    func toConversation() -> Project.Plan.Chat.Conversation {
        Project.Plan.Chat.Conversation(
            id: id,
            context: context,
            isDirty: isDirty
        )
    }
}
