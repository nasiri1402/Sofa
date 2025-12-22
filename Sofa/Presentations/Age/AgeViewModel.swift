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

    var ages: [Int] {
        var values = Array(14...50)
        if let index = values.firstIndex(of: 26) {
            values.insert(.zero, at: index)
        }
        return values
    }
    var selectedAge: Int = .zero
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
                selectedAge = profile?.age ?? selectedAge
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func saveProfile() {
        guard let profile else { return }
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
