//
//  OnboardingNamePage.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

struct OnboardingNamePage: View {

    // MARK: - Public Properties

    @Binding var nameInput: String
    let onFinish: () -> Void

    // MARK: - Private Properties

    @FocusState private var isFocused
    @State private var keyboardHeight: CGFloat = .zero
    @State private var isInputEnabled = false
    @State private var titleTopPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            WordRevealText(
                text: String(localized: "whatIsYourName"),
                font: .system(size: 34.fitW, weight: .bold),
                revealedColor: .white,
                hiddenColor: .white.opacity(0),
                onRevealFinished: completeTitleReveal
            )
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            if isInputEnabled {
                NameTextField()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer()
        }
        .padding(.top, titleTopPadding)
        .padding(.horizontal, 16.fitW)
        .contentShape(.rect)
        .onTapGesture {
            isFocused = false
        }
        .transition(.opacity)
        .onDisappear {
            isFocused = false
            transitionTask?.cancel()
        }
        .onChange(of: nameInput.isEmpty) { oldValue, newValue in
            guard oldValue != newValue else { return }
            if !newValue {
                onFinish()
            }
        }
        .onChangeKeyboardHeight { newValue in
            guard newValue != keyboardHeight else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                keyboardHeight = newValue
            }
        }
    }

    // MARK: - Views

    private func NameTextField() -> some View {
        TextField(String(localized: "yourName"), text: $nameInput)
            .font(.system(size: 17.fitW))
            .foregroundStyle(.grayE5E5EA)
            .autocorrectionDisabled()
            .focused($isFocused)
            .frame(height: 22.fitW)
    }

    // MARK: - Private Methods

    @MainActor
    private func completeTitleReveal() {
        transitionTask?.cancel()
        transitionTask = Task {
            await MainActor.run {
                withAnimation(.easeInOut) {
                    titleTopPadding = 72.fitW
                    isInputEnabled = true
                } completion: {
                    isFocused = true
                }
            }
        }
    }
}
