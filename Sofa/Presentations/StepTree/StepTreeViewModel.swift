//
//  StepTreeViewModel.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class StepTreeViewModel {

    // MARK: - Public Properties

    private(set) var plan: Project.Plan
    private(set) var selectedWeek: Project.Plan.Week?
    private(set) var lockedWeeks: [Project.Plan.Week] = []
    private(set) var highlightedStep: Project.Plan.Step?
    var stepToMenu: Project.Plan.Step?
    var textFieldAlertItem: TextFieldAlertItem?
    var alertItem: AlertItem?
    var isWellDone = false

    var isPro: Bool {
        storeManager.hasPurchasedProduct()
    }

    var isPaywallPresented = false {
        didSet {
            guard oldValue != isPaywallPresented else { return }
            if !isPaywallPresented {
                lockedWeeks = plan.weeks.filter(isWeekLocked)
            }
        }
    }

    // MARK: - Private Properties

    private let router: StepTreeRouter
    private let dataStorage: DataStorage
    private let storeManager: StoreManager
    private let chatter: Chatter

    private var project: Project
    private var highlightStepTask: Task<Void, Never>?

    // MARK: - Inits

    init(
        router: StepTreeRouter,
        dataStorage: DataStorage,
        storeManager: StoreManager,
        chatter: Chatter,
        project: Project,
        plan: Project.Plan
    ) {
        self.router = router
        self.dataStorage = dataStorage
        self.storeManager = storeManager
        self.chatter = chatter
        self.project = project
        self.plan = plan

        initialize()
    }
}

// MARK: - Public Properties

extension StepTreeViewModel {

    // MARK: - Input

    func didViewAppear() {
        fetchProject()
    }

    func didTapNavigationBarLeadingButton() {
        router.back()
    }

    func didTapNavigationBarTrailingButton() {
        plan.isFavorite.toggle()
        if let index = project.plans.firstIndex(where: { $0.id == plan.id }) {
            project.plans[index].isFavorite = plan.isFavorite
        }
        saveProject()
    }

    func didTapAddStepButton() {
        textFieldAlertItem = TextFieldAlertItem(
            title: String(localized: "addNewStep"),
            message: String(localized: "youCanRenameTheStepAtAnyTime"),
            submitTitle: String(localized: "add"),
            placeholder: String(localized: "nameYourStep"),
            inputText: "",
            onSubmit: { [weak self] newValue in
                guard let self else { return }
                let title = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !title.isEmpty else { return }
                addStep(title: title)
            }
        )
    }

    func didTapWeekButton(_ week: Project.Plan.Week) {
        guard !isWeekLocked(week) else {
            isPaywallPresented = true
            return
        }
        guard selectedWeek?.id != week.id else { return }
        selectedWeek = week
    }

    func didTapStepButton(_ step: Project.Plan.Step) {
        guard var week = selectedWeek else { return }
        if let stepIndex = week.steps.firstIndex(where: { $0.id == step.id }) {
            week.steps[stepIndex].isCompleted.toggle()
        }
        if let weekIndex = plan.weeks.firstIndex(where: { $0.id == week.id }) {
            plan.weeks[weekIndex] = week
        }
        if let planIndex = project.plans.firstIndex(where: { $0.id == plan.id }) {
            project.plans[planIndex] = plan
        }
        selectedWeek = week
        isWellDone = plan.isCompleted
        saveProject()
    }

    func didMoveStep(from offsets: IndexSet, to offset: Int) {
        guard var week = selectedWeek else { return }
        week.steps.move(fromOffsets: offsets, toOffset: offset)
        week.steps = week.steps.enumerated().map { index, step in
            Project.Plan.Step(
                id: step.id,
                title: step.title,
                number: index + 1,
                isCompleted: step.isCompleted
            )
        }
        updateWeek(week)
    }

    func didTapStepMenuButton(_ step: Project.Plan.Step) {
        stepToMenu = step
    }

    func didTapAskAssistantStepButton() {
        let step = stepToMenu
        stepToMenu = nil
        openChatIfAvailable(step: step)
    }

    func didTapRenameStepButton() {
        guard let step = stepToMenu else { return }
        stepToMenu = nil
        textFieldAlertItem = TextFieldAlertItem(
            title: String(localized: "changeTheNameOfTheStep"),
            message: String(localized: "youCanRenameTheStepAtAnyTime"),
            submitTitle: String(localized: "rename"),
            placeholder: String(localized: "nameYourStep"),
            inputText: step.title,
            onSubmit: { [weak self] newValue in
                guard let self else { return }
                let renamed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !renamed.isEmpty, renamed != step.title else { return }
                renameStep(step, title: renamed)
            }
        )
    }

    func didTapDeleteStepButton() {
        guard let step = stepToMenu else { return }
        stepToMenu = nil
        alertItem = AlertItem(
            title: Text(String(localized: "deleteStep")),
            message: Text(String(localized: "deleteStepMessage")),
            primaryButton: .destructive(Text(String(localized: "delete"))) { [weak self] in
                guard let self else { return }
                deleteStep(step)
            },
            secondaryButton: .cancel(Text(String(localized: "cancel")))
        )
    }

