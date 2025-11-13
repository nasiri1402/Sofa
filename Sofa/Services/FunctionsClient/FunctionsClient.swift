//
//  FunctionsClient.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import FirebaseFunctions
import Foundation

protocol FunctionsClient {
    func generator(request: GeneratorRequest) async throws -> GeneratorResponse
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
        let request = try encoder.encode(request)
        let payload = try JSONSerialization.jsonObject(with: request)
        let response = try await functions.httpsCallable(Function.generator).call(payload)
        let result = try JSONSerialization.data(withJSONObject: response.data)
        return try decoder.decode(GeneratorResponse.self, from: result)
    }
}

// MARK: - Types

extension DefaultFunctionsClient {
    enum Function {
        static let generator = "generator"
    }
}
