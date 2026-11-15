import Foundation

/// Shares one sign-in attempt between startup and callers, without changing an existing identity.
@MainActor
final class AuthenticationReadiness {
    private struct Flight {
        let id: UUID
        let task: Task<Void, Error>
    }

    private let isAuthenticated: () -> Bool
    private let signIn: () async throws -> Void
    private var flight: Flight?

    init(isAuthenticated: @escaping () -> Bool, signIn: @escaping () async throws -> Void) {
        self.isAuthenticated = isAuthenticated
        self.signIn = signIn
    }

    func ensureAuthenticated() async throws {
        try Task.checkCancellation()
        let currentFlight: Flight
        if let flight {
            currentFlight = flight
        } else if isAuthenticated() {
            return
        } else {
            currentFlight = Flight(id: UUID(), task: Task { try await signIn() })
            flight = currentFlight
        }

        // Cancelling a caller must not cancel a sign-in shared with another caller.
        defer {
            if flight?.id == currentFlight.id {
                flight = nil
            }
        }
        do {
            try await currentFlight.task.value
        } catch {
            try Task.checkCancellation()
            throw error
        }
        try Task.checkCancellation()
    }
}
