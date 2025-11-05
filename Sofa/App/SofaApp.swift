//
//  SofaApp.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

@main
struct SofaApp: App {

    // MARK: - Private Properties

    @UIApplicationDelegateAdaptor(SofaAppDelegate.self) private var delegate

    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            LaunchView(viewModel: LaunchViewModel(currentStage: .splash))
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - UIApplicationDelegate

final class SofaAppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Private Properties

    private let analyticsManager = ServiceLayer.analyticsManager
    private let storeManager = ServiceLayer.storeManager
    private let networkMonitor = ServiceLayer.networkMonitor

    // MARK: - Public Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // TODO: Конфигурировать фаербейс и аналитику
//        FirebaseApp.configure()
        storeManager.configure()
//        analyticsManager.configure()
        networkMonitor.startMonitoring()

//        Task { @MainActor in
//            try ServiceLayer.dataStorage.saveProject(.mock)
//        }
        return true
    }
}
