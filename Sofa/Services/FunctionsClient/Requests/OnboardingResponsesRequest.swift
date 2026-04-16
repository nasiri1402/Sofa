//
//  OnboardingResponsesRequest.swift
//  Sofa
//
//  Created by Codex on 4/16/26.
//

import Foundation

struct OnboardingResponsesRequest: Encodable {
    let name: Name
    let gender: Gender
    let age: Age
    let country: Country
    let aboutUs: AboutUs
}

extension OnboardingResponsesRequest {
    struct Name: Encodable {
        let name: String
    }

    struct Gender: Encodable {
        let gender: String?
    }

    struct Age: Encodable {
        let age: Int?
    }

    struct Country: Encodable {
        let isoCode: String?
        let name: String?
    }

    struct AboutUs: Encodable {
        let source: String?
        let other: String?
    }
}
