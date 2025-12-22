//
//  GenderViewModel.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class GenderViewModel {

    // MARK: - Public Properties

    private(set) var profile: Profile?
    let genders = Profile.Gender.allCases
    private(set) var selectedGender: Profile.Gender?
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let router: GenderRouter
    private let dataStorage: DataStorage

    // MARK: - Inits

    init(router: GenderRouter, dataStorage: DataStorage) {
        self.router = router
        self.dataStorage = dataStorage

        fetchProfile()
    }
}

// MARK: - Public Properties

extension GenderViewModel {

    // MARK: - Input

    func didTapNavigationBarLeadingButton() {
        router.back()
    }

    func didTapGenderButton(_ gender: Profile.Gender) {
        selectedGender = selectedGender == gender ? nil : gender
    }

    func didTapSaveButton() {
        saveProfile()
    }
}

// MARK: - Private Methods

extension GenderViewModel {
    private func fetchProfile() {
        Task { @MainActor in
            do {
                profile = try dataStorage.fetchProfile()
                withAnimation(nil) {
                    selectedGender = profile?.gender
                }
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func saveProfile() {
        guard let profile, let selectedGender else { return }
        let updatedProfile = profile.copy(gender: selectedGender)
        Task { @MainActor in
            do {
                try dataStorage.saveProfile(updatedProfile)
                router.back()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}
