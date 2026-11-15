//
//  BriefFocusPage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct BriefFocusPage: View {

    // MARK: - Public Properties

    let category: Project.Brief.Category
    let selectedFocus: String
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool
    let onSelect: (String) -> Void

    // MARK: - Private Properties

    @State private var isSelectionEnabled = false
    @State private var keyboardHeight: CGFloat = .zero
    @State private var topPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 24.fitW) {
            if needsReveal {
                WordRevealText(
                    text: category.focusQuestion,
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(category.focusQuestion)
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isSelectionEnabled {
                FocusScrollView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer(minLength: .zero)
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .onAppear {
            if needsReveal {
                isSelectionEnabled = false
                topPadding = 256.fitH
            } else {
                isSelectionEnabled = true
                topPadding = 72.fitW
            }
        }
        .onDisappear {
            transitionTask?.cancel()
        }
        .onChange(of: selectedFocus) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        .onChangeKeyboardHeight { newValue in
            guard keyboardHeight != newValue else { return }
            keyboardHeight = newValue
        }
    }

    // MARK: - Views

    private func FocusScrollView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12.fitW) {
                ForEach(category.focusOptions, id: \.self) { focus in
                    FocusButton(focus)
                }
            }
            .animation(.easeInOut, value: selectedFocus)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .contentMargins(.top, 16.fitW, for: .scrollContent)
        .contentMargins(
            .bottom,
            selectedFocus.isEmpty
            ? 16.fitW
            : keyboardHeight > .zero ? 84.fitW : 115.fitW,
            for: .scrollContent
        )
    }

    private func FocusButton(_ focus: String) -> some View {
        Button {
            onSelect(focus)
        } label: {
            Text(focus)
                .multilineMinimumScale()
                .multilineTextAlignment(.center)
                .font(.system(size: 15.fitW, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20.fitW)
                .frame(height: 52.fitW)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.gray787880.opacity(0.12))
                .clipShape(.capsule)
                .overlay {
                    Capsule()
                        .strokeBorder(.blue007AFF, lineWidth: 1.fitW)
                        .opacity(focus == selectedFocus ? 1 : 0)
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
                isSelectionEnabled = true
            }
        }
    }
}
