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
                    text: String(localized: "whatIsYourName"),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "whatIsYourName"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isInputEnabled {
                NameTextField()
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
        .onChange(of: nameInput) { oldValue, newValue in
            guard oldValue != newValue else { return }
            let scalars = newValue.unicodeScalars.filter { CharacterSet.letters.contains($0) }
            let letters = String(scalars.map(Character.init))
            if letters != newValue {
                nameInput = letters
            }
            isNextEnabled = !letters.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
