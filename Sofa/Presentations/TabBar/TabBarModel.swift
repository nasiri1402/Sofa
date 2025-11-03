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
        case generator, inProcess, settings

        var title: String {
            switch self {
            case .generator: String(localized: "generator")
            case .inProcess: String(localized: "inProcess")
            case .settings: String(localized: "settings")
            }
        }

        var selectedIcon: ImageResource {
            switch self {
            case .generator: .generatorSelected
            case .inProcess: .inProcessSelected
            case .settings: .settingsSelected
            }
        }

        var unselectedIcon: ImageResource {
            switch self {
            case .generator: .generatorUnselected
            case .inProcess: .inProcessUnselected
            case .settings: .settingsUnselected
            }
        }
    }
}
