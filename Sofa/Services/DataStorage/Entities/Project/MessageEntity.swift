//
//  MessageEntity.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation
import SwiftData

@Model
final class MessageEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: UUID
    var text: String
    var context: String?
    var isFromUser: Bool
    var sentAt: Date

    // MARK: - Inits

    init(from model: Project.Plan.Chat.Message) {
        self.id = model.id
        self.text = model.text
        self.context = model.context
        self.isFromUser = model.isFromUser
        self.sentAt = model.sentAt
    }

    // MARK: - Public Methods

    func toMessage() -> Project.Plan.Chat.Message {
        Project.Plan.Chat.Message(
            id: id,
            text: text,
            context: context,
            isFromUser: isFromUser,
            sentAt: sentAt
        )
    }
}
