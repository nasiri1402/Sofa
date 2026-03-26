//
//  ServiceLayer.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation

enum ServiceLayer {

    // MARK: - Public Properties

    static let authService: AuthService = DefaultAuthService()
    static let appChecker: AppChecker = DefaultAppChecker()
    static let analyticsManager = AnalyticsManager()
    static let storeManager: StoreManager = DefaultStoreManager()
    static let networkMonitor: NetworkMonitor = DefaultNetworkMonitor()
    static let dataStorage: DataStorage = DefaultDataStorage()
    static let notificationManager: NotificationManager = DefaultNotificationManager()
    static let permissionManager: PermissionManager = DefaultPermissionManager()
    static let projectGenerator: ProjectGenerator = DefaultProjectGenerator(
        functionsClient: functionsClient,
        dataStorage: dataStorage
    )

    // MARK: - Private Properties

    private static let functionsClient: FunctionsClient = DefaultFunctionsClient()
}
