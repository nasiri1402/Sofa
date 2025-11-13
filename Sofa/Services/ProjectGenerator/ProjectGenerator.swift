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

// MARK: - Errors

enum ProjectGeneratorError: LocalizedError {
    case failedToEncodeData

    var errorDescription: String? {
        switch self {
        case .failedToEncodeData:
            String(localized: "projectGeneratorErrorFailedToEncodeData")
        }
    }
}

// MARK: - Implementations

final class DefaultProjectGenerator: ProjectGenerator {

    // MARK: - Private Properties

    private let functionsClient: FunctionsClient
    private let dataStorage: DataStorage

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    private let calendar: Calendar = .current

    // MARK: - Inits

    init(
        functionsClient: FunctionsClient,
        dataStorage: DataStorage
    ) {
        self.functionsClient = functionsClient
        self.dataStorage = dataStorage
    }

    // MARK: - Public Methods

    @discardableResult
    func generate(brief: Project.Brief) async throws -> Project {
        let systemContent = makeSystemContent()
        let userContent = try await makeUserContent(brief: brief)
        let request = GeneratorRequest(
            messages: [
                GeneratorRequest.Message(
                    role: .system,
                    content: [GeneratorRequest.Message.Content(type: .text, text: systemContent)]
                ),
                GeneratorRequest.Message(
                    role: .user,
                    content: [GeneratorRequest.Message.Content(type: .text, text: userContent)]
                )
            ]
        )
        let response = try await functionsClient.generator(request: request)
        let project = makeProject(brief: brief, from: response)
        try dataStorage.saveProject(project)
        return project
    }

    // MARK: - Private Methods

    private func makeSystemContent() -> String {
        // swiftlint:disable line_length
        """
        You are a plan generator for personal growth, content strategy development, and achieving the user's goals through the practical realization of their idea.
        Your task:
        - Process the provided structured JSON input.
        - Use the input strictly as context for generating the final JSON response.
        - Produce 3 development plans (easy, medium, hard), each as a practical, step-by-step strategy.
        
        Input format JSON:
        {
          "profile": {
            "name": "<string, user's name>",
            "age": "<integer, user's age>",
            "gender": "<string: 'male' | 'female' | 'other'>",
            "country_code": "<string, ISO 3166-1 alpha-2 code>",
            "currency_code": "<string, ISO 4217 currency code (e.g. 'USD', 'EUR')>"
          },
          "brief": {
            "idea": "<string, description of user’s main idea or direction>",
            "timeframe": "<string, one of: '1_month' | '3_months' | '6_months' | '12_months'>",
            "experience": "<string, one of: 'beginner' | 'intermediate' | 'expert'>",
            "start_point": "<string, description of user’s current starting position>",
            "result": {
              "goals": ["money", "subscribers", "clients", "cases", "experience", "option"],
              "money": "<integer, optional — ONLY if 'money' exists in `goals`>",
              "subscribers": "<integer, optional — ONLY if 'subscribers' exists in `goals`>",
              "option": "<string, optional — ONLY if 'option' exists in `goals`>"
            },
            "budget": "<integer, optional — ONLY if the user has provided a starting budget>",
            "limits": "<string, user’s constraints, preferences, requirements, or any specific conditions>"
          },
          "response_language_code": "<string, BCP 47 language code for the output (e.g. 'ru-RU' | 'en-US')>"
        }
        
        Output format JSON:
        {
          "summary": "<string, high-level summary of idea and strategy>",
          "plans": [
            {
              "title": "<string, plan name>",
              "emoji": "<string, 1 emoji representing the plan>",
              "first_results": "<string, timeframe until first noticeable results (e.g. 'in 5 days', 'in 1 week', 'on week 2', 'on 3–4 week')>",
              "budget": <integer, approximate budget required to execute this plan>,
              "result": "<string, short description of the final outcome the user is expected to achieve by completing the plan>",
              "difficulty": <integer: 1=easy, 2=medium, 3=hard>,
              "weeks": [
                {
                  "number": <integer, week index starting from 1>,
                  "steps": [
                    {
                      "title": "<string, step description>",
                      "number": <integer, order number starting from 1>
                    }
                  ]
                }
              ]
            }
          ]
        }
        
        Strict rules:
        - Return ONLY the final JSON object. No explanations, no reasoning, no meta-text.
        - Always generate exactly 3 plans in increasing difficulty (easy → medium → hard).
        - Each plan must be a concrete, practical steps. Steps must be specific actions, not abstract advice.
        - Use `brief.timeframe` to scale plan length and intensity.
        - Number of weeks must approximately match `timeframe`:
          1_month → 4–5 weeks,
          3_months → 12–14 weeks,
          6_months → 24–28 weeks,
          12_months → 48–52 weeks.
        - Use `brief.experience` to adapt complexity of steps.
        - Use `brief.result.goals` to prioritize plan direction.
        - If goal is related to money, subscribers — estimate numeric outcomes.
        - Respect user limits (e.g., “online only”, “budget = $1000”, “focus on social media”).
        - Do NOT invent additional user goals beyond those in `brief`.
        - If budget exists, plan must include recommended allocation.
        - Use `profile` to keep plans, examples, tone, and recommendations relevant to the user’s demographic and local context.
        - Do NOT include profile data in the output JSON.
        - Do NOT include content outside the defined JSON structure.
        """
        // swiftlint:enable line_length
    }

