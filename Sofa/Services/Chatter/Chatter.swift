//
//  Chatter.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation

// MARK: - Interfaces

protocol Chatter {
    func createChat() async throws -> Project.Plan.Chat
    func sendMessage(_ message: String, threadID: String) async throws -> String
}

// MARK: - Errors

enum ChatterError: LocalizedError {
    case chatCreationFailed
    case messageSendFailed

    var errorDescription: String? {
        switch self {
        case .chatCreationFailed: String(localized: "chatterErrorChatCreationFailed")
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

    func createChat() async throws -> Project.Plan.Chat {
        do {
//            let response = try await apiService.createChatThread()
            let threadID = "threadID"
            let chat = Project.Plan.Chat(id: UUID(), threadID: threadID, messages: [])
            debugPrint("Chat created successfully. Thread ID: \(threadID)")
            return chat
        } catch {
            debugPrint("Failed to create chat: \(error.localizedDescription)")
            throw ChatterError.chatCreationFailed
        }
    }

    func sendMessage(_ message: String, threadID: String) async throws -> String {
        do {
//            let response = try await apiService.sendChatMessage(threadID: threadID, text: message)
            let message = "response.message"
            debugPrint("Message sent successfully")
            return message
        } catch {
            debugPrint("Failed to send message to chat:", error.localizedDescription)
            throw ChatterError.messageSendFailed
        }
    }
}
