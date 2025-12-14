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
        case letsBegin, name, gender, age, country, aboutUs, aboutUsOther, privacy, rateUs, letsAsk

        func actionTitle(isForceContinue: Bool) -> String {
            guard !isForceContinue else {
                return String(localized: "continue")
            }
            return switch self {
            case .letsBegin: String(localized: "letsBegin")
            case .name, .gender, .age, .country, .aboutUs, .aboutUsOther, .privacy: String(localized: "continue")
            case .rateUs: String(localized: "rateUs")
            case .letsAsk: String(localized: "letsAsk")
            }
        }
    }

    // MARK: - Country

    typealias Country = CountryModel.Country

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
