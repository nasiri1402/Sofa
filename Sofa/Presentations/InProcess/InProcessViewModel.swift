//
//  InProcessViewModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class InProcessViewModel {

    // MARK: - Public Properties

    let segments = InProcessModel.Segment.allCases
    var selectedSegment: InProcessModel.Segment = .inWork {
        didSet {
            guard oldValue != selectedSegment else { return }
            checkEmptyState()
        }
    }
    private(set) var emptyState: InProcessModel.EmptyState?

    // MARK: - Inits

    init() {
        checkEmptyState()
    }
}

// MARK: - Public Properties

extension InProcessViewModel {

    // MARK: - Input

}

// MARK: - Private Methods

extension InProcessViewModel {
    private func checkEmptyState() {
        // TODO: Нужно проверять есть ли данные для нужного сегмента
        switch selectedSegment {
        case .inWork: emptyState = .inWork
        case .completed: emptyState = .completed
        }
    }
}
