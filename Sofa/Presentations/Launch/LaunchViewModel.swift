//
//  LaunchViewModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class LaunchViewModel {

    // MARK: - Public Properties

    private(set) var currentStage: LaunchModel.Stage

    // MARK: - Private Properties

    @ObservationIgnored @AppStorage(SofaConstants.AppStorage.isBeforeLaunched)
    private var isBeforeLaunched = false
    private var isProductsUpdated = false

    // MARK: - Inits

    init(currentStage: LaunchModel.Stage = .splash) {
        self.currentStage = currentStage
    }

    // MARK: - Public Methods

    func didFinishStage(_ stage: LaunchModel.Stage) {
        currentStage = switch stage {
        case .splash: isBeforeLaunched ? .tabBar : .onboarding
        case .onboarding: .tabBar
        case .tabBar: currentStage
        }
    }
}
