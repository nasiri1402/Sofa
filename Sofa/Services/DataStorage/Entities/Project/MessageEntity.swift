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
    var itemID: String?
    var text: String
    var context: String?
    var isFromUser: Bool
    var isFailed: Bool = false
    var createdAt: Date

    // MARK: - Inits

    init(from model: Project.Plan.Chat.Message) {
        self.id = model.id
        self.itemID = model.itemID
        self.text = model.text
        self.context = model.context
        self.isFromUser = model.isFromUser
        self.isFailed = model.isFailed
        self.createdAt = model.createdAt
    }

    // MARK: - Public Methods

    func toMessage() -> Project.Plan.Chat.Message {
        Project.Plan.Chat.Message(
            id: id,
            itemID: itemID,
            text: text,
            context: context,
            isFromUser: isFromUser,
            isFailed: isFailed,
            createdAt: createdAt
        )
    }
}
