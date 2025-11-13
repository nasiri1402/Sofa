//
//  ViewFactory.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import SwiftUI

// MARK: - ViewFactory

protocol ViewFactory {
    @MainActor
    func makeView() -> AnyView
}
