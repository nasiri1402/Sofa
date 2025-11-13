//
//  Profile.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation

struct Profile: Identifiable, Hashable {
    let id: UUID
    let name: String
    let age: Int
    let gender: Gender
    let country: Country
    let currency: Currency

    func copy(
        name: String? = nil,
        age: Int? = nil,
        gender: Gender? = nil,
        country: Country? = nil,
        currency: Currency? = nil
    ) -> Profile {
        Profile(
            id: id,
            name: name ?? self.name,
            age: age ?? self.age,
            gender: gender ?? self.gender,
            country: country ?? self.country,
            currency: currency ?? self.currency
        )
    }
}

extension Profile {

    // MARK: - Gender

    enum Gender: Int, Hashable, CaseIterable {
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

    struct Country: Hashable {
        let isoCode: String
        let name: String
    }

    // MARK: - Currency

    struct Currency: Hashable {
        let code: String
    }
}

// MARK: - Mocks

extension Profile {
    static let mock = Profile(
        id: UUID(),
        name: "Ivan",
        age: 25,
        gender: .male,
        country: Country(isoCode: "RU", name: "Russia"),
        currency: Currency(code: "USD")
    )
}
