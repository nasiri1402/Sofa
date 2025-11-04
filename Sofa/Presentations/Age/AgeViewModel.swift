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

    // MARK: - Output
}

// MARK: - Private Methods

extension AgeViewModel {
    private func fetchProfile() {
        Task { @MainActor in
            do {
                profile = try dataStorage.fetchProfile()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }
}
