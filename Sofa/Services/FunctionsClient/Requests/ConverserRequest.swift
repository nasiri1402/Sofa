//
//  ConverserRequest.swift
//  Sofa
//
//  Created by dukes on 5/19/26.
//

import Foundation

struct ConverserRequest: Encodable {
    let action: Action

    private enum CodingKeys: String, CodingKey {
        case action, payload
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch action {
        case .create(let payload):
            try container.encode("create", forKey: .action)
            try container.encode(payload, forKey: .payload)
        case .close(let payload):
            try container.encode("close", forKey: .action)
            try container.encode(payload, forKey: .payload)
        }
    }
}

extension ConverserRequest {

    // MARK: - Action

    enum Action {
        case create(CreatePayload), close(ClosePayload)
    }

    // MARK: - CreatePayload

    struct CreatePayload: Encodable {}

    // MARK: - ClosePayload

    struct ClosePayload: Encodable {
        let conversationID: String

        private enum CodingKeys: String, CodingKey {
            case conversationID = "conversation_id"
        }
    }
}
