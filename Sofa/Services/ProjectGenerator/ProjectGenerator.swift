//
//  ProjectGenerator.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import Foundation

// MARK: - Interfaces

protocol ProjectGenerator {
    @discardableResult
    func generate(brief: Project.Brief) async throws -> Project
}

// MARK: - Implementations

final class DefaultProjectGenerator: ProjectGenerator {

    // MARK: - Private Properties

    private let functionsClient: FunctionsClient
    private let dataStorage: DataStorage

    // MARK: - Inits

    init(functionsClient: FunctionsClient, dataStorage: DataStorage) {
        self.functionsClient = functionsClient
        self.dataStorage = dataStorage
    }

    // MARK: - Public Methods

    @discardableResult
    func generate(brief: Project.Brief) async throws -> Project {
        try await Task.sleep(for: .seconds(5))
        let project: Project = .mock
        try dataStorage.saveProject(project)
        return project
    }
}
