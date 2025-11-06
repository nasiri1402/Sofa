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
    private(set) var finishedStages: Set<OnboardingModel.Stage> = []
    var isPreviousEnabled = false
    var isNextEnabled = false

    var name = ""

    var gender: Profile.Gender?
    let allGenders = Profile.Gender.allCases

    var age: Int = .zero
    var ages: [Int] {
        var values = Array(16...50)
        guard age == .zero else { return values }
        if let index = values.firstIndex(of: 26) {
            values.insert(.zero, at: index)
        }
        return values
    }

    var country: Profile.Country?
    private(set) var countries: [Profile.Country] = []
    var countrySearchInput = "" {
        didSet {
            guard oldValue != countrySearchInput else { return }
            applyCountrySearchFilter()
        }
    }

    var source: OnboardingModel.Source?
    let sources = OnboardingModel.Source.allCases
    var otherSourceText: String?

    private(set) var reviewTrigger = UUID()
    private(set) var isReviewing = false

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
        switch currentStage {
        case .gender:
            gender = nil
            isPreviousEnabled = false
            previousStage()
        case .age:
            age = .zero
            previousStage()
        case .country:
            country = nil
            countrySearchInput.removeAll()
            countries = []
            previousStage()
        case .aboutUs:
            source = nil
            otherSourceText = nil
            previousStage()
        default: break
        }
    }

    func didFinishStage() {
        switch currentStage {
        case .logo: nextStage()
        default: break
        }
    }

    func didTapContinueButton() {
        switch currentStage {
        case .logo: break
        case .letsBegin, .name, .gender, .country, .privacy, .letsAsk: nextStage()
        case .age:
            applyCountrySearchFilter()
            nextStage()
        case .aboutUs:
            if source == .other, otherSourceText == nil {
                otherSourceText = ""
            } else {
                nextStage()
            }
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
        finishedStages.insert(currentStage)
        currentStage = currentStage.next() ?? currentStage
    }

    private func previousStage() {
        isNextEnabled = true
        finishedStages.remove(currentStage)
        currentStage = currentStage.previous() ?? currentStage
    }

    private func applyCountrySearchFilter() {
        let allCountries: [Profile.Country] = Locale.Region.isoRegions.compactMap { region in
            guard let name = Locale.current.localizedString(forRegionCode: region.identifier) else { return nil }
            return Profile.Country(isoCode: region.identifier, name: name)
        }.sorted { $0.name < $1.name }
        guard !countrySearchInput.isEmpty else {
            countries = allCountries
            return
        }
        let query = countrySearchInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        countries = allCountries.filter { country in
            country.name.lowercased().contains(query) || country.isoCode.lowercased().contains(query)
        }
    }

    private func requestReview() {
        isReviewRequested = true
        isReviewing = true
        reviewTrigger = UUID()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            isReviewing = false
        }
    }
}
