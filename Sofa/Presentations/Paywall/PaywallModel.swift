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
        case generator, settings, generationResult, stepTree, gift
    }

    // MARK: - Subscription

    enum Subscription: Identifiable, CaseIterable {
        // Only these products are offered to new customers. Existing weekly
        // entitlements are still handled by StoreManager independently.
        case yearly, monthly

        var id: String {
            switch self {
            case .yearly: "com.ai.sofa.subscriptions.year"
            case .monthly: "com.ai.sofa.subscriptions.month"
            }
        }

        var title: String {
            switch self {
            case .yearly: String(format: String(localized: "yearsPluralFormat"), 1).capitalized
            case .monthly: String(format: String(localized: "monthsPluralFormat"), 1).capitalized
            }
        }

        var isBestValue: Bool {
            switch self {
            case .yearly: true
            case .monthly: false
            }
        }

        init?(id: String) {
            switch id {
            case Subscription.yearly.id: self = .yearly
            case Subscription.monthly.id: self = .monthly
            default: return nil
            }
        }
    }
}
