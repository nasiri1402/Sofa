//
//  BriefBudgetPage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct BriefBudgetPage: View {

    // MARK: - Public Properties

    @Binding var budgetInput: String
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @FocusState private var isFocused
    @State private var isInputEnabled = false
    @State private var topPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            if needsReveal {
                WordRevealText(
                    text: String(localized: "whatIsYourBudgetForTheIdea"),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "whatIsYourBudgetForTheIdea"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isInputEnabled {
                BudgetTextField()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer()
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .ignoresSafeArea(.keyboard)
        .contentShape(.rect)
        .onTapGesture {
            isFocused = false
        }
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
        .onChange(of: budgetInput) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !newValue.isEmpty
        }
    }

    // MARK: - Views

    private func BudgetTextField() -> some View {
        HStack(spacing: .zero) {
            Text(verbatim: "$ ")
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white)

            TextField(
                String("0"),
                text: Binding(get: { budgetInput }, set: { budgetInput = $0.filter(\.isNumber) })
            )
            .font(.system(size: 17.fitW))
            .foregroundStyle(.grayE5E5EA)
            .autocorrectionDisabled()
            .keyboardType(.numberPad)
            .focused($isFocused)
        }
    }

    // MARK: - Private Methods

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
