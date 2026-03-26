//
//  Project.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct Project: Identifiable {
    let id: UUID
    let brief: Brief
    let summary: String
    var plans: [Plan]
    var hasLifetimeAccess: Bool
    let createdAt: Date
    var updatedAt: Date
    var isCompleted: Bool {
        plans.allSatisfy(\.isCompleted)
    }
}

extension Project {

    // MARK: - Brief

    struct Brief: Identifiable, Hashable {
        let id: UUID
        let idea: String
        let timeframe: Timeframe
        let experience: Experience
        let startPoint: String
        let result: Result
        let budget: Int?
        let limits: String

        func copy(id: UUID) -> Brief {
            Brief(
                id: id,
                idea: idea,
                timeframe: timeframe,
                experience: experience,
                startPoint: startPoint,
                result: result,
                budget: budget,
                limits: limits
            )
        }
    }

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
        let createdAt: Date
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

        func copy(id: UUID) -> Plan {
            Project.Plan(
                id: id,
                title: title,
                emoji: emoji,
                firstResults: firstResults,
                budget: budget,
                result: result,
                difficulty: difficulty,
                weeks: weeks,
                isFavorite: isFavorite,
                createdAt: createdAt
            )
        }
    }
}

extension Project.Brief {

    // MARK: - Timeframe

    enum Timeframe: Int, CaseIterable, Equatable {
        case month1, month3, month6

        var name: String {
            switch self {
            case .month1: String(format: String(localized: "monthsPluralFormat"), 1)
            case .month3: String(format: String(localized: "monthsPluralFormat"), 3)
            case .month6: String(format: String(localized: "monthsPluralFormat"), 6)
            }
        }
    }

    // MARK: - Experience

    enum Experience: Int, CaseIterable, Hashable {
        case beginner, intermediate, expert

        var name: String {
            switch self {
            case .beginner: String(localized: "beginner")
            case .intermediate: String(localized: "intermediate")
            case .expert: String(localized: "expert")
            }
        }
    }

    // MARK: - Result

    struct Result: Hashable {
        let goals: Set<Goal>
        let money: Int?
        let subscribers: Int?
        let option: String?
    }

    // MARK: - Goal

    enum Goal: Int, CaseIterable, Hashable {
        case money, subscribers, clients, cases, experience, option

        var name: String {
            switch self {
            case .money: String(localized: "money")
            case .subscribers: String(localized: "subscribers")
            case .clients: String(localized: "clients")
            case .cases: String(localized: "cases")
            case .experience: String(localized: "experience")
            case .option: String(localized: "yourOption")
            }
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
        let number: Int
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
        brief: Brief(
            id: UUID(),
            idea: "idea",
            timeframe: .month1,
            experience: .expert,
            startPoint: "start point",
            result: Brief.Result(goals: [.money, .clients], money: 100, subscribers: nil, option: nil),
            budget: 1000,
            limits: "limits"
        ),
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
                                number: 1,
                                isCompleted: true
                            ),
                            .init(
                                id: UUID(),
                                title: "Design app icon",
                                number: 2,
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
                                number: 1,
                                isCompleted: false
                            ),
                            .init(
                                id: UUID(),
                                title: "Design splash screen",
                                number: 2,
                                isCompleted: false
                            )
                        ]
                    )
                ],
                isFavorite: false,
                createdAt: .now
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
                                number: 1,
                                isCompleted: true
                            ),
                            .init(
                                id: UUID(),
                                title: "Add main UI modules",
                                number: 2,
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
                                number: 0,
                                isCompleted: false
                            ),
                            .init(
                                id: UUID(),
                                title: "Add notifications and background refresh",
                                number: 1,
                                isCompleted: false
                            )
                        ]
                    )
                ],
                isFavorite: true,
                createdAt: .now
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
                                number: 1,
                                isCompleted: true
                            ),
                            .init(
                                id: UUID(),
                                title: "Prepare keywords and metadata",
                                number: 2,
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
                                number: 1,
                                isCompleted: false
                            ),
                            .init(
                                id: UUID(),
                                title: "Submit build and pass review",
                                number: 2,
                                isCompleted: false
                            )
                        ]
                    )
                ],
                isFavorite: true,
                createdAt: .now
            )
        ],
        hasLifetimeAccess: false,
        createdAt: Date().addingTimeInterval(-86400 * 10),
        updatedAt: Date()
    )
}
