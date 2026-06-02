//
//  Chatter.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation

// MARK: - Interfaces

protocol Chatter {
    func createChat(for plan: Project.Plan) async throws -> Project.Plan.Chat
    func closeChat(conversation: Project.Plan.Chat.Conversation) async throws
    func createChatContext(for plan: Project.Plan) -> String
    func updateChatContext(conversation: Project.Plan.Chat.Conversation) async throws
    func sendMessage(
        _ message: String,
        context: String?,
        conversation: Project.Plan.Chat.Conversation
    ) async throws -> String
}

// MARK: - Errors

enum ChatterError: LocalizedError {
    case chatCreationFailed
    case chatClosingFailed
    case contextUpdateFailed
    case messageSendFailed

    var errorDescription: String? {
        switch self {
        case .chatCreationFailed: String(localized: "chatterErrorChatCreationFailed")
        case .chatClosingFailed: String(localized: "chatterErrorChatClosingFailed")
        case .contextUpdateFailed: String(localized: "chatterErrorContextUpdateFailed")
        case .messageSendFailed: String(localized: "chatterErrorMessageSendFailed")
        }
    }
}

// MARK: - Implementations

final class DefaultChatter: Chatter {

    // MARK: - Private Properties

    private let functionsClient: FunctionsClient

    // MARK: - Initializers

    init(functionsClient: FunctionsClient) {
        self.functionsClient = functionsClient
    }

    // MARK: - Public Methods

    func createChat(for plan: Project.Plan) async throws -> Project.Plan.Chat {
        do {
            let response = try await functionsClient.converser(
                request: ConverserRequest(action: .create(ConverserRequest.CreatePayload()))
            )
            switch response.action {
            case .create(let payload):
                let chat = Project.Plan.Chat(
                    id: UUID(),
                    conversation: Project.Plan.Chat.Conversation(
                        id: payload.conversationID,
                        context: createChatContext(for: plan),
                        isDirty: true
                    ),
                    messages: []
                )
                debugPrint("Chat created successfully. Conversation ID: \(payload.conversationID)")
                return chat
            case .close:
                throw ChatterError.chatCreationFailed
            }
        } catch {
            debugPrint("Failed to create chat: \(error.localizedDescription)")
            throw ChatterError.chatCreationFailed
        }
    }

    func closeChat(conversation: Project.Plan.Chat.Conversation) async throws {
        do {
            let response = try await functionsClient.converser(
                request: ConverserRequest(action: .close(ConverserRequest.ClosePayload(conversationID: conversation.id)))
            )
            switch response.action {
            case .close:
                debugPrint("Chat closed successfully. Conversation ID: \(conversation.id)")
            case .create:
                throw ChatterError.chatClosingFailed
            }
        } catch {
            debugPrint("Failed to close chat:", error.localizedDescription)
            throw ChatterError.chatClosingFailed
        }
    }

    func sendMessage(
        _ message: String,
        context: String?,
        conversation: Project.Plan.Chat.Conversation
    ) async throws -> String {
        do {
            let response = try await functionsClient.chatter(
                request: ChatterRequest(action: .sendMessage(ChatterRequest.SendMessagePayload(
                    conversationID: conversation.id,
                    instructions: makeSendMessageInstructions(),
                    message: message,
                    context: context
                )))
            )
            switch response.action {
            case .updateContext:
                throw ChatterError.messageSendFailed
            case .sendMessage(let payload):
                debugPrint("Message sent successfully")
                return payload.message
            }
        } catch {
            debugPrint("Failed to send message to chat:", error.localizedDescription)
            throw ChatterError.messageSendFailed
        }
    }

    func updateChatContext(conversation: Project.Plan.Chat.Conversation) async throws {
        do {
            let response = try await functionsClient.chatter(
                request: ChatterRequest(action: .updateContext(ChatterRequest.UpdateContextPayload(
                    conversationID: conversation.id,
                    context: conversation.context
                )))
            )
            switch response.action {
            case .updateContext:
                debugPrint("Chat context updated successfully. Conversation ID: \(conversation.id)")
            case .sendMessage:
                throw ChatterError.contextUpdateFailed
            }
        } catch {
            debugPrint("Failed to update chat context:", error.localizedDescription)
            throw ChatterError.contextUpdateFailed
        }
    }

