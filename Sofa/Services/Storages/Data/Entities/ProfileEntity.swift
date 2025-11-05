//
//  ProfileEntity.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import SwiftData

@Model
final class ProfileEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: UUID
    var name: String
    var age: Int
    var genderRaw: Int
    var countryISOCode: String
    var countryName: String

    // MARK: - Inits

    init(from model: Profile) {
        self.id = model.id
        self.name = model.name
        self.age = model.age
        self.genderRaw = model.gender.rawValue
        self.countryISOCode = model.country.isoCode
        self.countryName = model.country.name
    }

    // MARK: - Public Methods

    func toProfile() -> Profile {
        Profile(
            id: id,
            name: name,
            age: age,
            gender: Profile.Gender(rawValue: genderRaw) ?? .male,
            country: Profile.Country(isoCode: countryISOCode, name: countryName)
        )
    }
}
