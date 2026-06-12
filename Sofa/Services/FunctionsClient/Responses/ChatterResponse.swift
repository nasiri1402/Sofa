//
//  ChatterResponse.swift
//  Sofa
//
//  Created by dukes on 5/19/26.
//

import Foundation

nonisolated struct ChatterResponse: Decodable, Sendable {
    let action: Action

    private enum CodingKeys: String, CodingKey {
        case action, payload
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .action) {
        case "update_context":
            action = .updateContext(try container.decode(UpdateContextPayload.self, forKey: .payload))
        case "delete_message":
            action = .deleteMessage(try container.decode(DeleteMessagePayload.self, forKey: .payload))
        case "send_message":
            action = .sendMessage(try container.decode(SendMessagePayload.self, forKey: .payload))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .action,
                in: container,
                debugDescription: "Unsupported chatter action response."
            )
        }
    }
}

extension ChatterResponse {

    // MARK: - Action

    enum Action: Sendable {
        case updateContext(UpdateContextPayload)
        case deleteMessage(DeleteMessagePayload)
        case sendMessage(SendMessagePayload)
    }

    // MARK: - UpdateContextPayload

    struct UpdateContextPayload: Decodable, Sendable {
        let isUpdated: Bool

        private enum CodingKeys: String, CodingKey {
            case isUpdated = "updated"
        }
    }

    // MARK: - DeleteMessagePayload

    struct DeleteMessagePayload: Decodable, Sendable {
        let isDeleted: Bool

        private enum CodingKeys: String, CodingKey {
            case isDeleted = "deleted"
        }
    }

    // MARK: - SendMessagePayload

    struct SendMessagePayload: Decodable, Sendable {
        let message: String
        let userItemID: String?
        let assistantItemID: String?

        private enum CodingKeys: String, CodingKey {
            case message
            case userItemID = "user_item_id"
            case assistantItemID = "assistant_item_id"
        }
    }

    // MARK: - StreamEvent

    enum StreamEvent {
        case delta(String)
        case result(ChatterResponse)
    }

    // MARK: - StreamChunk

    nonisolated struct StreamChunk: Decodable, Sendable {
        let delta: String
    }
}
