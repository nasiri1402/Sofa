//
//  FunctionsClient.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import FirebaseAuth
import FirebaseFunctions
import Foundation

protocol FunctionsClient {
    func generator(request: GeneratorRequest) async throws -> GeneratorResponse
    func onboardingResponses(request: OnboardingResponsesRequest) async throws
}

final class DefaultFunctionsClient: FunctionsClient {

    // MARK: - Private Properties

    private lazy var functions: Functions = {
        Functions.functions(region: "us-central1")
    }()
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    private let decoder = JSONDecoder()

    // MARK: - Public Methods

    func generator(request: GeneratorRequest) async throws -> GeneratorResponse {
        let data = try await call(Function.generator, request: request)
        return try decoder.decode(GeneratorResponse.self, from: data)
    }

    func onboardingResponses(request: OnboardingResponsesRequest) async throws {
        try await call(Function.onboardingResponses, request: request)
    }

    // MARK: - Private Methods

    @discardableResult
    private func call<T: Encodable>(_ function: String, request: T) async throws -> Data {
        let request = try encoder.encode(request)
        let payload = try JSONSerialization.jsonObject(with: request)
        let call = try await functions.httpsCallable(function).call(payload)
        let data = try JSONSerialization.data(withJSONObject: call.data)
        #if DEBUG
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        debugPrint(jsonString)
        #endif
        return data
    }
}

// MARK: - Types

extension DefaultFunctionsClient {
    enum Function {
        static let generator = "generator"
        static let onboardingResponses = "onboardingResponses"
    }
}
