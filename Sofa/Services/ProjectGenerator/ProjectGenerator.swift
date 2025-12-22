//
//  ProjectGenerator.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import Foundation

// MARK: - Interfaces

protocol ProjectGenerator {
    func generate(brief: Project.Brief, difficulty: Project.Plan.Difficulty) async throws -> Project
}

// MARK: - Errors

enum ProjectGeneratorError: LocalizedError {
    case failedToEncodeData
    case failedToDecodeData

    var errorDescription: String? {
        switch self {
        case .failedToEncodeData:
            String(localized: "projectGeneratorErrorFailedToEncodeData")
        case .failedToDecodeData:
            String(localized: "projectGeneratorErrorFailedToDecodeData")
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

    func generate(brief: Project.Brief, difficulty: Project.Plan.Difficulty) async throws -> Project {
        let systemContent = makeSystemContent()
        let userContent = try await makeUserContent(brief: brief, difficulty: difficulty)
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
        let response = try await generate(request: request)
        let project = try makeProject(brief: brief, difficulty: difficulty, from: response)
        return project
    }

    // MARK: - Private Methods

    private func generate(request: GeneratorRequest) async throws -> GeneratorResponse {
        do {
            return try await functionsClient.generator(request: request)
        } catch {
            throw ProjectGeneratorError.failedToDecodeData
        }
    }

    private func makeSystemContent() -> String {
        // swiftlint:disable line_length
        """
        You are a plan generator for personal growth, content strategy development, and achieving the user's goals through the practical realization of their idea.
        Your task:
        - Process the provided structured JSON input.
        - Use the input strictly as context for generating the final JSON response.
        - Develop 1 development plan as a practical step-by-step strategy.
        
        Input format JSON:
        {
          "profile": {
            "name": "<string, user's name>",
            "age": "<integer, optional — user's age, may be omitted>",
            "gender": "<string, optional — 'male' | 'female' | 'other', may be omitted>",
            "country_code": "<string, optional — ISO 3166-1 alpha-2 code, may be omitted>",
            "currency_code": "<string, optional — ISO 4217 currency code (e.g. 'USD', 'EUR')>"
          },
          "brief": {
            "idea": "<string, description of user’s main idea or direction>",
            "timeframe": "<string, one of: '1_month' | '3_months' | '6_months'",
            "experience": "<string, one of: 'beginner' | 'intermediate' | 'expert'>",
            "difficulty": "<string, one of: 'easy' | 'medium' | 'hard'>",
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
          "summary": "<string, personalized high-level description of idea>",
          "plan": {
            "title": "<string, plan name>",
            "emoji": "<string, 1 emoji representing the plan>",
            "first_results": "<string, timeframe until first noticeable results (e.g. 'in 5 days', 'in 1 week', 'on week 2', 'on 3–4 week')>",
            "budget": <integer, approximate budget required to execute this plan>,
            "result": "<string, short description of the final outcome the user is expected to achieve by completing the plan>",
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
        }
        
        STRICT RULES:
        - Return ONLY the final JSON object. No explanations or meta-text.
        - `summary` must describe ONLY the goal + timeframe (no steps, no strategy, no predictions).
        - `plan` must be 100% actionable steps (no abstract advice).
        - Each week MUST contain 4–7 concrete action steps.
        - Total number of weeks MUST strictly match `brief.timeframe`:
          • 1_month → 4-5 weeks  
          • 3_months → 12–14 weeks  
          • 6_months → 24–28 weeks  
          (Generating fewer weeks is NOT allowed.)
        - Steps MUST match both `brief.experience` and `brief.difficulty`.
        - Prioritize goals in `brief.result.goals` (estimate money/subscribers ONLY if explicitly requested).
        - Respect `brief.limits` (e.g., “online only”, “no Instagram”, “budget = $1000”).
        - If `budget` is NOT provided → ALL steps must be zero-cost; do NOT invent a budget.
        - Use `profile` ONLY for context and tone. Do NOT include profile data in the output.
        - If any optional profile field is missing, Do NOT infer, guess, or fabricate it.
        - Do NOT add anything outside the defined JSON structure.
        """
        // swiftlint:enable line_length
    }

    private func makeUserContent(
        brief: Project.Brief,
        difficulty: Project.Plan.Difficulty
    ) async throws -> String {
        let profile = try dataStorage.fetchProfile()
        let userContent = GeneratorRequest.UserContent(
            profile: GeneratorRequest.UserContent.Profile(
                name: profile?.name ?? "",
                age: profile?.age == 50 ? "50+" : profile?.age?.description,
                gender: {
                    switch profile?.gender {
                    case .male: "male"
                    case .female: "female"
                    case .other: "other"
                    case .none: nil
                    }
                }(),
                countryCode: profile?.country?.isoCode,
                currencyCode: profile?.currency.code ?? "USD"
            ),
            brief: GeneratorRequest.UserContent.Brief(
                idea: brief.idea,
                timeframe: {
                    switch brief.timeframe {
                    case .month1: "1_month"
                    case .month3: "3_months"
                    case .month6: "6_months"
                    }
                }(),
                experience: {
                    switch brief.experience {
                    case .beginner: "beginner"
                    case .intermediate: "intermediate"
                    case .expert: "expert"
                    }
                }(),
                difficulty: {
                    switch difficulty {
                    case .easy: "easy"
                    case .average: "medium"
                    case .difficult: "hard"
                    }
                }(),
                startPoint: brief.startPoint,
                result: GeneratorRequest.UserContent.Result(
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

    private func makeProject(
        brief: Project.Brief,
        difficulty: Project.Plan.Difficulty,
        from response: GeneratorResponse
    ) throws -> Project {
        guard !response.message.isEmpty,
              let data = response.message.data(using: .utf8),
              let content = try? decoder.decode(GeneratorResponse.ProjectContent.self, from: data)
        else { throw ProjectGeneratorError.failedToDecodeData }
        let project = Project(
            id: UUID(),
            brief: brief,
            summary: content.summary,
            plans: [
                Project.Plan(
                    id: UUID(),
                    title: content.plan.title,
                    emoji: content.plan.emoji,
                    firstResults: content.plan.firstResults,
                    budget: content.plan.budget,
                    result: content.plan.result,
                    difficulty: difficulty,
                    weeks: content.plan.weeks.sorted { $0.number < $1.number }.map {
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
                    isFavorite: false,
                    createdAt: .now,
                )
            ],
            createdAt: .now,
            updatedAt: .now
        )
        return project
    }
}
