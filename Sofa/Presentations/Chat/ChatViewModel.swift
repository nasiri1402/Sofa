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
    private(set) var isSending = false
    var alertItem: AlertItem?

    var messages: [Project.Plan.Chat.Message] {
        (plan.chat?.messages ?? []).sorted { $0.sentAt < $1.sentAt }
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
        try await chatter.updateChatContext(conversation: chat.conversation)
    }

    private func clearChat() {
        messageInput = ""
        Task { @MainActor in
            do {
                if let conversation = plan.chat?.conversation {
                    try? await chatter.closeChat(conversation: conversation)
                }
                plan.chat = nil
                try saveProject()
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func sendMessage(_ text: String, context: String?) async {
        isSending = true
        do {
            if plan.chat == nil {
                try await createChat()
            }
            try addMessage(text: text, context: context)
            guard let chat = plan.chat else { return }
            try addMessage(
                text: try await chatter.sendMessage(text, context: context, conversation: chat.conversation),
                isFromUser: false
            )
        } catch {
            alertItem = .error(message: error.localizedDescription)
        }
        isSending = false
    }

    private func addMessage(text: String, context: String? = nil, isFromUser: Bool = true) throws {
        let message = Project.Plan.Chat.Message(
            id: UUID(),
            text: text,
            context: context,
            isFromUser: isFromUser,
            sentAt: .now
        )
        plan.chat?.messages.insert(message, at: .zero)
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
}
