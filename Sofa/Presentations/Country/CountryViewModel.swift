//
//  CountryViewModel.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class CountryViewModel {

    // MARK: - Public Properties

    private(set) var displayCountries: [CountryModel.Country] = []
    private(set) var selectedCountry: CountryModel.Country?
    var searchInput = "" {
        didSet {
            guard oldValue != searchInput else { return }
            applySearchFilter()
        }
    }
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let router: CountryRouter
    private let dataStorage: DataStorage

    private let locale: Locale = .current

    private var profile: Profile?
    private let countries = CountryModel.Country.allCases

    // MARK: - Inits

    init(router: CountryRouter, dataStorage: DataStorage) {
        self.router = router
        self.dataStorage = dataStorage

        initialize()
    }
}

// MARK: - Public Properties

extension CountryViewModel {

    // MARK: - Input

    func didTapNavigationBarLeadingButton() {
        router.back()
    }

    func didTapCountryButton(_ country: CountryModel.Country) {
        selectedCountry = selectedCountry == country ? nil : country
    }

    func didTapSaveButton() {
        saveProfile()
    }
}

// MARK: - Private Methods

extension CountryViewModel {
    private func initialize() {
        fetchProfile()
        applySearchFilter()
    }

    private func fetchProfile() {
        Task { @MainActor in
            do {
                profile = try dataStorage.fetchProfile()
                selectedCountry = countries.first { $0.isoCode == profile?.country?.isoCode }
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func saveProfile() {
        guard let profile, let selectedCountry else { return }
        let country = Profile.Country(isoCode: selectedCountry.isoCode, name: selectedCountry.name)
        let updatedProfile = profile.copy(country: country)
        Task { @MainActor in
            do {
                try dataStorage.saveProfile(updatedProfile)
                router.back()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func applySearchFilter() {
        guard !searchInput.isEmpty else {
            displayCountries = countries
            return
        }
        let query = searchInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        displayCountries = countries.filter { country in
            country.name.lowercased().contains(query) || country.isoCode.lowercased().contains(query)
        }
    }
}
