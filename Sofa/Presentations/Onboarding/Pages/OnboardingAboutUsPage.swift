//
//  OnboardingAboutUsPage.swift
//  Sofa
//
//  Created by dukes on 11/6/25.
//

import SwiftUI

struct OnboardingAboutUsPage: View {

    // MARK: - Public Properties

    @Binding var selectedSource: OnboardingModel.Source?
    let sources: [OnboardingModel.Source]
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @State private var isSelectionEnabled = false
    @State private var keyboardHeight: CGFloat = .zero
    @State private var topPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            if needsReveal {
                WordRevealText(
                    text: String(localized: "howDidYouHearAboutUs"),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "howDidYouHearAboutUs"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isSelectionEnabled {
                SourcesScrollView()
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
        .onChange(of: selectedSource) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = newValue != nil
        }
        .onChangeKeyboardHeight { newValue in
            guard keyboardHeight != newValue else { return }
            keyboardHeight = newValue
        }
    }

    // MARK: - Views

    private func SourcesScrollView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12.fitW) {
                ForEach(sources, id: \.self) { source in
                    SourceButton(source)
                }
            }
            .animation(.easeInOut, value: selectedSource)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .contentMargins(
            .bottom,
            selectedSource == nil
            ? 16.fitW
            : keyboardHeight > .zero ? 84.fitW : 115.fitW,
            for: .scrollContent
        )
    }

    private func SourceButton(_ source: OnboardingModel.Source) -> some View {
        Button {
            selectedSource = source
        } label: {
            HStack(spacing: .zero) {
                Text(source.title)
                    .multilineMinimumScale()
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20.fitW)
            .frame(height: 48.fitW)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.gray787880.opacity(0.12))
            .clipShape(.capsule)
            .overlay {
                Capsule()
                    .strokeBorder(.blue007AFF, lineWidth: 1.fitW)
                    .opacity(source == selectedSource ? 1 : 0)
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
