//
//  StoriesModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

enum StoriesModel {

    // MARK: - Story

    enum Story: String, Identifiable, Hashable, CaseIterable {
        case green, orange, red

        var id: String {
            rawValue
        }

        var color: Color {
            switch self {
            case .green: .green34C759
            case .orange: .orangeFF9500
            case .red: .redFF3B30
            }
        }
    }

    // MARK: - Page

    struct Page: Hashable {
        let title: PageText
        let tips: [PageText]

        struct PageText: Hashable {
            let text: String
            let emoji: String?

            var fullText: String {
                if let emoji {
                    emoji + " " + text
                } else {
                    text
                }
            }
        }
    }
}
