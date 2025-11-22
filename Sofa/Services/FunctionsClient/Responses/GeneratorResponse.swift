//
//  GeneratorResponse.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import Foundation

struct GeneratorResponse: Decodable {
    let output: [Output]

    var message: String {
        for out in output {
            if let text = out.content?.first(where: { $0.type == "output_text" })?.text {
                return text
            }
        }
        return ""
    }
}

extension GeneratorResponse {
    struct Output: Decodable {
        let content: [Content]?
    }
}

extension GeneratorResponse.Output {
    struct Content: Decodable {
        let type: String
        let text: String?
    }
}

// MARK: - ProjectContent

extension GeneratorResponse {
    struct ProjectContent: Decodable {
        let summary: String
        let plans: [Plan]
    }

    struct Plan: Decodable {
        let title: String
        let emoji: String
        let firstResults: String
        let budget: Int
        let result: String
        let weeks: [Week]
    }

    struct Week: Decodable {
        let number: Int
        let steps: [Step]
    }

    struct Step: Decodable {
        let title: String
        let number: Int
    }
}
