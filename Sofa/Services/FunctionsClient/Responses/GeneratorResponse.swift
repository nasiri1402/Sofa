//
//  GeneratorResponse.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import Foundation

struct GeneratorResponse: Decodable {
    let summary: String
    let plans: [Plan]
}

extension GeneratorResponse {
    struct Plan: Decodable {
        let title: String
        let emoji: String
        let firstResults: String
        let budget: Int
        let result: String
        let difficulty: Int
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
