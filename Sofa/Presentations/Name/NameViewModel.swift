//
//  NameViewModel.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class NameViewModel {

    // MARK: - Public Properties

    var nameInput = ""
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let router: NameRouter
    private let dataStorage: DataStorage

    private var profile: Profile?

    // MARK: - Inits

    init(router: NameRouter, dataStorage: DataStorage) {
        self.router = router
        self.dataStorage = dataStorage

        fetchProfile()
    }
}

// MARK: - Public Properties

extension NameViewModel {

    // MARK: - Input

    func didTapBackButton() {
        router.back()
    }

    func didTapSaveButton() {
        saveProfile()
    }
}

// MARK: - Private Methods

extension NameViewModel {
    private func fetchProfile() {
        Task { @MainActor in
            do {
                profile = try dataStorage.fetchProfile()
                nameInput = profile?.name ?? ""
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func saveProfile() {
        guard let profile else { return }
        let updatedProfile = profile.copy(name: nameInput.trimmingCharacters(in: .whitespacesAndNewlines))
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