    private func makeUserContent(brief: Project.Brief) async throws -> String {
        let profile = try dataStorage.fetchProfile()
        let userContent = UserContent(
            profile: UserContent.Profile(
                name: profile?.name ?? "",
                age: profile?.age == 50 ? "50+" : profile?.age.description ?? "",
                gender: {
                    switch profile?.gender {
                    case .male: "male"
                    case .female: "female"
                    case .other: "other"
                    case .none: ""
                    }
                }(),
                countryCode: profile?.country.isoCode ?? "",
                currencyCode: profile?.currency.code ?? ""
            ),
            brief: UserContent.Brief(
                idea: brief.idea,
                timeframe: {
                    switch brief.timeframe {
                    case .month1: "1_month"
                    case .month3: "3_months"
                    case .month6: "6_months"
                    case .month12: "12_months"
                    }
                }(),
                experience: {
                    switch brief.experience {
                    case .beginner: "beginner"
                    case .intermediate: "intermediate"
                    case .expert: "expert"
                    }
                }(),
                startPoint: brief.startPoint,
                result: UserContent.Result(
                    goals: brief.result.goals.map {
                        switch $0 {
                        case .money: "money"
                        case .subscribers: "subscribers"
                        case .clients: "clients"
                        case .cases: "cases"
                        case .experience: "experience"
                        case .option: "option"
                        }
                    },
                    money: brief.result.money?.description,
                    subscribers: brief.result.subscribers?.description,
                    option: brief.result.option?.description
                ),
                budget: brief.budget,
                limits: brief.limits
            ),
            responseLanguageCode: Locale.current.identifier
        )
        let data = try encoder.encode(userContent)

        guard let content = String(data: data, encoding: .utf8) else {
            throw ProjectGeneratorError.failedToEncodeData
        }
        return content
    }

    private func makeProject(brief: Project.Brief, from response: GeneratorResponse) -> Project {
        Project(
            id: UUID(),
            brief: brief,
            summary: response.summary,
            plans: response.plans.map {
                Project.Plan(
                    id: UUID(),
                    title: $0.title,
                    emoji: $0.emoji,
                    firstResults: $0.firstResults,
                    budget: $0.budget,
                    result: $0.result,
                    difficulty: Project.Plan.Difficulty(rawValue: $0.difficulty) ?? .easy,
                    weeks: $0.weeks.sorted { $0.number < $1.number }.map {
                        Project.Plan.Week(
                            id: UUID(),
                            number: $0.number,
                            steps: $0.steps.sorted { $0.number < $1.number }.map {
                                Project.Plan.Step(
                                    id: UUID(),
                                    title: $0.title,
                                    number: $0.number,
                                    isCompleted: false
                                )
                            }
                        )
                    },
                    isFavorite: false
                )
            },
            createdAt: .now,
            updatedAt: .now
        )
    }
}

// MARK: - UserContent

extension DefaultProjectGenerator {
    struct UserContent: Encodable {
        let profile: Profile
        let brief: Brief
        let responseLanguageCode: String

        struct Profile: Encodable {
            let name: String
            let age: String
            let gender: String
            let countryCode: String
            let currencyCode: String
        }

        struct Brief: Encodable {
            let idea: String
            let timeframe: String
            let experience: String
            let startPoint: String
            let result: Result
            let budget: Int?
            let limits: String
        }

        struct Result: Encodable {
            let goals: [String]
            let money: String?
            let subscribers: String?
            let option: String?
        }
    }
}
