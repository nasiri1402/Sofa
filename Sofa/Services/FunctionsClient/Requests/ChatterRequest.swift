//
//  ChatterRequest.swift
//  Sofa
//
//  Created by dukes on 5/19/26.
//

import Foundation

struct ChatterRequest: Encodable {
    let action: Action

    private enum CodingKeys: String, CodingKey {
        case action, payload
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch action {
        case .updateContext(let payload):
            try container.encode("update_context", forKey: .action)
            try container.encode(payload, forKey: .payload)
        case .deleteMessage(let payload):
            try container.encode("delete_message", forKey: .action)
            try container.encode(payload, forKey: .payload)
        case .sendMessage(let payload):
            try container.encode("send_message", forKey: .action)
            try container.encode(payload, forKey: .payload)
        }
    }
}

extension ChatterRequest {

    // MARK: - Action

    enum Action {
        case updateContext(UpdateContextPayload)
        case deleteMessage(DeleteMessagePayload)
        case sendMessage(SendMessagePayload)
    }

    // MARK: - UpdateContextPayload

    struct UpdateContextPayload: Encodable {
        let conversationID: String
        let context: String

        private enum CodingKeys: String, CodingKey {
            case conversationID = "conversation_id"
            case context
        }
    }

    struct DeleteMessagePayload: Encodable {
        let conversationID: String
        let itemID: String

        private enum CodingKeys: String, CodingKey {
            case conversationID = "conversation_id"
            case itemID = "item_id"
        }
    }

    // MARK: - SendMessagePayload

    struct SendMessagePayload: Encodable {
        let conversationID: String
        let instructions: String
        let message: String
        let context: String?

        private enum CodingKeys: String, CodingKey {
            case conversationID = "conversation_id"
            case instructions, message, context
        }
    }
}
