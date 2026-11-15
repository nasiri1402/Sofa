//
//  BriefPreferencesPage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct BriefPreferencesPage: View {

    // MARK: - Public Properties

    @Binding var preferences: String
    let tip: String
    let placeholder: String
    let typewriterOptions: [String]
    let noPreferencesText: String
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
        VStack(alignment: .leading, spacing: 16.fitW) {
            if needsReveal {
                WordRevealText(
                    text: title,
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(2)
            } else {
                Text(title)
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(2)
            }
            if isInputEnabled {
                VStack(spacing: 24.fitW) {
                    Tip(text: tip)
                    InputField()
                    NoPreferencesButton()
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isFocused = preferences.isEmpty
                }
            }
        }
        .onDisappear {
            isFocused = false
            transitionTask?.cancel()
        }
        .onChange(of: preferences) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    // MARK: - Views

    private var title: String {
        BriefLocalization.text(en: "Any preferences for your plan?", ru: "Есть пожелания к плану?")
    }

    private func InputField() -> some View {
        TypewriterTextField(
            text: $preferences,
            placeholder: placeholder,
            typewriterOptions: typewriterOptions,
            isFocused: $isFocused
        )
    }

    private func NoPreferencesButton() -> some View {
        Button {
            preferences = noPreferencesText
            isFocused = false
        } label: {
            Text(noPreferencesText)
                .multilineMinimumScale()
                .multilineTextAlignment(.center)
                .font(.system(size: 15.fitW, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20.fitW)
                .frame(height: 48.fitW)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.gray787880.opacity(0.12))
                .clipShape(.capsule)
                .overlay {
                    Capsule()
                        .strokeBorder(.blue007AFF, lineWidth: 1.fitW)
                        .opacity(preferences == noPreferencesText ? 1 : 0)
                }
        }
        .buttonStyle(.plain)
        .hapticFeedback()
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
