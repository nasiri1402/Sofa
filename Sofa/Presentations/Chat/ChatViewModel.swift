//
//  ChatViewModel.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation
import Observation

@MainActor @Observable
final class ChatViewModel {

    // MARK: - Public Properties

    private(set) var plan: Project.Plan
    private(set) var profile: Profile?
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

        initialize()
    }
}

// MARK: - Input

extension ChatViewModel {
    func didTapNavigationBarLeadingButton() {
        guard !isSending else { return }
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

    func didTapNavigationBarTrailingButton() {
        router.back()
    }

    func didTapSendButton() {
        guard canSendMessage else { return }
        let text = messageInput.trimmingCharacters(in: .whitespacesAndNewlines)
        messageInput = ""
        Task { @MainActor in
            await sendMessage(text)
        }
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

    private func sendMessage(_ text: String) async {
        isSending = true
        do {
            if plan.chat == nil {
                plan.chat = try await chatter.createChat()
            }
            plan.chat?.addMessage(text: text, additional: nil)
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

    private func saveProject() throws {
        if let planIndex = project.plans.firstIndex(where: { $0.id == plan.id }) {
            project.plans[planIndex] = plan
        }
        project.updatedAt = .now
        try dataStorage.saveProject(project)
    }
}
