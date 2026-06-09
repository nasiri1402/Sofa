//
//  ServiceLayer.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation

enum ServiceLayer {

    // MARK: - Public Properties

    static let analyticsManager = AnalyticsManager()
    static let authService: AuthService = DefaultAuthService(analyticsManager: analyticsManager)
    static let appChecker: AppChecker = DefaultAppChecker()
    static let clipboard: Clipboard = DefaultClipboard()
    static let storeManager: StoreManager = DefaultStoreManager()
    static let networkMonitor: NetworkMonitor = DefaultNetworkMonitor()
    static let dataStorage: DataStorage = DefaultDataStorage()
    static let chatter: Chatter = DefaultChatter(functionsClient: functionsClient)
    static let remoteStorage: RemoteStorage = DefaultRemoteStorage(authService: authService)
    static let notificationManager: NotificationManager = DefaultNotificationManager()
    static let permissionManager: PermissionManager = DefaultPermissionManager()
    static let projectGenerator: ProjectGenerator = DefaultProjectGenerator(
        functionsClient: functionsClient,
        dataStorage: dataStorage
    )
    static let haptic: Haptic = DefaultHaptic()

    // MARK: - Private Properties

    private static let functionsClient: FunctionsClient = DefaultFunctionsClient()
}
