//
//  TabBarModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

enum TabBarModel {

    // MARK: - Item

    enum Tab {
        case generator, plans, settings

        var title: String {
            switch self {
            case .generator: String(localized: "generator")
            case .plans: String(localized: "plans")
            case .settings: String(localized: "settings")
            }
        }

        var selectedIcon: ImageResource {
            switch self {
            case .generator: .generatorSelected
            case .plans: .plansSelected
            case .settings: .settingsSelected
            }
        }

        var unselectedIcon: ImageResource {
            switch self {
            case .generator: .generatorUnselected
            case .plans: .plansUnselected
            case .settings: .settingsUnselected
            }
        }
    }
}
