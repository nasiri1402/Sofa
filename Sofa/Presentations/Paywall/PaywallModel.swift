//
//  PaywallModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

enum PaywallModel {

    // MARK: - Placement

    enum Placement: String, CaseIterable {
        case onboarding, settings, generationResult
    }

    // MARK: - Subscription

    enum Subscription: Identifiable, CaseIterable {
        case monthly, weekly

        var id: String {
            switch self {
            case .monthly: "sofa.month.notrial"
            case .weekly: "sofa.week.trial"
            }
        }

        var title: String {
            switch self {
            case .monthly: String(format: String(localized: "monthsPluralFormat"), 1).capitalized
            case .weekly: String(format: String(localized: "weeksPluralFormat"), 1).capitalized
            }
        }

        var isBestValue: Bool {
            switch self {
            case .monthly: true
            case .weekly: false
            }
        }

        var withTrial: Bool {
            switch self {
            case .monthly: false
            case .weekly: true
            }
        }

        init?(id: String) {
            switch id {
            case Subscription.monthly.id: self = .monthly
            case Subscription.weekly.id: self = .weekly
            default: return nil
            }
        }
    }
}
