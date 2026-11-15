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

    @MainActor func ensureAuthenticated() async throws
}

// MARK: - Implementations

final class DefaultAuthService: AuthService {

    // MARK: - Private Properties

    private let analyticsManager: AnalyticsManager

    @MainActor private var identifiedUserID: String?

    @MainActor private lazy var readiness = AuthenticationReadiness(
        isAuthenticated: { Auth.auth().currentUser != nil },
        signIn: {
            _ = try await Auth.auth().signInAnonymously()
        }
    )

    // MARK: - Inits

    init(analyticsManager: AnalyticsManager) {
        self.analyticsManager = analyticsManager
    }

    // MARK: - Public Methods

    func configure() {
        Task { @MainActor in
            do {
                try await ensureAuthenticated()
            } catch {
                // Requests await the same readiness and present a recoverable error.
            }
        }
    }

    func currentUser() -> User? {
        Auth.auth().currentUser
    }

    @MainActor
    func ensureAuthenticated() async throws {
        do {
            try await readiness.ensureAuthenticated()
            if let user = Auth.auth().currentUser, identifiedUserID != user.uid {
                analyticsManager.identify(uid: user.uid)
                identifiedUserID = user.uid
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            ServiceDiagnostics.record(error, operation: .authentication)
            throw AuthenticationServiceError(underlying: error)
        }
    }
}
