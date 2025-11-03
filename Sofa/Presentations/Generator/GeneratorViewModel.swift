//
//  GeneratorViewModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class GeneratorViewModel {

    // MARK: - Public Properties

    let stories = GeneratorModel.Story.allCases
}

// MARK: - Public Properties

extension GeneratorViewModel {

    // MARK: - Input

    func didTapGenerateButton() {
        // TODO: Навигация к новой генерации
    }
}