    func didTapAskAssistantButton() {
        openChatIfAvailable(step: nil)
    }

    func didTapViewPlanButton() {
        isWellDone = false
    }
}

// MARK: - Private Methods

extension StepTreeViewModel {
    private func initialize() {
        isWellDone = plan.isCompleted
        lockWeeks()
    }

    private func fetchProject() {
        do {
            guard let storedProject = try dataStorage.fetchProject(id: project.id),
                  let storedPlan = storedProject.plans.first(where: { $0.id == plan.id })
            else { return }

            project = storedProject
            plan = storedPlan
            isWellDone = plan.isCompleted

            if let week = selectedWeek {
                selectedWeek = plan.weeks.first(where: { $0.id == week.id })
            } else {
                lockWeeks()
            }
        } catch {
            alertItem = .error(message: error.localizedDescription)
        }
    }

    private func saveProject() {
        Task { @MainActor in
            do {
                updateChatConversationContext()
                if let planIndex = project.plans.firstIndex(where: { $0.id == plan.id }) {
                    project.plans[planIndex] = plan
                }
                project.updatedAt = .now
                try dataStorage.saveProject(project)
            } catch {
                alertItem = .error(message: error.localizedDescription)
            }
        }
    }

    private func updateWeek(_ week: Project.Plan.Week) {
        guard let weekIndex = plan.weeks.firstIndex(where: { $0.id == week.id }),
              let planIndex = project.plans.firstIndex(where: { $0.id == plan.id })
        else { return }
        plan.weeks[weekIndex] = week
        project.plans[planIndex] = plan
        selectedWeek = week
        isWellDone = plan.isCompleted
        saveProject()
    }

    private func findWeekByStepTitle(_ title: String) -> Project.Plan.Week? {
        plan.weeks.first { week in
            week.steps.contains { step in
                step.title
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .localizedCaseInsensitiveCompare(title) == .orderedSame
            }
        }
    }

    private func lockWeeks() {
        selectedWeek = isPro || project.hasLifetimeAccess
        ? plan.weeks.first { !$0.isCompleted } ?? plan.weeks.last
        : plan.weeks.min { $0.number < $1.number }
        lockedWeeks = plan.weeks.filter(isWeekLocked)
    }

    private func isWeekLocked(_ week: Project.Plan.Week) -> Bool {
        guard !isPro, !project.hasLifetimeAccess else { return false }
        return week.number != 1
    }

    private func addStep(title: String) {
        guard var week = selectedWeek else { return }
        let step = Project.Plan.Step(
            id: UUID(),
            title: title,
            number: (week.steps.map(\.number).max() ?? .zero) + 1,
            isCompleted: false
        )
        week.steps.append(step)
        updateWeek(week)
    }

    private func renameStep(_ step: Project.Plan.Step, title: String) {
        guard var week = selectedWeek,
              let stepIndex = week.steps.firstIndex(where: { $0.id == step.id })
        else { return }

        let step = week.steps[stepIndex]
        week.steps[stepIndex] = Project.Plan.Step(
            id: step.id,
            title: title,
            number: step.number,
            isCompleted: step.isCompleted
        )
        updateWeek(week)
    }

    private func deleteStep(_ step: Project.Plan.Step) {
        guard var week = selectedWeek,
              let stepIndex = week.steps.firstIndex(where: { $0.id == step.id })
        else { return }
        week.steps.remove(at: stepIndex)
        updateWeek(week)
    }

    private func highlightStep(_ step: Project.Plan.Step, duration: CGFloat = 3.2) {
        highlightStepTask?.cancel()
        highlightStepTask = Task { @MainActor [weak self] in
            guard let self else { return }
            highlightedStep = step
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            highlightedStep = nil
        }
    }

    private func findStepByTitle(_ title: String) -> Project.Plan.Step? {
        guard let week = findWeekByStepTitle(title) else { return nil }
        return week.steps.first(where: { step in
            step.title
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(title) == .orderedSame
        })
    }

    private func openChatIfAvailable(step: Project.Plan.Step?) {
        guard isPro else {
            isPaywallPresented = true
            return
        }
        if let planIndex = project.plans.firstIndex(where: { $0.id == plan.id }) {
            project.plans[planIndex] = plan
        }
        router.route(to: .chat(project, plan, step) { [weak self] in
            guard let self else { return }
            let context = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !context.isEmpty,
                  let week = findWeekByStepTitle(context),
                  !isWeekLocked(week),
                  let step = findStepByTitle(context)
            else { return }
            selectedWeek = week
            highlightStep(step)
        })
    }

    private func updateChatConversationContext() {
        guard let chat = plan.chat else { return }
        plan.chat = Project.Plan.Chat(
            id: chat.id,
            conversation: chat.conversation.map {
                Project.Plan.Chat.Conversation(
                    id: $0.id,
                    context: chatter.createChatContext(for: plan),
                    isDirty: true
                )
            },
            messages: chat.messages
        )
    }
}
