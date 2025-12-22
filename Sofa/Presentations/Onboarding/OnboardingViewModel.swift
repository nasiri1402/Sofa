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

    private(set) var currentStage: OnboardingModel.Stage = .letsBegin
    private(set) var revealedStages: Set<OnboardingModel.Stage> = []
    var isPreviousEnabled = false
    var isNextEnabled = false
    var alertItem: AlertItem?
    private(set) var safariURL: URL?
    var isSafariPresented = false

    var name = ""

    var gender: Profile.Gender?

    var age: Int = .zero
    var ages: [Int] {
        var values = Array(14...50)
        if let index = values.firstIndex(of: 26) {
            values.insert(.zero, at: index)
        }
        return values
    }

    var country: OnboardingModel.Country?
    private(set) var countries = OnboardingModel.Country.allCases
    var countrySearchInput = "" {
        didSet {
            guard oldValue != countrySearchInput else { return }
            applyCountrySearchFilter()
        }
    }

    var source: OnboardingModel.Source?
    var otherSourceText = ""

    var isPrivacyRead = true

    private(set) var reviewTrigger = UUID()
    private(set) var isReviewing = false
    private(set) var isReviewRequested = false

    // MARK: - Private Properties

    private let dataStorage: DataStorage
    private let onFinish: () -> Void

    // MARK: - Inits

    init(dataStorage: DataStorage, onFinish: @escaping () -> Void) {
        self.dataStorage = dataStorage
        self.onFinish = onFinish
    }
}

// MARK: - Public Properties

extension OnboardingViewModel {

    // MARK: - Input

    func didTapBackButton() {
        switch currentStage {
        case .letsBegin, .name: break
        case .gender:
            previousStage(.name)
            gender = nil
            isPreviousEnabled = false
        case .age:
            previousStage(.gender)
            age = .zero
        case .country:
            previousStage(.age)
            country = nil
            countrySearchInput.removeAll()
        case .aboutUs:
            previousStage(.country)
            source = nil
        case .aboutUsOther:
            previousStage(.aboutUs)
            otherSourceText.removeAll()
        case .privacy:
            if !otherSourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                previousStage(.aboutUsOther)
            } else {
                previousStage(.aboutUs)
            }
            isPrivacyRead = true
        case .rateUs:
            previousStage(.privacy)
        case .letsAsk:
            if isReviewRequested {
                previousStage(.privacy)
            } else {
                previousStage(.rateUs)
            }
        }
    }

    func didTapContinueButton() {
        switch currentStage {
        case .letsBegin:
            nextStage(.name)
        case .name:
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else { return }
            name = trimmedName
            nextStage(.gender)
        case .gender:
            nextStage(.age)
        case .age:
            applyCountrySearchFilter()
            nextStage(.country)
        case .country:
            nextStage(.aboutUs)
            countrySearchInput.removeAll()
        case .aboutUs:
            guard source != nil else { return }
            if source == .other {
                nextStage(.aboutUsOther)
            } else {
                nextStage(.privacy)
            }
        case .aboutUsOther:
            let trimmedOther = otherSourceText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedOther.isEmpty else { return }
            nextStage(.privacy)
        case .privacy:
            if isReviewRequested {
                nextStage(.letsAsk)
            } else {
                nextStage(.rateUs)
            }
        case .rateUs:
            guard !isReviewing else { return }
            if isReviewRequested {
                nextStage(.letsAsk)
            } else {
                requestReview()
            }
        case .letsAsk:
            saveProfile()
        }
    }

    func didTapPrivacyLink(url: URL) {
        safariURL = url
        isSafariPresented = true
    }
}

// MARK: - Private Methods

extension OnboardingViewModel {
    private func nextStage(_ stage: OnboardingModel.Stage) {
        isPreviousEnabled = false
        isNextEnabled = false
        revealedStages.insert(currentStage)
        currentStage = stage
    }

    private func previousStage(_ stage: OnboardingModel.Stage) {
        isNextEnabled = true
        revealedStages.remove(currentStage)
        currentStage = stage
    }

    private func applyCountrySearchFilter() {
        let allCountries = OnboardingModel.Country.allCases
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
        isPreviousEnabled = false
        isNextEnabled = false
        reviewTrigger = UUID()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            isReviewing = false
            isPreviousEnabled = true
            isNextEnabled = true
        }
    }

    private func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let profile = Profile(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            age: age == .zero ? nil : age,
            gender: gender,
            country: {
                guard let country else { return nil }
                return Profile.Country(isoCode: country.isoCode, name: country.name)
            }(),
            currency: Profile.Currency(code: "USD")
        )
        Task { @MainActor in
            do {
                try dataStorage.saveProfile(profile)
                onFinish()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}
