//
//  OnboardingViewModel.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class OnboardingViewModel {

    // MARK: - Public Properties

    private(set) var currentStage: OnboardingModel.Stage = .logo
    private(set) var reviewTrigger = UUID()
    private(set) var isPreviousEnabled = false
    private(set) var isNextEnabled = false
    private(set) var isLoading = false
    var nameInput = "" {
        didSet {
            guard oldValue != nameInput else { return }
            isNextEnabled = !nameInput.isEmpty
        }
    }

    // MARK: - Private Properties

    private let onFinish: () -> Void

    private var isReviewRequested = false

    // MARK: - Inits

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
}

// MARK: - Public Properties

extension OnboardingViewModel {

    // MARK: - Input

    func didTapBackButton() {
        previousStage()
    }

    func didFinishStage(_ stage: OnboardingModel.Stage) {
        switch stage {
        case .logo: nextStage()
        case .letsBegin, .name: isNextEnabled = true
        default: break
        }
    }

    func didTapContinueButton() {
        switch currentStage {
        case .logo: break
        case .letsBegin, .name, .gender, .age, .country, .aboutUs, .privacy, .letsAsk: nextStage()
        case .rateUs:
            if isReviewRequested {
                requestReview()
            } else {
                nextStage()
            }
        }
    }
}

// MARK: - Private Methods

extension OnboardingViewModel {
    private func nextStage() {
        isPreviousEnabled = false
        isNextEnabled = false
        currentStage = currentStage.next() ?? currentStage
    }

    private func previousStage() {
        currentStage = currentStage.previous() ?? currentStage
    }

    private func requestReview() {
        isReviewRequested = true
        isLoading = true
        reviewTrigger = UUID()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            isLoading = false
        }
    }
}
