//
//  GeneratorRequest.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import Foundation

struct GeneratorRequest: Encodable {
    let messages: [Message]
    let responseFormat: ResponseFormat

    init(
        messages: [Message],
        responseFormat: ResponseFormat = ResponseFormat(type: .json)
    ) {
        self.messages = messages
        self.responseFormat = responseFormat
    }
}

extension GeneratorRequest {
    struct Message: Encodable {
        let role: Role
        let content: [Content]
    }

    struct ResponseFormat: Encodable {
        let type: FormatType
    }
}

extension GeneratorRequest.ResponseFormat {
    enum FormatType: String, Encodable {
        case text, json = "json_object"
    }
}

extension GeneratorRequest.Message {
    struct Content: Encodable {
        let type: ContentType
        let image: String?
        let text: String?

        init(type: ContentType, imageBase64: String? = nil, text: String? = nil) {
            self.type = type
            self.image = imageBase64.map { "data:image/jpeg;base64," + $0 }
            self.text = text
        }
    }

    enum Role: String, Encodable {
        case system, user
    }
}

extension GeneratorRequest.Message.Content {
    enum ContentType: String, Encodable {
        case text = "input_text"
        case image = "input_image"
    }

    private enum CodingKeys: String, CodingKey {
        case type, text, image = "image_url"
    }
}

// MARK: - UsetContent

extension GeneratorRequest {
    struct UserContent: Encodable {
        let profile: Profile
        let brief: Brief
        let responseLanguageCode: String

        struct Profile: Encodable {
            let name: String
            let age: String?
            let gender: String?
            let countryCode: String?
            let currencyCode: String
        }

        struct Brief: Encodable {
            let idea: String
            let timeframe: String
            let experience: String
            let difficulty: String
            let startPoint: String
            let result: Result
            let budget: Int?
            let limits: String
        }

        struct Result: Encodable {
            let goals: [String]
            let money: String?
            let subscribers: String?
            let option: String?
        }
    }
}
