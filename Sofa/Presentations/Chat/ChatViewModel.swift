//
//  ChatViewModel.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class ChatViewModel {

    // MARK: - Public Properties

    private(set) var plan: Project.Plan
    private(set) var profile: Profile?
    private(set) var step: Project.Plan.Step?
    var messageInput = ""
    private(set) var sendingState: ChatModel.SendingState?
    var alertItem: AlertItem?

    var isSending: Bool {
        sendingState != nil
    }

    var messages: [Project.Plan.Chat.Message] {
        ((plan.chat?.messages ?? []) + [optimisticMessage].compactMap(\.self))
            .sorted { $0.sentAt < $1.sentAt }
    }

    var canSendMessage: Bool {
        !messageInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    // MARK: - Private Properties

    private let router: ChatRouter
    private let dataStorage: DataStorage
    private let chatter: Chatter

    private var project: Project
    private let onTapContext: (String) -> Void

    private var optimisticMessage: Project.Plan.Chat.Message?

    // MARK: - Inits

    init(
        router: ChatRouter,
        dataStorage: DataStorage,
        chatter: Chatter,
        project: Project,
        plan: Project.Plan,
        step: Project.Plan.Step?,
        onTapContext: @escaping (String) -> Void
    ) {
        self.router = router
        self.dataStorage = dataStorage
        self.chatter = chatter
        self.project = project
        self.plan = plan
        self.step = step
        self.onTapContext = onTapContext

        initialize()
    }
}

// MARK: - Public Methods

extension ChatViewModel {

    // MARK: - Input

    func didTapNavigationBarLeadingButton() {
        guard !isSending else { return }
        alertItem = AlertItem(
            title: Text(String(localized: "clearTheEntireChat")),
            message: Text(String(localized: "clearChatMessage")),
            primaryButton: .destructive(Text(String(localized: "clear"))) { [weak self] in
                guard let self else { return }
                clearChat()
            },
            secondaryButton: .cancel(Text(String(localized: "cancel")))
        )
    }

    func didTapNavigationBarTrailingButton() {
        router.back()
    }

    func didTapMessageContext(_ message: Project.Plan.Chat.Message) {
        guard let context = message.context else { return }
        guard canOpenMessageContext(context) else {
            alertItem = AlertItem(
                title: Text(String(localized: "messageContextStepNotFoundTitle")),
                message: Text(String(localized: "messageContextStepNotFoundMessage")),
                primaryButton: .default(Text(String(localized: "ok")))
            )
            return
        }
        onTapContext(context)
        router.back()
    }

    func didTapStepClearButton() {
        step = nil
    }

    func didTapSendButton() {
        guard canSendMessage else { return }
        let text = messageInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let attachedStepTitle = step?.title
        messageInput = ""
        step = nil

        Task { @MainActor in
            await sendMessage(text, context: attachedStepTitle)
        }
    }

    // MARK: - Output

    func getContext(_ message: Project.Plan.Chat.Message) -> String? {
        guard let context = message.context, !context.isEmpty else { return nil }
        return context
    }
}

// MARK: - Private Methods

extension ChatViewModel {
    private func initialize() {
        fetchProfile()
    }

    private func fetchProfile() {
        Task { @MainActor in
            do {
                profile = try dataStorage.fetchProfile()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func saveProject() throws {
        if let planIndex = project.plans.firstIndex(where: { $0.id == plan.id }) {
            project.plans[planIndex] = plan
        }
        project.updatedAt = .now
        try dataStorage.saveProject(project)
    }

    private func createChat() async throws {
        let chat = try await chatter.createChat(for: plan)
        plan.chat = chat
        try saveProject()
    }

    private func clearChat() {
        messageInput = ""
        let conversation = plan.chat?.conversation
        plan.chat = nil

        Task { @MainActor in
            do {
                await Task.yield()
                try saveProject()
                closeConversation(conversation)
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func sendMessage(_ text: String, context: String?) async {
        defer {
            optimisticMessage = nil
            sendingState = nil
        }
        let userMessage = makeMessage(text: text, context: context)
        optimisticMessage = userMessage
        await Task.yield()
        do {
            if plan.chat == nil {
                sendingState = .initializingChat
                try await createChat()
            }
            guard let chat = plan.chat else { return }
            if chat.conversation.isDirty {
                sendingState = .analyzingPlan
                try await syncConversationContext()
            }
            sendingState = .thinking
            let assistantMessage = makeMessage(
                text: try await chatter.sendMessage(text, context: context, conversation: chat.conversation),
                isFromUser: false
            )
            try addMessage(userMessage)
            try addMessage(assistantMessage)
        } catch {
            try? removeMessage(id: userMessage.id)
            alertItem = .error(message: error.localizedDescription)
        }
    }

    private func addMessage(_ message: Project.Plan.Chat.Message) throws {
        plan.chat?.messages.insert(message, at: .zero)
        try saveProject()
    }

    private func makeMessage(
        text: String,
        context: String? = nil,
        isFromUser: Bool = true
    ) -> Project.Plan.Chat.Message {
        Project.Plan.Chat.Message(
            id: UUID(),
            text: text,
            context: context,
            isFromUser: isFromUser,
            sentAt: .now
        )
    }

    private func removeMessage(id: UUID) throws {
        plan.chat?.messages.removeAll { $0.id == id }
        try saveProject()
    }

    private func canOpenMessageContext(_ context: String) -> Bool {
        let normalized = context.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return false }
        return plan.weeks.contains { week in
            week.steps.contains { step in
                step.title
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .localizedCaseInsensitiveCompare(normalized) == .orderedSame
            }
        }
    }

    private func syncConversationContext() async throws {
        guard let chat = plan.chat else { return }
        try await chatter.updateChatContext(conversation: chat.conversation)
        plan.chat = Project.Plan.Chat(
            id: chat.id,
            conversation: Project.Plan.Chat.Conversation(
                id: chat.conversation.id,
                context: chat.conversation.context,
                isDirty: false
            ),
            messages: chat.messages
        )
        try saveProject()
    }

    private func closeConversation(_ conversation: Project.Plan.Chat.Conversation?) {
        guard let conversation else { return }
        Task.detached { [weak self] in
            guard let self else { return }
            try? await chatter.closeChat(conversation: conversation)
        }
    }
}
