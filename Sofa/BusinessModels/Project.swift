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
    var plans: [Plan]
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
        let firstResults: String
        let budget: Int
        let result: String
        let difficulty: Difficulty
        var weeks: [Week]
        var isFavorite: Bool
        var allSteps: [Step] {
            weeks.flatMap(\.steps)
        }
        var progress: Double {
            guard !allSteps.isEmpty else { return .zero }
            let completedSteps = allSteps.filter(\.isCompleted)
            let ratio = Double(completedSteps.count) / Double(allSteps.count)
            return max(0, min(1, ratio))
        }
        var isCompleted: Bool {
            weeks.allSatisfy(\.isCompleted)
        }
    }
}

extension Project.Plan {

    // MARK: - Week

    struct Week: Identifiable, Hashable {
        let id: UUID
        let number: Int
        var steps: [Step]
        var isCompleted: Bool {
            steps.allSatisfy(\.isCompleted)
        }
    }

    // MARK: - Step

    struct Step: Identifiable, Hashable {
        let id: UUID
        let title: String
        let index: Int
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
    static let mock = Project(
        id: UUID(),
        prompt: "Launch a personal app",
        summary: "Roadmap to build and launch an iOS app.",
        plans: [
            Plan(
                id: UUID(),
                title: "Design & Branding",
                emoji: "🎨",
                firstResults: "3–4 weeks",
                budget: 1000,
                result: "App identity, logo, and UI components ready",
                difficulty: .easy,
                weeks: [
                    .init(
                        id: UUID(),
                        number: 1,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Create color palette and typography",
                                index: 1,
                                isCompleted: true
                            ),
                            .init(
                                id: UUID(),
                                title: "Design app icon",
                                index: 2,
                                isCompleted: false
                            )
                        ]
                    ),
                    .init(
                        id: UUID(),
                        number: 2,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Build UI kit in Figma",
                                index: 1,
                                isCompleted: false
                            ),
                            .init(
                                id: UUID(),
                                title: "Design splash screen",
                                index: 2,
                                isCompleted: false
                            )
                        ]
                    )
                ],
                isFavorite: false
            ),
            Plan(
                id: UUID(),
                title: "Core App Development",
                emoji: "💻",
                firstResults: "2–3 weeks",
                budget: 2000,
                result: "Functional MVP with core features",
                difficulty: .average,
                weeks: [
                    .init(
                        id: UUID(),
                        number: 1,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Implement SwiftData models",
                                index: 1,
                                isCompleted: true
                            ),
                            .init(
                                id: UUID(),
                                title: "Add main UI modules",
                                index: 2,
                                isCompleted: true
                            )
                        ]
                    ),
                    .init(
                        id: UUID(),
                        number: 2,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Integrate iCloud sync",
                                index: 0,
                                isCompleted: false
                            ),
                            .init(
                                id: UUID(),
                                title: "Add notifications and background refresh",
                                index: 1,
                                isCompleted: false
                            )
                        ]
                    )
                ],
                isFavorite: true
            ),
            Plan(
                id: UUID(),
                title: "App Store Launch",
                emoji: "🚀",
                firstResults: "2–4 weeks",
                budget: 5000,
                result: "Live app available on App Store",
                difficulty: .difficult,
                weeks: [
                    .init(
                        id: UUID(),
                        number: 1,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Write App Store description",
                                index: 1,
                                isCompleted: true
                            ),
                            .init(
                                id: UUID(),
                                title: "Prepare keywords and metadata",
                                index: 2,
                                isCompleted: false
                            )
                        ]
                    ),
                    .init(
                        id: UUID(),
                        number: 2,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Prepare screenshots and preview video",
                                index: 1,
                                isCompleted: false
                            ),
                            .init(
                                id: UUID(),
                                title: "Submit build and pass review",
                                index: 2,
                                isCompleted: false
                            )
                        ]
                    )
                ],
                isFavorite: true
            )
        ],
        createdAt: Date().addingTimeInterval(-86400 * 10),
        updatedAt: Date()
    )
}
