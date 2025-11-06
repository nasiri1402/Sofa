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
    @Binding var otherSourceInput: String?
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @FocusState private var isOtherFocused
    @State private var isSelectionEnabled = false
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
                VStack(alignment: .leading, spacing: 12.fitW) {
                    if otherSourceInput != nil {
                        OtherSourceTextField()
                    } else {
                        ForEach(sources, id: \.self) { source in
                            SourceButton(source)
                        }
                    }
                }
                .animation(.easeInOut, value: selectedSource)
                .animation(.easeInOut, value: otherSourceInput == nil)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer(minLength: .zero)
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .contentShape(.rect)
        .onTapGesture {
            isOtherFocused = false
        }
        .onAppear {
            if needsReveal {
                otherSourceInput = nil
                isSelectionEnabled = false
                topPadding = 256.fitH
            } else {
                isSelectionEnabled = true
                topPadding = 72.fitW
            }
        }
        .onDisappear {
            isOtherFocused = false
            transitionTask?.cancel()
        }
        .onChange(of: selectedSource) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = newValue != nil
        }
        .onChange(of: otherSourceInput) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !(newValue ?? "").isEmpty
        }
    }

    // MARK: - Views

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

    private func OtherSourceTextField() -> some View {
        TextField(
            String(localized: "yourAnswer"),
            text: Binding(get: { otherSourceInput ?? "" }, set: { otherSourceInput = $0 }),
            axis: .vertical
        )
        .font(.system(size: 17.fitW))
        .foregroundStyle(.grayE5E5EA)
        .autocorrectionDisabled()
        .focused($isOtherFocused)
        .lineLimit(7)
        .transition(.opacity)
        .onAppear {
            isOtherFocused = true
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
                isSelectionEnabled = true
            }
        }
    }
}
