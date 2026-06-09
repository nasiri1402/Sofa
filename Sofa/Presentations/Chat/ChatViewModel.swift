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
    private(set) var selectedEditedMessage: Project.Plan.Chat.Message?
    var selectedFailedMessage: Project.Plan.Chat.Message?
    var selectedActionsMessage: Project.Plan.Chat.Message?
    var toast: ToastItem?
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
    private let networkMonitor: NetworkMonitor
    private let chatter: Chatter
    private let clipboard: Clipboard

    private var project: Project
    private let onTapContext: (String) -> Void

    private var optimisticMessage: Project.Plan.Chat.Message?
    @ObservationIgnored private var toastTask: Task<Void, Never>?

    // MARK: - Inits

    init(
        router: ChatRouter,
        dataStorage: DataStorage,
        networkMonitor: NetworkMonitor,
        chatter: Chatter,
        clipboard: Clipboard,
        project: Project,
        plan: Project.Plan,
        step: Project.Plan.Step?,
        onTapContext: @escaping (String) -> Void
    ) {
        self.router = router
        self.dataStorage = dataStorage
        self.networkMonitor = networkMonitor
        self.chatter = chatter
        self.clipboard = clipboard
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

    func didTapUserMessageContext(_ message: Project.Plan.Chat.Message) {
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

    func didTapMessage(_ message: Project.Plan.Chat.Message) {
        guard message.isFromUser, message.isFailed else { return }
        selectedFailedMessage = message
    }

    func didLongPressMessage(_ message: Project.Plan.Chat.Message) {
        if message.isFromUser {
            selectedActionsMessage = message
        } else {
            copyMessage(message)
        }
    }

    func didTapWarningButton(_ message: Project.Plan.Chat.Message) {
        selectedFailedMessage = message
    }

    func didTapRetryDialogButton() {
        guard let message = selectedFailedMessage else { return }
        selectedFailedMessage = nil
        retryFailedMessage(message)
    }

    func didTapDeleteDialogButton() {
        guard let message = selectedFailedMessage else { return }
        selectedFailedMessage = nil
        do {
            try removeMessage(id: message.id)
        } catch {
            alertItem = .error(message: error.localizedDescription)
        }
    }

    func didTapEditDialogButton() {
        guard let message = selectedActionsMessage else { return }
        selectedActionsMessage = nil
        messageInput = message.text
        step = nil
        selectedEditedMessage = message
    }

    func didTapCopyDialogButton() {
        guard let message = selectedActionsMessage else { return }
        selectedActionsMessage = nil
        copyMessage(message)
    }

    func didTapContextClearButton() {
        selectedEditedMessage = nil
        step = nil
    }

    func didTapSendButton() {
        guard canSendMessage else { return }
        let text = messageInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let attachedStep = step
        let editedMessage = selectedEditedMessage
        guard networkMonitor.isConnected else {
            alertItem = .noInternetConnection(onRetry: { [weak self] in
                guard let self else { return }
                didTapSendButton()
            })
            return
        }
        messageInput = ""
        selectedEditedMessage = nil
        step = nil

        Task { @MainActor in
            await sendMessage(text: text, context: attachedStep?.title, editedMessage: editedMessage)
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
        plan.chat = Project.Plan.Chat(
            id: plan.chat?.id ?? chat.id,
            conversation: chat.conversation,
            messages: plan.chat?.messages ?? []
        )
        try saveProject()
    }

    private func clearChat() {
        guard networkMonitor.isConnected else {
            alertItem = .noInternetConnection(onRetry: { [weak self] in
                guard let self else { return }
                clearChat()
            })
            return
        }
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

    private func ensureChatExists() {
        guard plan.chat == nil else { return }
        plan.chat = Project.Plan.Chat(id: UUID(), conversation: nil, messages: [])
    }

    private func sendMessage(
        text: String,
        context: String?,
        editedMessage: Project.Plan.Chat.Message?
    ) async {
        defer {
            optimisticMessage = nil
            sendingState = nil
        }
        let userMessage = makeMessage(text: text, context: context)
        optimisticMessage = userMessage
        await Task.yield()
        do {
            if let editedMessage {
                try await removeEditedMessage(editedMessage)
            }
            if plan.chat?.conversation == nil {
                sendingState = .initializingChat
                try await createChat()
            }
            guard let conversation = plan.chat?.conversation else { return }
            if conversation.isDirty {
                sendingState = .analyzingPlan
                try await syncConversationContext()
            }
            sendingState = .thinking
            let payload = try await chatter.sendMessage(text, context: context, conversation: conversation)
            let assistantMessage = makeMessage(
                itemID: payload.assistantItemID,
                text: payload.message,
                isFromUser: false,
            )
            try addMessage(userMessage.sent(itemID: payload.userItemID))
            try addMessage(assistantMessage)
        } catch {
            do {
                ensureChatExists()
                try addMessage(userMessage.fail())
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func addMessage(_ message: Project.Plan.Chat.Message) throws {
        plan.chat?.messages.insert(message, at: .zero)
        try saveProject()
    }

    private func copyMessage(_ message: Project.Plan.Chat.Message) {
        clipboard.copy(message.text)
        toastTask?.cancel()
        toast = ToastItem(title: String(localized: "messageCopiedToClipboard"))
        toastTask = Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(2))
            toast = nil
        }
    }

    private func removeMessage(id: UUID) throws {
        plan.chat?.messages.removeAll { $0.id == id }
        try saveProject()
    }

    private func makeMessage(
        itemID: String? = nil,
        text: String,
        context: String? = nil,
        isFromUser: Bool = true,
        isFailed: Bool = false
    ) -> Project.Plan.Chat.Message {
        Project.Plan.Chat.Message(
            id: UUID(),
            itemID: itemID,
            text: text,
            context: context,
            isFromUser: isFromUser,
            isFailed: isFailed,
            sentAt: .now
        )
    }

    private func removeEditedMessage(_ message: Project.Plan.Chat.Message) async throws {
        guard let messages = plan.chat?.messages,
              let index = messages.firstIndex(where: { $0.id == message.id })
        else { return }
        let conversation = plan.chat?.conversation
        var removedMessages = [messages[index]]
        let nextIndex = messages.index(after: index)
        if messages.indices.contains(nextIndex) {
            let nextMessage = messages[nextIndex]
            if !nextMessage.isFromUser {
                removedMessages.append(nextMessage)
            }
        }
        if let conversation {
            for removed in removedMessages {
                guard let itemID = removed.itemID, !itemID.isEmpty else { continue }
                try await chatter.deleteMessage(itemID, conversation: conversation)
            }
        }
        let ids = Set(removedMessages.map(\.id))
        plan.chat?.messages.removeAll { ids.contains($0.id) }
        try saveProject()
    }

    private func retryFailedMessage(_ message: Project.Plan.Chat.Message) {
        guard networkMonitor.isConnected else {
            alertItem = .noInternetConnection(onRetry: { [weak self] in
                guard let self else { return }
                retryFailedMessage(message)
            })
            return
        }
        do {
            try removeMessage(id: message.id)
        } catch {
            alertItem = .error(message: error.localizedDescription)
            return
        }
        Task { @MainActor in
            await sendMessage(text: message.text, context: message.context, editedMessage: nil)
        }
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
        guard let chat = plan.chat, let conversation = chat.conversation else { return }
        try await chatter.updateChatContext(conversation: conversation)
        plan.chat = Project.Plan.Chat(
            id: chat.id,
            conversation: Project.Plan.Chat.Conversation(
                id: conversation.id,
                context: conversation.context,
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
