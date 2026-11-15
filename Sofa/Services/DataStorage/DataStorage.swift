//
//  DataStorage.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import SwiftData

// MARK: - Errors

private enum DataStorageError: LocalizedError {
    case containerUnavailable

    var errorDescription: String? {
        String(localized: "The local data could not be opened. Please restart the app and try again.")
    }
}

// MARK: - Interfaces

protocol DataStorage {

    // MARK: - Project

    /// Получает список всех сохранённых проектов.
    ///
    /// - Returns: Массив объектов `Project`.
    /// - Throws: Ошибка, если чтение из хранилища не удалось.
    @MainActor
    func fetchProjects() throws -> [Project]

    /// Получает сохранённый проект.
    ///
    /// - Parameter id: Идентификатор проекта.
    /// - Returns: Обьект `Project`.
    /// - Throws: Ошибка, если чтение из хранилища не удалось.
    @MainActor
    func fetchProject(id: UUID) throws -> Project?

    /// Сохраняет проект.
    ///
    /// - Parameter project: Проект для сохранения.
    /// - Throws: Ошибка, если сохранение не удалось.
    /// - Warning: Если проект с таким идентификатором уже существует — он будет перезаписан
    @MainActor
    func saveProject(_ project: Project) throws

    /// Удаляет проект по его идентификатору.
    ///
    /// - Parameter project: Проект для удаления.
    /// - Throws: Ошибка, если удаление не удалось.
    @MainActor
    func deleteProject(_ project: Project) throws

    // MARK: - Profile

    /// Получает профиль пользователя.
    ///
    /// - Returns: Обьект `Profile`.
    /// - Throws: Ошибка, если чтение из хранилища не удалось.
    @MainActor
    func fetchProfile() throws -> Profile?

    /// Сохраняет профиль пользователя.
    ///
    /// - Parameter profile: Профиль для сохранения.
    /// - Throws: Ошибка, если сохранение не удалось.
    /// - Warning: Если профиль с таким идентификатором уже существует — он будет перезаписан
    @MainActor
    func saveProfile(_ profile: Profile) throws
}

// MARK: - Implementations

final class DefaultDataStorage: DataStorage {

    // MARK: - Private Properties

    private let container: ModelContainer?
    private let initializationError: Error?

    // MARK: - Inits

    init() {
        let schema = Schema([
            ProfileEntity.self,
            ProjectEntity.self,
            BriefEntity.self,
            PlanEntity.self,
            ChatEntity.self,
            ConversationEntity.self,
            MessageEntity.self,
            WeekEntity.self,
            StepEntity.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.initializationError = nil
        } catch {
            self.container = nil
            self.initializationError = error
            debugPrint("Failed to open SwiftData container:", error.localizedDescription)
        }
    }

    // MARK: - Public Methods

    @MainActor
    func fetchProjects() throws -> [Project] {
        let context = try mainContext()
        let descriptor = FetchDescriptor<ProjectEntity>(
            // Сортировка по убыванию
            sortBy: [.init(\.createdAt, order: .reverse)]
        )
        let projects = try context.fetch(descriptor)
        return projects.map { $0.toProject() }
    }

    @MainActor
    func fetchProject(id: UUID) throws -> Project? {
        let context = try mainContext()
        let descriptor = FetchDescriptor<ProjectEntity>(
            predicate: #Predicate { $0.id == id },
            sortBy: []
        )
        let projects = try context.fetch(descriptor)
        return projects.map { $0.toProject() }.first
    }

    @MainActor
    func saveProject(_ project: Project) throws {
        let context = try mainContext()
        let descriptor = FetchDescriptor<ProjectEntity>(sortBy: [])
        if let existingProject = try context.fetch(descriptor).first(where: { $0.id == project.id }) {
            // Если проект найден, то удаляем его
            context.delete(existingProject)
        }
        context.insert(ProjectEntity(from: project))
        try context.save()
    }

    @MainActor
    func deleteProject(_ project: Project) throws {
        let context = try mainContext()
        let descriptor = FetchDescriptor<ProjectEntity>(sortBy: [])
        guard let project = try context.fetch(descriptor).first(where: { $0.id == project.id }) else {
            return
        }
        context.delete(project)
        try context.save()
    }

    @MainActor
    func fetchProfile() throws -> Profile? {
        let context = try mainContext()
        let descriptor = FetchDescriptor<ProfileEntity>(sortBy: [])
        let profiles = try context.fetch(descriptor)
        return profiles.map { $0.toProfile() }.first
    }

    @MainActor
    func saveProfile(_ profile: Profile) throws {
        let context = try mainContext()
        let descriptor = FetchDescriptor<ProfileEntity>(sortBy: [])
        if let existingProfile = try context.fetch(descriptor).first(where: { $0.id == profile.id }) {
            // Если рингтон найден, то удаляем его
            context.delete(existingProfile)
        }
        context.insert(ProfileEntity(from: profile))
        try context.save()
    }

    // MARK: - Private Methods

    @MainActor
    private func mainContext() throws -> ModelContext {
        guard let container else {
            throw initializationError ?? DataStorageError.containerUnavailable
        }
        return container.mainContext
    }
}
