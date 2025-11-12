//
//  AppChecker.swift
//  Sofa
//
//  Created by dukes on 11/11/25.
//

import Firebase
import FirebaseAppCheck
import FirebaseCore

// MARK: - Interfaces

protocol AppChecker {
    func configure()
    func isTokenAutoRefreshEnabled(_ isEnabled: Bool)
}

// MARK: - Implementations

final class DefaultAppChecker: AppChecker {

    // MARK: - Public Methods

    func configure() {
        #if targetEnvironment(simulator)
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(ProviderFactory())
        #endif
    }

    func isTokenAutoRefreshEnabled(_ isEnabled: Bool) {
        AppCheck.appCheck().isTokenAutoRefreshEnabled = isEnabled
    }
}

// MARK: - ProviderFactory

extension DefaultAppChecker {
    final class ProviderFactory: NSObject, AppCheckProviderFactory {
        func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
            AppAttestProvider(app: app)
        }
    }
}
