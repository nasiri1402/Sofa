//
//  MyDataModel.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation

enum MyDataModel {

    // MARK: - Field

    enum Field: Hashable, CaseIterable {
        case name, gender, age, country

        var title: String {
            switch self {
            case .name: String(localized: "name")
            case .gender: String(localized: "gender")
            case .age: String(localized: "age")
            case .country: String(localized: "country")
            }
        }
    }
}
