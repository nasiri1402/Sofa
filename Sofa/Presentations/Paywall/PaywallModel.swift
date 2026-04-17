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
        case generator, settings, generationResult, stepTree
    }

    // MARK: - Subscription

    enum Subscription: Identifiable, CaseIterable {
        case yearly, weekly

        var id: String {
            switch self {
            case .yearly: "com.ai.sofa.subscriptions.year"
            case .weekly: "com.ai.sofa.subscriptions.week.3trial"
            }
        }

        var title: String {
            switch self {
            case .yearly: String(format: String(localized: "yearsPluralFormat"), 1).capitalized
            case .weekly: String(format: String(localized: "weeksPluralFormat"), 1).capitalized
            }
        }

        var isBestValue: Bool {
            switch self {
            case .yearly: true
            case .weekly: false
            }
        }

        var withTrial: Bool {
            switch self {
            case .yearly: false
            case .weekly: true
            }
        }

        init?(id: String) {
            switch id {
            case Subscription.yearly.id: self = .yearly
            case Subscription.weekly.id: self = .weekly
            default: return nil
            }
        }
    }
}
