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
        let call = try await functions.httpsCallable(Function.generator).call(payload)
        let data = try JSONSerialization.data(withJSONObject: call.data)
        #if DEBUG
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        debugPrint(jsonString)
        #endif
        let response = try decoder.decode(GeneratorResponse.self, from: data)
        return response
    }
}

// MARK: - Types

extension DefaultFunctionsClient {
    enum Function {
        static let generator = "generator"
    }
}
