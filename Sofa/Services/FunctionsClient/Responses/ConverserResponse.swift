//
//  ConverserResponse.swift
//  Sofa
//
//  Created by dukes on 5/19/26.
//

import Foundation

struct ConverserResponse: Decodable {
    let action: Action

    private enum CodingKeys: String, CodingKey {
        case action, payload
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .action) {
        case "create":
            action = .create(try container.decode(CreatePayload.self, forKey: .payload))
        case "close":
            action = .close(try container.decode(ClosePayload.self, forKey: .payload))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .action,
                in: container,
                debugDescription: "Unsupported converser action response."
            )
        }
    }
}

extension ConverserResponse {

    // MARK: - Action

    enum Action {
        case create(CreatePayload), close(ClosePayload)
    }

    // MARK: - CreatePayload

    struct CreatePayload: Decodable {
        let conversationID: String

        private enum CodingKeys: String, CodingKey {
            case conversationID = "conversation_id"
        }
    }

    // MARK: - ClosePayload

    struct ClosePayload: Decodable {
        let isDeleted: Bool

        private enum CodingKeys: String, CodingKey {
            case isDeleted = "deleted"
        }
    }
}
