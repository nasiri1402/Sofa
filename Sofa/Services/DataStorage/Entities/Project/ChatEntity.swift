//
//  ChatEntity.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation
import SwiftData

@Model
final class ChatEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: UUID
    @Relationship(deleteRule: .cascade)
    var conversation: ConversationEntity?
    @Relationship(deleteRule: .cascade)
    var messages: [MessageEntity]

    // MARK: - Inits

    init(from model: Project.Plan.Chat) {
        self.id = model.id
        self.conversation = model.conversation.map { ConversationEntity(from: $0) }
        self.messages = model.messages.map { MessageEntity(from: $0) }
    }

    // MARK: - Public Methods

    func toChat() -> Project.Plan.Chat {
        Project.Plan.Chat(
            id: id,
            conversation: conversation?.toConversation(),
            messages: messages.map { $0.toMessage() }.sorted { $0.createdAt > $1.createdAt }
        )
    }
}
