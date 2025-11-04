//
//  Profile.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation

struct Profile: Identifiable {
    let id: UUID
    let name: String
    let age: Int
    let gender: Gender
    let country: Country
}

extension Profile {

    // MARK: - Gender

    enum Gender: Int {
        case male, female, other

        var name: String {
            switch self {
            case .female: String(localized: "female")
            case .male: String(localized: "male")
            case .other: String(localized: "other")
            }
        }
    }

    // MARK: - Country

    struct Country {
        let isoCode: String
        let name: String
    }
}

// MARK: - Mocks

extension Profile {
    static let mock = Profile(
        id: UUID(),
        name: "John",
        age: 25,
        gender: .male,
        country: Country(isoCode: "US", name: "United States")
    )
}
