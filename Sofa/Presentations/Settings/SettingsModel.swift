//
//  SettingsModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

enum SettingsModel {

    // MARK: - Field

    enum Field: Hashable, CaseIterable {
        case pro, termsOfUse, privacyPolicy, share, contactUs, rateUs, myData, language

        var title: String {
            switch self {
            case .pro: String(localized: "getProVersion")
            case .termsOfUse: String(localized: "termsOfUse")
            case .privacyPolicy: String(localized: "privacyPolicy")
            case .share: String(localized: "share")
            case .contactUs: String(localized: "contactUs")
            case .rateUs: String(localized: "rateUs")
            case .myData: String(localized: "myData")
            case .language: String(localized: "language")
            }
        }

        var icon: ImageResource {
            switch self {
            case .pro: .pro
            case .termsOfUse: .termsOfUse
            case .privacyPolicy: .privacyPolicy
            case .share: .share
            case .contactUs: .contactUs
            case .rateUs: .rateUs
            case .myData: .myData
            case .language: .language
            }
        }

        var foregroundColor: ColorResource {
            switch self {
            case .pro: .black090909
            case .rateUs: .yellowFFCC00
            default: .blue007AFF
            }
        }

        var needsExtraBottomPadding: Bool {
            switch self {
            case .pro, .privacyPolicy, .rateUs: true
            default: false
            }
        }
    }

    // MARK: - SupportMail

    struct SupportMail {
        let email: String
        let title: String
        let message: String
    }
}
