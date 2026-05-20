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
    func converser(request: ConverserRequest) async throws -> ConverserResponse
    func chatter(request: ChatterRequest) async throws -> ChatterResponse
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

    func converser(request: ConverserRequest) async throws -> ConverserResponse {
        let data = try await call(Function.converser, request: request)
        return try decoder.decode(ConverserResponse.self, from: data)
    }

    func chatter(request: ChatterRequest) async throws -> ChatterResponse {
        let data = try await call(Function.chatter, request: request)
        return try decoder.decode(ChatterResponse.self, from: data)
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
        static let converser = "converser"
        static let chatter = "chatter"
    }
}
