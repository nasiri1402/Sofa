//
//  BriefLimitsPage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct BriefLimitsPage: View {

    // MARK: - Public Properties

    let hasBudget: Bool
    @Binding var limitsInput: String
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @State private var phase: Phase = .one
    @FocusState private var isFocused
    @State private var isInputEnabled = false
    @State private var topPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16.fitW) {
            if needsReveal {
                WordRevealText(
                    text: hasBudget ? phase.text : String(localized: "whatAreTheLimitsOrRequests"),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: hasBudget ? advanceToNextPhase : completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "whatAreTheLimitsOrRequests"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isInputEnabled {
                VStack(spacing: 32.fitW) {
                    Tip(text: String(localized: "weWillConsiderThemInThePlanGenerating"))
                    LimitsTextField()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer()
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .contentShape(.rect)
        .onTapGesture {
            isFocused = false
        }
        .transition(.opacity)
        .onAppear {
            if needsReveal {
                isInputEnabled = false
                topPadding = 256.fitH
            } else {
                isInputEnabled = true
                topPadding = 72.fitW
            }
        }
        .onDisappear {
            isFocused = false
            transitionTask?.cancel()
        }
        .onChange(of: limitsInput) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    // MARK: - Views

    private func LimitsTextField() -> some View {
        TextField(String(localized: "writeDownTheDetails"), text: $limitsInput, axis: .vertical)
            .font(.system(size: 17.fitW))
            .foregroundStyle(.grayE5E5EA)
            .autocorrectionDisabled()
            .focused($isFocused)
            .lineLimit(7)
    }

    // MARK: - Private Methods

    @MainActor
    func advanceToNextPhase() {
        guard let next = nextPhase(after: phase) else {
            completeTitleReveal()
            return
        }
        phase = next
    }

    func nextPhase(after phase: Phase) -> Phase? {
        guard let index = Phase.allCases.firstIndex(of: phase) else { return nil }
        return Phase.allCases[safe: index + 1]
    }

    @MainActor
    private func completeTitleReveal() {
        isPreviousEnabled = true
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeInOut) {
                topPadding = 72.fitW
                isInputEnabled = true
            } completion: {
                isFocused = true
            }
        }
    }
}

// MARK: - Types

extension BriefLimitsPage {
    enum Phase: Int, CaseIterable {
        case one, two

        var text: String {
            switch self {
            case .one: String(localized: "goodBudgetToStartTakingAction") + " 💵"
            case .two: String(localized: "whatAreTheLimitsOrRequests")
            }
        }
    }
}
