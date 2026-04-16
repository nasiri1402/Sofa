//
//  AuthService.swift
//  Sofa
//
//  Created by dukes on 11/14/25.
//

import FirebaseAuth
import Foundation

// MARK: - Interfaces

protocol AuthService {
    /// - Note: Можно вызвать при старте приложения
    func configure()

    /// Возвращает текущего пользователя, если есть.
    func currentUser() -> User?
}

// MARK: - Implementations

final class DefaultAuthService: AuthService {

    // MARK: - Private Properties

    private let analyticsManager: AnalyticsManager

    // MARK: - Inits

    init(analyticsManager: AnalyticsManager) {
        self.analyticsManager = analyticsManager
    }

    // MARK: - Public Methods

    func configure() {
        Task {
            await signInAnonymously()
        }
    }

    func currentUser() -> User? {
        Auth.auth().currentUser
    }

    // MARK: - Private Methods

    @MainActor @discardableResult
    func signInAnonymously() async -> User? {
        do {
            let result = try await Auth.auth().signInAnonymously()
            debugPrint("✅ anonymous login successful, uid =", result.user.uid)
            analyticsManager.identify(uid: result.user.uid)
            return result.user
        } catch {
            debugPrint("❌ anonymous login failed:", error.localizedDescription)
            return nil
        }
    }
}
