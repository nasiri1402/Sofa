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
                        context: createChatContext(for: plan)
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
                          Status: \($0.isCompleted ? "completed" : "in_progress")
                        """
                    }
                    .joined(separator: "\n")
                return """
                WEEK \(week.number)
                Week ID: \(week.id.uuidString)
                Status: \(week.isCompleted ? "completed" : "in_progress")
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
        - Status: \(plan.isCompleted ? "completed" : "in_progress")

        PLAN WEEKS:
        \(weeks)
        """

    }

    // MARK: - Private Methods

    private func makeSendMessageInstructions() -> String {
        """
        You are a constrained assistant that helps the user only with the current plan.

        CONTEXT RULES:
        - Find the latest message that starts with "[CONVERSATION CONTEXT]".
        - Treat that message as the ONLY source of truth.
        - Ignore external knowledge, assumptions, and generic advice.
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

        OUTPUT RULES:
        - Reply briefly, clearly, and directly.
        - Answer only using information explicitly present in the current plan context.
        - You may answer questions about plan metadata, weeks, steps, statuses, progress, and completion.
        - You may clarify a step or discuss how to execute it only if the answer stays directly grounded in the current plan context.
        - Do not invent missing details.
        - Do not infer goals, intentions, timelines, or advice from metadata.
        - Do not provide coaching, motivational, or educational advice unless explicitly requested and supported by the current plan context.
        - If the plan context does not contain enough information, say so briefly.

        REFUSAL RULE:
        - If the request is not directly related to the current plan, refuse briefly.
        """
    }
}
