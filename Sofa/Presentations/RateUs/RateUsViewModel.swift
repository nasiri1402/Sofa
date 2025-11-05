//
//  RateUsViewModel.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class RateUsViewModel {

    // MARK: - Public Properties

    private(set) var isLoading = false

    // MARK: - Private Properties

    private let router: RateUsRouter

    private var isReviewRequested = false

    // MARK: - Inits

    init(router: RateUsRouter) {
        self.router = router
    }
}

// MARK: - Public Properties

extension RateUsViewModel {

    // MARK: - Input

    func didTapBackButton() {
        router.back()
    }

    func didTapRateButton() {
        guard !isReviewRequested else { return }
        isReviewRequested = true
        isLoading = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            isLoading = false
        }
    }
}
