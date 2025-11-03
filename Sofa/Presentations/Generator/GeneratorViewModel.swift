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
    var selectedStory: GeneratorModel.Story?
}

// MARK: - Public Properties

extension GeneratorViewModel {

    // MARK: - Input

    func didTapStoryButton(_ story: GeneratorModel.Story) {
        guard selectedStory != story else { return }
        selectedStory = story
    }

    func didTapGenerateButton() {
        // TODO: Навигация к новой генерации
    }
}
