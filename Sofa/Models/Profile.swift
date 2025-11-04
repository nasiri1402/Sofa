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

    func copy(
        name: String? = nil,
        age: Int? = nil,
        gender: Gender? = nil,
        country: Country? = nil
    ) -> Profile {
        Profile(
            id: id,
            name: name ?? self.name,
            age: age ?? self.age,
            gender: gender ?? self.gender,
            country: country ?? self.country
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
}

// MARK: - Mocks

extension Profile {
    static let mock = Profile(
        id: UUID(),
        name: "Ivan",
        age: 25,
        gender: .male,
        country: Country(isoCode: "RU", name: "Russia")
    )
}
