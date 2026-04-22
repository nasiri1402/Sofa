//
//  GiftPaywallModel.swift
//  Sofa
//
//  Created by dukes on 4/17/26.
//

import Foundation

enum GiftPaywallModel {

    // MARK: - State
    
    enum State {
        case teaser, offer

        var title: String {
            switch self {
            case .teaser: String(localized: "weHaveSpecialSurpriseForYou")
            case .offer: String(localized: "limitedOffer")
            }
        }

        var subtitle: String {
            switch self {
            case .teaser: String(localized: "waitDontGo")
            case .offer: String(localized: "onceYouCloseOfferItsGone")
            }
        }

        var action: String {
            switch self {
            case .teaser: String(localized: "seeTheSurprise")
            case .offer: String(localized: "claimLimitedOffer")
            }
        }
    }

    enum Subscription {
        case yearly

        var id: String {
            switch self {
            case .yearly: PaywallModel.Subscription.yearly.id + ".gift"
            }
        }
    }
}
