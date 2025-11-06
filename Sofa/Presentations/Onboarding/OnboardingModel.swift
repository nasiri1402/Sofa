//
//  OnboardingModel.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation

enum OnboardingModel {

    // MARK: - Stage

    enum Stage {
        case logo, letsBegin, name, gender, age, country, aboutUs, privacy, rateUs, letsAsk

        var actionTitle: String {
            switch self {
            case .logo: ""
            case .letsBegin: String(localized: "letsBegin")
            case .name, .gender, .age, .country, .aboutUs, .privacy: String(localized: "continue")
            case .rateUs: String(localized: "rateUs")
            case .letsAsk: String(localized: "letsAsk")
            }
        }

        func next() -> Stage? {
            switch self {
            case .logo: .letsBegin
            case .letsBegin: .name
            case .name: .gender
            case .gender: .age
            case .age: .country
            case .country: .aboutUs
            case .aboutUs: .privacy
            case .privacy: .rateUs
            case .rateUs: .letsAsk
            case .letsAsk: nil
            }
        }

        func previous() -> Stage? {
            switch self {
            case .logo: nil
            case .letsBegin: .logo
            case .name: .letsAsk
            case .gender: .name
            case .age: .gender
            case .country: .age
            case .aboutUs: .country
            case .privacy: .aboutUs
            case .rateUs: .privacy
            case .letsAsk: .rateUs
            }
        }
    }

    // MARK: - Source

    enum Source: CaseIterable {
        case instagramFacebook, tikTok, youTube, appStore, influencer, friendFamily, other

        var title: String {
            switch self {
            case .instagramFacebook: String(localized: "instagramFacebook")
            case .tikTok: String(localized: "tikTok")
            case .youTube: String(localized: "youTube")
            case .appStore: String(localized: "appStore")
            case .influencer: String(localized: "influencer")
            case .friendFamily: String(localized: "friendFamily")
            case .other: String(localized: "other")
            }
        }
    }
}
