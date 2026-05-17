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
    var threadID: String
    @Relationship(deleteRule: .cascade)
    var messages: [MessageEntity]

    // MARK: - Inits

    init(from model: Project.Plan.Chat) {
        self.id = model.id
        self.threadID = model.threadID
        self.messages = model.messages.map { MessageEntity(from: $0) }
    }

    // MARK: - Public Methods

    func toChat() -> Project.Plan.Chat {
        Project.Plan.Chat(
            id: id,
            threadID: threadID,
            messages: messages.map { $0.toMessage() }.sorted { $0.sentAt > $1.sentAt }
        )
    }
}
