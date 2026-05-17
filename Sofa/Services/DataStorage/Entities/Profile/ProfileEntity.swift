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
    var age: Int?
    var genderRaw: Int?
    var countryISOCode: String?
    var countryName: String?
    var currencyCode: String

    // MARK: - Inits

    init(from model: Profile) {
        self.id = model.id
        self.name = model.name
        self.age = model.age
        self.genderRaw = model.gender?.rawValue
        self.countryISOCode = model.country?.isoCode
        self.countryName = model.country?.name
        self.currencyCode = model.currency.code
    }

    // MARK: - Public Methods

    func toProfile() -> Profile {
        Profile(
            id: id,
            name: name,
            age: age,
            gender: {
                guard let genderRaw else { return nil }
                return Profile.Gender(rawValue: genderRaw)
            }(),
            country: {
                guard let countryISOCode, let countryName else { return nil }
                return Profile.Country(isoCode: countryISOCode, name: countryName)
            }(),
            currency: Profile.Currency(code: currencyCode)
        )
    }
}
