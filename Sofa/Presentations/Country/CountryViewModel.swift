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

    private(set) var displayCountries: [Profile.Country] = []
    private(set) var selectedCountry: Profile.Country?
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
    private var countries: [Profile.Country] = []

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

    func didTapCountryButton(_ country: Profile.Country) {
        guard selectedCountry != country else { return }
        selectedCountry = country
    }

    func didTapSaveButton() {
        saveProfile()
    }
}

// MARK: - Private Methods

extension CountryViewModel {
    private func initialize() {
        fetchProfile()
        countries = Locale.Region.isoRegions.compactMap { region in
            guard let name = locale.localizedString(forRegionCode: region.identifier) else { return nil }
            return Profile.Country(isoCode: region.identifier, name: name)
        }.sorted { $0.name < $1.name }
        applySearchFilter()
    }

    private func fetchProfile() {
        Task { @MainActor in
            do {
                profile = try dataStorage.fetchProfile()
                selectedCountry = profile?.country
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func saveProfile() {
        guard let profile, let selectedCountry else { return }
        let updatedProfile = profile.copy(country: selectedCountry)
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
