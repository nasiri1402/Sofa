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

    // MARK: - Inits

    init(
        router: ChatRouter,
        dataStorage: DataStorage,
        chatter: Chatter,
        project: Project,
        plan: Project.Plan,
        step: Project.Plan.Step?
    ) {
        self.router = router
        self.dataStorage = dataStorage
        self.chatter = chatter
        self.project = project
        self.plan = plan
        self.step = step

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

    private func sendMessage(_ text: String, context: String?) async {
        isSending = true
        do {
            if plan.chat == nil {
                plan.chat = try await chatter.createChat()
            }
            plan.chat?.addMessage(text: text, context: context)
            try saveProject()

            if let threadID = plan.chat?.threadID {
                plan.chat?.addMessage(
                    text: try await chatter.sendMessage(text, threadID: threadID),
                    isFromUser: false
                )
                try saveProject()
            }
        } catch {
            alertItem = .error(message: error.localizedDescription)
        }
        isSending = false
    }

    private func clearChat() {
        plan.chat = nil
        messageInput = ""
        Task { @MainActor in
            do {
                try saveProject()
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
}