    func createChatContext(for plan: Project.Plan) -> String {
        let weeks = plan.weeks
            .sorted { $0.number < $1.number }
            .map { week in
                let steps = week.steps
                    .sorted { $0.number < $1.number }
                    .map {
                        """
                        - Step ID: \($0.id.uuidString)
                          Step Number: \($0.number)
                          Title: \($0.title)
                          Status: \($0.isCompleted ? "completed" : "in progress")
                        """
                    }
                    .joined(separator: "\n")
                return """
                WEEK \(week.number)
                Week ID: \(week.id.uuidString)
                Status: \(week.isCompleted ? "completed" : "in progress")
                Steps:
                \(steps)
                """
            }
            .joined(separator: "\n\n")

        return """
        [CONVERSATION CONTEXT]
        
        This is the ONLY source of truth for the current plan.
        
        PLAN METADATA:
        - Plan ID: \(plan.id.uuidString)
        - Title: \(plan.title)
        - Emoji: \(plan.emoji)
        - First Results: \(plan.firstResults)
        - Budget: \(plan.budget)
        - Expected Result: \(plan.result)
        - Difficulty: \(plan.difficulty.name)
        - Favorite: \(plan.isFavorite ? "yes" : "no")
        - Created At: \(plan.createdAt)
        - Progress: \(Int((plan.progress * 100).rounded()))%
        - Status: \(plan.isCompleted ? "completed" : "in progress")

        PLAN WEEKS:
        \(weeks)
        """

    }

    // MARK: - Private Methods

    // swiftlint:disable line_length
    private func makeSendMessageInstructions() -> String {
        """
        You are Sofa, the in-app chat assistant and plan consultant.
        Help the user understand, follow, and make progress on the current plan.

        CONTEXT RULES:
        - Find the latest message that starts with "[CONVERSATION CONTEXT]".
        - Treat that message as the ONLY source of truth.
        - Ignore external knowledge, assumptions, and generic advice unless the user explicitly asks for general explanation.
        - When using general explanation, keep it directly connected to the current plan.
        - If no "[CONVERSATION CONTEXT]" message exists, refuse briefly.

        INPUT FORMAT:
        {
          "message": "<string, the user's current question>",
          "context": "<string, optional step title>"
        }

        INPUT RULES:
        - `message` is the user's request.
        - `context` is optional. If it is present, treat it as the exact title of a step from the current plan.
        - Use `context` only to narrow the scope of the answer.

        OUTPUT FORMAT:
        - Return one short plain-text user-facing answer.
        - Do not return JSON.

        RESPONSE RULES:
        - Sound like a friendly product assistant, not like a database report.
        - Be simple, practical, easy to scan on a phone, and use natural wording over technical labels.
        - Keep answers short, polite, user-oriented, and to the point.
        - Default length: 1-3 short sentences.
        - Use up to 5 bullets only when a list is clearly easier to read.
        - Do not list every week or every step unless the user asks for a full breakdown.
        - Answer only using information explicitly present in the current plan context.
        - Use `context` only to narrow the scope of the answer.
        - Use plan metadata only to understand the plan, not as content to show by default.
        - Do not expose internal IDs, timestamps, raw statuses, enum values, or technical fields unless the user explicitly asks for them.
        - Do not mention empty or unhelpful fields, such as a zero budget, unless directly relevant.
        - When the user asks about the plan, summarize the goal, the structure, and the next useful focus.
        - When the user asks about a specific week or step, explain what to do in simple practical words.
        - You may give simple execution guidance if it is directly grounded in the current plan.
        - You cannot change the plan.
        - Do not modify, rewrite, restructure, optimize, or replace any part of the plan.
        - Do not invent missing details.
        - Do not create new goals, timelines, or tasks that are not supported by the current plan context.
        - If the plan context does not contain enough information, say so briefly.

        REFUSAL RULES:
        - If the request is not related to the current plan, briefly say you can only help with this plan.
        - If the user asks to change the plan, briefly say you can only explain, clarify, or discuss the existing plan.
        """
    }
    // swiftlint:enable line_length
}
