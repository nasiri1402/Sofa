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
                    .map { "- Step \($0.number): \($0.title) [\($0.isCompleted ? "completed" : "in progress")]" }
                    .joined(separator: "\n")
                return """
                Week \(week.number):
                \(steps)
                """
            }
            .joined(separator: "\n\n")

        return """
        [CONVERSATION CONTEXT]:

        Current plan snapshot. Treat this as the source of truth for the this plan.

        Plan title: \(plan.title)
        Plan emoji: \(plan.emoji)
        First results: \(plan.firstResults)
        Budget: \(plan.budget)
        Expected result: \(plan.result)
        Difficulty: \(plan.difficulty.name)
        Is favorite: \(plan.isFavorite ? "yes" : "no")
        Progress: \(Int((plan.progress * 100).rounded()))%

        Weeks and Steps:
        \(weeks)
        """
    }
}
