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

    func didChangeNameInput(_ newValue: String) {
        let scalars = newValue.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        let letters = String(scalars.map(Character.init))
        guard letters != newValue else { return }
        nameInput = letters
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
        let name = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let profile, !name.isEmpty else { return }
        let updatedProfile = profile.copy(name: name)
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
