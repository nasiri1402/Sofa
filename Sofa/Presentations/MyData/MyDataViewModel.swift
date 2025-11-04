//
//  MyDataViewModel.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class MyDataViewModel {

    // MARK: - Public Properties

    let fields = MyDataModel.Field.allCases
    private(set) var profile: Profile?
    var alertItem: AlertItem?

    // MARK: - Private Properties

    private let router: MyDataRouter
    private let dataStorage: DataStorage

    // MARK: - Inits

    init(router: MyDataRouter, dataStorage: DataStorage) {
        self.router = router
        self.dataStorage = dataStorage
    }
}

// MARK: - Public Properties

extension MyDataViewModel {

    // MARK: - Input

    func didTapNavigationBarLeadingButton() {
        router.back()
    }

    func didViewAppear() {
        fetchProfile()
    }

    func didTapFieldButton(_ field: MyDataModel.Field) {
        switch field {
        case .name: router.route(to: .name)
        case .gender: router.route(to: .gender)
        case .age: router.route(to: .age)
        case .country: router.route(to: .country)
        }
    }

    // MARK: - Output

    func getFieldDetails(_ field: MyDataModel.Field) -> String {
        guard let profile else { return "" }
        return switch field {
        case .name: profile.name
        case .gender: profile.gender.name
        case .age: String(format: String(localized: "yearsPluralFormat"), profile.age)
        case .country: profile.country.name
        }
    }
}

// MARK: - Private Methods

extension MyDataViewModel {
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
