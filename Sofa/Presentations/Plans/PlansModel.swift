//
//  Model.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation

enum PlansModel {

    // MARK: - Segment

    enum Segment: Int, CaseIterable {
        case inWork, completed, favorites

        var title: String {
            switch self {
            case .inWork: String(localized: "inWork")
            case .completed: String(localized: "completed")
            case .favorites: String(localized: "favorites")
            }
        }
    }

    // MARK: - EmptyState

    enum EmptyState {
        case inWork, completed, favorites

        var title: String {
            String(localized: "itIsEmptyHere")
        }

        var description: String {
            switch self {
            case .inWork: String(localized: "emptyStateInWorkDescription")
            case .completed: String(localized: "emptyStateCompletedDescription")
            case .favorites: String(localized: "emptyStateFavoritesDescription")
            }
        }
    }
}
