//
//  AgeViewModel.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class AgeViewModel {

    // MARK: - Public Properties

    let ages = Array(14...50)
    private(set) var selectedAge: Int?
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let router: AgeRouter
    private let dataStorage: DataStorage

    private var profile: Profile?

    // MARK: - Inits

    init(router: AgeRouter, dataStorage: DataStorage) {
        self.router = router
        self.dataStorage = dataStorage

        fetchProfile()
    }
}

// MARK: - Public Properties

extension AgeViewModel {

    // MARK: - Input

    func didTapNavigationBarLeadingButton() {
        router.back()
    }

    func didTapAgeButton(_ age: Int) {
        guard selectedAge != age else { return }
        selectedAge = age
    }

    func didTapSaveButton() {
        saveProfile()
    }
}

// MARK: - Private Methods

extension AgeViewModel {
    private func fetchProfile() {
        Task { @MainActor in
            do {
                profile = try dataStorage.fetchProfile()
                selectedAge = profile?.age
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func saveProfile() {
        guard let profile, let selectedAge else { return }
        let updatedProfile = profile.copy(age: selectedAge)
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
