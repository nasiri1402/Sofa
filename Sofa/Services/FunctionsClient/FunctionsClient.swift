//
//  FunctionsClient.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import FirebaseFunctions
import FirebaseSharedSwift
import Foundation

protocol FunctionsClient {
    func generator(request: GeneratorRequest) async throws -> GeneratorResponse
    func converser(request: ConverserRequest) async throws -> ConverserResponse
    func chatter(request: ChatterRequest) async throws -> ChatterResponse
    func chatter(request: ChatterRequest) -> AsyncThrowingStream<ChatterResponse.StreamEvent, Error>
}

final class DefaultFunctionsClient: FunctionsClient {

    // MARK: - Private Properties

    private let authService: AuthService

    private lazy var functions: Functions = {
        Functions.functions(region: "us-central1")
    }()
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    private let streamEncoder: FirebaseDataEncoder = {
        let encoder = FirebaseDataEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    private let decoder = JSONDecoder()
    private let streamDecoder = FirebaseDataDecoder()

    init(authService: AuthService) {
        self.authService = authService
    }

    // MARK: - Public Methods

    func generator(request: GeneratorRequest) async throws -> GeneratorResponse {
        let data = try await call(Function.generator, request: request)
        return try decoder.decode(GeneratorResponse.self, from: data)
    }

    func converser(request: ConverserRequest) async throws -> ConverserResponse {
        let data = try await call(Function.converser, request: request)
        return try decoder.decode(ConverserResponse.self, from: data)
    }

    func chatter(request: ChatterRequest) async throws -> ChatterResponse {
        let data = try await call(Function.chatter, request: request)
        return try decoder.decode(ChatterResponse.self, from: data)
    }

    func chatter(request: ChatterRequest) -> AsyncThrowingStream<ChatterResponse.StreamEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await authService.ensureAuthenticated()
                    try Task.checkCancellation()
                    let callable: Callable<ChatterRequest, StreamResponse<ChatterResponse.StreamChunk, ChatterResponse>> = functions.httpsCallable(
                        Function.chatter,
                        encoder: streamEncoder,
                        decoder: streamDecoder
                    )
                    for try await response in try callable.stream(request) {
                        switch response {
                        case .message(let chunk):
                            continuation.yield(.delta(chunk.delta))
                        case .result(let result):
                            continuation.yield(.result(result))
                        }
                    }
                    continuation.finish()
                } catch {
                    if !(error is CancellationError), !(error is AuthenticationServiceError) {
                        ServiceDiagnostics.record(error, operation: .stream)
                    }
                    continuation.finish(throwing: mappedCallableError(error))
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    // MARK: - Private Methods

    @discardableResult
    private func call<T: Encodable>(_ function: String, request: T) async throws -> Data {
        try await authService.ensureAuthenticated()
        try Task.checkCancellation()
        let request = try encoder.encode(request)
        let payload = try JSONSerialization.jsonObject(with: request)

        do {
            let call = try await functions.httpsCallable(function).call(payload)
            let data = try JSONSerialization.data(withJSONObject: call.data)
            return data
        } catch {
            if !(error is CancellationError) {
                ServiceDiagnostics.record(error, operation: .callable)
            }
            throw mappedCallableError(error)
        }
    }

    private func mappedCallableError(_ error: Error) -> Error {
        let nsError = error as NSError
        if nsError.domain == "com.firebase.functions", nsError.code == 16 {
            return AuthenticationServiceError(underlying: error)
        }
        return error
    }
}

// MARK: - Types

extension DefaultFunctionsClient {
    enum Function {
        static let generator = "generator"
        static let converser = "converser"
        static let chatter = "chatter"
    }
}
