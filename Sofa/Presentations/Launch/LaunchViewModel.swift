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

    @ObservationIgnored @AppStorage(SofaConstants.AppStorage.isProfileCreated)
    private var isProfileCreated = false
    @ObservationIgnored @AppStorage(SofaConstants.AppStorage.isBeforeLaunched)
    private var isBeforeLaunched = false

    // MARK: - Inits

    init(currentStage: LaunchModel.Stage = .splash) {
        self.currentStage = currentStage
    }

    // MARK: - Public Methods

    func didFinishStage(_ stage: LaunchModel.Stage) {
        switch stage {
        case .splash:
            currentStage = isBeforeLaunched ? .tabBar : isProfileCreated ? .brief : .onboarding
        case .onboarding:
            isProfileCreated = true
            currentStage = .brief
        case .brief:
            print("tut")
            isBeforeLaunched = true
            currentStage = .tabBar
        case .tabBar: break
        }
    }
}
