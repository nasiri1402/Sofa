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

    private let dataStorage: DataStorage

    // MARK: - Inits

    init(dataStorage: DataStorage) {
        self.dataStorage = dataStorage

        fetchProfile()
    }
}

// MARK: - Public Properties

extension MyDataViewModel {

    // MARK: - Input

    func didTapFieldButton(_ field: MyDataModel.Field) {
        // TODO: навигация к нужному экрану
    }

    // MARK: - Output

    func getFieldDetails(_ field: MyDataModel.Field) -> String {
        guard let profile else { return "" }
        return switch field {
        case .name: profile.name
        case .gender: profile.name + " (" + profile.gender.name + ")"
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
