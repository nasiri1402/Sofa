//
//  OnboardingResponsesDocument.swift
//  Sofa
//
//  Created by dukes on 5/3/26.
//

import FirebaseFirestore
import Foundation

struct OnboardingResponsesDocument: Codable {
    let name: String
    let gender: String?
    let age: Int?
    let country: Country?
    let aboutUs: AboutUs?
    @ServerTimestamp var updatedAt: Timestamp?
}

extension OnboardingResponsesDocument {
    struct Country: Codable {
        let isoCode: String?
        let name: String?
    }

    struct AboutUs: Codable {
        let source: String?
    }
}
