//
//  InProcessModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation

enum InProcessModel {

    // MARK: - Segment

    enum Segment: Int, CaseIterable {
        case inWork, completed

        var title: String {
            switch self {
            case .inWork: String(localized: "inWork")
            case .completed: String(localized: "completed")
            }
        }
    }

    // MARK: - EmptyState

    enum EmptyState {
        case inWork, completed

        var title: String {
            String(localized: "itIsEmptyHere")
        }

        var description: String {
            switch self {
            case .inWork: String(localized: "emptyStateInWorkDescription")
            case .completed: String(localized: "emptyStateCompletedDescription")
            }
        }
    }
}
