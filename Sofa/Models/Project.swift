//
//  Project.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct Project: Identifiable {
    let id: UUID
    let prompt: String
    let summary: String
    let plans: [Plan]
    let createdAt: Date
    var updatedAt: Date
    var isCompleted: Bool {
        plans.allSatisfy(\.isCompleted)
    }
}

extension Project {

    // MARK: - Plan

    struct Plan: Identifiable, Hashable {
        let id: UUID
        let title: String
        let emoji: String
        let result: String
        let difficulty: Difficulty
        let steps: [Step]
        var progress: Double {
            guard !steps.isEmpty else { return .zero }
            let completedSteps = steps.filter(\.isCompleted)
            guard !completedSteps.isEmpty else { return .zero }
            let progress = Double(completedSteps.count) / Double(steps.count)
            return max(0, min(1, progress))
        }
        var isCompleted: Bool {
            steps.allSatisfy(\.isCompleted)
        }
    }
}

extension Project.Plan {

    // MARK: - Step

    struct Step: Identifiable, Hashable {
        let id: UUID
        let title: String
        var isCompleted: Bool
    }

    // MARK: - Difficulty

    enum Difficulty: Int, Hashable, CaseIterable {
        case easy, average, difficult

        var name: String {
            switch self {
            case .easy: String(localized: "easy")
            case .average: String(localized: "average")
            case .difficult: String(localized: "difficult")
            }
        }

        var color: ColorResource {
            switch self {
            case .easy: .green34C759
            case .average: .yellowFFCC00
            case .difficult: .redFF3B30
            }
        }
    }
}

// MARK: - Mocks

extension Project {
    static var mock: Project {
        Project(
            id: UUID(),
            prompt: "Launch a personal app",
            summary: "Roadmap to build and launch an iOS app.",
            plans: [
                Plan(
                    id: UUID(),
                    title: "Design & Branding",
                    emoji: "🎨",
                    result: "App identity, logo, and UI components ready",
                    difficulty: .easy,
                    steps: [
                        .init(id: UUID(), title: "Create color palette and typography", isCompleted: true),
                        .init(id: UUID(), title: "Design app icon and splash screen", isCompleted: false),
                        .init(id: UUID(), title: "Make UI kit in Figma", isCompleted: false)
                    ]
                ),
                Plan(
                    id: UUID(),
                    title: "Core App Development",
                    emoji: "💻",
                    result: "Functional MVP with core features",
                    difficulty: .average,
                    steps: [
                        .init(id: UUID(), title: "Implement SwiftData models", isCompleted: true),
                        .init(id: UUID(), title: "Add main UI modules", isCompleted: true),
                        .init(id: UUID(), title: "Integrate iCloud sync", isCompleted: false),
                        .init(id: UUID(), title: "Add notifications and background refresh", isCompleted: false)
                    ]
                ),
                Plan(
                    id: UUID(),
                    title: "App Store Launch",
                    emoji: "🚀",
                    result: "Live app available on App Store",
                    difficulty: .difficult,
                    steps: [
                        .init(id: UUID(), title: "Write App Store description and keywords", isCompleted: true),
                        .init(id: UUID(), title: "Prepare screenshots and preview video", isCompleted: false),
                        .init(id: UUID(), title: "Submit build and pass review", isCompleted: false)
                    ]
                )
            ],
            createdAt: Date().addingTimeInterval(-86400 * 10),
            updatedAt: Date()
        )
    }
}
