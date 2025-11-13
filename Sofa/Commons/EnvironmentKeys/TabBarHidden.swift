//
//  TabBarHidden.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import SwiftUI

// MARK: - EnvironmentKey

private struct TabBarHiddenEnvironmentKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

// MARK: - EnvironmentValues

extension EnvironmentValues {
    var isTabBarHidden: Binding<Bool> {
        get { self[TabBarHiddenEnvironmentKey.self] }
        set { self[TabBarHiddenEnvironmentKey.self] = newValue }
    }
}
