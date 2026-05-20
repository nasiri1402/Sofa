//
//  ChatterResponse.swift
//  Sofa
//
//  Created by dukes on 5/19/26.
//

import Foundation

struct ChatterResponse: Decodable {
    let action: Action

    private enum CodingKeys: String, CodingKey {
        case action, payload
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .action) {
        case "update_context":
            action = .updateContext(try container.decode(UpdateContextPayload.self, forKey: .payload))
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

    enum Action {
        case updateContext(UpdateContextPayload)
        case sendMessage(SendMessagePayload)
    }

    // MARK: - UpdateContextPayload

    struct UpdateContextPayload: Decodable {
        let isUpdated: Bool

        private enum CodingKeys: String, CodingKey {
            case isUpdated = "updated"
        }
    }

    // MARK: - SendMessagePayload

    struct SendMessagePayload: Decodable {
        let message: String
    }
}
